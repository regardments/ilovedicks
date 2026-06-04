---@module Modules.Globals.ProjectileListener
local ProjectileListener = getfenv().ProjectileListener

---@class Action
local Action = getfenv().Action

---@module Features.Combat.Defense
local Defense = getfenv().Defense

---@module Game.Timings.PartTiming
local PartTiming = getfenv().PartTiming

---@module Modules.Globals.Mantra
local Mantra = getfenv().Mantra

-- Listener object.
local plistener = ProjectileListener.new("FiringLine")

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local distance = self:distance(self.entity)
	local mantra = Mantra.data(self.entity, "Mantra:GunMetal{{Firing Line}}")

	-- Cannon variant.
	if distance <= 20 and mantra.blast then
		timing.iae = true
		timing.mat = 1000

		local action = Action.new()
		action._when = 600
		action._type = "Start Block"
		action.name = "(1) Firing Line Close Timing"
		action.ihbc = true
		self:action(timing, action)

		local actionTwo = Action.new()
		actionTwo._when = 1000
		actionTwo._type = "End Block"
		actionTwo.name = "(2) Firing Line Close Timing"
		actionTwo.ihbc = true
		return self:action(timing, actionTwo)
	end

	plistener:connect(function(child)
		if child.Name ~= "MetalBullet" and child.Name ~= "CannonBullet" then
			return
		end

		local action = Action.new()
		action._when = 0
		action._type = "Parry"
		action.name = "Bullet Part"

		local pt = PartTiming.new()
		pt.uhc = true
		pt.duih = true
		pt.fhb = true
		pt.ndfb = true
		pt.name = "BulletProjectile"
		pt.hitbox = Vector3.new(100, 100, 100)
		pt.actions:push(action)
		pt.cbm = true

		Defense.cdpo(child, pt)
	end)
end
