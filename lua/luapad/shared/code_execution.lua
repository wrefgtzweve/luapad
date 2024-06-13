local SERVER = SERVER
local CLIENT = CLIENT

local runEnv = {}
local print = print
local error = error
local Msg = Msg

function runEnv.__send( str )
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
    local args = { ... }
    local str = ""
    for _, arg in ipairs( args ) do
        str = str .. tostring( arg ) .. "\t"
    end
    runEnv.__send( str )
end

function runEnv.Msg( ... )
    Msg( ... )
    local args = { ... }
    local str = ""
    for _, arg in ipairs( args ) do
        str = str .. tostring( arg )
    end
    runEnv.__send( str )
end

function runEnv.error( str )
    runEnv.__send( str )
    error( str )
end

setmetatable( runEnv, {
    __index = _G,
} )

local function setEnv( ply, func )
    runEnv.__codeOwner = ply
    runEnv.me = ply
    runEnv.this = ply:GetEyeTrace().Entity
    runEnv.there = ply:GetEyeTrace().HitPos
    runEnv.here = ply:GetPos()

    setfenv( func, runEnv )
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
