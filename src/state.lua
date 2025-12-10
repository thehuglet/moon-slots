local M = {}
local m_card = require("src.card")
local m_layout = require("src.layout")

local NUM_COLUMNS = 6
local NUM_HAND_CARD_SLOTS = 7

---@class TweenState
---@field start number
---@field target number
---@field time number
---@field duration number
---@field delay number
---@field easing fun(t:number):number

---@class SlotColumn
---@field deck Card[]
---@field cursor number
---@field spin_duration number?
---@field spin_time_remaining number?
---@field tween TweenState?

---@type SlotColumn[]
M.slot_machine_columns = {}

---@type Card[]
M.cards_in_hand = {}

---@type integer?
M.dragged_card_index = nil

---@type integer
M.drag_offset_x = 0
M.drag_offset_y = 0

---@type integer?
M.potential_drop_index = nil

---@class HandUIPositions
---@field x number
---@field y number
---@field angle number
---@field scale number

---@type HandUIPositions[]
M.current_hand_card_ui_positions = {}

---@type HandUIPositions[]
M.target_hand_card_ui_positions = {}

---@type table<integer, boolean>
M.needs_tweening = {}

-- Tweening properties
M.tween_speed = 0.2 -- How fast cards move (0-1, higher = faster)

for _ = 1, NUM_COLUMNS do
    -- build deck
    local deck = {}
    for suit = 1, 4 do
        for rank = 1, 13 do
            table.insert(deck, m_card.Card(rank, suit))
        end
    end

    -- shuffle deck
    for i = #deck, 2, -1 do
        local j = love.math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end

    table.insert(M.slot_machine_columns, {
        deck = deck,
        cursor = 0,
        spin_duration = 0,
        spin_time_remaining = 0,
        tween = nil,
    })
end

for hand_card_slot_index = 1, NUM_HAND_CARD_SLOTS do
    local layout = m_layout.CARDS_IN_HAND
    local x_spacing = m_layout.CARD_BIG_SIZE.width * layout.x_spacing_ratio * layout.scale
    table.insert(M.cards_in_hand, m_card.Card(m_card.RANK.ACE, m_card.SUIT.SPADES))
end

return M
