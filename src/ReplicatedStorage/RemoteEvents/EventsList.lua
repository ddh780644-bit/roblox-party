-- RemoteEvents.lua
-- Remote events for Roblox Party Game
-- This is a placeholder - actual RemoteEvents should be created in ReplicatedStorage

-- Events list:
-- LobbyEvents:
--   - PlayerJoined (ClientEvent) - Notifies when a player joins/leaves lobby
--   - PlayerReady (ServerEvent) - Player indicates they're ready
--   - ReadyStatusChanged (ClientEvent) - Updated ready status
--   - LobbyFull (ClientEvent) - Lobby has reached max capacity
--   - GameStarting (ClientEvent) - Game countdown before starting
--
-- GameEvents:
--   - ReadyToStart (ServerEvent) - Player ready to start game
--   - ReadyToPlay (ServerEvent) - Player ready to play mini-game
--   - RoundStarted (ClientEvent) - Round has started
--   - MiniGameStarted (ClientEvent) - Mini-game has started
--   - MiniGameEnded (ClientEvent) - Mini-game has ended
--   - GameEnded (ClientEvent) - Entire game has ended
--   - MiniGameSelected (ClientEvent) - Selected mini-game name
--
-- EconomyEvents:
--   - BalanceChanged (ClientEvent) - Player balance updated
--   - TransactionCompleted (ClientEvent) - Transaction finished
--   - PaydayStarted (ClientEvent) - Payday collection started
--   - PaydayEnded (ClientEvent) - Payday collection ended
--
-- MiniGameEvents:
--   - MoveDiceRoll (ServerEvent) - Player rolled dice
--   - PositionChanged (ClientEvent) - Player moved
--   - BoardUpdated (ClientEvent) - Board state updated
--   - TurnStarted (ClientEvent) - Player turn started
--   - TurnEnded (ClientEvent) - Player turn ended
--
-- ItemEvents:
--   - UseItem (ServerEvent) - Player used item
--   - ItemUseResult (ClientEvent) - Item use result
--
-- CommunicationEvents:
--   - ChatMessage (ServerEvent) - Player sent chat message
--   - ChatMessageReceived (ClientEvent) - Chat message received
--   - PlayerMessage (ClientEvent) - Message to specific player

return {
	-- Client events (Server sends to Client)
	ClientEvents = {
		-- Lobby
		"PlayerJoined",
		"ReadyStatusChanged",
		"LobbyFull",
		"GameStarting",
		"RoundStarted",
		"MiniGameStarted",
		"MiniGameEnded",
		"GameEnded",
		"MiniGameSelected",
		-- Economy
		"BalanceChanged",
		"TransactionCompleted",
		"PaydayStarted",
		"PaydayEnded",
		-- Board/Game
		"PositionChanged",
		"BoardUpdated",
		"TurnStarted",
		"TurnEnded",
		-- Items
		"ItemUseResult",
		-- Chat
		"ChatMessageReceived",
		"PlayerMessage"
	},
	
	-- Server events (Client sends to Server)
	ServerEvents = {
		-- Lobby
		"PlayerReady",
		"ReadyToStart",
		"ReadyToPlay",
		-- Board/Game
		"MoveDiceRoll",
		"BuySpace",
		"UpgradeSpace",
		"SubmitGuess",
		"SubmitChoice",
		-- Items
		"UseItem",
		-- Chat
		"ChatMessage"
	}
}
