---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Signal
local Signal = require("Utility/Signal")

---@module Features.Visuals.Objects.ModelESP
local ModelESP = require("Features/Visuals/Objects/ModelESP")

---@module Features.Visuals.Objects.PartESP
local PartESP = require("Features/Visuals/Objects/PartESP")

---@module Features.Visuals.Objects.MobESP
local MobESP = require("Features/Visuals/Objects/MobESP")

---@module Features.Visuals.Objects.PlayerESP
local PlayerESP = require("Features/Visuals/Objects/PlayerESP")

---@module Utility.TaskSpawner
local TaskSpawner = require("Utility/TaskSpawner")

---@module Features.Visuals.Objects.FilteredESP
local FilteredESP = require("Features/Visuals/Objects/FilteredESP")

---@module Features.Visuals.Group
local Group = require("Features/Visuals/Group")

---@module Utility.Profiler
local Profiler = require("Utility/Profiler")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

---@module Utility.OriginalStoreManager
local OriginalStoreManager = require("Utility/OriginalStoreManager")

---@module Features.Visuals.Objects.ChestESP
local ChestESP = require("Features/Visuals/Objects/ChestESP")

---@module Utility.InstanceWrapper
local InstanceWrapper = require("Utility/InstanceWrapper")

---@module Utility.Table
local Table = require("Utility/Table")

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Features.Visuals.Objects.ObeliskESP
local ObeliskESP = require("Features/Visuals/Objects/ObeliskESP")

---@module Features.Visuals.Objects.BoneAltarESP
local BoneAltarESP = require("Features/Visuals/Objects/BoneAltarESP")

---@module Features.Combat.StateListener
local StateListener = require("Features/Combat/StateListener")

-- Visuals module.
local Visuals = { bdata = nil, drinfo = nil }

-- Last visuals update.
local lastVisualsUpdate = os.clock()
local lastHoveringUpdate = os.clock()
local lastESPUpdate = os.clock()

-- Services.
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local textChatService = game:GetService("TextChatService")
local userInputService = game:GetService("UserInputService")
local guiService = game:GetService("GuiService")

-- Signals.
local renderStepped = Signal.new(runService.RenderStepped)

-- Maids.
local visualsMaid = Maid.new()
local builderAssistanceMaid = Maid.new()

-- Card frames.
local cardFrames = {}

-- Map.
local labelMap = {}
local hoveringMap = {}

-- Terrain attachments.
local attachments = {}

-- Groups.
local groups = {}

-- Original stores.
local fieldOfView = nil

-- Auto favour state.
local autoFavourApplied = false
local autoFavourBdata = nil
local lastFavouredNames = {}

-- Mystery reveal state.
local roll2Notified = false
local roll2Dismissals = {}
local cachedRoll2Selection = nil

---Dismiss all Roll 2 notifications.
local function dismissRoll2()
	for _, dismiss in next, roll2Dismissals do
		task.spawn(dismiss)
	end
	roll2Dismissals = {}
end

-- Original store managers.
local showRobloxChatMap = visualsMaid:mark(OriginalStoreManager.new())
local noAnimatedSeaMap = visualsMaid:mark(OriginalStoreManager.new())
local noPersistentMap = visualsMaid:mark(OriginalStoreManager.new())
local buildAssistanceMap = visualsMaid:mark(OriginalStoreManager.new())
local mysteryRevealMap = visualsMaid:mark(OriginalStoreManager.new())
local jobBoardMap = visualsMaid:mark(OriginalStoreManager.new())

---Update chain of perfection tracker.
local updateChainOfPerfectionTracker = LPH_NO_VIRTUALIZE(function()
	local localPlayer = players.LocalPlayer
	if not localPlayer then
		return
	end

	local playerGui = localPlayer.PlayerGui
	if not playerGui then
		return
	end

	local currencyGui = playerGui:FindFirstChild("CurrencyGui")
	if not currencyGui then
		return
	end

	local currencyFrame = currencyGui:FindFirstChild("CurrencyFrame")
	if not currencyFrame then
		return
	end

	local crownsTextLabel = currencyFrame:FindFirstChild("Crowns")
	if not crownsTextLabel then
		return
	end

	-- Setup.
	local stackTextLabel = InstanceWrapper.mark(visualsMaid, "StackTextLabel", crownsTextLabel:Clone())
	stackTextLabel.Name = "ChainStacks"
	stackTextLabel.Parent = currencyFrame
	stackTextLabel.Visible = true

	-- Amount.
	local amountLabel = stackTextLabel:FindFirstChild("Amount")
	if not amountLabel then
		return
	end

	amountLabel.Text = tostring(StateListener.chainStacks or 0)
	amountLabel.TextColor3 = Color3.new(255, 255, 255)

	-- Icon.
	local icon = stackTextLabel:FindFirstChild("Icon")
	if not icon then
		return
	end

	icon.Image = "rbxassetid://92751444684393"
	icon.ImageColor3 = Color3.new(255, 255, 255)
	icon.ImageRectOffset = Vector2.new(0, 0)
	icon.ImageRectSize = Vector2.new(0, 0)

	-- Lore.
	stackTextLabel:SetAttribute("Tip_Title", "Chain Stacks")
	stackTextLabel:SetAttribute(
		"Tip_Desc",
		"This shows how many 'Chain of Perfection' stacks you currently have. This number is a prediction."
	)
end)

---Update sanity tracker.
local updateSanityTracker = LPH_NO_VIRTUALIZE(function()
	local localPlayer = players.LocalPlayer
	if not localPlayer then
		return
	end

	local playerGui = localPlayer.PlayerGui
	if not playerGui then
		return
	end

	local currencyGui = playerGui:FindFirstChild("CurrencyGui")
	if not currencyGui then
		return
	end

	local currencyFrame = currencyGui:FindFirstChild("CurrencyFrame")
	if not currencyFrame then
		return
	end

	local crownsTextLabel = currencyFrame:FindFirstChild("Crowns")
	if not crownsTextLabel then
		return
	end

	-- Character.
	local character = localPlayer.Character
	if not character then
		return
	end

	local sanity = character:FindFirstChild("Sanity")
	if not sanity then
		return
	end

	-- Setup.
	local sanityTextLabel = InstanceWrapper.mark(visualsMaid, "SanityTextLabel", crownsTextLabel:Clone())
	sanityTextLabel.Name = "Sanity"
	sanityTextLabel.Parent = currencyFrame
	sanityTextLabel.Visible = true

	local mainColor = Color3.fromRGB(0, 191, 255)

	if sanity.Value <= sanity.MaxValue * 0.70 then
		mainColor = Color3.fromRGB(255, 239, 94)
	end

	if sanity.Value <= sanity.MaxValue * 0.50 then
		mainColor = Color3.fromRGB(255, 216, 110)
	end

	if sanity.Value <= sanity.MaxValue * 0.40 then
		mainColor = Color3.fromRGB(255, 111, 0)
	end

	if sanity.Value <= sanity.MaxValue * 0.10 then
		mainColor = Color3.fromRGB(255, 0, 0)
	end

	if sanity.Value <= 0.0 then
		mainColor = Color3.fromRGB(114, 114, 114)
	end

	-- Amount.
	local amountLabel = sanityTextLabel:FindFirstChild("Amount")
	if not amountLabel then
		return
	end

	local formatString = ((sanity.Value / sanity.MaxValue) * 100) <= 1.0 and "%.2f" or "%i"
	amountLabel.Text = string.format(formatString, (sanity.Value / sanity.MaxValue) * 100) .. "%"
	amountLabel.TextColor3 = mainColor

	-- Icon.
	local icon = sanityTextLabel:FindFirstChild("Icon")
	if not icon then
		return
	end

	icon.Image = "http://www.roblox.com/asset/?id=16865012250"
	icon.ImageColor3 = mainColor
	icon.ImageRectOffset = Vector2.new(0, 0)
	icon.ImageRectSize = Vector2.new(0, 0)

	-- Lore.
	sanityTextLabel:SetAttribute("Tip_Title", "Sanity")
	sanityTextLabel:SetAttribute(
		"Tip_Desc",
		"The Flicker is a creeping affliction, awarded by the abyss for prolonged exposure to its horrors or a perverse talent for understanding its maddening secrets. This erosion of the mind holds a terrifying value in the afflicted's perception, granting a twisted understanding of the unseen, marking them as touched by powers beyond mortal comprehension."
	)
end)

---On Player GUI descendant added.
---@param descendant Instance
local onPlayerGuiDescendantAdded = LPH_NO_VIRTUALIZE(function(descendant)
	if descendant.Name ~= "CardFrame" then
		return
	end

	cardFrames[descendant] = true
	roll2Notified = false
	cachedRoll2Selection = nil
	dismissRoll2()
end)

