-- Task spawner module.
local TaskSpawner = {}

---@module Utility.Profiler
local Profiler = require("Utility/Profiler")

---@module Utility.Logger
local Logger = require("Utility/Logger")

-- Services.
local RunService = game:GetService("RunService")

---Spawn delayed task where the delay can be variable.
---@param label string
---@param delay function
---@param callback function
---@vararg any
function TaskSpawner.delay(label, delay, callback, ...)
	---Log task errors.
	---@param error string
	local function onTaskFunctionError(error)
		Logger.trace("onTaskFunctionError - (%s) - %s", label, error)
	end

	-- Wrap callback in profiler and error handling and delay handling.
	local taskFunction = Profiler.wrap(
		label,
		LPH_NO_VIRTUALIZE(function(...)
			local timestamp = os.clock()

			while os.clock() - timestamp < delay() do
				RunService.RenderStepped:Wait()
			end

			return xpcall(callback, onTaskFunctionError, ...)
		end)
	)

	return task.spawn(taskFunction, ...)
end

---Spawn task.
---@param label string
---@param callback function
---@vararg any
function TaskSpawner.spawn(label, callback, ...)
	---Log task errors.
	---@param error string
	local function onTaskFunctionError(error)
		Logger.trace("onTaskFunctionError - (%s) - %s", label, error)
	end

	-- Wrap callback in profiler and error handling.
	local taskFunction = Profiler.wrap(
		label,
		LPH_NO_VIRTUALIZE(function(...)
			return xpcall(callback, onTaskFunctionError, ...)
		end)
	)

	-- Return reference.
	return task.spawn(taskFunction, ...)
end

-- Return TaskSpawner module.
return TaskSpawner
