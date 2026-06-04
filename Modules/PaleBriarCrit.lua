---@class Action
local Action = getfenv().Action

-- Services.
local players = game:GetService("Players")

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local localChar = players.LocalPlayer.Character
	if not localChar then
		return
	end

	local handWeapon = localChar:FindFirstChild("RightHand") and localChar.RightHand:FindFirstChild("HandWeapon")
	if handWeapon then
		local critical = handWeapon:GetAttribute("Critical")
		if critical == "Pale Briar" then
			local humanoid = localChar:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			if animator then
				for _, track in next, animator:GetPlayingAnimationTracks() do
					if track.Animation and track.Animation.AnimationId:match("16582796768") then
						self:notify(timing, "Skipped - local player crit")
						return
					end
				end
			end
		end
	end

	self:notify(timing, "Pale Briar Crit detected")

	local action = Action.new()
	action._when = 120
	action._type = "Parry"
	action.hitbox = Vector3.new(40, 24, 24)
	action.name = "Pale Briar Crit Timing 1"
	self:action(timing, action)

	local actionTwo = Action.new()
	actionTwo._when = 250
	actionTwo._type = "Parry"
	actionTwo.hitbox = Vector3.new(40, 24, 24)
	actionTwo.name = "Pale Briar Crit Timing 2"
	self:action(timing, actionTwo)

	local actionThree = Action.new()
	actionThree._when = 500
	actionThree._type = "Parry"
	actionThree.hitbox = Vector3.new(40, 24, 24)
	actionThree.name = "Pale Briar Crit Timing 3"
	self:action(timing, actionThree)

	local actionFour = Action.new()
	actionFour._when = 750
	actionFour._type = "Parry"
	actionFour.hitbox = Vector3.new(40, 24, 24)
	actionFour.name = "Pale Briar Crit Timing 4"
	self:action(timing, actionFour)

	local actionFive = Action.new()
	actionFive._when = 1000
	actionFive._type = "Parry"
	actionFive.hitbox = Vector3.new(40, 24, 24)
	actionFive.name = "Pale Briar Crit Timing 5"
	self:action(timing, actionFive)

	local actionSix = Action.new()
	actionSix._when = 1250
	actionSix._type = "Parry"
	actionSix.hitbox = Vector3.new(40, 24, 24)
	actionSix.name = "Pale Briar Crit Timing 6"
	self:action(timing, actionSix)

	local actionSeven = Action.new()
	actionSeven._when = 1500
	actionSeven._type = "Parry"
	actionSeven.hitbox = Vector3.new(40, 24, 24)
	actionSeven.name = "Pale Briar Crit Timing 7"
	self:action(timing, actionSeven)

	local actionEight = Action.new()
	actionEight._when = 1750
	actionEight._type = "Parry"
	actionEight.hitbox = Vector3.new(40, 24, 24)
	actionEight.name = "Pale Briar Crit Timing 8"
	self:action(timing, actionEight)

	local actionNine = Action.new()
	actionNine._when = 2000
	actionNine._type = "Parry"
	actionNine.hitbox = Vector3.new(40, 24, 24)
	actionNine.name = "Pale Briar Crit Timing 9"
	self:action(timing, actionNine)

	local actionTen = Action.new()
	actionTen._when = 2250
	actionTen._type = "Parry"
	actionTen.hitbox = Vector3.new(40, 24, 24)
	actionTen.name = "Pale Briar Crit Timing 10"
	self:action(timing, actionTen)

	local actionEleven = Action.new()
	actionEleven._when = 2500
	actionEleven._type = "Parry"
	actionEleven.hitbox = Vector3.new(40, 24, 24)
	actionEleven.name = "Pale Briar Crit Timing 11"
	self:action(timing, actionEleven)

	local actionTwelve = Action.new()
	actionTwelve._when = 2750
	actionTwelve._type = "Parry"
	actionTwelve.hitbox = Vector3.new(40, 24, 24)
	actionTwelve.name = "Pale Briar Crit Timing 12"
	self:action(timing, actionTwelve)

	local actionThirteen = Action.new()
	actionThirteen._when = 3000
	actionThirteen._type = "Parry"
	actionThirteen.hitbox = Vector3.new(40, 24, 24)
	actionThirteen.name = "Pale Briar Crit Timing 13"
	self:action(timing, actionThirteen)

	local actionFourteen = Action.new()
	actionFourteen._when = 3250
	actionFourteen._type = "Parry"
	actionFourteen.hitbox = Vector3.new(40, 24, 24)
	actionFourteen.name = "Pale Briar Crit Timing 14"
	self:action(timing, actionFourteen)

	local actionFifteen = Action.new()
	actionFifteen._when = 3500
	actionFifteen._type = "Parry"
	actionFifteen.hitbox = Vector3.new(40, 24, 24)
	actionFifteen.name = "Pale Briar Crit Timing 15"
	return self:action(timing, actionFifteen)
end
