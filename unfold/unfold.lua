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

---@param config_path string|table
---@return table
local function AssertConfigFile(config_path)
    ---@type UnfoldConfig
    local config_table
    local config_path_type = type(config_path)

    if config_path_type == "string" then
        if config_path:sub(1, 1) == "/" then
            config_table = dofile(string.TrimPath(config_path))
        else
            config_table = dofile(config_path)
        end

        local config_type = type(config_table)
        if config_type == "nil" then
            error("Configuration file " .. config_path .. " must return a table.")
        elseif type(config_table) ~= "table" then
            error("Configuration returns " .. config_type .. ". `Table` expected")
        end
    elseif config_path_type == "table" then
        config_table = config_path
    else
        error("Invalid config type: `" .. config_path_type .. "`. Expected table or path.")
    end

    if type(config_table._id) ~= "table" then
        error("Configuration file's `_id` field is `" ..
            type(config_table._id) .. "`. Expected an array of strings")
    end

    return config_table
end

---@param scene_path string|table
---@return table
local function AssertSceneFile(scene_path)
    local scene_table
    local scene_json
    local scene_path_type = type(scene_path)
    if scene_path_type == "string" then
        local first_char = scene_path:sub(1, 1)
        if first_char == "{" then
            scene_json = scene_path
        else
            if first_char == "/" then
                scene_path = string.TrimPath(scene_path)
            end
            local scene_file, err = io.open(scene_path, "r")
            if scene_file then
                scene_json = scene_file:read("*a")
                scene_file:close()
            else
                error(err)
            end
        end
        scene_table = Decode(scene_json)
    elseif scene_path_type == "table" then
        scene_table = scene_path
    end

    return scene_table
end

local function AdjustNode(node)
    local extras = node.extras
    if extras then
        for k, v in pairs(extras) do
            node[k] = v
        end
        node.extras = nil
    end
end

local function AdjustScene(scene)
    local extras = scene.extras
    if extras then
        for k, v in pairs(extras) do
            scene[k] = v
        end
        scene.extras = nil
    end
end

local M = {}
local AppendDistinct = helper.AppendDistinct

---@param scene_path string|JSON
---@return string[]
function M.GetDistinctID(scene_path)
    local scene_data = AssertSceneFile(scene_path)

    local nodes = scene_data.nodes
    local scenes = scene_data.scenes

    local ids = {
        nodes = {},
        scenes = {}
    }

    local node
    for i = 1, #nodes do
        node = nodes[i]
        AdjustNode(node)
        if node._id then
            AppendDistinct(ids.nodes, node._id)
        end
    end

    local scene
    for i = 1, #scenes do
        scene = scenes[i]
        AdjustScene(scene)
        if scene._id then
            AppendDistinct(ids.scenes, scene._id)
        end
    end

    return ids
end

---@param scene_path string|table
---@param config_path string|table
---@return string
function M.UnfoldString(scene_path, config_path)
    local config = AssertConfigFile(config_path)
    local scene = AssertSceneFile(scene_path)

    local nodes = scene.nodes
    local scenes = scene.scenes
    local root_scene_idx = scene.scene + 1

    local unfolded_nodes = {}
    local node
    for i = 1, #nodes do
        node = nodes[i]
        AdjustNode(node)
        unfolded_nodes[#unfolded_nodes + 1] = NodeToEmbeddedGO(node, config)
    end

    local unfolded_scenes = {}
    local scene
    for i = 1, #scenes do
        scene = scenes[i]
        AdjustScene(scene)
        unfolded_scenes[#unfolded_scenes + 1] = SceneToCollection(scene, unfolded_nodes)
    end

    local unfolded_collection = unfolded_scenes[root_scene_idx]

    return helper.TableToCollectionString(unfolded_collection)
end

---@param scene_path string|table
---@param config_path string|table
---@param output_path string
function M.UnfoldFile(scene_path, config_path, output_path)
    local unfolded_collection = M.UnfoldString(scene_path, config_path)
    local test, err = io.open(output_path, "w+")
    if test then
        test:write(unfolded_collection)
        test:close()
    else
        error(err)
    end
end

return M
