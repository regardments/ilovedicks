---@class Action
local Action = getfenv().Action

---Module function for heavy aerial attack.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 100
	action._type = "Parry"
	action.hitbox = Vector3.new(12, 18, 18)
	action.name = "Heavy Aerial"
	return self:action(timing, action)
end
