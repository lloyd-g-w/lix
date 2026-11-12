-- Keeps each monitor's hyprsplit workspaces contiguous, like niri:
--
-- * Compaction: when a workspace is destroyed (Hyprland removes an empty one
--   once you leave it), the ones above it on the same monitor shift down to
--   fill the gap (1, 4, 5 -> 1, 2, 3). Done with workspace.change_id, so
--   windows keep their layout.
-- * Clamped goto: focusing/moving to workspace N past the last one in use
--   goes to the slot just after it instead (only 1 in use: mod+4 -> 2).
-- * Trailing empty workspace: the slot after the last one in use is kept
--   alive (empty and persistent), so bars show it too (1, 2 in use -> 1, 2, 3).
--
-- Usage (after hyprsplit is configured):
--   local cw = require("compact_workspaces")
--   cw.setup({ hyprsplit = hs, num_workspaces = 10 })
--   bind("1", cw.dsp.focus(1)); bind("CTRL + 1", cw.dsp.move(1))

local M = {}

local hs
local num_workspaces = 10

local function log(fmt, ...)
    print(string.format("[compact_workspaces] " .. fmt, ...))
end

local function valid_monitor(m)
    return m ~= nil and not m.is_mirror and m.id ~= -1
end

-- Existing normal workspaces in the monitor's hyprsplit block, sorted by id.
local function block_workspaces(range)
    local list = {}
    for _, ws in ipairs(hl.get_workspaces()) do
        if not ws.special and ws.id and range:contains(ws.id) then
            table.insert(list, ws)
        end
    end
    table.sort(list, function(a, b)
        return a.id < b.id
    end)
    return list
end

-- Trailing empty workspace per monitor: monitor name -> workspace id whose
-- persistent rule is enabled.
local trailing = {}
-- Persistent workspace rules, created on first use and then only toggled:
-- "monitor|id" -> HL.WorkspaceRule. The rule's workspace is written with a
-- leading 0 ("03" for 3): it still names workspace 3, but hl.workspace_rule
-- would otherwise merge it into the enabled default_name rule for "3" (in
-- hyprland.lua), and disabling it would then disable the name too.
local rules = {}

local function set_persistent(monitor_name, id, on)
    local key = monitor_name .. "|" .. id
    local rule = rules[key]
    if rule then
        rule:set_enabled(on)
    elseif on then
        rules[key] = hl.workspace_rule({
            workspace = "0" .. id,
            monitor = monitor_name,
            persistent = true,
        })
    end
end

-- The monitor's trailing workspace, while it is still the empty spare
-- (not when a window has been opened on it).
local function is_spare(m, ws)
    return ws.id == trailing[m.name] and ws.windows == 0
end

-- Shift every monitor's workspaces down into gaps in its block.
function M.compact()
    for _, m in ipairs(hl.get_monitors()) do
        if valid_monitor(m) then
            local range = hs.MonitorRange:new(m)
            local slot = range.min
            for _, ws in ipairs(block_workspaces(range)) do
                local active = m.active_workspace and m.active_workspace.id == ws.id
                -- Leave the spare where it is: update_trailing moves it.
                if is_spare(m, ws) and not active then
                    goto continue
                end
                -- Ascending order, so every id below ws.id that is still in
                -- use is already at or below slot: slot is free.
                if ws.id > slot then
                    local old = ws.id
                    hl.dispatch(hl.dsp.workspace.change_id({ workspace = old, id = slot }))
                    -- default_name rules only apply at creation, so relabel.
                    hl.dispatch(hl.dsp.workspace.rename({
                        workspace = slot,
                        name = tostring(slot - range.min + 1),
                    }))
                    log("%s: workspace %d -> %d", m.name, old, slot)
                end
                slot = slot + 1
                ::continue::
            end
        end
    end
end

