---@type Action
local Action = getfenv().Action

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	timing.ffh = true

	local distance = self:distance(self.entity)
	local player = game:GetService("Players"):GetPlayerFromCharacter(self.entity)
	local backpack = player and player:FindFirstChild("Backpack")

	local hasBlastSpark = false

	if backpack then
		for _, item in next, backpack:GetChildren() do
			if item.Name:find("GunWind") then
				local richStats = item:GetAttribute("RichStats")
				if richStats and richStats:find("Blast Spark") then
					hasBlastSpark = true
				end
				break
			end
		end
	end

	if hasBlastSpark then
		local action = Action.new()
		action._when = 500
		action._type = "Parry"
		action.hitbox = Vector3.new(30, 20, 40)
		action.name = string.format("(%.2f) Wind Gun (Blast Spark)", distance)

		return self:action(timing, action)
	else
		local action = Action.new()
		action._when = 400

		if distance >= 20 then
			action._when = 500
		end

		action._type = "Parry"
		action.hitbox = Vector3.new(30, 20, 40)
		action.name = string.format("(%.2f) Dynamic Wind Gun Timing", distance)

		return self:action(timing, action)
	end
end
