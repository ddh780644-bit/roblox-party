-- ===== LobbyManager =====
-- Manages the lobby system, player registration, and game waiting room

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Remote events
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
	
	-- Calculate countdown time based on ready percentage
	local countdownTime = self.Config.ReadyCountdown
	local readyPercentage = self:getReadyPercentage()
	
	-- Add extra time if less than 100% ready
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
	local countdownTimer = RunService.Heartbeat:Connect(function()
		remaining = remaining - 1
		
		if remaining <= 0 then
			countdownTimer:Disconnect()
			self:notifyGameStart()
		else
			-- Update countdown
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
	-- Notify all players game is starting
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
			
			-- Notify all players
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

return {
	LobbyManager = LobbyManager,
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
