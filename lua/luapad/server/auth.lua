util.AddNetworkString( "luapad.RequestCLAuth" )

function luapad.CanUseSV( ply )
    if not IsValid( ply ) then return false end
    if ply:IsListenServerHost() then return true end

    local result = hook.Run( "LuapadCanRunSV", ply )
    if result == true then return true end

    return false
end

local clAllowLua = GetConVar( "sv_allowcslua" )
function luapad.CanUseCL( ply )
    if clAllowLua:GetBool() then return true end
    if luapad.CanUseSV( ply ) then return true end

    local result = hook.Run( "LuapadCanRunCL", ply )
    if result == true then return true end

    return false
end

function luapad.SendAuth( ply )
    net.Start( "luapad.RequestCLAuth" )
    net.WriteBool( luapad.CanUseCL( ply ) )
    net.WriteBool( luapad.CanUseSV( ply ) )
    net.Send( ply )
end

net.Receive( "luapad.RequestCLAuth", function( _, ply )
    if ply.LuapadCLAuthTimeout and ply.LuapadCLAuthTimeout > CurTime() then return end
    ply.LuapadCLAuthTimeout = CurTime() + 1

    luapad.SendAuth( ply )
end )
