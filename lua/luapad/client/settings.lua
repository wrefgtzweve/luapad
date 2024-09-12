luapad.Settings = {}

function luapad.ToggleSettingsMenu()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( 300, 300 )
    frame:Center()
    frame:SetTitle( "Luapad settings" )
    frame:MakePopup()

    local font = vgui.Create( "DNumSlider", frame )
    font:Dock( TOP )
    font:SetText( "Font size" )
    font:SetMin( 4 )
    font:SetMax( 128 )
    font:SetDecimals( 0 )
    font:SetConVar( "luapad_font_size" )

    local theme = vgui.Create( "DTextEntry", frame )
    theme:Dock( TOP )
    theme:SetConVar( "luapad_font_name" )

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
