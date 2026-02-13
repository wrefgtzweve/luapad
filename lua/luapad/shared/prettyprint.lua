local MAX_TBL_LEN = 256
local MAX_DEPTH = 10

local converters = {
    ["function"] = function( func )
        local info = debug.getinfo( func )
        local str = tostring( func )
        return str .. " " .. info.short_src .. ":" .. info.linedefined
    end,
    ["string"] = function( str )
        return string.format( "\"%s\"", str )
    end
}
local function varToStr( var )
    local t = type( var )
    if converters[t] then
        return converters[t]( var )
    end

    return tostring( var )
end

local function prettyTable( t, str, indent, depth, done )
    indent = indent or 0
    str = str or ""
    depth = depth or 0
    done = done or {}

    if depth > MAX_DEPTH then
        return str .. string.rep( "  ", indent ) .. "Max table depth reached\n"
    end
    depth = depth + 1

    local keys = table.GetKeys( t )
    table.sort( keys, function( a, b )
        if ( isnumber( a ) and isnumber( b ) ) then return a < b end
        return tostring( a ) < tostring( b )
    end )

    done[t] = true

    local overMaxLen = #keys > MAX_TBL_LEN
    for i = 1, #keys do
        local key = keys[i]
        local value = t[key]
        key = ( type( key ) == "string" ) and "[\"" .. key .. "\"]" or "[" .. varToStr( key ) .. "]"
        str = str .. string.rep( "  ", indent )

        if istable( value ) and not done[value] then
            done[value] = true
            str = str .. key .. ":\n"
            str = prettyTable( value, str, indent + 2, depth, done )
            done[value] = nil
        else
            str = str .. key .. "\t=\t" .. varToStr( value ) .. "\n"
        end

        if overMaxLen and i == MAX_TBL_LEN then
            str = str .. string.rep( "  ", indent ) .. #keys - MAX_TBL_LEN .. " more elements...\n"
            break
        end
    end

    return str
end

function luapad.PrettyPrint( obj )
    if obj == nil then
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

function luapad.PrettyStack( err, stack )
    if not stack then
        stack = {}
        for i = 2, 1024 do
            local info = debug.getinfo( i )
            if not info then break end
            if info.name == "xpcall" then break end

            table.insert( stack, { Function = info.name, File = info.short_src, Line = info.currentline } )
        end
    end

    local niceError = err
    niceError = string.Replace( niceError, "\t", ( " " ):rep( 12 ) )
    for i, t in pairs( stack ) do
        if ( not t.Function or t.Function == "" ) then t.Function = "unknown" end

        niceError = niceError .. "\n" .. ( " " ):rep( i ) .. i .. ". " .. t.Function .. " - " .. t.File .. ":" .. t.Line
    end

    return niceError
end