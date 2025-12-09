local M = {}
local m_state = require("src.state")

-- constants
local BASE_SPIN_DURATION = 6.0
local STAGGER_RATIO = 0.35
local MIN_STAGGER_DELTA = 0.5
local GEOMETRIC_WEIGHT = 0.3
-- local SNAP_THRESHOLD = 0.5
local EXPONENT = 1.0

local function calc_spin_duration(col_index)
    if col_index == 1 then
        return BASE_SPIN_DURATION
    end

    local per_column_base = BASE_SPIN_DURATION * STAGGER_RATIO

    local total_stagger = 0
    for i = 1, col_index - 1 do
        local geometric = math.max(per_column_base * (STAGGER_RATIO ^ (i - 1)), MIN_STAGGER_DELTA)
        local linear = math.max(per_column_base, MIN_STAGGER_DELTA)
        total_stagger = total_stagger
            + (linear * (1 - GEOMETRIC_WEIGHT) + geometric * GEOMETRIC_WEIGHT)
    end

    return BASE_SPIN_DURATION + total_stagger
end

-- start spinning a column
function M.start_column(col_index, max_speed)
    local col = m_state.slot_columns[col_index]
    col.spin_duration = calc_spin_duration(col_index)
    col.spin_time_remaining = col.spin_duration
    col.max_speed = max_speed
end

function M.update_column(col, dt, card_spacing)
    local deck_length = #col.deck * card_spacing
    col.spin_time_remaining = math.max(col.spin_time_remaining - dt, 0)

    if col.spin_time_remaining <= 0 then
        return
    end

    col.spin_time_remaining = math.max(col.spin_time_remaining - dt, 0)

    local t = math.min(col.spin_time_remaining / col.spin_duration, 1)

    local speed = 0
    speed = col.max_speed * (1 - (1 - t) ^ EXPONENT)
    print(speed)

    if speed > 0.0 then
        col.cursor = (col.cursor + speed * dt) % deck_length

        if speed < 100.0 then
            col.spin_time_remaining = 0.0

            -- snap to nearest card
            local remainder = col.cursor % card_spacing
            if remainder >= card_spacing / 2 then
                col.cursor = col.cursor + (card_spacing - remainder)
            else
                col.cursor = col.cursor - remainder
            end

            -- wrap around just in case
            col.cursor = col.cursor % deck_length
        end
    end
end

function M.update_all_columns(dt, card_spacing)
    for _, col in ipairs(m_state.slot_columns) do
        M.update_column(col, dt, card_spacing)
    end
end

return M
