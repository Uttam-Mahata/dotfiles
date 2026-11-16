#!/usr/bin/env bash
# Waybar module: red dot while wf-recorder is running (signal 12). Click stops the recording.
if pgrep -x wf-recorder >/dev/null; then
    printf '{"text":"󰑋 REC","class":"recording","tooltip":"Screen recording — click or Super+Shift+R to stop"}\n'
else
    printf '{"text":"","class":"idle"}\n'
fi
