# Luapad

## Description
A simple lua editor for Garry's Mod.

## CL Concommands
```lua
luapad -- Opens the editor if you have permission to run it.
luapad_auth_refresh -- Rerequests the permission to use the editor.
```

## SV Hooks
```
LuapadCanRunSV ply | return true to allow
LuapadCanRunCL ply | return true to allow
LuapadRanSV ply code
```
