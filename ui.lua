return function()
local BuilderUI = {}
BuilderUI.Version = "2.3"

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// CONFIGURATION \\--
BuilderUI.Config = {
	Animation = {
		Duration = 0.3,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
	},
	Themes = {
		Dark = {
			Background = Color3.fromRGB(34, 35, 39),
			Secondary = Color3.fromRGB(44, 45, 49),
			Tertiary = Color3.fromRGB(59, 61, 65),
			Accent = Color3.fromRGB(80, 150, 255),
			Text = Color3.fromRGB(255, 255, 255),
			MutedText = Color3.fromRGB(180, 180, 180),
			Error = Color3.fromRGB(231, 76, 60),
			Success = Color3.fromRGB(46, 204, 113),
			Warning = Color3.fromRGB(241, 196, 15),
			Font = Enum.Font.BuilderSans,
			BoldFont = Enum.Font.BuilderSansBold,
			Radius = UDim.new(0, 8),
		},
		Light = {
			Background = Color3.fromRGB(240, 240, 240),
			Secondary = Color3.fromRGB(255, 255, 255),
			Tertiary = Color3.fromRGB(225, 225, 225),
			Accent = Color3.fromRGB(0, 122, 255),
			Text = Color3.fromRGB(20, 20, 20),
			MutedText = Color3.fromRGB(100, 100, 100),
			Error = Color3.fromRGB(231, 76, 60),
			Success = Color3.fromRGB(46, 204, 113),
			Warning = Color3.fromRGB(241, 196, 15),
			Font = Enum.Font.BuilderSans,
			BoldFont = Enum.Font.BuilderSansBold,
			Radius = UDim.new(0, 8),
		}
	}
}
-- Default Theme
BuilderUI.ActiveTheme = BuilderUI.Config.Themes.Dark

--// UNIVERSAL & HELPER FUNCTIONS \\--

local tooltipGui -- Forward declare for the helper function

local function createUICorner(parent)
	local uic = Instance.new("UICorner")
	uic.CornerRadius = BuilderUI.ActiveTheme.Radius
	uic.Parent = parent
	return uic
end

local function tween(obj, props)
	local info = TweenInfo.new(
		BuilderUI.Config.Animation.Duration,
		BuilderUI.Config.Animation.EasingStyle,
		BuilderUI.Config.Animation.EasingDirection
	)
	return TweenService:Create(obj, info, props)
end

local function createTooltip(parent, text)
	if not text then return end

	local function showTooltip()
		if not tooltipGui or not tooltipGui.Parent then
			tooltipGui = Instance.new("ScreenGui", playerGui)
			tooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
			tooltipGui.DisplayOrder = 999
			local frame = Instance.new("Frame", tooltipGui)
			frame.Name = "TooltipFrame"
			frame.BackgroundColor3 = Color3.new(0,0,0)
			frame.BackgroundTransparency = 0.4
			frame.BorderSizePixel = 0
			createUICorner(frame)
			local label = Instance.new("TextLabel", frame)
			label.Name = "TooltipLabel"
			label.BackgroundTransparency = 1
			label.Font = BuilderUI.ActiveTheme.Font
			label.TextSize = 14
			label.TextColor3 = Color3.new(1,1,1)
			label.Size = UDim2.fromOffset(0,0) -- Will be auto-sized
			label.AutomaticSize = Enum.AutomaticSize.XY
			local padding = Instance.new("UIPadding", frame)
			padding.PaddingTop = UDim.new(0, 4)
			padding.PaddingBottom = UDim.new(0, 4)
			padding.PaddingLeft = UDim.new(0, 8)
			padding.PaddingRight = UDim.new(0, 8)
		end
		
		local frame = tooltipGui.TooltipFrame
		local label = frame.TooltipLabel
		label.Text = text
		frame.Visible = true
	end
	
	local function hideTooltip()
		if tooltipGui and tooltipGui:FindFirstChild("TooltipFrame") then
			tooltipGui.TooltipFrame.Visible = false
		end
	end
	
	parent.MouseEnter:Connect(showTooltip)
	parent.MouseLeave:Connect(hideTooltip)

	-- Move tooltip with mouse
	if not playerGui:FindFirstChild("TooltipMover") then
		local moverScript = Instance.new("LocalScript", playerGui)
		moverScript.Name = "TooltipMover"
		RunService.RenderStepped:Connect(function()
			if tooltipGui and tooltipGui.TooltipFrame.Visible then
				local mousePos = UserInputService:GetMouseLocation()
				tooltipGui.TooltipFrame.Position = UDim2.fromOffset(mousePos.X + 15, mousePos.Y + 15)
			end
		end)
	end
