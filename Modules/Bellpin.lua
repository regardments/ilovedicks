---@class Action
local Action = getfenv().Action

---@module Utility.Finder
local Finder = getfenv().Finder

-- Services.
local players = game:GetService("Players")

-- State.
local spawnUntil = 0
local spawnCount = 0

---Start spawn window.
local function startSpawnWindow()
	spawnUntil = os.clock() + 5
	spawnCount = 0
end

---Queue pair parry.
---@param self PartDefender
---@param timing PartTiming
local function queuePairParry(self, timing)
	timing.forced = true

	local action = Action.new()
	action._when = 500
	action._type = "Parry"
	action.hitbox = Vector3.zero
	action.ihbc = true
	action.name = "Bellpin Pair Timing"
	return self:action(timing, action)
end

---Module function.
---@param self AnimatorDefender|PartDefender
---@param timing AnimationTiming|PartTiming
return function(self, timing)
	if self.__type == "Animation" then
		if timing._id ~= "rbxassetid://83828398681942" then
			return
		end

		if not Finder.entity("knell") then
			return
		end

		timing.forced = true

		return startSpawnWindow()
	end

	if os.clock() >= spawnUntil then
		return
	end

	local character = players.LocalPlayer and players.LocalPlayer.Character
	if character and self.part:IsDescendantOf(character) then
		return
	end

	local thrown = workspace:FindFirstChild("Thrown")
	if not thrown or not self.part:IsDescendantOf(thrown) then
		return
	end

	if not Finder.entity("knell") then
		return
	end

	spawnCount += 1

	if spawnCount % 2 ~= 0 then
		return
	end

	return queuePairParry(self, timing)
end
