---@module Modules.Globals.ProjectileListener
local ProjectileListener = getfenv().ProjectileListener

---@type PartTiming
local PartTiming = getfenv().PartTiming

---@type Action
local Action = getfenv().Action

---@module Features.Combat.Defense
local Defense = getfenv().Defense

---@module Game.Latency
local Latency = getfenv().Latency

-- Create listener for Smouldering Hallow projectiles
local plistener = ProjectileListener.new("SmoulderingCrit")

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	if self:distance(self.entity) <= 20 then
		local action = Action.new()
		action._type = "Start Block"
		action._when = 700
		action.name = "Smouldering Crit Start Timing"
		action.hitbox = Vector3.new(18, 18, 25)
		self:action(timing, action)

		local endAction = Action.new()
		endAction._type = "End Block"
		endAction._when = 2500
		endAction.name = "Smouldering Crit End Timing"
		return self:action(timing, endAction)
	end

	plistener:connect(function(child)
		if not child.Name:match("PumpkinProjectile") then
			return
		end

		local action = Action.new()
		action._when = 0
		action._type = "Parry"
		action.name = "Pumpkin Part"

		local pt = PartTiming.new()
		pt.uhc = true
		pt.duih = true
		pt.fhb = false
		pt.name = "PumpkinProjectile"
		pt.hitbox = Vector3.new(25, 25, 25)
		pt.actions:push(action)
		pt.cbm = true

		Defense.cdpo(child, pt)
	end)
end
