---@class Action
local Action = getfenv().Action

---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	if self.entity and self.entity.Name:lower():match("titus") then
		local dodge = Action.new()
		dodge._when = 250
		dodge._type = "Forced Full Dodge"
		dodge.name = "Flame Sentinel Titus Dodge"
		dodge.hitbox = Vector3.zero
		dodge.ihbc = true

		return self:action(timing, dodge)
	end

	local parry = Action.new()
	parry._when = 0
	parry._type = "Parry"
	parry.name = "Flame Sentinel Parry"
	parry.hitbox = timing.hitbox

	return self:action(timing, parry)
end
