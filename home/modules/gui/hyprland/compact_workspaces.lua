-- Keeps each monitor's hyprsplit workspaces contiguous, like niri:
--
-- * Compaction: when a workspace is destroyed (Hyprland removes an empty one
--   once you leave it), the ones above it on the same monitor shift down to
--   fill the gap (1, 4, 5 -> 1, 2, 3). Done with workspace.change_id, so
--   windows keep their layout.
-- * Clamped goto: focusing/moving to workspace N past the last one in use
--   goes to the slot just after it instead (only 1 in use: mod+4 -> 2).
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

-- Shift every monitor's workspaces down into gaps in its block.
function M.compact()
    for _, m in ipairs(hl.get_monitors()) do
        if valid_monitor(m) then
            local range = hs.MonitorRange:new(m)
            local slot = range.min
            for _, ws in ipairs(block_workspaces(range)) do
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
            end
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
    local used = #block_workspaces(range)
    local limit = used + 1
    -- If the last workspace is the active one and would be left empty (moving
    -- its only window, or focusing away from it while empty), a "new one
    -- after it" would just collapse back into the same slot; stay put.
    local active = mon.active_workspace
    local left_over = active and (active.windows - (moving and 1 or 0)) or 1
    if active and active.id == range.min + used - 1 and left_over <= 0 then
        limit = used
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
    -- Clean up gaps left from before (e.g. after a config reload).
    hl.on("config.reloaded", schedule_compact)
    hl.on("hyprland.start", schedule_compact)
end

return M
