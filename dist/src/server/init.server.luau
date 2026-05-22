-- ===== Server Initialization =====
-- Main server entry point for Roblox Party Game
-- This file contains ALL server-side code consolidated from:
--   - GameManager
--   - BoardManager
--   - EconomyManager
--   - LobbyManager
--   - MiniGameRegistry

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Load shared modules
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local GameState = require(SharedModules:WaitForChild("GameState"))
local PlayerData = require(SharedModules:WaitForChild("PlayerData"))

-- Load remote events
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- ============================================
-- ===== GameManager =====
-- ============================================

-- Import remote events
local GameEvents = {
	ReadyToStart = RemoteEvents:WaitForChild("ReadyToStart"),
	ReadyToPlay = RemoteEvents:WaitForChild("ReadyToPlay"),
	RoundStarted = RemoteEvents:WaitForChild("RoundStarted"),
	MiniGameStarted = RemoteEvents:WaitForChild("MiniGameStarted"),
	MiniGameEnded = RemoteEvents:WaitForChild("MiniGameEnded"),
	GameEnded = RemoteEvents:WaitForChild("GameEnded"),
	MiniGameSelected = RemoteEvents:WaitForChild("MiniGameSelected")
}

-- GameManager table
local GameManager = {
	State = GameState.new(),
	MiniGameRegistry = nil,
	MiniGames = {},
	Players = {},
	Config = {
		MaxPlayers = 12,
		MinPlayers = 2,
		RoundTime = 30,
		BetAmount = 100
	}
}

-- Player events
function GameManager:onPlayerAdded(player)
	local playerData = PlayerData.new(player)
	self.Players[player.UserId] = playerData
	
	print(("Player %s joined (ID: %d)"):format(player.Name, player.UserId))
	
	-- Send current game state to new player
	local playerState = self.State:getState()
	GameEvents.JoinResponse:FireClient(player, playerState)
end

function GameManager:onPlayerRemoved(player)
	if self.Players[player.UserId] then
		local data = self.Players[player.UserId]
		data = nil
		self.Players[player.UserId] = nil
		print(("Player %s left (ID: %d)"):format(player.Name, player.UserId))
	end
end

-- Game state management
function GameManager:startLobby()
	self.State:setState("LOBBY")
	print("Lobby started - waiting for players...")
	
	-- Notify all players
	for _, player in ipairs(Players:GetPlayers()) do
		GameEvents.LobbyStarted:FireClient(player)
	end
end

function GameManager:startRound()
	if #Players:GetPlayers() < self.Config.MinPlayers then
		print(("Not enough players! Need at least %d"):format(self.Config.MinPlayers))
		return false
	end
	
	self.State:setState("ROUND")
	print("Round started!")
	
	-- Select a mini-game
	local selectedGame = self.MiniGameRegistry:selectRandomGame()
	if not selectedGame then
		print("No mini-games available!")
		return false
	end
	
	-- Start the mini-game
	return self:startMiniGame(selectedGame)
end

function GameManager:startMiniGame(gameName)
	local miniGame = self.MiniGameRegistry:getGame(gameName)
	if not miniGame then
		print(("Mini-game %s not found!"):format(gameName))
		return false
	end
	
	self.State:setState("MINIGAME")
	self.CurrentMiniGame = miniGame
	
	print(("Starting mini-game: %s"):format(gameName))
	
	-- Initialize mini-game
	miniGame:init()
	
	-- Notify players
	for _, player in ipairs(Players:GetPlayers()) do
		local playerData = self.Players[player.UserId]
		if playerData then
			miniGame:playerJoin(player)
		end
	end

	-- Start mini-game
	miniGame:start()
	
	return true
end

function GameManager:endMiniGame()
	if not self.CurrentMiniGame then
		print("No mini-game running!")
		return
	end
	
	local miniGame = self.CurrentMiniGame
	miniGame:endGame()
	
	print(("Mini-game %s ended"):format(miniGame.Name))
	
	-- Reward winners
	for _, player in ipairs(Players:GetPlayers()) do
		local playerData = self.Players[player.UserId]
		if playerData then
			local result = miniGame:getPlayerResult(player)
			if result.won then
				playerData:addBalance(self.Config.BetAmount * 2)
			end
		end
	end
	
	-- Check if game should continue
	if self:getPlayerCount() < self.Config.MinPlayers then
		self:endGame()
	else
		task.delay(self.Config.RoundTime, function()
			self:startRound()
		end)
	end
