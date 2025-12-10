local M = {}

---@param atlas love.Image
---@param cols integer
---@param rows integer
---@return table<love.Quad>
function M.get_quads(atlas, cols, rows)
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

return M
