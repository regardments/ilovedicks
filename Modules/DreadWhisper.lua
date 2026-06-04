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
	action._when = 350
	action._type = "Parry"
	action.hitbox = Vector3.new(14, 10, 19)
	action.name = "Dread Whisper Timing"
	return self:action(timing, action)
end
