util.AddNetworkString( "luapad.Upload" )
util.AddNetworkString( "luapad.UploadCallback" )
util.AddNetworkString( "luapad.UploadClient" )
util.AddNetworkString( "luapad.UploadClientCallback" )
util.AddNetworkString( "luapad.DownloadRunClient" )

-- local content = "-- This is an automatically generated cache file for serverside global functions, meta-tables, and enumerations\n-- Don't touch it, or you'll probably mess up your syntax highlighting\n\nluapad._sG = {};\n"
-- local endcontent = ""

-- for k, v in pairs( _G ) do
--     if type( v ) == "function" or type( v ) == "table" then
--         if type( v ) == "function" then
--             content = content .. "luapad._sG[\"" .. k .. "\"] = \"f\";\n"
--         else
--             local hasfunc = false

--             for _, v in pairs( v ) do
--                 if type( v ) == "function" then
--                     hasfunc = true
--                     break
--                 end
--             end

--             if hasfunc then
--                 content = content .. "luapad._sG[\"" .. k .. "\"] = {};\n"

--                 for k2, v2 in pairs( v ) do
--                     if type( v2 ) == "function" then
--                         endcontent = endcontent .. "luapad._sG[\"" .. k .. "\"]" .. "[\"" .. k2 .. "\"] = \"f\";\n"
--                     end
--                 end
--             end
--         end
--     end
-- end

-- content = content .. endcontent
-- local content = content .. "\n\n-- Enumerations\n\n"

-- if _E then
--     for k, v in pairs( _E ) do
--         if ( type( v ) ~= "function" or type( v ) ~= "table" ) and string.upper( k ) == k then
--             content = content .. "luapad._sG[\"" .. k .. "\"] = \"e\";\n"
--         end
--     end
-- end

-- local content = content .. "\n\n-- Meta-tables\n\n"

-- for _, v in pairs( debug.getregistry() ) do
--     if type( v ) == "table" then
--         local hasfunc = false

--         for _, v in pairs( v ) do
--             if type( v ) == "function" then
--                 hasfunc = true
--                 break
--             end
--         end

--         if hasfunc then
--             for k2, v2 in pairs( v ) do
--                 if type( v2 ) == "function" and not string.find( content, "luapad._sG[\"" .. k2 .. "\"] = \"m\";" ) then
--                     content = content .. "luapad._sG[\"" .. k2 .. "\"] = \"m\";\n"
--                 end
--             end
--         end
--     end
-- end

function luapad.Upload( _, ply )
    if not luapad.CanUseLuapad( ply ) then return end
    local str = net.ReadString()

    if str and luapad.CanUseLuapad( ply ) then
        RunString( str )
    end

    net.Start( "luapad.UploadCallback" )
    net.Send( ply )
end

net.Receive( "luapad.Upload", luapad.Upload )

function luapad.UploadClient( _, ply )
    if not luapad.CanUseLuapad( ply ) then return end
    local str = net.ReadString()

    if str and luapad.CanUseLuapad( ply ) then
        net.Start( "luapad.DownloadRunClient" )
        net.WriteString( str )
        net.Send( player.GetAll() )
    end

    net.Start( "luapad.UploadClientCallback" )
    net.Send( ply )
end

net.Receive( "luapad.UploadClient", luapad.UploadClient )

local function AcceptStream( ply, handler )
    if luapad.CanUseLuapad( ply ) and ( handler == "luapad.Upload" or handler == "luapad.UploadClient" ) then return true end
    if not ply:IsAdmin() and ( handler == "luapad.Upload" or handler == "luapad.UploadClient" ) then return false end
end

hook.Add( "AcceptStream", "luapad.AcceptStream", AcceptStream )
