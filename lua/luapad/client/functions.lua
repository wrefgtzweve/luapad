function luapad.CheckGlobal( func )
    if luapad._sG[func] ~= nil then
        return luapad._sG[func]
    end

    if _E and _E[func] ~= nil then
        return _E[func]
    end

    if _G[func] ~= nil then
        return _G[func]
    end

    return false
end

function luapad.getObjectDefines()
    return "local me = player.GetByID(" .. LocalPlayer():EntIndex() .. ") local this = me:GetEyeTrace().Entity "
end

function luapad.getCurrentScript()
    return luapad.PropertySheet:GetActiveTab():GetPanel():GetValue() or ""
end

function luapad.RunScriptClient()
    if not luapad.CanUseCL( LocalPlayer() ) then return end
    local success, err = luapad.Execute( LocalPlayer(), luapad.getCurrentScript() )
    if success then
        luapad.AddConsoleText( "Code ran sucessfully!", Color( 72, 205, 72, 255 ) )
    else
        luapad.AddConsoleText( "Code execution failed! Check console for more details.", Color( 205, 72, 72, 255 ) )
        MsgC( Color( 255, 222, 102 ), err .. "\n" )
    end
end

net.Receive( "luapad_runclient", function()
    local runner = net.ReadPlayer()
    local script = luapad.ReadCompressed()
    local success, err = luapad.Execute( runner, script )
    if not success then
        MsgC( Color( 255, 222, 102 ), err .. "\n" )
    end
end )

function luapad.RunScriptServer()
    if not luapad.CanUseSV() then return end

    net.Start( "luapad_runserver" )
    luapad.WriteCompressed( luapad.getObjectDefines() .. luapad.getCurrentScript() )
    net.SendToServer()
end

net.Receive( "luapad_runserver", function()
    local success = net.ReadBool()
    if success then
        luapad.AddConsoleText( "Code executed on server succesfully.", Color( 92, 205, 92, 255 ) )
        return
    end

    local err = luapad.ReadCompressed()
    luapad.AddConsoleText( "Code execution on server failed! Check console for more details.", Color( 205, 92, 92, 255 ) )
    MsgC( Color( 137, 222, 255 ), err .. "\n" )
end )

function luapad.RunScriptServerClient()
    if not luapad.CanUseSV() then return end

    net.Start( "luapad_runclient" )
    luapad.WriteCompressed( luapad.getObjectDefines() .. luapad.getCurrentScript() )
    net.WriteBool( false )
    net.SendToServer()
end

function luapad.RunScriptOnClient( ply )
    if not luapad.CanUseSV() then return end

    net.Start( "luapad_runclient" )
    luapad.WriteCompressed( luapad.getObjectDefines() .. luapad.getCurrentScript() )
    net.WriteBool( true )
    net.WritePlayer( ply )
    net.SendToServer()
end

local function getConsole()
    if not IsValid( luapad.Frame ) then return false end
    if not IsValid( luapad.Frame.Console ) then return false end
    return luapad.Frame.Console
end

function luapad.AddConsoleText( str, clr )
    local console = getConsole()
    if not console then return end

    console:AddConsoleText( str, clr )
end

function luapad.AddConsoleTable( tbl, prefix )
    local console = getConsole()
    if not console then return end

    console:AddConsoleTable( tbl, prefix )
end

net.Receive( "luapad_prints_cl", function()
    local ply = net.ReadPlayer()
    local str = luapad.ReadCompressed()
    str = "[" .. ply:SteamID() .. "]" .. ply:Nick() .. ": " .. str
    luapad.AddConsoleText( str, Color( 255, 222, 102 ) )
end )

net.Receive( "luapad_prints_sv", function()
    local str = luapad.ReadCompressed()
    luapad.AddConsoleText( str, Color( 137, 222, 255 ) )
end )