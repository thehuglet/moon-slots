local M = {}
local m_assets = require("src.assets")
local m_layout = require("src.layout")
local m_utils = require("src.utils")

local cards_small_atlas = love.graphics.newImage("assets/cards_small.png")
local cards_big_atlas = love.graphics.newImage("assets/cards_big.png")
local card_big_shadow = love.graphics.newImage("assets/card_big_shadow.png")

local cards_small_quads = m_assets.get_quads(cards_small_atlas, 13, 4)
local cards_big_quads = m_assets.get_quads(cards_big_atlas, 13, 4)

---@enum Suit
M.SUIT = {
    SPADES = 1,
    HEARTS = 2,
    CLUBS = 3,
    DIAMONDS = 4,
}

---@enum Rank
M.RANK = {
    NUM_2 = 1,
    NUM_3 = 2,
    NUM_4 = 3,
    NUM_5 = 4,
    NUM_6 = 5,
    NUM_7 = 6,
    NUM_8 = 7,
    NUM_9 = 8,
    NUM_10 = 9,
    JACK = 10,
    QUEEN = 11,
    KING = 12,
    ACE = 13,
}

local RANK_TO_ATLAS_COL = {
    [M.RANK.ACE] = 1,
    [M.RANK.NUM_2] = 2,
    [M.RANK.NUM_3] = 3,
    [M.RANK.NUM_4] = 4,
    [M.RANK.NUM_5] = 5,
    [M.RANK.NUM_6] = 6,
    [M.RANK.NUM_7] = 7,
    [M.RANK.NUM_8] = 8,
    [M.RANK.NUM_9] = 9,
    [M.RANK.NUM_10] = 10,
    [M.RANK.JACK] = 11,
    [M.RANK.QUEEN] = 12,
    [M.RANK.KING] = 13,
}

---@class Card
---@field rank integer
---@field suit integer
---@return Card
function M.Card(rank, suit)
    return { rank = rank, suit = suit }
end

---@param card Card
---@param x integer
---@param y integer
---@param scale number?
function M.draw_card_small(card, x, y, scale)
    local atlas_row = card.suit
    local atlas_col = RANK_TO_ATLAS_COL[card.rank]
    local quad = cards_small_quads[atlas_row][atlas_col]

    love.graphics.draw(cards_small_atlas, quad, x, y, 0, scale, scale)
end

---@param x integer
---@param y integer
---@param max_length number
---@param scale number?
function M.draw_card_big_shadow(x, y, max_length, scale)
    local factor = 0.1

    local window_width = love.graphics.getWidth() * 0.5
    local window_height = love.graphics.getHeight() * 0.5
    local card_center_x = x + m_layout.CARD_BIG_SIZE.width * 0.5
    local card_center_y = y + m_layout.CARD_BIG_SIZE.height * 0.5

    -- stylua: ignore start
    local vector_x = m_utils.clamp((window_width - card_center_x) * factor, -max_length, max_length)
    local vector_y = m_utils.clamp((window_height - card_center_y) * factor, -max_length, max_length)
    -- stylua: ignore end

    local shadow_x = x + vector_x
    local shadow_y = y + vector_y

    love.graphics.draw(card_big_shadow, shadow_x, shadow_y, 0, scale, scale)
end

---@param card Card
---@param x number -- top-left of unscaled card
---@param y number
---@param angle_radians number
---@param scale number?
function M.draw_card_big(card, x, y, angle_radians, scale)
    scale = scale or 1
    local atlas_row = card.suit
    local atlas_col = RANK_TO_ATLAS_COL[card.rank]
    local quad = cards_big_quads[atlas_row][atlas_col]

    local card_width = m_layout.CARD_BIG_SIZE.width * scale
    local card_height = m_layout.CARD_BIG_SIZE.height * scale

    love.graphics.draw(
        cards_big_atlas,
        quad,
        x + card_width / 2,
        y + card_height / 2,
        angle_radians,
        scale,
        scale,
        m_layout.CARD_BIG_SIZE.width / 2, -- origin in unscaled coordinates
        m_layout.CARD_BIG_SIZE.height / 2
    )
end

return M
