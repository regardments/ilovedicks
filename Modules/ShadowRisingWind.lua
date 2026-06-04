---@class Action
local Action = getfenv().Action

---Module function for Shadow Rising Wind.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local action = Action.new()
	action._when = 300
	action._type = "Parry"
	action.hitbox = Vector3.new(20, 25, 20)
	action.name = "Shadow Rising Wind"
	return self:action(timing, action)
end