end
function BuilderUI:IntroUI(iconId, titleText, subText)
	local player = game:GetService("Players").LocalPlayer

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "IntroUI"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.Parent = player:WaitForChild("PlayerGui")

	-- Tween helper
	local function runTween(obj, props, time)
		local TweenService = game:GetService("TweenService")
		local info = TweenInfo.new(time or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(obj, info, props)
		tween:Play()
	end

	-- UICorner helper
	local function applyCorner(ui, rad)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, rad or 8)
		corner.Parent = ui
	end

	-- Overlay
	local overlay = Instance.new("Frame", screenGui)
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1

	-- Container
	local container = Instance.new("Frame", overlay)
	container.Size = UDim2.new(0, 360, 0, 240)
	container.Position = UDim2.new(0.5, -180, 1.5, 0)
	container.BackgroundColor3 = Color3.fromRGB(44, 45, 49)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	applyCorner(container, 10)

	-- Icon
	local icon = Instance.new("ImageLabel", container)
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0.5, -40, 0.5, -80)
	icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	icon.Image = "rbxassetid://" .. tostring(iconId or 7072712324)
	icon.BackgroundTransparency = 0
	applyCorner(icon, 10)

	-- Title
	local title = Instance.new("TextLabel", container)
	title.Size = UDim2.new(1, -40, 0, 28)
	title.Position = UDim2.new(0, 20, 0.5, 30)
	title.Font = Enum.Font.BuilderSansBold
	title.TextSize = 20
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Text = titleText or "Welcome to BuilderUI"

	-- Subtext
	local subtextLabel = Instance.new("TextLabel", container)
	subtextLabel.Size = UDim2.new(1, -40, 0, 22)
	subtextLabel.Position = UDim2.new(0, 20, 0.5, 70)
	subtextLabel.Font = Enum.Font.BuilderSans
	subtextLabel.TextSize = 14
	subtextLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	subtextLabel.BackgroundTransparency = 1
	subtextLabel.TextXAlignment = Enum.TextXAlignment.Center
	subtextLabel.Text = subText or "Please wait while the script loads..."

	-- Slide + Fade in
	runTween(overlay, {BackgroundTransparency = 0.7}, 0.5)
	runTween(container, {
		Position = UDim2.new(0.5, -180, 0.5, -120),
		BackgroundTransparency = 0
	}, 0.5)

	task.wait(3)

	-- Slide + Fade out
	runTween(container, {
		Position = UDim2.new(0.5, -180, 1.5, 0),
		BackgroundTransparency = 1
	}, 0.5)
	runTween(overlay, {BackgroundTransparency = 1}, 0.5)

	task.wait(0.5)
	screenGui:Destroy()
end
function BuilderUI:SetTheme(themeName)
	if BuilderUI.Config.Themes[themeName] then
		self.ActiveTheme = self.Config.Themes[themeName]
	else
		warn("BuilderUI: Theme '"..tostring(themeName).."' not found.")
	end
end

--// NOTIFICATION SYSTEM \\--

