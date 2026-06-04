-- LeaderboardClient module.
local LeaderboardClient = { calling = false }

-- Services.
local players = game:GetService("Players")

-- Caching.
local cachedUpvaluesTable = nil
local cachedUpvaluesFunction = nil
local lastDataCacheTime = os.clock()
local lastFunctionCacheTime = os.clock()

---Filter function.
---@param func function?
---@return boolean
local function filterFunction(func)
	if not func or not islclosure(func) then
		return false
	end

	local info = debug.getinfo(func)
	if info.name ~= nil and info.name ~= "" then
		return false
	end

	local constants = debug.getconstants(func)
	if #constants ~= 1 or constants[1] ~= "Destroy" then
		return false
	end

	local upvalues = debug.getupvalues(func)
	if not upvalues then
		return false
	end

	return true
end

---Get leaderboard refresh function.
---@return function?
function LeaderboardClient.glrf()
	if cachedUpvaluesFunction and os.clock() - lastFunctionCacheTime <= 2.0 then
		return cachedUpvaluesFunction
	end

	for _, con in next, getconnections(players.PlayerRemoving) do
		local func = con.Function
		if not filterFunction(func) then
			continue
		end

		local upvalues = debug.getupvalues(func)
		if not upvalues then
			continue
		end

		-- Fetch function.
		local upvaluesFunction = upvalues[2]

		-- Cache.
		lastFunctionCacheTime = os.clock()
		cachedUpvaluesFunction = function()
			-- Never allow a call when we already have an open one.
			if LeaderboardClient.calling then
				return
			end

			-- Mark that we're calling...
			LeaderboardClient.calling = true

			-- Call the function.
			upvaluesFunction()

			-- Close calling!
			LeaderboardClient.calling = false
		end

		-- Return function.
		return cachedUpvaluesFunction
	end

	return nil
end

---Get leaderboard data.
---@return table?
function LeaderboardClient.gld()
	if cachedUpvaluesTable and os.clock() - lastDataCacheTime <= 2.0 then
		return cachedUpvaluesTable
	end

	for _, con in next, getconnections(players.PlayerRemoving) do
		local func = con.Function
		if not filterFunction(func) then
			continue
		end

		local upvalues = debug.getupvalues(func)
		if not upvalues then
			continue
		end

		-- Fetch data.
		local upvaluesTable = upvalues[1]

		-- Cache.
		cachedUpvaluesTable = upvaluesTable
		lastDataCacheTime = os.clock()

		-- Return data.
		return upvaluesTable
	end

	return nil
end

-- Return LeaderboardClient module.
return LeaderboardClient
