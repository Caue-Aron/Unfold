local log = require 'unfold.unfold_log'

---@param str string
---@param suffix string
---@return boolean
function string.EndsWith(str, suffix)
    print(str:sub(- #suffix) == suffix)
    return str:sub(- #suffix) == suffix
end

function string.TrimPath(str)
    return str:sub(2)
end

function string.GetPathAndFile(path)
    return string.match(path, "(.*)/([^/]+)")
end

function string.StripExtension(path)
    return path:match("^(.-)%.%w+$"), path:match("%.([%w_]+)$")
end

function io.CheckFileExists(path)
    local file, err = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

---@return table
local function ShallowCopyTable(t)
    local tt = {}
    for key, value in pairs(t) do
        ttype = type(value)
        if ttype == "table" then
            tt[key] = ShallowCopyTable(value)
        elseif ttype ~= "nil" and ttype ~= "function" and ttype ~= "thread" and ttype ~= "userdata" then
            tt[key] = value
        end
    end
    return tt
end

local function TableToCollectionRaw(t, ident)
    ident = ident or 0
    local tab_char = "  "
    local prototext = ""
    for k, v in pairs(t) do
        prototext = prototext .. string.rep(tab_char, ident)

        if type(v) == "table" then
            -- multiple instances of the same key are held as index based table
            if v[1] then
                for i, vv in ipairs(v) do
                    prototext = prototext .. tostring(k) .. " {\n"
                    if type(vv) == "table" then
                        prototext = prototext .. TableToCollectionRaw(vv, ident + 1)
                    end
                    prototext = prototext .. string.rep(tab_char, ident) .. "}\n"
                end
            else
                prototext = prototext .. tostring(k) .. " {\n"
                prototext = prototext .. TableToCollectionRaw(v, ident + 1)
                prototext = prototext .. string.rep(tab_char, ident) .. "}"
            end
        else
            prototext = prototext .. tostring(k) .. ": "
            -- special cases
            if k == "scale_along_z" then
                prototext = prototext .. string.format("%i", v)
            elseif type(v) == "nil" then
                prototext = prototext .. "null"
            elseif type(v) == "number" then
                prototext = prototext .. math.floor(v * 1000 + 0.5) / 1000
            elseif type(v) == "string" then
                prototext = prototext .. string.format('"%s"', v)
            elseif type(v) ~= "thread" and type(v) ~= "function" and type(v) ~= "userdata" then
                prototext = prototext .. tostring(v)
            end
        end

        -- prototext = prototext .. "\t" .. type(v) .. "\n"
        prototext = prototext .. "\n"
    end

    return prototext
end

-- Called in order to make the table succeptible to being turned into a collction
local function TableToCollectionHelper(ot, ident)
    local t = ShallowCopyTable(ot)
    t.scale_along_z = t.scale_along_z or 0
    return TableToCollectionRaw(t, ident):gsub("\n\n+", "\n")
end

local M = {}

---@param t array
---@param tv any
---@return boolean
function M.AppendDistinct(t, tv)
    for i = 1, #t do
        if t[i] == tv then
            return false
        end
    end

    return true
end

---@param t table
---@param ouput_path string
---@return string
function M.TableToCollection(t, ouput_path)
    if not ouput_path:EndsWith(".collection") then
        ouput_path = ouput_path .. ".collection"
    end
    local collection_str = M.TableToCollectionString(t)
    local collection_file, err = io.open(ouput_path, "w+")
    if collection_file then
        collection_file:write(collection_str)
        return ouput_path
    else
        error(err)
    end
end

---@param t table
---@return string
function M.TableToCollectionString(t)
    local str = TableToCollectionHelper(t)
    return str:sub(1, #str - 1)
end

return M
