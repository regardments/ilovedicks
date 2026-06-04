---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Mantra
local Mantra = getfenv().Mantra

---Module function.
---@param self AnimatorDefender
---@param timing AnimationTiming
return function(self, timing)
	local hrp = self.entity:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	timing.pbfb = true
	timing.ndfb = true

	local player = game:GetService("Players"):GetPlayerFromCharacter(self.entity)
	local backpack = player and player:FindFirstChild("Backpack")
	if not backpack then return end

	local fireMantra = nil
	local iceMantra = nil

	for _, item in next, backpack:GetChildren() do
		if item.Name:find("SquadFire") then
			fireMantra = item
			break
		elseif item.Name:find("SquadIce") then
			iceMantra = item
			break
		end
	end

	if fireMantra then
		local data = Mantra.data(self.entity, fireMantra.Name)
		local range = data.stratus * 2 + data.cloud * 1

		timing.bfht = 1

		local action = Action.new()
		action._when = 325
		action._type = "Parry"
		action.hitbox = Vector3.new(30 + range, 25, 30 + range)
		action.name = "(1) Burning Servants Timing"
		self:action(timing, action)

		local secondAction = Action.new()
		secondAction._when = 2200
		secondAction._type = "Parry"
		secondAction.hitbox = Vector3.new(30 + range, 25, 30 + range)
		secondAction.name = "(2) Burning Servants Timing 2"
		return self:action(timing, secondAction)
	elseif iceMantra then
		local data = Mantra.data(self.entity, iceMantra.Name)
		local range = data.stratus * 2 + data.cloud * 1

		local action3 = Action.new()
		action3._when = 750
		action3._type = "Parry"
		action3.hitbox = Vector3.new(20 + range, 25, 20 + range)
		action3.name = "(1) Frozen Servants Timing"
		self:action(timing, action3)

		local action4 = Action.new()
		action4._when = 1050
		action4._type = "Parry"
		action4.hitbox = Vector3.new(20 + range, 25, 20 + range)
		action4.name = "(2) Frozen Servants Timing 2"
		return self:action(timing, action4)
	end
end
