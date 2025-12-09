local M = {}

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

---@class Card
---@field rank integer
---@field suit integer
---@return Card
function M.Card(rank, suit)
    return { rank = rank, suit = suit }
end

M.RANK_TO_ATLAS_COL = {
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

return M
