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
    print("ERROR:UNFOLD: " .. (msg or "nil"))
end

function M.Warning(msg)
    print("WARNING:UNFOLD: " .. (msg or "nil"))
end

function M.Debug(msg)
    print("DEBUG:UNFOLD: " .. (msg or "nil"))
end

function M.Info(msg)
    print("INFO:UNFOLD: " .. (msg or "nil"))
end

function M.Fatal(msg)
    print("FATAL:UNFOLD: " .. (msg or "nil"))
end

return M
