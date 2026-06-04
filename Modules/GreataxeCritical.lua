---@class Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.pfh = true
	timing.phd = true
	timing.pfht = 0.3
	timing.phds = 1.0

	local rightHand = self.entity:FindFirstChild("RightHand")
	local leftHand = self.entity:FindFirstChild("LeftHand")
	if not rightHand or not leftHand then
		return
	end

	local handWeapon = rightHand:FindFirstChild("HandWeapon") or leftHand:FindFirstChild("HandWeapon")
	if not handWeapon then
		return
	end

	local distance = self:distance(self.entity)

	if handWeapon:GetAttribute("WeaponName") == "Relic Axe" then
		local action = Action.new()
		action._when = 750
		action._type = "Parry"
		action.hitbox = Vector3.new(15, 30, 40)
		action.name = string.format("(%.2f) Dynamic Relic Axe Critical", distance)
		return self:action(timing, action)
	end

	local action = Action.new()
	action._when = 750
	action._type = "Parry"
	action.hitbox = Vector3.new(15, 15, 20)
	action.name = "Static Greataxe Critical"
	return self:action(timing, action)
end
