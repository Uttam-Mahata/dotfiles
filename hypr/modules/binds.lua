-- Keybindings. Every bind made with bind(..., "description") is listed in the
-- searchable cheatsheet (Super + /), generated into ~/.cache/hypr/keybinds.txt.
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local home     = os.getenv("HOME")
local bin      = home .. "/.local/bin/"
local mainMod  = "SUPER"

local terminal    = "kitty"
local fileManager = "yazi-term"
local menu        = "wofi --show drun"

local sheet = {}
local function bind(keys, dispatcher, desc, opts)
    opts = opts or {}
    if desc then
        opts.description = desc
        sheet[#sheet + 1] = string.format("%-26s  %s", keys:gsub("SUPER", "󰣇"), desc)
    end
    return hl.bind(keys, dispatcher, opts)
end
local function M(keys) return mainMod .. " + " .. keys end
local function sh(cmd) return hl.dsp.exec_cmd(cmd) end

------------------------------------------------------------------ apps / session
bind(M("Q"),          sh(terminal),                         "Terminal")
bind(M("R"),          sh(menu),                             "App launcher")
bind(M("E"),          sh(fileManager),                      "File manager (yazi)")
bind(M("C"),          hl.dsp.window.close(),                "Close window")
bind(M("M"),          sh("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), "Exit Hyprland")
bind(M("Escape"),     sh("loginctl lock-session"),          "Lock screen")
bind(M("X"),          sh(home .. "/.config/waybar/scripts/power-menu.sh"), "Power menu")
bind(M("slash"),      sh(bin .. "keybinds"),                "Keybind cheatsheet")
bind(M("B"),          sh("pkill -SIGUSR1 waybar"),          "Toggle Waybar")
bind(M("SHIFT + B"),  sh("pkill waybar; waybar"),           "Restart Waybar")

------------------------------------------------------------------ window state
bind(M("F"),          hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind(M("SHIFT + F"),  hl.dsp.window.fullscreen({ mode = "maximized" }),  "Maximize (keep bar & gaps)")
bind(M("V"),          hl.dsp.window.float({ action = "toggle" }),        "Toggle floating")
bind(M("SHIFT + T"),  hl.dsp.window.pin(),                               "Pin floating window on all workspaces")
bind(M("P"),          hl.dsp.window.pseudo(),                            "Pseudotile")
bind(M("J"),          hl.dsp.layout("togglesplit"),                      "Toggle split direction")

------------------------------------------------------------------ focus / move / resize
for _, d in ipairs({ "left", "right", "up", "down" }) do
    bind(M(d),            hl.dsp.focus({ direction = d }),       "Focus " .. d)
    bind(M("SHIFT + " .. d), hl.dsp.window.move({ direction = d }), "Move window " .. d)
end
local step = 40
bind(M("CTRL + right"), hl.dsp.window.resize({ x =  step, y = 0, relative = true }), "Grow width",   { repeating = true })
bind(M("CTRL + left"),  hl.dsp.window.resize({ x = -step, y = 0, relative = true }), "Shrink width", { repeating = true })
bind(M("CTRL + down"),  hl.dsp.window.resize({ x = 0, y =  step, relative = true }), "Grow height",  { repeating = true })
bind(M("CTRL + up"),    hl.dsp.window.resize({ x = 0, y = -step, relative = true }), "Shrink height",{ repeating = true })

bind(M("mouse:272"), hl.dsp.window.drag(),   nil, { mouse = true })
bind(M("mouse:273"), hl.dsp.window.resize(), nil, { mouse = true })

------------------------------------------------------------------ workspaces
for i = 1, 10 do
    local key = i % 10
    bind(M(key),             hl.dsp.focus({ workspace = i }),       i == 1 and "Go to workspace 1-10 (Super+1..0)" or nil)
    bind(M("SHIFT + " .. key), hl.dsp.window.move({ workspace = i }), i == 1 and "Send window to workspace 1-10" or nil)
end
bind(M("N"),            sh(bin .. "new-workspace"),            "New empty workspace on this monitor")
bind(M("mouse_down"),   hl.dsp.focus({ workspace = "e+1" }),   nil)
bind(M("mouse_up"),     hl.dsp.focus({ workspace = "e-1" }),   nil)

-- scratchpads
bind(M("S"),            hl.dsp.workspace.toggle_special("magic"),          "Scratchpad")
bind(M("SHIFT + S"),    hl.dsp.window.move({ workspace = "special:magic" }), "Send window to scratchpad")
bind(M("grave"),        hl.dsp.workspace.toggle_special("term"),           "Drop-down terminal")

------------------------------------------------------------------ monitors
bind(M("SHIFT + P"),      sh(bin .. "display-mode menu"),             "Display mode (extend/mirror/…)")
bind(M("comma"),          hl.dsp.focus({ monitor = "-1" }),           "Focus previous monitor")
bind(M("period"),         hl.dsp.focus({ monitor = "+1" }),           "Focus next monitor")
bind(M("SHIFT + comma"),  hl.dsp.window.move({ monitor = "-1" }),     "Send window to previous monitor")
bind(M("SHIFT + period"), hl.dsp.window.move({ monitor = "+1" }),     "Send window to next monitor")
bind(M("ALT + comma"),    hl.dsp.workspace.move({ monitor = "-1" }),  "Send workspace to previous monitor")
bind(M("ALT + period"),   hl.dsp.workspace.move({ monitor = "+1" }),  "Send workspace to next monitor")

------------------------------------------------------------------ screenshots / recording
local shotDir  = "$HOME/Pictures/Screenshots"
local shotSave = [[mkdir -p "]] .. shotDir .. [[" && f="]] .. shotDir .. [[/$(date +%Y%m%d-%H%M%S).png" && ]]
local shotDone = [[ "$f" && wl-copy < "$f" && notify-send -a Screenshot -i "$f" -t 2000 "Screenshot saved" "$f"]]

bind("Print",          sh(shotSave .. [[g=$(slurp) && grim -g "$g"]] .. shotDone), "Screenshot region")
bind(M("Print"),       sh(shotSave .. [[grim]] .. shotDone),                        "Screenshot screen")
bind("SHIFT + Print",  function()                                                    -- active window
    local w = hl.get_active_window()
    if not w then return end
    hl.exec_cmd(shotSave .. string.format([[grim -g "%d,%d %dx%d"]], w.at.x, w.at.y, w.size.x, w.size.y) .. shotDone)
end, "Screenshot active window")
bind("CTRL + Print",   sh([[g=$(slurp) && grim -g "$g" - | wl-copy && notify-send -a Screenshot -t 1500 "Screenshot copied"]]), "Screenshot region to clipboard")
bind("ALT + Print",    sh([[g=$(slurp) || exit; if command -v satty >/dev/null; then grim -g "$g" - | satty -f - --copy-command wl-copy --output-filename "$HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S)-edit.png"; else notify-send "satty not installed" "sudo pacman -S satty"; fi]]), "Screenshot region and annotate")
bind(M("SHIFT + R"),   sh(bin .. "screenrec"),                                      "Start/stop screen recording")

------------------------------------------------------------------ tools
bind(M("SHIFT + V"),   sh([[cliphist list | wofi --dmenu --cache-file /dev/null -p "Clipboard" | cliphist decode | wl-copy]]), "Clipboard history")
bind(M("SHIFT + C"),   sh("hyprpicker --autocopy"),                         "Colour picker")
bind(M("SHIFT + W"),   sh(bin .. "daily-wallpaper next"),                   "Next wallpaper")
bind(M("SHIFT + N"),   sh("dunstctl history-pop"),                          "Show previous notification")
bind(M("CTRL + N"),    sh("dunstctl close-all"),                            "Dismiss all notifications")
bind(M("ALT + N"),     sh("dunstctl set-paused toggle && pkill -RTMIN+11 waybar"), "Do not disturb on/off")

------------------------------------------------------------------ media keys (with on-screen indicator)
local L  = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume",  sh(bin .. "osd volume up"),     "Volume up",      L)
bind("XF86AudioLowerVolume",  sh(bin .. "osd volume down"),   "Volume down",    L)
bind("XF86AudioMute",         sh(bin .. "osd volume mute"),   "Mute",           { locked = true })
bind("XF86AudioMicMute",      sh(bin .. "osd mic mute"),      "Mute microphone",{ locked = true })
bind("XF86MonBrightnessUp",   sh(bin .. "osd brightness up"), "Brightness up",  L)
bind("XF86MonBrightnessDown", sh(bin .. "osd brightness down"),"Brightness down",L)
bind("XF86AudioNext",  sh("playerctl next"),       "Next track",     { locked = true })
bind("XF86AudioPrev",  sh("playerctl previous"),   "Previous track", { locked = true })
bind("XF86AudioPlay",  sh("playerctl play-pause"), "Play / pause",   { locked = true })
bind("XF86AudioPause", sh("playerctl play-pause"), nil,              { locked = true })

------------------------------------------------------------------ write the cheatsheet
os.execute("mkdir -p '" .. home .. "/.cache/hypr'")
local f = io.open(home .. "/.cache/hypr/keybinds.txt", "w")
if f then
    f:write(table.concat(sheet, "\n"), "\n")
    f:close()
end