end

function GameManager:endGame()
	self.State:setState("ENDED")
	print("Game ended!")
	
	-- Distribute final prizes
	local sortedPlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local playerData = self.Players[player.UserId]
		if playerData then
			table.insert(sortedPlayers, {
				name = player.Name,
				balance = playerData:getBalance()
			})
		end
	end
	
	table.sort(sortedPlayers, function(a, b)
		return a.balance > b.balance
	end)
	
	-- Show leaderboard
	print("=== LEADERBOARD ===")
	for i, player in ipairs(sortedPlayers) do
		print(("%d. %s: $%d"):format(i, player.name, player.balance))
	end
	
	-- Notify players
	for _, player in ipairs(Players:GetPlayers()) do
		GameEvents.GameEnded:FireClient(player, sortedPlayers)
	end
end

-- Utility functions
function GameManager:getPlayerCount()
	return #Players:GetPlayers()
end

function GameManager:isPlayerReady(player)
	local playerData = self.Players[player.UserId]
	return playerData and playerData.isReady
end

function GameManager:readyPlayer(player)
	local playerData = self.Players[player.UserId]
	if playerData then
		playerData.isReady = true
	end
end

-- Setup function
function GameManager:setup()
	local instance = setmetatable({}, {__index = GameManager})
	instance.MiniGames = instance.MiniGameRegistry:getAllGames()
	instance:startLobby()
	return instance
end

