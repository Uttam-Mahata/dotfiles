#!/usr/bin/env python3
"""
Wi-Fi Manager for Waybar using nmcli and wofi.
Allows instantaneous scanning (using cached APs), connecting,
disconnecting, and toggles closed if clicked again.
"""

import subprocess
import sys
import os
import signal
import atexit

PID_FILE = "/tmp/waybar-wifi-menu.pid"

def toggle_singleton():
    if os.path.exists(PID_FILE):
        try:
            with open(PID_FILE, "r") as f:
                old_pid = int(f.read().strip())
            os.kill(old_pid, 0)
            # Process is running -> kill process group to close old menu (toggle off)
            try:
                os.killpg(os.getpgid(old_pid), signal.SIGTERM)
            except Exception:
                os.kill(old_pid, signal.SIGTERM)
            if os.path.exists(PID_FILE):
                os.remove(PID_FILE)
            sys.exit(0)
        except (ProcessLookupError, ValueError):
            pass
        except Exception:
            pass

    try:
        os.setpgrp()
    except Exception:
        pass

    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

def cleanup():
    if os.path.exists(PID_FILE):
        try:
            with open(PID_FILE, "r") as f:
                if int(f.read().strip()) == os.getpid():
                    os.remove(PID_FILE)
        except Exception:
            pass

atexit.register(cleanup)

def run_cmd(cmd, check=False):
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=check)
        return res.stdout.strip(), res.returncode
    except Exception as e:
        return str(e), 1

def notify(title, message, urgency="normal"):
    subprocess.run(["notify-send", "-u", urgency, "-i", "network-wireless", title, message])

def get_wifi_device():
    out, _ = run_cmd(["nmcli", "-t", "-f", "DEVICE,TYPE", "device"])
    for line in out.splitlines():
        parts = line.split(":")
        if len(parts) >= 2 and parts[1] == "wifi":
            return parts[0]
    return "wlo1"

def is_wifi_enabled():
    out, _ = run_cmd(["nmcli", "radio", "wifi"])
    return out.strip().lower() == "enabled"

def get_saved_connections():
    out, _ = run_cmd(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"])
    saved = set()
    for line in out.splitlines():
        parts = line.split(":")
        if len(parts) >= 2 and "wireless" in parts[1]:
            saved.add(parts[0])
    return saved

def get_wifi_list(rescan=False):
    cmd = ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
    if not rescan:
        cmd.extend(["--rescan", "no"])
    else:
        cmd.extend(["--rescan", "yes"])

    out, _ = run_cmd(cmd)
    networks = {}
    current_ssid = None

    for line in out.splitlines():
        if not line.strip():
            continue
        parts = line.split(":")
        if len(parts) >= 4:
            in_use = (parts[0] == "*")
            security = parts[-1]
            try:
                signal = int(parts[-2])
            except ValueError:
                signal = 0
            ssid = ":".join(parts[1:-2]).strip()
            if not ssid:
                continue

            if in_use:
                current_ssid = ssid

            if ssid not in networks or signal > networks[ssid]["signal"]:
                networks[ssid] = {
                    "signal": signal,
                    "security": security if security else "Open",
                    "in_use": in_use
                }

    return networks, current_ssid

def prompt_wofi(prompt_text, items, width=440, height=380, password=False):
    cmd = [
        "wofi",
        "--dmenu",
        "--cache-file", "/dev/null",
        "-p", prompt_text,
        "--width", str(width),
        "--height", str(height)
    ]
    if password:
        cmd.append("--password")

    input_text = "\n".join(items) if items else ""
    res = subprocess.run(cmd, input=input_text, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode == 0:
        return res.stdout.strip()
    return None

def main():
    toggle_singleton()

    wifi_dev = get_wifi_device()
    wifi_on = is_wifi_enabled()

    if not wifi_on:
        choice = prompt_wofi("Wi-Fi is Off", ["󰖩  Turn Wi-Fi On", "󰅖  Cancel"], height=160)
        if choice and "Turn Wi-Fi On" in choice:
            run_cmd(["nmcli", "radio", "wifi", "on"])
            notify("Wi-Fi", "Wi-Fi turned on")
        return

    # Instant load using cached scan table (--rescan no)
    networks, current_ssid = get_wifi_list(rescan=False)
    saved_conns = get_saved_connections()

    menu_lines = []
    actions = {}

    if current_ssid:
        key_disc = f"󰤭  Disconnect from {current_ssid}"
        menu_lines.append(key_disc)
        actions[key_disc] = ("disconnect", current_ssid)

    key_rescan = "󰑐  Rescan Networks"
    menu_lines.append(key_rescan)
    actions[key_rescan] = ("rescan", None)

    key_off = "󰖪  Turn Wi-Fi Off"
    menu_lines.append(key_off)
    actions[key_off] = ("turn_off", None)

    sorted_ssids = sorted(
        networks.keys(),
        key=lambda s: (networks[s]["in_use"], networks[s]["signal"]),
        reverse=True
    )

    for ssid in sorted_ssids:
        info = networks[ssid]
        sig = info["signal"]
        sec = info["security"]
        in_use = info["in_use"]

        if in_use:
            icon = "󰤨 [Active]"
        elif sig >= 70:
            icon = "󰤨"
        elif sig >= 45:
            icon = "󰤥"
        elif sig >= 20:
            icon = "󰤢"
        else:
            icon = "󰤟"

        saved_tag = " ★" if ssid in saved_conns else ""
        label = f"{icon}  {ssid:<26} {sig:>3}%  [{sec}]{saved_tag}"
        menu_lines.append(label)
        actions[label] = ("connect", (ssid, sec, ssid in saved_conns, in_use))

    selected = prompt_wofi("Wi-Fi Networks", menu_lines, width=480, height=420)
    if not selected:
        return

    action_type, data = actions.get(selected, (None, None))
    if not action_type:
        return

    if action_type == "turn_off":
        run_cmd(["nmcli", "radio", "wifi", "off"])
        notify("Wi-Fi", "Wi-Fi turned off")
    elif action_type == "disconnect":
        run_cmd(["nmcli", "device", "disconnect", wifi_dev])
        notify("Wi-Fi", f"Disconnected from {data}")
    elif action_type == "rescan":
        notify("Wi-Fi", "Scanning for networks...")
        run_cmd(["nmcli", "device", "wifi", "rescan"])
        cleanup()
        os.execv(sys.executable, [sys.executable] + sys.argv)
    elif action_type == "connect":
        ssid, sec, is_saved, in_use = data
        if in_use:
            notify("Wi-Fi", f"Already connected to {ssid}")
            return

        notify("Wi-Fi", f"Connecting to {ssid}...")

        if is_saved:
            out, code = run_cmd(["nmcli", "connection", "up", "id", ssid])
            if code == 0:
                notify("Wi-Fi", f"Connected to {ssid}")
                return

        if sec == "Open" or sec == "--":
            out, code = run_cmd(["nmcli", "device", "wifi", "connect", ssid])
            if code == 0:
                notify("Wi-Fi", f"Connected to {ssid}")
            else:
                notify("Wi-Fi Error", f"Failed to connect:\n{out}", urgency="critical")
            return

        pwd = prompt_wofi(f"Password for {ssid}", [], width=380, height=140, password=True)
        if not pwd:
            return

        out, code = run_cmd(["nmcli", "device", "wifi", "connect", ssid, "password", pwd])
        if code == 0:
            notify("Wi-Fi", f"Connected to {ssid}")
        else:
            notify("Wi-Fi Error", f"Failed to connect to {ssid}:\n{out}", urgency="critical")

if __name__ == "__main__":
    main()
