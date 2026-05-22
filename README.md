# Roblox Party Game v1.0.0

A complete multiplayer party game for Roblox Studio with multiple mini-games, economy system, and lobby management.

## Features

- **4 Mini-games:**
  - Dice Battle - Roll dice, highest wins!
  - Number Guess - Guess a number 1-100 to win
  - Paper Scissors Rock - Classic game of chance
  - (More coming soon!)

- **Economy System:**
  - Player balances
  - Payday system every 5 minutes
  - Transaction tracking
  - Items and inventory

- **Lobby System:**
  - Player ready system
  - Countdown timer
  - Player management

- **Board System:**
  - Space ownership
  - Upgrades
  - Special spaces (Chance, Bonus, Free)

## Installation for Joe

### Option 1: Copy Files Manually

1. Copy the entire `roblox-party-game` folder to your PC
2. Place it in `C:\Roblox\RobloxParty\`
3. In Roblox Studio:
   - Create a new place file (`.rbxl`)
   - Open the Explorer window
   - Drag each folder's contents from the project folder into the corresponding place folders
   - Save your place file

### Option 2: Use Rojo (Recommended)

1. Install [Rojo](https://github.com/rojo-rbx/rojo) on your PC
2. Navigate to the project folder:
   ```
   cd C:\Roblox\RobloxParty
   ```
3. Run Rojo:
   ```
   rojo serve
   ```
4. Open Roblox Studio and connect to the game
5. All files will sync automatically

## Project Structure

```
roblox-party-game/
├── default.project.json          # Rojo configuration
└── src/                          # Source files (synced to Roblox Studio)
    ├── ServerScriptService/      # Server-side scripts
    │   ├── GameInit.lua          # Main game initialization
    │   ├── GameManager.lua       # Main game orchestrator
    │   ├── BoardManager.lua      # Board and movement logic
    │   ├── EconomyManager.lua    # Player economy system
    │   ├── LobbyManager.lua      # Lobby management
    │   └── MiniGameRegistry.lua  # Mini-game registry
    │
    ├── ReplicatedStorage/        # Shared between server and client
    │   ├── RemoteEvents/         # Remote event definitions
    │   └── SharedModules/        # Modules required by both
    │       ├── GameState.lua
    │       └── PlayerData.lua
    │
    └── StarterPlayer/            # Client-side scripts
        └── StarterPlayerScripts/
            └── ClientUI.lua      # Client UI system
```

## Game Flow

1. **Lobby Phase:**
   - Players join the lobby
   - Each player clicks "Ready" to join the game
   - When all players are ready, the countdown begins
   - The game starts after the countdown

2. **Round Phase:**
   - Game Manager selects a random mini-game
   - Players join the mini-game
   - Mini-game logic runs

3. **Mini-Game Phase:**
   - Players interact with the mini-game
   - Results are calculated
   - Winners are determined
   - Balances are updated

4. **Next Round:**
   - After the mini-game ends, players can play again
   - The round continues until all players leave or the game ends

## File Descriptions

### Server Scripts

#### GameManager.lua
Main game orchestrator. Handles:
- Game state management
- Round initialization
- Mini-game selection and management
- Player results and rewards

#### BoardManager.lua
Manages the game board:
- Space creation and types
- Player movement
- Space ownership
- Upgrades and costs

#### EconomyManager.lua
Handles player economy:
- Balance management
- Transactions
- Payday system
- Trading between players

#### LobbyManager.lua
Manages the lobby:
- Player join/leave events
- Ready status tracking
- Countdown timer
- Game start conditions

#### MiniGameRegistry.lua
Registry for all mini-games:
- Game registration
- Random game selection
- Mini-game lifecycle management

#### GameInit.lua
Initializes the entire game system:
- Imports all modules
- Sets up event connections
- Starts the game in lobby mode

### Client Scripts

#### ClientUI.lua
Main client-side UI:
- Lobby UI with player list
- Mini-game input interface
- Economy display
- Event handlers for all game events

### Shared Modules

#### GameState.lua
Shared state management:
- Current game state
- State transitions
- State checking

#### PlayerData.lua
Player-specific data:
- Balance tracking
- Inventory management
- Stats tracking
- Jail/skip state

## How to Play

### For Joe (Developer)

1. Place the files in your Roblox Studio project
2. Make sure all RemoteEvents exist in ReplicatedStorage
3. Test in Studio by pressing Play
4. Invite friends to test multiplayer

### For Players

1. Join the game in Roblox Studio or Roblox
2. Wait in the lobby until enough players join
3. Click "Ready" when ready to play
4. Wait for the countdown to finish
5. Play the mini-games when selected!
6. Try to earn the most money by winning mini-games

## Future Enhancements

- More mini-games (Trivia, Speed Clicker, Memory Match)
- Special items for sale
- Seasonal events and rewards
- Leaderboards
- Customizable board spaces
- Team-based mini-games

## Troubleshooting

### Files not syncing with Rojo
- Make sure `rojo serve` is running
- Check the port is not already in use
- Restart Rojo if needed

### RemoteEvents not found
- Create the RemoteEvents in ReplicatedStorage manually:
  - LobbyEvents (Folder)
  - GameEvents (Folder)
  - EconomyEvents (Folder)
  - MiniGameEvents (Folder)

### Mini-games not starting
- Check that all mini-games are registered in MiniGameRegistry
- Verify GameManager is importing correctly

## Credits

Created for Roblox Party Game v1.0.0
License: Free to use and modify