---On Player GUI descendant removed.
---@param descendant Instance
local onPlayerGuiDescendantRemoving = LPH_NO_VIRTUALIZE(function(descendant)
	if not cardFrames[descendant] then
		return
	end

	cardFrames[descendant] = nil
	dismissRoll2()
	roll2Notified = false
end)

local stripTags = nil
local correctBuilderName = nil
local mantraDisplayToInternal = nil

---Update card frames.
local updateCardFrames = LPH_NO_VIRTUALIZE(function()
	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	---@type BuilderData
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	-- Pre-build lookup sets from builder data for O(1) matching.
	local talentLookup = {}
	for _, talent in next, bdata.talents do
		local talentClean = stripTags(talent)
		talentLookup[talentClean] = talent
		talentLookup[talent] = talent
	end

	local mantraLookup = {}
	for _, mantra in next, bdata.mantras do
		local mantraClean = correctBuilderName(stripTags(mantra))
		mantraLookup[mantraClean] = mantra
		mantraLookup[mantra] = mantra
	end

	for frame in next, cardFrames do
		local title = frame:FindFirstChild("Title")
		if not title then
			continue
		end

		local border = frame:FindFirstChild("Border")
		if not border then
			continue
		end

		local trimmedName = string.gsub(title.Text, "^%s*(.-)%s*$", "%1")
		local fullTalentName = talentLookup[trimmedName] or mantraLookup[trimmedName]
		local cardInData = fullTalentName ~= nil

		buildAssistanceMap:add(border, "ImageColor3", cardInData and Color3.new(0, 255, 0) or Color3.new(255, 0, 0))

		if
			cardInData
			and fullTalentName
			and bdata.ddata:possible(fullTalentName, bdata.pre)
			and not bdata.ddata:possible(fullTalentName, bdata.post)
		then
			buildAssistanceMap:add(border, "ImageColor3", Color3.new(255, 0, 255))
		end

		if cardInData then
			continue
		end

		local mappingMatch = {
			["Vitality"] = { expectedValue = bdata.traits["Vitality"], value = drinfo["TraitHealth"] },
			["Erudition"] = { expectedValue = bdata.traits["Erudition"], value = drinfo["TraitEther"] },
			["Proficiency"] = { expectedValue = bdata.traits["Proficiency"], value = drinfo["TraitWeaponDamage"] },
			["Songchant"] = { expectedValue = bdata.traits["Songchant"], value = drinfo["TraitMantraDamage"] },
		}

		for idx, data in next, mappingMatch do
			if not title.Text:match(idx) then
				continue
			end

			buildAssistanceMap:add(
				border,
				"ImageColor3",
				data.expectedValue ~= data.value and Color3.new(0, 255, 0) or Color3.new(255, 0, 0)
			)
		end
	end
end)

---Update power background.
---@param jframe Frame
local updatePowerBackground = LPH_NO_VIRTUALIZE(function(jframe)
	local panels = jframe and jframe:FindFirstChild("Panels")
	local infoFrame = panels and panels:FindFirstChild("InfoFrame")
	local sheets = infoFrame and infoFrame:FindFirstChild("Sheets")
	local power = sheets and sheets:FindFirstChild("Power")
	local background = power and power:FindFirstChild("Background")
	if not background then
		return
	end

	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	---@type BuilderData
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	---@note: We do not care if there is no pre-shrine state at all.
	if not bdata:dshrine() then
		return
	end

	local color = Color3.fromRGB(245, 137, 5)
	local pstate = bdata:ipre(drinfo)

	if pstate == 0 then
		color = Color3.fromRGB(97, 4, 113)
	end

	if pstate == 1 then
		color = Color3.fromRGB(37, 129, 236)
	end

	buildAssistanceMap:add(background, "BackgroundColor3", color)
end)

---Update attribute frame.
---@param jframe Frame
local updateAttributeFrame = LPH_NO_VIRTUALIZE(function(jframe)
	local panels = jframe:FindFirstChild("Panels")
	local attributeFrame = panels and panels:FindFirstChild("AttributeFrame")
	local sheets = attributeFrame and attributeFrame:FindFirstChild("Sheets")
	if not sheets then
		return
	end

	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	---@type BuilderData
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	local attributes = bdata:attributes(drinfo)
	local mapping = {
		["Agility"] = attributes.base["Agility"],
		["Strength"] = attributes.base["Strength"],
		["Fortitude"] = attributes.base["Fortitude"],
		["Intelligence"] = attributes.base["Intelligence"],
		["Willpower"] = attributes.base["Willpower"],
		["Charisma"] = attributes.base["Charisma"],
		["ElementBlood"] = attributes.attunement["Bloodrend"],
		["ElementFire"] = attributes.attunement["Flamecharm"],
		["ElementIce"] = attributes.attunement["Frostdraw"],
		["ElementLightning"] = attributes.attunement["Thundercall"],
		["ElementWind"] = attributes.attunement["Galebreathe"],
		["ElementShadow"] = attributes.attunement["Shadowcast"],
		["ElementMetal"] = attributes.attunement["Ironsing"],
		["WeaponHeavy"] = attributes.weapon["Heavy Wep."],
		["WeaponMedium"] = attributes.weapon["Medium Wep."],
		["WeaponLight"] = attributes.weapon["Light Wep."],
	}

	for _, instance in next, sheets:GetDescendants() do
		if not instance:IsA("TextButton") then
			continue
		end

		local expectedValue = mapping[instance.Name]
		if not expectedValue then
			continue
		end

		local background = instance:FindFirstChild("Background")
		if not background then
			continue
		end

		local valueLabel = instance:FindFirstChild("Value")
		if not valueLabel then
			continue
		end

		local statInvested = tonumber(drinfo["Stat" .. instance.Name])
		if not statInvested then
			continue
		end

		local value = (bdata:ipre(drinfo) == 0 and statInvested <= 0) and statInvested or tonumber(valueLabel.Text)
		if not value then
			continue
		end

		local abbrevLabel = instance:FindFirstChild("Abbrev")
		if not abbrevLabel then
			continue
		end

		local color = expectedValue ~= value and Color3.fromRGB(9, 136, 0) or Color3.fromRGB(127, 0, 2)

		if value > expectedValue then
			color = Color3.fromRGB(128, 128, 128)
		end

		buildAssistanceMap:add(background, "BackgroundColor3", color)

		buildAssistanceMap:add(abbrevLabel, "Text", string.format("GET (%i)", expectedValue))
	end
end)

---Update traits.
---@param jframe Frame
local updateTraits = LPH_NO_VIRTUALIZE(function(jframe)
	local panels = jframe:FindFirstChild("Panels")
	local infoFrame = panels and panels:FindFirstChild("InfoFrame")
	local sheets = infoFrame and infoFrame:FindFirstChild("Sheets")
	local traitSheet = sheets and sheets:FindFirstChild("TraitSheet")
	local container = traitSheet and traitSheet:FindFirstChild("Container")
	if not container then
		return
	end

	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	---@type BuilderData
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	local mapping = {
		["Ether"] = bdata.traits["Erudition"],
		["Health"] = bdata.traits["Vitality"],
		["WeaponDamage"] = bdata.traits["Proficiency"],
		["MantraDamage"] = bdata.traits["Songchant"],
	}

	for _, instance in next, sheets:GetDescendants() do
		if not instance:IsA("Frame") then
			continue
		end

		local expectedValue = mapping[instance.Name]
		if not expectedValue then
			continue
		end

		local background = instance:FindFirstChild("Background")
		if not background then
			continue
		end

		local valueLabel = instance:FindFirstChild("Value")
		if not valueLabel then
			continue
		end

		local value = tonumber(valueLabel.Text)
		if not value then
			continue
		end

		local color = expectedValue ~= value and Color3.fromRGB(9, 136, 0) or Color3.fromRGB(127, 0, 2)

		if value > expectedValue then
			color = Color3.fromRGB(128, 128, 128)
		end

		buildAssistanceMap:add(background, "BackgroundColor3", color)
	end
end)

---Strip weapon tags like [HVY], [LHT], [MED], [FTD], [BLD] for display.
stripTags = function(str)
	return str:gsub("%s*%[.-%]$", "")
end

-- Builder name corrections (builder data name -> in-game name).
local builderNameCorrections = {
	["Shadow Meteors"] = "Shadow Meteor",
}

