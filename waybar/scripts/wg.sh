#!/usr/bin/env bash
# WireGuard wg0 status for Waybar; `wg.sh toggle` flips it via wg-quick.
if [ "$1" = toggle ]; then
  if ip link show wg0 >/dev/null 2>&1; then
    pkexec wg-quick down wg0
  else
    pkexec wg-quick up wg0
  fi
  exit
fi
if ip link show wg0 >/dev/null 2>&1; then
  echo '{"text":"󰖂","class":"up","tooltip":"WireGuard wg0: connected"}'
else
  echo '{"text":"󰖂","class":"down","tooltip":"WireGuard wg0: down"}'
fi
