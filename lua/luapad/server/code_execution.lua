util.AddNetworkString( "luapad_runserver" )
util.AddNetworkString( "luapad_runclient" )
util.AddNetworkString( "luapad_prints_cl" )
util.AddNetworkString( "luapad_prints_sv" )

net.Receive( "luapad_runserver", function( _, ply )
    if not luapad.CanUseSV( ply ) then
        ply:Kick( "You are not allowed to use Luapad." )
        return
    end

    local code = luapad.ReadCompressed()
    if not code then return end

    hook.Run( "LuapadRanSV", ply, code )
    local success, ret = luapad.Execute( ply, code )
    if not success then
        net.Start( "luapad_runserver" )
        net.WriteBool( false )
        luapad.WriteCompressed( ret )
        net.Send( ply )
        return
    end

    local pretty = luapad.PrettyPrint( ret )
    local compressed = util.Compress( pretty )
    if #compressed > 60000 then -- Output too large, shorten it
        local shortened = pretty:sub( 1, 60000 )
        net.Start( "luapad_runserver" )
        net.WriteBool( false )
        luapad.WriteCompressed( shortened .. "\nOutput too large, shortened." )
        net.Send( ply )
        return
    end

    net.Start( "luapad_runserver" )
    net.WriteBool( true )
    luapad.WriteCompressed( pretty )
    net.Send( ply )
end )

net.Receive( "luapad_runclient", function( _, ply )
    if not luapad.CanUseSV( ply ) then
        ply:Kick( "You are not allowed to use Luapad." )
        return
    end

    ply.LuapadCanReceivePrintsFrom = ply.LuapadCanReceivePrintsFrom or {}

    local str = luapad.ReadCompressed()
    local targeted = net.ReadBool()
    local target = net.ReadPlayer()

    net.Start( "luapad_runclient" )
    net.WritePlayer( ply )
    luapad.WriteCompressed( str )
    if targeted and IsValid( target ) then
        net.Send( target )
        ply.LuapadCanReceivePrintsFrom[target] = true
    else
        net.Broadcast()
        for _, targetedPly in ipairs( player.GetHumans() ) do
            ply.LuapadCanReceivePrintsFrom[targetedPly] = true
        end
    end
end )

net.Receive( "luapad_prints_cl", function( _, ply )
    local target = net.ReadPlayer()
    if not target.LuapadCanReceivePrintsFrom[ply] then return end

    local str = luapad.ReadCompressed()

    net.Start( "luapad_prints_cl" )
    net.WritePlayer( ply )
    luapad.WriteCompressed( str )
    net.Send( target )
end )
