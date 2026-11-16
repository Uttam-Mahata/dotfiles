-- Window, workspace and layer rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

------------------------------------------------------------------ general behaviour
hl.window_rule({
    -- ignore maximize requests from apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- don't idle/lock while anything is fullscreen (videos, games, presentations)
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    -- fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

------------------------------------------------------------------ dialogs & utilities float, centred
local function floatCentered(name, match, size)
    hl.window_rule({ name = name, match = match, float = true, center = true, size = size })
end
floatCentered("pavucontrol",   { class = "^(org.pulseaudio.pavucontrol|pavucontrol)$" }, "900 600")
floatCentered("blueman",       { class = "^(blueman-manager|.blueman-manager-wrapped)$" }, "800 560")
floatCentered("nm-editor",     { class = "^(nm-connection-editor)$" },                    "760 520")
floatCentered("polkit",        { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, nil)
floatCentered("portal-gtk",    { class = "^(xdg-desktop-portal-gtk)$" },                   "1000 640")
floatCentered("file-dialogs",  { title = "^(Open File|Open Files|Save File|Save As|Open Folder|Select a File|File Upload|Choose Files).*" }, "1000 640")
floatCentered("firefox-library", { class = "^firefox$", title = "^Library$" },             "900 600")
floatCentered("yazi-picker",   { class = "^yazi-picker$" },                                "1000 640")
floatCentered("calculator",    { class = "^(org.gnome.Calculator|qalculate-gtk)$" },       nil)

-- Picture-in-Picture: floating, pinned to every workspace, bottom-right corner
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    pin   = true,
    size  = "480 270",
    move  = "monitor_w-500 monitor_h-290",
    keep_aspect_ratio = true,
})

-- Hyprland-run
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

------------------------------------------------------------------ wofi menus (run as focused floating windows by wofi-menu)
hl.window_rule({
    name          = "wofi-menu",
    match         = { class = "^wofi$" },
    float         = true,
    center        = true,
    pin           = true,
    stay_focused  = true,
    border_size   = 0,
    rounding      = 22,
    no_shadow     = false,
    dim_around    = true,
    animation     = "popin 92%",
})

------------------------------------------------------------------ app tweaks
-- Apps that must NOT be faded by the global active/inactive opacity (looks.lua):
--  • Kitty / drop-down terminal: Kitty already makes only its background translucent (0.55),
--    so fading the whole window would also dim the text
--  • video players, image viewers, Picture-in-Picture: keep the picture solid
hl.window_rule({
    name    = "opaque-apps",
    match   = { class = "^(kitty|dropterm|mpv|vlc|org.videolan.VLC|imv|swayimg|org.gnome.Loupe|steam_app_.*)$" },
    opacity = "1.0 override 1.0 override",
})
hl.window_rule({
    name    = "opaque-pip",
    match   = { title = "^(Picture-in-Picture|Picture in picture)$" },
    opacity = "1.0 override 1.0 override",
})

------------------------------------------------------------------ drop-down terminal (Super + `)
hl.workspace_rule({
    workspace        = "special:term",
    on_created_empty = "kitty --class dropterm",
})
hl.window_rule({
    name   = "dropterm",
    match  = { class = "^dropterm$" },
    float  = true,
    center = true,
    size   = "1200 680",
})

------------------------------------------------------------------ layers (blur behind translucent surfaces)
hl.layer_rule({
    name  = "wofi-blur",
    match = { namespace = "^wofi$" },
    blur         = true,
    ignore_alpha = 0.3,
    animation    = "popin 92%",
})
hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "^waybar$" },
    blur         = true,
    ignore_alpha = 0.2,
})
hl.layer_rule({
    name  = "notifications-blur",
    match = { namespace = "^notifications$" },
    blur         = true,
    ignore_alpha = 0.3,
    animation    = "slide right",
})
