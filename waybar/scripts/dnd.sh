#!/usr/bin/env bash
# Waybar module: dunst do-not-disturb state. Click toggles, right-click shows the last notification.
# Refreshed with signal 11 (pkill -RTMIN+11 waybar).
if [ "${1:-}" = toggle ]; then dunstctl set-paused toggle; pkill -RTMIN+11 waybar; exit 0; fi
if [ "$(dunstctl is-paused 2>/dev/null)" = true ]; then
    n=$(dunstctl count waiting 2>/dev/null || echo 0)
    printf '{"text":"󰂛","class":"dnd","tooltip":"Do not disturb is on (%s waiting)\\nClick to turn off · Super+Alt+N"}\n' "$n"
else
    printf '{"text":"󰂚","class":"on","tooltip":"Notifications on\\nClick: do not disturb · Right-click: last notification"}\n'
fi
