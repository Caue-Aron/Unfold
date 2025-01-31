local helper = require 'unfold.unfold_helper'
local log = require 'unfold.unfold_log'
local Decode = require 'unfold.json'.decode

local M = {}

---@param data string
---@param config table?
---@return string
function M.UnfoldString(data, config)
    local scene_data = Decode(data)
    local unfolded_collection = {
        name = scene_data.scenes[1].name
    }
    log.Debug(unfolded_collection.name)
end

return M
