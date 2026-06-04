---@module Utility.Signal
local Signal = require("Utility/Signal")

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Utility.TaskSpawner
local TaskSpawner = require("Utility/TaskSpawner")

-- AP Breaker module.
local APBreaker = {}

-- Services.
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Animation IDs pool (AP breaker animations).
local ANIMATIONS = {
    "rbxassetid://9149348937",
    "rbxassetid://10880473795",
    "rbxassetid://5778357994",
    "rbxassetid://16873988732",
    "rbxassetid://7620630583",
    "rbxassetid://8378263543",
}

-- Configuration defaults.
local PULSES_PER_SECOND = 1000  -- Animations per second
local SPEED = 10                 -- Animation speed multiplier
local WEIGHT = 0.006             -- Animation weight
local FADE_TIME = 0              -- No fade time
local PRIORITY = Enum.AnimationPriority.Idle

-- State.
local apMaid = Maid.new()
local isRunning = false
local currentAnimationTrack = nil
local currentAnimator = nil
local lastPulseTime = 0
local pulseInterval = 1 / PULSES_PER_SECOND

-- Animation track pool.
local animationTracks = {}

---Get or create animation track.
---@param animator Animator
---@param animationId string
---@return AnimationTrack?
local function getAnimationTrack(animator, animationId)
    if not animator or not animationId then
        return nil
    end
    
    -- Check cache.
    if animationTracks[animationId] and animationTracks[animationId].IsLoaded then
        return animationTracks[animationId]
    end
    
    -- Load new animation.
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    animation.Name = "APBreaker_Anim"
    
    local track = animator:LoadAnimation(animation)
    if track then
        animationTracks[animationId] = track
        -- Cleanup when done.
        task.defer(function()
            track.Stopped:Wait()
            animationTracks[animationId] = nil
            animation:Destroy()
        end)
    end
    
    return track
end

