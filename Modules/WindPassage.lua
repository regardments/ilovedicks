---@type Action
local Action = getfenv().Action

---@module Utility.Finder
local Finder = getfenv().Finder

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local entity = Finder.entity("evengarde")

	-- Maestro detection.
	if entity then
		local action = Action.new()
		action._when = 370
		action._type = "Parry"
		action.hitbox = Vector3.new(31, 31, 100)
		action.name = "Maestro Wind Passage Timing"
		return self:action(timing, action)
	end

	-- Normal.
	local action = Action.new()
	action._when = 250
	action._type = "Parry"
	action.hitbox = Vector3.new(31, 31, 80)
	action.name = "Wind Passage Timing"
	return self:action(timing, action)
end
