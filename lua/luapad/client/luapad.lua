-- Autorefresh support
if IsValid( luapad.Frame ) then
    luapad.Frame:Remove()
end

local function saveAsScript()
    local name = luapad.PropertySheet:GetActiveTab():GetPanel().name
    Derma_StringRequest( "Luapad", "You are about to save a file, please enter the desired filename.", name, function( filename )
        local extension = string.GetExtensionFromFilename( filename )
        if not extension then
            filename = filename .. ".txt"
        end

        local contents = luapad.getCurrentScript()
        local filePath = "luapad/" .. filename
        file.Write( filePath, contents )

        if file.Exists( filePath, "DATA" ) then
            luapad.AddConsoleText( "File succesfully saved!", Color( 72, 205, 72, 255 ) )
            luapad.PropertySheet:GetActiveTab():GetPanel().name = filename
            luapad.PropertySheet:GetActiveTab():SetText( filename )
            luapad.PropertySheet:SetActiveTab( luapad.PropertySheet:GetActiveTab() )

            luapad.PropertySheet:InvalidateChildren()
        else
            luapad.AddConsoleText( "Save failed! (check your filename for illegal characters)", Color( 205, 72, 72, 255 ) )
        end

        luapad.SaveTabs()
    end, nil, "Save", "Cancel" )
end

function luapad.SaveCurrentScript()
    local contents = luapad.getCurrentScript()
    contents = string.gsub( contents, "   	", "\t" )

    local path = "luapad/" .. luapad.PropertySheet:GetActiveTab():GetPanel().name
    if not file.Exists( path, "DATA" ) then
        saveAsScript()
    else
        file.Write( path, contents )

        if file.Time( path, "DATA" ) == os.time() then
            luapad.AddConsoleText( "File succesfully saved!", Color( 72, 205, 72, 255 ) )
        else
            luapad.AddConsoleText( "Save failed! (check your filename for illegal characters)", Color( 205, 72, 72, 255 ) )
        end
    end
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
        local content = panel:GetValue()
        if content == "" then continue end
        table.insert( store.tabs, { name = name, path = path, content = content } )
    end

    file.Write( "luapad/_tabs.dat", "luapad " .. util.Compress( util.TableToJSON( store ) ) )
end
hook.Add( "ShutDown", "luapad.SaveTabs", luapad.SaveTabs )

local function loadSavedTabs()
    if not file.Exists( "luapad/_tabs.dat", "DATA" ) then
        if file.Exists( "luapad/_tabs.txt", "DATA" ) then
            file.Rename( "luapad/_tabs.txt", "luapad/_tabs.dat" )
        else
            return
        end
    end

    local store = util.JSONToTable( util.Decompress( file.Read( "luapad/_tabs.dat", "DATA" ):sub( 8 ) ) )

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

local function addToolbarItem( tooltip, mat, func )
    local button = vgui.Create( "DImageButton" )
    button:SetImage( mat )
    button:SetTooltip( tooltip )
    button:SetSize( 16, 16 )
    button.DoClick = func
    luapad.Toolbar:AddItem( button )
end

local function addToolbarSpacer()
    local lab = vgui.Create( "DLabel" )
    lab:SetText( " | " )
    lab:SizeToContents()
    luapad.Toolbar:AddItem( lab )
end

