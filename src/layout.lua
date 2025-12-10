local M = {}

M.CARD_SMALL_SIZE = {
    width = 71,
    height = 41,
}

M.CARD_BIG_SIZE = {
    width = 57,
    height = 89,
}

---@class LayoutSlotMachineReels
---@field visible_rows integer
---@field center_row integer
---@field center_y integer
---@field scissor_height integer
---@field row_spacing integer
---@field scissor_y integer
---@field height integer
M.SLOT_MACHINE_REELS = {
    x_origin = 680,
    y_origin = 50,
    vertical_cutoff_ratio = 0.75,
    column_spacing = 95,
    -- ratio of the card height
    row_spacing_ratio = 1.0,
    row_neighbor_count = 4,
    max_columns = 6,
    scale = 1.0,
}

M.CARDS_IN_HAND = {
    x_origin = 590,
    y_origin = 900,
    x_spacing_ratio = 1.2,
    scale = 1.25,
}

-- inferred values
local layout = M.SLOT_MACHINE_REELS
layout.visible_rows = layout.row_neighbor_count * 2 + 1
layout.center_row = layout.row_neighbor_count + 1
layout.row_spacing = M.CARD_SMALL_SIZE.height * layout.row_spacing_ratio * layout.scale

layout.height = layout.visible_rows * layout.row_spacing
    - (layout.row_spacing - M.CARD_SMALL_SIZE.height * layout.scale)
layout.height = layout.height * layout.vertical_cutoff_ratio
layout.center_y = layout.y_origin + layout.height / 2

return M
