local function turnCollection(t, ident)
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
                        prototext = prototext .. turnCollection(vv, ident + 1)
                    end
                    prototext = prototext .. string.rep(tab_char, ident) .. "}\n"
                end
            else
                prototext = prototext .. tostring(k) .. " {\n"
                prototext = prototext .. turnCollection(v, ident + 1)
                prototext = prototext .. string.rep(tab_char, ident) .. "}"
            end
        else
            prototext = prototext .. tostring(k) .. ": "
            -- special cases
            if k == "scale_along_z" then
                prototext = prototext .. string.format("%.0f", v)
            elseif type(v) == "nil" then
                prototext = prototext .. "null"
            elseif type(v) == "number" then
                prototext = prototext .. string.format("%.3f", v)
            elseif type(v) == "string" then
                prototext = prototext .. string.format('"%s"', v)
            elseif type(v) ~= "thread" and type(v) ~= "function" and type(v) ~= "userdata" then
                prototext = prototext .. tostring(v)
            end
        end

        prototext = prototext .. "\n"
    end

    return prototext
end

local M = {}

---@param t table
---@param ouput_path string
---@return string?
function M.tableToCollection(t, ouput_path)
    local collection_str = M.tableToCollectionString(t)
    local collection_file, err = io.open(ouput_path, "w+")
    if collection_file then
        collection_file:write(collection_str)
    else
        return err
    end
end

---@param t table
---@return string
function M.tableToCollectionString(t)
    local str = turnCollection(t, 0):gsub("\n\n+", "\n")
    return str:sub(1, #str - 1)
end

return M
