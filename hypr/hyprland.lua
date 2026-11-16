-- Hyprland (Lua config) — entry point
-- The configuration lives in ~/.config/hypr/modules/*.lua (symlinked from dotfiles/hypr/modules).
-- https://wiki.hypr.land/Configuring/Start/
--
--   monitors.lua   display modes, monitor layout, workspace pinning
--   looks.lua      borders, opacity, shadows, blur, smart gaps, animations, misc
--   input.lua      keyboard, touchpad, gestures, cursor
--   autostart.lua  environment variables and session services
--   rules.lua      window / workspace / layer rules
--   binds.lua      keybindings (Super + / shows them all)

local modules = os.getenv("HOME") .. "/.config/hypr/modules/"
package.path = modules .. "?.lua;" .. package.path

for _, name in ipairs({ "monitors", "looks", "input", "autostart", "rules", "binds" }) do
    package.loaded[name] = nil   -- re-read on every `hyprctl reload`
    require(name)
end
