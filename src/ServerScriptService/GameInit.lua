-- GameInit.lua
-- Main initialization script for Roblox Party Game
-- Run on ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- RemoteEvents container
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Import game modules
local GameState = require(ReplicatedStorage.SharedModules:WaitForChild("GameState"))
local PlayerData = require(ReplicatedStorage.SharedModules:WaitForChild("PlayerData"))
local MiniGameRegistry = require(ServerScriptService:WaitForChild("MiniGameRegistry"))

-- Import managers
local GameManager = require(ServerScriptService:WaitForChild("GameManager"))
local BoardManager = require(ServerScriptService:WaitForChild("BoardManager"))
local EconomyManager = require(ServerScriptService:WaitForChild("EconomyManager"))
local LobbyManager = require(ServerScriptService:WaitForChild("LobbyManager"))

local Game = {
	Started = false,
	GameManager = nil,
	BoardManager = nil,
	EconomyManager = nil,
	LobbyManager = nil,
	
	start = function(self)
		if self.Started then
			print("Game already started!")
			return false
		end
		
		print("Initializing Roblox Party Game...")
		
		-- Initialize Game Manager
		self.GameManager = GameManager.setup()
		if not self.GameManager then
			print("Failed to initialize Game Manager")
			return false
		end
		
		-- Initialize Board Manager
		self.BoardManager = BoardManager.setup()
		if not self.BoardManager then
			print("Failed to initialize Board Manager")
			return false
		end
		
		-- Initialize Economy Manager
		self.EconomyManager = EconomyManager.setup()
		if not self.EconomyManager then
			print("Failed to initialize Economy Manager")
			return false
		end
		
		-- Initialize Lobby Manager
		self.LobbyManager = LobbyManager.setup()
		if not self.LobbyManager then
			print("Failed to initialize Lobby Manager")
			return false
		end
		
		-- Register all mini-games
		local registry = MiniGameRegistry.setup()
		if not registry then
			print("Failed to setup Mini-Game Registry")
			return false
		end
		
		-- Start the game
		self.Started = true
		print("Roblox Party Game started successfully!")
		
		-- Start in lobby
		self.GameManager:startLobby()
		
		return true
	end,
	
	stop = function(self)
		if not self.Started then
			print("Game not started!")
			return false
		end
		
		print("Stopping Roblox Party Game...")
		
		-- Cleanup
		if self.GameManager then
			self.GameManager:endGame()
		end
		
		self.Started = false
		print("Roblox Party Game stopped.")
		
		return true
	end
}

-- Setup function
function Game.setup()
	local instance = setmetatable({}, {__index = Game})
	return instance
end

return {
	Game = Game,
	setup = Game.setup
}
