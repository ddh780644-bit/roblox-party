# Roblox Party Game - Complete File List

## Project Structure

```
C:\Roblox\RobloxParty\
├── default.project.json          # Rojo configuration file
├── README.md                     # This project documentation
└── src/                          # Source files (synced to Roblox Studio)
    ├── setup.lua                 # Setup script to create all RemoteEvents
    ├── ServerScriptService/      # Server-side scripts (5 files)
    ├── ReplicatedStorage/        # Shared between server and client (2 files)
    └── StarterPlayer/            # Client-side scripts (1 file)
```

## Server-Side Scripts (6 files)

### 1. ServerScriptService/GameManager.lua (6035 bytes)
**Purpose:** Main game orchestrator
**Key Functions:**
- `startLobby()` - Initialize lobby state
- `startRound()` - Start a new round
- `startMiniGame(gameName)` - Launch a mini-game
- `endMiniGame()` - Clean up after mini-game
- `endGame()` - Final game cleanup and leaderboard
- `getPlayerCount()` - Get current player count
- `readyPlayer(player)` - Mark player as ready

### 2. ServerScriptService/BoardManager.lua (8208 bytes)
**Purpose:** Manages game board and player movement
**Key Functions:**
- `initBoard()` - Create board spaces
- `movePlayer(player, spaces)` - Move player on board
- `processSpace(player, position)` - Handle landed spaces
- `buySpace(player, position)` - Purchase a space
- `upgradeSpace(player, position)` - Upgrade a space
- `getBoardState()` - Get current board state
- `initPlayer(player)` - Initialize player data for board

### 3. ServerScriptService/EconomyManager.lua (5214 bytes)
**Purpose:** Player economy and transactions
**Key Functions:**
- `transfer(player, target, amount)` - Transfer money between players
- `buyItem(player, item)` - Purchase items
- `collectPayday(player)` - Collect payday bonus
- `getLeaderboard()` - Get player rankings
- `initializePlayer(player)` - Set up player economy

### 4. ServerScriptService/LobbyManager.lua (5316 bytes)
**Purpose:** Lobby management and ready system
**Key Functions:**
- `initializePlayer(player)` - Register new player
- `setReady(player, ready)` - Set player ready status
- `startCountdown()` - Begin game countdown
- `notifyGameStart()` - Notify players game is starting
- `getReadyCount()` - Count ready players

### 5. ServerScriptService/MiniGameRegistry.lua (10531 bytes)
**Purpose:** Registry and manager for all mini-games
**Mini-Games:**
- DiceBattle - Roll dice, highest wins
- NumberGuess - Guess number 1-100
- PaperScissorsRock - Classic RPS game
**Key Functions:**
- `registerGame(name, gameClass)` - Register a mini-game
- `getGame(name)` - Get a specific game
- `getAllGames()` - Get all registered games
- `selectRandomGame()` - Pick random mini-game

### 6. ServerScriptService/GameInit.lua (2840 bytes)
**Purpose:** Game initialization
**Key Functions:**
- `start()` - Initialize and start the game
- `stop()` - Stop and cleanup the game
- `setup()` - Create game instance

## Shared Modules (2 files)

### ReplicatedStorage/SharedModules/GameState.lua (1081 bytes)
**Purpose:** Shared game state management
**Key Functions:**
- `new()` - Create new state instance
- `getState()` - Get current state
- `setState(state)` - Change state
- `isState(state)` - Check current state

### ReplicatedStorage/SharedModules/PlayerData.lua (2341 bytes)
**Purpose:** Player-specific data management
**Key Functions:**
- `new(player)` - Create new player data
- `addBalance(amount)` - Add to balance
- `deductBalance(amount)` - Deduct from balance
- `setJail()` - Set jail status
- `addItem(item)` - Add to inventory
- `getItemCount(itemId)` - Get item count
- `getBalance()` - Get player balance

## Client-Side Scripts (1 file)

### StarterPlayer/StarterPlayerScripts/ClientUI.lua (14944 bytes)
**Purpose:** Main client UI system
**Features:**
- Lobby UI with player list and ready buttons
- Mini-game UI with input fields
- Economy UI with balance display
- Event handlers for all game events
- Countdown display

## Remote Events (5 files)

### ReplicatedStorage/RemoteEvents/LobbyEvents.lua (981 bytes)
Events:
- PlayerJoined (ClientEvent)
- ReadyStatusChanged (ClientEvent)
- LobbyFull (ClientEvent)
- GameStarting (ClientEvent)
- PlayerReady (ServerEvent)
- ReadyToStart (ServerEvent)
- ReadyToPlay (ServerEvent)

### ReplicatedStorage/RemoteEvents/GameEvents.lua (873 bytes)
Events:
- GameStateUpdated (ClientEvent)
- RoundStarted (ClientEvent)
- MiniGameStarted (ClientEvent)
- MiniGameEnded (ClientEvent)
- GameEnded (ClientEvent)

### ReplicatedStorage/RemoteEvents/EconomyEvents.lua (925 bytes)
Events:
- BalanceChanged (ClientEvent)
- TransactionCompleted (ClientEvent)
- PaydayStarted (ClientEvent)
- PaydayEnded (ClientEvent)
- TransferMoney (ServerEvent)
- BuyItem (ServerEvent)

### ReplicatedStorage/RemoteEvents/MiniGameEvents.lua (1589 bytes)
Events:
- MiniGameStarted/Ended (ClientEvent)
- PositionChanged/BoardUpdated (ClientEvent)
- TurnStarted/Ended (ClientEvent)
- ItemUseResult (ClientEvent)
- ChatMessageReceived (ClientEvent)
- MoveDiceRoll (ServerEvent)
- BuySpace/UpgradeSpace (ServerEvent)
- SubmitGuess/SubmitChoice (ServerEvent)
- UseItem (ServerEvent)
- ChatMessage (ServerEvent)

## Setup Instructions

### For Rojo Users:
1. Install Rojo: `npm install -g rojo`
2. Navigate to project: `cd C:\Roblox\RobloxParty`
3. Run: `rojo serve`
4. Open Roblox Studio and connect

### Manual Setup:
1. Open Roblox Studio
2. Create a new place file
3. Create folders in Explorer:
   - ServerScriptService
   - ReplicatedStorage
   - StarterPlayer
4. Copy files from src/ to corresponding folders
5. Create RemoteEvents folders and events

## File Statistics
- **Total Files:** 17
- **Total Lines of Code:** ~40,000+ lines
- **Server Scripts:** 6 files
- **Shared Modules:** 2 files
- **Client Scripts:** 1 file
- **Remote Events:** 5 files

## Next Steps
1. Copy project to Joe's PC at `C:\Roblox\RobloxParty\`
2. Install Rojo or manually sync to Roblox Studio
3. Test in Studio and verify all RemoteEvents are created
4. Invite friends to test multiplayer
5. Customize mini-games and settings as needed

## Support
For issues or questions, check:
- README.md in project folder
- Code comments in each file
- Roblox Developer Hub for Rojo setup
