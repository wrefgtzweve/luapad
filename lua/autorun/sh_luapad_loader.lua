luapad = luapad or {}

local SERVER = SERVER
local function include_shared( path )
    if SERVER then
        AddCSLuaFile( path )
    end
    include( path )
end

local function include_client( path )
    if SERVER then
        AddCSLuaFile( path )
    else
        include( path )
    end
end

local function include_server( path )
    if not SERVER then return end
    include( path )
end

include_shared( "luapad/shared/code_execution.lua" )
include_shared( "luapad/shared/net.lua" )

include_client( "luapad/client/ui_materials.lua" )
include_client( "luapad/client/luapad_editorpanel.lua" )
include_client( "luapad/client/luapad_consolepanel.lua" )
include_client( "luapad/client/auth.lua" )
include_client( "luapad/client/functions.lua" )
include_client( "luapad/client/luapad.lua" )

include_server( "luapad/server/auth.lua" )
include_server( "luapad/server/code_execution.lua" )

AddCSLuaFile( "luapad/client/server_globals.lua" ) -- Special case, only gets included when luapad is being used.
