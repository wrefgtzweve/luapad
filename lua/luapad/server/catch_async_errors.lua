hook.Add( "OnLuaError", "Luapad_CatchLuaPadErrors", function( err, _stack, stack, _name, _id )
    local hasLuapadError = false
    local codeOwner = nil
    for i = #stack, 1, -1 do
        local frame = stack[i]
        if not frame then continue end
        if not frame.File then continue end
        if not string.StartsWith( frame.File, "Luapad[" ) then continue end

        luapadIdentifier = string.match( frame.File, "Luapad%[(.-)%]" )
        if luapadIdentifier then
            local ply = player.GetBySteamID( luapadIdentifier )
            if IsValid( ply ) then
                hasLuapadError = true
                codeOwner = ply
                break
            end
        end
    end

    if hasLuapadError then
        local niceError = luapad.PrettyStack( err, stack )
        net.Start( "luapad_runserver" )
            net.WriteBool( false )
            luapad.WriteCompressed( niceError )
        net.Send( codeOwner )
    end
end )
