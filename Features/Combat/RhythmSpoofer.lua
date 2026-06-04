-- RhythmSpoofer module.
local RhythmSpoofer = {}

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local soundService = game:GetService("SoundService")

local localPlayer = players.LocalPlayer

local rhythmMaid = Maid.new()

local CONFIG = {
	FALLBACK_KEY = Enum.KeyCode.G,
	MIN_DURATION = 4.0,
	DETECTION_RANGE = 1000,
	ANIMATION_ID = "rbxassetid://4746910224",
	SOUND_ID = "rbxassetid://4748402358",
	SOUND_VOLUME = 0.8,
	FADE_IN_DURATION = 1.0,
	FADE_OUT_DURATION = 1.0,
	SATURATION_NORMAL = 0,
	SATURATION_ACTIVE = -1.0,
	TINT_NORMAL = Color3.new(1, 1, 1),
	TINT_ACTIVE = Color3.fromRGB(217, 217, 217),
	SONAR_COLOR = Color3.fromRGB(35, 55, 70),
	SONAR_START_SIZE = 80,
	SONAR_END_SIZE = 200,
}

local rhythmActive = false
local rhythmStartTime = nil
local pendingStop = false
local rhythmCC = nil
local currentAnimTrack = nil
local currentSound = nil
local reverbEffect = nil
local volumeEffect = nil
local reverbLoop = nil
local pulseLoop = nil
local debounce = false
local entityTimestamps = {}
local rhythmKeybind = nil
local effectModule = nil

local function getCharacter()
	return localPlayer and localPlayer.Character
end

local function getHRP()
	local character = getCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local character = getCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function hasRhythmTalent()
	local passives = localPlayer.Character and localPlayer.Character:GetAttribute("ssv_Passives")
	if passives and passives:find("Murmur: Rhythm") then return true end
	local backpack = localPlayer:FindFirstChild("Backpack")
	return backpack and backpack:FindFirstChild("Talent:Murmur: Rhythm")
end

local function getEffectModule()
	if effectModule then return effectModule end
	local effectReplicator = replicatedStorage:FindFirstChild("EffectReplicator")
	if effectReplicator then
		local success, result = pcall(require, effectReplicator)
		if success then
			effectModule = result
		end
	end
	return effectModule
end

local function isCrouching()
	local em = getEffectModule()
	if not em then return false end
	local clientCrouch = em:FindEffect("ClientCrouch")
	local serverCrouch = em:FindEffect("Crouching")
	return (clientCrouch ~= nil) or (serverCrouch ~= nil)
end

local function canUseRhythm()
	if not isCrouching() then
		return false
	end
	local em = getEffectModule()
	if em and em:FindEffect("Stun") then
		return false
	end
	return true
end

local function getRhythmKeybind()
	if rhythmKeybind then return rhythmKeybind end

	local keybindsModule = replicatedStorage:FindFirstChild("KeyBinds")
	if keybindsModule then
		local success, keybinds = pcall(require, keybindsModule)
		if success and keybinds and keybinds.GetBinding then
			local binding = keybinds.GetBinding("Rhythm")
			if binding and type(binding) == "table" then
				for _, keyName in ipairs(binding) do
					local ok, keyCode = pcall(function()
						return Enum.KeyCode[keyName]
					end)
					if ok and keyCode then
						rhythmKeybind = keyCode
						return rhythmKeybind
					end
				end
			end
		end
	end

	rhythmKeybind = CONFIG.FALLBACK_KEY
	return rhythmKeybind
end

local function getThrown()
	local thrown = workspace:FindFirstChild("Thrown")
	if not thrown then
		thrown = Instance.new("Folder")
		thrown.Name = "Thrown"
		thrown.Parent = workspace
	end
	return thrown
end

