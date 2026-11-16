-- Environment and session services
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

local home = os.getenv("HOME")

-- true when a program is installed (optional extras are skipped when missing)
local function has(bin)
    return os.execute("command -v " .. bin .. " >/dev/null 2>&1") == true
end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- native Wayland for Qt / Electron / Firefox
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")
if has("qt6ct") then hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") end

hl.on("hyprland.start", function()
    -- bar, notifications, and the auth agent GUI apps need for admin prompts
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- wallpaper, idle/lock, clipboard history
    hl.exec_cmd(home .. "/.local/bin/daily-wallpaper daily")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- low-battery warnings (15% / 7%)
    hl.exec_cmd(home .. "/.local/bin/battery-notify")

    -- dark preference for GTK/libadwaita apps
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")

    -- optional extras, used when installed
    if has("hyprsunset") then hl.exec_cmd("hyprsunset") end   -- night light schedule: hypr/hyprsunset.conf
end)

-- Monitor hot-plug: put workspaces 6-10 back on the external screen when it returns
local monitorSync = home .. "/.config/hypr/scripts/monitor-sync.sh"
hl.on("monitor.added",   function() hl.exec_cmd(monitorSync) end)
hl.on("monitor.removed", function() hl.exec_cmd(monitorSync) end)
