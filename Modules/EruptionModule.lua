---@class Action
local Action = getfenv().Action

---@class Signal
local Signal = getfenv().Signal

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local onDescendantAdded = Signal.new(self.part.DescendantAdded)

	self.tmaid:add(onDescendantAdded:connect("LavaSerpent_WindupListener", function(child)
		if child.Name == "CLIENT_SOUND_5033484755" then
			local action = Action.new()
			action._when = 1100
			action._type = "Parry"
			action.hitbox = Vector3.new(20, 20, 20)
			action.name = "Lava Serpent Windup"
			return self:action(timing, action)
		end
	end))
end
