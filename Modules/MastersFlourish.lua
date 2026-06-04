---@type Action
local Action = getfenv().Action

---@module Game.InputClient
local InputClient = getfenv().InputClient

---@module Game.Latency
local Latency = getfenv().Latency

-- Services.
local replicatedStorage = game:GetService("ReplicatedStorage")

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local effectReplicator = replicatedStorage:FindFirstChild("EffectReplicator")
	if not effectReplicator then return end
	local effectReplicatorModule = require(effectReplicator)

	-- First hit.
	local action = Action.new()
	action._when = 350
	action._type = "Parry"
	action.hitbox = Vector3.new(25, 15, 25)
	action.name = "Masters Flourish (1)"
	self:action(timing, action)

	-- Wait for first action to fire, then check if we dodged.
	task.wait((0.35 - Latency.rtt()) + 0.05)

	if effectReplicatorModule:FindEffect("DodgeFrame") then
		-- Dodged instead of parried, dodge again for second hit.
		local dodge = Action.new()
		dodge._when = 100
		dodge._type = "Dodge"
		dodge.ihbc = true
		dodge.name = "Masters Flourish Dodge Chain"
		return self:action(timing, dodge)
	end

	-- Second hit.
	local actionTwo = Action.new()
	actionTwo._when = 800 - 350 - 50
	actionTwo._type = "Parry"
	actionTwo.hitbox = Vector3.new(20, 18, 20)
	actionTwo.name = "Masters Flourish (2)"
	return self:action(timing, actionTwo)
end
