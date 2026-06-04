-- QueuedBlocking module. Allows of easy control of blocking without failure (e.g constant blocking randomly or w/e) and being frame-perfect.
local QueuedBlocking = {
	BLOCK_TYPE_DEFLECT = 1, -- For parry/deflect frames. This means it will get removed as soon as we are considered as blocking.
	BLOCK_TYPE_NORMAL = 2, -- For normal blocking. This means it will stay in the queue until dead time expires or manually removed.
}

---@module Game.InputClient
local InputClient = require("Game/InputClient")

---@module Game.KeyHandling
local KeyHandling = require("Game/KeyHandling")

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Utility.Signal
local Signal = require("Utility/Signal")

---@module Utility.Maid
local Maid = require("Utility/Maid")

-- Maids.
local qiMaid = Maid.new()

-- Queue.
local blockQueue = {}

-- Services.
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- Cached references.
local cachedStateListener = nil

---Get cached StateListener module.
local function getStateListener()
	if cachedStateListener then
		return cachedStateListener
	end

	local success, result = pcall(require, "Features/Combat/StateListener")
	if success and result then
		cachedStateListener = result
	end

	return cachedStateListener
end

---On render stepped.
local function onRenderStepped()
	local effectReplicator = replicatedStorage:FindFirstChild("EffectReplicator")
	if not effectReplicator then
		return
	end

	local effectReplicatorModule = require(effectReplicator)
	if not effectReplicatorModule then
		return
	end

	local blockRemote = KeyHandling.getRemote("Block")
	if not blockRemote then
		return
	end

	local unblockRemote = KeyHandling.getRemote("Unblock")
	if not unblockRemote then
		return
	end

	local inputData = InputClient.getInputData()
	if not inputData then
		return
	end

	local stateListener = getStateListener()
	if stateListener and stateListener.hblock() then
		return QueuedBlocking.empty()
	end

	-- Are we blocking?
	local blocking = effectReplicatorModule:HasEffect("Blocking")

	-- Set up input data.
	inputData["f"] = true

	-- Process entries that need to be killed.
	for id, data in next, blockQueue do
		local dead = data.dt and os.clock() - data.start >= data.dt
		local deflected = data.type == QueuedBlocking.BLOCK_TYPE_DEFLECT and blocking

		if not deflected and not dead then
			continue
		end

		QueuedBlocking.stop(id)
	end

	-- Calculate if we have something in the queue.
	local blockQueueLength = 0

	for _, _ in next, blockQueue do
		blockQueueLength = blockQueueLength + 1
	end

	-- Handle blocking input.
	inputData["f"] = blockQueueLength > 0

	-- Call with direct functions so our hooks call...
	local fireServer = Instance.new("RemoteEvent").FireServer

	if blocking then
		return blockQueueLength <= 0 and fireServer(unblockRemote)
	end

	if not effectReplicatorModule:FindEffect("Action") and not effectReplicatorModule:FindEffect("Knocked") then
		return blockQueueLength > 0 and fireServer(blockRemote)
	end
end

---Invoke a block action.
---@param type number The block type.
---@param id string Identifier tied to this action.
---@param dt number?
function QueuedBlocking.invoke(type, id, dt)
	local effectReplicator = replicatedStorage:FindFirstChild("EffectReplicator")
	if not effectReplicator then
		return
	end

	local effectReplicatorModule = require(effectReplicator)
	if not effectReplicatorModule then
		return
	end

	local blockRemote = KeyHandling.getRemote("Block")
	if not blockRemote then
		return Logger.warn("QueuedBlocking.invoke(...) - Missing block remote.")
	end

	local sprintFunction = InputClient.sprintFunctionCache
	local inputData = InputClient.getInputData()

	if not sprintFunction or not inputData then
		return Logger.warn(
			"QueuedBlocking.invoke(...) - (%s, %s) - Missing important data.",
			tostring(sprintFunction),
			tostring(inputData)
		)
	end

	local bufferEffect = effectReplicatorModule:FindEffect("M1Buffering")

	if bufferEffect then
		bufferEffect:Remove()
	end

	if effectReplicatorModule:HasEffect("CastingSpell") then
		return
	end

	blockRemote:FireServer()

	inputData["f"] = true

	sprintFunction(false)

	Logger.warn(
		"QueuedBlocking.invoke(...) - (at %.2f) Invoking block action '%s' of type %d with dead time (%s) to queue.",
		os.clock(),
		tostring(id),
		type,
		tostring(dt)
	)

	blockQueue[id] = {
		start = os.clock(),
		type = type,
		dt = dt,
	}
end

---Empty the block queue.
function QueuedBlocking.empty()
	blockQueue = {}
end

---Stop a block action from the queue.
---@param id string The block action ID.
function QueuedBlocking.stop(id)
	if not blockQueue[id] then
		return
	end

	-- Log.
	Logger.warn("QueuedBlocking.stop(...) - Stopping block action '%s' in queue.", tostring(id))

	-- Remove.
	blockQueue[id] = nil
end

---Initialize QueuedBlocking module.
function QueuedBlocking.init()
	local renderStepped = Signal.new(runService.RenderStepped)
	qiMaid:mark(renderStepped:connect("QueuedInputs_Update", onRenderStepped))
end

---Detach QueuedBlocking module.
function QueuedBlocking.detach()
	qiMaid:clean()
end

-- Return QueuedBlocking module.
return QueuedBlocking
