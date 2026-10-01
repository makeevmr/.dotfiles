#!/usr/bin/env python3
"""Exercise the real watcher with isolated audio, player and locker commands."""

import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "media-idle-inhibit.sh"
MOCK = r'''#!/usr/bin/env python3
import json, os, signal, sys, time
from pathlib import Path

state = json.loads(Path(os.environ["MEDIA_IDLE_TEST_STATE"]).read_text())
name = Path(sys.argv[0]).name
args = sys.argv[1:]

def event(kind):
    with open(os.environ["MEDIA_IDLE_TEST_EVENTS"], "a") as log:
        log.write(f"{kind} {os.getpid()}\n")

if name == "pactl":
    if state.get("audio_error"):
        sys.exit(1)
    print(json.dumps(state["streams"]))
elif name == "busctl":
    if "list" in args:
        for player in state["players"]:
            print(player, "100 mock")
    else:
        status = state["players"].get(args[args.index("get-property") + 1])
        if status is None:
            sys.exit(1)
        print('s "' + status + '"')
elif name == "swaymsg":
    if args == ["-t", "get_version", "-r"]:
        sys.exit(0 if state["session"] else 1)
    elif args == ["-t", "get_tree", "-r"]:
        print(json.dumps(state["tree"]))
    else:
        event("display-mutation")
        sys.exit(1)
elif name == "sleep":
    time.sleep(0.04)
elif name == "pgrep":
    sys.exit(0 if state["locked"] else 1)
elif name == "systemd-inhibit":
    assert "--what=idle" in args and "--mode=block" in args
    def stop(*_):
        event("inhibit-stop")
        sys.exit(0)
    for sig in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        signal.signal(sig, stop)
    event("inhibit-start")
    if args[-1] != "infinity":
        time.sleep(float(args[-1]) * 0.04)
        stop()
    while True:
        time.sleep(1)
elif name == "lock.sh":
    assert args == ["-d"]
    event("lock-start")
else:
    raise AssertionError(name)
'''


class MediaIdleTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sway-media-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for command in ("pactl", "busctl", "swaymsg", "sleep", "pgrep", "systemd-inhibit"):
            self.executable(self.bin / command, MOCK)
        (self.root / "sway").mkdir()
        (self.root / "gtklock").mkdir()
        self.script = self.root / "sway" / SCRIPT.name
        shutil.copy2(SCRIPT, self.script)
        self.executable(self.root / "gtklock" / "lock.sh", MOCK)
        self.state = {
            "streams": [], "players": {}, "session": True, "locked": False,
            # Sway workspaces report fullscreen_mode=1 without fullscreen video.
            "tree": {"type": "workspace", "fullscreen_mode": 1, "nodes": []},
        }
        self.state_file = self.root / "state.json"
        self.events_file = self.root / "events"
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}",
                        XDG_RUNTIME_DIR=str(self.root),
                        MEDIA_IDLE_TEST_STATE=str(self.state_file),
                        MEDIA_IDLE_TEST_EVENTS=str(self.events_file))
        self.update()

    @staticmethod
    def executable(path, contents):
        path.write_text(contents)
        path.chmod(0o755)

    def update(self, **changes):
        self.state.update(changes)
        staging = self.state_file.with_suffix(".new")
        staging.write_text(json.dumps(self.state))
        staging.replace(self.state_file)

    def events(self, kind):
        lines = self.events_file.read_text().splitlines() if self.events_file.exists() else []
        return [int(line.split()[1]) for line in lines if line.split()[0] == kind]

    def wait_for(self, condition):
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if condition():
                return
            time.sleep(0.02)
        self.fail("Watcher did not reach the expected state")

    def run_mode(self, mode):
        return subprocess.run([str(self.script), mode], env=self.env,
                              capture_output=True, text=True, timeout=5).returncode

    def watcher(self):
        process = subprocess.Popen([str(self.script)], env=self.env,
                                   stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        def cleanup():
            if process.poll() is None:
                process.terminate()
            process.communicate(timeout=5)
        self.addCleanup(cleanup)
        return process

    def test_audio_and_all_players(self):
        cases = [
            ([], {}, 1),
            ([{"corked": True}], {}, 1),
            ([{"corked": False, "mute": True}], {}, 0),
            ([], {"org.mpris.MediaPlayer2.browser": "Playing"}, 0),
            ([], {"org.mpris.MediaPlayer2.first": "Stopped",
                  "org.mpris.MediaPlayer2.background": "Playing"}, 0),
            ([], {"org.mpris.MediaPlayer2.browser": "Paused"}, 1),
            ([], {"org.mpris.MediaPlayer2.browser": "Stopped"}, 1),
            ([], {"org.mpris.MediaPlayer2.disappeared": None}, 1),
        ]
        for streams, players, expected in cases:
            with self.subTest(streams=streams, players=players):
                self.update(streams=streams, players=players)
                self.assertEqual(self.run_mode("--check"), expected)
        self.update(audio_error=True, players={"org.mpris.MediaPlayer2.video": "Playing"})
        self.assertEqual(self.run_mode("--check"), 0)

    def test_no_lock_surface_during_playback_or_when_already_locked(self):
        for changes in ({"streams": [{"corked": False}]},
                        {"streams": [], "players": {"org.mpris.MediaPlayer2.video": "Playing"}},
                        {"players": {}, "locked": True}):
            self.update(**changes)
            self.assertEqual(self.run_mode("--lock"), 0)
            self.assertEqual(self.events("lock-start"), [])
        self.update(locked=False, players={"org.mpris.MediaPlayer2.video": "Paused"})
        self.assertEqual(self.run_mode("--lock"), 0)
        self.assertEqual(len(self.events("lock-start")), 1)
        self.assertEqual(self.events("display-mutation"), [])
        self.wait_for(lambda: len(self.events("inhibit-start")) == len(self.events("inhibit-stop")))

    def test_playback_at_deadline_rearms_without_a_watcher(self):
        self.update(players={"org.mpris.MediaPlayer2.video": "Playing"})
        self.assertEqual(self.run_mode("--lock"), 0)
        self.wait_for(lambda: len(self.events("inhibit-start")) == 1)
        # Playback ends before the next five-second watcher poll.
        self.update(players={})
        self.wait_for(lambda: len(self.events("inhibit-stop")) == 1)
        self.assertEqual(self.events("lock-start"), [])
        self.assertEqual(self.events("display-mutation"), [])

    def test_inhibitor_is_stable_releases_on_pause_and_cleans_up(self):
        self.update(players={"org.mpris.MediaPlayer2.background": "Playing"})
        process = self.watcher()
        self.wait_for(lambda: len(self.events("inhibit-start")) == 1)
        time.sleep(0.35)
        self.assertEqual(len(self.events("inhibit-start")), 1)
        self.assertEqual(self.events("inhibit-stop"), [])
        self.assertEqual(self.events("lock-start"), [])
        self.assertEqual(self.events("display-mutation"), [])
        # A second watcher must not create a second inhibitor.
        second = self.watcher()
        self.assertEqual(second.wait(timeout=5), 0)
        self.update(players={"org.mpris.MediaPlayer2.background": "Paused"})
        self.wait_for(lambda: len(self.events("inhibit-stop")) == 1)
        self.update(streams=[{"corked": False}])
        self.wait_for(lambda: len(self.events("inhibit-start")) == 2)
        process.terminate()
        self.assertEqual(process.wait(timeout=5), 0)
        self.assertEqual(len(self.events("inhibit-stop")), 2)

    def test_workspace_metadata_does_not_inhibit_and_session_exit_releases(self):
        process = self.watcher()
        time.sleep(0.35)
        self.assertIsNone(process.poll())
        self.assertEqual(self.events("inhibit-start"), [])
        self.update(streams=[{"corked": False}])
        self.wait_for(lambda: len(self.events("inhibit-start")) == 1)
        self.update(session=False)
        self.assertEqual(process.wait(timeout=5), 0)
        self.assertEqual(len(self.events("inhibit-stop")), 1)

    def test_recreates_an_inhibitor_if_its_process_exits(self):
        self.update(streams=[{"corked": False}])
        process = self.watcher()
        self.wait_for(lambda: len(self.events("inhibit-start")) == 1)
        os.kill(self.events("inhibit-start")[0], signal.SIGTERM)
        self.wait_for(lambda: len(self.events("inhibit-start")) == 2)
        self.assertIsNone(process.poll())
        self.update(streams=[{"corked": True}])
        self.wait_for(lambda: len(self.events("inhibit-stop")) == 2)


if __name__ == "__main__":
    unittest.main()
