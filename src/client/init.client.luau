-- ===== ClientUI =====
-- Main client-side UI script for Roblox Party Game
-- Handles all client-side UI interactions and rendering

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local TextService = game:GetService("TextService")

-- Remote events container
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- ClientUI table
local ClientUI = {
	RemoteEvents = RemoteEvents,
	LocalPlayer = Players.LocalPlayer,
	
	-- UI Elements
	UILayer = nil,
	LobbyUI = nil,
	MiniGameUI = nil,
	EconomyUI = nil,
	
	-- State
	InLobby = true,
	InMiniGame = false,
	
	-- Config
	Config = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.8, 0, 0.9, 0),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
}

-- UI Helper Functions
function createFrame(parent, name, backgroundColor3, size, position, borderColor3, borderWidth)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = backgroundColor3
	frame.BorderSizePixel = borderWidth or 1
	if borderColor3 then
		frame.BorderColor3 = borderColor3
	end
	frame.Size = size
	frame.Position = position
	frame.Parent = parent
	return frame
end

function createTextLabel(parent, name, text, textColor3, textSize, backgroundColor3, size, position, textXAlignment, textYAlignment)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.TextColor3 = textColor3
	label.TextSize = textSize
	if backgroundColor3 then
		label.BackgroundColor3 = backgroundColor3
	end
	label.Size = size
	label.Position = position
	if textXAlignment then
		label.TextXAlignment = textXAlignment
	end
	if textYAlignment then
		label.TextYAlignment = textYAlignment
	end
	label.Parent = parent
	return label
end

function createTextButton(parent, name, text, textColor3, textSize, backgroundColor3, size, position, visible)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.TextColor3 = textColor3
	button.TextSize = textSize
	if backgroundColor3 then
		button.BackgroundColor3 = backgroundColor3
	end
	button.Size = size
	button.Position = position
	if visible ~= nil then
		button.Visible = visible
	end
	button.Parent = parent
	return button
end

function createScrollingFrame(parent, name, backgroundColor3, size, position, canvasSize)
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name
	if backgroundColor3 then
		frame.BackgroundColor3 = backgroundColor3
	end
	frame.BorderSizePixel = 0
	frame.Size = size
	frame.Position = position
	if canvasSize then
		frame.CanvasSize = canvasSize
	end
	frame.Parent = parent
	return frame
end

function createTextBox(parent, name, text, textColor3, textSize, backgroundColor3, size, position)
	local box = Instance.new("TextBox")
	box.Name = name
	box.Text = text
	box.TextColor3 = textColor3
	box.TextSize = textSize
	if backgroundColor3 then
		box.BackgroundColor3 = backgroundColor3
	end
	box.Size = size
	box.Position = position
	box.Parent = parent
	return box
end

-- Create UI container
function ClientUI:createUILayer()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RobloxPartyUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = self.LocalPlayer:WaitForChild("PlayerGui")
	
	self.UILayer = screenGui
	
	-- Create main container
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