local function setupRhythmCC()
	rhythmCC = lighting:FindFirstChild("Rhythm")
	if not rhythmCC then
		rhythmCC = Instance.new("ColorCorrectionEffect")
		rhythmCC.Name = "Rhythm"
		rhythmCC.Brightness = 0
		rhythmCC.Contrast = 0
		rhythmCC.Saturation = 0
		rhythmCC.TintColor = Color3.new(1, 1, 1)
		rhythmCC.Enabled = false
		rhythmCC.Parent = lighting
	end
	return rhythmCC
end

local function activateLighting()
	if not rhythmCC then setupRhythmCC() end

	rhythmCC.Saturation = CONFIG.SATURATION_NORMAL
	rhythmCC.TintColor = CONFIG.TINT_NORMAL
	rhythmCC.Enabled = true

	tweenService:Create(rhythmCC,
		TweenInfo.new(CONFIG.FADE_IN_DURATION, Enum.EasingStyle.Linear),
		{ Saturation = CONFIG.SATURATION_ACTIVE, TintColor = CONFIG.TINT_ACTIVE }
	):Play()
end

local function deactivateLighting()
	if not rhythmCC then return end

	tweenService:Create(rhythmCC,
		TweenInfo.new(CONFIG.FADE_OUT_DURATION, Enum.EasingStyle.Linear),
		{ Saturation = CONFIG.SATURATION_NORMAL, TintColor = CONFIG.TINT_NORMAL }
	):Play()
end

local function startAmbientOverride()
	local em = getEffectModule()
	if not em then return end

	if reverbEffect then
		pcall(function() reverbEffect:Remove() end)
		reverbEffect = nil
	end
	if volumeEffect then
		pcall(function() volumeEffect:Remove() end)
		volumeEffect = nil
	end
	if reverbLoop then
		pcall(function() reverbLoop:Disconnect() end)
		reverbLoop = nil
	end

	task.wait()

	pcall(function()
		reverbEffect = em:CreateEffect("ReverbOverride", {})
	end)

	pcall(function()
		volumeEffect = em:CreateEffect("AmbientVolume", { Value = 1 })
	end)

	reverbLoop = runService.Heartbeat:Connect(function()
		if rhythmActive then
			if soundService.AmbientReverb ~= Enum.ReverbType.Alley then
				soundService.AmbientReverb = Enum.ReverbType.Alley
			end
		end
	end)

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	numberValue.Changed:Connect(function()
		if volumeEffect then
			volumeEffect.Value = numberValue.Value
		end
	end)

	tweenService:Create(numberValue, TweenInfo.new(1), { Value = 0 }):Play()

	task.delay(1.5, function()
		numberValue:Destroy()
	end)
end

local function stopAmbientOverride(immediate)
	if reverbLoop then
		pcall(function() reverbLoop:Disconnect() end)
		reverbLoop = nil
	end

	local currentVolumeEffect = volumeEffect
	local currentReverbEffect = reverbEffect
	volumeEffect = nil
	reverbEffect = nil

	if currentReverbEffect then
		pcall(function() currentReverbEffect:Remove() end)
	end

	soundService.AmbientReverb = Enum.ReverbType.NoReverb

	if not currentVolumeEffect then return end

	if immediate then
		pcall(function() currentVolumeEffect:Remove() end)
		return
	end

	local success, numberValue = pcall(function()
		local nv = Instance.new("NumberValue")
		nv.Value = 0
		return nv
	end)

	if success and numberValue then
		local conn
		conn = numberValue.Changed:Connect(function()
			pcall(function()
				currentVolumeEffect.Value = numberValue.Value
			end)
		end)

		tweenService:Create(numberValue, TweenInfo.new(1), { Value = 1 }):Play()

		task.delay(1.1, function()
			pcall(function() conn:Disconnect() end)
			pcall(function() numberValue:Destroy() end)
			pcall(function() currentVolumeEffect:Remove() end)
		end)
	else
		pcall(function() currentVolumeEffect:Remove() end)
	end
end