-- Mantra display name -> internal name mapping.
mantraDisplayToInternal = {
	["Tornado Kick"] = "HeavyKick:Wind",
	["Ice Forge"] = "Forge:Ice",
	["Fire Forge"] = "Forge:Fire",
	["Storm Blades"] = "Forge:Lightning",
	["Wind Forge"] = "Forge:Wind",
	["Iron Tether"] = "Forge:Metal",
	["Blood Orb"] = "Forge:Blood",
	["Flaming Scourge"] = "Whip:Fire",
	["Ice Cubes"] = "Push:Ice",
	["Bloodtide Ritual"] = "Judgement:Blood",
	["Relentless Flames"] = "RapidArms:Fire",
	["Reinforce"] = "Reinforce:Fortitude",
	["Iceberg"] = "Reinforce:Ice",
	["Iron Skin"] = "Reinforce:Metal",
	["Shade Devour"] = "Devour:Shadow",
	["Devouring Eye"] = "SilenceField:Shadow",
	["Warden's Blades"] = "Dice:Ice",
	["Taunt"] = "Taunt:Charisma",
	["Glare"] = "Glare:Willpower",
	["Sing"] = "Sing:Charisma",
	["Strong Left"] = "StrongPunch:Strength",
	["Ash Slam"] = "StrongPunch:Fire",
	["Master's Flourish"] = "StrongPunch:WeaponMedium",
	["Pressure Blast"] = "StrongPunch:WeaponHeavy",
	["Eclipse Kick"] = "StrongPunch:Shadow",
	["Rocket Lance"] = "StrongPunch:Metal",
	["Veinbreaker"] = "StrongPunch:Blood",
	["Adrenaline Surge"] = "Adrenaline:Agility",
	["Dash"] = "Dash:Agility",
	["Metal Fakeout"] = "Dash:Metal",
	["Rapid Slashes"] = "Dash:WeaponLight",
	["Slice 'n' Dice"] = "Dash:WeaponMedium",
	["Revenge"] = "Revenge:Agility",
	["Punishment"] = "Revenge:WeaponHeavy",
	["Twincleave"] = "Revenge:WeaponMedium",
	["Permafrost Prison"] = "Zone:Shadow",
	["Ether Barrage"] = "Barrage:Intelligence",
	["Metal Gatling"] = "Barrage:Metal",
	["Rapid Punches"] = "Barrage:Strength",
	["Encircle"] = "Encircle:Shadow",
	["Shadow Vortex"] = "Attract:Shadow",
	["Emotion Wave"] = "Wave:Lightning",
	["Champion's Whirlthrow"] = "Toss:Wind",
	["Grand Javelin"] = "Toss:Lightning",
	["Needle Barrage"] = "Toss:Metal",
	["Flame Ballista"] = "Toss:Fire",
	["Ice Flock"] = "Toss:Ice",
	["Table Flip"] = "Toss:Strength",
	["Sanguine Dive"] = "Toss:Blood",
	["Thunder Kick"] = "Kick:Lightning",
	["Metal Kick"] = "Kick:Metal",
	["Flashfire Sweep"] = "Kick:Fire",
	["Twister Kicks"] = "Kick:Wind",
	["Crucifixion"] = "Conjure:Blood",
	["Bolt Piercer"] = "SkyArrow:Lightning",
	["Metal Rain"] = "SkyArrow:Metal",
	["Flame Sentinel"] = "SkyArrow:Fire",
	["Ice Skate"] = "Skate:Ice",
	["Gaze"] = "Gaze:Willpower",
	["Ice Fissure"] = "Fissure:Ice",
	["Ice Smash"] = "Smash:Ice",
	["Iron Slam"] = "Smash:Metal",
	["Shadow Meteor"] = "Palm:Shadow",
	["Gale Punch"] = "Palm:Wind",
	["Fire Palm"] = "Palm:Fire",
	["Lightning Impact"] = "Palm:Lightning",
	["Iron Quills"] = "Palm:Metal",
	["Flame Blind"] = "Blind:Fire",
	["Ice Spikes"] = "Pillar:Ice",
	["Metal Rampart"] = "Pillar:Metal",
	["Flame Leap"] = "Leap:Fire",
	["Strong Leap"] = "Leap:Strength",
	["Neural Pathway"] = "Leap:Intelligence",
	["Spark Swap"] = "Swap:Lightning",
	["Crimson Surge"] = "UpSmash:Blood",
	["Flashdraw Strike"] = "UpSmash:WeaponMedium",
	["Shade Step"] = "UpSmash:Shadow",
	["Updraft"] = "UpSmash:Wind",
	["Ice Chain"] = "Restraint:Ice",
	["Shadow Chains"] = "Restraint:Shadow",
	["Bloodcurdle"] = "Restraint:Blood",
	["Wind Carve"] = "Carve:Wind",
	["Electro Carve"] = "Carve:Lightning",
	["Ice Carve"] = "Carve:Ice",
	["Ice Daggers"] = "Dagger:Ice",
	["Shadow Seekers"] = "Dagger:Shadow",
	["Fleeting Sparks"] = "Dagger:Lightning",
	["Crimson Rain"] = "Dagger:Blood",
	["Vicious Descent"] = "DownAir:Blood",
	["Tempest Blitz"] = "DownAir:Lightning",
	["Prediction"] = "Prediction:Intelligence",
	["Heavenly Wind"] = "HeavenlyStrike:Wind",
	["Gale Lunge"] = "Pierce:Wind",
	["Metal Ball"] = "Pierce:Metal",
	["Ice Lance"] = "Pierce:Ice",
	["Blood Stakes"] = "Pierce:Blood",
	["Lightning Stream"] = "Stream:Lightning",
	["Chain Pull"] = "Stream:Metal",
	["Lightning Clones"] = "Clones:Lightning",
	["Shadow Assault"] = "Strike:Shadow",
	["Flame Assault"] = "Strike:Fire",
	["Shoulder Bash"] = "Strike:Fortitude",
	["Prominence Draw"] = "Strike:WeaponMedium",
	["Lightning Assault"] = "Strike:Lightning",
	["Oxidizing Rush"] = "Strike:Metal",
	["Razor Blitz"] = "Strike:Blood",
	["Wind Passage"] = "Strike:Wind",
	["Burning Servants"] = "Squad:Fire",
	["Frozen Servants"] = "Squad:Ice",
	["Glacial Arc"] = "Arc:Ice",
	["Astral Wind"] = "Astral:Wind",
	["Ceaseless Slashes"] = "Astral:WeaponLight",
	["Rising Flame"] = "RisingSlash:Fire",
	["Rising Shadow"] = "RisingSlash:Shadow",
	["Rising Thunder"] = "RisingSlash:Lightning",
	["Rising Frost"] = "RisingSlash:Ice",
	["Rising Wind"] = "RisingSlash:Wind",
	["Exhaustion Strike"] = "Exhaustion:Willpower",
	["Flame Repulsion"] = "Repulsion:Fire",
	["Fire Gun"] = "Gun:Fire",
	["Wind Gun"] = "Gun:Wind",
	["Shadow Gun"] = "Gun:Shadow",
	["Firing Line"] = "Gun:Metal",
	["Lightning Cloak"] = "Cloak:Lightning",
	["Flame Grab"] = "Choke:Fire",
	["Clutching Shadow"] = "Choke:Shadow",
	["Jolt Grab"] = "Choke:Lightning",
	["Iron Hug"] = "Choke:Metal",
	["Soulflare Siphon"] = "Choke:Blood",
	["Frost Grab"] = "Choke:Ice",
	["Dread Whisper"] = "Choke:Charisma",
	["Metal Turret"] = "Turret:Metal",
	["Galetrap"] = "Trap:Wind",
	["Caltrops"] = "Trap:Metal",
	["Searing Snare"] = "Trap:Fire",
	["Ice Eruption"] = "Eruption:Ice",
	["Tornado"] = "Eruption:Wind",
	["Shadow Eruption"] = "Eruption:Shadow",
	["Fire Eruption"] = "Eruption:Fire",
	["Lightning Strike"] = "Eruption:Lightning",
	["Metal Eruption"] = "Eruption:Metal",
	["Scarlet Cyclone"] = "Eruption:Blood",
	["Ice Beam"] = "Beam:Ice",
	["Lightning Beam"] = "Beam:Lightning",
	["Flare Volley"] = "Beam:Fire",
	["Scarlet Cannon"] = "Beam:Blood",
	["Air Force"] = "Blast:Wind",
	["Flame of Denial"] = "Clutch:Fire",
	["Vein Tendrils"] = "Clutch:Blood",
	["Summon Cauldron"] = "Cauldron:Intelligence",
	["Shade Bringer"] = "Bringer:Shadow",
	["Onslaught"] = "Bringer:WeaponHeavy",
	["Fire Blade"] = "Blade:Fire",
	["Wind Blade"] = "Blade:Wind",
	["Dark Blade"] = "Blade:Shadow",
	["Ice Blade"] = "Blade:Ice",
	["Lightning Blade"] = "Blade:Lightning",
	["Metal Armament"] = "Blade:Metal",
	["Bloodedge"] = "Blade:Blood",
	["Blood Wisp"] = "Wisp:Blood",
	["Flame Wisp"] = "Wisp:Fire",
	["Frost Wisp"] = "Wisp:Ice",
	["Thunder Wisp"] = "Wisp:Lightning",
	["Metal Wisp"] = "Wisp:Metal",
	["Shade Wisp"] = "Wisp:Shadow",
	["Gale Wisp"] = "Wisp:Wind",
	["Shadow Roar"] = "Roar:Shadow",
	["Graceful Flame"] = "Graceful:Fire",
	["Umbral Slash"] = "Slash:Shadow",
}

