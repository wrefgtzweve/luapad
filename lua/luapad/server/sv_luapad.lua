util.AddNetworkString( "luapad.Upload" )
util.AddNetworkString( "luapad.UploadClient" )
util.AddNetworkString( "luapad.DownloadRunClient" )

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
        net.Start( "luapad.Upload" )
        net.WriteBool( false )
        luapad.WriteCompressed( err )
        net.Send( ply )
        return
    end

    net.Start( "luapad.Upload" )
    net.WriteBool( true )
    net.Send( ply )
end

net.Receive( "luapad.Upload", upload )

local function uploadClient( _, ply )
    if not luapad.CanUseSV( ply ) then
        ply:Kick( "You are not allowed to use Luapad." )
        return
    end

    local str = luapad.ReadCompressed()
    local targeted = net.ReadBool()
    local target = net.ReadPlayer()

    net.Start( "luapad.DownloadRunClient" )
    luapad.WriteCompressed( str )
    if targeted and IsValid( target ) then
        net.Send( target )
    else
        net.Broadcast()
    end

    net.Start( "luapad.UploadClient" )
    net.Send( ply )
end

net.Receive( "luapad.UploadClient", uploadClient )