local function createNotification(type, title, text, duration, icon)
	duration = duration or 5
	local theme = BuilderUI.ActiveTheme
	local typeInfo = {
		Default = { Color = theme.Accent, Icon = icon or "🔔" },
		Success = { Color = theme.Success, Icon = icon or "✅" },
		Warning = { Color = theme.Warning, Icon = icon or "⚠️" },
		Error = { Color = theme.Error, Icon = icon or "❌" },
	}
	local info = typeInfo[type] or typeInfo.Default

	local screenGui = playerGui:FindFirstChild("BuilderUI_Notifications")
	if not screenGui then
		screenGui = Instance.new("ScreenGui", playerGui)
		screenGui.Name = "BuilderUI_Notifications"
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		screenGui.IgnoreGuiInset = true
		local listLayout = Instance.new("UIListLayout", screenGui)
		listLayout.Padding = UDim.new(0, 8)
		listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	end

	local notifyFrame = Instance.new("Frame", screenGui)
	notifyFrame.Size = UDim2.new(0, 300, 0, 65)
	notifyFrame.Position = UDim2.new(1, 320, 1, -10) -- Start off-screen
	notifyFrame.BackgroundColor3 = theme.Secondary
	notifyFrame.AnchorPoint = Vector2.new(1, 1)
	createUICorner(notifyFrame)

	local colorStripe = Instance.new("Frame", notifyFrame)
	colorStripe.Size = UDim2.new(0, 5, 1, 0)
	colorStripe.BackgroundColor3 = info.Color
	colorStripe.BorderSizePixel = 0
	createUICorner(colorStripe)

	local iconContainer = Instance.new("Frame", notifyFrame)
	iconContainer.Size = UDim2.new(0, 32, 0, 32)
	iconContainer.Position = UDim2.new(0, 20, 0.5, -16)
	iconContainer.BackgroundTransparency = 1

	if type(info.Icon) == "string" and string.sub(info.Icon, 1, 13) == "rbxassetid://" then
		local iconImage = Instance.new("ImageLabel", iconContainer)
		iconImage.Size = UDim2.fromScale(1, 1)
		iconImage.BackgroundTransparency = 1
		iconImage.Image = info.Icon
		iconImage.ImageColor3 = info.Color
	else
		local iconLabel = Instance.new("TextLabel", iconContainer)
		iconLabel.Size = UDim2.fromScale(1, 1)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Font = theme.Font
		iconLabel.TextScaled = true
		iconLabel.TextColor3 = info.Color
		iconLabel.Text = info.Icon
	end

	local titleLabel = Instance.new("TextLabel", notifyFrame)
	titleLabel.Size = UDim2.new(1, -70, 0, 20)
	titleLabel.Position = UDim2.new(0, 60, 0, 10)
	titleLabel.Font = theme.BoldFont
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = theme.Text
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title

	local textLabel = Instance.new("TextLabel", notifyFrame)
	textLabel.Size = UDim2.new(1, -70, 0, 20)
	textLabel.Position = UDim2.new(0, 60, 0, 32)
	textLabel.Font = theme.Font
	textLabel.TextSize = 14
	textLabel.TextColor3 = theme.MutedText
	textLabel.BackgroundTransparency = 1
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = text

	local progressBar = Instance.new("Frame", notifyFrame)
	progressBar.Position = UDim2.new(0,0,1,0)
	progressBar.Size = UDim2.new(1, 0, 0, 3)
	progressBar.AnchorPoint = Vector2.new(0, 1)
	progressBar.BackgroundColor3 = info.Color
	progressBar.BorderSizePixel = 0

	tween(notifyFrame, { Position = UDim2.new(1, -10, 1, -10) }):Play()
	tween(progressBar, { Size = UDim2.new(0, 0, 0, 3) }, TweenInfo.new(duration, Enum.EasingStyle.Linear)):Play()

	task.delay(duration, function()
		if not notifyFrame or not notifyFrame.Parent then return end
		tween(notifyFrame, { Position = UDim2.new(1, 320, 1, -10) }):Play()
		task.wait(BuilderUI.Config.Animation.Duration)
		notifyFrame:Destroy()
	end)
end

function BuilderUI:Notify(...) createNotification("Default", ...) end
function BuilderUI:NotifySuccess(...) createNotification("Success", ...) end
function BuilderUI:NotifyWarning(...) createNotification("Warning", ...) end
function BuilderUI:NotifyError(...) createNotification("Error", ...) end