---Correct known builder data name mismatches.
correctBuilderName = function(name)
	return builderNameCorrections[name] or name
end

---Update talent sheet.
---@param rframe Frame
local updateTalentSheet = LPH_NO_VIRTUALIZE(function(rframe)
	task.wait()

	local talentSheet = rframe:FindFirstChild("TalentSheet")
	local container = talentSheet and talentSheet:FindFirstChild("Container")
	local talentScroll = container and container:FindFirstChild("TalentScroll")
	if not talentScroll then
		return
	end

	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	---@type BuilderData
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	-- Find a talent Frame template and category group template.
	local talentFrameTemplate = nil
	local categoryGroupTemplate = nil
	for _, category in next, talentScroll:GetChildren() do
		if category:IsA("Frame") and category:FindFirstChild("Title") then
			if not categoryGroupTemplate then
				categoryGroupTemplate = category
			end

			for _, talent in next, category:GetChildren() do
				if talent:IsA("Frame") and talent:FindFirstChild("Title") then
					talentFrameTemplate = talent
					break
				end
			end

			if talentFrameTemplate then
				break
			end
		end
	end

	if not talentFrameTemplate or not categoryGroupTemplate then
		return
	end

	-- Clean maid to re-setup.
	builderAssistanceMaid:clean()

	-- Create state.
	labelMap = {}

	-- First step: color everything inside and remove everything that is in the builder list already.
	local filteredTalents = table.clone(bdata.talents)

	-- Pre-build name to index lookup from talents for O(1) matching.
	local talentNameToIdx = {}
	for idx, talent in next, filteredTalents do
		local talentClean = stripTags(talent)
		talentNameToIdx[talentClean] = idx
		talentNameToIdx[talent] = idx
	end

	-- Iterate through Title TextLabels inside category sub-frames.
	for _, instance in next, talentScroll:GetDescendants() do
		if not instance:IsA("TextLabel") then
			continue
		end

		-- Only process Title labels.
		if instance.Name ~= "Title" then
			continue
		end

		local idx = talentNameToIdx[instance.Text]

		if not idx then
			continue
		end

		buildAssistanceMap:add(instance, "TextColor3", Color3.fromRGB(9, 255, 0))

		-- Remove from lookup to prevent duplicate matches.
		local talent = filteredTalents[idx]
		talentNameToIdx[stripTags(talent)] = nil
		talentNameToIdx[talent] = nil
		filteredTalents[idx] = nil
	end

	-- Second step: create a missing talents group and add unmatched talents.
	local missingTalentGroup = InstanceWrapper.mark(builderAssistanceMaid, "missingTalentGroup", categoryGroupTemplate:Clone())
	for _, child in next, missingTalentGroup:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	missingTalentGroup.Name = "LMissingTalents"
	missingTalentGroup.LayoutOrder = 9990

	local missingTalentTitle = missingTalentGroup:FindFirstChild("Title")
	if missingTalentTitle then
		missingTalentTitle.Text = "MISSING"
		missingTalentTitle.TextColor3 = Color3.fromRGB(255, 0, 2)
	end

	local hasMissingTalents = false
	local talentOrder = 1
	for _, talent in next, filteredTalents do
		-- Use full talent name (WITH tag) for ddata lookup since API stores with tags.
		local data = bdata.ddata:get(talent)
		if not data then
			continue
		end

		hasMissingTalents = true

		-- Strip tags for display (game shows without tags).
		local cleanTalent = stripTags(talent)

		local newFrame = InstanceWrapper.mark(builderAssistanceMaid, talent, talentFrameTemplate:Clone())
		local pshlocked = (bdata.ddata:possible(talent, bdata.pre) and not bdata.ddata:possible(talent, bdata.post))
		newFrame.Name = "M" .. cleanTalent
		newFrame.LayoutOrder = talentOrder
		talentOrder = talentOrder + 1

		local icon = newFrame:FindFirstChild("Icon")
		if icon then
			icon:Destroy()
		end

		-- Update Title text and color - display WITHOUT tag.
		local title = newFrame:FindFirstChild("Title")
		if title then
			title.Name = "M" .. cleanTalent
			title.Text = cleanTalent
			title.TextColor3 = pshlocked and Color3.fromRGB(255, 4, 255) or Color3.fromRGB(255, 0, 2)
			title.TextTransparency = 0.4
		end

		newFrame.Parent = missingTalentGroup

		labelMap["M" .. cleanTalent] = data
	end

	if hasMissingTalents then
		missingTalentGroup.Parent = talentScroll
	end

	-- Third step: create a missing mantras group and add unmatched mantras.
	local missingMantraGroup = InstanceWrapper.mark(builderAssistanceMaid, "missingMantraGroup", categoryGroupTemplate:Clone())
	for _, child in next, missingMantraGroup:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	missingMantraGroup.Name = "XMissingMantras"
	missingMantraGroup.LayoutOrder = 9995

	local missingMantraTitle = missingMantraGroup:FindFirstChild("Title")
	if missingMantraTitle then
		missingMantraTitle.Text = "MISSING MANTRAS"
		missingMantraTitle.TextColor3 = Color3.fromRGB(255, 0, 2)
	end

	local hasMissingMantras = false
	local mantraOrder = 1
	for _, mantra in next, bdata.mantras do
		-- Use full mantra name (WITH tag) for ddata lookup.
		local data = bdata.ddata:get(mantra)
		if not data then
			continue
		end

		-- Strip tags and correct builder name mismatches for display.
		local cleanMantra = correctBuilderName(stripTags(mantra))

		local idx = Table.find(players.LocalPlayer.Backpack:GetChildren(), function(value, _)
			local displayName = value:GetAttribute("DisplayName")
			if not displayName then
				return false
			end
			local cleanDisplayName = stripTags(displayName)
			return cleanDisplayName == cleanMantra or displayName == cleanMantra
		end)

		hasMissingMantras = true

		local newFrame = InstanceWrapper.mark(builderAssistanceMaid, mantra, talentFrameTemplate:Clone())
		local pshlocked = (bdata.ddata:possible(mantra, bdata.pre) and not bdata.ddata:possible(mantra, bdata.post))
		newFrame.Name = "Z" .. cleanMantra
		newFrame.LayoutOrder = mantraOrder
		mantraOrder = mantraOrder + 1

		local icon = newFrame:FindFirstChild("Icon")
		if icon then
			icon:Destroy()
		end

		local title = newFrame:FindFirstChild("Title")
		if title then
			title.Name = "Z" .. cleanMantra
			title.Text = cleanMantra
			title.TextColor3 = pshlocked and Color3.fromRGB(255, 4, 255) or Color3.fromRGB(255, 0, 2)
			title.TextTransparency = 0.4

			if idx then
				title.TextColor3 = Color3.fromRGB(9, 255, 0)
			end
		end

		newFrame.Parent = missingMantraGroup

		labelMap["Z" .. cleanMantra] = data
	end

	if hasMissingMantras then
		missingMantraGroup.Parent = talentScroll
	end
end)

