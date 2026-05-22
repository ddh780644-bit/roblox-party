# Roblox Party Game — Joe's Structure

## Files for Joe's Dashboard

### Zip File Download
**Download:** `/root/.openclaw/workspace-coder/roblox-party-game.zip`

### File Structure (Joe's Format)
```
my game/
├─ default.project.json
└─ src/
   ├─ server/
   │  └─ init.server.luau    ← ALL server code goes here
   ├─ client/
   │  └─ init.client.luau    ← ALL client code goes here
   └─ shared/
      └─ init.luau           ← ALL shared modules go here
```

### Dashboard API Endpoint
**API:** `http://localhost:8960/api/roblox/files`

### Direct File Contents (for copy/paste)

#### 1. default.project.json
```json
{
	"name": "RobloxParty",
	"serve": {"host": "0.0.0.0", "port": 8080},
	"plugins": ["RojoPlugin"],
	"root": "src",
	"tree": {
		"children": [
			{
				"name": "ServerScriptService",
				"children": [
					{
						"name": "RobloxParty",
						"path": "src/server"
					}
				]
			},
			{
				"name": "ReplicatedStorage",
				"children": [
					{
						"name": "SharedModules",
						"path": "src/shared"
					}
				]
			},
			{
				"name": "StarterPlayer",
				"children": [
					{
						"name": "StarterPlayerScripts",
						"children": [
							{
								"name": "RobloxParty",
								"path": "src/client"
							}
						]
					}
				]
			}
		]
	}
}
```

#### 2. src/server/init.server.luau
Contains all server code:
- GameManager
- BoardManager
- EconomyManager
- LobbyManager
- MiniGameRegistry

#### 3. src/client/init.client.luau
Contains all client code:
- ClientUI
- Event handlers

#### 4. src/shared/init.luau
Contains all shared modules:
- GameState
- PlayerData

## How to Use

1. **Extract the zip file** to `C:\Roblox\my game\`
2. **Run `rojo serve`** from the project directory
3. **Connect in Roblox Studio** to start developing

## Original Files Preserved

All original individual files are still available in the zip under the old paths:
- `src/ServerScriptService/GameManager.luau`
- `src/ServerScriptService/BoardManager.luau`
- `src/ServerScriptService/EconomyManager.lua`
- `src/ServerScriptService/LobbyManager.lua`
- `src/ServerScriptService/MiniGameRegistry.lua`
- And more...

## Files Summary

| File | Size | Description |
|------|------|-------------|
| default.project.json | ~1KB | Rojo project configuration |
| src/server/init.server.luau | ~35KB | Combined server code |
| src/client/init.client.luau | ~17KB | Combined client code |
| src/shared/init.luau | ~5KB | Combined shared modules |
| **Total zip** | ~57KB | Complete project |

## Testing

To test the reorganized structure:
```bash
cd /root/.openclaw/workspace-coder/roblox-party-game
rojo serve --port 8080
```

Then connect from Roblox Studio and verify:
- All server scripts are in `ServerScriptService.RobloxParty`
- Client scripts are in `StarterPlayer.StarterPlayerScripts.RobloxParty`
- Shared modules are in `ReplicatedStorage.SharedModules`

---

**Report completed** ✅

Zip file ready: `/root/.openclaw/workspace-coder/roblox-party-game.zip`  
Files in dashboard API: `http://localhost:8960/api/roblox/files`
