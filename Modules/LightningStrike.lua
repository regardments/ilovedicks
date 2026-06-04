---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Finder
local Finder = getfenv().Finder

---Module function.
---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local part = self.part
	if not part then return end

	-- Ignore if stormblade is active (LightningSword in Thrown near player).
	local thrown = workspace:FindFirstChild("Thrown")
	if thrown then
		for _, child in next, thrown:GetChildren() do
			if child.Name == "LightningSword" and self:distance(child) <= 50 then
				return
			end
		end
	end

	-- Parasol present: delayed parry with ignore hitbox check.
	if Finder.entity("parasol") then
		local action = Action.new()
		action._when = 600
		action._type = "Parry"
		action.ihbc = true
		action.name = "Lightning Strike (Parasol)"
		return self:action(timing, action)
	end
end
