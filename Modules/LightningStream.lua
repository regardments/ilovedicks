---@type PartTiming
local PartTiming = getfenv().PartTiming

---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Mantra
local Mantra = getfenv().Mantra

---@type ProjectileTracker
---@diagnostic disable-next-line: unused-local
local ProjectileTracker = getfenv().ProjectileTracker

---@module Features.Combat.Defense
local Defense = getfenv().Defense

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local data = Mantra.data(self.entity, "Mantra:StreamLightning{{Lightning Stream}}")
	local range = data.perfect * 26 + data.crystal * 24
	local thrown = workspace:FindFirstChild("Thrown")
	if not thrown then
		return
	end

	local tracker = ProjectileTracker.new(function(candidate)
		return candidate.Name == "STREAMPART"
	end)

	task.wait(0.575 - Latency.rtt())

	if self:distance(self.entity) <= 25 then
		local action = Action.new()
		action._type = "Start Crouch"
		action._when = 0
		action.name = "Lightning Stream Close Timing"
		action.ihbc = true
		self:action(timing, action)

		local actionEnd = Action.new()
		actionEnd._type = "End Crouch"
		actionEnd._when = 100
		actionEnd.name = "Lightning Stream Close End"
		actionEnd.ihbc = true
		return self:action(timing, actionEnd)
	end

	local action = Action.new()
	action._when = 0
	action._type = "Start Crouch"
	action.name = "Lightning Stream Part"

	local actionTwo = Action.new()
	actionTwo._when = 500
	actionTwo._type = "End Crouch"
	actionTwo.name = "Lightning Stream End"
	actionTwo.ihbc = true

	local pt = PartTiming.new()
	pt.uhc = true
	pt.duih = true
	pt.fhb = false
	pt.name = "LightningStreamProjectile"
	pt.hitbox = Vector3.new(55 + range, 55 + range, 55 + range)
	pt.actions:push(action)
	pt.actions:push(actionTwo)
	pt.cbm = true

	Defense.cdpo(tracker:wait(), pt)
end
