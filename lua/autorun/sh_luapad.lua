luapad = luapad or {}
luapad.Frame = luapad.Frame or nil
luapad.OpenFiles = luapad.OpenFiles or {}

local function gettraceback( err )
    local trace = err .. "\n"
    local traceback = debug.traceback()

    local expl = string.Explode( "\n", traceback )
    table.remove( expl, 1 ) -- Removes "stack traceback:"
    table.remove( expl, 1 ) -- Removes the line as we already have it

    for _, line in ipairs( expl ) do
        line = string.gsub( line, "\t", "" )
        if line == "[C]: in function 'xpcall'" then break end
        trace = trace .. line .. "\n"
    end

    return trace
end

function luapad.Execute( str, src )
    local func = CompileString( str, src, false )
    if isstring( func ) then
        return false, func
    end

    local status, ret = xpcall( func, gettraceback )
    if not status then
        return false, ret
    end

    return true, ret
end

if CLIENT then
    include( "luapad/client/server_globals.lua" )
    include( "luapad/client/luapad_editorpanel.lua" )
    include( "luapad/client/luapad_consolepanel.lua" )
    include( "luapad/client/cl_auth.lua" )
    include( "luapad/client/cl_functions.lua" )
    include( "luapad/client/cl_luapad.lua" )
end
