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

local function gettraceback( err )
    local trace = err .. "\n"
    local traceback = debug.traceback()

    local expl = string.Explode( "\n", traceback )
    table.remove( expl, 1 ) -- Removes "stack traceback:"
    table.remove( expl, 1 ) -- Removes the line as we already have it

    for _, line in ipairs( expl ) do
        line = string.gsub( line, "\t", "" )
        if line == "[C]: in function 'xpcall'" then break end
        trace = trace .. line .. "\n"
    end

    return trace
end

function luapad.Execute( owner, code )
    local src = "Luapad[" .. owner:SteamID() .. "]" .. owner:Nick() .. ".lua"
    local func = CompileString( "return " .. code, src, false )
    if not isfunction( func ) then
        func = CompileString( code, src, false )
    end

    if isstring( func ) then
        return false, func
    end

    createEnv( owner, func )

    local status, ret = xpcall( func, gettraceback )
    if not status then
        return false, ret
    end

    return true, ret
end