local function setupToolbar()
    if not IsValid( luapad.Toolbar ) then return end
    luapad.Toolbar:Clear()

    addToolbarItem( "New (CTRL + N)", "icon16/page_white_add.png", luapad.NewTab )
    addToolbarItem( "Open (CTRL + O)", "icon16/folder_page_white.png", luapad.OpenScript )
    addToolbarItem( "Save (CTRL + S)", "icon16/disk.png", SaveCurrentScript )
    addToolbarItem( "Save As (CTRL + ALT + S)", "icon16/disk_multiple.png", saveAsScript )
    addToolbarItem( "Paste large text without lag", "icon16/paste_plain.png", function()
        local dframe = vgui.Create( "DFrame" )
        dframe:SetSize( 200, 100 )
        dframe:Center()
        dframe:MakePopup()

        local dhtml = vgui.Create( "DHTML", dframe )
        dhtml:Dock( FILL )
        dhtml:SetHTML( [[<textarea id="paste"></textarea>
            <script>
                document.getElementById("paste").focus();
                document.getElementById("paste").oninput = function() {
                    gmod.paste( document.getElementById("paste").value );
                };
            </script>
        ]] )
        dhtml:AddFunction( "gmod", "paste", function( text )
            luapad.NewTab( text )
            dframe:Remove()
        end )
    end )
    addToolbarItem( "Settings", "icon16/cog.png", function()
        luapad.ToggleSettingsMenu()
    end )

    addToolbarSpacer()

    local isSVUser = luapad.CanUseSV()

    addToolbarItem( "Run Clientside", "!luapadRunClient", function()
        luapad.SaveTabs()
        luapad.RunScriptClient()
    end )

    if isSVUser then
        addToolbarItem( "Run Serverside", "!luapadRunServer", function()
            luapad.SaveTabs()
            luapad.RunScriptServer( luapad.getCurrentScript() )
        end )

        addToolbarSpacer()

        addToolbarItem( "Run Shared", "!luapadShared", function()
            luapad.SaveTabs()
            luapad.RunScriptClient()
            luapad.RunScriptServer( luapad.getCurrentScript() )
        end )
        addToolbarItem( "Run on all clients", "!luapadClientAll", function()
            luapad.SaveTabs()
            luapad.RunScriptServerClient()
        end )
        addToolbarItem( "Run on specific client", "!luapadClientSpecific", function()
            luapad.SaveTabs()
            local menu = DermaMenu()

            -- sort players by name
            local players = player.GetAll()
            table.sort( players, function( a, b )
                return string.lower( a:Nick() ) < string.lower( b:Nick() )
            end )

            for _, v in pairs( players ) do
                if v == LocalPlayer() then continue end
                menu:AddOption( v:Nick(), function()
                    if not IsValid( v ) then return end

                    luapad.RunScriptOnClient( v )
                end )
            end
            menu:Open()
        end )
    end
end

function luapad.Toggle()
    if IsValid( luapad.Frame ) then
        luapad.Frame:SetVisible( not luapad.Frame:IsVisible() )
        return
    end

    include( "luapad/client/server_globals.lua" )

    -- Build it, if it doesn't exist
    luapad.Frame = vgui.Create( "DFrame" )
    luapad.Frame:SetSize( ScrW() * 2 / 3, ScrH() * 2 / 3 )
    luapad.Frame:SetPos( ScrW() * 1 / 6, ScrH() * 1 / 6 )
    luapad.Frame:SetTitle( "Luapad" )
    luapad.Frame:ShowCloseButton( true )
    luapad.Frame:SetSizable( true )
    luapad.Frame:MakePopup()
    luapad.Frame:SetIcon( "icon16/application_osx_terminal.png" )

    function luapad.Frame.btnClose:DoClick()
        luapad.Toggle()
        luapad.SaveTabs()
    end

    luapad.Toolbar = vgui.Create( "DPanelList", luapad.Frame )
    luapad.Toolbar:Dock( TOP )
    luapad.Toolbar:SetSize( luapad.Frame:GetWide() - 6, 22 )
    luapad.Toolbar:SetSpacing( 5 )
    luapad.Toolbar:EnableHorizontal( true )
    luapad.Toolbar:EnableVerticalScrollbar( false )

    luapad.PropertySheet = vgui.Create( "DPropertySheet", luapad.Frame )
    luapad.PropertySheet.tabScroller:DockMargin( 0, 0, 0, 0 )
    luapad.PropertySheet.tabScroller:SetOverlap( 0 )
    luapad.PropertySheet.____SetActiveTab = luapad.PropertySheet.SetActiveTab
    function luapad.PropertySheet:SetActiveTab( ... )
        luapad.PropertySheet:____SetActiveTab( ... )

        if luapad.PropertySheet:GetActiveTab() then
            local panel = luapad.PropertySheet:GetActiveTab():GetPanel()
            luapad.Frame:SetTitle( "Luapad - " .. panel.path .. panel.name )
        end
    end
    luapad.PropertySheet.tabScroller:SetTall( 22 )
    luapad.PropertySheet.tabScroller.SetTall = function() end
    luapad.PropertySheet.Paint = function() end

    local console = vgui.Create( "LuapadConsole", luapad.Frame )
    luapad.Frame.Console = console

    local hdiv = vgui.Create( "DVerticalDivider", luapad.Frame )
    hdiv:Dock( FILL )
    hdiv:SetDividerHeight( 5 )
    hdiv:SetTop( luapad.PropertySheet )
    hdiv:SetBottom( console )
    hdiv:SetTopMin( 300 )
    hdiv:SetBottomMin( 100 )
    hdiv:SetTopHeight( luapad.Frame:GetTall() - 200 )

    luapad.Frame.Divider = hdiv

    luapad.PropertySheet:InvalidateLayout()


    setupToolbar()
    loadSavedTabs()

    if table.Count( luapad.PropertySheet.Items ) == 0 then
        luapad.NewTab()
    end
