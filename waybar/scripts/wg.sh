#!/usr/bin/env bash
# WireGuard (wg0) for Waybar, managed through the wg-quick@wg0 systemd service.
#   wg.sh          status JSON for the bar
#   wg.sh menu     on/off menu (left click): connect / disconnect / start on boot
#   wg.sh toggle   quick connect/disconnect (right click)
# Privileged actions go through polkit (the auth dialog appears automatically).
IF=wg0
UNIT="wg-quick@$IF.service"
MENU="$HOME/.local/bin/wofi-menu"

is_up()      { ip link show "$IF" >/dev/null 2>&1; }
svc_active() { systemctl is-active --quiet "$UNIT"; }
on_boot()    { [ "$(systemctl is-enabled "$UNIT" 2>/dev/null)" = enabled ]; }
refresh()    { pkill -RTMIN+13 -x waybar 2>/dev/null || true; }
note()       { notify-send -a WireGuard -t 2500 "󰖂  WireGuard" "$1"; }

connect() {
    if systemctl start "$UNIT"; then
        note "$IF connected"
    else
        # show why: the last lines wg-quick wrote to the journal
        why=$(journalctl -u "$UNIT" -n 4 -o cat --no-pager 2>/dev/null | grep -v '^\[#\]' | tail -3)
        notify-send -u critical -a WireGuard "󰖂  Could not connect $IF" "${why:-Authentication cancelled, or /etc/wireguard/$IF.conf is missing}"
    fi
    refresh
}
disconnect() {
    # brought up by the service -> stop it; brought up by hand with wg-quick -> take it down directly
    if svc_active; then systemctl stop "$UNIT"; else pkexec wg-quick down "$IF"; fi
    is_up && note "Could not disconnect $IF" || note "$IF disconnected"
    refresh
}

case "${1:-}" in
    toggle)
        if is_up; then disconnect; else connect; fi
        exit 0 ;;
    menu)
        if is_up; then state="󰖂  Status: connected"; action="󰅖  Disconnect"
        else           state="󰖂  Status: disconnected"; action="󰌘  Connect"; fi
        if on_boot; then boot="󰔡  Start on boot: on  (click to turn off)"
        else             boot="󰨙  Start on boot: off  (click to turn on)"; fi
        pick=$(printf '%s\n' "$action" "$boot" "$state" |
               "$MENU" wireguard --dmenu --cache-file /dev/null -p "WireGuard $IF" --width 420 --height 200) || exit 0
        case "$pick" in
            *Disconnect*) disconnect ;;
            *Connect*)    connect ;;
            *"boot: on"*)  systemctl disable "$UNIT" && note "Won't start on boot" ; refresh ;;
            *"boot: off"*) systemctl enable  "$UNIT" && note "Will start on boot"  ; refresh ;;
        esac
        exit 0 ;;
esac

boot_txt=$(on_boot && echo "on" || echo "off")
if is_up; then
    printf '{"text":"󰖂","class":"up","tooltip":"WireGuard %s: connected\\nStart on boot: %s\\nClick: menu · Right-click: disconnect"}\n' "$IF" "$boot_txt"
else
    printf '{"text":"󰖂","class":"down","tooltip":"WireGuard %s: down\\nStart on boot: %s\\nClick: menu · Right-click: connect"}\n' "$IF" "$boot_txt"
fi
