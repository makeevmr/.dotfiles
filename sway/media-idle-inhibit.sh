#!/bin/sh
set -eu

media_playing() {
    # Uncorked streams include background audio and video with a muted sink.
    if timeout 2s pactl -f json list sink-inputs 2>/dev/null \
        | jq -e 'any(.[]; .corked == false)' >/dev/null; then
        return 0
    fi

    # Query every player, including browsers and players on other workspaces.
    # MPRIS also covers silent video which has no audio stream.
    players=$(busctl --user --timeout=2s --acquired --full --no-pager --no-legend list 2>/dev/null \
        | awk '$1 ~ /^org\.mpris\.MediaPlayer2\./ {print $1}')
    for player in $players; do
        if [ "$(busctl --user --timeout=2s --auto-start=no get-property "$player" \
            /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlaybackStatus \
            2>/dev/null)" = 's "Playing"' ]; then
            return 0
        fi
    done
    return 1
}

case ${1-} in
    --check)
        media_playing
        exit $?
        ;;
    --lock)
        # Close the polling race before mapping any lock surface. Starting a
        # locker and then cancelling it would make the screen blink.
        if pgrep -x gtklock >/dev/null; then
            exit 0
        fi
        if media_playing; then
            # swayidle fires each timeout only once. Even very brief playback
            # missed by the watcher must rearm it. Outlive one watcher poll and
            # return immediately so swayidle -w can process the inhibit signal.
            systemd-inhibit --what=idle --who=sway-media-deadline \
                --why="Playback at the idle deadline; rearm the timer" \
                --mode=block sleep 6 >/dev/null 2>&1 &
            exit 0
        fi
        config_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
        exec "$config_dir/../gtklock/lock.sh" -d
        ;;
    '') ;;
    *)
        printf 'Usage: %s [--check|--lock]\n' "$0" >&2
        exit 2
        ;;
esac

# Only one watcher per session. Do not pass this lock to the inhibitor child.
exec 9>"${XDG_RUNTIME_DIR:?}/sway-media-idle-inhibit.lock"
flock -n 9 || exit 0

inhibitor_pid=
poll_interval=5

clear_inhibitor() {
    if [ -n "$inhibitor_pid" ]; then
        # systemd-inhibit terminates its command when its own process exits.
        kill "$inhibitor_pid" 2>/dev/null || true
        wait "$inhibitor_pid" 2>/dev/null || true
        inhibitor_pid=
    fi
}

trap clear_inhibitor EXIT
trap 'exit 0' HUP INT TERM

# Exit and release the logind inhibitor when this Sway session goes away.
while swaymsg -t get_version -r >/dev/null 2>&1; do
    if media_playing; then
        if [ -z "$inhibitor_pid" ] || ! kill -0 "$inhibitor_pid" 2>/dev/null; then
            clear_inhibitor
            # swayidle honors logind idle inhibitors. This works even with no
            # open windows and never changes focus, brightness or output power.
            systemd-inhibit --what=idle --who=sway-media \
                --why="Audio or video is playing" --mode=block sleep infinity 9>&- &
            inhibitor_pid=$!
        fi
    else
        clear_inhibitor
    fi

    sleep "$poll_interval"
done
