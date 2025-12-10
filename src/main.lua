local m_assets = require("src.assets")
local m_card = require("src.card")
local m_hand = require("src.hand")
local m_layout = require("src.layout")
local m_slot_machine = require("src.slot_machine")
local m_state = require("src.state")

-- debug section
m_state.cards_in_hand[1] = m_card.Card(m_card.RANK.KING, m_card.SUIT.CLUBS)
m_state.cards_in_hand[3] = m_card.Card(m_card.RANK.NUM_2, m_card.SUIT.DIAMONDS)
m_state.cards_in_hand[7] = m_card.Card(m_card.RANK.NUM_10, m_card.SUIT.HEARTS)

-- Helper function to calculate positions with gap
local function calculate_positions_with_gap(cards, dragged_index, gap_index)
    local positions = {}
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local card_width = m_layout.CARD_BIG_SIZE.width * m_layout.CARDS_IN_HAND.scale

    local display_count = #cards
    if dragged_index then
        display_count = display_count - 1
    end

    if display_count == 0 then
        return positions
    end

    local max_total_width = window_width * 0.5
    local x_spacing = math.min(card_width * 0.9, max_total_width / display_count)
    local total_width = card_width + (display_count - 1) * x_spacing

    local x_start = window_width * 0.5 - total_width * 0.5
    local y_start = window_height * 0.75

    local center_index = (display_count + 1) / 2
    local y_curve_strength = 60

    local fan_angle = math.rad(50)
    local angle_step = display_count > 1 and fan_angle / (display_count - 1) or 0

    -- Create positions for all cards (with gap if dragging)
    local display_idx = 1
    for card_index = 1, #cards do
        if card_index ~= dragged_index then
            -- Check if we're at the gap position
            if card_index == gap_index then
                -- Skip this position (leave gap)
                display_idx = display_idx + 1
            end

            local x = x_start + (display_idx - 1) * x_spacing
            local angle = -fan_angle * 0.5 + (display_idx - 1) * angle_step
            local offset = display_idx - center_index
            local y_offset = y_curve_strength * (offset ^ 2) / ((display_count / 2) ^ 2)
            local y = y_start + y_offset

            positions[card_index] = {
                x = x,
                y = y,
                angle = angle,
                scale = 1.25,
            }

            display_idx = display_idx + 1
        end
    end

    return positions
end

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.12, 0.06)

    -- Initialize positions
    local positions = calculate_positions_with_gap(m_state.cards_in_hand, nil, nil)
    for i = 1, #m_state.cards_in_hand do
        if positions[i] then
            m_state.current_hand_card_ui_positions[i] = {
                x = positions[i].x,
                y = positions[i].y,
                angle = positions[i].angle,
                scale = positions[i].scale,
            }
            m_state.target_hand_card_ui_positions[i] = {
                x = positions[i].x,
                y = positions[i].y,
                angle = positions[i].angle,
                scale = positions[i].scale,
            }
        end
    end
end