---Update card hovering.
local updateCardHovering = LPH_NO_VIRTUALIZE(function()
	if os.clock() - lastHoveringUpdate <= 0.05 then
		return
	end

	lastHoveringUpdate = os.clock()

	local localPlayer = players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	local backpackGui = playerGui and playerGui:FindFirstChild("BackpackGui")
	if not backpackGui then
		return
	end

	local rightFrame = backpackGui and backpackGui:FindFirstChild("RightFrame")
	if not rightFrame then
		return
	end

	local talentSheet = rightFrame and rightFrame:FindFirstChild("TalentSheet")
	local container = talentSheet and talentSheet:FindFirstChild("Container")
	local talentScroll = container and container:FindFirstChild("TalentScroll")
	if not talentScroll then
		return
	end

	local talentDisplay = talentSheet and talentSheet:FindFirstChild("TalentDisplay")
	local cardFrame = talentDisplay and talentDisplay:FindFirstChild("CardFrame")
	if not cardFrame then
		return
	end

	local icon = cardFrame:FindFirstChild("Icon")
	local stats = cardFrame:FindFirstChild("Stats")
	local title = cardFrame:FindFirstChild("Title")

	local details = cardFrame:FindFirstChild("Details")
	local desc = details and details:FindFirstChild("Desc")
	local class = details and details:FindFirstChild("Class")

	if not icon or not stats or not class or not desc or not title then
		return
	end

	local mousePosition = userInputService:GetMouseLocation() - guiService:GetGuiInset()
	if not mousePosition then
		return
	end

	local guiObjects = playerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y)

	-- Build hovering set.
	local currentlyHovering = {}
	for _, object in next, guiObjects do
		if object:IsA("TextLabel") and labelMap[object.Name] then
			currentlyHovering[object.Name] = object
		end

		-- Check Frame > Title pattern.
		if object:IsA("Frame") then
			local titleLabel = object:FindFirstChild("Title")
			if titleLabel and titleLabel:IsA("TextLabel") and labelMap[titleLabel.Name] then
				currentlyHovering[titleLabel.Name] = titleLabel
			end
		end
	end

	-- Remove unhovered objects.
	for name, storedObject in next, hoveringMap do
		if currentlyHovering[name] then
			continue
		end

		-- Reset transparency.
		if storedObject and typeof(storedObject) == "Instance" and storedObject:IsA("TextLabel") then
			storedObject.TextTransparency = 0.4
		end

		hoveringMap[name] = nil
	end

	local firstHoveringData = nil
	local hoveringOverTalent = false

	-- Check talent sheet hover.
	for _, object in next, guiObjects do
		if not hoveringOverTalent and object:IsDescendantOf(talentSheet) then
			hoveringOverTalent = true
		end
	end

	-- Update hovered objects.
	for name, targetLabel in next, currentlyHovering do
		local data = labelMap[name]
		if not data then
			continue
		end

		-- Set transparency.
		targetLabel.TextTransparency = 0.1

		-- Store reference.
		hoveringMap[name] = targetLabel

		-- Set data.
		firstHoveringData = firstHoveringData or data
	end

	talentDisplay.Visible = hoveringOverTalent
	stats.Text = ""

	if not firstHoveringData then
		return
	end

	desc.Text = firstHoveringData.desc or "N/A"
	title.Text = firstHoveringData.name or "N/A"
	class.Text = firstHoveringData.category or "???"
	icon.ImageRectOffset = Vector2.new(0, 0)
	icon.Image = "rbxassetid://94097748688985"

	local colorTable = {
		["rare"] = Color3.fromRGB(145, 94, 95),
		["common"] = Color3.fromRGB(98, 97, 90),
		["advanced"] = Color3.fromRGB(58, 117, 129),
		["whisper"] = Color3.fromRGB(143, 110, 145),
		["mystery"] = Color3.fromRGB(145, 158, 172),
		["oath"] = Color3.fromRGB(25, 44, 62),
		["faction"] = Color3.fromRGB(52, 83, 41),
		["quest"] = Color3.fromRGB(153, 125, 47),
		["resonance"] = Color3.fromRGB(63, 78, 129),
		["corrupted resonance"] = Color3.fromRGB(117, 48, 81),
		["drowned resonance"] = Color3.fromRGB(198, 199, 255),
		["legendary resonance"] = Color3.fromRGB(222, 209, 191),
		["artifact"] = Color3.fromRGB(114, 77, 222),
	}

	local backgroundColor = colorTable[string.lower(firstHoveringData.rarity or "N/A")]
	if backgroundColor then
		cardFrame.BackgroundColor3 = backgroundColor
	end

	local reqData = firstHoveringData.reqs
	local reqTags = {}
	local tagMap = {
		["Strength"] = "STR",
		["Fortitude"] = "FTD",
		["Agility"] = "AGI",
		["Intelligence"] = "INT",
		["Willpower"] = "WIL",
		["Charisma"] = "CHA",
		["Mind"] = "MIND",
		["Body"] = "BODY",
		["Heavy Wep."] = "WEP",
		["Medium Wep."] = "WEP",
		["Light Wep."] = "WEP",
		["Flamecharm"] = "FLM",
		["Frostdraw"] = "FRST",
		["Thundercall"] = "THUN",
		["Galebreathe"] = "GALE",
		["Shadowcast"] = "SDW",
		["Ironsing"] = "IRON",
		["Bloodrend"] = "BLD",
	}

	local function checkAttributes(attributes)
		for idx, requirement in next, attributes do
			local tag = tagMap[idx]
			if not tag then
				continue
			end

			if requirement == 0 then
				continue
			end

			reqTags[#reqTags + 1] = string.format("%s %s", requirement, tag)
		end
	end

	if reqData.power ~= "0" then
		reqTags[#reqTags + 1] = string.format("PWR %s", reqData.power)
	end

	checkAttributes(reqData.base)
	checkAttributes(reqData.weapon)
	checkAttributes(reqData.attunement)

	stats.Text = table.concat(reqTags, ", ")
end)

---Update train.
---@param jframe Frame
local updateTrain = LPH_NO_VIRTUALIZE(function(jframe)
	local panels = jframe:FindFirstChild("Panels")
	local attributeFrame = panels and panels:FindFirstChild("AttributeFrame")
	local sheets = attributeFrame and attributeFrame:FindFirstChild("Sheets")
	if not sheets then
		return
	end

	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	---@type BuilderData
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	local attributes = bdata:attributes(drinfo)
	local mapping = {
		["Agility"] = attributes.base["Agility"],
		["Strength"] = attributes.base["Strength"],
		["Fortitude"] = attributes.base["Fortitude"],
		["Intelligence"] = attributes.base["Intelligence"],
		["Willpower"] = attributes.base["Willpower"],
		["Charisma"] = attributes.base["Charisma"],
		["ElementBlood"] = attributes.attunement["Bloodrend"],
		["ElementFire"] = attributes.attunement["Flamecharm"],
		["ElementIce"] = attributes.attunement["Frostdraw"],
		["ElementLightning"] = attributes.attunement["Thundercall"],
		["ElementWind"] = attributes.attunement["Galebreathe"],
		["ElementShadow"] = attributes.attunement["Shadowcast"],
		["ElementMetal"] = attributes.attunement["Ironsing"],
		["WeaponHeavy"] = attributes.weapon["Heavy Wep."],
		["WeaponMedium"] = attributes.weapon["Medium Wep."],
		["WeaponLight"] = attributes.weapon["Light Wep."],
	}

	for _, instance in next, sheets:GetDescendants() do
		if not instance:IsA("TextButton") then
			continue
		end

		local expectedValue = mapping[instance.Name]
		if not expectedValue then
			continue
		end

		local train = instance:FindFirstChild("Train")
		if not train then
			continue
		end

		if not train.Visible then
			continue
		end

		local valueLabel = instance:FindFirstChild("Value")
		if not valueLabel then
			continue
		end

		local statInvested = tonumber(drinfo["Stat" .. instance.Name])
		if not statInvested then
			continue
		end

		local value = (bdata:ipre(drinfo) == 0 and statInvested <= 0) and statInvested or tonumber(valueLabel.Text)
		if not value then
			continue
		end

		local color = expectedValue ~= value and Color3.fromRGB(9, 136, 0) or Color3.fromRGB(127, 0, 2)

		if value > expectedValue then
			color = Color3.fromRGB(128, 128, 128)
		end

		buildAssistanceMap:add(train, "ImageColor3", color)
	end
end)

---Apply auto favour to build cards and unfavour non-build cards.
local function applyAutoFavour()
	local bdata = Visuals.bdata
	if not bdata then
		return
	end

	local drinfo = Visuals.drinfo
	if not drinfo then
		return
	end

	local requests = replicatedStorage:FindFirstChild("Requests")
	if not requests then
		return
	end

	local cards = requests:FindFirstChild("Cards")
	if not cards then
		return
	end

	local favourCard = cards:FindFirstChild("FavourCard")
	if not favourCard then
		return
	end

	local removeFavourRemote = cards:FindFirstChild("RemoveFavour")
	if not removeFavourRemote then
		return
	end

	-- Collect card names (internal format) and build a set for lookup.
	local names = {}
	local buildSet = {}

	for _, talent in next, bdata.talents do
		local name = correctBuilderName(stripTags(talent))
		table.insert(names, name)
		buildSet[name] = true
	end

	for _, mantra in next, bdata.mantras do
		local displayName = correctBuilderName(stripTags(mantra))
		local internalName = mantraDisplayToInternal[displayName] or displayName
		table.insert(names, internalName)
		buildSet[internalName] = true
	end

	-- Check current favour state to skip already-favoured cards.
	local cardsFavoured = drinfo.CardsFavoured
	local cardsForetold = drinfo.CardsForetold

	local favourNames = {}
	for _, name in next, names do
		if not (cardsFavoured and cardsFavoured[name]) then
			table.insert(favourNames, name)
		end
	end

	-- Collect non-build favoured cards to unfavour (skip foretold).
	local unfavourNames = {}

	if cardsFavoured then
		for cardName, _ in next, cardsFavoured do
			if not buildSet[cardName] and not (cardsForetold and cardsForetold[cardName]) then
				table.insert(unfavourNames, cardName)
			end
		end
	end

	lastFavouredNames = names
	autoFavourApplied = true
	autoFavourBdata = bdata

	TaskSpawner.spawn("Visuals_AutoFavourCards", function()
		-- Favour build cards that aren't already favoured.
		for _, name in next, favourNames do
			pcall(favourCard.InvokeServer, favourCard, name)
			task.wait(0.1)
		end

		-- Unfavour non-build cards.
		for _, name in next, unfavourNames do
			pcall(removeFavourRemote.InvokeServer, removeFavourRemote, name)
			task.wait(0.1)
		end

		Logger.notify("Favoured %d cards, unfavoured %d non-build cards.", #favourNames, #unfavourNames)
	end)
end

---Update build assistance.
local updateBuildAssistance = LPH_NO_VIRTUALIZE(function()
	updateCardFrames()

	local localPlayer = players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	local backpackGui = playerGui and playerGui:FindFirstChild("BackpackGui")
	if not backpackGui then
		return
	end

	local rightFrame = backpackGui and backpackGui:FindFirstChild("RightFrame")
	if not rightFrame then
		return
	end

	local bpJournalFrame = rightFrame and rightFrame:FindFirstChild("JournalFrame")
	if not bpJournalFrame then
		return
	end

	updateAttributeFrame(bpJournalFrame)
	updateTraits(bpJournalFrame)
	updatePowerBackground(bpJournalFrame)
	updateTalentSheet(rightFrame)
	updateTrain(bpJournalFrame)

	-- Auto favour cards.
	local shouldFavour = Configuration.expectToggleValue("AutoFavourCards") and Visuals.bdata
	if shouldFavour and (not autoFavourApplied or Visuals.bdata ~= autoFavourBdata) then
		applyAutoFavour()
	end
end)

---Update no persistence.
local updateNoPersistence = LPH_NO_VIRTUALIZE(function()
	local localPlayer = players.LocalPlayer
	if not localPlayer then
		return
	end

	for _, group in next, groups do
		for _, object in next, group:data() do
			if object.__type == "PlayerESP" and object.character and object.character:IsA("Model") then
				noPersistentMap:add(object.character, "ModelStreamingMode", Enum.ModelStreamingMode.Default)
			end

			if object.__type == "ModelESP" and object.model then
				noPersistentMap:add(object.model, "ModelStreamingMode", Enum.ModelStreamingMode.Default)
			end
		end
	end
end)

---Update show roblox chat.
local updateShowRobloxChat = LPH_NO_VIRTUALIZE(function()
	local localPlayer = players.LocalPlayer
	if not localPlayer then
		return
	end

	local playerGui = localPlayer.PlayerGui
	if not playerGui then
		return
	end

	local chatWindowConfiguration = textChatService:FindFirstChild("ChatWindowConfiguration")
	if not chatWindowConfiguration then
		return
	end

	showRobloxChatMap:add(chatWindowConfiguration, "Enabled", true)

	---@note: Probably set a proper restore for this?
	--- But, in Deepwoken, users cannot realisitically access the Roblox chat anyway.
	textChatService.OnIncomingMessage = function(message)
		local source = message.TextSource
		if not source then
			return
		end

		local player = players:GetPlayerByUserId(source.UserId)
		if not player then
			return
		end

		if Configuration.expectToggleValue("InfoSpoofing") then
			message.PrefixText = "[REDACTED]"
			return
		end

		message.PrefixText = string.gsub(message.PrefixText, player.DisplayName, player.Name)
		message.PrefixText =
			string.format("(%s) %s", player:GetAttribute("CharacterName") or "Unknown Character Name", player.Name)
	end
end)

---Update no animated sea.
local updateNoAnimatedSea = LPH_NO_VIRTUALIZE(function()
	local localPlayer = players.LocalPlayer
	local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return
	end

	local seaClient = playerScripts:FindFirstChild("SeaClient")
	if not seaClient then
		return
	end

	noAnimatedSeaMap:add(seaClient, "Enabled", false)

	for _, descendant in next, seaClient:GetDescendants() do
		if not descendant:IsA("LocalScript") then
			continue
		end

		noAnimatedSeaMap:add(descendant, "Enabled", false)
	end
end)

---Update terrain attachments.
local updateTerrainAttachments = LPH_NO_VIRTUALIZE(function()
	for _, attachment in next, attachments do
		local jtg = attachment:FindFirstChild("JobTrackerGui")
		if not jtg then
			continue
		end

		jobBoardMap:add(jtg, "MaxDistance", Configuration.idOptionValue("JobBoard", "MaxDistance") or 1e9)
	end
end)

---Update mystery mantra reveal.
local updateMysteryReveal = LPH_NO_VIRTUALIZE(function()
	local drinfo = Visuals.drinfo
	if not drinfo or not drinfo.AvailableMantras then
		return
	end

	-- Build mantra data lookup from AvailableMantras.
	local mantraDataLookup = {}
	for _, mantra in next, drinfo.AvailableMantras do
		if mantra.Name then
			mantraDataLookup[mantra.Name] = mantra
		end
	end

	for frame in next, cardFrames do
		local parent = frame.Parent
		if not parent then
			continue
		end

		-- Only process ChoiceFrame cards.
		local choiceFrame = parent.Parent
		if not choiceFrame or choiceFrame.Name ~= "ChoiceFrame" then
			continue
		end

		-- Check if this card is a mystery card by its class text.
		local details = frame:FindFirstChild("Details")
		if not details then
			continue
		end

		local class = details:FindFirstChild("Class")
		if not class or class.Text ~= "Mystery" then
			continue
		end

		-- Look up the real mantra data by the card's internal name.
		local realData = mantraDataLookup[parent.Name]
		if not realData then
			continue
		end

		local title = frame:FindFirstChild("Title")
		if title and realData.MantraName then
			mysteryRevealMap:add(title, "Text", realData.MantraName)
		end

		if realData.Class then
			mysteryRevealMap:add(class, "Text", realData.Class)
		end

		local desc = details:FindFirstChild("Desc")
		if desc and realData.Desc then
			mysteryRevealMap:add(desc, "Text", realData.Desc)
		end
	end
end)

---Update Roll 2 reveal.
local updateRoll2Reveal = LPH_NO_VIRTUALIZE(function()
	-- Cache Roll 2 selection from TalentChoice when available.
	local drinfo = Visuals.drinfo
	if drinfo then
		local talentChoice = drinfo.TalentChoice
		if talentChoice and talentChoice.Selection then
			for _, entry in next, talentChoice.Selection do
				if entry.Type == "Roll2" and entry.Selection then
					cachedRoll2Selection = entry.Selection
					break
				end
			end
		end
	end

	if roll2Notified or not cachedRoll2Selection then
		return
	end

	-- Verify the Roll 2 card is actually visible in ChoiceFrame.
	local found = false
	for frame in next, cardFrames do
		local parent = frame.Parent
		if parent and parent.Name == "Roll 2" then
			local choiceFrame = parent.Parent
			if choiceFrame and choiceFrame.Name == "ChoiceFrame" then
				found = true
				break
			end
		end
	end

	if not found then
		return
	end

	roll2Notified = true

	local dismiss = Logger.mnnotify("Available Roll 2 Talents:")
	if dismiss then
		table.insert(roll2Dismissals, dismiss)
	end

	for _, talent in next, cachedRoll2Selection do
		local talentDismiss =
			Logger.mnnotify("  %s (%s) - %s", talent.Name or "Unknown", talent.Class or "Unknown", talent.Desc or "")
		if talentDismiss then
			table.insert(roll2Dismissals, talentDismiss)
		end
	end
end)

---Update ESP.
local updateESP = LPH_NO_VIRTUALIZE(function()
	if os.clock() - lastESPUpdate <= (1 / (Configuration.expectOptionValue("ESPRefreshRate") or 30)) then
		return
	end

	lastESPUpdate = os.clock()

	for _, group in next, groups do
		group:update()
	end
end)

---Update visuals.
local updateVisuals = LPH_NO_VIRTUALIZE(function()
	updateESP()

	if Configuration.expectToggleValue("BuildAssistance") then
		updateCardHovering()
	end

	if os.clock() - lastVisualsUpdate <= 2.5 then
		return
	end

	lastVisualsUpdate = os.clock()

	if Configuration.expectToggleValue("MysteryMantraRevealer") then
		updateMysteryReveal()
	else
		mysteryRevealMap:restore()
	end

	if Configuration.expectToggleValue("Roll2Revealer") then
		updateRoll2Reveal()
	else
		dismissRoll2()
		roll2Notified = false
	end

	if Configuration.idToggleValue("JobBoard", "Enable") then
		updateTerrainAttachments()
	else
		jobBoardMap:restore()
	end

	if Configuration.expectToggleValue("ChainOfPerfectionTracker") then
		updateChainOfPerfectionTracker()
	else
		visualsMaid["StackTextLabel"] = nil
	end

	if Configuration.expectToggleValue("SanityTracker") then
		updateSanityTracker()
	else
		visualsMaid["SanityTextLabel"] = nil
	end

	if Configuration.expectToggleValue("BuildAssistance") then
		updateBuildAssistance()
	else
		buildAssistanceMap:restore()
		builderAssistanceMaid:clean()
	end

	if Configuration.expectToggleValue("NoPersisentESP") then
		updateNoPersistence()
	else
		noPersistentMap:restore()
	end

	if Configuration.expectToggleValue("NoAnimatedSea") then
		updateNoAnimatedSea()
	else
		noAnimatedSeaMap:restore()
	end

	if Configuration.expectToggleValue("ModifyFieldOfView") then
		-- Save original.
		fieldOfView = fieldOfView or players.LocalPlayer:GetAttribute("FieldOfView")

		-- Set modified.
		players.LocalPlayer:SetAttribute("FieldOfView", Configuration.expectOptionValue("FieldOfView"))
	elseif fieldOfView then
		-- Set original.
		players.LocalPlayer:SetAttribute("FieldOfView", fieldOfView)

		-- Clear.
		fieldOfView = nil
	end

	if Configuration.expectToggleValue("ShowRobloxChat") then
		updateShowRobloxChat()
	else
		showRobloxChatMap:restore()
	end
end)

---Emplace object.
---@param instance Instance
---@param object ModelESP|PartESP
local emplaceObject = LPH_NO_VIRTUALIZE(function(instance, object)
	local group = groups[object.identifier] or Group.new(object.identifier)

	group:insert(instance, object)

	groups[object.identifier] = group
end)

---On Live ChildAdded.
---@param child Instance
local onLiveChildrenAdded = LPH_NO_VIRTUALIZE(function(child)
	if players:GetPlayerFromCharacter(child) then
		return
	end

	-- Safeguard to not get players on the Mob ESP.
	if players:FindFirstChild(child.Name) then
		return
	end

	return emplaceObject(
		child,
		FilteredESP.new(MobESP.new("Mob", child, child:GetAttribute("MOB_rich_name") or child.Name))
	)
end)

---On NPCs ChildAdded.
---@param child Instance
local onNPCsChildAdded = LPH_NO_VIRTUALIZE(function(child)
	if child.Name == "WindrunnerOrb" and child:IsA("BasePart") then
		return emplaceObject(child, PartESP.new("WindrunnerOrb", child, "Windrunner Orb"))
	end

	return emplaceObject(child, ModelESP.new("NPC", child, child.Name))
end)

---On Ingredients ChildAdded.
---@param child Instance
local onIngredientsChildAdded = LPH_NO_VIRTUALIZE(function(child)
	return emplaceObject(child, FilteredESP.new(PartESP.new("Ingredient", child, child.Name)))
end)

---On Thrown ChildAdded.
---@param child Instance
local onThrownChildAdded = LPH_NO_VIRTUALIZE(function(child)
	local name = child.Name

	if name == "MinistryCacheIndicator" then
		return emplaceObject(child, PartESP.new("MinistryCacheIndicator", child, "Ministry Cache Indicator"))
	end

	if name == "BigArtifact" and child:IsA("Model") then
		return emplaceObject(child, ModelESP.new("Artifact", child, "Artifact"))
	end

	if name == "BellMeteor" then
		return emplaceObject(child, ModelESP.new("BellMeteor", child, "Bell Meteor"))
	end

	if name == "ExplodeCrate" then
		return emplaceObject(child, PartESP.new("ExplosiveBarrel", child, "Explosive Barrel"))
	end

	if name == "BagDrop" then
		return emplaceObject(child, PartESP.new("BagDrop", child, "Bag"))
	end

	if name == "EventFeatherRef" then
		return emplaceObject(child, PartESP.new("OwlFeathers", child, "Owl Feathers"))
	end

	if name == "BoneSpear" then
		return emplaceObject(child, PartESP.new("BoneSpear", child, "Bone Spear"))
	end

	visualsMaid:mark(TaskSpawner.spawn("Visuals_ChestCheck", function()
		if child.Name == "Chest" and child:GetAttribute("LootName") ~= nil then
			return emplaceObject(child, ChestESP.new("Chest", child, "Chest"))
		end

		if not child:IsA("Model") and not child:IsA("Part") then
			return
		end

		if child:WaitForChild("LootUpdated", 0.1) then
			return emplaceObject(child, ChestESP.new("Chest", child, "Chest"))
		end
	end))
end)

---On Shop ChildAdded.
---@param child Instance
local onShopChildAdded = LPH_NO_VIRTUALIZE(function(child)
	local name = child.Name

	if not child:FindFirstChild("Cost") then
		return
	end

	if child:IsA("Model") then
		return emplaceObject(child, ModelESP.new("ShopESP", child, name))
	end

	return emplaceObject(child, PartESP.new("ShopESP", child, name))
end)

---Create listener.
---@param instance Instance
---@param identifier string
---@param addedCallback function
---@param removingCallback function
---@param childFlag boolean
local createListener = LPH_NO_VIRTUALIZE(function(instance, identifier, addedCallback, removingCallback, childFlag)
	local type = childFlag and "Child" or "Descendant"
	local added = Signal.new(childFlag and instance.ChildAdded or instance.DescendantAdded)
	local removed = Signal.new(childFlag and instance.ChildRemoved or instance.DescendantRemoving)

	visualsMaid:add(added:connect(string.format("Visuals_%sOn%sAdded", identifier, type), addedCallback))
	visualsMaid:add(removed:connect(string.format("Visuals_%sOn%sRemoved", identifier, type), removingCallback))

	Profiler.run(string.format("Visuals_%sAddInitial", identifier), function()
		for _, child in next, (childFlag and instance:GetChildren() or instance:GetDescendants()) do
			addedCallback(child)
		end
	end)
end)

-- Forward declaration.
local onWorkspaceChildAdded = nil

---On instance removing.
---@param inst Instance
local onInstanceRemoving = LPH_NO_VIRTUALIZE(function(inst)
	for _, group in next, groups do
		local object = group:remove(inst)
		if not object then
			continue
		end

		object:detach()
	end
end)

---On Avatar Room DescendantAdded.
---@param descendant Instance
local onAvatarRoomDescendantAdded = LPH_NO_VIRTUALIZE(function(descendant)
	if descendant.Name ~= "Altar" then
		return
	end

	return emplaceObject(descendant, BoneAltarESP.new("BoneAltar", descendant, "Bone Altar"))
end)

---On Workspace ChildAdded.
---@param child Instance
onWorkspaceChildAdded = LPH_NO_VIRTUALIZE(function(child)
	local name = child.Name

	if name == "Layer2Floor2" then
		return createListener(child, "Layer2Floor2", onWorkspaceChildAdded, onInstanceRemoving, true)
	end

	if name == "TrueAvatarBossRoom" then
		return createListener(child, "TrueAvatarBossRoom", onAvatarRoomDescendantAdded, onInstanceRemoving, false)
	end

	if name == "BellKeys" then
		for _, descendant in next, child:GetDescendants() do
			if not descendant:IsA("BasePart") then
				continue
			end

			if descendant.Name ~= "BellKey" then
				continue
			end

			return emplaceObject(descendant, PartESP.new("BellKey", descendant, "Bell Key"))
		end
	end

	if name == "JobBoard" then
		return emplaceObject(child, ModelESP.new("JobBoard", child, "Job Board"))
	end

	if name == "BigArtifact" and child:IsA("Model") then
		return emplaceObject(child, ModelESP.new("Artifact", child, "Artifact"))
	end

	if name == "WindrunnerOrb" and child:IsA("BasePart") then
		return emplaceObject(child, PartESP.new("WindrunnerOrb", child, "Windrunner Orb"))
	end

	if name == "DepthsWhirlpool" then
		return emplaceObject(child, ModelESP.new("Whirlpool", child, "Whirlpool"))
	end

	if name == "Sack" then
		return emplaceObject(child, PartESP.new("BagDrop", child, "Sack"))
	end

	if name == "MinistryCacheIndicator" then
		return emplaceObject(child, PartESP.new("MinistryCacheIndicator", child, "Ministry Cache Indicator"))
	end

	if name:match("GuildDoor") then
		local doorName = child:GetAttribute("GuildName") or "Unidentified Guild Door"
		return emplaceObject(child, PartESP.new("GuildDoor", child, doorName))
	end

	if name == "GuildBanner" then
		return emplaceObject(child, ModelESP.new("GuildBanner", child, "Guild Banner"))
	end

	if name == "Obelisk" then
		return emplaceObject(child, ObeliskESP.new("Obelisk", child, "Obelisk"))
	end

	if name:match("ArmorBrick") then
		local billboardGui = child:FindFirstChild("BillboardGui")
		local armorBrickLabel = billboardGui and billboardGui:FindFirstChild("TextLabel")
		local armorBrickName = armorBrickLabel and armorBrickLabel.Text

		if not armorBrickLabel then
			armorBrickName = "Unknown Armor Brick"
		end

		return emplaceObject(child, PartESP.new("ArmorBrick", child, armorBrickName))
	end

	if name == "RareObelisk" then
		return emplaceObject(child, ModelESP.new("RareObelisk", child, "Rare Obelisk"))
	end

	if name == "HealBrick" then
		return emplaceObject(child, PartESP.new("HealBrick", child, "Heal Brick"))
	end

	if name == "MantraObelisk" then
		return emplaceObject(child, ModelESP.new("MantraObelisk", child, "Mantra Obelisk"))
	end

	if name:match("Boundary") then
		return emplaceObject(child, PartESP.new("VOIBoundaryESP", child, child.Name))
	end

	if child:GetAttribute("Rarity") and child:IsA("MeshPart") then
		return emplaceObject(child, PartESP.new("VOIWeaponESP", child, child.Name))
	end

	visualsMaid:mark(TaskSpawner.spawn("Visuals_BRWeaponCheck", function()
		if child:IsA("MeshPart") and child:WaitForChild("InteractPrompt", 0.1) and not name:match("Barrel") then
			return emplaceObject(child, PartESP.new("BRWeapon", child, name))
		end
	end))
end)

---On terrain added.
local onTerrainChildAdded = LPH_NO_VIRTUALIZE(function(child)
	if child.Name ~= "Attachment" and not child:IsA("Attachment") then
		return
	end

	attachments[#attachments + 1] = child
end)

---On player added.
---@param player Player
local onPlayerAdded = LPH_NO_VIRTUALIZE(function(player)
	if player == players.LocalPlayer then
		return
	end

	local characterAdded = Signal.new(player.CharacterAdded)
	local characterRemoving = Signal.new(player.CharacterRemoving)
	local playerDestroying = Signal.new(player.Destroying)

	local characterAddedId = nil
	local characterRemovingId = nil
	local playerDestroyingId = nil

	characterAddedId = visualsMaid:add(characterAdded:connect("Visuals_OnCharacterAdded", function(character)
		emplaceObject(player, PlayerESP.new("Player", player, character))
	end))

	characterRemovingId = visualsMaid:add(characterRemoving:connect("Visuals_OnCharacterRemoving", function()
		onInstanceRemoving(player)
	end))

	playerDestroyingId = visualsMaid:add(playerDestroying:connect("Visuals_OnPlayerDestroying", function()
		visualsMaid[characterAddedId] = nil
		visualsMaid[characterRemovingId] = nil
		visualsMaid[playerDestroyingId] = nil
	end))

	local character = player.Character
	if not character then
		return
	end

	emplaceObject(player, PlayerESP.new("Player", player, character))
end)

---Initialize Visuals.
function Visuals.init()
	local live = workspace:WaitForChild("Live")
	local npcs = workspace:WaitForChild("NPCs")
	local ingredients = workspace:WaitForChild("Ingredients")
	local thrown = workspace:WaitForChild("Thrown")
	local terrain = workspace:WaitForChild("Terrain")
	local shops = workspace:WaitForChild("Shops")

	createListener(terrain, "Terrain", onTerrainChildAdded, onInstanceRemoving, true)
	createListener(workspace, "Workspace", onWorkspaceChildAdded, onInstanceRemoving, true)
	createListener(thrown, "Thrown", onThrownChildAdded, onInstanceRemoving, true)
	createListener(live, "Live", onLiveChildrenAdded, onInstanceRemoving, true)
	createListener(npcs, "NPCs", onNPCsChildAdded, onInstanceRemoving, true)
	createListener(ingredients, "Ingredients", onIngredientsChildAdded, onInstanceRemoving, true)
	createListener(players, "Players", onPlayerAdded, onInstanceRemoving, true)
	createListener(shops, "Shops", onShopChildAdded, onInstanceRemoving, true)

	---@note: We only need to get this once.
	for _, descendant in next, replicatedStorage:WaitForChild("MarkerWorkspace"):GetDescendants() do
		if descendant.Name ~= "AreaMarker" then
			continue
		end

		local areaMarkerName = descendant.Parent.Name or "Unidentified Area Marker"
		emplaceObject(descendant, FilteredESP.new(PartESP.new("AreaMarker", descendant, areaMarkerName)))
	end

	local localPlayer = players.LocalPlayer
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local playerGuiDescendantAdded = Signal.new(playerGui.DescendantAdded)
	local playerGuiDescendantRemoving = Signal.new(playerGui.DescendantRemoving)

	-- Wait for UIVanity and fix its initialization.
	visualsMaid:mark(TaskSpawner.spawn("Visuals_UIVanityWait", function()
		local uiVanity = playerGui:WaitForChild("UIVanity", 10)

		-- Disable and re-enable UIVanity to fix initialization issues.
		if uiVanity then
			uiVanity.Enabled = false
			task.wait()
			uiVanity.Enabled = true
		end

		-- Now safe to connect signals and process GUI.
		visualsMaid:add(playerGuiDescendantAdded:connect("Visuals_OnPlayerGuiDescendantAdded", onPlayerGuiDescendantAdded))
		visualsMaid:add(
			playerGuiDescendantRemoving:connect("Visuals_OnPlayerGuiDescendantRemoving", onPlayerGuiDescendantRemoving)
		)
		visualsMaid:add(renderStepped:connect("Visuals_RenderStepped", updateVisuals))

		for _, descendant in next, playerGui:GetDescendants() do
			onPlayerGuiDescendantAdded(descendant)
		end
	end))

	local info = replicatedStorage:WaitForChild("Info")
	local dataReplication = info:WaitForChild("DataReplication")
	local dataReplicationModule = require(dataReplication)

	-- GetData() can fail on hot reload after remotes have been called because
	-- The game's internal DataReplication state changes (require cache corruption).
	-- Strategy: Try GetData() first, fall back to reading directly from character attributes.
	local success, drinfo = pcall(function()
		return dataReplicationModule.GetData()
	end)

	if success and type(drinfo) == "table" then
		Visuals.drinfo = drinfo
	else
		-- GetData() failed - read data directly from character attributes (always fresh).
		Logger.warn("GetData() failed, reading stats directly from character...")

		local character = localPlayer and localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local fallbackData = {}
			local statNames = {
				"Agility",
				"Strength",
				"Fortitude",
				"Intelligence",
				"Willpower",
				"Charisma",
				"ElementBlood",
				"ElementFire",
				"ElementIce",
				"ElementLightning",
				"ElementWind",
				"ElementShadow",
				"ElementMetal",
				"WeaponHeavy",
				"WeaponMedium",
				"WeaponLight",
			}

			for _, statName in ipairs(statNames) do
				local key = "Stat" .. statName
				fallbackData[key] = humanoid:GetAttribute(key) or character:GetAttribute(key) or 0
			end

			-- Read trait attributes.
			fallbackData["TraitHealth"] = humanoid:GetAttribute("TraitHealth") or character:GetAttribute("TraitHealth") or 0
			fallbackData["TraitEther"] = humanoid:GetAttribute("TraitEther") or character:GetAttribute("TraitEther") or 0
			fallbackData["TraitWeaponDamage"] = humanoid:GetAttribute("TraitWeaponDamage")
				or character:GetAttribute("TraitWeaponDamage")
				or 0
			fallbackData["TraitMantraDamage"] = humanoid:GetAttribute("TraitMantraDamage")
				or character:GetAttribute("TraitMantraDamage")
				or 0

			Visuals.drinfo = fallbackData
			Logger.warn("Successfully read stats from character attributes (fallback mode).")
		else
			Visuals.drinfo = nil
			Logger.warn("Could not read character attributes - BuildAssistance disabled.")
		end
	end

	Logger.warn("Visuals initialized.")
end

-- Detach Visuals.
function Visuals.detach()
	for _, group in next, groups do
		group:detach()
	end

	mysteryRevealMap:restore()
	autoFavourApplied = false
	autoFavourBdata = nil
	lastFavouredNames = {}
	dismissRoll2()
	roll2Notified = false
	cachedRoll2Selection = nil

	visualsMaid:clean()
	builderAssistanceMaid:clean()

	Logger.warn("Visuals detached.")
end

-- Return Visuals module.
return Visuals
