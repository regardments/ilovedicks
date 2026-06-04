-- Interaction utility.
local Interactions = {}

---@module Utility.Logger
local Logger = require("Utility/Logger")

-- Services.
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Constants.
local DEBUGGING_MODE = true

---Telemetry log.
local function telemetryLog(...)
	if not DEBUGGING_MODE then
		return
	end

	Logger.warn(...)
end

---Use a tool.
---@param tool Instance
---@param data any Response to interaction to send with the tool use.
function Interactions.utool(tool, data)
	-- Equip tool.
	Interactions.etool(tool)

	-- Keep activating the tool until a 'ChoicePrompt' appears.
	telemetryLog("Activating tool '%s' until ChoicePrompt appears.", tool.Name)

	local playerGui = players.LocalPlayer:WaitForChild("PlayerGui")
	local choicePrompt = nil

	while not choicePrompt do
		-- Activate.
		tool:Activate()

		-- Check for 'ChoicePrompt' in GUI.
		choicePrompt = playerGui:FindFirstChild("ChoicePrompt")

		-- Wait.
		task.wait()
	end

	-- Fire the choice.
	telemetryLog("Firing ChoicePrompt ('%s') with data.", tostring(data))

	local choice = choicePrompt:WaitForChild("Choice")
	choice:FireServer(data)

	-- Wait for it to disappear.
	telemetryLog("Waiting for ChoicePrompt to disappear...")

	repeat
		task.wait()
	until not choicePrompt.Parent

	-- Done.
	telemetryLog("ChoicePrompt has disappeared.")
end

---Equip a tool.
---@param tool Instance
function Interactions.etool(tool)
	local character = players.LocalPlayer.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	repeat
		-- Equip tool.
		humanoid:EquipTool(tool)

		-- Wait.
		task.wait()
	until tool.Parent == players.LocalPlayer.Character
end

---Perform an NPC-style interaction and go through the dialogue.
---@param instance Model
---@param actions table
---@param teleport boolean Should we teleport to the instance?
function Interactions.interact(instance, actions, teleport)
	if not instance or not instance.Parent then
		return
	end

	local interactPrompt = instance:FindFirstChild("InteractPrompt")
	if not interactPrompt or not interactPrompt:IsA("ProximityPrompt") then
		return
	end

	-- Step 1. Wait until we get dialogue and keep interacting until so.
	telemetryLog("(%s) Interacting until dialogue appears.", instance.Name)

	local playerGui = players.LocalPlayer:WaitForChild("PlayerGui")
	local dialogueGui = playerGui:WaitForChild("DialogueGui")
	local character = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait()

	repeat
		-- Teleport.
		if teleport then
			character:PivotTo(instance:GetPivot())
		end

		-- Fire.
		fireproximityprompt(interactPrompt)

		-- Wait.
		task.wait()
	until dialogueGui.Enabled

	-- Step 2. Go through the dialogue.
	telemetryLog("(%s) Going through dialogue with %i actions.", instance.Name, #actions)

	local requests = replicatedStorage:WaitForChild("Requests")
	local dialogueEvent = requests:WaitForChild("SendDialogue")

	local dialogueCompleted = false

	dialogueEvent.OnClientEvent:Connect(function()
		dialogueCompleted = true
	end)

	for _, action in next, actions do
		dialogueEvent:FireServer(action)

		dialogueCompleted = false

		telemetryLog(
			"(%s) Sent dialogue action '%s' and now waiting for OnClientEvent to fire.",
			instance.Name,
			action.exit and "[EXIT]" or (action.choice or "N/A")
		)

		if action.exit then
			break
		end

		repeat
			task.wait()
		until dialogueCompleted
	end

	telemetryLog("(%s) Completed dialogue.", instance.Name)
end

-- Return Interactions module.
return Interactions
