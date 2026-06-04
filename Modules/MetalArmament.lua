---@type Action
local Action = getfenv().Action

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local part = self.part
	local localChar = game.Players.LocalPlayer.Character

	if localChar and part:IsDescendantOf(localChar) then
		self:notify(timing, "Skipped - local player")
		return
	end

	local parent = part.Parent
	if not parent then
		self:notify(timing, "Skipped - no parent")
		return
	end

	local handle = parent:FindFirstChild("Handle")
	if not handle then
		self:notify(timing, "Skipped - no handle found")
		return
	end

	local hrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
	local enemyHrp = parent.Parent and parent.Parent:FindFirstChild("HumanoidRootPart")

	self.part = handle

	local action = Action.new()

	if part.Name == "MetalSword" then
		if hrp and enemyHrp then
			local dist = (hrp.Position - enemyHrp.Position).Magnitude
			if dist > 50 then
				return
			end
		end
		self:notify(timing, "Metal Armament detected")
		action._when = 400
		action._type = "Parry"
		action.hitbox = Vector3.new(31, 31, 31)
		action.name = "MetalArmament"
	elseif part.Name == "BladePart" then
		if hrp and enemyHrp then
			local dist = (hrp.Position - enemyHrp.Position).Magnitude
			if dist > 118 then
				return
			end
		end
		self:notify(timing, "Grand Warden Axe detected")
		action._when = 800
		action._type = "Parry"
		action.hitbox = Vector3.new(32, 18, 32)
		action.name = "GrandWardenAxe"
	else
		return
	end

	return self:action(timing, action)
end
