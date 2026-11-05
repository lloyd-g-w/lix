-- Hyprland config, kept close to ../niri/config.kdl.
-- Lua config reference: https://wiki.hypr.land/Configuring/Start/

local terminal = "@TERMINAL@"
local browser = "@BROWSER@"
local menu = "@MENU@"
local mod = "SUPER"

-------------------
---- MONITORS -----
-------------------

-- Fallback for monitors not listed in lix.home.monitors.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- We replace the below with lix.home.monitors during the nix pass
@MONITORS@

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    -- This is for discord to recognize portals when launched with walker
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("latus")
    hl.exec_cmd("@BACKGROUND@")
    hl.exec_cmd("playerctld daemon")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,
        col = {
            active_border = "rgb(618c4d)",
            inactive_border = "rgb(5a5b5e)",
        },
        -- niri-like scrollable tiling
        layout = "scrolling",
    },

    decoration = {
        rounding = 0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },

    scrolling = {
        column_width = 0.5,
        explicit_column_widths = "0.33333, 0.5, 0.66667",
        fullscreen_on_one_column = false,
        -- center-focused-column "never": only scroll enough to fit the column
        focus_fit_method = 1,
        wrap_focus = false,
        wrap_swapcol = false,
    },

    animations = { enabled = true },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        -- Wake monitors after power-off-monitors on any input
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
    },
})

hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("easeOutQuad", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 800, dampening = 56.57 })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.5, bezier = "easeOutExpo", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "easeOutQuad", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, spring = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutExpo", style = "slidevert" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "easeOutQuad" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "au",
        numlock_by_default = true,
        -- focus-follows-mouse
        follow_mouse = 1,
        touchpad = {
            tap_to_click = true,
            tap_and_drag = false,
            natural_scroll = true,
        },
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

local function bind(keys, dispatcher, opts)
    hl.bind(keys == "" and mod or mod .. " + " .. keys, dispatcher, opts)
end

local function layout(msg)
    return hl.dsp.layout(msg)
end

bind("RETURN", hl.dsp.exec_cmd(terminal))
bind("E", hl.dsp.exec_cmd(browser))
bind("D", hl.dsp.exec_cmd(menu))
bind("ALT + L", hl.dsp.exec_cmd("swaylock"))

local locked = { locked = true }
local lockedRepeat = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+"), lockedRepeat)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"), lockedRepeat)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), lockedRepeat)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), lockedRepeat)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), lockedRepeat)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), lockedRepeat)

bind("Q", hl.dsp.window.close())

-- Focus columns / windows (vim keys and arrows)
local dirs = {
    { "LEFT", "H", "l", "left" },
    { "DOWN", "J", "d", "down" },
    { "UP", "K", "u", "up" },
    { "RIGHT", "L", "r", "right" },
}
for _, d in ipairs(dirs) do
    local arrow, vim, short, long = d[1], d[2], d[3], d[4]
    for _, key in ipairs({ arrow, vim }) do
        bind(key, layout("focus " .. short))

        -- Left/right moves the whole column, up/down moves the window within it
        if short == "l" or short == "r" then
            bind("SHIFT + " .. key, layout("swapcol " .. short))
        else
            bind("SHIFT + " .. key, hl.dsp.window.move({ direction = long }))
        end

        bind("CTRL + " .. key, hl.dsp.focus({ monitor = short }))
        bind("SHIFT + CTRL + " .. key, hl.dsp.window.move({ monitor = short }))
    end
end

-- Workspaces (niri's are vertical: down = next)
for _, key in ipairs({ "Page_Down", "U" }) do
    bind(key, hl.dsp.focus({ workspace = "r+1" }))
    bind("CTRL + " .. key, hl.dsp.window.move({ workspace = "r+1" }))
end
for _, key in ipairs({ "Page_Up", "I" }) do
    bind(key, hl.dsp.focus({ workspace = "r-1" }))
    bind("CTRL + " .. key, hl.dsp.window.move({ workspace = "r-1" }))
end

for i = 1, 9 do
    bind(tostring(i), hl.dsp.focus({ workspace = i }))
    bind("CTRL + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse wheel
bind("mouse_down", hl.dsp.focus({ workspace = "r+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "r-1" }))
bind("CTRL + mouse_down", hl.dsp.window.move({ workspace = "r+1" }))
bind("CTRL + mouse_up", hl.dsp.window.move({ workspace = "r-1" }))
bind("mouse_right", layout("focus r"))
bind("mouse_left", layout("focus l"))
bind("CTRL + mouse_right", layout("swapcol r"))
bind("CTRL + mouse_left", layout("swapcol l"))
bind("SHIFT + mouse_down", layout("focus r"))
bind("SHIFT + mouse_up", layout("focus l"))
bind("CTRL + SHIFT + mouse_down", layout("swapcol r"))
bind("CTRL + SHIFT + mouse_up", layout("swapcol l"))

-- Move/resize windows with mod + LMB/RMB drag
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Consume or expel the window into the neighbouring column
bind("COMMA", layout("consume_or_expel prev"))
bind("PERIOD", layout("consume_or_expel next"))

-- Column sizing
bind("R", layout("colresize +conf"))
bind("F", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("CTRL + F", layout("fit expand"))
bind("C", layout("center"))
bind("MINUS", layout("colresize -0.1"))
bind("EQUAL", layout("colresize +0.1"))
bind("SHIFT + MINUS", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
bind("SHIFT + EQUAL", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Floating
bind("V", hl.dsp.window.float({ action = "toggle" }))
bind("SHIFT + V", hl.dsp.window.cycle_next({ floating = true }))

-- Closest thing to niri's tabbed columns
bind("W", hl.dsp.group.toggle())

bind("SHIFT + S", hl.dsp.exec_cmd("@SCREENSHOT@"))

bind("SHIFT + E", hl.dsp.exit())
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())

bind("SHIFT + P", hl.dsp.dpms({ action = "off" }))
