---@type Action
local Action = getfenv().Action

---@module Modules.Globals.Waiter
local Waiter = getfenv().Waiter

---@module Utility.Finder
local Finder = getfenv().Finder

-- Services.
local players = game:GetService("Players")

---Module function.
---@param self SoundDefender
---@param timing SoundTiming
return function(self, timing)
	if not self.owner then
		return
	end

	local localCharacter = players.LocalPlayer and players.LocalPlayer.Character
	if not localCharacter then
		return
	end

	if self.owner ~= localCharacter then
		return
	end

	if not Finder.entity("lordregent") then
		return
	end
end
