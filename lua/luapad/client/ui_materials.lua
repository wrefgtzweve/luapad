local ICON_SIZE = 64
local icons = {}
luapad.Icons = icons

local iconsToCreate = {}
local function createIcon( name, drawFunc )
    iconsToCreate[name] = drawFunc
    local rt = GetRenderTarget( name .. "RT", ICON_SIZE, ICON_SIZE, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 2, 0, IMAGE_FORMAT_BGRA8888 )

    render.PushRenderTarget( rt )
        render.Clear( 0, 0, 0, 0 )
        cam.Start2D()
        drawFunc()
        cam.End2D()
    render.PopRenderTarget()

    local iconMaterial = CreateMaterial( name, "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$translucent"] = "1"
    } )

    icons[name] = iconMaterial
end

local function renderIcons()
    for name, drawFunc in pairs( iconsToCreate ) do
        local rt = GetRenderTarget( name .. "RT", ICON_SIZE, ICON_SIZE, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 2, 0, IMAGE_FORMAT_BGRA8888 )

        render.PushRenderTarget( rt )
            render.Clear( 0, 0, 0, 0 )
            cam.Start2D()
            drawFunc()
            cam.End2D()
        render.PopRenderTarget()

        local iconMaterial = CreateMaterial( name, "UnlitGeneric", {
            ["$basetexture"] = rt:GetName(),
            ["$translucent"] = "1"
        } )

        icons[name] = iconMaterial
    end
end

-- hook.Add( "HUDPaint", "DrawIconsTest", function()
--     local count = 0
--     for _, iconMaterial in pairs( icons ) do
--         surface.SetDrawColor( 255, 255, 255, 255 )
--         surface.SetMaterial( iconMaterial )
--         surface.DrawTexturedRect( 0 + count * ICON_SIZE * 1.5,  0, ICON_SIZE, ICON_SIZE )
--         draw.SimpleTextOutlined( iconMaterial:GetName(), "DermaDefault", 0 + count * ICON_SIZE * 1.5, ICON_SIZE, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
--         count = count + 1
--     end
-- end )

local function drawRealmSquare( color )
    draw.RoundedBox( ICON_SIZE * 0.3, 0, 0, ICON_SIZE, ICON_SIZE, color )
end

createIcon( "luapadClient", function()
    drawRealmSquare( luapad.Colors.clientWiki )
end )

createIcon( "luapadServer", function()
    drawRealmSquare( luapad.Colors.serverWiki )
end )

createIcon( "luapadShared", function()
    drawRealmSquare( luapad.Colors.clientWiki )

    render.SetStencilEnable( true )

    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )

    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
    render.SetStencilReferenceValue( 9 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

    surface.SetDrawColor( 255, 0, 0, 255 )
    surface.DrawTexturedRectRotated( ICON_SIZE, 0, ICON_SIZE + ICON_SIZE * 0.41, ICON_SIZE * 2, 45 )

    render.SetStencilFailOperation( STENCILOPERATION_KEEP )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

    drawRealmSquare( luapad.Colors.serverWiki )

    render.SetStencilEnable( false )
end )

createIcon( "luapadRunClient", function()
    drawRealmSquare( luapad.Colors.clientWiki )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( Material( "icon16/user.png", "ignorez" ) )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

createIcon( "luapadRunServer", function()
    drawRealmSquare( luapad.Colors.serverWiki )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( Material( "icon16/server.png", "ignorez" ) )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

createIcon( "luapadClientAll", function()
    drawRealmSquare( luapad.Colors.clientWiki )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( Material( "icon16/transmit_blue.png", "ignorez" ) )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

createIcon( "luapadClientSpecific", function()
    drawRealmSquare( luapad.Colors.clientWiki )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( Material( "icon16/user_go.png", "ignorez" ) )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

renderIcons()
-- This hook runs for all graphic changes, including resolution changes.
hook.Add( "OnScreenSizeChanged", "Luapad_RecreateIcons", function()
    timer.Simple( 0, renderIcons )
end )