end

function luapad.AddTab( name, content, path )
    content = content or ""
    path = path or ""
    content = string.gsub( content, "\t", "	   " )

    local editor = vgui.Create( "LuapadEditor", luapad.PropertySheet )
    editor:SetText( content )
    editor:Dock( FILL )
    editor:RequestFocus()
    editor.name = name
    editor.path = path

    local sheet = luapad.PropertySheet:AddSheet( name, editor, "icon16/page_white.png", false, false )
    local dtab = sheet.Tab
    editor.dtab = dtab

    function dtab:DoRightClick()
        local menu = DermaMenu()
        menu:AddOption( "Close", function()
            local tabCount = table.Count( luapad.PropertySheet.Items )
            if tabCount == 1 then
                luapad.NewTab()
                luapad.PropertySheet:CloseTab( self, true )
                return
            end

            luapad.PropertySheet:CloseTab( self, true )
        end ):SetIcon( "icon16/cross.png" )

        menu:AddOption( "Save", luapad.SaveCurrentScript ):SetIcon( "icon16/disk.png" )

        menu:AddSpacer()

        menu:AddOption( "Close all but this", function()
            for _, v in pairs( luapad.PropertySheet.Items ) do
                if v["Tab"] == self then continue end
                luapad.PropertySheet:CloseTab( v["Tab"], true )
            end
        end ):SetIcon( "icon16/cross.png" )

        menu:AddOption( "Close all", function()
            for _, v in pairs( luapad.PropertySheet.Items ) do
                luapad.PropertySheet:CloseTab( v["Tab"], true )
            end
        end ):SetIcon( "icon16/cross.png" )

        menu:Open()
    end

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

    function luapad.OpenCloseButton:DoClick()
        luapad.OpenTree:Remove()
    end

    local node1 = luapad.OpenTree:AddNode( "garrysmod\\data" )
    node1.RootFolder = "data"
    node1:MakeFolder( "data", "GAME", true )
    node1.Icon:SetImage( "icon16/computer.png" )

    local node2 = luapad.OpenTree:AddNode( "luapad" )

    node2.RootFolder = "data/luapad"
    node2:MakeFolder( "data/luapad", "GAME", true, "*.txt" )
    node2.Icon:SetImage( "icon16/folder_page_white.png" )
end

concommand.Add( "luapad", function()
    if luapad.CanUseCL() then
        luapad.Toggle()
        return
    end

    luapad.RequestCLAuth( luapad.Toggle )
end )

concommand.Add( "luapad_auth_refresh", function()
    luapad.RequestCLAuth( setupToolbar )
end )
