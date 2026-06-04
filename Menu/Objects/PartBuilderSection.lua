---@module Menu.Objects.BuilderSection
local BuilderSection = require("Menu/Objects/BuilderSection")

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Game.Timings.PartTiming
local PartTiming = require("Game/Timings/PartTiming")

---@class PartBuilderSection: BuilderSection
---@field partName table
---@field timingDelay table
---@field initialMinimumDistance table
---@field initialMaximumDistance table
---@field timing PartTiming
local PartBuilderSection = setmetatable({}, { __index = BuilderSection })
PartBuilderSection.__index = PartBuilderSection

---Check before writing.
---@return boolean
function PartBuilderSection:check()
	if not BuilderSection.check(self) then
		return false
	end

	if not self.partName.Value or #self.partName.Value <= 0 then
		return Logger.longNotify("Please enter a valid part name.")
	end

	if self.pair:index(self.partName.Value) then
		return Logger.longNotify("The timing ID '%s' is already in the list.", self.partName.Value)
	end

	return true
end

---Load the extra elements. Override me.
---@param timing Timing
function PartBuilderSection:exload(timing)
	self.useHitboxCFrame:SetRawValue(timing.uhc)
	self.partName:SetRawValue(timing.pname)
end

---Reset the elements. Extend me.
function PartBuilderSection:reset()
	BuilderSection.reset(self)
	self.partName:SetRawValue("")
end

---Set creation timing properties. Override me.
---@param timing PartTiming
function PartBuilderSection:cset(timing)
	timing.name = self.timingName.Value
	timing.pname = self.partName.Value
end

---Create new timing. Override me.
---@return PartTiming
function PartBuilderSection:create()
	local timing = PartTiming.new()
	self:cset(timing)
	return timing
end

---Create timing ID element. Override me.
---@param tab table
function PartBuilderSection:tide(tab)
	self.partName = tab:AddInput(nil, {
		Text = "Part Name",
	})
end

---Initialize extra tab.
---@param tab table
function PartBuilderSection:extra(tab)
	self.useHitboxCFrame = tab:AddToggle(nil, {
		Text = "Use Hitbox CFrame",
		Tooltip = "Should the hitbox face where it was originally supposed to?",
		Default = true,
		Callback = self:tnc(function(timing, value)
			timing.uhc = value
		end),
	})
end

---Initialize PartBuilderSection object.
function PartBuilderSection:init()
	self:timing()
	self:builder()
	self:action()
end

---Create new PartBuilderSection object.
---@param name string
---@param tabbox table
---@param pair TimingContainerPair
---@param timing PartTiming
---@return PartBuilderSection
function PartBuilderSection.new(name, tabbox, pair, timing)
	return setmetatable(BuilderSection.new(name, tabbox, pair, timing), PartBuilderSection)
end

-- Return PartBuilderSection module.
return PartBuilderSection
