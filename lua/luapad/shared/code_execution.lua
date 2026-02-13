luapad.createdHooks = luapad.createdHooks or {}
if CLIENT then
    luapad.createdPanels = luapad.createdPanels or {}
end

local function addHook( ply, hookname, hookID )
    luapad.createdHooks[ply] = luapad.createdHooks[ply] or {}
    luapad.createdHooks[ply][hookname] = luapad.createdHooks[ply][hookname] or {}
    luapad.createdHooks[ply][hookname][hookID] = true
end

local function removeHook( ply, hookname, hookID )
    if not luapad.createdHooks[ply] then return end
    if not luapad.createdHooks[ply][hookname] then return end
    if luapad.createdHooks[ply][hookname][hookID] then
        luapad.createdHooks[ply][hookname][hookID] = nil
    end
end

local function addPanel( panel )
    table.insert( luapad.createdPanels, panel )
end

local function cleanupPanels()
    local panels = luapad.createdPanels
    local toremove = {}
    if #panels == 0 then return end
    for k, panel in ipairs( panels ) do
        if not IsValid( panel ) then
            table.insert( toremove, k )
        end
    end
    for I = #toremove, 1, -1 do
        table.remove( panels, toremove[I] )
    end
end

local function recursiveCleanupTables( t )
    for k, v in pairs( t ) do
        if type( v ) == "table" then
            recursiveCleanupTables( v )
            if next( v ) == nil then
                t[k] = nil
            end
        end
    end
end

local function setEnvFunctions( ply, env )
    env.__send = function( str, color, newline )
        newline = newline == nil and true or newline
        if CLIENT then
            if LocalPlayer() == ply then
                luapad.AddConsoleText( str, color or luapad.Colors.clientConsole, newline )
            else
                net.Start( "luapad_prints_cl" )
                    net.WritePlayer( ply )
                    luapad.WriteCompressed( str )
                    if color then
                        net.WriteBool( true )
                        net.WriteColor( color )
                    else
                        net.WriteBool( false )
                    end
                    net.WriteBool( newline )
                net.SendToServer()
            end
        else
            net.Start( "luapad_prints_sv" )
                luapad.WriteCompressed( str )
                if color then
                    net.WriteBool( true )
                    net.WriteColor( color )
                else
                    net.WriteBool( false )
                end
                net.WriteBool( newline )
            net.Send( ply )
        end
    end

    env.print = function( ... )
        print( ... )

        local str = ""
        for i = 1, select( "#", ... ) do
            local arg = select( i, ... )
            str = str .. tostring( arg ) .. "\t"
        end

        str = str:sub( 1, -2 )

        env.__send( str )
    end

    env.lpprint = function( ... )
        local str = ""
        for i = 1, select( "#", ... ) do
            local arg = select( i, ... )
            str = str .. tostring( arg ) .. "\t"
        end

        str = str:sub( 1, -2 )

        env.__send( str )
    end

    env.Msg = function( ... )
        Msg( ... )

        local str = ""
        for i = 1, select( "#", ... ) do
            local arg = select( i, ... )
            str = str .. tostring( arg )
        end

        env.__send( str )
    end

    env.MsgN = function( ... )
        MsgN( ... )

        local str = ""
        for i = 1, select( "#", ... ) do
            local arg = select( i, ... )
            str = str .. tostring( arg )
        end

        env.__send( str )
    end

    env.MsgC = function( ... )
        MsgC( ... )

        local lastColor
        for i = 1, select( "#", ... ) do
            local arg = select( i, ... )
            if IsColor( arg ) then
                lastColor = arg
            else
                env.__send( tostring( arg ), lastColor, false )
            end
        end
    end

    env.error = function( str )
        env.__send( str )
        error( str )
    end

    env.PrintTable = function( tbl )
        PrintTable( tbl )
        env.__send( luapad.PrettyPrint( tbl ) )
    end

    if SERVER then
        env.ServerLog = function( str )
            ServerLog( str )
            env.__send( str )
        end
    end

    env.randombot = function()
        local bots = player.GetBots()
        if #bots == 0 then
            env.error( "No bots found." )
        end

        return table.Random( bots )
    end

    env.hook = setmetatable( {}, { __index = _G.hook } )

    env.hook.Add = function( hookname, hookID, func )
        addHook( CLIENT and LocalPlayer():SteamID() or ply:SteamID(), hookname, hookID )
        _G.hook.Add( hookname, hookID, func )
    end

    env.hook.Remove = function( hookname, hookID )
        removeHook( CLIENT and LocalPlayer():SteamID() or ply:SteamID(), hookname, hookID )
        _G.hook.Remove( hookname, hookID )
    end

    if CLIENT and ply == LocalPlayer() then
        env.vgui = setmetatable( {}, { __index = _G.vgui } )

        env.vgui.Create = function( classname, parent, name )
            local panel = vgui.Create( classname, parent, name )
            addPanel( panel )
            return panel
        end
    end

end

local function setEnvVariables( ply, env )
    local tr = ply:GetEyeTrace()

    env.me = ply
    env.tr = tr
    env.this = tr.Entity
    env.there = tr.HitPos
    env.here = ply:GetPos()
    env.bot = player.GetBots()[1]
    env.GM = GM or GAMEMODE
end

local function createEnv( ply, func )
    local env = {}

    setEnvFunctions( ply, env )
    setEnvVariables( ply, env )

    hook.Run( "LuapadCustomizeEnv", ply, env )

    setmetatable( env, {
        __index = _G,
        __newindex = _G
    } )

    setfenv( func, env )
end

function luapad.ClearAllHooks( tply )
    local padhooks = luapad.createdHooks
    local ply = tply:SteamID()
    if padhooks[ply] then
        for hookname, IDs in pairs( padhooks[ply] ) do
            for ID, _ in pairs( IDs ) do
                hook.Remove( hookname, ID )
            end
        end
        padhooks[ply] = {}
    end
    recursiveCleanupTables( padhooks )
end

function luapad.ClearPanels()
    local panels = luapad.createdPanels
    if next( panels ) == nil then return end
    for _, v in ipairs( panels ) do
        if IsValid( v ) then
            v:Remove()
        end
    end
    cleanupPanels()
end

function luapad.GetIdentifier( owner )
    return "Luapad[" .. owner:SteamID() .. "]" .. owner:Nick()
end

function luapad.Execute( owner, code )
    local src = luapad.GetIdentifier( owner ) .. ".lua"
    local func = CompileString( "return " .. code, src, false )
    if not isfunction( func ) then
        func = CompileString( code, src, false )
    end

    if isstring( func ) then
        return false, func
    end

    createEnv( owner, func )

    local status, ret = xpcall( func, luapad.PrettyStack )
    recursiveCleanupTables( luapad.createdHooks )
    if CLIENT and owner == LocalPlayer() then
        cleanupPanels()
    end
    if not status then
        return false, ret
    end

    return true, ret
end