function BuilderUI:CreateWindow(titleText)
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui", playerGui)
	gui.Name = "BuilderUI_" .. titleText:gsub("%s+", "")
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 600, 0, 400)
	frame.Position = UDim2.new(0.5, -300, 0.45, -200)
	frame.BackgroundColor3 = BuilderUI.ActiveTheme.Background
	frame.BackgroundTransparency = 1
	frame.Active = true
	frame.Draggable = true
	frame.ClipsDescendants = true
	createUICorner(frame)

	local originalSize = frame.Size
	local isMinimized = false

	tween(frame, {
		Position = UDim2.new(0.5, -300, 0.5, -200),
		BackgroundTransparency = 0
	}):Play()

	-- Header
	local header = Instance.new("Frame", frame)
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundColor3 = BuilderUI.ActiveTheme.Secondary

	local title = Instance.new("TextLabel", header)
	title.Size = UDim2.new(1, -80, 1, 0)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.Text = titleText
	title.Font = BuilderUI.ActiveTheme.BoldFont
	title.TextSize = 16
	title.TextColor3 = BuilderUI.ActiveTheme.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1

	-- Close Button
	local close = Instance.new("TextButton", header)
	close.Size = UDim2.new(0, 24, 0, 24)
	close.Position = UDim2.new(1, -32, 0.5, -12)
	close.Text = "✕"
	close.Font = BuilderUI.ActiveTheme.Font
	close.TextSize = 16
	close.TextColor3 = BuilderUI.ActiveTheme.MutedText
	close.BackgroundTransparency = 1
	createTooltip(close, "Close")
	close.MouseButton1Click:Connect(function()
		tween(frame, {Position = UDim2.new(0.5, -300, 0.45, -200), BackgroundTransparency = 1}):Play()
		task.wait(BuilderUI.Config.Animation.Duration)
		gui:Destroy()
	end)
	close.MouseEnter:Connect(function() tween(close, {TextColor3 = BuilderUI.ActiveTheme.Error}):Play() end)
	close.MouseLeave:Connect(function() tween(close, {TextColor3 = BuilderUI.ActiveTheme.MutedText}):Play() end)

	-- Minimize Button
	local minimize = Instance.new("TextButton", header)
	minimize.Size = UDim2.new(0, 24, 0, 24)
	minimize.Position = UDim2.new(1, -56, 0.5, -12)
	minimize.Text = "—"
	minimize.Font = BuilderUI.ActiveTheme.Font
	minimize.TextSize = 16
	minimize.TextColor3 = BuilderUI.ActiveTheme.MutedText
	minimize.BackgroundTransparency = 1
	createTooltip(minimize, "Minimize")
	minimize.MouseEnter:Connect(function() tween(minimize, {TextColor3 = BuilderUI.ActiveTheme.Text}):Play() end)
	minimize.MouseLeave:Connect(function() tween(minimize, {TextColor3 = BuilderUI.ActiveTheme.MutedText}):Play() end)

	-- Sidebar
	local sidebar = Instance.new("Frame", frame)
	sidebar.Size = UDim2.new(0, 150, 1, -36)
	sidebar.Position = UDim2.new(0, 0, 0, 36)
	sidebar.BackgroundColor3 = BuilderUI.ActiveTheme.Background

	local sidebarLayout = Instance.new("UIListLayout", sidebar)
	sidebarLayout.Padding = UDim.new(0, 5)
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

	-- Tab Content Holder
	local tabContentHolder = Instance.new("Frame", frame)
	tabContentHolder.Size = UDim2.new(1, -165, 1, -46)
	tabContentHolder.Position = UDim2.new(0, 155, 0, 41)
	tabContentHolder.BackgroundTransparency = 1

	minimize.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		sidebar.Visible = not isMinimized
		tabContentHolder.Visible = not isMinimized
		if isMinimized then
			tween(frame, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 36)}):Play()
		else
			tween(frame, {Size = originalSize}):Play()
		end
	end)

	-- API
	local tabs = {}
	local tabButtons = {}
	local api = {}
	local currentActiveTab = nil

	local function setActiveTab(tabName)
		if currentActiveTab == tabName then return end
		for name, tabData in pairs(tabs) do
			local isVisible = (name == tabName)
			tabData.Content.Visible = isVisible
			if tabButtons[name] then
				tween(tabButtons[name], {
					BackgroundColor3 = isVisible and BuilderUI.ActiveTheme.Accent or BuilderUI.ActiveTheme.Tertiary,
				}):Play()
				if tabButtons[name]:IsA("TextButton") then
					tween(tabButtons[name], {
						TextColor3 = isVisible and BuilderUI.ActiveTheme.Text or BuilderUI.ActiveTheme.MutedText
					}):Play()
				end
			end
		end
		currentActiveTab = tabName
	end

	function api:CreateTab(name, icon)
		local tab = {}
		local tabButton = Instance.new("TextButton", sidebar)
		tabButton.Size = UDim2.new(1, -10, 0, 34)
		tabButton.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
		createUICorner(tabButton)

		local iconOffset = 0
		if icon then
			iconOffset = 22
			local iconContainer = Instance.new("Frame", tabButton)
			iconContainer.Size = UDim2.new(0, 16, 0, 16)
			iconContainer.Position = UDim2.new(0, 12, 0.5, -8)
			iconContainer.BackgroundTransparency = 1

			if type(icon) == "string" and string.sub(icon, 1, 13) == "rbxassetid://" then
				local iconImg = Instance.new("ImageLabel", iconContainer)
				iconImg.Size = UDim2.fromScale(1,1)
				iconImg.Image = icon
				iconImg.BackgroundTransparency = 1
			else
				local iconLabel = Instance.new("TextLabel", iconContainer)
				iconLabel.Size = UDim2.fromScale(1,1)
				iconLabel.BackgroundTransparency = 1
				iconLabel.Font = BuilderUI.ActiveTheme.Font
				iconLabel.TextScaled = true
				iconLabel.TextColor3 = BuilderUI.ActiveTheme.MutedText
				iconLabel.Text = icon
			end
		end

		tabButton.Text = name
		tabButton.Font = BuilderUI.ActiveTheme.Font
		tabButton.TextSize = 16
		tabButton.TextColor3 = BuilderUI.ActiveTheme.MutedText
		tabButton.TextXAlignment = Enum.TextXAlignment.Left

		local padding = Instance.new("UIPadding", tabButton)
		padding.PaddingLeft = UDim.new(0, 12 + iconOffset)

		local tabContent = Instance.new("ScrollingFrame", tabContentHolder)
		tabContent.Name = name .. "_Content"
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false
		tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabContent.CanvasSize = UDim2.new()
		tabContent.ScrollBarImageColor3 = BuilderUI.ActiveTheme.Accent
		tabContent.ScrollBarThickness = 4
		tabContent.ClipsDescendants = true

		local layout = Instance.new("UIListLayout", tabContent)
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		Instance.new("UIPadding", tabContent).PaddingRight = UDim.new(0, 6)

		tabs[name] = { Content = tabContent }
		tabButtons[name] = tabButton

		tabButton.MouseButton1Click:Connect(function()
			setActiveTab(name)
		end)

		if not currentActiveTab then
			setActiveTab(name)
		end
		
		-- Component Functions --
		function tab:AddSection(title)
			local container = Instance.new("Frame", tabContent)
			container.Size = UDim2.new(1, 0, 0, 24)
			container.BackgroundTransparency = 1
			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(1, 0, 1, 0)
			label.Text = title
			label.Font = BuilderUI.ActiveTheme.BoldFont
			label.TextSize = 18
			label.TextColor3 = BuilderUI.ActiveTheme.Text
			label.BackgroundTransparency = 1
			label.TextXAlignment = Enum.TextXAlignment.Left
		end
		
		function tab:AddButton(text, callback, tooltipText)
	local btn = Instance.new("TextButton", tabContent)
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.Text = text or "Button"
	btn.Font = BuilderUI.ActiveTheme.Font
	btn.TextSize = 16
	btn.TextColor3 = BuilderUI.ActiveTheme.Text
	btn.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
	btn.AutoButtonColor = false

	createUICorner(btn)
	if tooltipText then
		createTooltip(btn, tooltipText)
	end

	local originalColor = btn.BackgroundColor3

	btn.MouseEnter:Connect(function()
		tween(btn, { BackgroundColor3 = Color3.Lerp(originalColor, Color3.new(1, 1, 1), 0.1) }):Play()
	end)

	btn.MouseLeave:Connect(function()
		tween(btn, { BackgroundColor3 = originalColor }):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		tween(btn, { BackgroundColor3 = BuilderUI.ActiveTheme.Accent }):Play()
		task.wait(0.1)
		tween(btn, { BackgroundColor3 = originalColor }):Play()

		if typeof(callback) == "function" then
			task.spawn(function()
				pcall(callback)
			end)
		else
			warn("[AddButton] Callback is not a function:", typeof(callback))
		end
	end)

	return btn
