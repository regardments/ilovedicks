---@class Action
local Action = getfenv().Action

---Module function for dagger aerial attack.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.hitbox = Vector3.new(10, 15, 15)
	action.name = "Dagger Aerial"
	return self:action(timing, action)
end
