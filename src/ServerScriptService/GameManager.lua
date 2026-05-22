-- GameManager.lua
-- Main game orchestrator for Roblox Party Game
-- v1.0.0 - Complete game state management

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Load shared modules
local GameState = require(SharedModules:WaitForChild("GameState"))
local MiniGameRegistry = require(SharedModules:WaitForChild("MiniGameRegistry"))
local PlayerData = require(SharedModules:WaitForChild("PlayerData"))

-- Load remote events
local GameEvents = {
	ReadyToStart = RemoteEvents:WaitForChild("ReadyToStart"),
	ReadyToPlay = RemoteEvents:WaitForChild("ReadyToPlay"),
	RoundStarted = RemoteEvents:WaitForChild("RoundStarted"),
	MiniGameStarted = RemoteEvents:WaitForChild("MiniGameStarted"),
	MiniGameEnded = RemoteEvents:WaitForChild("MiniGameEnded"),
	GameEnded = RemoteEvents:WaitForChild("GameEnded"),
	MiniGameSelected = RemoteEvents:WaitForChild("MiniGameSelected")
}

local GameManager = {
	State = GameState.new(),
	MiniGameRegistry = MiniGameRegistry,
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
		data:cleanup()
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

-- Setup
function GameManager.setup()
	local instance = setmetatable({}, {__index = GameManager})
	instance.MiniGames = MiniGameRegistry:getAllGames()
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
return {
	setup = GameManager.setup,
	getPlayerCount = function() return GameManager.Instance and GameManager.Instance:getPlayerCount() end,
	readyPlayer = function(player) 
		if GameManager.Instance then
			GameManager.Instance:readyPlayer(player)
		end
	end
}
