-- GameEvents.luau
-- Remote events for game state management
-- Luau type-annotated version

-- Event types for RemoteEvents
type RemoteEvent = {
	Name: string,
	Parent: Instance
}

type ServerToClientEvents = {
	GameStateUpdated: RemoteEvent,
	RoundStarted: RemoteEvent,
	MiniGameStarted: RemoteEvent,
	MiniGameEnded: RemoteEvent,
	GameEnded: RemoteEvent,
	MiniGameSelected: RemoteEvent
}

type ClientToServerEvents = {
	ReadyToStart: RemoteEvent,
	ReadyToPlay: RemoteEvent
}

type GameEventsTable = {
	ServerToClient: ServerToClientEvents,
	ClientToServer: ClientToServerEvents
}

-- Create RemoteEvents container
local RemoteEvents: {RemoteEvent} = {}

-- Server to Client events (Server sends to Client)
RemoteEvents.GameStateUpdated = Instance.new("RemoteEvent", RemoteEvents)
RemoteEvents.RoundStarted = Instance.new("RemoteEvent", RemoteEvents)
RemoteEvents.MiniGameStarted = Instance.new("RemoteEvent", RemoteEvents)
RemoteEvents.MiniGameEnded = Instance.new("RemoteEvent", RemoteEvents)
RemoteEvents.GameEnded = Instance.new("RemoteEvent", RemoteEvents)
RemoteEvents.MiniGameSelected = Instance.new("RemoteEvent", RemoteEvents)

-- Client to Server events (Client sends to Server)
RemoteEvents.ReadyToStart = Instance.new("RemoteEvent", RemoteEvents)
RemoteEvents.ReadyToPlay = Instance.new("RemoteEvent", RemoteEvents)

return {
	-- Server events (for server-side use)
	ServerToClient = {
		GameStateUpdated = RemoteEvents.GameStateUpdated,
		RoundStarted = RemoteEvents.RoundStarted,
		MiniGameStarted = RemoteEvents.MiniGameStarted,
		MiniGameEnded = RemoteEvents.MiniGameEnded,
		GameEnded = RemoteEvents.GameEnded,
		MiniGameSelected = RemoteEvents.MiniGameSelected
	},
	-- Client events (for client-side use)
	ClientToServer = {
		ReadyToStart = RemoteEvents.ReadyToStart,
		ReadyToPlay = RemoteEvents.ReadyToPlay
	}
}: GameEventsTable
