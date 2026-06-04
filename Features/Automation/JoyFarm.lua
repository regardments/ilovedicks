-- JoyFarm module.
local JoyFarm = {}

---@module Game.AntiAFK
local AntiAFK = require("Game/AntiAFK")

---@module Features.Game.Tweening
local Tweening = require("Features/Game/Tweening")

---@module Utility.FiniteState
local FiniteState = require("Utility/FiniteState")

---@module Utility.FiniteStateMachine
local FiniteStateMachine = require("Utility/FiniteStateMachine")

---@module Utility.Finder
local Finder = require("Utility/Finder")

---@module Utility.Table
local Table = require("Utility/Table")

---@module Game.Latency
local Latency = require("Game/Latency")

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Game.InputClient
local InputClient = require("Game/InputClient")

---@module Utility.TaskSpawner
local TaskSpawner = require("Utility/TaskSpawner")

-- Maid.
local joyFarmMaid = Maid.new()

-- Services.
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Hooks.
local oldGetMouseInvoke = nil

-- Cached target.
local cachedTarget = nil

-- Tweening offset.
local offsetCFrame = CFrame.new(0.0, 30.0, 0.0)

-- Obstacles map. Position to radius.
local OBSTACLES_MAP = {
	-- Big castles.
	{ pos = Vector3.new(-16837.07, 50.97, 12143.41), radius = 20 },

	-- Small castles.
	{ pos = Vector3.new(-16848.69, 50.87, 12182.70), radius = 10 },
	{ pos = Vector3.new(-16849.81, 56.64, 12104.16), radius = 10 },
	{ pos = Vector3.new(-16752.79, 53.05, 12054.92), radius = 10 },
}

---Target a part.
---@param part BasePart
local function targetPart(part)
	local requests = replicatedStorage:WaitForChild("Requests")
	local getMouse = requests:WaitForChild("GetMouse")

	if not oldGetMouseInvoke then
		oldGetMouseInvoke = getcallbackvalue(getMouse, "OnClientInvoke")
	end

	-- Override OnClientInvoke with new data.
	---@todo: Spoof better later with proper 1:1 InputClient data.
	getMouse.OnClientInvoke = function()
		---@note: Add some prediction to prevent mobs from running in a straight line.
		local currentCamera = workspace.CurrentCamera
		local at = part.CFrame + (part.AssemblyLinearVelocity * (0.25 + Latency.rtt()))
		local pos = currentCamera:WorldToViewportPoint(at.Position)
		local ray = currentCamera:ViewportPointToRay(pos.X, pos.Y)

		-- Return spoofed data.
		return {
			["Hit"] = at,
			["Target"] = part,
			["UnitRay"] = ray,
			["X"] = pos.X,
			["Y"] = pos.Y,
		}
	end
end

---Attack at obstacles.
local function attackAtObstacles()
	for _, obstacle in next, OBSTACLES_MAP do
		local entity = Finder.enear(obstacle.pos, obstacle.radius)
		if not entity then
			continue
		end

		-- Root part?
		local targetHrp = entity:FindFirstChild("HumanoidRootPart")
		if not targetHrp then
			continue
		end

		-- Target part.
		targetPart(targetHrp)

		-- Start attacking the target.
		InputClient.left(targetHrp.CFrame, true)

		-- Return.
		return true
	end

	return false
end
---Attack valid targets.
local function attackValidTargets()
	local targets = Finder.geir(300, true)
	if not targets then
		return true
	end

	local activeTarget = cachedTarget or targets[1]
	if not activeTarget then
		return true
	end

	if not activeTarget.Parent then
		return false
	end

	local targetHrp = activeTarget:FindFirstChild("HumanoidRootPart")
	if not targetHrp then
		return false
	end

	local targetHumanoid = activeTarget:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return false
	end

	if targetHumanoid.Health <= 0 then
		return false
	end

	cachedTarget = activeTarget

	-- Tween to target.
	local targetPosition = (targetHrp.CFrame * offsetCFrame).Position
	local goalCFrame = CFrame.lookAt(targetPosition, targetHrp.Position)

	Tweening.stop("JoyFarm_TweenAboveShrine")
	Tweening.goal("JoyFarm_TweenToTarget", goalCFrame, false)

	-- Target part.
	targetPart(targetHrp)

	-- Start attacking the target.
	InputClient.left(targetHrp.CFrame, true)

	-- Return true indicating we attacked a valid target.
	return true
end

-- States.
local jfIdleState = FiniteState.new("Idle", function(_, machine)
	-- Activate shrine.
	local shrine = Finder.wshrine()
	local interactPrompt = shrine:WaitForChild("InteractPrompt")

	Tweening.goal("JoyFarm_TweenToShrine", shrine:GetPivot(), false)

	while task.wait() do
		-- Fire prompt.
		fireproximityprompt(interactPrompt)

		-- Check if "Wave 1" was detected.
		local prompts = Finder.sprompts()
		local detected = Table.find(prompts, function(value, _)
			return value:lower():match("wave 1")
		end)

		-- Break out of loop, if so.
		if detected then
			break
		end
	end

	-- Break out of idle state.
	return machine:transition("Attack")
end, function()
	-- Stop tweens.
	Tweening.stop("JoyFarm_TweenToShrine")
end)

local jfAttackState = FiniteState.new("Attack", function(_, machine)
	-- Attack loop.
	while task.wait() do
		-- Check if "Final Wave Cleared" was detected.
		local prompts = Finder.sprompts()
		local detected = Table.find(prompts, function(value, _)
			return value:lower():match("final wave cleared")
		end)

		-- Transition us to idle state, if so.
		if detected then
			return machine:transition("Idle")
		end

		-- Tween us above the shrine. If we're attempting to attack a valid target, this will be overriden!
		local shrine = Finder.wshrine()
		Tweening.goal("JoyFarm_TweenAboveShrine", shrine:GetPivot() * offsetCFrame, false)
		Tweening.stop("JoyFarm_TweenToTarget")

		-- Check if anyone is near any obstacles?
		if attackAtObstacles() then
			continue
		end

		-- Attack valid targets.
		if attackValidTargets() then
			continue
		end

		-- We must clear the cached target if we failed to attack valid targets.
		cachedTarget = nil
	end
end, function()
	-- Stop tweens.
	Tweening.stop("JoyFarm_TweenAboveShrine")
	Tweening.stop("JoyFarm_TweenToTarget")

	-- Reset "OnClientInvoke" spoof.
	---@todo: Make this more perfect later and add a silent aim.

	local requests = replicatedStorage:WaitForChild("Requests")
	local getMouse = requests:WaitForChild("GetMouse")

	if oldGetMouseInvoke then
		getMouse.OnClientInvoke = oldGetMouseInvoke
	end
end)

-- State machine.
local jfStateMachine = FiniteStateMachine.new({ jfIdleState, jfAttackState }, "Idle")

---Start JoyFarm module.
function JoyFarm.start()
	AntiAFK.start("JoyFarm")
	joyFarmMaid:add(TaskSpawner.spawn("JoyFarm_StateMachineStart", jfStateMachine.start, jfStateMachine))
end

---Stop JoyFarm module.
function JoyFarm.stop()
	AntiAFK.stop("JoyFarm")
	jfStateMachine:stop()
	joyFarmMaid:clean()
end

return JoyFarm
