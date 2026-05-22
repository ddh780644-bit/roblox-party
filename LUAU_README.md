# Roblox Party Game - Luau Version

This is the complete Roblox Party Game project organized for Rojo sync with Roblox Studio.

## Features

- **Luau Type Annotations**: All `.luau` files include full Luau type annotations for better IDE support and type safety
- **Rojo Sync**: Automatically syncs files to Roblox Studio via `rojo serve`
- **Modular Structure**: Well-organized code following Roblox best practices

## File Structure

```
roblox-party-game/
├── src/
│   ├── ServerScriptService/
│   │   ├── GameManager.luau          # Main game orchestrator (Luau)
│   │   ├── BoardManager.luau         # Board management (Luau)
│   │   ├── GameInit.lua              # Initialization script
│   │   ├── MiniGameRegistry.lua      # Mini-game registry
│   │   ├── LobbyManager.lua          # Lobby management
│   │   └── EconomyManager.lua        # Economy management
│   │
│   ├── ReplicatedStorage/
│   │   ├── RemoteEvents/
│   │   │   ├── LobbyEvents.lua       # Lobby remote events
│   │   │   ├── EconomyEvents.lua     # Economy remote events
│   │   │   ├── MiniGameEvents.lua    # Mini-game remote events
│   │   │   └── GameEvents.luau       # Game events (Luau)
│   │   │
│   │   └── SharedModules/
│   │       ├── GameState.luau        # Game state management (Luau)
│   │       └── PlayerData.luau       # Player data management (Luau)
│   │
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           └── ClientUI.luau         # Client UI (Luau)
│
├── default.project.json            # Rojo configuration
├── setup.lua                        # Setup script for Roblox Studio
└── README.md                        # This file
```

## Rojo Studio Paths

Each file maps to a specific location in Roblox Studio:

| Local Path | Roblox Studio Path |
|------------|-------------------|
| `ServerScriptService/GameManager.luau` | `ServerScriptService.GameManager` |
| `ServerScriptService/BoardManager.luau` | `ServerScriptService.BoardManager` |
| `ServerScriptService/GameInit.lua` | `ServerScriptService.GameInit` |
| `ServerScriptService/MiniGameRegistry.lua` | `ServerScriptService.MiniGameRegistry` |
| `ServerScriptService/LobbyManager.lua` | `ServerScriptService.LobbyManager` |
| `ServerScriptService/EconomyManager.lua` | `ServerScriptService.EconomyManager` |
| `ReplicatedStorage/RemoteEvents/GameEvents.luau` | `ReplicatedStorage.RemoteEvents.GameEvents` |
| `ReplicatedStorage/RemoteEvents/LobbyEvents.lua` | `ReplicatedStorage.RemoteEvents.LobbyEvents` |
| `ReplicatedStorage/RemoteEvents/EconomyEvents.lua` | `ReplicatedStorage.RemoteEvents.EconomyEvents` |
| `ReplicatedStorage/RemoteEvents/MiniGameEvents.lua` | `ReplicatedStorage.RemoteEvents.MiniGameEvents` |
| `ReplicatedStorage/SharedModules/GameState.luau` | `ReplicatedStorage.SharedModules.GameState` |
| `ReplicatedStorage/SharedModules/PlayerData.luau` | `ReplicatedStorage.SharedModules.PlayerData` |
| `StarterPlayer/StarterPlayerScripts/ClientUI.luau` | `StarterPlayer.StarterPlayerScripts.ClientUI` |

## Installation Instructions

### Prerequisites

1. **Roblox Studio** (any recent version)
2. **Node.js** (v16 or higher)
3. **Rojo** (install via npm): `npm install -g rojo`

### Setup Steps

1. **Install Rojo**
   ```bash
   npm install -g rojo
   ```

2. **Navigate to the project folder**
   ```bash
   cd /path/to/roblox-party-game
   ```

3. **Run Rojo server**
   ```bash
   rojo serve
   ```

4. **Open Roblox Studio and create a new place or open an existing one**

5. **Connect Rojo to Studio**
   - In Roblox Studio, open the Rojo plugin (View → Plugins → Rojo)
   - The connection should auto-detect since Rojo is running on the default port (8080)
   - Click "Connect" in the Rojo plugin

6. **Sync files to Roblox**
   - In the Rojo plugin, click "Sync to Roblox"
   - All files will be created in the correct locations

### Alternative: Manual Setup

If Rojo doesn't work, you can manually create the instances:

1. Open Roblox Studio
2. Create a new place (Baseplate template)
3. Run the `setup.lua` script in the Studio command bar or as a LocalScript
4. This will create all required instances and RemoteEvents

## Luau Type Annotations

The `.luau` files include full Luau type annotations:

- `type GameStateType = "LOBBY" | "ROUND" | "MINIGAME" | "ENDED"`
- `type PlayerData = { UserId: number, Name: string, Balance: number, ... }`
- `type GameManager = { State: GameState, ... }`
- And many more...

These types provide:
- Better IDE autocomplete and error detection
- Type safety for function parameters and return values
- Improved code documentation

## Remote Events

All RemoteEvents are defined in `ReplicatedStorage.RemoteEvents`:

**LobbyEvents**:
- `PlayerJoined`, `ReadyStatusChanged`, `LobbyFull`, `GameStarting`
- `PlayerReady`, `ReadyToStart`, `ReadyToPlay`

**EconomyEvents**:
- `BalanceChanged`, `TransactionCompleted`
- `PaydayStarted`, `PaydayEnded`
- `TransferMoney`, `BuyItem`

**MiniGameEvents**:
- `MiniGameStarted`, `MiniGameEnded`, `PositionChanged`, `BoardUpdated`
- `MoveDiceRoll`, `BuySpace`, `UpgradeSpace`
- `SubmitGuess`, `SubmitChoice`, `UseItem`, `ChatMessage`

**GameEvents**:
- `GameStateUpdated`, `RoundStarted`, `MiniGameStarted`, `MiniGameEnded`
- `GameEnded`, `MiniGameSelected`
- `ReadyToStart`, `ReadyToPlay`

## Mini-Games Included

1. **Dice Battle**: Roll 2d6, highest wins
2. **Number Guess**: Guess number 1-100
3. **Paper Scissors Rock**: Classic rock-paper-scissors

## Troubleshooting

### Rojo not connecting
- Ensure Rojo is running: `rojo serve`
- Check if port 8080 is not blocked
- Try restarting Roblox Studio

### Files not syncing
- Click "Sync to Roblox" in the Rojo plugin
- Verify the project structure matches `default.project.json`

### Luau type errors in Studio
- Luau types are for IDE support only
- The code will run correctly in Roblox even without type annotations

## License

MIT - Free to use and modify
