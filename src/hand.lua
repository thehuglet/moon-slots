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
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local card_width = m_layout.CARD_BIG_SIZE.width * m_layout.CARDS_IN_HAND.scale

    local card_count = #cards
    if card_count == 0 then
        return
    end

    local max_total_width = window_width * 0.5
    local x_spacing = math.min(card_width * 0.9, max_total_width / card_count)
    local total_width = card_width + (card_count - 1) * x_spacing

    local x_start = window_width * 0.5 - total_width * 0.5
    local y_start = window_height * 0.75

    local center_index = (card_count + 1) / 2
    local y_curve_strength = 60

    local fan_angle = math.rad(50)
    local angle_step = card_count > 1 and fan_angle / (card_count - 1) or 0

    -- clear positions table
    m_state.current_hand_card_ui_positions = {}

    for card_index = 1, card_count do
        local is_dragged = m_state.dragged_card_index == card_index

        local x = x_start + (card_index - 1) * x_spacing
        local angle = -fan_angle * 0.5 + (card_index - 1) * angle_step
        local offset = card_index - center_index
        local y_offset = y_curve_strength * (offset ^ 2) / ((card_count / 2) ^ 2)
        local y = y_start + y_offset

        -- update positions for hit detection
        m_state.current_hand_card_ui_positions[card_index] = {
            x = x,
            y = y,
            angle = angle,
            scale = 1.25,
        }

        if not is_dragged and cards[card_index] then
            m_card.draw_card_big(cards[card_index], x, y, angle, 1.25)
        end
    end
end

---@param cards Card[]
---@return integer?
function M.card_index_under_mouse(cards)
    local mouse_x, mouse_y = love.mouse.getPosition()

    for i = #m_state.current_hand_card_ui_positions, 1, -1 do
        local card_pos = m_state.current_hand_card_ui_positions[i]
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

return M
