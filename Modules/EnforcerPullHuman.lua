---@type Action
local Action = getfenv().Action

-- Services.
local players = game:GetService("Players")

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	---@todo: I'm lazy; doesn't actually check for the move. Just assumes it's being used.
	local player = players:GetPlayerFromCharacter(self.entity)
	if not player then
		return
	end

	local playerPassives = self.entity and self.entity:GetAttribute("ssv_Passives")
	local playerBackpack = player:FindFirstChild("Backpack")
	local assumeJailer = (playerPassives and playerPassives:find("Rending Needle: Jailer")) or (playerBackpack and playerBackpack:FindFirstChild("Talent:Rending Needle: Jailer"))

	local action = Action.new()
	action._when = assumeJailer and 0 or 700
	action._type = "Parry"
	action.hitbox = Vector3.new(100, 100, 100)
	action.name = assumeJailer and "Jailer Timing" or "Enforcer Pull Human Timing"

	return self:action(timing, action)
end