-- Event connections
Players.PlayerAdded:Connect(function(player)
	if GameManager.Instance then
		GameManager.Instance:onPlayerAdded(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if GameManager.Instance then
		GameManager.Instance:onPlayerRemoved(player)
	end
end)

-- Exports
local function GameManager_exports()
	return {
		setup = function()
			return GameManager.setup()
		end,
		getPlayerCount = function()
			return GameManager.Instance and GameManager.Instance:getPlayerCount() or 0
		end,
		readyPlayer = function(player)
			if GameManager.Instance then
				GameManager.Instance:readyPlayer(player)
			end
		end
	}
end


-- ============================================
-- ===== BoardManager =====
-- ============================================

-- Services
local BoardRemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Board events
local BoardEvents = {
	TurnStarted = BoardRemoteEvents:WaitForChild("TurnStarted"),
	TurnEnded = BoardRemoteEvents:WaitForChild("TurnEnded"),
	MovementStarted = BoardRemoteEvents:WaitForChild("MovementStarted"),
	MovementEnded = BoardRemoteEvents:WaitForChild("MovementEnded"),
	PositionChanged = BoardRemoteEvents:WaitForChild("PositionChanged"),
	BoardUpdated = BoardRemoteEvents:WaitForChild("BoardUpdated")
}

-- BoardManager table
local BoardManager = {
	Board = {
		Spaces = {},
		Size = 40,
		JailPosition = 10,
		StartPosition = 1,
		FinalPosition = 40
	},
	Players = {},
	Config = {
		BoardSize = 40,
		DiceMin = 1,
		DiceMax = 6,
		FreePassageCost = 50,
		LandingReward = 25
	}
}

-- Board space types
local SpaceTypes = {
	START = "Start",
	NORMAL = "Normal",
	CHANCE = "Chance",
	BONUS = "Bonus",
	JAIL = "Jail",
	FREE = "Free",
	FINISH = "Finish"
}

function BoardManager:initBoard()
	-- Create spaces
	for i = 1, self.Config.BoardSize do
		self.Board.Spaces[i] = {
			id = i,
			type = self:getSpaceType(i),
			owners = {},
			lvl = 0,
			basePrice = self:getSpaceBasePrice(i)
		}
	end
end

function BoardManager:getSpaceType(index)
	if index == self.Config.StartPosition then
		return SpaceTypes.START
	elseif index == self.Config.JailPosition then
		return SpaceTypes.JAIL
	elseif index == self.Config.FinalPosition then
		return SpaceTypes.FINISH
	elseif index % 5 == 0 then
		return SpaceTypes.CHANCE
	elseif index % 4 == 0 then
		return SpaceTypes.BONUS
	elseif index % 3 == 0 then
		return SpaceTypes.FREE
	else
		return SpaceTypes.NORMAL
	end
end

function BoardManager:getSpaceBasePrice(index)
	local base = 100
	if self.Board.Spaces[index].type == SpaceTypes.CHANCE then
		return base * 1.5
	elseif self.Board.Spaces[index].type == SpaceTypes.BONUS then
		return base * 2
	elseif self.Board.Spaces[index].type == SpaceTypes.FREE then
		return base * 0.5
	else
		return base
	end
end

function BoardManager:movePlayer(player, spaces)
	local playerData = self.Players[player.UserId]
	if not playerData then
		return false
	end
	
	-- Calculate new position
	local newPos = playerData.position + spaces
	
	-- Handle wrap-around
	if newPos > self.Config.BoardSize then
		newPos = newPos - self.Config.BoardSize
		-- Give start bonus
		playerData:addBalance(self.Config.LandingReward)
	end
	
	-- Update position
	playerData.position = newPos
	
	-- Notify players
	for _, p in ipairs(Players:GetPlayers()) do
		local pd = self.Players[p.UserId]
		if pd then
			BoardEvents.PositionChanged:FireClient(p, {
				playerName = player.Name,
				newPosition = newPos
			})
		end
	end
	
	-- Process landed space
	self:processSpace(player, newPos)
	
	return true
end

function BoardManager:processSpace(player, position)
	local space = self.Board.Spaces[position]
	local playerData = self.Players[player.UserId]
	
	if not space or not playerData then
		return
	end
	
	-- Process based on space type
	if space.type == SpaceTypes.CHANCE then
		self:handleChance(player)
	elseif space.type == SpaceTypes.BONUS then
		playerData:addBalance(self.Config.LandingReward * 2)
	elseif space.type == SpaceTypes.FREE then
		-- Free passage - no cost
	elseif space.type == SpaceTypes.JAIL then
		-- Jail logic
		playerData:setJail()
	end
	
	-- Notify board update
	for _, p in ipairs(Players:GetPlayers()) do
		BoardEvents.BoardUpdated:FireClient(p, self:getBoardState())
	end
end

function BoardManager:handleChance(player)
	local playerData = self.Players[player.UserId]
	if not playerData then
		return
	end
	
	-- Generate random chance event
	local chanceType = math.random(1, 3)
	
	if chanceType == 1 then
		-- Pay 50
		playerData:deductBalance(50)
		print(("Player %s paid $50 from Chance space"):format(player.Name))
	elseif chanceType == 2 then
		-- Get 50
		playerData:addBalance(50)
		print(("Player %s got $50 from Chance space"):format(player.Name))
	else
		-- Skip turn
		playerData:setSkipTurn(true)
		print(("Player %s skipped turn from Chance space"):format(player.Name))
	end
end

function BoardManager:buySpace(player, position)
	local space = self.Board.Spaces[position]
	local playerData = self.Players[player.UserId]
	
	if not space or not playerData then
		return false
	end
	
	-- Check if already owned
	if #space.owners > 0 then
		for _, owner in ipairs(space.owners) do
			if owner == player.UserId then
				return false -- Already owned
			end
		end
	end
	
	-- Check if player can afford
	if playerData:getBalance() < space.basePrice then
		return false
	end
	
	-- Complete purchase
	playerData:deductBalance(space.basePrice)
	table.insert(space.owners, player.UserId)
	
	-- Notify
	for _, p in ipairs(Players:GetPlayers()) do
		BoardEvents.PositionChanged:FireClient(p, {
			playerName = player.Name,
			spaceId = position,
			action = "buy",
			ownerId = player.UserId
		})
	end
	
	return true
end

function BoardManager:upgradeSpace(player, position)
	local space = self.Board.Spaces[position]
	local playerData = self.Players[player.UserId]
	
	if not space or not playerData then
		return false
	end
	
	-- Check if player owns this space
	local ownsSpace = false
	for _, owner in ipairs(space.owners) do
		if owner == player.UserId then
			ownsSpace = true
			break
		end
	end
	
	if not ownsSpace then
		return false
	end
	
	-- Check if can upgrade
	if space.lvl >= 3 then
		return false
	end
	
	local upgradeCost = space.basePrice * 0.5 * (space.lvl + 1)
	if playerData:getBalance() < upgradeCost then
		return false
	end
	
	-- Complete upgrade
	playerData:deductBalance(upgradeCost)
	space.lvl = space.lvl + 1
	
	-- Notify
	for _, p in ipairs(Players:GetPlayers()) do
		BoardEvents.PositionChanged:FireClient(p, {
			playerName = player.Name,
			spaceId = position,
			action = "upgrade",
			newLevel = space.lvl
		})
	end
	
	return true
end

function BoardManager:getBoardState()
	local state = {
		spaces = {},
		players = {}
	}
	
	for i, space in ipairs(self.Board.Spaces) do
		table.insert(state.spaces, {
			id = i,
			type = space.type,
			lvl = space.lvl,
			ownerCount = #space.owners
		})
	end
	
	for userId, playerData in pairs(self.Players) do
		table.insert(state.players, {
			userId = userId,
			name = Players:GetPlayerByUserId(userId) and Players:GetPlayerByUserId(userId).Name or "Unknown",
			balance = playerData:getBalance(),
			position = playerData.position
		})
	end
	
	return state
end

function BoardManager:initPlayer(player)
	self.Players[player.UserId] = {
		userId = player.UserId,
		name = player.Name,
		balance = 1000,
		position = 1,
		isJail = false,
		skipTurn = false,
		jailTurns = 0,
		
		addBalance = function(amount)
			self.balance = self.balance + amount
		end,
		
		deductBalance = function(amount)
			self.balance = math.max(0, self.balance - amount)
		end,
		
		setJail = function()
			self.isJail = true
			self.jailTurns = 3
		end,
		
		setSkipTurn = function(skip)
			self.skipTurn = skip
		end,
		
		nextTurn = function()
			if self.isJail then
				self.jailTurns = self.jailTurns - 1
				if self.jailTurns <= 0 then
					self.isJail = false
				end
				return false -- Can't move from jail
			end
			
			if self.skipTurn then
				self.skipTurn = false
				return false
			end
			
			return true
		end,
		
		getBalance = function()
			return self.balance
		end
	}
end

function BoardManager:setup()
	self:initBoard()
	
	-- Initialize existing players
	for _, player in ipairs(Players:GetPlayers()) do
		self:initPlayer(player)
	end
	
	-- Listen for new players
	Players.PlayerAdded:Connect(function(player)
		self:initPlayer(player)
	end)
end

-- Exports
local function BoardManager_exports()
	return {
		setup = function()
			BoardManager:setup()
		end,
		getBoardState = function()
			return BoardManager:getBoardState()
		end
	}
end


-- ============================================
-- ===== EconomyManager =====
-- ============================================

-- Load economy remote events
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
		PaydayRateLimit = 30,
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
	
	-- Rate limiting
	local currentTime = os.time()
	local lastCollection = PaydayLastCollection[player.UserId] or 0
	
	if currentTime - lastCollection < self.Config.PaydayRateLimit then
		return false, "Payday too recent, wait " .. (self.Config.PaydayRateLimit - (currentTime - lastCollection)) .. " seconds"
	end
	
	-- Check if payday is ready
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

-- Exports
local function EconomyManager_exports()
	return {
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
end


-- ============================================
-- ===== LobbyManager =====
-- ============================================

-- Lobby remote events
local LobbyEvents = {
	PlayerJoined = RemoteEvents:WaitForChild("PlayerJoined"),
	PlayerReady = RemoteEvents:WaitForChild("PlayerReady"),
	ReadyStatusChanged = RemoteEvents:WaitForChild("ReadyStatusChanged"),
	LobbyFull = RemoteEvents:WaitForChild("LobbyFull"),
	GameStarting = RemoteEvents:WaitForChild("GameStarting")
}

local LobbyManager = {
	Players = {},
	Config = {
		MaxPlayers = 12,
		MinPlayers = 2,
		ReadyCountdown = 5,
		CountdownInterval = 1
	}
}

function LobbyManager:getPlayerCount()
	return #Players:GetPlayers()
end

function LobbyManager:isLobbyFull()
	return self:getPlayerCount() >= self.Config.MaxPlayers
end

function LobbyManager:canStart()
	return self:getPlayerCount() >= self.Config.MinPlayers
end

function LobbyManager:getReadyCount()
	local count = 0
	for userId, playerData in pairs(self.Players) do
		if playerData.isReady then
			count = count + 1
		end
	end
	return count
end

function LobbyManager:getReadyPercentage()
	local ready = self:getReadyCount()
	local total = self:getPlayerCount()
	if total == 0 then
		return 0
	end
	return math.floor(ready / total * 100)
end

function LobbyManager:initializePlayer(player)
	local playerData = {
		userId = player.UserId,
		name = player.Name,
		isReady = false,
		isHost = false,
		joinTime = os.time()
	}
	
	self.Players[player.UserId] = playerData
	
	-- Default first player as host
	if #Players:GetPlayers() == 1 then
		playerData.isHost = true
	end
	
	-- Notify all players
	for _, p in ipairs(Players:GetPlayers()) do
		LobbyEvents.PlayerJoined:FireClient(p, {
			name = player.Name,
			userId = player.UserId,
			isHost = playerData.isHost
		})
	end
	
	-- Notify new player
	LobbyEvents.PlayerJoined:FireClient(player, {
		name = player.Name,
		userId = player.UserId,
		isHost = playerData.isHost,
		currentPlayers = #Players:GetPlayers(),
		maxPlayers = self.Config.MaxPlayers
	})
end

function LobbyManager:setReady(player, ready)
	local playerData = self.Players[player.UserId]
	if not playerData then
		return false
	end
	
	playerData.isReady = ready
	
	-- Notify all players
	for _, p in ipairs(Players:GetPlayers()) do
		LobbyEvents.ReadyStatusChanged:FireClient(p, {
			userId = player.UserId,
			name = player.Name,
			isReady = ready,
			readyCount = self:getReadyCount(),
			readyPercentage = self:getReadyPercentage()
		})
	end
	
	return true
end

function LobbyManager:readyPlayer(player)
	return self:setReady(player, true)
end

function LobbyManager:unreadyPlayer(player)
	return self:setReady(player, false)
end

function LobbyManager:startCountdown()
	if not self:canStart() then
		return false
	end
	
	local countdownTime = self.Config.ReadyCountdown
	local readyPercentage = self:getReadyPercentage()
	
	if readyPercentage < 100 then
		countdownTime = countdownTime + math.ceil((100 - readyPercentage) / 10)
	end
	
	-- Notify all players
	for _, player in ipairs(Players:GetPlayers()) do
		LobbyEvents.GameStarting:FireClient(player, {
			countdown = countdownTime,
			readyCount = self:getReadyCount(),
			totalPlayers = #Players:GetPlayers()
		})
	end
	
	-- Start countdown
	local remaining = countdownTime
	local countdownTimer = game:GetService("RunService").Heartbeat:Connect(function()
		remaining = remaining - 1
		
		if remaining <= 0 then
			countdownTimer:Disconnect()
			self:notifyGameStart()
		else
			for _, player in ipairs(Players:GetPlayers()) do
				LobbyEvents.ReadyStatusChanged:FireClient(player, {
					countdown = remaining,
					readyCount = self:getReadyCount()
				})
			end
		end
	end)
	
	return true
end

function LobbyManager:notifyGameStart()
	for _, player in ipairs(Players:GetPlayers()) do
		LobbyEvents.GameStarting:FireClient(player, {
			countdown = 0,
			started = true
		})
	end
end

function LobbyManager:setup()
	-- Initialize existing players
	for _, player in ipairs(Players:GetPlayers()) do
		self:initializePlayer(player)
	end
	
	-- Listen for new players
	Players.PlayerAdded:Connect(function(player)
		self:initializePlayer(player)
	end)
	
	-- Listen for player removal
	Players.PlayerRemoving:Connect(function(player)
		if self.Players[player.UserId] then
			self.Players[player.UserId] = nil
			
			for _, p in ipairs(Players:GetPlayers()) do
				LobbyEvents.PlayerJoined:FireClient(p, {
					name = player.Name,
					userId = player.UserId,
					left = true
				})
			end
		end
	end)
end

-- Exports
local function LobbyManager_exports()
	return {
		setup = function()
			LobbyManager:setup()
		end,
		getPlayerCount = function()
			return LobbyManager:getPlayerCount()
		end,
		readyPlayer = function(player)
			return LobbyManager:readyPlayer(player)
		end,
		unreadyPlayer = function(player)
			return LobbyManager:unreadyPlayer(player)
		end,
		startCountdown = function()
			return LobbyManager:startCountdown()
		end
	}
end


-- ============================================
-- ===== MiniGameRegistry =====
-- ============================================

-- Mini-game definitions
local MiniGames = {}

-- Base MiniGame class
local BaseMiniGame = {
	Name = "BaseMiniGame",
	Description = "Base mini-game class",
	State = "LOBBY",
	Players = {},
	Config = {
		MinPlayers = 1,
		MaxPlayers = 4,
		Duration = 60
	},
	
	init = function(self)
		self.State = "LOBBY"
		self.Players = {}
	end,
	
	playerJoin = function(self, player)
		if #self.Players >= self.Config.MaxPlayers then
			return false
		end
		table.insert(self.Players, player)
		self:playerReady(player)
		return true
	end,
	
	playerLeave = function(self, player)
		for i, p in ipairs(self.Players) do
			if p.UserId == player.UserId then
				table.remove(self.Players, i)
				break
			end
		end
	end,
	
	playerReady = function(self, player)
	end,
	
	start = function(self)
		self.State = "PLAYING"
	end,
	
	endGame = function(self)
		self.State = "ENDED"
	end,
	
	getPlayerResult = function(self, player)
		return {
			won = false,
			score = 0
		}
	end,
	
	reset = function(self)
		self:init()
	end
}

MiniGames.BaseMiniGame = BaseMiniGame

-- Dice Battle Mini-Game
local DiceBattle = {
	Name = "DiceBattle",
	Description = "Roll dice to win! Highest roll wins the pot.",
	Config = {
		MinPlayers = 2,
		MaxPlayers = 6,
		Duration = 30,
		BetAmount = 100,
		PayoutMultiplier = 2
	},
	
	Players = {},
	BetAmount = 0,
	Results = {},
	
	init = function(self)
		BaseMiniGame.init(self)
		self.BetAmount = self.Config.BetAmount
		self.Results = {}
		self.Inputs = {}
	end,
	
	start = function(self)
		BaseMiniGame.start(self)
		local pot = self.BetAmount * #self.Players
		
		for _, player in ipairs(self.Players) do
			local roll = math.random(1, 6) + math.random(1, 6)
			self.Results[player.UserId] = {
				roll = roll,
				won = false
			}
		end
		
		local maxRoll = 0
		for _, result in pairs(self.Results) do
			if result.roll > maxRoll then
				maxRoll = result.roll
			end
		end
		
		local winners = {}
		for userId, result in pairs(self.Results) do
			if result.roll == maxRoll then
				result.won = true
				table.insert(winners, userId)
			end
		end
	end,
	
	getPlayerResult = function(self, player)
		local result = self.Results[player.UserId]
		if result then
			return {
				won = result.won,
				roll = result.roll
			}
		end
		return {
			won = false,
			roll = 0
		}
	end
}

MiniGames.DiceBattle = DiceBattle

-- Number Guess Mini-Game
local NumberGuess = {
	Name = "NumberGuess",
	Description = "Guess the number between 1-100 to win!",
	Config = {
		MinPlayers = 1,
		MaxPlayers = 10,
		Duration = 45,
		BetAmount = 50,
		WinMultiplier = 3
	},
	
	Players = {},
	TargetNumber = 0,
	Guesses = {},
	Results = {},
	
	init = function(self)
		BaseMiniGame.init(self)
		self.TargetNumber = math.random(1, 100)
		self.Guesses = {}
	end,
	
	playerReady = function(self, player)
		BaseMiniGame.playerReady(self, player)
	end,
	
	start = function(self)
		BaseMiniGame.start(self)
		local potentialWin = self.Config.BetAmount * self.Config.WinMultiplier
		
		for userId, guess in pairs(self.Guesses) do
			local result = {
				guess = guess,
				closest = false,
				exact = false,
				diff = 0
			}
			result.diff = math.abs(guess - self.TargetNumber)
			
			if guess == self.TargetNumber then
				result.exact = true
				result.closest = true
			end
			
			if not result.exact then
				local minDiff = 100
				for _, g in pairs(self.Guesses) do
					local diff = math.abs(g - self.TargetNumber)
					if diff < minDiff then
						minDiff = diff
					end
				end
				if result.diff == minDiff then
					result.closest = true
				end
			end
			
			self.Results[userId] = result
		end
	end,
	
	submitGuess = function(self, player, number)
		if type(number) ~= "number" then
			return false, "Invalid input type"
		end
		if number < 1 or number > 100 then
			return false, "Number must be between 1 and 100"
		end
		if self.State ~= "LOBBY" and self.State ~= "PLAYING" then
			return false, "Game already started"
		end
		if self.Inputs[player.UserId] then
			return false, "Guess already submitted"
		end
		self.Inputs[player.UserId] = true
		self.Guesses[player.UserId] = number
		return true, "Guess submitted"
	end,
	
	getPlayerResult = function(self, player)
		local result = self.Results[player.UserId]
		if result then
			return {
				won = result.exact,
				closest = result.closest,
				target = self.TargetNumber,
				diff = result.diff
			}
		end
		return {
			won = false
		}
	end
}

MiniGames.NumberGuess = NumberGuess

-- Paper Scissors Rock Mini-Game
local PaperScissorsRock = {
	Name = "PaperScissorsRock",
	Description = "Classic game of chance!",
	Config = {
		MinPlayers = 2,
		MaxPlayers = 4,
		Duration = 30,
		BetAmount = 75,
		PayoutMultiplier = 2
	},
	
	Players = {},
	Choices = {},
	Results = {},
	
	Options = {"PAPER", "SCISSORS", "ROCK"},
	
	init = function(self)
		BaseMiniGame.init(self)
		self.Choices = {}
		self.Results = {}
		self.Inputs = {}
	end,
	
	playerReady = function(self, player)
		BaseMiniGame.playerReady(self, player)
	end,
	
	submitChoice = function(self, player, choice)
		local choiceUpper = string.upper(choice)
		
		if not self.Options[choiceUpper] and choiceUpper ~= "PAPER" and choiceUpper ~= "SCISSORS" and choiceUpper ~= "ROCK" then
			return false, "Invalid choice"
		end
		if self.State ~= "LOBBY" and self.State ~= "PLAYING" then
			return false, "Game already started"
		end
		self.Choices[player.UserId] = choiceUpper
		return true, "Choice submitted"
	end,
	
	start = function(self)
		BaseMiniGame.start(self)
		
		local winningChoice = nil
		local winners = {}
		
		local allSame = true
		local firstChoice = nil
		for userId, choice in pairs(self.Choices) do
			if not firstChoice then
				firstChoice = choice
			elseif choice ~= firstChoice then
				allSame = false
				break
			end
		end
		
		if allSame then
			for userId in pairs(self.Choices) do
				self.Results[userId] = {
					won = true,
					refund = true
				}
			end
			return
		end
		
		local choicesSet = {}
		for choice in pairs(self.Choices) do
			choicesSet[choice] = true
		end
		
		if choicesSet["PAPER"] and choicesSet["ROCK"] and choicesSet["SCISSORS"] then
			for userId in pairs(self.Choices) do
				self.Results[userId] = {
					won = false,
					refund = false
				}
			end
			return
		end
		
		if choicesSet["PAPER"] and choicesSet["ROCK"] then
			winningChoice = "PAPER"
		elseif choicesSet["PAPER"] and choicesSet["SCISSORS"] then
			winningChoice = "SCISSORS"
		elseif choicesSet["ROCK"] and choicesSet["SCISSORS"] then
			winningChoice = "ROCK"
		end
		
		for userId, choice in pairs(self.Choices) do
			if choice == winningChoice then
				self.Results[userId] = {
					won = true,
					refund = false
				}
			else
				self.Results[userId] = {
					won = false,
					refund = false
				}
			end
		end
	end,
	
	getPlayerResult = function(self, player)
		local result = self.Results[player.UserId]
		if result then
			return {
				won = result.won,
				choice = self.Choices[player.UserId],
				refund = result.refund or false
			}
		end
		return {
			won = false
		}
	end
}

MiniGames.PaperScissorsRock = PaperScissorsRock

-- Create registry
local MiniGameRegistry = {
	Games = {},
	
	new = function()
		local obj = {
			Games = {}
		}
		setmetatable(obj, {
			__index = function(t, key)
				return t.Games[key]
			end
		})
		return obj
	end,
	
	registerGame = function(self, gameName, gameClass)
		self.Games[gameName] = gameClass
	end,
	
	getGame = function(self, gameName)
		return self.Games[gameName]
	end,
	
	getAllGames = function(self)
		return self.Games
	end,
	
	selectRandomGame = function(self)
		local gameNames = {}
		for name in pairs(self.Games) do
			table.insert(gameNames, name)
		end
		
		if #gameNames == 0 then
			return nil
		end
		
		local randomIndex = math.random(1, #gameNames)
		return gameNames[randomIndex]
	end,
	
	registerAll = function(self)
		self:registerGame("DiceBattle", DiceBattle)
		self:registerGame("NumberGuess", NumberGuess)
		self:registerGame("PaperScissorsRock", PaperScissorsRock)
	end
}

-- Exports
local function MiniGameRegistry_exports()
	return {
		MiniGameRegistry = MiniGameRegistry,
		MiniGames = MiniGames,
		setup = function()
			local registry = MiniGameRegistry.new()
			registry:registerAll()
			return registry
		end
	}
end


-- ============================================
-- ===== Main Game Class =====
-- ============================================

-- Main Game class
local Game = {
	Started = false,
	GameManager = nil,
	BoardManager = nil,
	EconomyManager = nil,
	LobbyManager = nil,
	
	start = function()
		if Game.Started then
			print("Game already started!")
			return false
		end
		
		print("Initializing Roblox Party Game...")
		
		-- Initialize Game Manager
		Game.GameManager = GameManager_exports().setup()
		if not Game.GameManager then
			print("Failed to initialize Game Manager")
			return false
		end
		
		-- Initialize Board Manager
		Game.BoardManager = BoardManager_exports().setup()
		if not Game.BoardManager then
			print("Failed to initialize Board Manager")
			return false
		end
		
		-- Initialize Economy Manager
		Game.EconomyManager = EconomyManager_exports().setup()
		if not Game.EconomyManager then
			print("Failed to initialize Economy Manager")
			return false
		end
		
		-- Initialize Lobby Manager
		Game.LobbyManager = LobbyManager_exports().setup()
		if not Game.LobbyManager then
			print("Failed to initialize Lobby Manager")
			return false
		end
		
		-- Register all mini-games
		local registry = MiniGameRegistry_exports().setup()
		if not registry then
			print("Failed to setup Mini-Game Registry")
			return false
		end
		
		-- Link registry to GameManager
		if Game.GameManager then
			Game.GameManager.MiniGameRegistry = registry
		end
		
		-- Start the game
		Game.Started = true
		print("Roblox Party Game started successfully!")
		
		-- Start in lobby
		if Game.GameManager then
			Game.GameManager:startLobby()
		end
		
		return true
	end,
	
	stop = function()
		if not Game.Started then
			print("Game not started!")
			return false
		end
		
		print("Stopping Roblox Party Game...")
		
		-- Cleanup
		if Game.GameManager then
			Game.GameManager:endGame()
		end
		
		Game.Started = false
		print("Roblox Party Game stopped.")
		
		return true
	end
}

-- Setup function
function Game.setup()
	local instance = setmetatable({}, {__index = Game})
	return instance
end

-- Exports
return {
	Game = Game,
	setup = Game.setup,
	
	getGameManager = function()
		return Game.GameManager
	end,
	
	getBoardManager = function()
		return Game.BoardManager
	end,
	
	getEconomyManager = function()
		return Game.EconomyManager
	end,
	
	getLobbyManager = function()
		return Game.LobbyManager
	end
}
