-- Autorefresh support
if IsValid( luapad.Frame ) then
    luapad.Frame:Remove()
end

function luapad.CheckGlobal( func )
    if luapad._sG[func] ~= nil then
        return luapad._sG[func]
    end

    if _E and _E[func] ~= nil then
        return _E[func]
    end

    if _G[func] ~= nil then
        return _G[func]
    end

    return false
end

function luapad.SaveTabs()
    if not luapad.Frame then return end

    local store = {
        activetab = luapad.PropertySheet:GetActiveTab().name,
        tabs = {}
    }

    for _, v in pairs( luapad.PropertySheet.Items ) do
        local panel = v["Panel"]
        local name = panel.name
        local path = panel.path
        local content = panel:GetItems()[1]:GetValue()
        if content == "" then continue end
        table.insert( store.tabs, { name = name, path = path, content = content } )
    end

    file.Write( "luapad/_tabs.txt", "luapad " .. util.Compress( util.TableToJSON( store ) ) )
end
hook.Add( "ShutDown", "luapad.SaveTabs", luapad.SaveTabs )

function luapad.LoadSavedTabs()
    if not file.Exists( "luapad/_tabs.txt", "DATA" ) then return end
    local store = util.JSONToTable( util.Decompress( file.Read( "luapad/_tabs.txt", "DATA" ):sub( 8 ) ) )

    if store then
        for _, v in pairs( store.tabs ) do
            luapad.AddTab( v.name, v.content, v.path )
        end

        for _, v in pairs( luapad.PropertySheet.Items ) do
            if v["Name"] == store.activetab then
                luapad.PropertySheet:SetActiveTab( v["Tab"] )
            end
        end
    end
end

function luapad.Toggle()
    if not luapad.CanUseCL( LocalPlayer() ) then
        print( "You don't have permission to use Luapad." )
        return
    end

    if not IsValid( luapad.Frame ) then
        -- Build it, if it doesn't exist
        luapad.Frame = vgui.Create( "DFrame" )
        luapad.Frame:SetSize( ScrW() * 2 / 3, ScrH() * 2 / 3 )
        luapad.Frame:SetPos( ScrW() * 1 / 6, ScrH() * 1 / 6 )
        luapad.Frame:SetTitle( "Luapad" )
        luapad.Frame:ShowCloseButton( true )
        luapad.Frame:MakePopup()

        luapad.Frame.btnClose.DoClick = function()
            luapad.Toggle()
            luapad.SaveTabs()
        end

        luapad.Toolbar = vgui.Create( "DPanelList", luapad.Frame )
        luapad.Toolbar:SetPos( 3, 26 )
        luapad.Toolbar:SetSize( luapad.Frame:GetWide() - 6, 22 )
        luapad.Toolbar:SetSpacing( 5 )
        luapad.Toolbar:EnableHorizontal( true )
        luapad.Toolbar:EnableVerticalScrollbar( false )

        luapad.Toolbar.PerformLayout = function( self )
            local Wide = self:GetWide()
            local YPos = 3

            if not self.Rebuild then
                debug.Trace()
            end

            self:Rebuild()

            if self.VBar and not m_bSizeToContents then
                self.VBar:SetPos( self:GetWide() - 16, 0 )
                self.VBar:SetSize( 16, self:GetTall() )
                self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
                YPos = self.VBar:GetOffset() + 3

                if self.VBar.Enabled then
                    Wide = Wide - 16
                end
            end

            self.pnlCanvas:SetPos( 3, YPos )
            self.pnlCanvas:SetWide( Wide )
            self:Rebuild()

            if self:GetAutoSize() then
                self:SetTall( self.pnlCanvas:GetTall() )
                self.pnlCanvas:SetPos( 3, 3 )
            end
        end

        local _, y = luapad.Toolbar:GetPos()
        luapad.PropertySheet = vgui.Create( "DPropertySheet", luapad.Frame )
        luapad.PropertySheet:SetPos( 3, y + luapad.Toolbar:GetTall() + 5 )
        luapad.PropertySheet:SetSize( luapad.Frame:GetWide() - 6, luapad.Frame:GetTall() - 82 )
        luapad.PropertySheet:SetPadding( 1 )
        luapad.PropertySheet:SetFadeTime( 0 )
        luapad.PropertySheet.____SetActiveTab = luapad.PropertySheet.SetActiveTab

        luapad.PropertySheet.SetActiveTab = function( ... )
            luapad.PropertySheet.____SetActiveTab( ... )

            if luapad.PropertySheet:GetActiveTab() then
                local panel = luapad.PropertySheet:GetActiveTab():GetPanel()
                luapad.Frame:SetTitle( "Luapad - " .. panel.path .. panel.name )
            end
        end

        luapad.PropertySheet:InvalidateLayout()

        luapad.NewTab()

        luapad.Statusbar = vgui.Create( "DPanelList", luapad.Frame )
        luapad.Statusbar:SetPos( 3, luapad.Frame:GetTall() - 25 )
        luapad.Statusbar:SetSize( luapad.Frame:GetWide() - 6, 22 )
        luapad.Statusbar:SetSpacing( 5 )
        luapad.Statusbar:EnableHorizontal( true )
        luapad.Statusbar:EnableVerticalScrollbar( false )
        luapad.Statusbar.PerformLayout = luapad.Toolbar.PerformLayout
        luapad.Statusbar:InvalidateLayout()
        luapad.AddToolbarItem( "New (CTRL + N)", "icon16/page_white_add.png", luapad.NewTab )
        luapad.AddToolbarItem( "Open (CTRL + O)", "icon16/folder_page_white.png", luapad.OpenScript )
        luapad.AddToolbarItem( "Save (CTRL + S)", "icon16/disk.png", luapad.SaveScript )
        luapad.AddToolbarItem( "Save As (CTRL + ALT + S)", "icon16/disk_multiple.png", luapad.SaveAsScript )

        luapad.AddToolbarSpacer()

        local isSVUser = luapad.CanUseSV( LocalPlayer() )

        luapad.AddToolbarItem( "Run Clientside", "icon16/script_code.png", luapad.RunScriptClient )
        if isSVUser then
            luapad.AddToolbarItem( "Run Serverside", "icon16/script_code_red.png", luapad.RunScriptServer )

            luapad.AddToolbarSpacer()

            luapad.AddToolbarItem( "Run Shared", "icon16/script_lightning.png", function()
                luapad.RunScriptClient()
                luapad.RunScriptServer()
            end )
            luapad.AddToolbarItem( "Run on all clients", "icon16/script_palette.png", luapad.RunScriptServerClient )
            luapad.AddToolbarItem( "Run on specfic client", "icon16/script_go.png", function()
                local menu = DermaMenu()
                for _, v in pairs( player.GetAll() ) do
                    if v == LocalPlayer() then continue end
                    menu:AddOption( v:Nick(), function()
                        luapad.RunScriptOnClient( v )
                    end )
                end
                menu:Open()
            end )
        end

        luapad.LoadSavedTabs()
    else
        luapad.Frame:SetVisible( not luapad.Frame:IsVisible() )
    end
