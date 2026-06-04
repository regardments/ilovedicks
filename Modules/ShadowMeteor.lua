---@class Action
local Action = getfenv().Action

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@param self PartDefender
---@param timing PartTiming
return function(self, timing)
	local effectReplicator = ReplicatedStorage:FindFirstChild("EffectReplicator")
	if effectReplicator then
		local effectReplicatorModule = require(effectReplicator)
		if effectReplicatorModule then
			for _, effect in next, effectReplicatorModule:GetEffectsOfClass("ToolLockCD") do
				if effect.index and effect.index.Value then
					if tostring(effect.index.Value):find("PalmShadow") and effect.index.DebrisTime == nil then
						self:notify(timing, "Shadow Meteor (Local | Skipped)")
						return
					end
				end
			end
		end
	end

	self:notify(timing, "Shadow Meteor Dynamic Timing")

	local action = Action.new()
	action._when = 500
	action._type = "Parry"
	action.name = "Shadow Meteor"
	action.hitbox = timing.hitbox

	return self:action(timing, action)
end
