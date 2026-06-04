---@class Action
local Action = getfenv().Action

---Module function for Silentheart Light Relentless.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 100
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 12, 18)
	action.name = "Silentheart Light Relentless"
	return self:action(timing, action)
end
