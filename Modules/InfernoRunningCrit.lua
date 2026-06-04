---@class Action
local Action = getfenv().Action

---@module Utility.TaskSpawner
local TaskSpawner = getfenv().TaskSpawner

---@class PartTiming
local PartTiming = getfenv().PartTiming

---@module Features.Combat.Defense
local Defense = getfenv().Defense

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local hrp = self.entity:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	if hrp:WaitForChild("REP_SOUND_15237686618", 0.1) then
		TaskSpawner.spawn("InfernoRunningCrit", function()
			if self:distance(self.entity) <= 35 then
				local action = Action.new()
				action._when = 300
				action._type = "Parry"
				action.ihbc = true
				action.name = "Inferno Running Crit Close"
				return self:action(timing, action)
			end

			local tracker = ProjectileTracker.new(function(candidate)
			return candidate and candidate.Name and string.find(candidate.Name, "Fireball")
			end)

			local projectile = tracker:wait()
			if not projectile or not projectile:IsA("BasePart") then
				return
			end

			local action = Action.new()
			action._when = 0
			action._type = "Parry"
			action.name = "Contact"

			local pt = PartTiming.new()
			pt.uhc = true
			pt.duih = true
			pt.fhb = false
			pt.imxd = 45
			pt.imdd = 0
			pt.name = "FireballInfernoRunningCrit"
			pt.hitbox = Vector3.new(10, 10, 60)
			pt.actions:push(action)
			pt.cbm = true

			Defense.cdpo(projectile, pt)  -- Use the projectile we already got
		end)
	end
end
