local canUseCL = false
local canUseSV = false

local callbacks = {}
function luapad.RequestCLAuth( callback )
    net.Start( "luapad_requestauth" )
    net.SendToServer()

    table.insert( callbacks, callback )
end

net.Receive( "luapad_requestauth", function()
    canUseCL = net.ReadBool()
    canUseSV = net.ReadBool()

    if not canUseCL then
        chat.AddText( Color( 255, 0, 0 ), "You are not allowed to use Luapad!" )
        return
    end

    for _, callback in ipairs( callbacks ) do
        callback( canUseCL )
    end

    table.Empty( callbacks )
end )

function luapad.CanUseCL()
    return canUseCL
end

function luapad.CanUseSV()
    return canUseSV
end
