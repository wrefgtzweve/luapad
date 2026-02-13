local maxLogs = 40
local logTime = 30
luapad.ActiveHudLogs = luapad.ActiveHudLogs or {}
local activeLogs = luapad.ActiveHudLogs

local outlineColor = Color( 0, 0, 0 )
local logBoxColor = Color( 30, 30, 30, 200 )
local headerColor = Color( 200, 200, 200 )

local enabledCvar = CreateClientConVar( "luapad_console_hud_enabled", 1, true, false, "Whether the console HUD is enabled." )

local function addLog( text, color )
    if not enabledCvar:GetBool() then return end

    text = tostring( text )
    if #text > 256 then
        text = string.sub( text, 1, 256 ) .. "..."
    end

    -- Replace tabs and newlines
    text = string.gsub( text, "\t", " " )
    text = string.gsub( text, "\n", " " )

    local log = {
        text = text,
        color = color,
        createTime = os.date( "[%H:%M:%S]" ),
        removeTime = SysTime() + logTime
    }

    table.insert( activeLogs, log )
    if #activeLogs > maxLogs then
        table.remove( activeLogs, 1 )
    end
end

function luapad.AddHudConsoleText( text, color )
    addLog( text, color )
end

surface.CreateFont( "LuapadConsoleFont", {
    font = "Trebuchet18",
    antialias = true,
    outline = true,
} )

local function logsDraw()
    if #activeLogs == 0 then return end

    surface.SetFont( "LuapadConsoleFont" )

    -- Header
    local header = "Luapad Console"
    local headerWidth = 120
    local startX = 5
    local startY = 20

    surface.SetDrawColor( logBoxColor )
    surface.DrawRect( startX, startY, headerWidth, 30 )
    draw.SimpleText( header, "LuapadConsoleFont", startX + headerWidth / 2, startY + 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, outlineColor )

    -- Logs
    for i, log in ipairs( activeLogs ) do
        local baseY = startY + i * 20 + 15

        surface.SetFont( "LuapadConsoleFont" )
        local textWidth = surface.GetTextSize( log.text )
        surface.SetDrawColor( logBoxColor )
        surface.DrawRect( startX, baseY, textWidth + 75, 20 )

        -- Draw timestamp
        draw.SimpleText( log.createTime, "LuapadConsoleFont", startX + 5, baseY + 10, headerColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor )

        -- Draw log text
        draw.SimpleText( log.text, "LuapadConsoleFont", startX + 70, baseY + 10, log.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor )

        if log.removeTime < SysTime() then
            table.remove( activeLogs, i )
        end
    end
end

hook.Add( "HUDPaint", "Luapad_DrawConsole", logsDraw )
