luapad.Themes = {
    light = {
        ["Name"] = "Light",
        ["linebar"] = Color( 215, 215, 215, 255 ),
        ["linenumber"] = Color( 128, 128, 128, 255 ),
        ["currentline"] = Color( 220, 220, 220, 255 ),
        ["selection"] = Color( 170, 170, 170, 255 ), 
        ["background"] = Color( 250, 250, 250, 255 ), 
        ["text"] = Color( 0, 0, 0, 255),
        ["caret"] = Color( 72, 61, 139, 255 ),
        ["operator"] = Color( 0, 0, 128, 255 ), 
        ["string"] = Color( 120, 120, 120, 255 ),
        ["keyword"] = Color( 0, 0, 255, 255 ), 
        ["metatable"] = Color( 140, 100, 90, 255), 
        ["func"] = Color( 100, 100, 255, 255 ),
        ["comment"] = Color( 0, 120, 0, 255), 
        ["number"] = Color( 218, 165, 32, 255 ),
        ["enumeration"] = Color( 184, 134, 11, 255 )
    },

    dark = {
        ["Name"] = "Dark",
        ["Base"] = "light",
        ["linebar"] = Color( 15, 15, 15, 255 ),
        ["currentline"] = Color( 20, 20, 20, 255 ),
        ["selection"] = Color( 70, 70, 70, 255 ),
        ["background"] = Color( 50, 50, 50, 255 ),
        ["text"] = Color( 255, 255, 255, 255 ),
        ["caret"] = Color( 255, 255, 255, 255),
        ["operator"] = Color( 0, 255, 255, 255 ),
        ["string"] = Color( 206, 145, 120, 255 ),
        ["keyword"] = Color( 197, 134, 192, 255 ),
        ["metatable"] = Color( 0, 255, 125, 255),
        ["func"] = Color( 220, 220, 170, 255 ),
        ["comment"] = Color( 0, 200, 0, 255)
    }
}

function luapad.GetThemeColor(name, themeName)
    local lightTheme = luapad.Themes.light -- fallback
    local theme = luapad.Themes[themeName] or lightTheme

    local color = theme[name]

    if color then 
        return color 
    end

    local baseName = theme.Base

    while true do
        if not baseName then break end

        local baseTheme = luapad.Themes[baseName] or lightTheme
        color = baseTheme[name]
        
        if color then break end

        baseName = baseTheme.Base
    end

    return color
end