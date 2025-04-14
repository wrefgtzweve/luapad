local maxLogs = 40
local logTime = 30
luapad.ActiveHudLogs = luapad.ActiveHudLogs or {}
local activeLogs = luapad.ActiveHudLogs

local outlineColor = Color( 0, 0, 0 )
local logBoxColor = Color( 30, 30, 30, 200 )
local headerColor = Color( 200, 200, 200 )

local function addLog( text, color )
    if #text > 256 then
        text = string.sub( text, 1, 256 ) .. "..."
    end

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

local function logsDraw()
    if #activeLogs == 0 then return end

    surface.SetFont( "Trebuchet18" )

    -- Header
    local header = "Luapad Console"
    local headerWidth = 120
    local startX = 5
    local startY = 20

    surface.SetDrawColor( logBoxColor )
    surface.DrawRect( startX, startY, headerWidth, 30 )
    draw.SimpleTextOutlined( header, "Trebuchet18", startX + headerWidth / 2, startY + 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, outlineColor )

    -- Logs
    for i, log in ipairs( activeLogs ) do
        local baseY = startY + i * 20 + 15

        surface.SetFont( "Trebuchet18" )
        local textWidth = surface.GetTextSize( log.text )
        surface.SetDrawColor( logBoxColor )
        surface.DrawRect( startX, baseY, textWidth + 75, 20 )

        -- Draw timestamp
        draw.SimpleTextOutlined( log.createTime, "Trebuchet18", startX + 5, baseY + 10, headerColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor )

        -- Draw log text
        draw.SimpleTextOutlined( log.text, "Trebuchet18", startX + 70, baseY + 10, log.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor )

        if log.removeTime < SysTime() then
            table.remove( activeLogs, i )
        end
    end
end

hook.Add( "HUDPaint", "Luapad_DrawConsole", logsDraw )
