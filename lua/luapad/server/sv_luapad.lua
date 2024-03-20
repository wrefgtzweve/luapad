util.AddNetworkString( "luapad.Upload" )
util.AddNetworkString( "luapad.UploadClient" )
util.AddNetworkString( "luapad.DownloadRunClient" )

local function upload( _, ply )
    if not luapad.CanUseSV( ply ) then
        ply:Kick( "You are not allowed to use Luapad." )
        return
    end

    local str = net.ReadString()
    if not str then return end

    local source = "Luapad[" .. ply:SteamID() .. "]" .. ply:Nick() .. ".lua"
    local success, err = luapad.Execute( str, source )
    if not success then
        net.Start( "luapad.Upload" )
        net.WriteBool( false )
        net.WriteString( err )
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

    local str = net.ReadString()

    if str and luapad.CanUseSV( ply ) then
        net.Start( "luapad.DownloadRunClient" )
        net.WriteString( str )
        net.Send( player.GetAll() )
    end

    net.Start( "luapad.UploadClient" )
    net.Send( ply )
end

net.Receive( "luapad.UploadClient", uploadClient )
