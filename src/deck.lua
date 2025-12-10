local M = {}
local m_card = require("src.card")

function M.build_standard_52()
    local deck = {}
    for suit = 1, 4 do
        for rank = 1, 13 do
            table.insert(deck, m_card.Card(rank, suit))
        end
    end
    return deck
end

function M.shuffle(deck)
    -- deep copy
    local shuffled = {}
    for i = 1, #deck do
        local card = deck[i]
        shuffled[i] = m_card.Card(card.rank, card.suit)
    end

    for i = #shuffled, 2, -1 do
        local j = love.math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    return shuffled
end

return M
