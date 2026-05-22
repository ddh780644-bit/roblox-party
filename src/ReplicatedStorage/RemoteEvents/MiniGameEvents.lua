-- MiniGameEvents
-- Remote events for mini-game management
-- Original Lua version for Roblox compatibility

local RemoteEvents = {}

-- Client events (Server sends to Client)
RemoteEvents.MiniGameEvents = {
	-- Mini-game started
	MiniGameStarted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Mini-game ended
	MiniGameEnded = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Player position changed on board
	PositionChanged = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Board state updated
	BoardUpdated = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Player turn started
	TurnStarted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Player turn ended
	TurnEnded = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Item use result
	ItemUseResult = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Chat message received
	ChatMessageReceived = Instance.new("RemoteEvent", RemoteEvents)
}

-- Server events (Client sends to Server)
RemoteEvents.ServerEvents = {
	-- Dice roll result (for board games)
	MoveDiceRoll = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Buy a board space
	BuySpace = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Upgrade a board space
	UpgradeSpace = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Submit a number guess
	SubmitGuess = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Submit a choice (for Rock-Paper-Scissors)
	SubmitChoice = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Use an item
	UseItem = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Send a chat message
	ChatMessage = Instance.new("RemoteEvent", RemoteEvents)
}

return RemoteEvents
