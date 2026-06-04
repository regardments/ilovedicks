---@class Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	if self.entity.Name:lower():match("knell") then
		timing.forced = true
	end

	local action = Action.new()
	action._when = 1400
	action._type = "Dodge"
	action.hitbox = Vector3.new(30, 30, 30)
	action.name = "Knell Bell Swing Timing"
	return self:action(timing, action)
end
