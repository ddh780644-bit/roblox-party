-- ===== Shared Modules =====
-- All shared modules consolidated into this single file
-- Exports: { GameState = ..., PlayerData = ... }

local SharedModules = {}

-- ============================================
-- ===== GameState =====
-- ============================================

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

SharedModules.GameState = {
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

-- ============================================
-- ===== PlayerData =====
-- ============================================

type PlayerId = number
type PlayerName = string
type Balance = number

type PlayerItem = {
	id: string,
	quantity: number
}

type PlayerInventory = {
	Items: {string: number},
	Inventory: {PlayerItem}
}

type PlayerStats = {
	gamesPlayed: number,
	gamesWon: number,
	totalEarnings: number
}

type PlayerData = {
	UserId: PlayerId,
	Name: PlayerName,
	Balance: Balance,
	Position: number,
	Items: {string: number},
	Inventory: {PlayerItem},
	Stats: PlayerStats,
	isReady: boolean,
	isJail: boolean,
	skipTurn: boolean,
	jailTurns: number,
	
	-- Methods
	addBalance: (self: PlayerData, amount: number) -> Balance,
	deductBalance: (self: PlayerData, amount: number) -> boolean,
	setJail: (self: PlayerData) -> (),
	setSkipTurn: (self: PlayerData, skip: boolean) -> (),
	addItem: (self: PlayerData, item: PlayerItem) -> (),
	removeItem: (self: PlayerData, itemId: string, quantity: number?) -> boolean,
	getItemCount: (self: PlayerData, itemId: string) -> number,
	getBalance: (self: PlayerData) -> Balance,
	updateStats: (self: PlayerData, stats: PlayerStats) -> (),
	getStats: (self: PlayerData) -> PlayerStats
}

local PlayerData = {
	-- Methods
	addBalance = function(self: PlayerData, amount: number): Balance
		self.Balance = self.Balance + amount
		return self.Balance
	end,
	
	deductBalance = function(self: PlayerData, amount: number): boolean
		if self.Balance >= amount then
			self.Balance = self.Balance - amount
			return true
		else
			return false
		end
	end,
	
	setJail = function(self: PlayerData)
		self.isJail = true
		self.jailTurns = 3
	end,
	
	setSkipTurn = function(self: PlayerData, skip: boolean)
		self.skipTurn = skip
	end,
	
	addItem = function(self: PlayerData, item: PlayerItem)
		if not self.Items[item.id] then
			self.Items[item.id] = 0
		end
		self.Items[item.id] = self.Items[item.id] + 1
		table.insert(self.Inventory, item)
	end,
	
	removeItem = function(self: PlayerData, itemId: string, quantity: number?): boolean
		quantity = quantity or 1
		if self.Items[itemId] and self.Items[itemId] >= quantity then
			self.Items[itemId] = self.Items[itemId] - quantity
			if self.Items[itemId] <= 0 then
				self.Items[itemId] = nil
			end
			return true
		end
		return false
	end,
	
	getItemCount = function(self: PlayerData, itemId: string): number
		return self.Items[itemId] or 0
	end,
	
	getBalance = function(self: PlayerData): Balance
		return self.Balance
	end,
	
	updateStats = function(self: PlayerData, stats: PlayerStats)
		for key, value in pairs(stats) do
			if self.Stats[key] then
				self.Stats[key] = self.Stats[key] + value
			end
		end
	end,
	
	getStats = function(self: PlayerData): PlayerStats
		return self.Stats
	end
}

-- Factory function
function PlayerData.new(player)
	return setmetatable({
		UserId = player.UserId,
		Name = player.Name,
		Balance = 1000,
		Position = 1,
		Items = {},
		Inventory = {},
		Stats = {
			gamesPlayed = 0,
			gamesWon = 0,
			totalEarnings = 0
		},
		isReady = false,
		isJail = false,
		skipTurn = false,
		jailTurns = 0
	}, {
		__index = PlayerData
	})
end

SharedModules.PlayerData = {
	PlayerData = PlayerData,
	new = PlayerData.new
}

-- ============================================
-- ===== Exports =====
-- ============================================

return SharedModules
