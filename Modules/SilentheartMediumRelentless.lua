---@class Action
local Action = getfenv().Action

---Module function for Silentheart Medium Relentless.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 150
	action._type = "Parry"
	action.hitbox = Vector3.new(14, 14, 18)
	action.name = "Silentheart Medium Relentless"
	return self:action(timing, action)
end