end
		function tab:AddToggle(text, callback, default, tooltipText)
			local toggled = default or false
			local container = Instance.new("Frame", tabContent)
			container.Size = UDim2.new(1, 0, 0, 32)
			container.BackgroundTransparency = 1
			createTooltip(container, tooltipText)
			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(1, -65, 1, 0)
			label.Font = BuilderUI.ActiveTheme.Font
			label.TextSize = 16
			label.TextColor3 = BuilderUI.ActiveTheme.Text
			label.Text = text
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1
			local toggleButton = Instance.new("TextButton", container)
			toggleButton.Size = UDim2.new(0, 50, 0, 24)
			toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
			toggleButton.Text = ""
			createUICorner(toggleButton, UDim.new(0, 12))
			local knob = Instance.new("Frame", toggleButton)
			knob.Size = UDim2.new(0, 18, 0, 18)
			knob.BackgroundColor3 = Color3.new(1, 1, 1)
			knob.BorderSizePixel = 0
			createUICorner(knob, UDim.new(0, 9))
			local function updateToggleState(isToggled, instant)
				local duration = instant and 0 or nil
				local bgColor = isToggled and BuilderUI.ActiveTheme.Accent or BuilderUI.ActiveTheme.Tertiary
				local knobPos = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
				local t1 = tween(toggleButton, { BackgroundColor3 = bgColor }, duration)
				local t2 = tween(knob, { Position = knobPos }, duration)
				t1:Play()
				t2:Play()
			end
			updateToggleState(toggled, true)
			toggleButton.MouseButton1Click:Connect(function()
				toggled = not toggled
				updateToggleState(toggled)
				if callback then spawn(function() pcall(callback, toggled) end) end
			end)
		end
		
		function tab:AddSlider(text, min, max, start, callback, tooltipText)
			local container = Instance.new("Frame", tabContent)
			container.Size = UDim2.new(1, 0, 0, 48)
			container.BackgroundTransparency = 1
			createTooltip(container, tooltipText)
			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(0.7, 0, 0, 20)
			label.Font = BuilderUI.ActiveTheme.Font
			label.TextSize = 16
			label.TextColor3 = BuilderUI.ActiveTheme.Text
			label.Text = text
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1
			local valueLabel = Instance.new("TextLabel", container)
			valueLabel.Size = UDim2.new(0.3, -5, 0, 20)
			valueLabel.Position = UDim2.new(0.7, 5, 0, 0)
			valueLabel.Font = BuilderUI.ActiveTheme.Font
			valueLabel.TextSize = 14
			valueLabel.TextColor3 = BuilderUI.ActiveTheme.MutedText
			valueLabel.Text = tostring(start)
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.BackgroundTransparency = 1
			local sliderBar = Instance.new("Frame", container)
			sliderBar.Size = UDim2.new(1, 0, 0, 8)
			sliderBar.Position = UDim2.new(0, 0, 0, 28)
			sliderBar.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
			createUICorner(sliderBar, UDim.new(0, 4))
			local fillBar = Instance.new("Frame", sliderBar)
			fillBar.BackgroundColor3 = BuilderUI.ActiveTheme.Accent
			createUICorner(fillBar, UDim.new(0, 4))
			local thumb = Instance.new("Frame", sliderBar)
			thumb.Size = UDim2.new(0, 16, 0, 16)
			thumb.Position = UDim2.new(0, -8, 0.5, -8)
			thumb.BackgroundColor3 = BuilderUI.ActiveTheme.Text
			createUICorner(thumb, UDim.new(0, 8))
			thumb.Active = true
			local function updateSlider(value, fromInput)
				local percentage = (value - min) / (max - min)
				percentage = math.clamp(percentage, 0, 1)
				fillBar.Size = UDim2.new(percentage, 0, 1, 0)
				thumb.Position = UDim2.new(percentage, -8, 0.5, -8)
				valueLabel.Text = string.format("%.2f", value)
				if fromInput and callback then spawn(function() pcall(callback, value) end) end
			end
			updateSlider(start)
			thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local moveConn, releaseConn
					moveConn = UserInputService.InputChanged:Connect(function(inputChanged)
						if inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch then
							local mousePos = UserInputService:GetMouseLocation()
							local relativePos = mousePos.X - sliderBar.AbsolutePosition.X
							local percentage = math.clamp(relativePos / sliderBar.AbsoluteSize.X, 0, 1)
							local value = min + (max - min) * percentage
							updateSlider(value, true)
						end
					end)
					releaseConn = UserInputService.InputEnded:Connect(function(inputEnded)
						if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
							moveConn:Disconnect()
							releaseConn:Disconnect()
						end
					end)
				end
			end)
		end
		
		function tab:AddDropdown(text, options, callback, defaultIndex, tooltipText)
    -- Create the container for the dropdown
    local container = Instance.new("Frame", tabContent)
    container.BackgroundTransparency = 1
    container.ZIndex = 2
    createTooltip(container, tooltipText)

    -- Create the dropdown button
    local dropdownButton = Instance.new("TextButton", container)
    dropdownButton.Size = UDim2.new(1, 0, 0, 36)
    dropdownButton.Text = ""
    dropdownButton.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
    createUICorner(dropdownButton)

    -- Create the label for the dropdown
    local label = Instance.new("TextLabel", dropdownButton)
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Font = BuilderUI.ActiveTheme.Font
    label.TextSize = 16
    label.TextColor3 = BuilderUI.ActiveTheme.Text
    label.Text = text .. ": " .. (options[defaultIndex] or options[1] or "")
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    -- Create the arrow icon
    local arrow = Instance.new("TextLabel", dropdownButton)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.Font = BuilderUI.ActiveTheme.BoldFont
    arrow.TextSize = 16
    arrow.TextColor3 = BuilderUI.ActiveTheme.Text
    arrow.Text = "▼"
    arrow.BackgroundTransparency = 1

    -- Create the options frame (this will hold the options that can be selected)
    local optionsFrame = Instance.new("ScrollingFrame", container)
    optionsFrame.Position = UDim2.new(0, 0, 0, 36 + 4) -- Positioning below the button with a 4px gap
    optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Initially closed
    optionsFrame.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
    optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsFrame.CanvasSize = UDim2.new()
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ClipsDescendants = true
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 3
    createUICorner(optionsFrame)

    -- Correctly create the padding for the options frame
    local listLayout = Instance.new("UIListLayout", optionsFrame)
    listLayout.Padding = UDim.new(0, 2)

    -- Correct the UIPadding to set padding properly
    local listPadding = Instance.new("UIPadding", optionsFrame)
    listPadding.PaddingTop = UDim.new(0, 4)  -- Set padding for the top
    listPadding.PaddingLeft = UDim.new(0, 4) -- Optionally set padding for the left
    listPadding.PaddingRight = UDim.new(0, 4) -- Optionally set padding for the right
    listPadding.PaddingBottom = UDim.new(0, 4) -- Optionally set padding for the bottom

    -- Variable to track if the dropdown is open
    local dropdownOpen = false

    -- Set the initial size of the container
    container.Size = UDim2.new(1, 0, 0, 36)

    -- Create the buttons for each option in the dropdown
    for _, optionText in ipairs(options) do
        local optionButton = Instance.new("TextButton", optionsFrame)
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Text = optionText
        optionButton.Font = BuilderUI.ActiveTheme.Font
        optionButton.TextSize = 14
        optionButton.TextColor3 = BuilderUI.ActiveTheme.Text
        optionButton.BackgroundTransparency = 1
        optionButton.ZIndex = 4
        createUICorner(optionButton)

        -- Add hover effects to the option buttons
        optionButton.MouseEnter:Connect(function()
            tween(optionButton, {BackgroundColor3 = BuilderUI.ActiveTheme.Accent, BackgroundTransparency = 0}):Play()
        end)

        optionButton.MouseLeave:Connect(function()
            tween(optionButton, {BackgroundTransparency = 1}):Play()
        end)

        -- Handle the option being clicked
        optionButton.MouseButton1Click:Connect(function()
            dropdownOpen = false
            arrow.Text = "▼"
            label.Text = text .. ": " .. optionText
            tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(BuilderUI.Config.Animation.Duration / 2)
            optionsFrame.Visible = false
            container.Size = UDim2.new(1, 0, 0, 36)

            if callback then
                spawn(function()
                    pcall(callback, optionText)
                end)
            end
        end)
    end

    -- Toggle the dropdown when the button is clicked
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        arrow.Text = dropdownOpen and "▲" or "▼"

        if dropdownOpen then
            local desiredHeight = math.min(#options * 32 + 8, 140)
            container.Size = UDim2.new(1, 0, 0, 36 + desiredHeight + 5)
            optionsFrame.Visible = true
            tween(optionsFrame, {Size = UDim2.new(1, 0, 0, desiredHeight)}):Play()
        else
            tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(BuilderUI.Config.Animation.Duration)
            optionsFrame.Visible = false
            container.Size = UDim2.new(1, 0, 0, 36)
        end
    end)
