local ICON_SIZE = 64
local icons = {}

local function createIcon( name, drawFunc )
    local rt = GetRenderTarget( name .. "RT", ICON_SIZE, ICON_SIZE, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 2, 0, IMAGE_FORMAT_BGRA8888 )

    render.PushRenderTarget( rt )
        render.Clear( 0, 0, 0, 0 )
        cam.Start2D()
        drawFunc()
        cam.End2D()
    render.PopRenderTarget()

    local iconMaterial = CreateMaterial( name, "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
    } )

    icons[name] = iconMaterial
end

hook.Add( "HUDPaint", "DrawIconsTest", function()
    local count = 0
    for _, iconMaterial in pairs( icons ) do
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( iconMaterial )
        surface.DrawTexturedRect( 0 + count * ICON_SIZE * 1.5,  0, ICON_SIZE, ICON_SIZE )
        draw.SimpleTextOutlined( iconMaterial:GetName(), "DermaDefault", 0 + count * ICON_SIZE * 1.5, ICON_SIZE, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
        count = count + 1
    end
end )

local function drawRealmSquare( color )
    draw.RoundedBox( ICON_SIZE * 0.3, 0, 0, ICON_SIZE, ICON_SIZE, color )
end

createIcon( "luapadClient", function()
    drawRealmSquare( Color( 222, 169, 9 ) )
end )

createIcon( "luapadServer", function()
    drawRealmSquare( Color( 3, 169, 244 ) )
end )

createIcon( "luapadShared", function()
    drawRealmSquare( Color( 222, 169, 9 ) )

    render.SetStencilEnable( true )

    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )

    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
    render.SetStencilReferenceValue( 9 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

    surface.SetDrawColor( Color( 255, 0, 0 ) )
    surface.DrawTexturedRectRotated( ICON_SIZE, 0, ICON_SIZE + ICON_SIZE * 0.41, ICON_SIZE * 2, 45 )

    render.SetStencilFailOperation( STENCILOPERATION_KEEP )
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

    drawRealmSquare( Color( 3, 169, 244 ) )

    render.SetStencilEnable( false )
end )

local userMat = Material( "icon16/user.png" )
userMat:SetInt( "$flags", bit.bor( userMat:GetInt( "$flags" ), 32768 ) )
createIcon( "luapadRunClient", function()
    drawRealmSquare( Color( 222, 169, 9 ) )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( userMat )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

local serverMat = Material( "icon16/server.png" )
serverMat:SetInt( "$flags", bit.bor( serverMat:GetInt( "$flags" ), 32768 ) )
createIcon( "luapadRunServer", function()
    drawRealmSquare( Color( 3, 169, 244 ) )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( serverMat )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

local transmitMat = Material( "icon16/transmit_blue.png" )
transmitMat:SetInt( "$flags", bit.bor( transmitMat:GetInt( "$flags" ), 32768 ) )
createIcon( "luapadClientAll", function()
    drawRealmSquare( Color( 222, 169, 9 ) )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( transmitMat )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )

local usergoMat = Material( "icon16/user_go.png" )
usergoMat:SetInt( "$flags", bit.bor( usergoMat:GetInt( "$flags" ), 32768 ) )
createIcon( "luapadClientSpecific", function()
    drawRealmSquare( Color( 222, 169, 9 ) )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( usergoMat )
    surface.DrawTexturedRect( 8, 8, ICON_SIZE - 16, ICON_SIZE - 16 )
end )
