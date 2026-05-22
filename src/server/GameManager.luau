-- ===== GameManager =====
-- Main game orchestrator for Roblox Party Game
-- Luau type-annotated version with proper type safety

-- Services
type PlayersService = Instance & {
	GetPlayers: () -> {Instance},
	PlayerAdded: RBXScriptSignal<(player: Instance) -> ()>,
	PlayerRemoving: RBXScriptSignal<(player: Instance) -> ()>
}

type ReplicatedStorageService = Instance & {
	WaitForChild: (self: ReplicatedStorageService, name: string) -> Instance
}

type ServerScriptService = Instance

-- Event types
type RemoteEvent = Instance & {
	FireClient: (self: RemoteEvent, player: Instance, ...) -> (),
	FireAllClients: (self: RemoteEvent, ...) -> ()
}

-- Type definitions
type GameStateType = "LOBBY" | "ROUND" | "MINIGAME" | "ENDED"

type PlayerData = {
	UserId: number,
	Name: string,
	Balance: number,
	Position: number,
	isReady: boolean,
	isJail: boolean,
	addBalance: (amount: number) -> (),
	deductBalance: (amount: number) -> boolean,
	setJail: () -> (),
	setSkipTurn: (boolean) -> (),
	getBalance: () -> number
}

type MiniGame = {
	Name: string,
	State: string,
	Players: {Instance},
	Config: {
		MinPlayers: number,
		MaxPlayers: number,
		Duration: number
	},
	init: () -> (),
	start: () -> (),
	endGame: () -> (),
	getPlayerResult: (player: Instance) -> {won: boolean, score: number}
}

type MiniGameRegistry = {
	getAllGames: () -> {string: MiniGame},
	selectRandomGame: () -> string?,
	getGame: (name: string) -> MiniGame?
}

type GameManagerConfig = {
	MaxPlayers: number,
	MinPlayers: number,
	RoundTime: number,
	BetAmount: number
}

type GameManager = {
	State: {setState: (GameStateType) -> (), getState: () -> GameStateType},
	MiniGameRegistry: MiniGameRegistry,
	MiniGames: {string: MiniGame},
	Players: {number: PlayerData},
	Config: GameManagerConfig,
	Instance: GameManager,
	
	-- Methods
	onPlayerAdded: (self: GameManager, player: Instance) -> (),
	onPlayerRemoved: (self: GameManager, player: Instance) -> (),
	startLobby: (self: GameManager) -> (),
	startRound: (self: GameManager) -> boolean,
	startMiniGame: (self: GameManager, gameName: string) -> boolean,
	endMiniGame: (self: GameManager) -> (),
	endGame: (self: GameManager) -> (),
	getPlayerCount: (self: GameManager) -> number,
	readyPlayer: (self: GameManager, player: Instance) -> (),
	setup: () -> GameManager
}

-- Dependencies
type ReplicatedStorage = Instance
type ServerScriptService = Instance
type Players = PlayersService
type TeleportService = Instance

type GameEvents = {
	ReadyToStart: RemoteEvent,
	ReadyToPlay: RemoteEvent,
	RoundStarted: RemoteEvent,
	MiniGameStarted: RemoteEvent,
	MiniGameEnded: RemoteEvent,
	GameEnded: RemoteEvent,
	MiniGameSelected: RemoteEvent
}

-- Import modules
local Players = game:GetService("Players") :: PlayersService
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorageService
local ServerScriptService = game:GetService("ServerScriptService") :: ServerScriptService
local TeleportService = game:GetService("TeleportService") :: TeleportService

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules") :: Instance
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents") :: Instance

local GameState = require(SharedModules:WaitForChild("GameState")) :: {new: () -> {setState: (GameStateType) -> (), getState: () -> GameStateType}}
local PlayerData = require(SharedModules:WaitForChild("PlayerData")) :: {new: (Instance) -> PlayerData}

-- Load remote events
local GameEvents: GameEvents = {
	ReadyToStart = RemoteEvents:WaitForChild("ReadyToStart") :: RemoteEvent,
	ReadyToPlay = RemoteEvents:WaitForChild("ReadyToPlay") :: RemoteEvent,
	RoundStarted = RemoteEvents:WaitForChild("RoundStarted") :: RemoteEvent,
	MiniGameStarted = RemoteEvents:WaitForChild("MiniGameStarted") :: RemoteEvent,
	MiniGameEnded = RemoteEvents:WaitForChild("MiniGameEnded") :: RemoteEvent,
	GameEnded = RemoteEvents:WaitForChild("GameEnded") :: RemoteEvent,
	MiniGameSelected = RemoteEvents:WaitForChild("MiniGameSelected") :: RemoteEvent
}

-- Require MiniGameRegistry for type checking
local MiniGameRegistry = require(ServerScriptService:WaitForChild("MiniGameRegistry")) :: {setup: () -> MiniGameRegistry}

-- GameManager table
local GameManager: GameManager = {
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
function GameManager:onPlayerAdded(player: Instance)
	local playerData = PlayerData.new(player)
	self.Players[player.UserId :: number] = playerData
	
	print(("Player %s joined (ID: %d)"):format(player.Name, player.UserId :: number))
	
	-- Send current game state to new player
	local playerState = self.State:getState()
	GameEvents.JoinResponse:FireClient(player, playerState)
end

function GameManager:onPlayerRemoved(player: Instance)
	if self.Players[player.UserId :: number] then
		local data = self.Players[player.UserId :: number]
		data = nil
		self.Players[player.UserId :: number] = nil
		print(("Player %s left (ID: %d)"):format(player.Name, player.UserId :: number))
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

function GameManager:startRound(): boolean
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

function GameManager:startMiniGame(gameName: string): boolean
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
		local playerData = self.Players[player.UserId :: number]
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
		local playerData = self.Players[player.UserId :: number]
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
		local playerData = self.Players[player.UserId :: number]
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
function GameManager:getPlayerCount(): number
	return #Players:GetPlayers()
end

function GameManager:isPlayerReady(player: Instance): boolean
	local playerData = self.Players[player.UserId :: number]
	return playerData and playerData.isReady
end

function GameManager:readyPlayer(player: Instance)
	local playerData = self.Players[player.UserId :: number]
	if playerData then
		playerData.isReady = true
	end
end

-- Setup function
function GameManager.setup(): GameManager
	local instance = setmetatable({}, {__index = GameManager})
	instance.MiniGames = MiniGameRegistry:getAllGames()
	instance:startLobby()
	
	return instance
end

-- Event connections
Players.PlayerAdded:Connect(function(player: Instance)
	if GameManager.Instance then
		GameManager.Instance:onPlayerAdded(player)
	end
end)

Players.PlayerRemoving:Connect(function(player: Instance)
	if GameManager.Instance then
		GameManager.Instance:onPlayerRemoved(player)
	end
end)

-- Exports
return {
	setup = GameManager.setup,
	getPlayerCount = function(): number
		return GameManager.Instance and GameManager.Instance:getPlayerCount() or 0
	end,
	readyPlayer = function(player: Instance)
		if GameManager.Instance then
			GameManager.Instance:readyPlayer(player)
		end
	end
}
