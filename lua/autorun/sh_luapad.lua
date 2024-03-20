luapad = luapad or {}
luapad.Frame = luapad.Frame or nil
luapad.OpenFiles = luapad.OpenFiles or {}

local clUsers = {
    ["STEAM_0:0:89834634"] = true, -- MrSmig
    ["STEAM_0:0:60212276"] = true, -- Nanners
    ["STEAM_0:1:115653024"] = true -- NoahG
}

local svUsers = {
    ["STEAM_0:0:55976004"] = true, -- Redox
    ["STEAM_0:1:74347705"] = true, -- Charity
}

-- Add all the server users to the client users
for id in pairs( svUsers ) do
    clUsers[id] = true
end

function luapad.CanUseSV( ply )
    if not IsValid( ply ) then return false end
    if not svUsers[ply:SteamID()] then return false end
    return true
end

function luapad.CanUseCL( ply )
    if not IsValid( ply ) then return false end
    if not clUsers[ply:SteamID()] then return false end
    return true
end

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

if SERVER then
    AddCSLuaFile( "luapad/client/server_globals.lua" )
    AddCSLuaFile( "luapad/client/luapad_editorpanel.lua" )
    AddCSLuaFile( "luapad/client/cl_luapad.lua" )

    include( "luapad/server/sv_luapad.lua" )
end

if CLIENT then
    include( "luapad/client/server_globals.lua" )
    include( "luapad/client/luapad_editorpanel.lua" )
    include( "luapad/client/cl_luapad.lua" )
end
