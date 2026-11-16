#!/usr/bin/env bash
# Tailscale exit node for Waybar.
#   (no args)  JSON status for the bar
#   menu       pick an exit node (or "off") from a wofi list   <- left click
#   toggle     clear the node / re-apply the last one          <- right click
#   set X      set node by name or IP ("off" clears)
state="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-ts-exit"
UP="󰒍"; DOWN="󰒎"

status_json() { tailscale status --json 2>/dev/null; }

# prints: "<hostname>\t<ip>" of the active exit node, or nothing
current() {
  status_json | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    peers = (d.get("Peer") or {}).values()
    cur = next((p for p in peers if p.get("ExitNode")), None)
    if cur is None:
        eid = (d.get("ExitNodeStatus") or {}).get("ID")
        cur = next((p for p in peers if eid and p.get("ID") == eid), None)
    if cur:
        print(cur["HostName"] + "\t" + cur["TailscaleIPs"][0])
except Exception:
    pass'
}

refresh_bar() { pkill -RTMIN+9 -x waybar 2>/dev/null; true; }

# run `tailscale set ...`; on "access denied" make this user the Tailscale operator once
# (polkit password prompt), then retry — after that no root is needed from the bar.
ts_set() {
  local out
  out=$(tailscale set "$@" 2>&1) && return 0
  if grep -qi 'access denied' <<<"$out"; then
    notify-send -a Tailscale -t 4000 "Exit node" "One-time setup: allowing $USER to control Tailscale…" 2>/dev/null
    if pkexec tailscale set --operator="$USER" >/dev/null 2>&1; then
      out=$(tailscale set "$@" 2>&1) && return 0
    else
      out="Permission was not granted (polkit prompt cancelled or failed)."
    fi
  fi
  notify-send -u normal -t 8000 -a Tailscale "Exit node" "$out" 2>/dev/null
  return 1
}

# make sure the daemon is up and logged in before changing anything
ensure_running() {
  local st
  st=$(status_json | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("BackendState",""))
except Exception: print("")')
  case "$st" in
    Running) return 0 ;;
    "")
      if ! systemctl is-active --quiet tailscaled; then
        notify-send -a Tailscale "Tailscale" "Starting the tailscaled service…" 2>/dev/null
        systemctl start tailscaled || { notify-send -u normal -t 8000 -a Tailscale "Tailscale" "Could not start tailscaled"; return 1; }
        sleep 2
      fi ;;
    NeedsLogin)
      notify-send -u normal -t 8000 -a Tailscale "Tailscale" "Not logged in — run: tailscale up" 2>/dev/null; return 1 ;;
    Stopped)
      ts_up=$(tailscale up 2>&1) || { notify-send -u normal -t 8000 -a Tailscale "Tailscale" "$ts_up"; return 1; } ;;
  esac
}

apply() {  # $1 = name/ip or "off"
  ensure_running || return 1
  if [ "$1" = off ]; then
    ts_set --exit-node= || return 1
  else
    ts_set --exit-node="$1" --exit-node-allow-lan-access=true || return 1
  fi
  refresh_bar
}

case "$1" in
  set)
    [ -n "$2" ] && apply "$2"
    exit ;;
  toggle)
    IFS=$'\t' read -r name ip < <(current)
    if [ -n "$ip" ]; then
      echo "$ip" > "$state"; apply off
    elif [ -s "$state" ]; then
      apply "$(cat "$state")"
    else
      "$0" menu
    fi
    exit ;;
  menu)
    choices=$(status_json | python3 -c '
import json, sys
d = json.load(sys.stdin)
peers = sorted((d.get("Peer") or {}).values(), key=lambda p: p["HostName"].lower())
aid = (d.get("ExitNodeStatus") or {}).get("ID")
is_exit = lambda p: bool(p.get("ExitNode") or (aid and p.get("ID") == aid))
active = any(is_exit(p) for p in peers)
print(("   " if active else "\u25cf ") + "Off (direct internet)" + "\t")
for p in peers:
    if not p.get("ExitNodeOption"):
        continue
    mark = "\u25cf " if is_exit(p) else "   "
    tail = "" if p.get("Online") else "  (offline)"
    print(mark + p["HostName"] + tail + "\t" + p["TailscaleIPs"][0])
')
    [ -z "$choices" ] && { notify-send "Exit node" "tailscale not reachable"; exit 1; }
    pick=$(cut -f1 <<<"$choices" | "$HOME/.local/bin/wofi-menu" tailscale --dmenu --cache-file /dev/null -p "Exit node" --width 380 --height 300) || exit 0
    [ -z "$pick" ] && exit 0
    ip=$(awk -F'\t' -v p="$pick" '$1 == p {print $2}' <<<"$choices")
    if [ -z "$ip" ]; then apply off; else apply "$ip"; fi
    exit ;;
esac

# status for the bar
IFS=$'\t' read -r name ip < <(current)
if [ -n "$name" ]; then
  printf '{"text":"%s  %s","class":"up","tooltip":"Exit node: %s (%s)\\nLeft click: choose node\\nRight click: toggle off/on"}\n' "$UP" "$name" "$name" "$ip"
else
  printf '{"text":"%s","class":"down","tooltip":"Tailscale: no exit node\\nLeft click: choose node\\nRight click: re-apply last node"}\n' "$DOWN"
fi
