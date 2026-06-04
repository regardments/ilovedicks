---@type PartTiming
local PartTiming = getfenv().PartTiming

---@type Action
local Action = getfenv().Action

---@module Utility.Finder
local Finder = getfenv().Finder

---@type ProjectileTracker
---@diagnostic disable-next-line: unused-local
local ProjectileTracker = getfenv().ProjectileTracker

---@module Features.Combat.Defense
local Defense = getfenv().Defense

---@module Game.Latency
local Latency = getfenv().Latency

---Module function.
---@param self AnimatorDefender|PartDefender
---@param timing AnimationTiming|PartTiming
return function(self, timing)
	if self.__type == "Part" then
		local duke = Finder.entity("theduke")
		local root = duke and duke:FindFirstChild("HumanoidRootPart")

		if root and (self.part.Position - root.Position).Magnitude <= 10 then
			return
		end

		local action = Action.new()
		action._when = timing.name == "WindSlashProjectile" and 150 or 0
		action._type = "Parry"
		action.hitbox = Vector3.zero
		action.ihbc = false
		action.name = timing.name == "WindSlashProjectile" and "Wind Slash Projectile Timing" or "Wind Blade Timing"
		return self:action(timing, action)
	end

	local thrown = workspace:FindFirstChild("Thrown")
	if not thrown then
		return
	end

	local tracker = ProjectileTracker.new(function(candidate)
		return candidate.Name == "WindSlashProjectile"
	end)

	task.wait(0.5 - Latency.rtt())

	if self:distance(self.entity) <= 20 then
		local action = Action.new()
		action._type = "Parry"
		action._when = 0
		action.name = "Arc Beam Close Timing"
		action.ihbc = true
		return self:action(timing, action)
	end

	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.name = "Wind Slash Part"

	local pt = PartTiming.new()
	pt.uhc = true
	pt.duih = true
	pt.fhb = true
	pt.name = "WindSlashProjectile"
	pt.hitbox = Vector3.new(10, 10, 10)
	pt.actions:push(action)
	pt.cbm = true

	Defense.cdpo(tracker:wait(), pt)
end
