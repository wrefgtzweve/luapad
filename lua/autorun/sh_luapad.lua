luapad = {}
luapad.OpenFiles = {}

luapad.debugmode = false

local allowedPlayers = {
    ["STEAM_0:0:55976004"] = true,
    ["STEAM_0:1:74347705"] = true
}

function luapad.CanUseLuapad( ply )
    if not IsValid( ply ) then return false end
    if not allowedPlayers[ply:SteamID()] then return false end
    return true
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
