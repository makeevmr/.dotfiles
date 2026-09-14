#!/bin/sh
set -eu

inhibited_id=
poll_interval=15

clear_inhibitor() {
    if [ -n "$inhibited_id" ]; then
        swaymsg "[con_id=$inhibited_id] inhibit_idle none" >/dev/null 2>&1 || true
        inhibited_id=
    fi
}

trap clear_inhibitor EXIT
trap 'exit 0' HUP INT TERM

while :; do
    tree=$(swaymsg -t get_tree -r)

    # Audio is visible through PipeWire even when its application does not
    # implement Wayland idle inhibition. Muted video has no audio stream, so
    # also honor application-provided inhibitors and fullscreen windows.
    if pactl -f json list sink-inputs 2>/dev/null \
        | jq -e 'any(.[]; .corked == false)' >/dev/null \
        || printf '%s\n' "$tree" \
        | jq -e 'any(.. | objects;
            .idle_inhibitors?.application == "enabled"
            or ((.fullscreen_mode? // 0) != 0))' >/dev/null; then
        focused_id=$(printf '%s\n' "$tree" \
            | jq -r 'first(.. | objects | select(.focused? == true) | .id) // empty')

        if [ -n "$focused_id" ] && [ "$focused_id" != "$inhibited_id" ]; then
            clear_inhibitor
            if swaymsg "[con_id=$focused_id] inhibit_idle open" >/dev/null; then
                inhibited_id=$focused_id
            fi
        fi
    else
        clear_inhibitor
    fi

    sleep "$poll_interval"
done
