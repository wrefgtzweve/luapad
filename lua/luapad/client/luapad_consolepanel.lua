local realmSideCvar = CreateClientConVar( "luapad_console_realm_left", 1, true, false, "Whether the realm selector for the console appears on the left." )

local PANEL = {}

if system.IsWindows() then
    surface.CreateFont( "luapadConsoleText", {
        font = "Lucida Console",
        size = 10,
        weight = 500,
        antialias = false,
    } )
else
    surface.CreateFont( "luapadConsoleText", {
        font = "Verdana",
        size = 14,
        weight = 500,
        antialias = false,
    } )
end

function PANEL:Init()
    self:SetPaintBackground( false )

    self.Display = vgui.Create( "RichText", self )
    self.Display:Dock( FILL )

    self.Bottombar = vgui.Create( "DPanel", self )
    self.Bottombar:DockMargin( 0, 5, 0, 0 )
    self.Bottombar:Dock( BOTTOM )
    self.Bottombar:SetPaintBackground( false )

    self.Realm = vgui.Create( "DComboBox", self.Bottombar )
    self.Realm:SetWide( 100 )

    if realmSideCvar:GetBool() then
        self.Realm:DockMargin( 0, 0, 5, 0 )
        self.Realm:Dock( LEFT )
    else
        self.Realm:DockMargin( 5, 0, 0, 0 )
        self.Realm:Dock( RIGHT )
    end

    self.Realm.Icon = self.Realm:Add( "DImage" )
    self.Realm.Icon:SetImage( "!luapadClient" )
    self.Realm.Icon:SetSize( 16, 16 )
    self.Realm.Icon:SetPos( 4, 4 )

    self.Realm._SetText = self.Realm.SetText
    function self.Realm:SetText( text )
        self:_SetText( "      " .. text )
        self.Icon:SetImage( "!luapad" .. text )
    end

    self.Realm._GetValue = self.Realm.GetValue
    function self.Realm:GetValue()
        return self:_GetValue():sub( 7 )
    end

    self.Realm:AddChoice( "Client", nil, false, "!luapadClient" )
    if luapad.CanUseSV() then
        self.Realm:AddChoice( "Server", nil, false, "!luapadServer" )
        self.Realm:AddChoice( "Shared", nil, false, "!luapadShared" )
    end
    self.Realm:SetValue( "Client" )

    self.Input = vgui.Create( "DTextEntry", self.Bottombar )
    self.Input:Dock( FILL )
    self.Input:SetEnterAllowed( false )
    self.Input:SetHistoryEnabled( true )
    self.Input.History = {}

    self.Input.OnKeyCode = function( _, key )
        -- Hack to make the text entry not lose focus when pressing enter
        if key == KEY_ENTER then
            self.Input:OnEnter()
        end
    end

    self.Input.OnEnter = function()
        local text = self.Input:GetText()
        if text == "" then return end

        self.Input:SetText( "" )

        self:AddConsoleText( "> " .. text, Color( 23, 136, 0 ) )
        if text == "clear" or text == "cls" then
            self:ClearConsoleText()
            return
        end

        local exists = table.KeyFromValue( self.Input.History, text )
        if not exists then
            table.insert( self.Input.History, text )

            if #self.Input.History > 10 then
                table.remove( self.Input.History, 1 )
            end
        end

        local isClient = self.Realm:GetValue() == "Client"
        local isServer = self.Realm:GetValue() == "Server"
        local isShared = self.Realm:GetValue() == "Shared"

        if isClient or isShared then
            local success, ret = luapad.Execute( LocalPlayer(), text )
            if success and ret ~= nil then
                luapad.AddConsoleText( luapad.PrettyPrint( ret ), luapad.Colors.clientConsole )
            elseif not success then
                self:AddConsoleText( ret, luapad.Colors.clientConsole )
            end

            if isClient then
                return
            end
        end

        if isServer or isShared then
            luapad.RunScriptServer( text )
        end
    end

    self.EnlargeButton = vgui.Create( "DImageButton", self.Input )
    self.EnlargeButton:SetImage( "icon16/application_xp_terminal.png" )
    self.EnlargeButton:SetTooltip( "Enlarge Console" )
    self.EnlargeButton:SetSize( 16, 16 )

    function self.EnlargeButton:DoClick()
        if luapad.ConsoleMode then
            luapad.Frame.Console:Dock( NODOCK )

            luapad.Frame.Divider:SetBottom( luapad.Frame.Console )
            luapad.Frame.Divider:Show()

            luapad.ConsoleMode = nil
        else
            luapad.Frame.Divider:Hide()

            luapad.Frame.Console:SetParent( luapad.Frame )
            luapad.Frame.Console:Dock( FILL )

            luapad.ConsoleMode = true
        end
    end

    local performLayout = self.EnlargeButton.PerformLayout

    self.EnlargeButton.PerformLayout = function(pnl, w, h)
        performLayout(pnl, w, h)

        self.EnlargeButton:SetPos(self.Input:GetWide() - 21, 4)
    end

    function self.Display:PerformLayout()
        self:SetPaintBackgroundEnabled( true )
        self:SetBGColor( Color( 77, 80, 82 ) )
        self:SetFontInternal( "luapadConsoleText" )
    end
end

function PANEL:AddConsoleText( str, color )
    color = color or Color( 255, 255, 255 )
    self.Display:InsertColorChange( color.r, color.g, color.b, color.a )
    self.Display:AppendText( str .. "\n" )
    if color then
        self.Display:InsertColorChange( 50, 50, 50, 255 )
    end
end

function PANEL:ClearConsoleText()
    self.Display:SetText( "" )
end

vgui.Register( "LuapadConsole", PANEL, "DPanel" )
