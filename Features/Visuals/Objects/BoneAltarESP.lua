---@module Features.Visuals.Objects.ModelESP
local ModelESP = require("Features/Visuals/Objects/ModelESP")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

---@class BoneAltarESP: ModelESP
local BoneAltarESP = setmetatable({}, { __index = ModelESP })
BoneAltarESP.__index = BoneAltarESP
BoneAltarESP.__type = "BoneAltarESP"

---Update BoneAltarESP.
---@param self BoneAltarESP
BoneAltarESP.update = LPH_NO_VIRTUALIZE(function(self)
	local model = self.model

	local boneSpear = model:FindFirstChild("BoneSpear")

	if Configuration.idToggleValue(self.identifier, "HideIfBoneInside") and boneSpear then
		return self:visible(false)
	end

	ModelESP.update(self, {})
end)

---Create new BoneAltarESP object.
---@param identifier string
---@param model Model
---@param label string
function BoneAltarESP.new(identifier, model, label)
	return setmetatable(ModelESP.new(identifier, model, label), BoneAltarESP)
end

-- Return BoneAltarESP module.
return BoneAltarESP
