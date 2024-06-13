local function prettyTable( tbl, str, prefix )
    str = str or ""
    if not next( tbl ) then
        return "{}"
    end

    if not prefix then
        str = str .. "{"
        prefix = "   "
    end

    for k, v in pairs( tbl ) do
        if istable( v ) then
            str = str .. "\n" .. prefix .. tostring( k ) .. " = {"
            str = str .. prettyTable( v, str, prefix .. "    " )
        else
            str = str .. "\n" .. prefix .. tostring( k ) .. " = " .. tostring( v ) .. ","
        end
    end

    str = str .. "\n" .. "},"
    return str
end

function luapad.PrettyPrint( obj )
    if istable( obj ) then
        return prettyTable( obj )
    end

    if isfunction( obj ) then
        local info = debug.getinfo( obj )
        return prettyTable( info )
    end

    return tostring( obj )
end
