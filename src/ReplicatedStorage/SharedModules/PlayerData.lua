-- PlayerData.lua
-- Manages individual player data for the Roblox Party Game
-- Shared module that can be required on both server and client

local ReplicatedStorage = game and game:GetService("ReplicatedStorage")

local PlayerData = {
	-- Methods
	addBalance = function(self, amount)
		self.Balance = self.Balance + amount
		return self.Balance
	end,
	
	-- Deduct balance
	deductBalance = function(self, amount)
		if self.Balance >= amount then
			self.Balance = self.Balance - amount
			return true
		else
			return false
		end
	end,
	
	-- Set jail state
	setJail = function(self)
		self.isJail = true
		self.jailTurns = 3
	end,
	
	-- Set skip turn
	setSkipTurn = function(self, skip)
		self.skipTurn = skip
	end,
	
	-- Add item to inventory
	addItem = function(self, item)
		if not self.Items[item.id] then
			self.Items[item.id] = 0
		end
		self.Items[item.id] = self.Items[item.id] + 1
		table.insert(self.Inventory, item)
	end,
	
	-- Remove item from inventory
	removeItem = function(self, itemId, quantity)
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
	
	-- Get item count
	getItemCount = function(self, itemId)
		return self.Items[itemId] or 0
	end,
	
	-- Get balance
	getBalance = function(self)
		return self.Balance
	end,
	
	-- Update stats
	updateStats = function(self, stats)
		for key, value in pairs(stats) do
			if self.Stats[key] then
				self.Stats[key] = self.Stats[key] + value
			end
		end
	end,
	
	-- Get total stats
	getStats = function(self)
		return self.Stats
	end
}

function PlayerData.new(player)
	local obj = {
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
		skipTurn = false
	}
	setmetatable(obj, {
		__index = PlayerData
	})
	return obj
end

return {
	PlayerData = PlayerData,
	new = PlayerData.new
}
