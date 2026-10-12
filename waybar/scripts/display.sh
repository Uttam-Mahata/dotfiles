#!/usr/bin/env bash
# Waybar module: icon for the current display mode (extend / mirror / external / laptop).
# Click opens the display menu; display-mode refreshes this module (signal 10) after a switch.
mode=$(cat "$HOME/.local/state/display-mode" 2>/dev/null); mode=${mode:-extend}
case "$mode" in
  mirror)   icon=$'\U000f0322 \U000f0379'; label="Mirror: the external screen shows the laptop's picture" ;;
  external) icon=$'\U000f0379';           label="External only: laptop panel is off" ;;
  laptop)   icon=$'\U000f0322';           label="Laptop only: external screen is off" ;;
  *)        mode=extend; icon=$'\U000f0380'; label="Extend: separate screens" ;;
esac
printf '{"text":"%s","class":"%s","tooltip":"%s\\nClick to change (Super+Shift+P)"}\n' "$icon" "$mode" "$label"
