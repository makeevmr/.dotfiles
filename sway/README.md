# Idle locking

`swayidle` locks after 300 seconds without input or a playback inhibitor.
`media-idle-inhibit.sh` checks active PulseAudio/PipeWire audio streams and every
MPRIS player's `PlaybackStatus` every five seconds. Active playback holds one
logind idle inhibitor, including background playback and players on other
workspaces. Paused/stopped players and corked audio streams do not inhibit idle.
When playback stops, the five-minute idle timer starts again.

Sway's native Wayland application inhibitors remain supported. Fullscreen
windows and workspace metadata alone do not count as playback. Silent video
must expose MPRIS playback status or a Wayland idle inhibitor to be detected.

At the idle deadline, `--lock` checks playback again before starting `gtklock`.
If playback is detected, a six-second idle inhibitor rearms the timer even if
playback stops before the watcher sees it. It skips an already running locker.
The watcher does not dim the screen, toggle
display power, change focus, or launch/cancel a locker periodically.
Manual locking and locking before suspend continue to work during playback.

Dependencies: `swayidle`, `pactl` (from `pulseaudio-utils`), `jq`, `busctl` and
`systemd-inhibit` (from systemd), and `flock` (from util-linux).

To inspect playback detection without locking:

```sh
~/.config/sway/media-idle-inhibit.sh --check
# Exit status 0: playing; 1: no playback detected.
```

Run the isolated playback, lock-guard and watcher lifecycle tests from the
repository root with `python3 -B -m unittest discover -s sway/tests -v`.
