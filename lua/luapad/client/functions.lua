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

function luapad.getCurrentScript()
    return luapad.PropertySheet:GetActiveTab():GetPanel():GetValue() or ""
end

function luapad.RunScriptClient()
    if not luapad.CanUseCL( LocalPlayer() ) then return end
    local success, ret = luapad.Execute( LocalPlayer(), luapad.getCurrentScript() )
    if success then
        luapad.AddConsoleText( "Code ran successfully!", Color( 72, 205, 72, 255 ) )
    end

    if ret ~= nil then
        luapad.AddConsoleText( luapad.PrettyPrint( ret ), luapad.Colors.clientConsole )
    end
end

net.Receive( "luapad_runclient", function()
    local runner = net.ReadPlayer()
    if not IsValid( runner ) then return end

    local script = luapad.ReadCompressed()
    local success, err = luapad.Execute( runner, script )
    if not success then
        net.Start( "luapad_prints_cl" )
            net.WritePlayer( runner )
            luapad.WriteCompressed( err )
        net.SendToServer()
    end
end )

function luapad.RunScriptServer( code )
    if not luapad.CanUseSV() then return end

    net.Start( "luapad_runserver" )
    luapad.WriteCompressed( code )
    net.SendToServer()
end

net.Receive( "luapad_runserver", function()
    local success = net.ReadBool()
    if success then
        luapad.AddConsoleText( "Code executed on server successfully.", Color( 92, 205, 92, 255 ) )
    end

    local ret = luapad.ReadCompressed()
    if #ret > 0 then
        luapad.AddConsoleText( ret, luapad.Colors.serverConsole )
    end
end )

function luapad.RunScriptServerClient()
    if not luapad.CanUseSV() then return end

    net.Start( "luapad_runclient" )
    luapad.WriteCompressed( luapad.getCurrentScript() )
    net.WriteBool( false )
    net.SendToServer()
end

function luapad.RunScriptOnClient( ply )
    if not luapad.CanUseSV() then return end

    net.Start( "luapad_runclient" )
    luapad.WriteCompressed( luapad.getCurrentScript() )
    net.WriteBool( true )
    net.WritePlayer( ply )
    net.SendToServer()
end

local function getConsole()
    if not IsValid( luapad.Frame ) then return false end
    if not IsValid( luapad.Frame.Console ) then return false end
    return luapad.Frame.Console
end

function luapad.AddConsoleText( str, clr, newline )
    local console = getConsole()
    if not console then return end

    luapad.AddHudConsoleText( str, clr, newline )
    console:AddConsoleText( str, clr, newline )
end

net.Receive( "luapad_prints_cl", function()
    local ply = net.ReadPlayer()
    local str = luapad.ReadCompressed()

    local color = luapad.Colors.clientConsole
    local hasColor = net.ReadBool()
    if hasColor then
        color = net.ReadColor()
    end
    local newline = net.ReadBool()

    str = "[" .. ply:SteamID() .. "]" .. ply:Nick() .. ": " .. str
    luapad.AddConsoleText( str, color, newline )
end )

net.Receive( "luapad_prints_sv", function()
    local str = luapad.ReadCompressed()

    local color = luapad.Colors.serverConsole
    local hasColor = net.ReadBool()
    if hasColor then
        color = net.ReadColor()
    end
    local newline = net.ReadBool()

    luapad.AddConsoleText( str, color, newline )
end )
