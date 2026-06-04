---@type PartTiming
local PartTiming = getfenv().PartTiming

---@module Features.Combat.Defense
local Defense = getfenv().Defense

---@type Action
local Action = getfenv().Action

---@module Utility.TaskSpawner
local TaskSpawner = getfenv().TaskSpawner

---@module Game.Latency
local Latency = getfenv().Latency

-- Services.
local players = game:GetService("Players")

---Check if the ParaHook is aiming at the local player.
---@param hook BasePart
---@return boolean
local function isAimingAtPlayer(hook)
	local character = players.LocalPlayer and players.LocalPlayer.Character
	if not character then return false end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	local toPlayer = (rootPart.Position - hook.Position).Unit
	return hook.CFrame.UpVector:Dot(toPlayer) < -0.75
end

---Module function.
---@param self SoundDefender
---@param timing SoundTiming
return function(self, timing)
	local part = self.part
	if not part then return end
	if not part.Name:match("ParaHook") then return end

	-- Poll aiming continuously for 1000ms.
	local isAiming = false
	local startTime = os.clock()
	while (os.clock() - startTime) < 1 do
		if not part.Parent then return end
		if isAimingAtPlayer(part) then
			isAiming = true
			break
		end
		task.wait()
	end
	if not isAiming then return end

	-- Close range: delayed parry via spawned task (survives sound destruction).
	local elapsed = os.clock() - startTime
	if self:distance(part) <= 100 then
		TaskSpawner.spawn("ParasolTendrilClose", function()
			task.wait(math.max(0, 1.35 - Latency.rtt() - elapsed))
			local action = Action.new()
			action._when = 0
			action._type = "Parry"
			action.ihbc = true
			action.name = "Parasol Tendril Close Parry"
			self:action(timing, action)
		end)
		return
	end

	-- Far range: track the hook with duih.
	local action = Action.new()
	action._when = 0
	action._type = "Parry"
	action.ihbc = true
	action.name = "Parasol Tendril Parry"

	local pt = PartTiming.new()
	pt.uhc = true
	pt.duih = true
	pt.fhb = false
	pt.name = "Parasol Tendril"
	pt.hitbox = Vector3.new(25, 200, 25)
	pt.actions:push(action)
	pt.cbm = true

	Defense.cdpo(part, pt)
end
