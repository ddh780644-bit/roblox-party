-- MiniGameRegistry.lua
-- Registry and manager for all mini-games in the party game

local ReplicatedStorage = game and game:GetService("ReplicatedStorage")
local ServerScriptService = game and game:GetService("ServerScriptService")

local SharedModules = ReplicatedStorage and ReplicatedStorage:WaitForChild("SharedModules")

-- Import shared modules
local GameState = SharedModules and require(SharedModules:WaitForChild("GameState"))
local PlayerData = SharedModules and require(SharedModules:WaitForChild("PlayerData"))

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
	
	-- Initialize the mini-game
	init = function(self)
		self.State = "LOBBY"
		self.Players = {}
	end,
	
	-- Add a player to the mini-game
	playerJoin = function(self, player)
		if #self.Players >= self.Config.MaxPlayers then
			return false
		end
		
		table.insert(self.Players, player)
		self:playerReady(player)
		return true
	end,
	
	-- Remove a player from the mini-game
	playerLeave = function(self, player)
		for i, p in ipairs(self.Players) do
			if p.UserId == player.UserId then
				table.remove(self.Players, i)
				break
			end
		end
	end,
	
	-- Check if player is ready to play
	playerReady = function(self, player)
	end,
	
	-- Start the mini-game
	start = function(self)
		self.State = "PLAYING"
	end,
	
	-- End the mini-game
	endGame = function(self)
		self.State = "ENDED"
	end,
	
	-- Get player result
	getPlayerResult = function(self, player)
		return {
			won = false,
			score = 0
		}
	end,
	
	-- Reset the mini-game
	reset = function(self)
		self:init()
	end
}

-- Export the base class
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
		
		-- Calculate pot
		local pot = self.BetAmount * #self.Players
		
		-- Roll dice for each player
		for _, player in ipairs(self.Players) do
			local roll = math.random(1, 6) + math.random(1, 6) -- 2d6
			self.Results[player.UserId] = {
				roll = roll,
				won = false
			}
		end
		
		-- Determine winner
		local maxRoll = 0
		for _, result in pairs(self.Results) do
			if result.roll > maxRoll then
				maxRoll = result.roll
			end
		end
		
		-- Find all players with max roll (for ties)
		local winners = {}
		for userId, result in pairs(self.Results) do
			if result.roll == maxRoll then
				result.won = true
				table.insert(winners, userId)
			end
		end
		
		-- Split pot among winners
		local winnerShare = math.floor(pot / #winners)
		for _, userId in ipairs(winners) do
			-- Update player balance - this would be done through EconomyManager
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

-- Export to MiniGames table
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
		
		-- Calculate potential win
		local potentialWin = self.Config.BetAmount * self.Config.WinMultiplier
		
		-- Check guesses
		for userId, guess in pairs(self.Guesses) do
			local result = {
				guess = guess,
				closest = false,
				exact = false,
				diff = 0
			}
			
			-- Calculate difference
			result.diff = math.abs(guess - self.TargetNumber)
			
			-- Check if exact match
			if guess == self.TargetNumber then
				result.exact = true
				result.closest = true
			end
			
			-- Check if closest (if no exact matches)
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
		-- Server-side input validation
		if type(number) ~= "number" then
			return false, "Invalid input type"
		end
		
		if number < 1 or number > 100 then
			return false, "Number must be between 1 and 100"
		end
		
		if self.State ~= "LOBBY" and self.State ~= "PLAYING" then
			return false, "Game already started"
		end
		
		-- Rate limiting: prevent multiple guesses from same player
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

-- Export to MiniGames table
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
		
		-- Find winner based on choices
		local winningChoice = nil
		local winners = {}
		
		-- Check if all players chose the same
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
			-- All same, everyone gets refund
			for userId in pairs(self.Choices) do
				self.Results[userId] = {
					won = true,
					refund = true
				}
			end
			return
		end
		
		-- Determine winning choice
		-- Paper beats Rock, Rock beats Scissors, Scissors beats Paper
		local choicesSet = {}
		for choice in pairs(self.Choices) do
			choicesSet[choice] = true
		end
		
		if choicesSet["PAPER"] and choicesSet["ROCK"] and choicesSet["SCISSORS"] then
			-- All three choices, nobody wins
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
		
		-- Find winners
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

-- Export to MiniGames table
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
	
	-- Register all mini-games
	registerAll = function(self)
		self:registerGame("DiceBattle", DiceBattle)
		self:registerGame("NumberGuess", NumberGuess)
		self:registerGame("PaperScissorsRock", PaperScissorsRock)
	end
}

return {
	MiniGameRegistry = MiniGameRegistry,
	MiniGames = MiniGames,
	setup = function()
		local registry = MiniGameRegistry.new()
		registry:registerAll()
		return registry
	end
}
