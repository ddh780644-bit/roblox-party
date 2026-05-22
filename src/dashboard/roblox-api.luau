-- API: /api/roblox/files
-- Returns the reorganized Roblox Party game files for Joe

local HttpService = game:GetService("HttpService")

-- File contents as base64 strings (or we can embed them directly)
local RobloxFiles = {
	default_project = [[
{
	"name": "RobloxParty",
	"serve": {
		"host": "0.0.0.0",
		"port": 8080
	},
	"plugins": ["RojoPlugin"],
	"packages": {},
	"watches": [{"name": "src", "path": "./src"}],
	"ports": {"RojoPlugin": 8080},
	"root": "src",
	"tree": {
		"name": "RobloxParty",
		"className": "DataModel",
		"children": [
			{
				"name": "ServerScriptService",
				"className": "ServerScriptService",
				"children": [
					{
						"name": "RobloxParty",
						"className": "Script",
						"path": "src/server"
					}
				]
			},
			{
				"name": "ReplicatedStorage",
				"className": "ReplicatedStorage",
				"children": [
					{
						"name": "SharedModules",
						"className": "ModuleScript",
						"path": "src/shared"
					}
				]
			},
			{
				"name": "StarterPlayer",
				"className": "StarterPlayer",
				"children": [
					{
						"name": "StarterPlayerScripts",
						"className": "StarterPlayerScripts",
						"children": [
							{
								"name": "RobloxParty",
								"className": "LocalScript",
								"path": "src/client"
							}
						]
					}
				]
			}
		]
	}
}]],
	server_init = [[
-- Server initialization for Roblox Party Game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local GameState = require(SharedModules:WaitForChild("GameState"))
local PlayerData = require(SharedModules:WaitForChild("PlayerData"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local GameManager = require(ServerScriptService:WaitForChild("GameManager"))
local BoardManager = require(ServerScriptService:WaitForChild("BoardManager"))
local EconomyManager = require(ServerScriptService:WaitForChild("EconomyManager"))
local LobbyManager = require(ServerScriptService:WaitForChild("LobbyManager"))
local MiniGameRegistry = require(ServerScriptService:WaitForChild("MiniGameRegistry"))

local Game = {
	Started = false,
	GameManager = nil,
	BoardManager = nil,
	EconomyManager = nil,
	LobbyManager = nil,
	start = function()
		if Game.Started then return false end
		print("Initializing Roblox Party Game...")
		Game.GameManager = GameManager.setup()
		if not Game.GameManager then print("Failed to initialize Game Manager") return false end
		Game.BoardManager = BoardManager.setup()
		if not Game.BoardManager then print("Failed to initialize Board Manager") return false end
		Game.EconomyManager = EconomyManager.setup()
		if not Game.EconomyManager then print("Failed to initialize Economy Manager") return false end
		Game.LobbyManager = LobbyManager.setup()
		if not Game.LobbyManager then print("Failed to initialize Lobby Manager") return false end
		local registry = MiniGameRegistry.setup()
		if not registry then print("Failed to setup Mini-Game Registry") return false end
		if Game.GameManager then Game.GameManager.MiniGameRegistry = registry end
		Game.Started = true
		print("Roblox Party Game started successfully!")
		if Game.GameManager then Game.GameManager:startLobby() end
		return true
	end,
	stop = function()
		if not Game.Started then return false end
		if Game.GameManager then Game.GameManager:endGame() end
		Game.Started = false
		print("Roblox Party Game stopped.")
		return true
	end
}

return {
	Game = Game,
	setup = function()
		local instance = setmetatable({}, {__index = Game})
		return instance
	end
}
]],
	client_init = [[
-- Client initialization for Roblox Party Game
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local ClientUI = {
	RemoteEvents = RemoteEvents,
	LocalPlayer = Players.LocalPlayer,
	InLobby = true,
	InMiniGame = false,
	Config = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.8, 0, 0.9, 0),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
}

function ClientUI:createUILayer()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RobloxPartyUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = self.LocalPlayer:WaitForChild("PlayerGui")
	self.UILayer = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "MainContainer"
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	frame.Size = UDim2.new(0.8, 0, 0.9, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Parent = screenGui
	return frame
end

function ClientUI:setup()
	local container = self:createUILayer()
end

return {
	ClientUI = ClientUI,
	setup = function()
		if ClientUI.LocalPlayer and ClientUI.RemoteEvents then
			ClientUI:setup()
			return ClientUI
		end
		return nil
	end
}
]],
	shared_init = [[
-- Shared modules for Roblox Party Game

local SharedModules = {}

-- GameState module
local GameState = {
	State = "LOBBY",
	States = {LOBBY = "LOBBY", ROUND = "ROUND", MINIGAME = "MINIGAME", ENDED = "ENDED"}
}

function GameState:getState()
	return self.State
end

function GameState:setState(newState)
	self.State = newState
	print(string.format("GameState changed to: %s", newState))
end

function GameState:isState(state)
	return self.State == state
end

function GameState:isLobby()
	return self:isState("LOBBY")
end

function GameState:isRound()
	return self:isState("ROUND")
end

function GameState:isMiniGame()
	return self:isState("MINIGAME")
end

function GameState:isEnded()
	return self:isState("ENDED")
end

function GameState.new()
	return setmetatable({
		State = "LOBBY",
		States = GameState.States
	}, {__index = GameState})
end

SharedModules.GameState = {
	new = GameState.new,
	getState = function()
		local instance = GameState.new()
		return instance:getState()
	end,
	setState = function(state)
		local instance = GameState.new()
		instance:setState(state)
		return instance
	end
}

-- PlayerData module
local PlayerData = {}

function PlayerData.new(player)
	return setmetatable({
		UserId = player.UserId,
		Name = player.Name,
		Balance = 1000,
		Position = 1,
		Items = {},
		Inventory = {},
		Stats = {gamesPlayed = 0, gamesWon = 0, totalEarnings = 0},
		isReady = false,
		isJail = false,
		skipTurn = false,
		jailTurns = 0
	}, {
		__index = PlayerData
	})
end

function PlayerData.addBalance(self, amount)
	self.Balance = self.Balance + amount
	return self.Balance
end

function PlayerData.deductBalance(self, amount)
	if self.Balance >= amount then
		self.Balance = self.Balance - amount
		return true
	else
		return false
	end
end

function PlayerData.setJail(self)
	self.isJail = true
	self.jailTurns = 3
end

function PlayerData.setSkipTurn(self, skip)
	self.skipTurn = skip
end

function PlayerData.getBalance(self)
	return self.Balance
end

SharedModules.PlayerData = {
	PlayerData = PlayerData,
	new = PlayerData.new
}

return SharedModules
]]
}

-- Main entry point
return {
	RobloxFiles = RobloxFiles,
	getFile = function(filename)
		if filename == "default.project.json" then
			return RobloxFiles.default_project
		elseif filename == "src/server/init.server.luau" or filename == "init.server.luau" then
			return RobloxFiles.server_init
		elseif filename == "src/client/init.client.luau" or filename == "init.client.luau" then
			return RobloxFiles.client_init
		elseif filename == "src/shared/init.luau" or filename == "init.luau" then
			return RobloxFiles.shared_init
		else
			return nil
		end
	end
}