local m_card = require("src.card")
local m_slot_machine = require("src.slot_machine")
local m_state = require("src.state")

---@param atlas love.Image
---@param cols integer
---@param rows integer
---@return table<love.Quad>
local function quads_from_atlas(atlas, cols, rows)
    local atlasWidth, atlasHeight = atlas:getWidth(), atlas:getHeight()
    local spriteWidth = atlasWidth / cols
    local spriteHeight = atlasHeight / rows

    ---@type table<love.Quad>
    local quads = {}

    for y = 0, rows - 1 do
        quads[y + 1] = {}
        for x = 0, cols - 1 do
            quads[y + 1][x + 1] = love.graphics.newQuad(
                x * spriteWidth,
                y * spriteHeight,
                spriteWidth,
                spriteHeight,
                atlasWidth,
                atlasHeight
            )
        end
    end

    return quads
end

local cards_small_atlas = love.graphics.newImage("assets/cards_small.png")
local cards_big_atlas = love.graphics.newImage("assets/cards_big.png")

local card_spacing = 41
local startX, startY = 50, 50

local rows, cols = 4, 13
local cards_small_quads = quads_from_atlas(cards_small_atlas, cols, rows)
local cards_big_quads = quads_from_atlas(cards_big_atlas, cols, rows)

-- local cards_test = {
--     m_card.Card(m_card.RANK.JACK, m_card.SUIT.SPADES),
--     m_card.Card(m_card.RANK.ACE, m_card.SUIT.SPADES),
-- }

-- build deck
local deck = {}
for suit = 1, 4 do
    for rank = 1, 13 do
        table.insert(deck, m_card.Card(rank, suit))
    end
end

-- shuffle deck (Fisher–Yates)
for i = #deck, 2, -1 do
    local j = love.math.random(i) -- random integer between 1 and i
    deck[i], deck[j] = deck[j], deck[i]
end

-- give each card a floating position
local card_positions = {}
for i = 1, #deck do
    card_positions[i] = i * card_spacing
end

-- local speed = 1000 -- pixels per second
local VISIBLE_SLOTS = 5
local COLUMN_SPACING = 120

local visible = 7

local scissors_x, scissors_y = 100, 170 -- top-left corner of the visible reel area
local width, height = 100, 100 -- size of the visible area

-- helper: wrap an index into an array (1..n)
local function wrap_index(t, i)
    local n = #t
    if n == 0 then
        return nil
    end
    -- convert any integer i into 1..n
    return ((i - 1) % n) + 1
end

function love.load()
    -- start spinning all columns
    for col_index, _ in ipairs(m_state.slot_columns) do
        m_slot_machine.start_column(col_index, 2500)
    end
end

function love.update(dt)
    if love.keyboard.isDown("r") then
        m_state.slot_columns[1].cursor = m_state.slot_columns[1].cursor + 500.0 * dt
    end

    m_slot_machine.update_all_columns(dt, card_spacing)
    -- print(m_state.slot_columns[1].cursor % 1)
end

function love.draw()
    local center_y = scissors_y + (height / 2)
    local sigma = card_spacing * 1.5
    -- local slot_col_one = m_state.slot_columns[1]

    -- love.graphics.setScissor(scissors_x, scissors_y, width, height)
    for column_index = 1, #m_state.slot_columns do
        local column = m_state.slot_columns[column_index]
        local start_index = math.floor(column.cursor / card_spacing) + 1

        for card_row = 0, visible - 1 do
            local index = ((start_index + card_row - 1) % #column.deck) + 1
            local x = 100 + column_index * 100
            local y = 100 + (card_row * card_spacing) - (column.cursor % card_spacing)
            local card = column.deck[index]

            local atlas_row = card.suit
            local atlas_col = m_card.RANK_TO_ATLAS_COL[card.rank]
            local quad = cards_small_quads[atlas_row][atlas_col]

            local distance = y - center_y
            local factor = math.exp(-0.5 * (distance / sigma) ^ 2)
            love.graphics.setColor(factor, factor, factor, 1)

            love.graphics.draw(cards_small_atlas, quad, x, y)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.setScissor()
end
