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
    local source = "Luapad[" .. LocalPlayer():SteamID() .. "]" .. LocalPlayer():Nick() .. ".lua"
    local code = luapad.getObjectDefines() .. luapad.getCurrentScript()
    local success, err = luapad.Execute( code, source )
    if success then
        luapad.SetStatus( "Code ran sucessfully!", Color( 72, 205, 72, 255 ) )
    else
        luapad.SetStatus( "Code execution failed! Check console for more details.", Color( 205, 72, 72, 255 ) )
        MsgC( Color( 255, 222, 102 ), err .. "\n" )
    end
end

local function runScriptClientFromServer()
    local script = net.ReadString()
    local success, err = luapad.Execute( script, "Luapad[SERVER].lua" )
    if not success then
        MsgC( Color( 255, 222, 102 ), err .. "\n" )
    end
end

net.Receive( "luapad.DownloadRunClient", runScriptClientFromServer )

function luapad.RunScriptServer()
    if not luapad.CanUseSV() then return end

    net.Start( "luapad.Upload" )
    net.WriteString( luapad.getObjectDefines() .. luapad.getCurrentScript() )
    net.SendToServer()
end

net.Receive( "luapad.Upload", function()
    local success = net.ReadBool()
    if success then
        luapad.SetStatus( "Code executed on server succesfully.", Color( 92, 205, 92, 255 ) )
        return
    end

    local err = net.ReadString()
    luapad.SetStatus( "Code execution on server failed! Check console for more details.", Color( 205, 92, 92, 255 ) )
    MsgC( Color( 145, 219, 232 ), err .. "\n" )
end )

function luapad.RunScriptServerClient()
    if not luapad.CanUseSV() then return end

    net.Start( "luapad.UploadClient" )
    net.WriteString( luapad.getObjectDefines() .. luapad.getCurrentScript() )
    net.WriteBool( false )
    net.SendToServer()
end

function luapad.RunScriptOnClient( ply )
    if not luapad.CanUseSV() then return end

    net.Start( "luapad.UploadClient" )
    net.WriteString( luapad.getObjectDefines() .. luapad.getCurrentScript() )
    net.WriteBool( true )
    net.WritePlayer( ply )
    net.SendToServer()
end

net.Receive( "luapad.UploadClient", function()
    luapad.SetStatus( "Scrip ran.", Color( 92, 205, 92, 255 ) )
end )
