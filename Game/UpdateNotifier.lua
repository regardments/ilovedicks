-- Update notifier popup.
local UpdateNotifier = {}

---@module GUI.Library
local Library = require("GUI/Library")

---@module Utility.Logger
local Logger = require("Utility/Logger")

-- Services.
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")

-- Constants.
local VERSION_FILE = "Lycoris-Rewrite-Version.txt"

---Check if update popup should show and display it.
---@param version string
function UpdateNotifier.check(version)
	if not version then
		return
	end

	-- Check workspace version file.
	local shouldShow = false

	if isfile and isfile(VERSION_FILE) then
		local savedVersion = readfile(VERSION_FILE)
		if savedVersion ~= version then
			shouldShow = true
		end
	else
		shouldShow = true
	end

	if not shouldShow then
		return
	end

	if shared.Lycoris and shared.Lycoris.silent then
		return
	end

	-- Update file.
	if writefile then
		pcall(writefile, VERSION_FILE, version)
	end

	-- Show popup.
	UpdateNotifier.show(version)
end

---Show the update popup.
---@param version string
function UpdateNotifier.show(version)
	-- ScreenGui.
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LycorisUpdatePopup"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999
	screenGui.IgnoreGuiInset = true

	pcall(function()
		screenGui.Parent = coreGui
	end)

	if not screenGui.Parent then
		pcall(function()
			screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end)
	end

	-- Overlay.
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 90
	overlay.Parent = screenGui

	-- Outer frame.
	local outer = Instance.new("Frame")
	outer.Name = "Outer"
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	outer.Position = UDim2.new(0.5, 0, 0.5, 0)
	outer.Size = UDim2.new(0, 380, 0, 340)
	outer.BackgroundTransparency = 1
	outer.BorderSizePixel = 0
	outer.ZIndex = 100
	outer.Parent = screenGui

	-- Inner frame.
	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.new(1, 0, 1, 0)
	inner.BackgroundColor3 = Library.MainColor
	inner.BorderMode = Enum.BorderMode.Inset
	inner.BorderColor3 = Library.OutlineColor
	inner.BorderSizePixel = 1
	inner.ZIndex = 101
	inner.BackgroundTransparency = 1
	inner.Parent = outer

	Library:AddToRegistry(inner, {
		BackgroundColor3 = "MainColor",
		BorderColor3 = "OutlineColor",
	})

	-- Accent bar.
	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Size = UDim2.new(1, 0, 0, 2)
	accentBar.Position = UDim2.new(0, 0, 0, 0)
	accentBar.BackgroundColor3 = Library.AccentColor
	accentBar.BorderSizePixel = 0
	accentBar.ZIndex = 102
	accentBar.BackgroundTransparency = 1
	accentBar.Parent = inner

	Library:AddToRegistry(accentBar, {
		BackgroundColor3 = "AccentColor",
	})

	-- Title.
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "v" .. version .. " New Update"
	title.Position = UDim2.new(0, 0, 0, 8)
	title.Size = UDim2.new(1, 0, 0, 22)
	title.BackgroundTransparency = 1
	title.TextColor3 = Library.AccentColor
	title.FontFace = Library.Font
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 102
	title.TextTransparency = 1
	title.Parent = inner

	Library:AddToRegistry(title, {
		TextColor3 = "AccentColor",
	})

	-- Separator.
	local separator = Instance.new("Frame")
	separator.Name = "Separator"
	separator.Size = UDim2.new(1, -16, 0, 1)
	separator.Position = UDim2.new(0, 8, 0, 34)
	separator.BackgroundColor3 = Library.OutlineColor
	separator.BorderSizePixel = 0
	separator.ZIndex = 102
	separator.BackgroundTransparency = 1
	separator.Parent = inner

	Library:AddToRegistry(separator, {
		BackgroundColor3 = "OutlineColor",
	})

	-- Body scrolling frame.
	local bodyFrame = Instance.new("ScrollingFrame")
	bodyFrame.Name = "Body"
	bodyFrame.Position = UDim2.new(0, 8, 0, 40)
	bodyFrame.Size = UDim2.new(1, -16, 1, -82)
	bodyFrame.BackgroundColor3 = Library.BackgroundColor
	bodyFrame.BorderColor3 = Library.OutlineColor
	bodyFrame.BorderMode = Enum.BorderMode.Inset
	bodyFrame.BorderSizePixel = 1
	bodyFrame.ScrollBarThickness = 4
	bodyFrame.ScrollBarImageColor3 = Library.AccentColor
	bodyFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	bodyFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	bodyFrame.ZIndex = 102
	bodyFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	bodyFrame.BackgroundTransparency = 1
	bodyFrame.Parent = inner

	Library:AddToRegistry(bodyFrame, {
		BackgroundColor3 = "BackgroundColor",
		BorderColor3 = "OutlineColor",
		ScrollBarImageColor3 = "AccentColor",
	})

	-- Body text.
	local bodyText = Instance.new("TextLabel")
	bodyText.Name = "BodyText"
	bodyText.Text = "Loading release notes..."
	bodyText.Size = UDim2.new(1, -12, 0, 0)
	bodyText.Position = UDim2.new(0, 6, 0, 4)
	bodyText.AutomaticSize = Enum.AutomaticSize.Y
	bodyText.BackgroundTransparency = 1
	bodyText.TextColor3 = Library.FontColor
	bodyText.FontFace = Library.Font
	bodyText.TextSize = 15
	bodyText.TextXAlignment = Enum.TextXAlignment.Left
	bodyText.TextYAlignment = Enum.TextYAlignment.Top
	bodyText.TextWrapped = true
	bodyText.ZIndex = 103
	bodyText.RichText = true
	bodyText.TextTransparency = 1
	bodyText.Parent = bodyFrame

	Library:AddToRegistry(bodyText, {
		TextColor3 = "FontColor",
	})

	-- Dismiss button.
	local dismissBtn = Instance.new("TextButton")
	dismissBtn.Name = "Dismiss"
	dismissBtn.AnchorPoint = Vector2.new(0.5, 0)
	dismissBtn.Position = UDim2.new(0.5, 0, 1, -36)
	dismissBtn.Size = UDim2.new(1, -16, 0, 28)
	dismissBtn.BackgroundColor3 = Library.MainColor
	dismissBtn.BorderColor3 = Library.OutlineColor
	dismissBtn.BorderMode = Enum.BorderMode.Inset
	dismissBtn.BorderSizePixel = 1
	dismissBtn.Text = "Dismiss"
	dismissBtn.TextColor3 = Library.FontColor
	dismissBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	dismissBtn.TextSize = 16
	dismissBtn.ZIndex = 102
	dismissBtn.AutoButtonColor = false
	dismissBtn.BackgroundTransparency = 1
	dismissBtn.TextTransparency = 1
	dismissBtn.Parent = inner

	Library:AddToRegistry(dismissBtn, {
		BackgroundColor3 = "MainColor",
		BorderColor3 = "OutlineColor",
		TextColor3 = "FontColor",
	})

	-- Button hover.
	dismissBtn.MouseEnter:Connect(function()
		dismissBtn.BackgroundColor3 = Library.AccentColor
	end)

	dismissBtn.MouseLeave:Connect(function()
		dismissBtn.BackgroundColor3 = Library.MainColor
	end)

	---Fade in.
	local function fadeIn()
		tweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.5
		}):Play()

		outer.Size = UDim2.new(0, 360, 0, 320)

		tweenService:Create(outer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 380, 0, 340)
		}):Play()

		tweenService:Create(inner, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
		tweenService:Create(accentBar, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
		tweenService:Create(separator, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
		tweenService:Create(bodyFrame, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
		tweenService:Create(title, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		tweenService:Create(bodyText, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		tweenService:Create(dismissBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
	end

	---Fade out.
	local function fadeOut()
		tweenService:Create(overlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()

		tweenService:Create(inner, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		tweenService:Create(accentBar, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		tweenService:Create(separator, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		tweenService:Create(bodyFrame, TweenInfo.new(0.2), { BackgroundTransparency = 1, ScrollBarImageTransparency = 1 }):Play()
		tweenService:Create(title, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		tweenService:Create(bodyText, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		tweenService:Create(dismissBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

		task.wait(0.25)
		screenGui:Destroy()
	end

	-- Dismiss handler.
	dismissBtn.MouseButton1Click:Connect(fadeOut)

	-- Fetch release notes from GitHub.
	task.spawn(function()
		local success, response = pcall(function()
			return game:HttpGet("https://api.github.com/repos/Blastbrean/Lycoris-Rewrite/releases/latest")
		end)

		if success and response then
			local data = game:GetService("HttpService"):JSONDecode(response)
			if data and data.body then
				-- Strip version line and script block from release notes.
				local notes = data.body
				notes = notes:gsub("%*Your version should be[^\n]*%*", "")
				notes = notes:gsub("```lua.-```", "")
				notes = notes:gsub("```%w*\n?", "")
				notes = notes:gsub("%*%*", "")
				notes = notes:gsub("\n\n\n+", "\n\n")
				notes = notes:gsub("\n(%d+%.) ", "\n\n%1 ")
				notes = notes:match("^%s*(.-)%s*$") or notes
				bodyText.Text = notes
			else
				bodyText.Text = "v" .. version .. " has been released."
			end
		else
			bodyText.Text = "v" .. version .. " has been released."
		end
	end)

	-- Show.
	fadeIn()
end

-- Return UpdateNotifier module.
return UpdateNotifier
