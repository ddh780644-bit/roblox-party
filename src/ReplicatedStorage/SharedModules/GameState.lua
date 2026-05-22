-- GameState.lua
-- Shared state management for Roblox Party Game
-- Can be required on both server and client

local GameState = {
	-- Base class with methods
	getState = function(self)
		return self.State
	end,
	
	setState = function(self, newState)
		self.State = newState
		print(("GameState changed to: %s"):format(newState))
	end,
	
	isState = function(self, state)
		return self.State == state
	end,
	
	isLobby = function(self)
		return self:isState("LOBBY")
	end,
	
	isRound = function(self)
		return self:isState("ROUND")
	end,
	
	isMiniGame = function(self)
		return self:isState("MINIGAME")
	end,
	
	isEnded = function(self)
		return self:isState("ENDED")
	end
}

return {
	new = function()
		return setmetatable({
			State = "LOBBY",
			States = {
				LOBBY = "LOBBY",
				ROUND = "ROUND",
				MINIGAME = "MINIGAME",
				ENDED = "ENDED"
			}
		}, {__index = GameState})
	end,
	
	getState = function()
		local instance = GameState.new()
		return instance:getState()
	end,
	
	setState = function(state)
		local instance = GameState.new()
		instance:setState(state)
		return instance
	end,
	
	isState = function(state)
		local instance = GameState.new()
		return instance:isState(state)
	end
}
