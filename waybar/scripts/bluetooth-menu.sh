#!/usr/bin/env python3
"""
Bluetooth Manager for Waybar using bluetoothctl and wofi.
Allows viewing controller status, scanning for devices, pairing,
connecting, disconnecting, and toggles closed if clicked again.
"""

import subprocess
import sys
import os
import re
import signal
import atexit

PID_FILE = "/tmp/waybar-bluetooth-menu.pid"

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

def run_cmd(cmd, timeout=10):
    try:
        res = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout
        )
        return res.stdout.strip(), res.returncode
    except subprocess.TimeoutExpired:
        return "Command timed out", 1
    except Exception as e:
        return str(e), 1

def notify(title, message, urgency="normal"):
    subprocess.run(["notify-send", "-u", urgency, "-i", "bluetooth", title, message])

def is_powered_on():
    out, _ = run_cmd(["bluetoothctl", "show"])
    return "Powered: yes" in out

def get_devices():
    devices = {}

    out, _ = run_cmd(["bluetoothctl", "devices"])
    for line in out.splitlines():
        line = line.strip()
        m = re.match(r"^Device\s+([0-9A-Fa-f:]{17})\s+(.*)$", line)
        if m:
            mac, name = m.group(1), m.group(2).strip()
            devices[mac] = {
                "mac": mac,
                "name": name,
                "paired": False,
                "connected": False
            }

    out_paired, _ = run_cmd(["bluetoothctl", "devices", "Paired"])
    for line in out_paired.splitlines():
        m = re.match(r"^Device\s+([0-9A-Fa-f:]{17})\s+(.*)$", line.strip())
        if m:
            mac = m.group(1)
            if mac in devices:
                devices[mac]["paired"] = True
            else:
                devices[mac] = {"mac": mac, "name": m.group(2).strip(), "paired": True, "connected": False}

    out_conn, _ = run_cmd(["bluetoothctl", "devices", "Connected"])
    for line in out_conn.splitlines():
        m = re.match(r"^Device\s+([0-9A-Fa-f:]{17})\s+(.*)$", line.strip())
        if m:
            mac = m.group(1)
            if mac in devices:
                devices[mac]["connected"] = True
            else:
                devices[mac] = {"mac": mac, "name": m.group(2).strip(), "paired": True, "connected": True}

    return devices

def prompt_wofi(prompt_text, items, width=440, height=360):
    cmd = [
        "wofi",
        "--dmenu",
        "--cache-file", "/dev/null",
        "-p", prompt_text,
        "--width", str(width),
        "--height", str(height)
    ]
    input_text = "\n".join(items) if items else ""
    res = subprocess.run(cmd, input=input_text, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode == 0:
        return res.stdout.strip()
    return None

def main():
    toggle_singleton()

    if not is_powered_on():
        choice = prompt_wofi("Bluetooth is Off", ["󰂲  Turn Bluetooth On", "󰅖  Cancel"], height=160)
        if choice and "Turn Bluetooth On" in choice:
            run_cmd(["bluetoothctl", "power", "on"])
            notify("Bluetooth", "Bluetooth turned on")
        return

    devices = get_devices()

    menu_lines = []
    actions = {}

    key_scan = "󰑐  Scan for Devices (5s)"
    menu_lines.append(key_scan)
    actions[key_scan] = ("scan", None)

    key_off = "󰂲  Turn Bluetooth Off"
    menu_lines.append(key_off)
    actions[key_off] = ("turn_off", None)

    connected_devs = [d for d in devices.values() if d["connected"]]
    paired_devs = [d for d in devices.values() if d["paired"] and not d["connected"]]
    other_devs = [d for d in devices.values() if not d["paired"] and not d["connected"]]

    for d in connected_devs:
        label = f"󰂱  [Connected] {d['name']} ({d['mac']})"
        menu_lines.append(label)
        actions[label] = ("connected_device", d)

    for d in paired_devs:
        label = f"󰂯  [Paired]    {d['name']} ({d['mac']})"
        menu_lines.append(label)
        actions[label] = ("connect_device", d)

    for d in other_devs:
        name = d["name"]
        if name == d["mac"].replace(":", "-"):
            continue
        label = f"󰂰  {name} ({d['mac']})"
        menu_lines.append(label)
        actions[label] = ("pair_device", d)

    selected = prompt_wofi("Bluetooth Devices", menu_lines, width=480, height=380)
    if not selected:
        return

    action_type, dev = actions.get(selected, (None, None))
    if not action_type:
        return

    if action_type == "turn_off":
        run_cmd(["bluetoothctl", "power", "off"])
        notify("Bluetooth", "Bluetooth turned off")

    elif action_type == "scan":
        notify("Bluetooth", "Scanning for nearby devices...")
        subprocess.run(["bluetoothctl", "--timeout", "5", "scan", "on"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        cleanup()
        os.execv(sys.executable, [sys.executable] + sys.argv)

    elif action_type == "connected_device":
        sub_choice = prompt_wofi(
            dev["name"],
            [f"󰤭  Disconnect from {dev['name']}", f"󰆴  Unpair / Forget {dev['name']}", "󰅖  Cancel"],
            width=380,
            height=200
        )
        if not sub_choice:
            return
        if "Disconnect" in sub_choice:
            run_cmd(["bluetoothctl", "disconnect", dev["mac"]])
            notify("Bluetooth", f"Disconnected from {dev['name']}")
        elif "Unpair" in sub_choice:
            run_cmd(["bluetoothctl", "remove", dev["mac"]])
            notify("Bluetooth", f"Unpaired {dev['name']}")

    elif action_type == "connect_device":
        notify("Bluetooth", f"Connecting to {dev['name']}...")
        out, code = run_cmd(["bluetoothctl", "connect", dev["mac"]], timeout=15)
        if code == 0 and "Successful" in out:
            notify("Bluetooth", f"Connected to {dev['name']}")
        else:
            notify("Bluetooth", f"Connection response:\n{out}")

    elif action_type == "pair_device":
        notify("Bluetooth", f"Pairing with {dev['name']}...")
        run_cmd(["bluetoothctl", "pair", dev["mac"]], timeout=15)
        run_cmd(["bluetoothctl", "trust", dev["mac"]])
        out, code = run_cmd(["bluetoothctl", "connect", dev["mac"]], timeout=15)
        if code == 0 and "Successful" in out:
            notify("Bluetooth", f"Connected to {dev['name']}")
        else:
            notify("Bluetooth", f"Pairing result:\n{out}")

if __name__ == "__main__":
    main()
