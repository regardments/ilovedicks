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
	action._type = "Parry"
	action.hitbox = Vector3.new(25, 20, 20)
	action.name = "Knell Flurry Timing 1"
	self:action(timing, action)

	local actionTwo = Action.new()
	actionTwo._when = 1000
	actionTwo._type = "Parry"
	actionTwo.hitbox = Vector3.new(25, 20, 20)
	actionTwo.name = "Knell Flurry Timing 2"
	self:action(timing, actionTwo)

	local actionThree = Action.new()
	actionThree._when = 1300
	actionThree._type = "Parry"
	actionThree.hitbox = Vector3.new(25, 20, 20)
	actionThree.name = "Knell Flurry Timing 3"
	self:action(timing, actionThree)

	local actionFour = Action.new()
	actionFour._when = 1600
	actionFour._type = "Parry"
	actionFour.hitbox = Vector3.new(25, 20, 20)
	actionFour.name = "Knell Flurry Timing 4"
	self:action(timing, actionFour)

	local actionFive = Action.new()
	actionFive._when = 1850
	actionFive._type = "Parry"
	actionFive.hitbox = Vector3.new(25, 20, 20)
	actionFive.name = "Knell Flurry Timing 5"
	self:action(timing, actionFive)

	local actionSix = Action.new()
	actionSix._when = 2250
	actionSix._type = "Parry"
	actionSix.hitbox = Vector3.new(25, 20, 20)
	actionSix.name = "Knell Flurry Timing 6"
	return self:action(timing, actionSix)
end
