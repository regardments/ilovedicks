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
	action._when = 700
	action._type = "Jump"
	action.hitbox = Vector3.new(30, 30, 30)
	action.ihbc = true
	action.name = "Knell Jump Timing"
	return self:action(timing, action)
end