end
function tab:AddInfoCard(title, value, icon, color)
	local card = Instance.new("Frame", tabContent)
	card.Size = UDim2.new(1, 0, 0, 48)
	card.BackgroundColor3 = color or Color3.fromRGB(60, 62, 65)
	createUICorner(card, 8)

	local iconLabel = Instance.new("TextLabel", card)
	iconLabel.Size = UDim2.new(0, 32, 1, 0)
	iconLabel.Position = UDim2.new(0, 10, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = Enum.Font.BuilderSansBold
	iconLabel.TextSize = 20
	iconLabel.Text = icon or "ℹ️"
	iconLabel.TextColor3 = Color3.new(1, 1, 1)

	local titleLabel = Instance.new("TextLabel", card)
	titleLabel.Size = UDim2.new(0.5, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 50, 0, 0)
	titleLabel.Font = Enum.Font.BuilderSans
	titleLabel.TextSize = 16
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1

	local valueLabel = Instance.new("TextLabel", card)
	valueLabel.Size = UDim2.new(0.5, -20, 1, 0)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
	valueLabel.Font = Enum.Font.BuilderSansBold
	valueLabel.TextSize = 16
	valueLabel.Text = value
	valueLabel.TextColor3 = Color3.new(1, 1, 1)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1
end
function tab:AddUserCard(username)
	local container = Instance.new("Frame", tabContent)
	container.Size = UDim2.new(1, 0, 0, 120)
	container.BackgroundColor3 = Color3.fromRGB(44, 45, 49)
	createUICorner(container, 8)

	local avatar = Instance.new("ImageLabel", container)
	avatar.Size = UDim2.new(0, 80, 0, 80)
	avatar.Position = UDim2.new(0, 15, 0.5, -40)
	avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	avatar.BackgroundTransparency = 0
	avatar.ScaleType = Enum.ScaleType.Fit
	createUICorner(avatar, 40)

	local displayNameLabel = Instance.new("TextLabel", container)
	displayNameLabel.Size = UDim2.new(1, -110, 0, 26)
	displayNameLabel.Position = UDim2.new(0, 105, 0.5, -20)
	displayNameLabel.Font = Enum.Font.BuilderSansBold
	displayNameLabel.TextSize = 18
	displayNameLabel.TextColor3 = Color3.new(1, 1, 1)
	displayNameLabel.BackgroundTransparency = 1
	displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayNameLabel.Text = "Loading..."

	local usernameLabel = Instance.new("TextLabel", container)
	usernameLabel.Size = UDim2.new(1, -110, 0, 20)
	usernameLabel.Position = UDim2.new(0, 105, 0.5, 6)
	usernameLabel.Font = Enum.Font.BuilderSans
	usernameLabel.TextSize = 14
	usernameLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.Text = ""

	-- Try getting UserId
	local success, userId = pcall(function()
		return game.Players:GetUserIdFromNameAsync(username)
	end)

	if success and userId then
		-- Set username
		usernameLabel.Text = "@" .. username

		-- Set Display Name
		local nameSuccess, displayName = pcall(function()
			local user = game.Players:GetNameFromUserIdAsync(userId)
			return user
		end)
		if nameSuccess and displayName then
			displayNameLabel.Text = displayName
		else
			displayNameLabel.Text = username
		end

		-- Set avatar thumbnail
		local thumbSuccess, thumb = pcall(function()
			return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if thumbSuccess then
			avatar.Image = thumb
		end
	else
		displayNameLabel.Text = "Unknown User"
		usernameLabel.Text = "@" .. username
	end
end
function tab:AddCredits(title, names)
	local container = Instance.new("Frame", tabContent)
	container.Size = UDim2.new(1, 0, 0, 40 + (#names * 24))
	container.BackgroundTransparency = 1

	local header = Instance.new("TextLabel", container)
	header.Size = UDim2.new(1, 0, 0, 28)
	header.Font = Enum.Font.BuilderSansBold
	header.TextSize = 18
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.Text = title or "Credits"
	header.BackgroundTransparency = 1
	header.TextXAlignment = Enum.TextXAlignment.Left

	local listContainer = Instance.new("Frame", container)
	listContainer.Size = UDim2.new(1, 0, 0, #names * 24)
	listContainer.Position = UDim2.new(0, 0, 0, 32)
	listContainer.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout", listContainer)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)

	for _, name in ipairs(names) do
		local nameLabel = Instance.new("TextLabel", listContainer)
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Font = Enum.Font.BuilderSans
		nameLabel.TextSize = 16
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		nameLabel.Text = "- " .. name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.BackgroundTransparency = 1
	end
end
		
		function tab:AddTextbox(text, placeholder, callback, tooltipText)
			local container = Instance.new("Frame", tabContent)
			container.Size = UDim2.new(1, 0, 0, 36)
			container.BackgroundTransparency = 1
			createTooltip(container, tooltipText)
			local textbox = Instance.new("TextBox", container)
			textbox.Size = UDim2.new(1, 0, 1, 0)
			textbox.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
			textbox.Text = ""
			textbox.PlaceholderText = placeholder or "Enter text here..."
			textbox.TextColor3 = BuilderUI.ActiveTheme.Text
			textbox.PlaceholderColor3 = BuilderUI.ActiveTheme.MutedText
			textbox.Font = BuilderUI.ActiveTheme.Font
			textbox.TextSize = 16
			createUICorner(textbox)
			local pad = Instance.new("UIPadding", textbox)
			pad.PaddingLeft = UDim.new(0, 10)
			pad.PaddingRight = UDim.new(0, 10)
			textbox.FocusLost:Connect(function(enterPressed)
				if enterPressed and callback then
					spawn(function() pcall(callback, textbox.Text) end)
				end
			end)
			return textbox
		end

		function tab:AddDivider()
			local divider = Instance.new("Frame", tabContent)
			divider.Size = UDim2.new(1, 0, 0, 1)
			divider.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
			divider.BorderSizePixel = 0
		end
		
		function tab:AddKeybind(text, callback, defaultKey, tooltipText)
			local container = Instance.new("Frame", tabContent)
			container.Size = UDim2.new(1, 0, 0, 36)
			container.BackgroundTransparency = 1
			createTooltip(container, tooltipText)
			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(0.5, 0, 1, 0)
			label.Font = BuilderUI.ActiveTheme.Font
			label.TextSize = 16
			label.TextColor3 = BuilderUI.ActiveTheme.Text
			label.Text = text
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1
			local keybindButton = Instance.new("TextButton", container)
			keybindButton.Size = UDim2.new(0.5, -10, 1, 0)
			keybindButton.Position = UDim2.new(0.5, 10, 0, 0)
			keybindButton.BackgroundColor3 = BuilderUI.ActiveTheme.Tertiary
			keybindButton.Text = defaultKey and defaultKey.Name or "..."
			keybindButton.Font = BuilderUI.ActiveTheme.Font
			keybindButton.TextSize = 14
			keybindButton.TextColor3 = BuilderUI.ActiveTheme.Text
			createUICorner(keybindButton)
			keybindButton.MouseButton1Click:Connect(function()
				keybindButton.Text = "..."
				local conn
				conn = UserInputService.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						keybindButton.Text = input.KeyCode.Name
						conn:Disconnect()
						if callback then spawn(function() pcall(callback, input.KeyCode) end) end
					end
				end)
			end)
		end
		
		return tab
	end
	return api
end

return BuilderUI
end
