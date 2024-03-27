local PANEL = {}

function PANEL:Init()
    self.Display = vgui.Create( "RichText", self )
    self.Input = vgui.Create( "DTextEntry", self )

    self.Display:Dock( FILL )
    self.Input:Dock( BOTTOM )
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

        local glob = _G
        local isGlobal = true
        local parts = string.Explode( ".", text )
        for _, part in ipairs( parts ) do
            if not glob[part] then
                isGlobal = false
                break
            end
            glob = glob[part]
        end

        if isGlobal then
            self:AddConsoleText( "Global: " .. text, Color( 0, 0, 255 ) )
            self:AddConsoleText( "Type: " .. type( glob ), Color( 0, 0, 255 ) )
            self:AddConsoleText( "Value: " .. tostring( glob ), Color( 0, 0, 255 ) )
        else
            local success, err = luapad.Execute( text, "LuapadConsole" )
            if success then
                self:AddConsoleText( "Success: " .. text, Color( 0, 255, 0 ) )
            else
                self:AddConsoleText( "Error: " .. text, Color( 255, 0, 0 ) )
                self:AddConsoleText( "Error: " .. err, Color( 255, 0, 0 ) )
            end
        end


        local exists = table.KeyFromValue( self.Input.History, text )
        if exists then return end
        table.insert( self.Input.History, text )

        if #self.Input.History > 10 then
            table.remove( self.Input.History, 1 )
        end
    end

    function self.Display:PerformLayout()
        self:SetPaintBackgroundEnabled( true )
        self:SetBGColor( Color( 77, 80, 82 ) )
    end
end

function PANEL:AddConsoleText( str, color )
    if color then
        self.Display:InsertColorChange( color.r, color.g, color.b, color.a )
    end
    self.Display:AppendText( str .. "\n" )
    if color then
        self.Display:InsertColorChange( 50, 50, 50, 255 )
    end
end

function PANEL:ClearConsoleText()
    self.Display:SetText( "" )
end

vgui.Register( "LuapadConsole", PANEL, "DPanel" )
