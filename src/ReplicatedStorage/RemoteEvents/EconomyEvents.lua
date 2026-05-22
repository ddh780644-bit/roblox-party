-- EconomyEvents
-- Remote events for economy management
-- Original Lua version for Roblox compatibility

local RemoteEvents = {}

-- Client events (Server sends to Client)
RemoteEvents.EconomyEvents = {
	-- Player balance changed
	BalanceChanged = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Transaction completed
	TransactionCompleted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Payday collection started
	PaydayStarted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Payday collection ended
	PaydayEnded = Instance.new("RemoteEvent", RemoteEvents)
}

-- Server events (Client sends to Server)
RemoteEvents.ServerEvents = {
	-- Request to collect payday
	PaydayStarted = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Request to transfer money to another player
	TransferMoney = Instance.new("RemoteEvent", RemoteEvents),
	
	-- Request to buy an item
	BuyItem = Instance.new("RemoteEvent", RemoteEvents)
}

return RemoteEvents
