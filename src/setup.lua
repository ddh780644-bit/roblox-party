-- Setup.lua
-- Setup script for Roblox Party Game
-- Run this in Roblox Studio to create all required instances

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Helper function to create or get folder
local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

-- Helper function to create or get RemoteEvent
local function getOrCreateRemoteEvent(parent, name)
	local event = parent:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = parent
	end
	return event
end

print("Setting up Roblox Party Game...")

-- Create RemoteEvents folder (all events go directly here)
local remoteEventsFolder = getOrCreateFolder(ReplicatedStorage, "RemoteEvents")

-- Create LobbyEvents
print("Creating LobbyEvents...")
getOrCreateRemoteEvent(remoteEventsFolder, "PlayerJoined")
getOrCreateRemoteEvent(remoteEventsFolder, "PlayerReady")
getOrCreateRemoteEvent(remoteEventsFolder, "ReadyStatusChanged")
getOrCreateRemoteEvent(remoteEventsFolder, "LobbyFull")
getOrCreateRemoteEvent(remoteEventsFolder, "GameStarting")
getOrCreateRemoteEvent(remoteEventsFolder, "ReadyToStart")
getOrCreateRemoteEvent(remoteEventsFolder, "ReadyToPlay")

-- Create GameEvents
print("Creating GameEvents...")
getOrCreateRemoteEvent(remoteEventsFolder, "GameStateUpdated")
getOrCreateRemoteEvent(remoteEventsFolder, "RoundStarted")
getOrCreateRemoteEvent(remoteEventsFolder, "MiniGameStarted")
getOrCreateRemoteEvent(remoteEventsFolder, "MiniGameEnded")
getOrCreateRemoteEvent(remoteEventsFolder, "GameEnded")
getOrCreateRemoteEvent(remoteEventsFolder, "MiniGameSelected")

-- Create EconomyEvents
print("Creating EconomyEvents...")
getOrCreateRemoteEvent(remoteEventsFolder, "BalanceChanged")
getOrCreateRemoteEvent(remoteEventsFolder, "TransactionCompleted")
getOrCreateRemoteEvent(remoteEventsFolder, "PaydayStarted")
getOrCreateRemoteEvent(remoteEventsFolder, "PaydayEnded")
getOrCreateRemoteEvent(remoteEventsFolder, "TransferMoney")
getOrCreateRemoteEvent(remoteEventsFolder, "BuyItem")

-- Create MiniGameEvents
print("Creating MiniGameEvents...")
getOrCreateRemoteEvent(remoteEventsFolder, "MiniGameStarted")
getOrCreateRemoteEvent(remoteEventsFolder, "MiniGameEnded")
getOrCreateRemoteEvent(remoteEventsFolder, "PositionChanged")
getOrCreateRemoteEvent(remoteEventsFolder, "BoardUpdated")
getOrCreateRemoteEvent(remoteEventsFolder, "TurnStarted")
getOrCreateRemoteEvent(remoteEventsFolder, "TurnEnded")
getOrCreateRemoteEvent(remoteEventsFolder, "ItemUseResult")
getOrCreateRemoteEvent(remoteEventsFolder, "ChatMessageReceived")
getOrCreateRemoteEvent(remoteEventsFolder, "MoveDiceRoll")
getOrCreateRemoteEvent(remoteEventsFolder, "BuySpace")
getOrCreateRemoteEvent(remoteEventsFolder, "UpgradeSpace")
getOrCreateRemoteEvent(remoteEventsFolder, "SubmitGuess")
getOrCreateRemoteEvent(remoteEventsFolder, "SubmitChoice")
getOrCreateRemoteEvent(remoteEventsFolder, "UseItem")
getOrCreateRemoteEvent(remoteEventsFolder, "ChatMessage")

print("Creating SharedModules...")
local sharedModulesFolder = getOrCreateFolder(ReplicatedStorage, "SharedModules")
getOrCreateFolder(sharedModulesFolder, "GameState")
getOrCreateFolder(sharedModulesFolder, "PlayerData")

print("Creating ServerScriptService scripts...")
local serverScriptsFolder = getOrCreateFolder(ServerScriptService, "GameScripts")
getOrCreateFolder(serverScriptsFolder, "GameManager")
getOrCreateFolder(serverScriptsFolder, "BoardManager")
getOrCreateFolder(serverScriptsFolder, "EconomyManager")
getOrCreateFolder(serverScriptsFolder, "LobbyManager")
getOrCreateFolder(serverScriptsFolder, "MiniGameRegistry")
getOrCreateFolder(serverScriptsFolder, "GameInit")

print("Creating StarterPlayer scripts...")
local starterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
getOrCreateFolder(starterPlayerScripts, "ClientUI")

print("Roblox Party Game setup complete!")
print("All instances have been created. You can now run the game.")