function love.update(dt)
    local mouse_x, mouse_y = love.mouse.getPosition()
    m_slot_machine.update_all_columns(dt)

    -- Update tweening for all non-dragged cards
    for i = 1, #m_state.cards_in_hand do
        if i ~= m_state.dragged_card_index then
            local current = m_state.current_hand_card_ui_positions[i]
            local target = m_state.target_hand_card_ui_positions[i]

            if current and target then
                -- Smooth tweening
                current.x = current.x + (target.x - current.x) * m_state.tween_speed
                current.y = current.y + (target.y - current.y) * m_state.tween_speed
                current.angle = current.angle + (target.angle - current.angle) * m_state.tween_speed
                current.scale = current.scale + (target.scale - current.scale) * m_state.tween_speed
            end
        end
    end

    if m_state.dragged_card_index then
        -- Calculate potential drop position based on mouse X
        local potential_drop_index = #m_state.cards_in_hand -- default to last position

        -- Find where the mouse would insert the card
        -- We'll calculate based on screen position, not card positions
        local window_width = love.graphics.getWidth()
        local card_width = m_layout.CARD_BIG_SIZE.width * m_layout.CARDS_IN_HAND.scale
        local display_count = #m_state.cards_in_hand - 1
        local max_total_width = window_width * 0.5
        local x_spacing = math.min(card_width * 0.9, max_total_width / display_count)
        local total_width = card_width + (display_count - 1) * x_spacing
        local x_start = window_width * 0.5 - total_width * 0.5

        -- Find which slot the mouse is over
        for i = 1, #m_state.cards_in_hand do
            if i ~= m_state.dragged_card_index then
                -- Calculate slot center for this position
                local slot_x = x_start + (i - 1) * x_spacing + card_width * 0.5
                if mouse_x < slot_x then
                    potential_drop_index = i
                    break
                end
            end
        end

        -- Only update if drop position changed
        if potential_drop_index ~= m_state.potential_drop_index then
            m_state.potential_drop_index = potential_drop_index

            -- Update target positions with gap at new position
            local target_positions = calculate_positions_with_gap(
                m_state.cards_in_hand,
                m_state.dragged_card_index,
                m_state.potential_drop_index
            )

            for i = 1, #m_state.cards_in_hand do
                if i ~= m_state.dragged_card_index then
                    if target_positions[i] then
                        if not m_state.target_hand_card_ui_positions[i] then
                            m_state.target_hand_card_ui_positions[i] = {}
                        end
                        m_state.target_hand_card_ui_positions[i].x = target_positions[i].x
                        m_state.target_hand_card_ui_positions[i].y = target_positions[i].y
                        m_state.target_hand_card_ui_positions[i].angle = target_positions[i].angle
                        m_state.target_hand_card_ui_positions[i].scale = target_positions[i].scale
                    end
                end
            end
        end

        -- Update dragged card position to follow mouse
        if not m_state.current_hand_card_ui_positions[m_state.dragged_card_index] then
            m_state.current_hand_card_ui_positions[m_state.dragged_card_index] = {}
        end
        m_state.current_hand_card_ui_positions[m_state.dragged_card_index].x = mouse_x
            - m_state.drag_offset_x
        m_state.current_hand_card_ui_positions[m_state.dragged_card_index].y = mouse_y
            - m_state.drag_offset_y
        m_state.current_hand_card_ui_positions[m_state.dragged_card_index].angle = 0
        m_state.current_hand_card_ui_positions[m_state.dragged_card_index].scale = 1.3
    else
        m_state.potential_drop_index = nil
    end
end

function love.draw()
    m_slot_machine.draw_all_columns()

    local hovered_card_index = m_hand.card_index_under_mouse(m_state.cards_in_hand)
    m_hand.draw(m_state.cards_in_hand, hovered_card_index)

    -- draw dragged card on top
    if m_state.dragged_card_index then
        local card = m_state.cards_in_hand[m_state.dragged_card_index]
        local mouse_x, mouse_y = love.mouse.getPosition()
        local pos = m_state.current_hand_card_ui_positions[m_state.dragged_card_index]

        if pos then
            local x = pos.x
            local y = pos.y

            -- Draw shadow
            m_card.draw_card_big_shadow(x, y, 10.0, 1.3)
            -- Draw dragged card (slightly lifted)
            m_card.draw_card_big(card, x, y - 5, 0, 1.3)
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        m_slot_machine.start_all_columns()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local hovered = m_hand.card_index_under_mouse(m_state.cards_in_hand)
        if hovered then
            m_state.dragged_card_index = hovered
            local card_pos = m_state.current_hand_card_ui_positions[hovered]
            if card_pos then
                m_state.drag_offset_x = x - card_pos.x
                m_state.drag_offset_y = y - card_pos.y
            end
            m_state.potential_drop_index = hovered
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and m_state.dragged_card_index then
        -- Calculate final drop position
        local dragged = m_state.dragged_card_index
        local new_index = m_state.potential_drop_index or #m_state.cards_in_hand

        -- Move the card
        local card = table.remove(m_state.cards_in_hand, dragged)
        table.insert(m_state.cards_in_hand, new_index, card)

        -- Reset drag state
        m_state.dragged_card_index = nil
        m_state.potential_drop_index = nil
        m_state.drag_offset_x = 0
        m_state.drag_offset_y = 0

        -- Update target positions without gap
        local positions = calculate_positions_with_gap(m_state.cards_in_hand, nil, nil)
        for i = 1, #m_state.cards_in_hand do
            if positions[i] then
                if not m_state.target_hand_card_ui_positions[i] then
                    m_state.target_hand_card_ui_positions[i] = {}
                end
                m_state.target_hand_card_ui_positions[i].x = positions[i].x
                m_state.target_hand_card_ui_positions[i].y = positions[i].y
                m_state.target_hand_card_ui_positions[i].angle = positions[i].angle
                m_state.target_hand_card_ui_positions[i].scale = positions[i].scale
            end
        end
    end
end