local function playAnimation()
	local humanoid = getHumanoid()
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	local listenAnim = replicatedStorage:FindFirstChild("Assets")
		and replicatedStorage.Assets:FindFirstChild("Anims")
		and replicatedStorage.Assets.Anims:FindFirstChild("Powers")
		and replicatedStorage.Assets.Anims.Powers:FindFirstChild("Listen")

	if listenAnim then
		currentAnimTrack = animator:LoadAnimation(listenAnim)
	else
		local anim = Instance.new("Animation")
		anim.AnimationId = CONFIG.ANIMATION_ID
		currentAnimTrack = animator:LoadAnimation(anim)
	end

	currentAnimTrack.Priority = Enum.AnimationPriority.Action
	currentAnimTrack:Play()
end

local function stopAnimation()
	if currentAnimTrack then
		currentAnimTrack:Stop()
		currentAnimTrack = nil
	end
end

local function playSound()
	local rhythmSound = replicatedStorage:FindFirstChild("Sounds")
		and replicatedStorage.Sounds:FindFirstChild("Rhythm")

	if rhythmSound then
		currentSound = rhythmSound:Clone()
	else
		currentSound = Instance.new("Sound")
		currentSound.SoundId = CONFIG.SOUND_ID
		currentSound.Volume = CONFIG.SOUND_VOLUME
	end

	currentSound.Name = "Rhythm"
	currentSound.Parent = workspace
	currentSound:Play()

	debris:AddItem(currentSound, 3)
end

local function stopSound()
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end
end

local function createExpandingSonar()
	local hrp = getHRP()
	if not hrp then return end

	local part
	local sonarAsset = replicatedStorage:FindFirstChild("Assets")
		and replicatedStorage.Assets:FindFirstChild("Effects")
		and replicatedStorage.Assets.Effects:FindFirstChild("Sonar")

	if sonarAsset then
		part = sonarAsset:Clone()
	else
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Color = CONFIG.SONAR_COLOR
		part.Material = Enum.Material.ForceField
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
	end

	part.Name = "Sonar"
	part.Transparency = 1
	part.Size = Vector3.new(CONFIG.SONAR_START_SIZE, CONFIG.SONAR_START_SIZE, CONFIG.SONAR_START_SIZE)
	part.CFrame = hrp.CFrame
	part.Parent = getThrown()

	tweenService:Create(part,
		TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Size = Vector3.new(CONFIG.SONAR_END_SIZE, CONFIG.SONAR_END_SIZE, CONFIG.SONAR_END_SIZE) }
	):Play()

	tweenService:Create(part,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
		{ Transparency = 0 }
	):Play()

	debris:AddItem(part, 4)
end

local function detectEntities()
	local hrp = getHRP()
	if not hrp then return end

	local character = getCharacter()
	local myPos = hrp.Position
	local range = CONFIG.DETECTION_RANGE

	local liveFolder = workspace:FindFirstChild("Live")
	if not liveFolder then return end

	local clientEffectDirect = replicatedStorage:FindFirstChild("Requests")
		and replicatedStorage.Requests:FindFirstChild("ClientEffectDirect")
	if not clientEffectDirect then return end

	for _, entity in ipairs(liveFolder:GetChildren()) do
		local entityHRP = entity:FindFirstChild("HumanoidRootPart")

		if entityHRP and entity ~= character and not entity:HasTag("InTacet") then
			if not entityTimestamps[entity.Name] then
				entityTimestamps[entity.Name] = tick()
			elseif tick() - entityTimestamps[entity.Name] >= 1 then
				entityTimestamps[entity.Name] = tick()
			else
				continue
			end

			local effectiveRange = range
			if entity:HasTag("Disguised") then
				effectiveRange = effectiveRange * 0.1
			end

			local dist = (myPos - entityHRP.Position).Magnitude
			if dist < effectiveRange then
				local color = Color3.new(1, 1, 1)

				local hum = entity:FindFirstChildOfClass("Humanoid")
				if hum and not entity:HasTag("NoVisibleDamage") then
					local healthPercent = hum.Health / hum.MaxHealth
					if healthPercent < 0.33 then
						color = Color3.fromRGB(255, 0, 0)
					elseif healthPercent < 0.66 then
						color = Color3.fromRGB(255, 179, 0)
					end
				end

				clientEffectDirect:Fire("sonarsmall", {
					pos = entityHRP.Position,
					col = color
				})
			end
		end
	end
