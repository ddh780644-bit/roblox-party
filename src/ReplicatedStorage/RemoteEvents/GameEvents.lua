-- GameEvents
-- Remote events for game state management

local RemoteEvents = {}

-- Client events (Server sends to Client)
RemoteEvents.GameEvents = {
	-- Game state changed
	GameStateUpdated = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Round has started
	RoundStarted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Mini-game has started
	MiniGameStarted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Mini-game has ended
	MiniGameEnded = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Entire game has ended
	GameEnded = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Selected mini-game name
	MiniGameSelected = Instance.new("RemoteEvent", RemoteEvents)
}

-- Server events (Client sends to Server)
RemoteEvents.ServerEvents = {
	-- Ready to start game
	ReadyToStart = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Ready to play mini-game
	ReadyToPlay = Instance.new("RemoteEvent", RemoteEvents)
}

return RemoteEvents