end

function luapad.AddToolbarItem( tooltip, mat, func )
    local button = vgui.Create( "DImageButton" )
    button:SetImage( mat )
    button:SetTooltip( tooltip )
    button:SetSize( 16, 16 )
    button.DoClick = func
    luapad.Toolbar:AddItem( button )
end

function luapad.AddToolbarSpacer()
    local lab = vgui.Create( "DLabel" )
    lab:SetText( " | " )
    lab:SizeToContents()
    luapad.Toolbar:AddItem( lab )
end

function luapad.SetStatus( str, clr )
    timer.Remove( "luapad.Statusbar.Fade" )
    luapad.Statusbar:Clear()
    local msg = vgui.Create( "DLabel", luapad.Statusbar )
    msg:SetText( str )
    msg:SetTextColor( clr )
    msg:SizeToContents()

    timer.Create( "luapad.Statusbar.Fade", 0.01, 0, function()
        local statusMsg = luapad.Statusbar:GetItems()[1]
        local col = statusMsg:GetTextColor()
        col.a = math.Clamp( col.a - 1, 0, 255 )
        statusMsg:SetTextColor( Color( col.r, col.g, col.b, col.a ) )

        if col.a == 0 then
            timer.Remove( "luapad.Statusbar.Fade" )
        end
    end )

    luapad.Statusbar:AddItem( msg )
    surface.PlaySound( "common/wpn_select.wav" )
end

function luapad.AddTab( name, content, path )
    content = content or ""
    path = path or ""
    content = string.gsub( content, "\t", "	   " )

    local form = vgui.Create( "DPanelList", luapad.PropertySheet )
    form:SetSize( luapad.PropertySheet:GetWide(), luapad.PropertySheet:GetTall() - 23 )
    form.name = name
    form.path = path

    local textentry = vgui.Create( "LuapadEditor", form )
    textentry:SetSize( form:GetWide(), form:GetTall() )
    textentry:SetText( content or "" )
    textentry:RequestFocus()

    form:AddItem( textentry )
    luapad.PropertySheet:AddSheet( name, form, "icon16/page_white.png", false, false )
    luapad.PropertySheet:SetActiveTab( luapad.PropertySheet.Items[table.Count( luapad.PropertySheet.Items )]["Tab"] )
    luapad.PropertySheet:InvalidateLayout()
end

local newTabNum = 1
function luapad.NewTab( content )
    if not isstring( content ) then
        content = ""
    end

    luapad.AddTab( "untitled" .. newTabNum .. ".txt", content, "data/luapad/" )

    newTabNum = newTabNum + 1
