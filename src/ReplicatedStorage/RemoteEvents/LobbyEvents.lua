-- LobbyEvents
-- Remote events for lobby management
-- Original Lua version for Roblox compatibility

local RemoteEvents = {}

-- Client events (Server sends to Client)
RemoteEvents.LobbyEvents = {
	-- Notifies when a player joins or leaves the lobby
	PlayerJoined = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Player ready status has changed
	ReadyStatusChanged = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Lobby has reached maximum capacity
	LobbyFull = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Game countdown before starting
	GameStarting = Instance.new("RemoteEvent", RemoteEvents)
}

-- Server events (Client sends to Server)
RemoteEvents.ServerEvents = {
	-- Player indicates they're ready to play
	PlayerReady = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Player clicks ready to start game
	ReadyToStart = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Player clicks ready to play mini-game
	ReadyToPlay = Instance.new("RemoteEvent", RemoteEvents)
}

return RemoteEvents
