#!/usr/bin/env bash
# Run by Hyprland on every monitor hot-plug (monitor.added / monitor.removed) and at login.
#  extend mode : workspaces 6-10 go (back) to the external monitor when it is present.
#  external mode, external gone : switch back to extend so the laptop panel comes back on.
#  mirror / laptop : nothing to do.
EXT="HDMI-A-1"
STATE="$HOME/.local/state/display-mode"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/monitor-sync.log"
log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >> "$LOG"; }

sleep 1   # let the new output finish initialising before touching workspaces
mode=$(cat "$STATE" 2>/dev/null); mode=${mode:-extend}
present=$(hyprctl monitors -j | jq -r --arg m "$EXT" '[.[]|select(.name==$m)]|length')
log "event: mode=$mode external_present=$present monitors=$(hyprctl monitors -j | jq -r '[.[].name]|join(",")')"

if [ "$mode" = external ] && [ "$present" = 0 ]; then
    log "external gone while laptop panel was off -> back to extend"
    echo extend > "$STATE"
    hyprctl reload >/dev/null
    exit 0
fi

[ "$mode" = extend ] && [ "$present" != 0 ] || exit 0

for ws in 6 7 8 9 10; do
    cur=$(hyprctl workspaces -j | jq -r --argjson id "$ws" '.[] | select(.id == $id) | .monitor')
    if [ -n "$cur" ] && [ "$cur" != "$EXT" ]; then
        log "moving workspace $ws from $cur to $EXT"
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = $ws, monitor = \"$EXT\" })" >/dev/null
    fi
done