end

function luapad.CloseActiveTab()
    if table.Count( luapad.PropertySheet.Items ) == 1 then return end
    local tabs = {}

    for _, v in pairs( luapad.PropertySheet.Items ) do
        if v["Tab"] ~= luapad.PropertySheet:GetActiveTab() then
            table.insert( tabs, v["Panel"] )
            v["Tab"]:Remove()
            v["Panel"]:Remove()
        end
    end

    luapad.PropertySheet:Remove()
    local _, y = luapad.Toolbar:GetPos()
    luapad.PropertySheet = vgui.Create( "DPropertySheet", luapad.Frame )
    luapad.PropertySheet:SetPos( 3, y + luapad.Toolbar:GetTall() + 5 )
    luapad.PropertySheet:SetSize( luapad.Frame:GetWide() - 6, luapad.Frame:GetTall() - 82 )
    luapad.PropertySheet:SetPadding( 1 )
    luapad.PropertySheet:SetFadeTime( 0 )
    luapad.PropertySheet.____SetActiveTab = luapad.PropertySheet.SetActiveTab

    luapad.PropertySheet.SetActiveTab = function( ... )
        luapad.PropertySheet.____SetActiveTab( ... )

        if luapad.PropertySheet:GetActiveTab() then
            local panel = luapad.PropertySheet:GetActiveTab():GetPanel()
            luapad.Frame:SetTitle( "Luapad - " .. panel.path .. panel.name )
        end
    end

    luapad.PropertySheet:InvalidateLayout()

    for _, v in pairs( tabs ) do
        luapad.AddTab( v.name, v:GetItems()[1]:GetValue(), v.path )
    end

    luapad.SaveTabs()
end

function luapad.OpenScript()
    if luapad.OpenTree then
        luapad.OpenTree:Remove()
    end

    local x, y = luapad.PropertySheet:GetPos()
    luapad.OpenTree = vgui.Create( "DTree", luapad.Frame )
    luapad.OpenTree:SetPadding( 5 )
    luapad.OpenTree:SetPos( x + luapad.PropertySheet:GetWide() - luapad.PropertySheet:GetWide() / 4, y + 22 )
    luapad.OpenTree:SetSize( luapad.PropertySheet:GetWide() / 4, luapad.PropertySheet:GetTall() - 23 )

    function luapad.OpenTree:DoClick( node )
        local fileName = node:GetFileName()
        if not fileName then return end
        luapad.AddTab( node.Label:GetValue(), file.Read( fileName, "GAME" ), node.Path )
    end

    luapad.OpenCloseButton = vgui.Create( "DButton", luapad.OpenTree )
    luapad.OpenCloseButton:SetSize( 16, 16 )
    luapad.OpenCloseButton:SetPos( luapad.OpenTree:GetWide() - 20, 4 )
    luapad.OpenCloseButton:SetText( "X" )
    luapad.OpenCloseButton:SetTooltip( "Close" )

    luapad.OpenCloseButton.DoClick = function()
        luapad.OpenTree:Remove()
    end

    local node = luapad.OpenTree:AddNode( "garrysmod\\data" )
    node.RootFolder = "data"
    node:MakeFolder( "data", "GAME", true )
    node.Icon:SetImage( "icon16/computer.png" )

    local node2 = luapad.OpenTree:AddNode( "luapad" )
    node2.RootFolder = "data/luapad";
    node2:MakeFolder( "data/luapad", "GAME", true );
    node2.Icon:SetImage( "icon16/folder_page_white.png" );
end

function luapad.SaveScript()
    local contents = luapad.PropertySheet:GetActiveTab():GetPanel():GetItems()[1]:GetValue() or ""
    contents = string.gsub( contents, "   	", "\t" )
    local path = string.gsub( luapad.PropertySheet:GetActiveTab():GetPanel().path, "data/luapad", "", 1 )
    Msg( "data/luapad" .. path .. luapad.PropertySheet:GetActiveTab():GetPanel().name )

    if not file.Exists( path .. luapad.PropertySheet:GetActiveTab():GetPanel().name, "DATA" ) then
        luapad.SaveAsScript()
    else
        file.Write( path .. luapad.PropertySheet:GetActiveTab():GetPanel().name, contents )

        if file.Exists( path .. luapad.PropertySheet:GetActiveTab():GetPanel().name, "DATA" ) then
            luapad.SetStatus( "File succesfully saved!", Color( 72, 205, 72, 255 ) )
        else
            luapad.SetStatus( "Save failed! (check your filename for illegal characters)", Color( 205, 72, 72, 255 ) )
        end
    end
end

