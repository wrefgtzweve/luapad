# Luapad
A simple lua run tool for Garry's Mod.
![image](https://github.com/user-attachments/assets/d66411e1-3f8e-4d35-8468-edaebbef5e42)

### Clientside console commands
```lua
luapad -- Opens the editor if you have permission to run it.
luapad_auth_refresh -- Rerequests the permission to use the editor.
```

#### SV Hooks
```
LuapadCanRunSV ply | return true to allow
LuapadCanRunCL ply | return true to allow
LuapadRanSV ply code
```

#### SH Hooks
```
LuapadCustomizeEnv ply env
```
