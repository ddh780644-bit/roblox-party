-- PlayerData.luau
-- Manages individual player data for the Roblox Party Game
-- Shared module that can be required on both server and client
-- Luau type-annotated version

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
function PlayerData.new(player: Instance): PlayerData
	return setmetatable({
		UserId = player.UserId :: number,
		Name = player.Name :: string,
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

return {
	PlayerData = PlayerData,
	new = PlayerData.new
}
