local MAX_DEPTH = 3

local function getIndent( depth )
    local str = ""
    for _ = 1, depth do
        str = str .. "  "
    end
    return str
end

local function prettyTable( tbl, str, indent, done )
    if not next( tbl ) then
        return "{}"
    end

    if not str then
        str = "{"
        indent = 0
        done = {}
    end

    if tbl == _G then
        return str .. "\n" .. getIndent( indent ) .. "_G = _G,"
    end

    if indent >= MAX_DEPTH then
        return str .. "\n" .. getIndent( indent + 1 ) .. "Max table depth " .. tostring( tbl ) .. "," .. "\n" .. getIndent( indent ) .. "},"
    end

    done[tbl] = true

    indent = indent + 1
    for k, v in pairs( tbl ) do
        if istable( v ) then
            if done[v] then
                str = str .. "\n" .. getIndent( indent ) .. tostring( k ) .. " = Recursive " .. tostring( v ) .. ","
            else
                str = str .. "\n" .. getIndent( indent ) .. tostring( k ) .. " = {"
                str = prettyTable( v, str, indent, done )
            end
        else
            str = str .. "\n" .. getIndent( indent ) .. tostring( k ) .. " = " .. tostring( v ) .. ","
        end
    end
    indent = indent - 1

    return str .. "\n" .. getIndent( indent ) .. "},"
end

function luapad.PrettyPrint( obj )
    if not obj then
        return ""
    end

    if istable( obj ) then
        return prettyTable( obj )
    end

    if isfunction( obj ) then
        local info = debug.getinfo( obj )
        return prettyTable( info )
    end

    return tostring( obj )
end
