---@module Utility.TaskSpawner
local TaskSpawner = getfenv().TaskSpawner

---@module Game.QueuedBlocking
local QueuedBlocking = getfenv().QueuedBlocking

---@class Action
local Action = getfenv().Action

---@module Utility.Finder
local Finder = getfenv().Finder

-- Services.
local players = game:GetService("Players")

-- State.
local blockUntil = 0
local parryBellUntil = 0
local running = false

---Check if animation is a parry bell animation.
---@param animationId string
---@return boolean
local function isParryBellAnimation(animationId)
	return animationId == "rbxassetid://76760612897349"
		or animationId == "rbxassetid://95485609909879"
		or animationId == "rbxassetid://124372082770931"
end

---Start block loop.
local function startBlockLoop()
	if running then
		return
	end

	running = true

	TaskSpawner.spawn("LittleBell_BlockLoop", function()
		while os.clock() < blockUntil do
			task.wait()
		end

		QueuedBlocking.stop("LittleBell")
		running = false
	end)
end

---Invoke block.
local function invokeBlock()
	QueuedBlocking.invoke(QueuedBlocking.BLOCK_TYPE_NORMAL, "LittleBell", nil)
	startBlockLoop()
end

---Start hold block window.
local function startHoldBlockWindow()
	blockUntil = math.max(blockUntil, os.clock() + 5.5)
	invokeBlock()
end

---Parry bell animation.
local function parryBellAnimation(self, timing)
	parryBellUntil = math.max(parryBellUntil, os.clock() + 1.5)
	timing.forced = true

	local action = Action.new()
	action._when = 720
	action._type = "Parry"
	action.hitbox = Vector3.new(25, 20, 25)
	action.ihbc = true
	action.name = "Knell Bell Parry Timing"
	return self:action(timing, action)
end

---Module function.
---@param self AnimatorDefender|PartDefender
---@param timing AnimationTiming|PartTiming
return function(self, timing)
	if self.__type == "Animation" then
		local isParryAnimation = isParryBellAnimation(timing._id)

		if timing._id ~= "rbxassetid://140154405052975" and not isParryAnimation then
			return
		end

		if not Finder.entity("knell") then
			return
		end

		timing.forced = true

		if isParryAnimation then
			return parryBellAnimation(self, timing)
		end

		return startHoldBlockWindow()
	end

	if os.clock() < parryBellUntil then
		return
	end

	if os.clock() >= blockUntil then
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

	if self:distance(self.part) > 15 then
		return
	end

	if not Finder.entity("knell") then
		return
	end

	invokeBlock()
end