function luapad.SaveAsScript()
    Derma_StringRequest( "Luapad", "You are about to save a file, please enter the desired filename.", luapad.PropertySheet:GetActiveTab():GetPanel().path .. luapad.PropertySheet:GetActiveTab():GetPanel().name, function( filename )
        local contents = luapad.PropertySheet:GetActiveTab():GetPanel():GetItems()[1]:GetValue() or ""

        --I really do hate how '.' is a wildcard...
        if string.find( filename, "../" ) == 1 then
            filename = string.gsub( filename, "../", "", 1 )
        end

        local dirs = string.Explode( "/", string.gsub( filename, "data/", "", 1 ) )
        local d = ""

        for k, v in ipairs( dirs ) do
            if k == #dirs then break end --don't make a directory for the filename
            d = d .. v .. "/"

            if not file.IsDir( d, "DATA" ) then
                file.CreateDir( d )
            end
        end

        file.Write( string.gsub( filename, "data/", "", 1 ), contents )

        if file.Exists( string.gsub( filename, "data/", "", 1 ), "DATA" ) then
            luapad.SetStatus( "File succesfully saved!", Color( 72, 205, 72, 255 ) )
            luapad.PropertySheet:GetActiveTab():GetPanel().name = string.Explode( "/", filename )[#string.Explode( "/", filename )]
            luapad.PropertySheet:GetActiveTab():GetPanel().path = string.gsub( filename, luapad.PropertySheet:GetActiveTab():GetPanel().name, "", 1 )
            luapad.PropertySheet:GetActiveTab():SetText( string.Explode( "/", filename )[#string.Explode( "/", filename )] )
            luapad.PropertySheet:SetActiveTab( luapad.PropertySheet:GetActiveTab() )
        else
            luapad.SetStatus( "Save failed! (check your filename for illegal characters)", Color( 205, 72, 72, 255 ) )
        end
    end, nil, "Save", "Cancel" )
end

local function getObjectDefines()
    return "local me = player.GetByID(" .. LocalPlayer():EntIndex() .. ") local this = me:GetEyeTrace().Entity "
end

function luapad.RunScriptClient()
    if not luapad.CanUseCL( LocalPlayer() ) then return end
    local source = "Luapad[" .. LocalPlayer():SteamID() .. "]" .. LocalPlayer():Nick() .. ".lua"
    local code = getObjectDefines() .. luapad.PropertySheet:GetActiveTab():GetPanel():GetItems()[1]:GetValue()
    local success, err = luapad.Execute( code, source )
    if success then
        luapad.SetStatus( "Code ran sucessfully!", Color( 72, 205, 72, 255 ) )
    else
        luapad.SetStatus( "Code execution failed! Check console for more details.", Color( 205, 72, 72, 255 ) )
        MsgC( Color( 255, 222, 102 ), err .. "\n" )
    end
end

local function runScriptClientFromServer()
    local script = net.ReadString()
    local success, err = luapad.Execute( script, "Luapad[SERVER]" )
    if not success then
        MsgC( Color( 255, 222, 102 ), err .. "\n" )
    end
end

net.Receive( "luapad.DownloadRunClient", runScriptClientFromServer )

function luapad.RunScriptServer()
    if not luapad.CanUseSV( LocalPlayer() ) then return end

    net.Start( "luapad.Upload" )
    net.WriteString( getObjectDefines() .. luapad.PropertySheet:GetActiveTab():GetPanel():GetItems()[1]:GetValue() )
    net.SendToServer()
end

net.Receive( "luapad.Upload", function()
    local success = net.ReadBool()
    if success then
        luapad.SetStatus( "Code executed on server succesfully.", Color( 92, 205, 92, 255 ) )
        return
    end

    local err = net.ReadString()
    luapad.SetStatus( "Code execution on server failed! Check console for more details.", Color( 205, 92, 92, 255 ) )
    MsgC( Color( 145, 219, 232 ), err .. "\n" )
end )

function luapad.RunScriptServerClient()
    if not luapad.CanUseSV( LocalPlayer() ) then return end

    net.Start( "luapad.UploadClient" )
    net.WriteString( getObjectDefines() .. luapad.PropertySheet:GetActiveTab():GetPanel():GetItems()[1]:GetValue() )
    net.WriteBool( false )
    net.SendToServer()
end

function luapad.RunScriptOnClient( ply )
    if not luapad.CanUseSV( LocalPlayer() ) then return end

    net.Start( "luapad.UploadClient" )
    net.WriteString( getObjectDefines() .. luapad.PropertySheet:GetActiveTab():GetPanel():GetItems()[1]:GetValue() )
    net.WriteBool( true )
    net.WritePlayer( ply )
    net.SendToServer()
end

net.Receive( "luapad.UploadClient", function()
    luapad.SetStatus( "Scrip ran.", Color( 92, 205, 92, 255 ) )
end )

concommand.Add( "luapad", luapad.Toggle )
