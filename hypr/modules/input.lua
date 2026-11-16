-- Keyboard, touchpad, gestures and cursor

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification

        touchpad = {
            natural_scroll       = false,
            tap_to_click         = true,
            disable_while_typing = true,
            scroll_factor        = 0.8,
        },
    },

    -- keyboard moves between screens carry the pointer along
    cursor = {
        warp_on_change_workspace = 1,
        hide_on_key_press        = true,
    },
})

-- 3-finger horizontal swipe switches workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