end

local function canDeactivate()
	if not rhythmStartTime then return true end
	return (tick() - rhythmStartTime) >= CONFIG.MIN_DURATION
end

local function stopRhythm()
	if not rhythmActive then return end

	rhythmActive = false
	rhythmStartTime = nil
	pendingStop = false
	debounce = true

	stopAnimation()
	currentSound = nil
	deactivateLighting()
	stopAmbientOverride()

	if pulseLoop then
		task.cancel(pulseLoop)
		pulseLoop = nil
	end

	task.spawn(function()
		task.wait(0.2)
		debounce = false
	end)

	task.spawn(function()
		task.wait(1)
		if rhythmCC then
			rhythmCC.Enabled = false
		end
	end)
end

local function startRhythm()
	if debounce then return end
	if rhythmActive then return end

	rhythmActive = true
	debounce = true
	rhythmStartTime = tick()
	pendingStop = false

	playAnimation()

	task.wait(0.1)
	playSound()

	task.wait(0.2)

	if not isCrouching() then
		rhythmActive = false
		rhythmStartTime = nil
		pendingStop = false
		stopAnimation()

		if currentSound then
			tweenService:Create(currentSound, TweenInfo.new(0.2), { Volume = 0 }):Play()
			task.wait(0.2)
			stopSound()
		end

		debounce = false
		return
	end

	setupRhythmCC()
	activateLighting()
	startAmbientOverride()

	entityTimestamps = {}
	detectEntities()

	pulseLoop = task.spawn(function()
		while rhythmActive do
			task.wait(0.2)
			detectEntities()
		end
	end)

	for _ = 1, 10 do
		task.spawn(createExpandingSonar)
		task.wait(0.1)
	end

	task.wait(0.5)

	task.spawn(function()
		task.wait(0.2)
		debounce = false
	end)
end

local function onKeyPress(input, gameProcessed)
	if gameProcessed then return end
	if not Configuration.expectToggleValue("RhythmSpoofer") then return end
	if hasRhythmTalent() then return end

	local keybind = getRhythmKeybind()
	if input.KeyCode ~= keybind then return end

	if rhythmActive then
		if canDeactivate() then
			stopRhythm()
		else
			pendingStop = true
		end
	else
		if canUseRhythm() then
			startRhythm()
		end
	end
end

local function monitorRhythmCheck()
	if not rhythmActive then return end
	if not Configuration.expectToggleValue("RhythmSpoofer") then
		stopRhythm()
		return
	end

	if canDeactivate() then
		local canUse = canUseRhythm()
		if pendingStop or not canUse then
			stopRhythm()
		end
	end
end

function RhythmSpoofer.init()
	rhythmMaid:add(userInputService.InputBegan:Connect(onKeyPress))
	rhythmMaid:add(runService.Heartbeat:Connect(monitorRhythmCheck))

	rhythmMaid:add(localPlayer.CharacterAdded:Connect(function()
		currentAnimTrack = nil
		currentSound = nil
		stopAmbientOverride(true)
		if rhythmActive then
			stopRhythm()
		end
	end))

	getRhythmKeybind()
end

function RhythmSpoofer.detach()
	if rhythmActive then
		stopRhythm()
	end
	rhythmMaid:clean()

	if rhythmCC then
		rhythmCC:Destroy()
		rhythmCC = nil
	end
end

return RhythmSpoofer
