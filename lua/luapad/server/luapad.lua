util.AddNetworkString( "luapad_runserver" )
util.AddNetworkString( "luapad_runclient" )

local function upload( _, ply )
    if not luapad.CanUseSV( ply ) then
        ply:Kick( "You are not allowed to use Luapad." )
        return
    end

    local code = luapad.ReadCompressed()
    if not code then return end

    local source = "Luapad[" .. ply:SteamID() .. "]" .. ply:Nick() .. ".lua"
    hook.Run( "LuapadRanSV", ply, code )
    local success, err = luapad.Execute( code, source )
    if not success then
        net.Start( "luapad_runserver" )
        net.WriteBool( false )
        luapad.WriteCompressed( err )
        net.Send( ply )
        return
    end

    net.Start( "luapad_runserver" )
    net.WriteBool( true )
    net.Send( ply )
end

net.Receive( "luapad_runserver", upload )

local function uploadClient( _, ply )
    if not luapad.CanUseSV( ply ) then
        ply:Kick( "You are not allowed to use Luapad." )
        return
    end

    local str = luapad.ReadCompressed()
    local targeted = net.ReadBool()
    local target = net.ReadPlayer()

    net.Start( "luapad_runclient" )
    luapad.WriteCompressed( str )
    if targeted and IsValid( target ) then
        net.Send( target )
    else
        net.Broadcast()
    end
end

net.Receive( "luapad_runclient", uploadClient )
