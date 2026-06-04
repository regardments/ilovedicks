---@class Action
local Action = getfenv().Action

---Module function for rapier critical.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.pfh = true
	timing.phd = true
	timing.pfht = 0.25
	timing.phds = 0.8

	local action = Action.new()
	action._when = 500
	action._type = "Parry"
	action.hitbox = Vector3.new(10, 10, 18)
	action.name = "Rapier Critical"
	return self:action(timing, action)
end
