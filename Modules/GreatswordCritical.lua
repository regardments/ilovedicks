---@class Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.pfh = true
	timing.phd = true
	timing.pfht = 0.3
	timing.phds = 1.0

	local action = Action.new()
	action._when = 700
	action._type = "Parry"
	action.hitbox = Vector3.new(20, 20, 20)
	action.name = "Static Greatsword Critical"
	return self:action(timing, action)
end
