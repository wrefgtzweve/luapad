luapad.Settings = {}

local editorTheme = GetConVar( "luapad_theme" )

function luapad.ToggleSettingsMenu()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( 300, 300 )
    frame:Center()
    frame:SetTitle( "Luapad settings" )
    frame:MakePopup()

    local themeLabel = vgui.Create( "DLabel", frame )
    themeLabel:Dock( TOP )
    themeLabel:SetText( "Editor Theme" )
    
    local theme = vgui.Create( "DComboBox", frame )
    local currentTheme = luapad.Themes[editorTheme:GetString()] or luapad.Themes.light

    theme:Dock( TOP )
    theme:SetValue( currentTheme.Name )

    for k, tab in pairs(luapad.Themes) do
        theme:AddChoice( tab.Name, k )
    end

    theme.OnSelect = function( self, index, value, data )
        editorTheme:SetString( data )
    end

    local font = vgui.Create( "DNumSlider", frame )
    font:Dock( TOP )
    font:SetText( "Font size" )
    font:SetMin( 4 )
    font:SetMax( 128 )
    font:SetDecimals( 0 )
    font:SetConVar( "luapad_font_size" )

    local fontName = vgui.Create( "DTextEntry", frame )
    fontName:Dock( TOP )
    fontName:SetConVar( "luapad_font_name" )

    local weight = vgui.Create( "DNumSlider", frame )
    weight:Dock( TOP )
    weight:SetText( "Font weight" )
    weight:SetMin( 100 )
    weight:SetMax( 1000 )
    weight:SetDecimals( 0 )
    weight:SetConVar( "luapad_font_weight" )

    local realm = vgui.Create( "DCheckBoxLabel", frame )
    realm:Dock( TOP )
    realm:SetText ("Left-handed realm selector" )
    realm:SetConVar( "luapad_console_realm_left" )

    local button = vgui.Create( "DButton", frame )
    button:Dock( BOTTOM )
    button:SetText( "Reload luapad" )

    button.DoClick = function()
        if IsValid( luapad.Frame ) then
            luapad.Frame:Close()
            luapad.Toggle()
        end

        frame:Close()
    end
end