---Execute single animation pulse.
local function executePulse()
    if not isRunning then
        return
    end
    
    local localPlayer = players.LocalPlayer
    local character = localPlayer and localPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local animator = humanoid and humanoid:FindFirstChild("Animator")
    
    if not animator then
        return
    end
    
    -- Random animation from pool.
    local randomAnimId = ANIMATIONS[math.random(1, #ANIMATIONS)]
    
    -- Get or create track.
    local track = getAnimationTrack(animator, randomAnimId)
    if not track then
        return
    end
    
    -- Configure animation.
    track:AdjustSpeed(SPEED)
    track:AdjustWeight(WEIGHT)
    
    -- Play with zero fade time (instant).
    track:Play(FADE_TIME, 1, PRIORITY)
    
    -- Stop immediately after playing (creates micro-pulse).
    task.defer(function()
        if track and track.IsPlaying then
            track:Stop(FADE_TIME)
        end
    end)
end

---Ultra-fast pulse loop.
local function pulseLoop()
    if not isRunning then
        return
    end
    
    local currentTime = os.clock()
    
    -- Execute at maximum possible rate.
    if currentTime - lastPulseTime >= pulseInterval then
        lastPulseTime = currentTime
        
        -- Execute multiple pulses per frame if needed.
        local pulsesToExecute = math.floor((currentTime - lastPulseTime) / pulseInterval) + 1
        for _ = 1, math.min(pulsesToExecute, 10) do -- Limit to 10 per frame to avoid lag
            task.spawn(executePulse)
        end
    end
end

---Rapid burst mode (for maximum AP breaking).
local function rapidBurstMode(duration, intensity)
    if not isRunning then
        return
    end
    
    Logger.warn("AP Breaker - Rapid burst mode activated for %.2f seconds at %dx intensity", duration, intensity)
    
    local startTime = tick()
    local burstMaid = Maid.new()
    
    -- Override pulse interval temporarily.
    local originalInterval = pulseInterval
    pulseInterval = pulseInterval / intensity
    
    -- Stop after duration.
    burstMaid:mark(TaskSpawner.delay("APBreaker_BurstEnd", function()
        return duration
    end, function()
        pulseInterval = originalInterval
        burstMaid:clean()
        Logger.warn("AP Breaker - Rapid burst mode ended")
    end))
end

---Start AP breaker.
---@param burstMode boolean? Enable rapid burst mode
---@param intensity number? Burst intensity multiplier
function APBreaker.start(burstMode, intensity)
    if isRunning then
        Logger.warn("AP Breaker is already running")
        return
    end
    
    local localPlayer = players.LocalPlayer
    if not localPlayer then
        Logger.warn("LocalPlayer not found")
        return
    end
    
    local character = localPlayer.Character
    if not character then
        Logger.warn("Character not found")
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local animator = humanoid and humanoid:FindFirstChild("Animator")
    
    if not animator then
        Logger.warn("Animator not found")
        return
    end
    
    isRunning = true
    lastPulseTime = os.clock()
    currentAnimator = animator
    
    -- Connect to render stepped for continuous pulsing.
    apMaid:mark(runService.RenderStepped:Connect(function()
        pulseLoop()
    end))
    
    -- Start burst mode if requested.
    if burstMode then
        rapidBurstMode(3.0, intensity or 5)
    end
    
    Logger.warn("AP Breaker started - Pulses/sec: %d, Speed: %.1fx, Weight: %.3f", 
        PULSES_PER_SECOND, SPEED, WEIGHT)
end

---Stop AP breaker.
function APBreaker.stop()
    if not isRunning then
        return
    end
    
    isRunning = false
    
    -- Stop all animation tracks.
    for animId, track in pairs(animationTracks) do
        if track and track.IsPlaying then
            pcall(function()
                track:Stop(0)
            end)
        end
    end
    
    -- Clear tracks.
    table.clear(animationTracks)
    
    -- Clean maid connections.
    apMaid:clean()
    
    currentAnimationTrack = nil
    currentAnimator = nil
    lastPulseTime = 0
    
    Logger.warn("AP Breaker stopped")
end

---Toggle AP breaker.
---@param burstMode boolean?
---@param intensity number?
function APBreaker.toggle(burstMode, intensity)
    if isRunning then
        APBreaker.stop()
    else
        APBreaker.start(burstMode, intensity)
    end
end

---Set animation speed.
---@param speed number
function APBreaker.setSpeed(speed)
    SPEED = math.max(0.1, math.min(100, speed))
    Logger.warn("AP Breaker speed set to %.1f", SPEED)
end

---Set pulses per second.
---@param pps number
function APBreaker.setPulsesPerSecond(pps)
    PULSES_PER_SECOND = math.max(10, math.min(5000, pps))
    pulseInterval = 1 / PULSES_PER_SECOND
    Logger.warn("AP Breaker pulses/sec set to %d", PULSES_PER_SECOND)
end

---Set animation weight.
---@param weight number
function APBreaker.setWeight(weight)
    WEIGHT = math.max(0, math.min(1, weight))
    Logger.warn("AP Breaker weight set to %.3f", WEIGHT)
end

---Initialize AP Breaker (add to menu/configuration).
function APBreaker.init()
    -- Register with configuration system if needed.
    if Configuration and Configuration.registerToggle then
        Configuration.registerToggle("APBreaker", false, "AP Breaker - Breaks animations")
        Configuration.registerOption("APBreakerSpeed", 10, "AP Breaker animation speed")
        Configuration.registerOption("APBreakerPPS", 1000, "AP Breaker pulses per second")
    end
    
    Logger.warn("AP Breaker initialized with %d animations", #ANIMATIONS)
end

---Clean up AP Breaker.
function APBreaker.detach()
    APBreaker.stop()
    animationTracks = {}
    Logger.warn("AP Breaker detached")
end

-- Return APBreaker module.
return APBreaker