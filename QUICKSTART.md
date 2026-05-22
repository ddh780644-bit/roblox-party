# Roblox Party Game - Luau Type Annotations

This project contains the complete Roblox Party Game organized for **Rojo sync** with proper **Luau type annotations**.

## Quick Start

### Requirements
- Roblox Studio
- Node.js v16+
- Rojo (`npm install -g rojo`)

### Installation
```bash
cd roblox-party-game
rojo serve
```

Then in Roblox Studio:
1. Open the Rojo plugin (View → Plugins → Rojo)
2. Click "Connect"
3. Click "Sync to Roblox"

## Files Overview

### Luau Files (with Type Annotations)
| File | Purpose |
|------|---------|
| `src/ServerScriptService/GameManager.luau` | Main game orchestrator |
| `src/ServerScriptService/BoardManager.luau` | Board management |
| `src/ReplicatedStorage/SharedModules/GameState.luau` | Game state management |
| `src/ReplicatedStorage/SharedModules/PlayerData.luau` | Player data |
| `src/ReplicatedStorage/RemoteEvents/GameEvents.luau` | Game events |
| `src/StarterPlayer/StarterPlayerScripts/ClientUI.luau` | Client UI |

### Lua Files (Legacy/Compatible)
- `src/ServerScriptService/GameManager.lua` - Original
- `src/ServerScriptService/BoardManager.lua` - Original
- `src/ReplicatedStorage/SharedModules/GameState.lua` - Original
- `src/ReplicatedStorage/SharedModules/PlayerData.lua` - Original
- `src/StarterPlayer/StarterPlayerScripts/ClientUI.lua` - Original

## Rojo Mapping

Each file maps to a specific Roblox Studio location:

```
ServerScriptService/
├── GameManager (GameManager.luau)
├── BoardManager (BoardManager.luau)
├── GameInit (GameInit.lua)
├── MiniGameRegistry (MiniGameRegistry.lua)
├── LobbyManager (LobbyManager.lua)
└── EconomyManager (EconomyManager.lua)

ReplicatedStorage/
├── RemoteEvents/
│   ├── LobbyEvents (LobbyEvents.lua)
│   ├── EconomyEvents (EconomyEvents.lua)
│   ├── MiniGameEvents (MiniGameEvents.lua)
│   └── GameEvents (GameEvents.luau)
└── SharedModules/
    ├── GameState (GameState.luau)
    └── PlayerData (PlayerData.luau)

StarterPlayer/
└── StarterPlayerScripts/
    └── ClientUI (ClientUI.luau)
```

## Luau Type Annotations

The `.luau` files include full type annotations like:

```luau
type GameStateType = "LOBBY" | "ROUND" | "MINIGAME" | "ENDED"

type PlayerData = {
	UserId: number,
	Name: string,
	Balance: number,
	Position: number,
	isReady: boolean,
	-- ... more fields
}

type GameManager = {
	State: GameState,
	Players: {number: PlayerData},
	-- ... more fields
}
```

This provides:
- Better IDE autocomplete
- Type safety for parameters
- Better code documentation

## Mini-Games

1. **DiceBattle** - Roll 2d6, highest wins
2. **NumberGuess** - Guess number 1-100
3. **PaperScissorsRock** - Classic rock-paper-scissors

## Remote Events

All events are in `ReplicatedStorage.RemoteEvents`:

- **Lobby**: PlayerJoined, ReadyStatusChanged, LobbyFull, GameStarting
- **Economy**: BalanceChanged, TransactionCompleted, PaydayStarted/Ended
- **MiniGame**: MiniGameStarted, MiniGameEnded, PositionChanged, BoardUpdated
- **Game**: GameStateUpdated, RoundStarted, MiniGameStarted/Ended, GameEnded

## Zip File Contents

The zip includes:
- All source files organized by Roblox service
- Rojo configuration (`default.project.json`)
- Documentation files
- Total: 24 files (6 Luau with types, 18 Lua)

## License

MIT - Free to use and modify
