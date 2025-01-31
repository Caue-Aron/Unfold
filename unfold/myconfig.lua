---@class UnfoldConfig
---@field _id string[]
--- recieves the node table that will be transformed into either
--- a collection or a gameobject. In order to discard it, return false,
--- otherwise return true in order to keep the node into the next operations.
--- In the case that this function isnt implemented, all nodes are kept.
---@field OnNodeStart? fun(node: table): boolean
--- recieves the node table that got transformed into a gameobject or
--- collection already. This is the last step before a node gets computed
--- and ready to be used in collections or gameobjects
---@field OnNodeEnd? fun(node: table): boolean

---@type UnfoldConfig
local M = {
    _id = {
        cube = "/test_chamber/cube.go",
        cylinder = "/test_chamber/pillar.go",
        cube_parent = "/test_chamber/cube.go",
    }
}

return M
