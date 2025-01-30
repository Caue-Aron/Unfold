local JsonToLua = require 'unfold.json'.decode
local buddy_fold = require 'unfold.buddy_fold'

local M = {}

---@param gltf string
---@param config table
---@return boolean, string
function M.UnfoldString(gltf, config)
    local json_success, result = pcall(JsonToLua, gltf)
    if not json_success then

    end
end

return M
