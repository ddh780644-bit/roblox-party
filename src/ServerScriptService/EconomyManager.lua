-- EconomyManager.lua
-- Complete implementation for player economy management

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Load remote events
local EconomyEvents = {
	BalanceChanged = RemoteEvents:WaitForChild("BalanceChanged"),
	TransactionCompleted = RemoteEvents:WaitForChild("TransactionCompleted"),
	PaydayStarted = RemoteEvents:WaitForChild("PaydayStarted"),
	PaydayEnded = RemoteEvents:WaitForChild("PaydayEnded")
}

local EconomyManager = {
	Players = {},
	Config = {
		StartingBalance = 1000,
		PaydayAmount = 100,
		PaydayInterval = 300,
		PaydayRateLimit = 30,  -- Max once per 30 seconds
		MaxBalance = 100000,
		MinTransaction = 1
	}
}

-- Security: Track last payday collection time for each player
local PaydayLastCollection = {}

local PlayerEconomy = {}

function PlayerEconomy:new(userId, name)
	local obj = {
		userId = userId,
		name = name,
		balance = self.Config.StartingBalance,
		transactions = {},
		lastPayday = os.time(),
		debt = 0
	}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function PlayerEconomy:addTransaction(type, amount, description)
	table.insert(self.transactions, {
		type = type,
		amount = amount,
		description = description,
		timestamp = os.time()
	})
	
	if type == "income" then
		self.balance = math.min(self.balance + amount, self.Config.MaxBalance)
	elseif type == "expense" then
		self.balance = math.max(self.balance - amount, 0)
	end
end

function PlayerEconomy:deduct(amount)
	if self.balance >= amount then
		self.balance = self.balance - amount
		self:addTransaction("expense", amount, "Payment")
		return true
	end
	local debtAmount = amount - self.balance
	self.balance = 0
	self.debt = self.debt + debtAmount
	self:addTransaction("expense", amount, "Payment (Debt)")
	return false
end

function PlayerEconomy:getBalance()
	return self.balance
end

function PlayerEconomy:collectPayday()
	local currentTime = os.time()
	if currentTime - self.lastPayday >= self.Config.PaydayInterval then
		self.balance = self.balance + self.Config.PaydayAmount
		self.lastPayday = currentTime
		self:addTransaction("income", self.Config.PaydayAmount, "Payday")
		EconomyEvents.BalanceChanged:FireClient(self.userId, self.balance)
		return true
	end
	return false
end

function EconomyManager:getPlayerEconomy(player)
	return self.Players[player.UserId]
end

function EconomyManager:transfer(player, targetPlayer, amount)
	local sourceEconomy = self.Players[player.UserId]
	local targetEconomy = self.Players[targetPlayer.UserId]
	
	if not sourceEconomy or not targetEconomy then
		return false, "Player not found"
	end
	
	if amount < self.Config.MinTransaction then
		return false, "Amount too small"
	end
	
	if amount > 10000 then
		-- Large transaction validation - log for review
		print(("[Economy] Large transfer detected: %s -> %s for $%d"):format(player.Name, targetPlayer.Name, amount))
	end
	
	if sourceEconomy:getBalance() < amount then
		return false, "Insufficient balance"
	end
	
	sourceEconomy:deduct(amount)
	targetEconomy:addTransaction("income", amount, "Received from " .. player.Name)
	
	EconomyEvents.TransactionCompleted:FireClient(player, {
		type = "transfer_sent",
		target = targetPlayer.Name,
		amount = amount
	})
	
	EconomyEvents.TransactionCompleted:FireClient(targetPlayer, {
		type = "transfer_received",
		sender = player.Name,
		amount = amount
	})
	
	return true, "Transfer successful"
end

function EconomyManager:buyItem(player, item)
	local economy = self.Players[player.UserId]
	if not economy then
		return false, "Player not found"
	end
	
	if not item or not item.price then
		return false, "Invalid item"
	end
	
	if item.price < 0 then
		return false, "Invalid price"
	end
	
	if economy:getBalance() < item.price then
		return false, "Insufficient balance"
	end
	
	economy:deduct(item.price)
	
	EconomyEvents.TransactionCompleted:FireClient(player, {
		type = "purchase",
		item = item.name,
		amount = item.price
	})
	
	return true, "Purchase successful"
end

function EconomyManager:collectPayday(player)
	local economy = self.Players[player.UserId]
	if not economy then
		return false, "Player not found"
	end
	
	-- Rate limiting: prevent collecting payday more than once per configured interval
	local currentTime = os.time()
	local lastCollection = PaydayLastCollection[player.UserId] or 0
	
	if currentTime - lastCollection < self.Config.PaydayRateLimit then
		return false, "Payday too recent, wait " .. (self.Config.PaydayRateLimit - (currentTime - lastCollection)) .. " seconds"
	end
	
	-- Check if payday is ready based on interval
	if currentTime - economy.lastPayday < self.Config.PaydayInterval then
		return false, "Payday not ready"
	end
	
	-- Update last collection time
	PaydayLastCollection[player.UserId] = currentTime
	
	-- Collect payday
	economy.balance = economy.balance + self.Config.PaydayAmount
	economy.lastPayday = currentTime
	economy:addTransaction("income", self.Config.PaydayAmount, "Payday")
	
	EconomyEvents.BalanceChanged:FireClient(player, economy:getBalance())
	
	return true, "Payday collected"
end

function EconomyManager:getLeaderboard()
	local leaderboard = {}
	for _, economy in pairs(self.Players) do
		table.insert(leaderboard, {
			name = economy.name,
			balance = economy:getBalance()
		})
	end
	
	table.sort(leaderboard, function(a, b)
		return a.balance > b.balance
	end)
	
	return leaderboard
end

function EconomyManager:initializePlayer(player)
	local economy = PlayerEconomy:new(player.UserId, player.Name)
	self.Players[player.UserId] = economy
	EconomyEvents.BalanceChanged:FireClient(player, economy:getBalance())
end

function EconomyManager:setup()
	for _, player in ipairs(Players:GetPlayers()) do
		self:initializePlayer(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		self:initializePlayer(player)
	end)
end

return {
	EconomyManager = EconomyManager,
	PlayerEconomy = PlayerEconomy,
	setup = function()
		EconomyManager:setup()
	end,
	getPlayerEconomy = function(player)
		return EconomyManager:getPlayerEconomy(player)
	end,
	buyItem = function(player, item)
		return EconomyManager:buyItem(player, item)
	end,
	collectPayday = function(player)
		return EconomyManager:collectPayday(player)
	end
}
