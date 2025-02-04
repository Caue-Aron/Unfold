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

---@class JSON

---@class GLTF
---@field nodes GLTF.Node[]
---@field scenes GLTF.Scene[]

---@class GLTF.Scene
---@field name string

---@class GLTF.Node
---@field name string
---@field translation vector3
---@field rotation vector3
---@field scale vector3

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
local AppendDistinct = helper.AppendDistinct

---@param data JSON
---@return string[]
function M.GetDistinctID(data)
    local scene_data = Decode(data)

    local nodes = scene_data.nodes
    local scenes = scene_data.scenes

    local ids = {}

    local node
    for i = 1, #nodes do
        node = nodes[i]
        if node._id then
            AppendDistinct(ids, node._id)
        end
    end

    local scene
    for i = 1, #scenes do
        scene = scenes[i]
        if scene._id then
            AppendDistinct(ids, scene._id)
        end
    end

    return ids
end

---@param data JSON
---@param config table
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

    return helper.TableToCollectionString(unfolded_collection)
end

return M