-- Keep one empty workspace after the last one in use on every monitor (none
-- if the last one is already empty, e.g. you are on a fresh one).
function M.update_trailing()
    local present = {}
    for _, m in ipairs(hl.get_monitors()) do
        if valid_monitor(m) then
            present[m.name] = true
            local range = hs.MonitorRange:new(m)
            local last
            for _, ws in ipairs(block_workspaces(range)) do
                if not is_spare(m, ws) then
                    last = ws
                end
            end
            local want
            if last == nil then
                want = range.min
            elseif last.windows > 0 and last.id < range.max then
                want = last.id + 1
            end
            local have = trailing[m.name]
            if want ~= have then
                if have then
                    set_persistent(m.name, have, false)
                end
                if want then
                    set_persistent(m.name, want, true)
                end
                trailing[m.name] = want
            end
        end
    end
    -- Unplugged monitors
    for name, id in pairs(trailing) do
        if not present[name] then
            set_persistent(name, id, false)
            trailing[name] = nil
        end
    end
end

-- Workspace removals come in bursts (monitor unplug, hyprsplit reshuffles),
-- so compact once they settle.
local pending = false
local function schedule_compact()
    if pending then
        return
    end
    pending = true
    hl.timer(function()
        pending = false
        M.compact()
        M.update_trailing()
    end, { timeout = 50, type = "oneshot" })
end

-- Local workspace number (1-based) to actually use for "go to n" on the
-- focused monitor, and whether that is the active workspace. moving: the
-- active window is being moved there.
local function clamp(n, moving)
    local mon = hl.get_active_monitor()
    if not valid_monitor(mon) then
        return n, false
    end
    local range = hs.MonitorRange:new(mon)
    local list = block_workspaces(range)
    local used = #list
    -- An empty last workspace (the trailing spare, or a fresh one you are
    -- on) is the slot after the ones in use: go no further than it.
    local last = list[used]
    local trailing_empty = last ~= nil and last.windows == 0
    local last_used = trailing_empty and used - 1 or used
    local limit = trailing_empty and used or used + 1
    -- Moving the only window of the last workspace in use to the slot after
    -- it would leave the same layout one slot along; stay put.
    local active = mon.active_workspace
    if moving and active and active.id == range.min + last_used - 1 and active.windows <= 1 then
        limit = last_used
    end
    local target = math.max(1, math.min(n, limit, num_workspaces))
    local is_active = active ~= nil and active.id == range.min + target - 1
    return target, is_active
end

-- Clamping onto the active workspace means "already as far as it goes":
-- do nothing, rather than letting hyprsplit treat it as
-- workspace_back_and_forth. Pressing the active workspace's own number
-- still goes back and forth.
local function clamped(n, moving)
    local target, is_active = clamp(n, moving)
    if is_active and target ~= n then
        return nil
    end
    return target
end

M.dsp = {}

---@param n integer local workspace number on the focused monitor
function M.dsp.focus(n)
    return function()
        local target = clamped(n, false)
        if target then
            hs.dsp.focus({ workspace = target })()
        end
    end
end

---@param n integer local workspace number on the focused monitor
function M.dsp.move(n)
    return function()
        local target = clamped(n, true)
        if target then
            hs.dsp.window.move({ workspace = target })()
        end
    end
end

---@param opts { hyprsplit: table, num_workspaces?: integer }
function M.setup(opts)
    hs = opts.hyprsplit
    num_workspaces = opts.num_workspaces or num_workspaces

    hl.on("workspace.removed", schedule_compact)
    -- Anything that can change which workspaces are in use or empty
    for _, ev in ipairs({
        "workspace.created",
        "workspace.active",
        "window.open",
        "window.close",
        "window.destroy",
        "window.move_to_workspace",
        "monitor.added",
        "monitor.removed",
    }) do
        hl.on(ev, schedule_compact)
    end
    -- Clean up gaps left from before (e.g. after a config reload).
    hl.on("config.reloaded", schedule_compact)
    hl.on("hyprland.start", schedule_compact)
end

return M
