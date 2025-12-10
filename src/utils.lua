local M = {}

function M.clamp(v, minv, maxv)
    return math.max(minv, math.min(maxv, v))
end

return M