-- Create Lobby UI
function ClientUI:createLobbyUI(container)
	local lobbyFrame = Instance.new("Frame")
	lobbyFrame.Name = "LobbyUI"
	lobbyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	lobbyFrame.BorderSizePixel = 1
	lobbyFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	lobbyFrame.Size = UDim2.new(1, 0, 1, 0)
	lobbyFrame.Parent = container
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "Roblox Party Game"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.Size = UDim2.new(1, 0, 0.08, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.Parent = lobbyFrame
	title.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Player List
	local playerList = Instance.new("ScrollingFrame")
	playerList.Name = "PlayerList"
	playerList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	playerList.BorderSizePixel = 0
	playerList.Size = UDim2.new(1, -20, 0.6, 0)
	playerList.Position = UDim2.new(0, 10, 0.1, 0)
	playerList.CanvasSize = UDim2.new(0, 0, 0, 100)
	playerList.Parent = lobbyFrame
	
	-- Ready Button
	local readyButton = Instance.new("TextButton")
	readyButton.Name = "ReadyButton"
	readyButton.Text = "Ready"
	readyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	readyButton.TextSize = 18
	readyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	readyButton.Size = UDim2.new(0.4, 0, 0.06, 0)
	readyButton.Position = UDim2.new(0.3, 0, 0.75, 0)
	readyButton.Parent = lobbyFrame
	
	-- Not Ready Button (hidden initially)
	local notReadyButton = Instance.new("TextButton")
	notReadyButton.Name = "NotReadyButton"
	notReadyButton.Text = "Not Ready"
	notReadyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	notReadyButton.TextSize = 18
	notReadyButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	notReadyButton.Size = UDim2.new(0.4, 0, 0.06, 0)
	notReadyButton.Position = UDim2.new(0.3, 0, 0.75, 0)
	notReadyButton.Visible = false
	notReadyButton.Parent = lobbyFrame
	
	-- Status Label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.Text = "Waiting for players..."
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.TextSize = 16
	statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	statusLabel.Size = UDim2.new(0.6, 0, 0.05, 0)
	statusLabel.Position = UDim2.new(0.2, 0, 0.85, 0)
	statusLabel.Parent = lobbyFrame
	statusLabel.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Countdown Label
	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "Countdown"
	countdownLabel.Text = ""
	countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	countdownLabel.TextSize = 32
	countdownLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	countdownLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
	countdownLabel.Position = UDim2.new(0.5, 0, 0.9, 0)
	countdownLabel.Parent = lobbyFrame
	countdownLabel.Visible = false
	countdownLabel.TextXAlignment = Enum.TextXAlignment.Center
	
	return {
		container = lobbyFrame,
		title = title,
		playerList = playerList,
		readyButton = readyButton,
		notReadyButton = notReadyButton,
		statusLabel = statusLabel,
		countdownLabel = countdownLabel
	}
end

-- Create Mini-Game UI
function ClientUI:createMiniGameUI(container)
	local miniGameFrame = Instance.new("Frame")
	miniGameFrame.Name = "MiniGameUI"
	miniGameFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	miniGameFrame.BorderSizePixel = 1
	miniGameFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	miniGameFrame.Size = UDim2.new(1, 0, 0.8, 0)
	miniGameFrame.Position = UDim2.new(0, 0, 0.1, 0)
	miniGameFrame.Parent = container
	miniGameFrame.Visible = false
	
	-- Game Name
	local gameNameLabel = Instance.new("TextLabel")
	gameNameLabel.Name = "GameName"
	gameNameLabel.Text = "Mini-Game"
	gameNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	gameNameLabel.TextSize = 20
	gameNameLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	gameNameLabel.Size = UDim2.new(1, 0, 0.1, 0)
	gameNameLabel.Position = UDim2.new(0, 0, 0, 0)
	gameNameLabel.Parent = miniGameFrame
	gameNameLabel.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Game Info
	local gameInfoLabel = Instance.new("TextLabel")
	gameInfoLabel.Name = "GameInfo"
	gameInfoLabel.Text = ""
	gameInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	gameInfoLabel.TextSize = 16
	gameInfoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	gameInfoLabel.Size = UDim2.new(1, 0, 0.2, 0)
	gameInfoLabel.Position = UDim2.new(0, 0, 0.1, 0)
	gameInfoLabel.Parent = miniGameFrame
	gameInfoLabel.TextXAlignment = Enum.TextXAlignment.Center
	gameInfoLabel.TextYAlignment = Enum.TextYAlignment.Center
	
	-- Controls
	local controlsFrame = Instance.new("Frame")
	controlsFrame.Name = "Controls"
	controlsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	controlsFrame.BorderSizePixel = 1
	controlsFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	controlsFrame.Size = UDim2.new(1, -20, 0.3, 0)
	controlsFrame.Position = UDim2.new(0, 10, 0.35, 0)
	controlsFrame.Parent = miniGameFrame
	
	-- Input Field
	local inputField = Instance.new("TextBox")
	inputField.Name = "InputField"
	inputField.Text = ""
	inputField.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputField.TextSize = 16
	inputField.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	inputField.Size = UDim2.new(0.7, 0, 0.3, 0)
	inputField.Position = UDim2.new(0.15, 0, 0.35, 0)
	inputField.Parent = controlsFrame
	
	-- Submit Button
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Text = "Submit"
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.TextSize = 16
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
	submitButton.Size = UDim2.new(0.2, 0, 0.3, 0)
	submitButton.Position = UDim2.new(0.88, 0, 0.35, 0)
	submitButton.Parent = controlsFrame
	
	return {
		container = miniGameFrame,
		gameNameLabel = gameNameLabel,
		gameInfoLabel = gameInfoLabel,
		inputField = inputField,
		submitButton = submitButton
	}
end

-- Create Economy UI
function ClientUI:createEconomyUI(container)
	local economyFrame = Instance.new("Frame")
	economyFrame.Name = "EconomyUI"
	economyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	economyFrame.BorderSizePixel = 1
	economyFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
	economyFrame.Size = UDim2.new(1, 0, 0.2, 0)
	economyFrame.Position = UDim2.new(0, 0, 0.8, 0)
	economyFrame.Parent = container
	
	-- Balance Display
	local balanceLabel = Instance.new("TextLabel")
	balanceLabel.Name = "Balance"
	balanceLabel.Text = "Balance: $1000"
	balanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	balanceLabel.TextSize = 18
	balanceLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	balanceLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	balanceLabel.Position = UDim2.new(0, 0, 0, 0)
	balanceLabel.Parent = economyFrame
	balanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Payday Button
	local paydayButton = Instance.new("TextButton")
	paydayButton.Name = "PaydayButton"
	paydayButton.Text = "Collect Payday"
	paydayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	paydayButton.TextSize = 14
	paydayButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	paydayButton.Size = UDim2.new(0.4, 0, 0.5, 0)
	paydayButton.Position = UDim2.new(0.55, 0, 0, 0)
	paydayButton.Parent = economyFrame
	
	return {
		container = economyFrame,
		balanceLabel = balanceLabel,
		paydayButton = paydayButton
	}
end

-- Update Player List
function ClientUI:updatePlayerList(players)
	local playerList = self.LobbyUI and self.LobbyUI.playerList
	if not playerList then return end
	
	-- Clear existing players
	for _, playerFrame in ipairs(playerList:GetChildren()) do
		if playerFrame:IsA("TextButton") then
			playerFrame:Destroy()
		end
	end
	
	-- Add players
	for _, playerInfo in ipairs(players) do
		local button = Instance.new("TextButton")
		button.Name = "Player_" .. playerInfo.userId
		button.Text = playerInfo.name .. (playerInfo.isReady and " ✅" or " ⏳")
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 14
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		button.Size = UDim2.new(0.9, 0, 0, 40)
		button.Position = UDim2.new(0, 0, 0, (#playerList:GetChildren() * 45))
		button.Parent = playerList
		
		-- Set anchor point to position correctly in scrolling frame
		button.AnchorPoint = Vector2.new(0.5, 0)
		button.Position = UDim2.new(0.5, 0, 0, (#playerList:GetChildren() - 1) * 45)
	end
end

-- Update Balance Display
function ClientUI:updateBalance(amount)
	if not self.EconomyUI then return end
	self.EconomyUI.balanceLabel.Text = "Balance: $" .. amount
end

-- Show/Hide Mini-Game UI
function ClientUI:showMiniGameUI(gameName)
	if not self.MiniGameUI then return end
	self.MiniGameUI.container.Visible = true
	self.MiniGameUI.gameNameLabel.Text = gameName
end

function ClientUI:hideMiniGameUI()
	if not self.MiniGameUI then return end
	self.MiniGameUI.container.Visible = false
end

-- Get RemoteEvent helper
function ClientUI:getRemoteEvent(name)
	return self.RemoteEvents:FindFirstChild(name)
end

-- Setup event handlers
function ClientUI:setupEventHandlers()
	-- Lobby events
	local PlayerJoined = self:getRemoteEvent("PlayerJoined")
	local PlayerReady = self:getRemoteEvent("PlayerReady")
	local ReadyStatusChanged = self:getRemoteEvent("ReadyStatusChanged")
	local LobbyFull = self:getRemoteEvent("LobbyFull")
	local GameStarting = self:getRemoteEvent("GameStarting")
	
	if PlayerReady then
		PlayerReady.OnClientEvent:Connect(function()
			-- Fire server event when ready button clicked
		end)
	end
	
	if ReadyStatusChanged then
		ReadyStatusChanged.OnClientEvent:Connect(function(data)
			-- Handle ready status change
			if data.countdown then
				if data.countdown > 0 then
					if self.LobbyUI then
						self.LobbyUI.countdownLabel.Text = "Starting in: " .. data.countdown
						self.LobbyUI.countdownLabel.Visible = true
					end
				else
					if self.LobbyUI then
						self.LobbyUI.countdownLabel.Visible = false
					end
				end
			end
		end)
	end
	
	if GameStarting then
		GameStarting.OnClientEvent:Connect(function(data)
			if data.countdown and data.countdown > 0 then
				if self.LobbyUI then
					self.LobbyUI.countdownLabel.Text = "Starting in: " .. data.countdown
					self.LobbyUI.countdownLabel.Visible = true
				end
			else
				if self.LobbyUI then
					self.LobbyUI.countdownLabel.Visible = false
				end
			end
		end)
	end
	
	-- Economy events
	local BalanceChanged = self:getRemoteEvent("BalanceChanged")
	local TransactionCompleted = self:getRemoteEvent("TransactionCompleted")
	
	if BalanceChanged then
		BalanceChanged.OnClientEvent:Connect(function(amount)
			self:updateBalance(amount)
		end)
	end
	
	if TransactionCompleted then
		TransactionCompleted.OnClientEvent:Connect(function(data)
			print(string.format("Transaction: %s - %s ($%d)", data.type or "", data.description or data.item or "", data.amount or 0))
		end)
	end
	
	-- Mini-Game events
	local MiniGameStarted = self:getRemoteEvent("MiniGameStarted")
	local MiniGameEnded = self:getRemoteEvent("MiniGameEnded")
	local SubmitGuess = self:getRemoteEvent("SubmitGuess")
	
	if MiniGameStarted then
		MiniGameStarted.OnClientEvent:Connect(function(gameName, gameInfo)
			self:showMiniGameUI(gameName)
		end)
	end
	
	if MiniGameEnded then
		MiniGameEnded.OnClientEvent:Connect(function(gameName, results)
			self:hideMiniGameUI()
		end)
	end
end

-- Setup function
function ClientUI:setup()
	-- Create UI layer
	local container = self:createUILayer()
	
	-- Create UI sections
	self.LobbyUI = self:createLobbyUI(container)
	self.MiniGameUI = self:createMiniGameUI(container)
	self.EconomyUI = self:createEconomyUI(container)
	
	-- Setup event handlers
	self:setupEventHandlers()
	
	-- Connect ready button
	if self.LobbyUI and self.LobbyUI.readyButton then
		self.LobbyUI.readyButton.MouseButton1Click:Connect(function()
			if self.RemoteEvents:FindFirstChild("PlayerReady") then
				self.RemoteEvents.PlayerReady:FireServer()
			end
		end)
	end
	
	-- Connect not ready button
	if self.LobbyUI and self.LobbyUI.notReadyButton then
		self.LobbyUI.notReadyButton.MouseButton1Click:Connect(function()
			if self.RemoteEvents:FindFirstChild("PlayerReady") then
				self.RemoteEvents.PlayerReady:FireServer()
			end
		end)
	end
	
	-- Connect submit button
	if self.MiniGameUI and self.MiniGameUI.submitButton then
		self.MiniGameUI.submitButton.MouseButton1Click:Connect(function()
			local input = self.MiniGameUI.inputField.Text
			if input ~= "" then
				if self.RemoteEvents:FindFirstChild("SubmitGuess") then
					self.RemoteEvents.SubmitGuess:FireServer(input)
				end
				self.MiniGameUI.inputField.Text = ""
			end
		end)
	end
	
	-- Connect payday button
	if self.EconomyUI and self.EconomyUI.paydayButton then
		self.EconomyUI.paydayButton.MouseButton1Click:Connect(function()
			if self.RemoteEvents:FindFirstChild("PaydayStarted") then
				self.RemoteEvents.PaydayStarted:FireServer()
			end
		end)
	end
end

-- Exports
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
