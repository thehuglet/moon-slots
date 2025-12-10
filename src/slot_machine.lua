local M = {}
local m_card = require("src.card")
local m_layout = require("src.layout")
local m_state = require("src.state")

local layout = m_layout.SLOT_MACHINE_REELS

local function ease_out_cubic(t) -- t in [0,1]
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

local function update_column(col, dt)
    local card_height = m_layout.CARD_SMALL_SIZE.height * layout.scale
    local deck_len_px = #col.deck * card_height

    if col.tween then
        if col.tween.delay > 0 then
            col.tween.delay = col.tween.delay - dt
            return
        end

        col.tween.time = math.min(col.tween.time + dt, col.tween.duration)
        local t = col.tween.time / col.tween.duration
        local eased = col.tween.easing(t)
        col.cursor = col.tween.start + (col.tween.target - col.tween.start) * eased

        if col.tween.time >= col.tween.duration then
            -- snap to exact card boundary
            local remainder = col.cursor % card_height
            if remainder >= card_height / 2 then
                col.cursor = col.cursor + (card_height - remainder)
            else
                col.cursor = col.cursor - remainder
            end
            col.cursor = col.cursor % deck_len_px
            col.tween = nil
        end

        return
    end
end

local function start_column(col_index, target_index, loops, duration, delay)
    local col = m_state.slot_machine_columns[col_index]
    local card_height = m_layout.CARD_SMALL_SIZE.height
    local deck_len_px = #col.deck * card_height

    local target_cursor_nominal = (target_index - 1) * card_height

    local current = col.cursor % deck_len_px
    local delta = target_cursor_nominal - current
    if delta <= 0 then
        delta = delta + deck_len_px
    end
    local total_distance = delta + (loops * deck_len_px)

    local target_cursor_absolute = col.cursor + total_distance

    col.tween = {
        start = col.cursor,
        target = target_cursor_absolute,
        time = 0,
        duration = duration or 2.0,
        delay = delay or 0.0,
        easing = ease_out_cubic,
        finished = false,
    }
end

function M.start_all_columns()
    local results = {}
    for i = 1, #m_state.slot_machine_columns do
        local deck_len = #m_state.slot_machine_columns[i].deck
        results[i] = love.math.random(1, deck_len)
    end

    for i = 1, #m_state.slot_machine_columns do
        local loops = 2
        local duration = 3.5 + (i - 1) * 0.5
        local delay = (i - 1) * 0.08
        start_column(i, results[i], loops, duration, delay)
    end
end

---@param dt number
function M.update_all_columns(dt)
    for _, col in ipairs(m_state.slot_machine_columns) do
        update_column(col, dt)
    end
end

function M.draw_all_columns()
    local scissor_width = layout.max_columns * layout.column_spacing
        - (layout.column_spacing - m_layout.CARD_SMALL_SIZE.width)

    love.graphics.setColor(0.0, 0.0, 0.0, 1)
    love.graphics.rectangle(
        "fill",
        layout.x_origin,
        layout.y_origin,
        scissor_width,
        layout.height - 1
    )
    love.graphics.setScissor(layout.x_origin, layout.y_origin, scissor_width, layout.height)

    local total_rows_height = layout.visible_rows * layout.row_spacing
    local y_start = layout.y_origin + (layout.height - total_rows_height) / 2

    local sigma = layout.row_spacing * layout.row_neighbor_count

    for column_index, column in ipairs(m_state.slot_machine_columns) do
        local start_index = math.floor(column.cursor / layout.row_spacing) + 1

        for card_row = 0, layout.visible_rows - 1 do
            local index = ((start_index + card_row - 1) % #column.deck) + 1
            local x = layout.x_origin + (column_index - 1) * layout.column_spacing
            local y = y_start
                + (card_row * layout.row_spacing)
                - (column.cursor % layout.row_spacing)
            local card = column.deck[index]

            local distance = (y + m_layout.CARD_SMALL_SIZE.height / 2) - layout.center_y
            local factor = math.exp(-3.5 * (distance / sigma) ^ 2)

            love.graphics.setColor(factor, factor, factor, 1)
            m_card.draw_card_small(card, x, y, layout.scale)
        end
    end
    -- love.graphics.setColor(0.5, 0.9, 0.5, 1)
    -- love.graphics.rectangle(
    --     "line",
    --     layout.x_origin,
    --     layout.y_origin,
    --     scissor_width,
    --     layout.height - 1
    -- )

    -- reset
    love.graphics.setScissor()
    love.graphics.setColor(1, 1, 1, 1)
end

return M
