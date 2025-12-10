local M = {}
local m_card = require("src.card")
local m_layout = require("src.layout")
local m_state = require("src.state")

---@param mouse_x number
---@param mouse_y number
---@param card_x number -- top-left X of card
---@param card_y number -- top-left Y of card
---@param card_width number
---@param card_height number
---@param rotation number -- in radians
---@return boolean
local function is_mouse_over_card(
    mouse_x,
    mouse_y,
    card_x,
    card_y,
    card_width,
    card_height,
    rotation
)
    -- center of the card
    local card_center_x = card_x + card_width / 2
    local card_center_y = card_y + card_height / 2

    -- vector from card center to mouse
    local x_offset = mouse_x - card_center_x
    local y_offset = mouse_y - card_center_y

    -- rotate the vector in the opposite direction of the card rotation
    local cosine = math.cos(-rotation)
    local sine = math.sin(-rotation)
    local x_local = x_offset * cosine - y_offset * sine
    local y_local = x_offset * sine + y_offset * cosine

    -- check if mouse is inside the unrotated card rectangle
    return math.abs(x_local) <= card_width / 2 and math.abs(y_local) <= card_height / 2
end

---@param cards Card[]
---@param hovered_index integer?
function M.draw(cards, hovered_index)
    -- Draw all cards except the dragged one
    for card_index = 1, #cards do
        local is_dragged = card_index == m_state.dragged_card_index
        local card_pos = m_state.current_hand_card_ui_positions[card_index]

        if not is_dragged and card_pos and cards[card_index] then
            -- Highlight hovered card (only when not dragging)
            if card_index == hovered_index and not m_state.dragged_card_index then
                love.graphics.setColor(0.5, 1, 1, 1)
            end

            m_card.draw_card_big(
                cards[card_index],
                card_pos.x,
                card_pos.y,
                card_pos.angle,
                card_pos.scale
            )
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

---@param cards Card[]
---@return integer?
function M.card_index_under_mouse(cards)
    if m_state.dragged_card_index then
        return nil -- Don't check for hover while dragging
    end

    local mouse_x, mouse_y = love.mouse.getPosition()

    for i = #cards, 1, -1 do
        local card_pos = m_state.current_hand_card_ui_positions[i]
        if card_pos and cards[i] then
            if
                is_mouse_over_card(
                    mouse_x,
                    mouse_y,
                    card_pos.x,
                    card_pos.y,
                    m_layout.CARD_BIG_SIZE.width * card_pos.scale,
                    m_layout.CARD_BIG_SIZE.height * card_pos.scale,
                    card_pos.angle
                )
            then
                return i
            end
        end
    end
end

return M
