#!/usr/bin/env bash
# Power menu for Waybar (wofi). Reboot / shutdown / log out ask for confirmation.
choice=$(printf '%s\n' "  Lock" "󰤄  Suspend" "󰜉  Reboot" "󰐥  Shutdown" "󰍃  Log out" |
    wofi --dmenu --cache-file /dev/null -p "Power" --width 300 --height 270) || exit 0
confirm() {
  [ "$(printf 'No\nYes\n' | wofi --dmenu --cache-file /dev/null -p "$1?" --width 260 --height 130)" = Yes ]
}
case "$choice" in
  *Lock)     loginctl lock-session ;;
  *Suspend)  systemctl suspend ;;
  *Reboot)   confirm Reboot   && systemctl reboot ;;
  *Shutdown) confirm Shutdown && systemctl poweroff ;;
  *"Log out") confirm "Log out" && {
      uwsm check is-active >/dev/null 2>&1 && uwsm stop || hyprctl dispatch 'hl.dsp.exit()'
  } ;;
esac
