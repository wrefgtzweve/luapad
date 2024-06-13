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
    self.Display = vgui.Create( "RichText", self )
    self.Display:Dock( FILL )

    self.Bottombar = vgui.Create( "DPanel", self )
    self.Bottombar:Dock( BOTTOM )

    self.Realm = vgui.Create( "DComboBox", self.Bottombar )
    self.Realm:Dock( RIGHT )
    self.Realm:AddChoice( "Client", nil, false, "!luapadClient" )
    if luapad.CanUseSV() then
        self.Realm:AddChoice( "Server", nil, false, "!luapadServer" )
        self.Realm:AddChoice( "Shared", nil, false, "!luapadShared" )
    end
    self.Realm:SetValue( "Client" )

    self.Input = vgui.Create( "DTextEntry", self.Bottombar )
    self.Input:Dock( BOTTOM )
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
        self:SetText( "" )

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
                luapad.AddConsoleText( luapad.PrettyPrint( ret ) )
            elseif not success then
                self:AddConsoleText( ret, Color( 255, 222, 102 ) )
            end

            if isClient then
                return
            end
        end

        if isServer or isShared then
            luapad.RunScriptServer( text )
        end
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
