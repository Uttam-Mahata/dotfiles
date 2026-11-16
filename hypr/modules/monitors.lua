-- Monitors, display modes (Super+Shift+P) and workspace-to-monitor pinning

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Display mode (like GNOME's Join / Mirror / Single display), chosen with Super+Shift+P.
-- Stored in ~/.local/state/display-mode: extend | mirror | external | laptop
local function readDisplayMode()
    local f = io.open(os.getenv("HOME") .. "/.local/state/display-mode", "r")
    if not f then return "extend" end
    local m = f:read("*l"); f:close()
    if m == "mirror" or m == "external" or m == "laptop" then return m end
    return "extend"
end
local displayMode = readDisplayMode()

if displayMode == "mirror" then
    -- external screen shows exactly what the laptop panel shows
    hl.monitor({ output = "eDP-1",    mode = "preferred", position = "0x0", scale = 1.25 })
    hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1.25, mirror = "eDP-1" })
elseif displayMode == "external" then
    -- laptop panel off, everything on the external screen
    hl.monitor({ output = "eDP-1",    disabled = true })
    hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = 1.25 })
elseif displayMode == "laptop" then
    -- external screen off, everything on the laptop panel
    hl.monitor({ output = "eDP-1",    mode = "preferred", position = "0x0", scale = 1.25 })
    hl.monitor({ output = "HDMI-A-1", disabled = true })
else
    -- extend: separate screens, laptop on the left, external to its right
    hl.monitor({ output = "eDP-1",    mode = "preferred", position = "0x0",        scale = 1.25 })
    hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-right", scale = 1.25 })

    -- Workspaces are pinned to a monitor: 1-5 on the laptop, 6-10 on the external screen.
    -- With only one screen connected they all collapse onto it automatically.
    for i = 1, 5 do
        hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1",    default = (i == 1) })
    end
    for i = 6, 10 do
        hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = (i == 6) })
    end

    -- Spare workspaces made with Super+N: 11-20 on the laptop, 21-30 on the external screen.
    for i = 11, 20 do
        hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
    end
    for i = 21, 30 do
        hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
    end
end

-- Any other / future display
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

