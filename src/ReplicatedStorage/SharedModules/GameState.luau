-- GameState.luau
-- Shared state management for Roblox Party Game
-- Can be required on both server and client
-- Luau type-annotated version

type GameStateType = "LOBBY" | "ROUND" | "MINIGAME" | "ENDED"

type GameState = {
	State: GameStateType,
	States: {
		LOBBY: "LOBBY",
		ROUND: "ROUND",
		MINIGAME: "MINIGAME",
		ENDED: "ENDED"
	},
	
	-- Methods
	getState: (self: GameState) -> GameStateType,
	setState: (self: GameState, newState: GameStateType) -> (),
	isState: (self: GameState, state: GameStateType) -> boolean,
	isLobby: (self: GameState) -> boolean,
	isRound: (self: GameState) -> boolean,
	isMiniGame: (self: GameState) -> boolean,
	isEnded: (self: GameState) -> boolean
}

local GameState = {
	State = "LOBBY",
	States = {
		LOBBY = "LOBBY",
		ROUND = "ROUND",
		MINIGAME = "MINIGAME",
		ENDED = "ENDED"
	}
}

-- Methods
function GameState:getState(): GameStateType
	return self.State
end

function GameState:setState(newState: GameStateType)
	self.State = newState
	print(string.format("GameState changed to: %s", newState))
end

function GameState:isState(state: GameStateType): boolean
	return self.State == state
end

function GameState:isLobby(): boolean
	return self:isState("LOBBY")
end

function GameState:isRound(): boolean
	return self:isState("ROUND")
end

function GameState:isMiniGame(): boolean
	return self:isState("MINIGAME")
end

function GameState:isEnded(): boolean
	return self:isState("ENDED")
end

return {
	-- Factory function
	new = function(): GameState
		return setmetatable({
			State = "LOBBY",
			States = GameState.States
		}, {__index = GameState})
	end,
	
	-- Static methods (for convenience)
	getState = function(): GameStateType
		local instance = GameState.new()
		return instance:getState()
	end,
	
	setState = function(state: GameStateType)
		local instance = GameState.new()
		instance:setState(state)
		return instance
	end,
	
	isState = function(state: GameStateType): boolean
		local instance = GameState.new()
		return instance:isState(state)
	end
}
