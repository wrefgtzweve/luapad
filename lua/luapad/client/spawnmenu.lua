-- Browse Lua Files for the Sandbox Spawn Menu

local function onNodeSelected( self, node )
    local viewPanel = self.ViewPanel
    local path = self.Path

    viewPanel:Clear()

    local files = file.Find( path .. "/*", self.SearchPath )

    for _, fileName in ipairs( files ) do
        spawnmenu.CreateContentIcon( "gamefile", viewPanel, {
            fileName = fileName,
            filePath = path .. "/" .. fileName
        } )
    end

    self.pnlContent:SwitchPanel( viewPanel )
end

local function addFolderNode( mainNode, node, name, icon, path, searchPath )
    local folderNode = node:AddNode( name, icon )

    folderNode.ViewPanel = mainNode.ViewPanel
    folderNode.pnlContent = mainNode.pnlContent

    folderNode.Path = path
    folderNode.SearchPath = searchPath
    folderNode.OnNodeSelected = onNodeSelected

    return folderNode
end

local function recursiveAddLua( mainNode, node, path, searchPath )
    local _, dirs = file.Find( path .. "*", searchPath )

    for _, dir in ipairs( dirs ) do
        local folderPath = path .. dir
        local folder = addFolderNode( mainNode, node, dir, "icon16/folder.png", folderPath, searchPath )

        local _, subDirs = file.Find( folderPath .. "/*", searchPath )

        if subDirs[1] then
            recursiveAddLua( mainNode, folder, folderPath .. "/", searchPath )
        end
    end
end

local function deleteIfEmpty( node )
    if #node:GetChildNodes() <= 0 then
        node:Remove()
    end
end

local function refreshGModLua( node )
    recursiveAddLua( node, node, "lua/", "MOD" )
    deleteIfEmpty( node )
end

local function refreshAddonLuaFiles( node )
    for _, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do
        if addon.downloaded and addon.mounted then
            local title = addon.title

            local files, dirs = file.Find( "lua/*", title )
            local hasLua = files[1] or dirs[1]

            if hasLua then
                local luaFiles = addFolderNode( node, node, title, "icon16/bricks.png", "lua", title )

                recursiveAddLua( node, luaFiles, "lua/", title )
            end
        end
    end

    deleteIfEmpty( node )
end

local function refreshLegacyAddonLuaFiles( node )
    local legacyAddons = {}
    local _, dirs = file.Find( "addons/*", "GAME" )

    if not dirs[1] then
        return node:Remove()
    end

    for _, addon in ipairs( dirs ) do
        table.insert( legacyAddons, addon )
    end

    table.sort( legacyAddons )

    for k, addon in ipairs( legacyAddons ) do
        local files, dirs = file.Find( "addons/" .. addon .. "/lua/*", "GAME" )
        local hasLua = files[1] or dirs[1]

        if hasLua then
            local luaFiles = addFolderNode( node, node, addon, "icon16/bricks.png", "addons/" .. addon .. "/lua", "GAME" )

            recursiveAddLua( node, luaFiles, "addons/" .. addon .. "/lua/", "GAME" )
        end
    end

    deleteIfEmpty( node )
end

hook.Add( "PopulateContent", "SpawnmenuLuapadBrowse", function( panelContent, tree )
    timer.Simple( 0.1, function() -- Make sure this is added after normal Browse is created
        local viewPanel = tree:Add( "ContentContainer" )

        viewPanel:SetVisible( false )

        local function createTreeNode( name, icon, parent )
            parent = parent or tree

            local newTree = parent:AddNode( name, icon )
        
            newTree.pnlContent = panelContent
            newTree.ViewPanel = viewPanel
        
            return newTree
        end

        local browseLua = createTreeNode( "#spawnmenu.category.browselua", "icon16/page_white_text.png" )
        local browseLuapad = createTreeNode( "#spawnmenu.category.luapadlua", "icon16/folder.png", browseLua )
        local browseAddonLua = createTreeNode( "#spawnmenu.category.addons", "icon16/folder.png", browseLua )
        local browseLegacyLua = createTreeNode( "#spawnmenu.category.addonslegacy", "icon16/folder.png", browseLua )
        local browseGmodLua = createTreeNode( "Garry's Mod", "games/16/garrysmod.png", browseLua )

        browseLuapad.OnNodeSelected = onNodeSelected
        browseLuapad.Path = "data/luapad"
        browseLuapad.SearchPath = "GAME"

        refreshAddonLuaFiles( browseAddonLua )
        refreshLegacyAddonLuaFiles( browseLegacyLua )
        refreshGModLua( browseGmodLua )
    end)
end)

language.Add( "spawnmenu.category.browselua", "Browse Lua" )
language.Add( "spawnmenu.category.luapadlua", "Luapad Storage" )

spawnmenu.AddContentType( "gamefile", function( container, obj )
	local icon = vgui.Create( "ContentIcon", container )
    
	icon:SetContentType( "gamefile" )
	icon:SetSpawnName( obj.filePath )
	icon:SetName( obj.fileName )
	icon:SetMaterial( "icon16/page_white_text.png" )

	icon.DoClick = function()
        local function openFile()
            if IsValid( luapad.Frame ) then
                luapad.Frame:SetVisible( true )
            else
                luapad.Toggle( true )
            end

            luapad.OpenFile( obj.filePath )

            local spawnMenu = g_SpawnMenu

            if IsValid( spawnMenu ) then
                spawnMenu:Close()
            end
        end

        if luapad.CanUseCL() then
            return openFile()
        end
    
        luapad.RequestCLAuth( openFile )
	end

	icon.OpenMenu = function( icn )
		local menu = DermaMenu()
			menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( obj.filePath ) end ):SetIcon( "icon16/page_copy.png" )
			menu:AddSpacer()
			menu:AddOption( "#spawnmenu.menu.delete", function() icn:Remove() hook.Run( "SpawnlistContentChanged", icn ) end ):SetIcon( "icon16/bin_closed.png" )
		menu:Open()
	end

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon

end )