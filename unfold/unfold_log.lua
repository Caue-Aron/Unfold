local M = {}

local function Log(severity, tag, subtag, msg)
    assert()
    if type(msg) == "nil" then
        if type(subtag) == "nil" then
            subtag = "nil"
        end
        msg = subtag
        subtag = ""
    end
    print("ERROR:UNFOLD: " .. msg)
end

function M.Error(msg)
    print("ERROR:UNFOLD: " .. tostring(msg))
end

function M.Warning(msg)
    print("WARNING:UNFOLD: " .. tostring(msg))
end

function M.Debug(msg)
    print("DEBUG:UNFOLD: " .. tostring(msg))
end

function M.Info(msg)
    print("INFO:UNFOLD: " .. tostring(msg))
end

function M.Fatal(msg)
    print("FATAL:UNFOLD: " .. tostring(msg))
end

return M
