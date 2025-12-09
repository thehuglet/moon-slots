---@class StateModule
---@field slot_columns SlotColumn[]
local M = {}

local m_card = require("src.card")

local NUM_COLUMNS = 3

---@class SlotColumn
---@field deck Card[]
---@field cursor number
---@field spin_duration number?      -- total spin duration
---@field spin_time_remaining number? -- remaining spin time
---@field max_speed number?   -- peak speed for easing

---@type SlotColumn[]
M.slot_columns = {}

local card_spacing = 41 -- spacing in pixels

for col = 1, NUM_COLUMNS do
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

    table.insert(M.slot_columns, {
        deck = deck,
        cursor = 0,
        spin_duration = 0, -- set when spinning
        spin_time_remaining = 0,
        max_speed = 0, -- optional, set per spin
    })
end

return M
