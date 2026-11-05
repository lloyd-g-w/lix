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

-- Starts the shared session (bar etc.): home/modules/gui/autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("lix-session start")
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
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },

    dwindle = {
        preserve_split = true,
    },

    animations = { enabled = false },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        -- Wake monitors after power-off-monitors on any input
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        -- A new window on a workspace with a maximized/fullscreen window opens
        -- normally and the other window goes back to tiling, instead of the
        -- new window taking over the maximized state (tested on 0.56.2: 0
        -- and 2 both take over, 1 doesn't).
        on_focus_under_fullscreen = 1,
    },
})

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

bind("RETURN", hl.dsp.exec_cmd(terminal))
bind("E", hl.dsp.exec_cmd(browser))
bind("D", hl.dsp.exec_cmd(menu))
bind("Escape", hl.dsp.exec_cmd("noctalia msg session lock"))

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

-- Focus / move / resize windows (vim keys and arrows)
local resize_step = 50
local dirs = {
    { "LEFT", "H", "l", "left", -1, 0 },
    { "DOWN", "J", "d", "down", 0, 1 },
    { "UP", "K", "u", "up", 0, -1 },
    { "RIGHT", "L", "r", "right", 1, 0 },
}
for _, d in ipairs(dirs) do
    local arrow, vim, short, long, dx, dy = d[1], d[2], d[3], d[4], d[5], d[6]
    for _, key in ipairs({ arrow, vim }) do
        bind("ALT + " .. key, hl.dsp.window.resize({
            x = dx * resize_step, y = dy * resize_step, relative = true,
        }), { repeating = true })

        bind(key, hl.dsp.focus({ direction = long }))
        bind("SHIFT + " .. key, hl.dsp.window.move({ direction = long }))

        bind("CTRL + " .. key, hl.dsp.focus({ monitor = short }))
        bind("SHIFT + CTRL + " .. key, hl.dsp.window.move({ monitor = short }))
    end
end

-- Workspaces are per monitor, like niri, using hyprsplit: each monitor gets
-- its own 10 workspaces and these binds act on the focused monitor's ones.
-- Monitors get blocks (1-10, 11-20, ...) in lix.home.monitors order.
local hs = require("hyprsplit")
local num_workspaces = 10
local monitor_priority = @MONITOR_PRIORITY@
hs.config({ num_workspaces = num_workspaces })
hs.monitor_priority(monitor_priority)

-- Name every workspace by its position on its monitor (11 -> "1", 12 -> "2",
-- ...) so bars that show workspace names number each monitor 1..10.
-- One extra block covers a monitor not listed in lix.home.monitors.
for block = 0, #monitor_priority do
    for i = 1, num_workspaces do
        hl.workspace_rule({
            workspace = tostring(block * num_workspaces + i),
            default_name = tostring(i),
        })
    end
end

-- niri's are vertical: down = next
for _, key in ipairs({ "Page_Down", "U", "mouse_down" }) do
    bind(key, hs.dsp.focus({ workspace = "+1" }))
    bind("CTRL + " .. key, hs.dsp.window.move({ workspace = "+1" }))
end
for _, key in ipairs({ "Page_Up", "I", "mouse_up" }) do
    bind(key, hs.dsp.focus({ workspace = "-1" }))
    bind("CTRL + " .. key, hs.dsp.window.move({ workspace = "-1" }))
end

for i = 1, 10 do
    local key = tostring(i % 10) -- 10 is the 0 key
    bind(key, hs.dsp.focus({ workspace = i }))
    bind("CTRL + " .. key, hs.dsp.window.move({ workspace = i }))
end

-- Pull in windows stranded on a workspace of an unplugged monitor
bind("SHIFT + G", hs.dsp.grab_rogue_windows())

-- Mouse wheel
bind("mouse_right", hl.dsp.focus({ direction = "right" }))
bind("mouse_left", hl.dsp.focus({ direction = "left" }))
bind("CTRL + mouse_right", hl.dsp.window.move({ direction = "right" }))
bind("CTRL + mouse_left", hl.dsp.window.move({ direction = "left" }))
bind("SHIFT + mouse_down", hl.dsp.focus({ direction = "right" }))
bind("SHIFT + mouse_up", hl.dsp.focus({ direction = "left" }))
bind("CTRL + SHIFT + mouse_down", hl.dsp.window.move({ direction = "right" }))
bind("CTRL + SHIFT + mouse_up", hl.dsp.window.move({ direction = "left" }))

-- Move/resize windows with mod + LMB/RMB drag
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Flip the split direction of the focused window (dwindle)
bind("COMMA", hl.dsp.layout("togglesplit"))

-- Sizing
bind("F", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("MINUS", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
bind("EQUAL", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
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
