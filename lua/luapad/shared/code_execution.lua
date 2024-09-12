local SERVER = SERVER
local CLIENT = CLIENT

local runEnv = {}
local print = print
local error = error
local Msg = Msg

function runEnv.__send( str )
    if not IsValid( runEnv.__codeOwner ) then return end

    if CLIENT then
        if LocalPlayer() == runEnv.__codeOwner then
            luapad.AddConsoleText( str, luapad.Colors.clientConsole )
        else
            net.Start( "luapad_prints_cl" )
            net.WritePlayer( runEnv.__codeOwner )
            luapad.WriteCompressed( str )
            net.SendToServer()
        end
    end

    if SERVER then
        net.Start( "luapad_prints_sv" )
        luapad.WriteCompressed( str )
        net.Send( runEnv.__codeOwner )
    end
end

function runEnv.print( ... )
    print( ... )
    local str = ""
    for i = 1, select( "#", ... ) do
        local arg = select( i, ... )
        str = str .. tostring( arg ) .. "\t"
    end

    str = str:sub( 1, -2 )

    runEnv.__send( str )
end

function runEnv.Msg( ... )
    Msg( ... )
    local str = ""
    for i = 1, select( "#", ... ) do
        local arg = select( i, ... )
        str = str .. tostring( arg )
    end
    runEnv.__send( str )
end

function runEnv.MsgN( ... )
    MsgN( ... )
    local str = ""
    for i = 1, select( "#", ... ) do
        local arg = select( i, ... )
        str = str .. tostring( arg )
    end
    runEnv.__send( str )
end

function runEnv.MsgC( ... )
    MsgC( ... )
    local str = ""
    for i = 1, select( "#", ... ) do
        local arg = select( i, ... )
        if IsColor( arg ) then
            str = str .. string.format( "Color( %i, %i, %i, %i ) ", arg.r, arg.g, arg.b, arg.a )
        else
            str = str .. tostring( arg )
        end
    end
    runEnv.__send( str )
end

function runEnv.error( str )
    runEnv.__send( str )
    error( str )
end

function runEnv.PrintTable( tbl )
    PrintTable( tbl )
    runEnv.__send( luapad.PrettyPrint( tbl ) )
end

if SERVER then
    function runEnv.ServerLog( str )
        ServerLog( str )
        runEnv.__send( str )
    end
end

setmetatable( runEnv, {
    __index = _G,
} )

local function setEnv( ply, func )
    runEnv.__codeOwner = ply

    local customEnv = setmetatable( {
        me = ply,
        this = ply:GetEyeTrace().Entity,
        there = ply:GetEyeTrace().HitPos,
        here = ply:GetPos(),
        randombot = player.GetBots()[1]
    }, {
        __index = runEnv,
        __newindex = _G
    } )

    hook.Run( "LuapadCustomizeEnv", ply, customEnv )

    setfenv( func, customEnv )

    return func
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

    func = setEnv( owner, func )

    local status, ret = xpcall( func, gettraceback )
    if not status then
        return false, ret
    end

    return true, ret
end
