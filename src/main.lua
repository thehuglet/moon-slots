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

-- Store last drop position to prevent constant rearranging
local last_potential_drop_index = nil

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.12, 0.06)
end

function love.update(dt)
    local mouse_x, mouse_y = love.mouse.getPosition()
    m_slot_machine.update_all_columns(dt)

    if m_state.dragged_card_index then
        -- Calculate potential drop position based on current mouse X
        local potential_drop_index = #m_state.cards_in_hand -- default to last position

        -- We need positions to check against, so we use a temporary calculation
        -- or we can use the last known positions
        if
            m_state.current_hand_card_ui_positions
            and #m_state.current_hand_card_ui_positions > 0
        then
            for i, pos in ipairs(m_state.current_hand_card_ui_positions) do
                if pos then
                    local card_right_edge = pos.x + (m_layout.CARD_BIG_SIZE.width * pos.scale)
                    if mouse_x < card_right_edge then
                        potential_drop_index = i
                        break
                    end
                end
            end
        end

        -- Only rearrange if the drop position has changed
        if potential_drop_index ~= last_potential_drop_index then
            last_potential_drop_index = potential_drop_index

            -- Actually move the card in the array
            local dragged = m_state.dragged_card_index
            local new_index = potential_drop_index

            -- Adjust index if needed
            if new_index > dragged then
                new_index = new_index
            end

            -- Ensure valid index
            new_index = math.max(1, math.min(new_index, #m_state.cards_in_hand))

            -- Only move if the position actually changed
            if dragged ~= new_index then
                local card = table.remove(m_state.cards_in_hand, dragged)
                table.insert(m_state.cards_in_hand, new_index, card)

                -- Update the dragged card index to its new position
                m_state.dragged_card_index = new_index
            end
        end

        -- Update dragged card position to follow mouse
        local card = m_state.cards_in_hand[m_state.dragged_card_index]
        m_state.current_hand_card_ui_positions[m_state.dragged_card_index] = {
            x = mouse_x - m_state.drag_offset_x,
            y = mouse_y - m_state.drag_offset_y,
            angle = 0,
            scale = 1.25,
        }
    else
        last_potential_drop_index = nil
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

        local x = mouse_x - m_state.drag_offset_x
        local y = mouse_y - m_state.drag_offset_y

        m_card.draw_card_big(card, x, y, 0, 1.3)
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
            m_state.drag_offset_x = x - card_pos.x
            m_state.drag_offset_y = y - card_pos.y
            last_potential_drop_index = hovered
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and m_state.dragged_card_index then
        -- Just reset the drag state - the card is already in the right position
        m_state.dragged_card_index = nil
        m_state.drag_offset_x = 0
        m_state.drag_offset_y = 0
        last_potential_drop_index = nil

        -- Clear positions so they get recalculated next frame
        m_state.current_hand_card_ui_positions = {}
    end
end
