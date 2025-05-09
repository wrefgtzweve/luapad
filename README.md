# 💻Luapad
## ⚒️A simple tool to run lua code on the client and server in Garry's Mod.
![image](https://github.com/user-attachments/assets/d66411e1-3f8e-4d35-8468-edaebbef5e42)

## Features:
- **Execute Code Anywhere**: Run Lua code seamlessly on both the client and server.
- **Enhanced Environment**: Code executes in a custom environment with additional utilities for convenience.
- **Debugging Made Easy**: Client-side prints are automatically forwarded to the original code runner, enabling efficient debugging across players.
- **Granular Permissions**: Use hooks to independently allow or restrict code execution on the client and server for specific players.
- **Customization Options**: Enjoy custom fonts, themes, and more to personalize your experience.
- **Integrated Console**: Includes a built-in console for running code in a CLI-style interface.
- **File Management**: Save and manage your scripts with the integrated file browser and storage system.

### 📜 Clientside Console Commands

- **`luapad`**: Opens the editor if you have the necessary permissions.
- **`luapad_auth_refresh`**: Refreshes the authorization for the Luapad editor.

### 🌟 Enhanced Environment Variables

When executing code, Luapad provides a custom environment with several useful global variables to simplify your scripting:

- **`_G.me`**: The player entity running the code.
- **`_G.tr`**: The eyetrace of the code runner.
- **`_G.this`**: The entity the code runner is looking at.
- **`_G.there`**: The hit position of the code runner's eyetrace.
- **`_G.here`**: The current position of the code runner.
- **`_G.bot`**: The first bot player (`player.GetBots()[1]`).
- **`_G.randombot()`**: Returns a random bot player.
- **`_G.GM`**: The current game mode (Same as `GAMEMODE` but for ease of use in gamemode development).

These variables are designed to enhance your coding experience by providing quick access to commonly used entities and positions.

### 🔧 Server-Side (SV) Hooks

- **`LuapadCanRunSV(Entity ply)`**
    Triggered when a player attempts to execute code on the server. Return `true` to permit execution.

- **`LuapadCanRunCL(Entity ply)`**
    Triggered when a player attempts to execute code on the client. Return `true` to permit execution.

- **`LuapadRanSV(Entity ply, string code)`**
    Triggered after a player successfully executes code on the server. The executed code is passed as a string.

### 🔄 Shared (SH) Hooks

- **`LuapadCustomizeEnv(Entity ply, Table env)`**
    Triggered when a player executes code on the server. The `env` table is passed, allowing you to modify it by adding custom functions or variables.
