local helper = require 'unfold.unfold_helper'
local log = require 'unfold.unfold_log'
local Decode = require 'unfold.json'.decode

local function ArrayToVector(arr)
    if type(arr) == "table" then
        return { x = arr[1] or nil, y = arr[2] or nil, z = arr[3] or nil, w = arr[4] or nil }
    end
end

local function NodeToEmbeddedGO(node, config)
    if config.OnNodeStart then
        if not config.OnNodeStart(node) then
            return nil
        end
    end

    local embedded_go = {
        prototype = config._id[node._id],
        id = node.name,
        position = ArrayToVector(node.translation),
        rotation = ArrayToVector(node.rotation),
        scale3 = ArrayToVector(node.scale)
    }

    if config.OnNodeStart then
        if not config.OnNodeEnd(embedded_go) then
            return nil
        end
    end

    return embedded_go
end

local function SceneToCollection(scene, unfolded_nodes)
    local instances = {}
    local collection = {
        name = scene.name,
        instances = instances
    }
    local folded_nodes = scene.nodes
    for i = 1, #folded_nodes do
        instances[#instances + 1] = unfolded_nodes[folded_nodes[i] + 1]
    end
    return collection
end

local M = {}

---@param data string
---@param config table?
---@return string
function M.UnfoldString(data, config)
    local scene_data = Decode(data)

    local nodes = scene_data.nodes
    local scenes = scene_data.scenes
    local root_scene_idx = scene_data.scene + 1

    local unfolded_nodes = {}
    local node
    for i = 1, #nodes do
        node = nodes[i]
        for k, v in pairs(node.extras) do
            node[k] = v
        end
        node.extras = nil
        unfolded_nodes[#unfolded_nodes + 1] = NodeToEmbeddedGO(node, config)
    end

    local unfolded_scenes = {}
    local scene
    for i = 1, #scenes do
        scene = scenes[i]
        unfolded_scenes[#unfolded_scenes + 1] = SceneToCollection(scene, unfolded_nodes)
    end

    local unfolded_collection = unfolded_scenes[root_scene_idx]

    helper.TableToCollection(unfolded_collection, "example/test")
end

return M
