-- BoardManager.lua
-- Manages the game board, positions, and movement logic

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Load shared modules
local GameState = require(SharedModules:WaitForChild("GameState"))
local PlayerData = require(SharedModules:WaitForChild("PlayerData"))

-- Load remote events
local GameEvents = {
	TurnStarted = RemoteEvents:WaitForChild("TurnStarted"),
	TurnEnded = RemoteEvents:WaitForChild("TurnEnded"),
	MovementStarted = RemoteEvents:WaitForChild("MovementStarted"),
	MovementEnded = RemoteEvents:WaitForChild("MovementEnded"),
	PositionChanged = RemoteEvents:WaitForChild("PositionChanged"),
	BoardUpdated = RemoteEvents:WaitForChild("BoardUpdated")
}

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
			GameEvents.PositionChanged:FireClient(p, {
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
		GameEvents.BoardUpdated:FireClient(p, self:getBoardState())
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
		GameEvents.PositionChanged:FireClient(p, {
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
		GameEvents.PositionChanged:FireClient(p, {
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
		
		addBalance = function(self, amount)
			self.balance = self.balance + amount
		end,
		
		deductBalance = function(self, amount)
			self.balance = self.max(0, self.balance - amount)
		end,
		
		setJail = function(self)
			self.isJail = true
			self.jailTurns = 3
		end,
		
		setSkipTurn = function(self, skip)
			self.skipTurn = skip
		end,
		
		nextTurn = function(self)
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
		
		getBalance = function(self)
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

return {
	BoardManager = BoardManager,
	setup = function()
		BoardManager:setup()
	end,
	getBoardState = function()
		return BoardManager:getBoardState()
	end
}
