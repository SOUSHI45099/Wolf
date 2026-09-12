--//====================================================================--
--// Wolf UI Library V1
--//====================================================================--

local Wolf = {}
Wolf.__index = Wolf

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- ICON MODULE (Lucide + Custom Icons)
---------------------------------------------------------------------

local LucideModule

pcall(function()
	LucideModule = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
	)()
end)

local function IsValidCustomIcon(Icon: string)
	return typeof(Icon) == "string"
		and (
			Icon:match("^rbxasset://textures/")
			or Icon:match("^rbxassetid://")
			or Icon:match("^rbxthumb://type=")
			or Icon:match("roblox%.com/asset/%?id=")
		)
end

local function GetLucideIcon(iconName: string)
	if tonumber(iconName) then
		iconName = "rbxassetid://" .. iconName
	end

	if IsValidCustomIcon(iconName) then
		return iconName
	end

	if LucideModule then
		local Success, Asset = pcall(function()
			return LucideModule.GetAsset(iconName)
		end)

		if Success and Asset then
			return Asset.Url
		end
	end

	return "rbxassetid://10709782497"
end

---------------------------------------------------------------------
-- FONTS
---------------------------------------------------------------------

Wolf.Fonts = {

	Logo = Font.fromName("Bangers", Enum.FontWeight.Bold),

	Title = Font.fromName("BuilderSans", Enum.FontWeight.SemiBold),

	Body = Font.fromName("Code", Enum.FontWeight.Medium),

	Small = Font.fromName("Code", Enum.FontWeight.Regular),

	Button = Font.fromName("Code", Enum.FontWeight.Bold),
}

---------------------------------------------------------------------
-- DEFAULT THEME
---------------------------------------------------------------------

Wolf.Theme = {

	Background = Color3.fromRGB(15, 15, 17),
	Sidebar = Color3.fromRGB(24, 24, 27),
	Header = Color3.fromRGB(18, 18, 20),
	Card = Color3.fromRGB(30, 30, 34),

	Surface = Color3.fromRGB(38, 38, 42),
	SurfaceHover = Color3.fromRGB(48, 48, 52),

	Accent = Color3.fromRGB(130, 6, 6),
	AccentDark = Color3.fromRGB(90, 0, 0),

	Text = Color3.fromRGB(245, 245, 245),
	SubText = Color3.fromRGB(155, 155, 160),

	Border = Color3.fromRGB(55, 55, 60),
}

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------

local FastTween = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function Tween(Object, Properties)
	TweenService:Create(Object, FastTween, Properties):Play()
end

local function Corner(Object, Radius)
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, Radius or 6)
	C.Parent = Object
end

local function Stroke(Object, Color)
	local S = Instance.new("UIStroke")
	S.Color = Color
	S.Thickness = 1
	S.Transparency = 0.5
	S.Parent = Object

	return S
end

local function Padding(Object, L, R, T, B)
	local P = Instance.new("UIPadding")

	P.PaddingLeft = UDim.new(0, L or 0)
	P.PaddingRight = UDim.new(0, R or 0)
	P.PaddingTop = UDim.new(0, T or 0)
	P.PaddingBottom = UDim.new(0, B or 0)

	P.Parent = Object
end

---------------------------------------------------------------------
-- CREATE WINDOW
---------------------------------------------------------------------

function Wolf:CreateWindow(Config)
	Config = Config or {}

	if CoreGui:FindFirstChild("WolfUI") then
		CoreGui.WolfUI:Destroy()
	end

	---------------------------------------------------------
	-- ScreenGui
	---------------------------------------------------------

	local WolfUI = Instance.new("ScreenGui")
	WolfUI.Name = "WolfUI"
	WolfUI.ResetOnSpawn = false
	WolfUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	WolfUI.Parent = CoreGui

	---------------------------------------------------------
	-- Main Window
	---------------------------------------------------------

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	MainFrame.Size = UDim2.fromOffset(700, 440)

	MainFrame.BackgroundColor3 = self.Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = WolfUI

	Corner(MainFrame, 8)
	Stroke(MainFrame, self.Theme.Border)

	---------------------------------------------------------
	-- Accent Line
	---------------------------------------------------------

	local Accent = Instance.new("Frame")
	Accent.Size = UDim2.new(1, 0, 0, 2)
	Accent.BorderSizePixel = 0
	Accent.BackgroundColor3 = self.Theme.Accent
	Accent.Parent = MainFrame

	---------------------------------------------------------
	-- Header
	---------------------------------------------------------

	local HeaderFrame = Instance.new("Frame")
	HeaderFrame.Name = "HeaderFrame"
	HeaderFrame.Size = UDim2.new(1, 0, 0, 52)
	HeaderFrame.BackgroundColor3 = self.Theme.Header
	HeaderFrame.BorderSizePixel = 0
	HeaderFrame.Parent = MainFrame

	---------------------------------------------------------
	-- Wolf Logo
	---------------------------------------------------------

	local HeaderTitle = Instance.new("TextLabel")
	HeaderTitle.BackgroundTransparency = 1
	HeaderTitle.Position = UDim2.fromOffset(190, 0)
	HeaderTitle.Size = UDim2.fromOffset(180, 52)

	HeaderTitle.FontFace = self.Fonts.Logo
	HeaderTitle.Text = Config.Title or "Wolf"
	HeaderTitle.TextSize = 28
	HeaderTitle.TextColor3 = self.Theme.Accent
	HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

	HeaderTitle.Parent = HeaderFrame

	---------------------------------------------------------
	-- Search Box
	---------------------------------------------------------

	local SearchBox = Instance.new("TextBox")
	SearchBox.Name = "SearchBox"

	SearchBox.Position = UDim2.fromOffset(445, 8)
	SearchBox.Size = UDim2.fromOffset(120, 34)

	SearchBox.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
	SearchBox.TextColor3 = Color3.fromRGB(20, 20, 20)

	SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	SearchBox.PlaceholderText = "Search..."

	SearchBox.FontFace = self.Fonts.Body
	SearchBox.TextSize = 12
	SearchBox.ClearTextOnFocus = false

	SearchBox.Parent = HeaderFrame

	Corner(SearchBox, 6)

	---------------------------------------------------------
	-- Lock Button
	---------------------------------------------------------

	local LockButton = Instance.new("TextButton")
	LockButton.Name = "LockButton"

	LockButton.Position = UDim2.fromOffset(575, 12)
	LockButton.Size = UDim2.fromOffset(62, 28)

	LockButton.BackgroundColor3 = self.Theme.AccentDark
	LockButton.TextColor3 = Color3.new(1, 1, 1)

	LockButton.FontFace = self.Fonts.Button
	LockButton.TextSize = 12
	LockButton.Text = "LOCK"

	LockButton.Parent = HeaderFrame

	Corner(LockButton, 6)

	---------------------------------------------------------
	-- Move Icon
	---------------------------------------------------------

	local DragIcon = Instance.new("ImageButton")
	DragIcon.BackgroundTransparency = 1

	DragIcon.Position = UDim2.fromOffset(650, 4)
	DragIcon.Size = UDim2.fromOffset(40, 40)

	DragIcon.Image = GetLucideIcon("move")
	DragIcon.ImageColor3 = self.Theme.Accent

	DragIcon.Parent = HeaderFrame

	---------------------------------------------------------
	-- Sidebar
	---------------------------------------------------------

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"

	Sidebar.Size = UDim2.new(0, 180, 1, -24)
	Sidebar.BackgroundColor3 = self.Theme.Sidebar
	Sidebar.BorderSizePixel = 0

	Sidebar.Parent = MainFrame

	local Divider = Instance.new("Frame")
	Divider.Size = UDim2.new(0, 1, 1, 0)
	Divider.Position = UDim2.new(1, -1, 0, 0)
	Divider.BorderSizePixel = 0
	Divider.BackgroundColor3 = self.Theme.Border
	Divider.Parent = Sidebar

	---------------------------------------------------------
	-- Profile Card
	---------------------------------------------------------

	local ProfileCard = Instance.new("Frame")
	ProfileCard.Size = UDim2.new(1, 0, 0, 110)
	ProfileCard.BackgroundColor3 = self.Theme.Card
	ProfileCard.BorderSizePixel = 0
	ProfileCard.Parent = Sidebar

	local Avatar = Instance.new("ImageLabel")
	Avatar.Position = UDim2.fromOffset(12, 18)
	Avatar.Size = UDim2.fromOffset(50, 50)
	Avatar.BackgroundTransparency = 1
	Avatar.Image = GetLucideIcon("user")
	Avatar.ImageColor3 = self.Theme.Text
	Avatar.Parent = ProfileCard

	Corner(Avatar, 100)

	pcall(function()
		Avatar.Image = Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	local PlayerName = Instance.new("TextLabel")
	PlayerName.BackgroundTransparency = 1
	PlayerName.Position = UDim2.fromOffset(70, 18)
	PlayerName.Size = UDim2.fromOffset(100, 20)

	PlayerName.FontFace = self.Fonts.Body
	PlayerName.TextSize = 14
	PlayerName.TextColor3 = self.Theme.Text
	PlayerName.TextXAlignment = Enum.TextXAlignment.Left
	PlayerName.Text = LocalPlayer.DisplayName

	PlayerName.Parent = ProfileCard

	local Username = Instance.new("TextLabel")
	Username.BackgroundTransparency = 1
	Username.Position = UDim2.fromOffset(70, 38)
	Username.Size = UDim2.fromOffset(100, 15)

	Username.FontFace = self.Fonts.Small
	Username.TextSize = 10
	Username.TextColor3 = self.Theme.SubText
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Text = "@" .. LocalPlayer.Name

	Username.Parent = ProfileCard

	---------------------------------------------------------
	-- Device Row
	---------------------------------------------------------

	local DeviceIcon = Instance.new("ImageLabel")
	DeviceIcon.Position = UDim2.fromOffset(12, 82)
	DeviceIcon.Size = UDim2.fromOffset(16, 16)
	DeviceIcon.BackgroundTransparency = 1

	local Device = "monitor"

	if UserInputService.TouchEnabled then
		Device = "smartphone"
	end

	DeviceIcon.Image = GetLucideIcon(Device)
	DeviceIcon.ImageColor3 = self.Theme.Accent
	DeviceIcon.Parent = ProfileCard

	local DeviceLabel = Instance.new("TextLabel")
	DeviceLabel.BackgroundTransparency = 1
	DeviceLabel.Position = UDim2.fromOffset(34, 80)
	DeviceLabel.Size = UDim2.fromOffset(130, 18)

	DeviceLabel.FontFace = self.Fonts.Small
	DeviceLabel.TextSize = 11
	DeviceLabel.TextColor3 = self.Theme.SubText
	DeviceLabel.TextXAlignment = Enum.TextXAlignment.Left
	DeviceLabel.Text = UserInputService.TouchEnabled and "MOBILE" or "PC"

	DeviceLabel.Parent = ProfileCard

	---------------------------------------------------------
	-- Tab Holder
	---------------------------------------------------------

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"

	TabContainer.Position = UDim2.fromOffset(0, 118)
	TabContainer.Size = UDim2.new(1, 0, 1, -118)

	TabContainer.BackgroundTransparency = 1
	TabContainer.BorderSizePixel = 0

	TabContainer.ScrollBarThickness = 2
	TabContainer.ScrollBarImageColor3 = self.Theme.Accent
	TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabContainer.CanvasSize = UDim2.new()

	TabContainer.Parent = Sidebar

	Padding(TabContainer, 6, 6, 4, 6)

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.Padding = UDim.new(0, 5)
	TabLayout.Parent = TabContainer

	---------------------------------------------------------
	-- Content Area
	---------------------------------------------------------

	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"

	ContentArea.Position = UDim2.fromOffset(180, 52)
	ContentArea.Size = UDim2.new(1, -180, 1, -76)

	ContentArea.BackgroundTransparency = 1
	ContentArea.ClipsDescendants = true

	ContentArea.Parent = MainFrame

    Window.Flags = {}

    local Window = {}

    Window.Gui = WolfUI
    Window.MainFrame = MainFrame
    Window.ContentArea = ContentArea
    Window.TabContainer = TabContainer
    Window.SearchBox = SearchBox

    Window.Flags = {}
    Window.Pages = {}
    Window.Tabs = {}
    Window.Connections = {}
    Window.Minimized = false

    function Window:SetFlag(Name, Value)
        self.Flags[Name] = Value
    end

    function Window:GetFlag(Name)
        return self.Flags[Name]
    end

	---------------------------------------------------------
	-- Footer
	---------------------------------------------------------

	local Footnote = Instance.new("Frame")
	Footnote.Size = UDim2.new(1, 0, 0, 24)
	Footnote.Position = UDim2.new(0, 0, 1, -24)
	Footnote.BackgroundColor3 = self.Theme.Header
	Footnote.BorderSizePixel = 0
	Footnote.Parent = MainFrame

	local FootText = Instance.new("TextLabel")
	FootText.BackgroundTransparency = 1
	FootText.Size = UDim2.new(1, -30, 1, 0)

	FootText.FontFace = self.Fonts.Small
	FootText.Text = Config.Footnote or "By Alpha"
	FootText.TextColor3 = self.Theme.SubText
	FootText.TextSize = 11

	FootText.Parent = Footnote

	local ResizeIcon = Instance.new("ImageLabel")
	ResizeIcon.AnchorPoint = Vector2.new(1, 0.5)
	ResizeIcon.Position = UDim2.new(1, -6, 0.5, 0)
	ResizeIcon.Size = UDim2.fromOffset(16, 16)

	ResizeIcon.BackgroundTransparency = 1
	ResizeIcon.Image = GetLucideIcon("move-diagonal-2")
	ResizeIcon.ImageColor3 = self.Theme.SubText

	ResizeIcon.Parent = Footnote

	---------------------------------------------------------
	-- DRAG WINDOW
	---------------------------------------------------------

	local dragging = false
	local dragStart
	local startPos

	DragIcon.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = input.Position - dragStart

			MainFrame.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
		end
	end)

	---------------------------------------------------------
	-- LOCK BUTTON
	---------------------------------------------------------

	local Locked = false

	LockButton.MouseButton1Click:Connect(function()
		Locked = not Locked

		LockButton.Text = Locked and "UNLOCK" or "LOCK"

		Tween(LockButton, {
			BackgroundColor3 = Locked and self.Theme.Surface or self.Theme.AccentDark,
		})
	end)

	---------------------------------------------------------
	-- WINDOW OBJECT
	---------------------------------------------------------

	local Window = {}

	Window.Gui = WolfUI
	Window.MainFrame = MainFrame
	Window.ContentArea = ContentArea
	Window.TabContainer = TabContainer
	Window.SearchBox = SearchBox

	---------------------------------------------------------------------
	-- TAB SYSTEM
	---------------------------------------------------------------------

	Window.Tabs = {}
	Window.Pages = {}
	Window.CurrentPage = nil

	local function DeselectAllTabs()
		for _, Data in pairs(Window.Tabs) do
			Tween(Data.Button, {
				BackgroundColor3 = Wolf.Theme.Sidebar,
			})

			Tween(Data.Icon, {
				ImageColor3 = Wolf.Theme.SubText,
			})

			Tween(Data.Text, {
				TextColor3 = Wolf.Theme.SubText,
			})

			Data.Indicator.Visible = false
		end
	end

	local function SelectTab(Name)
		DeselectAllTabs()

		local Data = Window.Tabs[Name]

		if not Data then
			return
		end

		Data.Indicator.Visible = true

		Tween(Data.Button, {
			BackgroundColor3 = Wolf.Theme.Surface,
		})

		Tween(Data.Icon, {
			ImageColor3 = Wolf.Theme.Accent,
		})

		Tween(Data.Text, {
			TextColor3 = Wolf.Theme.Text,
		})

		for _, Page in pairs(Window.Pages) do
			Page.Visible = false
		end

		Data.Page.Visible = true
		Window.CurrentPage = Data.Page
	end

	---------------------------------------------------------------------
	-- CREATE TAB
	---------------------------------------------------------------------

	function Window:AddTab(Config)
		if typeof(Config) == "string" then
			Config = {
				Title = Config,
			}
		end

		Config = Config or {}

		local Name = Config.Title or "Tab"
		local Icon = Config.Icon or "circle"

		-------------------------------------------------------
		-- Sidebar Button
		-------------------------------------------------------

		local TabButton = Instance.new("TextButton")
		TabButton.Name = Name
		TabButton.Size = UDim2.new(1, 0, 0, 38)

		TabButton.BackgroundColor3 = Wolf.Theme.Sidebar
		TabButton.BorderSizePixel = 0
		TabButton.AutoButtonColor = false
		TabButton.Text = ""

		TabButton.Parent = TabContainer

		Corner(TabButton, 6)

		-------------------------------------------------------
		-- Indicator
		-------------------------------------------------------

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 3, 0, 24)
		Indicator.Position = UDim2.fromOffset(0, 7)

		Indicator.BorderSizePixel = 0
		Indicator.BackgroundColor3 = Wolf.Theme.Accent
		Indicator.Visible = false

		Indicator.Parent = TabButton

		Corner(Indicator, 10)

		-------------------------------------------------------
		-- Icon
		-------------------------------------------------------

		local IconImage = Instance.new("ImageLabel")
		IconImage.BackgroundTransparency = 1

		IconImage.Position = UDim2.fromOffset(12, 10)
		IconImage.Size = UDim2.fromOffset(18, 18)

		IconImage.Image = GetLucideIcon(Icon)
		IconImage.ImageColor3 = Wolf.Theme.SubText

		IconImage.Parent = TabButton

		-------------------------------------------------------
		-- Text
		-------------------------------------------------------

		local TabLabel = Instance.new("TextLabel")
		TabLabel.BackgroundTransparency = 1

		TabLabel.Position = UDim2.fromOffset(38, 0)
		TabLabel.Size = UDim2.new(1, -45, 1, 0)

		TabLabel.FontFace = Wolf.Fonts.Body
		TabLabel.Text = Name
		TabLabel.TextSize = 13

		TabLabel.TextColor3 = Wolf.Theme.SubText
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		TabLabel.Parent = TabButton

		-------------------------------------------------------
		-- Hover
		-------------------------------------------------------

		TabButton.MouseEnter:Connect(function()
			if Window.CurrentPage ~= Window.Pages[Name] then
				Tween(TabButton, {
					BackgroundColor3 = Wolf.Theme.SurfaceHover,
				})

				Tween(IconImage, {
					ImageColor3 = Wolf.Theme.Accent,
				})
			end
		end)

		TabButton.MouseLeave:Connect(function()
			if Window.CurrentPage ~= Window.Pages[Name] then
				Tween(TabButton, {
					BackgroundColor3 = Wolf.Theme.Sidebar,
				})

				Tween(IconImage, {
					ImageColor3 = Wolf.Theme.SubText,
				})
			end
		end)

		-------------------------------------------------------
		-- Page
		-------------------------------------------------------

		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name .. "Page"

		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.CanvasSize = UDim2.new()
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Wolf.Theme.Accent

		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0

		Page.Visible = false
		Page.Parent = ContentArea

		Padding(Page, 12, 12, 12, 12)

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 8)
		PageLayout.Parent = Page

		-------------------------------------------------------
		-- Search Registry
		-------------------------------------------------------

		Page:SetAttribute("SearchName", Name)

		Window.Pages[Name] = Page

		Window.Tabs[Name] = {
			Button = TabButton,
			Page = Page,
			Icon = IconImage,
			Text = TabLabel,
			Indicator = Indicator,
		}

		-------------------------------------------------------
		-- Click
		-------------------------------------------------------

		TabButton.MouseButton1Click:Connect(function()
			SelectTab(Name)
		end)

		-------------------------------------------------------
		-- First Tab
		-------------------------------------------------------

		if not Window.CurrentPage then
			SelectTab(Name)
		end

		-------------------------------------------------------
		-- Tab Object
		-------------------------------------------------------

		local Tab = {}

		Tab.Page = Page
		Tab.Sections = {}

		-------------------------------------------------------
		-- SUBTAB
		-------------------------------------------------------

		function Tab:AddSubTab(Config)
			if typeof(Config) == "string" then
				Config = {
					Title = Config,
				}
			end

			Config = Config or {}

			local SubName = Config.Title or "SubTab"

			local Holder = Instance.new("Frame")
			Holder.Name = SubName
			Holder.Size = UDim2.new(1, 0, 0, 34)

			Holder.BackgroundTransparency = 1
			Holder.Parent = Page

			local Button = Instance.new("TextButton")
			Button.BackgroundTransparency = 1
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.Text = ""

			Button.Parent = Holder

			local Text = Instance.new("TextLabel")
			Text.BackgroundTransparency = 1

			Text.Position = UDim2.fromOffset(2, 0)
			Text.Size = UDim2.new(1, -2, 1, -4)

			Text.FontFace = Wolf.Fonts.Title
			Text.Text = SubName
			Text.TextSize = 16

			Text.TextColor3 = Wolf.Theme.Text
			Text.TextXAlignment = Enum.TextXAlignment.Left

			Text.Parent = Holder

			local Underline = Instance.new("Frame")
			Underline.Size = UDim2.new(0, 0, 0, 2)
			Underline.Position = UDim2.new(0, 2, 1, -2)

			Underline.BorderSizePixel = 0
			Underline.BackgroundColor3 = Wolf.Theme.Accent

			Underline.Parent = Holder

			Button.MouseEnter:Connect(function()
				Tween(Text, {
					TextColor3 = Wolf.Theme.AccentLight,
				})

				Tween(Underline, {
					Size = UDim2.new(0, 70, 0, 2),
				})
			end)

			Button.MouseLeave:Connect(function()
				Tween(Text, {
					TextColor3 = Wolf.Theme.Text,
				})

				Tween(Underline, {
					Size = UDim2.new(0, 40, 0, 2),
				})
			end)

			Underline.Size = UDim2.new(0, 40, 0, 2)

			local SubPage = {}

			SubPage.Container = Page

			---------------------------------------------------
			-- Part 2B Adds Section()
			---------------------------------------------------

			return SubPage
		end

		return Tab
	end

	---------------------------------------------------------------------
	-- SEARCH FILTER
	---------------------------------------------------------------------

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local Query = SearchBox.Text:lower()

		for _, Page in pairs(Window.Pages) do
			for _, Object in ipairs(Page:GetChildren()) do
				if Object:IsA("GuiObject") and not Object:IsA("UIListLayout") then
					local Visible = true

					if Query ~= "" then
						Visible = false

						for _, Child in ipairs(Object:GetDescendants()) do
							if Child:IsA("TextLabel") or Child:IsA("TextButton") then
								if Child.Text:lower():find(Query, 1, true) then
									Visible = true
									break
								end
							end
						end
					end

					Object.Visible = Visible
				end
			end
		end
	end)

	---------------------------------------------------------------------
	-- TAB COUNT AUTO SIZE
	---------------------------------------------------------------------

	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
	end)

	---------------------------------------------------------------------
	-- SECTION SYSTEM
	---------------------------------------------------------------------

	function SubPage:AddSection(Config)
		if typeof(Config) == "string" then
			Config = {
				Title = Config,
			}
		end

		Config = Config or {}

		local SectionTitle = Config.Title or "Section"
		local SectionIcon = Config.Icon or "folder"
		local DefaultOpen = Config.Open ~= false

		---------------------------------------------------
		-- Main Card
		---------------------------------------------------

		local SectionFrame = Instance.new("Frame")
		SectionFrame.Name = SectionTitle

		SectionFrame.Size = UDim2.new(1, 0, 0, 42)
		SectionFrame.BackgroundColor3 = Wolf.Theme.Card
		SectionFrame.BorderSizePixel = 0
		SectionFrame.Parent = Page

		Corner(SectionFrame, 8)
		Stroke(SectionFrame, Wolf.Theme.Border)

		---------------------------------------------------
		-- Accent Line
		---------------------------------------------------

		local Accent = Instance.new("Frame")
		Accent.Size = UDim2.new(0, 3, 1, 0)
		Accent.BorderSizePixel = 0
		Accent.BackgroundColor3 = Wolf.Theme.Accent
		Accent.Parent = SectionFrame

		Corner(Accent, 8)

		---------------------------------------------------
		-- Header Button
		---------------------------------------------------

		local Header = Instance.new("TextButton")
		Header.Name = "Header"

		Header.Size = UDim2.new(1, 0, 0, 42)
		Header.BackgroundTransparency = 1
		Header.Text = ""

		Header.Parent = SectionFrame

		---------------------------------------------------
		-- Icon
		---------------------------------------------------

		local Icon = Instance.new("ImageLabel")
		Icon.BackgroundTransparency = 1

		Icon.Position = UDim2.fromOffset(12, 12)
		Icon.Size = UDim2.fromOffset(18, 18)

		Icon.Image = GetLucideIcon(SectionIcon)
		Icon.ImageColor3 = Wolf.Theme.Accent

		Icon.Parent = Header

		---------------------------------------------------
		-- Title
		---------------------------------------------------

		local Title = Instance.new("TextLabel")
		Title.BackgroundTransparency = 1

		Title.Position = UDim2.fromOffset(38, 0)
		Title.Size = UDim2.new(1, -80, 1, 0)

		Title.FontFace = Wolf.Fonts.Title
		Title.Text = SectionTitle
		Title.TextSize = 14

		Title.TextColor3 = Wolf.Theme.Text
		Title.TextXAlignment = Enum.TextXAlignment.Left

		Title.Parent = Header

		---------------------------------------------------
		-- Chevron
		---------------------------------------------------

		local Chevron = Instance.new("ImageLabel")
		Chevron.BackgroundTransparency = 1

		Chevron.AnchorPoint = Vector2.new(1, 0.5)
		Chevron.Position = UDim2.new(1, -14, 0.5, 0)

		Chevron.Size = UDim2.fromOffset(18, 18)

		Chevron.Image = GetLucideIcon("chevron-down")
		Chevron.ImageColor3 = Wolf.Theme.SubText

		Chevron.Parent = Header

		---------------------------------------------------
		-- Holder
		---------------------------------------------------

		local Holder = Instance.new("Frame")
		Holder.Name = "Container"

		Holder.Position = UDim2.fromOffset(0, 42)
		Holder.Size = UDim2.new(1, 0, 0, 0)

		Holder.BackgroundTransparency = 1
		Holder.ClipsDescendants = true

		Holder.Parent = SectionFrame

		Padding(Holder, 12, 12, 8, 8)

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0, 8)
		Layout.Parent = Holder

		---------------------------------------------------
		-- Resize Function
		---------------------------------------------------

		local function Resize()
			Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 16)

			if DefaultOpen then
				SectionFrame.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 58)
			end
		end

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)

		---------------------------------------------------
		-- Collapse
		---------------------------------------------------

		local Open = DefaultOpen

		if not Open then
			Holder.Size = UDim2.new(1, 0, 0, 0)
			SectionFrame.Size = UDim2.new(1, 0, 0, 42)

			Chevron.Rotation = -90
		end

		Header.MouseEnter:Connect(function()
			Tween(SectionFrame, {
				BackgroundColor3 = Wolf.Theme.Surface,
			})

			Tween(Chevron, {
				ImageColor3 = Wolf.Theme.Accent,
			})
		end)

		Header.MouseLeave:Connect(function()
			Tween(SectionFrame, {
				BackgroundColor3 = Wolf.Theme.Card,
			})

			Tween(Chevron, {
				ImageColor3 = Wolf.Theme.SubText,
			})
		end)

		Header.MouseButton1Click:Connect(function()
			Open = not Open

			if Open then
				Tween(Chevron, {
					Rotation = 0,
				})

				Tween(Holder, {
					Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 16),
				})

				Tween(SectionFrame, {
					Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 58),
				})
			else
				Tween(Chevron, {
					Rotation = -90,
				})

				Tween(Holder, {
					Size = UDim2.new(1, 0, 0, 0),
				})

				Tween(SectionFrame, {
					Size = UDim2.new(1, 0, 0, 42),
				})
			end
		end)

		Resize()

		---------------------------------------------------
		-- SECTION OBJECT
		---------------------------------------------------

		local Section = {}

		Section.Container = Holder
		Section.Layout = Layout
		Section.Frame = SectionFrame

		---------------------------------------------------
		-- INTERNAL ITEM
		---------------------------------------------------

		local function NewItem(Height)
			local Item = Instance.new("Frame")
			Item.Size = UDim2.new(1, 0, 0, Height or 32)

			Item.BackgroundTransparency = 1
			Item.Parent = Holder

			return Item
		end

		---------------------------------------------------
		-- LABEL
		---------------------------------------------------

		function Section:AddLabel(Text)
			local Item = NewItem(20)

			local Label = Instance.new("TextLabel")
			Label.BackgroundTransparency = 1

			Label.Size = UDim2.new(1, 0, 1, 0)

			Label.FontFace = Wolf.Fonts.Body
			Label.Text = Text

			Label.TextSize = 13
			Label.TextColor3 = Wolf.Theme.Text
			Label.TextXAlignment = Enum.TextXAlignment.Left

			Label.Parent = Item

			Resize()

			return Label
		end

		---------------------------------------------------
		-- PARAGRAPH
		---------------------------------------------------

		function Section:AddParagraph(TitleText, BodyText)
			local Item = NewItem(54)

			local Title = Instance.new("TextLabel")
			Title.BackgroundTransparency = 1

			Title.Size = UDim2.new(1, 0, 0, 18)

			Title.FontFace = Wolf.Fonts.Title
			Title.Text = TitleText

			Title.TextSize = 14
			Title.TextColor3 = Wolf.Theme.Text
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Title.Parent = Item

			local Body = Instance.new("TextLabel")
			Body.BackgroundTransparency = 1

			Body.Position = UDim2.fromOffset(0, 20)
			Body.Size = UDim2.new(1, 0, 0, 32)

			Body.FontFace = Wolf.Fonts.Small
			Body.TextWrapped = true

			Body.Text = BodyText
			Body.TextSize = 12

			Body.TextColor3 = Wolf.Theme.SubText
			Body.TextXAlignment = Enum.TextXAlignment.Left
			Body.TextYAlignment = Enum.TextYAlignment.Top

			Body.Parent = Item

			Resize()

			return Item
		end

		---------------------------------------------------
		-- DIVIDER
		---------------------------------------------------

		function Section:AddDivider(Text)
			local Item = NewItem(18)

			local Line = Instance.new("Frame")
			Line.Position = UDim2.new(0, 0, 0.5, 0)

			Line.Size = UDim2.new(1, 0, 0, 1)
			Line.BorderSizePixel = 0

			Line.BackgroundColor3 = Wolf.Theme.Border
			Line.Parent = Item

			if Text then
				local Label = Instance.new("TextLabel")
				Label.BackgroundColor3 = Wolf.Theme.Card

				Label.Position = UDim2.fromOffset(8, -8)
				Label.Size = UDim2.fromOffset(#Text * 6 + 18, 16)

				Label.FontFace = Wolf.Fonts.Small
				Label.Text = Text

				Label.TextSize = 11
				Label.TextColor3 = Wolf.Theme.SubText

				Label.Parent = Item

				Corner(Label, 4)
			end

			Resize()

			return Item
		end

		---------------------------------------------------
		-- SPACER
		---------------------------------------------------

		function Section:AddSpace(Size)
			local Space = NewItem(Size or 8)
			Resize()
			return Space
		end

		return Section
	end

	---------------------------------------------------------------------
	-- BUTTON
	---------------------------------------------------------------------

	function Section:AddButton(Config)
		if typeof(Config) == "string" then
			Config = {
				Title = Config,
			}
		end

		Config = Config or {}

		local Item = NewItem(38)

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.BackgroundColor3 = Wolf.Theme.Surface
		Button.BorderSizePixel = 0
		Button.AutoButtonColor = false
		Button.Text = ""
		Button.Parent = Item

		Corner(Button, 6)
		Stroke(Button, Wolf.Theme.Border)

		local Icon = Instance.new("ImageLabel")
		Icon.BackgroundTransparency = 1
		Icon.Position = UDim2.fromOffset(12, 10)
		Icon.Size = UDim2.fromOffset(18, 18)
		Icon.Image = GetLucideIcon(Config.Icon or "mouse-pointer")
		Icon.ImageColor3 = Wolf.Theme.Accent
		Icon.Parent = Button

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Position = UDim2.fromOffset(38, 0)
		Label.Size = UDim2.new(1, -45, 1, 0)
		Label.FontFace = Wolf.Fonts.Button
		Label.Text = Config.Title or "Button"
		Label.TextSize = 13
		Label.TextColor3 = Wolf.Theme.Text
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Button

		Button.MouseEnter:Connect(function()
			Tween(Button, { BackgroundColor3 = Wolf.Theme.SurfaceHover })
		end)

		Button.MouseLeave:Connect(function()
			Tween(Button, { BackgroundColor3 = Wolf.Theme.Surface })
		end)

		Button.MouseButton1Down:Connect(function()
			Tween(Button, { BackgroundColor3 = Wolf.Theme.AccentDark })
		end)

		Button.MouseButton1Up:Connect(function()
			Tween(Button, { BackgroundColor3 = Wolf.Theme.SurfaceHover })
		end)

		Button.MouseButton1Click:Connect(function()
			if Config.Callback then
				task.spawn(Config.Callback)
			end
		end)

		Resize()

		return Button
	end

	---------------------------------------------------------------------
	-- TOGGLE
	---------------------------------------------------------------------

	function Section:AddToggle(Config)
		Config = Config or {}

		local Value = Config.Default or false

		local Item = NewItem(42)

		local Background = Instance.new("Frame")
		Background.Size = UDim2.new(1, 0, 1, 0)
		Background.BackgroundColor3 = Wolf.Theme.Surface
		Background.BorderSizePixel = 0
		Background.Parent = Item

		Corner(Background, 6)
		Stroke(Background, Wolf.Theme.Border)

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Position = UDim2.fromOffset(12, 0)
		Label.Size = UDim2.new(1, -80, 1, 0)
		Label.FontFace = Wolf.Fonts.Body
		Label.Text = Config.Title or "Toggle"
		Label.TextSize = 13
		Label.TextColor3 = Wolf.Theme.Text
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Background

		local Switch = Instance.new("Frame")
		Switch.AnchorPoint = Vector2.new(1, 0.5)
		Switch.Position = UDim2.new(1, -12, 0.5, 0)
		Switch.Size = UDim2.fromOffset(42, 22)
		Switch.BackgroundColor3 = Value and Wolf.Theme.AccentDark or Color3.fromRGB(65, 65, 70)
		Switch.BorderSizePixel = 0
		Switch.Parent = Background

		Corner(Switch, 100)

		local Knob = Instance.new("Frame")
		Knob.Size = UDim2.fromOffset(18, 18)
		Knob.Position = Value and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
		Knob.BackgroundColor3 = Color3.new(1, 1, 1)
		Knob.BorderSizePixel = 0
		Knob.Parent = Switch

		Corner(Knob, 100)

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.fromScale(1, 1)
		Button.BackgroundTransparency = 1
		Button.Text = ""
		Button.Parent = Background

		local function SetState(State)
			Value = State

			Tween(Switch, {
				BackgroundColor3 = Value and Wolf.Theme.AccentDark or Color3.fromRGB(65, 65, 70),
			})

			Tween(Knob, {
				Position = Value and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
			})

			if Config.Callback then
				task.spawn(Config.Callback, Value)
			end
		end

		Button.MouseButton1Click:Connect(function()
			SetState(not Value)
		end)

		Resize()

		return {
			SetValue = SetState,
			GetValue = function()
				return Value
			end,
		}
	end

	---------------------------------------------------------------------
	-- SLIDER
	---------------------------------------------------------------------

	function Section:AddSlider(Config)
		Config = Config or {}

		local Min = Config.Min or 0
		local Max = Config.Max or 100

		local Value = Config.Default or Min
		local Suffix = Config.Suffix or ""

		local Item = NewItem(56)

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(1, -70, 0, 20)
		Label.FontFace = Wolf.Fonts.Body
		Label.Text = Config.Title or "Slider"
		Label.TextSize = 13
		Label.TextColor3 = Wolf.Theme.Text
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Item

		local ValueLabel = Instance.new("TextLabel")
		ValueLabel.BackgroundTransparency = 1
		ValueLabel.AnchorPoint = Vector2.new(1, 0)
		ValueLabel.Position = UDim2.new(1, 0, 0, 0)
		ValueLabel.Size = UDim2.fromOffset(60, 20)
		ValueLabel.FontFace = Wolf.Fonts.Small
		ValueLabel.Text = tostring(Value) .. Suffix
		ValueLabel.TextSize = 12
		ValueLabel.TextColor3 = Wolf.Theme.Accent
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
		ValueLabel.Parent = Item

		local Bar = Instance.new("Frame")
		Bar.Position = UDim2.fromOffset(0, 30)
		Bar.Size = UDim2.new(1, 0, 0, 8)
		Bar.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		Bar.BorderSizePixel = 0
		Bar.Parent = Item

		Corner(Bar, 100)

		local Fill = Instance.new("Frame")
		Fill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
		Fill.BackgroundColor3 = Wolf.Theme.Accent
		Fill.BorderSizePixel = 0
		Fill.Parent = Bar

		Corner(Fill, 100)

		local Knob = Instance.new("Frame")
		Knob.AnchorPoint = Vector2.new(0.5, 0.5)
		Knob.Position = UDim2.new((Value - Min) / (Max - Min), 0, 0.5, 0)
		Knob.Size = UDim2.fromOffset(16, 16)
		Knob.BackgroundColor3 = Color3.new(1, 1, 1)
		Knob.BorderSizePixel = 0
		Knob.Parent = Bar

		Corner(Knob, 100)

		local Dragging = false

		local function Update(InputX)
			local Alpha = math.clamp((InputX - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

			Value = math.floor((Min + (Max - Min) * Alpha) * 100) / 100

			Fill.Size = UDim2.new(Alpha, 0, 1, 0)
			Knob.Position = UDim2.new(Alpha, 0, 0.5, 0)

			ValueLabel.Text = tostring(Value) .. Suffix

			if Config.Callback then
				task.spawn(Config.Callback, Value)
			end
		end

		Bar.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				Update(Input.Position.X)
			end
		end)

		UserInputService.InputChanged:Connect(function(Input)
			if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
				Update(Input.Position.X)
			end
		end)

		UserInputService.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = false
			end
		end)

		Resize()

		return {
			SetValue = function(_, NewValue)
				NewValue = math.clamp(NewValue, Min, Max)
				Update(Bar.AbsolutePosition.X + ((NewValue - Min) / (Max - Min)) * Bar.AbsoluteSize.X)
			end,
			GetValue = function()
				return Value
			end,
		}
	end

	---------------------------------------------------------------------
	-- TEXTBOX
	---------------------------------------------------------------------

	function Section:AddTextbox(Config)
		Config = Config or {}

		local Item = NewItem(42)

		local Background = Instance.new("Frame")
		Background.Size = UDim2.new(1, 0, 1, 0)
		Background.BackgroundColor3 = Wolf.Theme.Surface
		Background.BorderSizePixel = 0
		Background.Parent = Item

		Corner(Background, 6)
		Stroke(Background, Wolf.Theme.Border)

		local Icon = Instance.new("ImageLabel")
		Icon.BackgroundTransparency = 1
		Icon.Position = UDim2.fromOffset(10, 11)
		Icon.Size = UDim2.fromOffset(18, 18)
		Icon.Image = GetLucideIcon(Config.Icon or "text-cursor")
		Icon.ImageColor3 = Wolf.Theme.Accent
		Icon.Parent = Background

		local Box = Instance.new("TextBox")
		Box.BackgroundTransparency = 1
		Box.Position = UDim2.fromOffset(36, 0)
		Box.Size = UDim2.new(1, -44, 1, 0)

		Box.FontFace = Wolf.Fonts.Body
		Box.TextSize = 13

		Box.PlaceholderText = Config.Placeholder or "Enter text..."
		Box.PlaceholderColor3 = Wolf.Theme.SubText

		Box.Text = Config.Default or ""
		Box.TextColor3 = Wolf.Theme.Text
		Box.TextXAlignment = Enum.TextXAlignment.Left
		Box.ClearTextOnFocus = false

		Box.Parent = Background

		Box.Focused:Connect(function()
			Tween(Background, {
				BackgroundColor3 = Wolf.Theme.SurfaceHover,
			})
		end)

		Box.FocusLost:Connect(function(EnterPressed)
			Tween(Background, {
				BackgroundColor3 = Wolf.Theme.Surface,
			})

			if Config.Callback then
				task.spawn(Config.Callback, Box.Text, EnterPressed)
			end
		end)

		Resize()

		return {
			SetValue = function(_, Text)
				Box.Text = Text
			end,
			GetValue = function()
				return Box.Text
			end,
		}
	end

	---------------------------------------------------------------------
	-- DROPDOWN
	---------------------------------------------------------------------

	function Section:AddDropdown(Config)
		Config = Config or {}

		local Values = Config.Values or {}
		local Selected = Config.Default or Values[1] or "None"
		local Open = false

		local Item = NewItem(42)

		local Background = Instance.new("Frame")
		Background.Size = UDim2.new(1, 0, 1, 0)
		Background.BackgroundColor3 = Wolf.Theme.Surface
		Background.BorderSizePixel = 0
		Background.Parent = Item
		Corner(Background, 6)
		Stroke(Background, Wolf.Theme.Border)

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.fromScale(1, 1)
		Button.BackgroundTransparency = 1
		Button.Text = ""
		Button.Parent = Background

		local Icon = Instance.new("ImageLabel")
		Icon.BackgroundTransparency = 1
		Icon.Position = UDim2.fromOffset(10, 11)
		Icon.Size = UDim2.fromOffset(18, 18)
		Icon.Image = GetLucideIcon(Config.Icon or "chevron-down")
		Icon.ImageColor3 = Wolf.Theme.Accent
		Icon.Parent = Background

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Position = UDim2.fromOffset(38, 0)
		Label.Size = UDim2.new(1, -90, 1, 0)
		Label.FontFace = Wolf.Fonts.Body
		Label.Text = Config.Title or "Dropdown"
		Label.TextColor3 = Wolf.Theme.Text
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Background

		local ValueLabel = Instance.new("TextLabel")
		ValueLabel.BackgroundTransparency = 1
		ValueLabel.AnchorPoint = Vector2.new(1, 0.5)
		ValueLabel.Position = UDim2.new(1, -34, 0.5, 0)
		ValueLabel.Size = UDim2.fromOffset(120, 18)
		ValueLabel.FontFace = Wolf.Fonts.Small
		ValueLabel.Text = tostring(Selected)
		ValueLabel.TextSize = 12
		ValueLabel.TextColor3 = Wolf.Theme.Accent
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
		ValueLabel.Parent = Background

		local Chevron = Instance.new("ImageLabel")
		Chevron.BackgroundTransparency = 1
		Chevron.AnchorPoint = Vector2.new(1, 0.5)
		Chevron.Position = UDim2.new(1, -10, 0.5, 0)
		Chevron.Size = UDim2.fromOffset(16, 16)
		Chevron.Image = GetLucideIcon("chevron-down")
		Chevron.ImageColor3 = Wolf.Theme.SubText
		Chevron.Parent = Background

		local ListFrame = Instance.new("Frame")
		ListFrame.Position = UDim2.fromOffset(0, 42)
		ListFrame.Size = UDim2.new(1, 0, 0, 0)
		ListFrame.ClipsDescendants = true
		ListFrame.BackgroundColor3 = Wolf.Theme.Card
		ListFrame.BorderSizePixel = 0
		ListFrame.Parent = Background
		Corner(ListFrame, 6)
		Stroke(ListFrame, Wolf.Theme.Border)

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0, 2)
		Layout.Parent = ListFrame

		local function ToggleDropdown(State)
			Open = State

			Tween(Chevron, {
				Rotation = Open and 180 or 0,
			})

			local Height = Open and (#Values * 32 + 4) or 0

			Tween(ListFrame, {
				Size = UDim2.new(1, 0, 0, Height),
			})

			Tween(Background, {
				Size = UDim2.new(1, 0, 0, 42 + Height),
			})

			Tween(Item, {
				Size = UDim2.new(1, 0, 0, 42 + Height),
			})

			Resize()
		end

		Button.MouseButton1Click:Connect(function()
			ToggleDropdown(not Open)
		end)

		for _, Value in ipairs(Values) do
			local Option = Instance.new("TextButton")
			Option.Size = UDim2.new(1, -4, 0, 30)
			Option.Position = UDim2.fromOffset(2, 0)
			Option.BackgroundColor3 = Wolf.Theme.Surface
			Option.BorderSizePixel = 0
			Option.AutoButtonColor = false
			Option.Text = ""
			Option.Parent = ListFrame
			Corner(Option, 5)

			local Text = Instance.new("TextLabel")
			Text.BackgroundTransparency = 1
			Text.Position = UDim2.fromOffset(12, 0)
			Text.Size = UDim2.new(1, -24, 1, 0)
			Text.FontFace = Wolf.Fonts.Small
			Text.Text = tostring(Value)
			Text.TextSize = 12
			Text.TextColor3 = Wolf.Theme.Text
			Text.TextXAlignment = Enum.TextXAlignment.Left
			Text.Parent = Option

			Option.MouseEnter:Connect(function()
				Tween(Option, { BackgroundColor3 = Wolf.Theme.SurfaceHover })
			end)

			Option.MouseLeave:Connect(function()
				Tween(Option, { BackgroundColor3 = Wolf.Theme.Surface })
			end)

			Option.MouseButton1Click:Connect(function()
				Selected = Value
				ValueLabel.Text = tostring(Value)

				if Config.Callback then
					task.spawn(Config.Callback, Value)
				end

				ToggleDropdown(false)
			end)
		end

		return {
			SetValue = function(_, Value)
				Selected = Value
				ValueLabel.Text = tostring(Value)
			end,

			GetValue = function()
				return Selected
			end,
		}
	end

	---------------------------------------------------------------------
	-- MULTI DROPDOWN
	---------------------------------------------------------------------

	function Section:AddMultiDropdown(Config)
		Config = Config or {}

		local Selected = {}
		local Values = Config.Values or {}

		local Dropdown = Section:AddDropdown({
			Title = Config.Title,
			Icon = Config.Icon,
			Values = Values,
		})

		local Holder = Dropdown

		for _, Value in ipairs(Values) do
			Selected[Value] = false
		end

		function Holder:GetValue()
			local List = {}

			for Name, Enabled in pairs(Selected) do
				if Enabled then
					table.insert(List, Name)
				end
			end

			return List
		end

		return Holder
	end

	---------------------------------------------------------------------
	-- COLOR PICKER (RGB STYLE)
	---------------------------------------------------------------------

	function Section:AddColorPicker(Config)
		Config = Config or {}

		local Current = Config.Default or Color3.fromRGB(130, 6, 6)

		local Item = NewItem(120)

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(1, 0, 0, 20)
		Label.FontFace = Wolf.Fonts.Body
		Label.Text = Config.Title or "Color Picker"
		Label.TextColor3 = Wolf.Theme.Text
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Item

		local Preview = Instance.new("Frame")
		Preview.Position = UDim2.new(1, -32, 0, 0)
		Preview.Size = UDim2.fromOffset(24, 24)
		Preview.BackgroundColor3 = Current
		Preview.BorderSizePixel = 0
		Preview.Parent = Item
		Corner(Preview, 5)

		local Channels = {}

		local function CreateChannel(Name, Y, Default)
			local Text = Instance.new("TextLabel")
			Text.BackgroundTransparency = 1
			Text.Position = UDim2.fromOffset(0, Y)
			Text.Size = UDim2.fromOffset(18, 16)
			Text.FontFace = Wolf.Fonts.Small
			Text.Text = Name
			Text.TextSize = 11
			Text.TextColor3 = Wolf.Theme.SubText
			Text.Parent = Item

			local Box = Instance.new("TextBox")
			Box.Position = UDim2.fromOffset(22, Y - 2)
			Box.Size = UDim2.fromOffset(42, 20)
			Box.BackgroundColor3 = Wolf.Theme.Surface
			Box.TextColor3 = Wolf.Theme.Text
			Box.Text = tostring(Default)
			Box.ClearTextOnFocus = false
			Box.FontFace = Wolf.Fonts.Small
			Box.TextSize = 11
			Box.Parent = Item
			Corner(Box, 4)

			Channels[Name] = Box
		end

		CreateChannel("R", 34, math.floor(Current.R * 255))
		CreateChannel("G", 62, math.floor(Current.G * 255))
		CreateChannel("B", 90, math.floor(Current.B * 255))

		local function Update()
			local R = math.clamp(tonumber(Channels.R.Text) or 0, 0, 255)
			local G = math.clamp(tonumber(Channels.G.Text) or 0, 0, 255)
			local B = math.clamp(tonumber(Channels.B.Text) or 0, 0, 255)

			Current = Color3.fromRGB(R, G, B)

			Preview.BackgroundColor3 = Current

			if Config.Callback then
				task.spawn(Config.Callback, Current)
			end
		end

		for _, Box in pairs(Channels) do
			Box.FocusLost:Connect(Update)
		end

		return {
			GetValue = function()
				return Current
			end,

			SetValue = function(_, Color)
				Current = Color
				Preview.BackgroundColor3 = Color
			end,
		}
	end

	---------------------------------------------------------------------
	-- KEYBIND
	---------------------------------------------------------------------

	function Section:AddKeybind(Config)
		Config = Config or {}

		local CurrentKey = Config.Default or Enum.KeyCode.RightShift
		local Waiting = false

		local Item = NewItem(38)

		local Background = Instance.new("Frame")
		Background.Size = UDim2.fromScale(1, 1)
		Background.BackgroundColor3 = Wolf.Theme.Surface
		Background.BorderSizePixel = 0
		Background.Parent = Item
		Corner(Background, 6)
		Stroke(Background, Wolf.Theme.Border)

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Position = UDim2.fromOffset(12, 0)
		Label.Size = UDim2.new(0.6, 0, 1, 0)
		Label.FontFace = Wolf.Fonts.Body
		Label.Text = Config.Title or "Keybind"
		Label.TextColor3 = Wolf.Theme.Text
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Background

		local KeyButton = Instance.new("TextButton")
		KeyButton.AnchorPoint = Vector2.new(1, 0.5)
		KeyButton.Position = UDim2.new(1, -10, 0.5, 0)
		KeyButton.Size = UDim2.fromOffset(70, 24)
		KeyButton.BackgroundColor3 = Wolf.Theme.Card
		KeyButton.Text = CurrentKey.Name
		KeyButton.FontFace = Wolf.Fonts.Small
		KeyButton.TextSize = 11
		KeyButton.TextColor3 = Wolf.Theme.Accent
		KeyButton.Parent = Background
		Corner(KeyButton, 5)

		KeyButton.MouseButton1Click:Connect(function()
			Waiting = true
			KeyButton.Text = "..."
		end)

		UserInputService.InputBegan:Connect(function(Input, Typing)
			if Typing then
				return
			end

			if Waiting then
				Waiting = false
				CurrentKey = Input.KeyCode

				KeyButton.Text = CurrentKey.Name

				if Config.Changed then
					task.spawn(Config.Changed, CurrentKey)
				end

				return
			end

			if Input.KeyCode == CurrentKey then
				if Config.Callback then
					task.spawn(Config.Callback)
				end
			end
		end)

		return {
			SetKey = function(_, Key)
				CurrentKey = Key
				KeyButton.Text = Key.Name
			end,

			GetKey = function()
				return CurrentKey
			end,
		}
	end

	---------------------------------------------------------------------
	-- NOTIFICATION (WINDOW METHOD)
	---------------------------------------------------------------------

	Window.NotificationHolder = Instance.new("Frame")
	Window.NotificationHolder.AnchorPoint = Vector2.new(1, 1)
	Window.NotificationHolder.Position = UDim2.new(1, -16, 1, -16)
	Window.NotificationHolder.Size = UDim2.fromOffset(260, 260)
	Window.NotificationHolder.BackgroundTransparency = 1
	Window.NotificationHolder.Parent = WolfUI

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 8)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	Layout.Parent = Window.NotificationHolder

	function Window:Notify(Config)
		Config = Config or {}

		local Toast = Instance.new("Frame")
		Toast.Size = UDim2.fromOffset(250, 70)
		Toast.BackgroundColor3 = Wolf.Theme.Card
		Toast.BorderSizePixel = 0
		Toast.Parent = Window.NotificationHolder
		Corner(Toast, 8)
		Stroke(Toast, Wolf.Theme.Border)

		local Accent = Instance.new("Frame")
		Accent.Size = UDim2.new(0, 3, 1, 0)
		Accent.BackgroundColor3 = Config.Color or Wolf.Theme.Accent
		Accent.BorderSizePixel = 0
		Accent.Parent = Toast
		Corner(Accent, 8)

		local Title = Instance.new("TextLabel")
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.fromOffset(12, 8)
		Title.Size = UDim2.new(1, -20, 0, 18)
		Title.FontFace = Wolf.Fonts.Body
		Title.Text = Config.Title or "Wolf"
		Title.TextColor3 = Wolf.Theme.Text
		Title.TextSize = 13
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Toast

		local Content = Instance.new("TextLabel")
		Content.BackgroundTransparency = 1
		Content.Position = UDim2.fromOffset(12, 28)
		Content.Size = UDim2.new(1, -20, 0, 30)
		Content.FontFace = Wolf.Fonts.Small
		Content.TextWrapped = true
		Content.Text = Config.Content or ""
		Content.TextColor3 = Wolf.Theme.SubText
		Content.TextSize = 11
		Content.TextXAlignment = Enum.TextXAlignment.Left
		Content.TextYAlignment = Enum.TextYAlignment.Top
		Content.Parent = Toast

		Toast.Position = UDim2.new(1, 300, 1, 0)

		Tween(Toast, {
			Position = UDim2.new(0, 0, 0, 0),
		})

		task.delay(Config.Duration or 4, function()
			Tween(Toast, {
				Position = UDim2.new(1, 300, 0, 0),
			})

			task.wait(0.25)

			Toast:Destroy()
		end)
	end

    ---------------------------------------------------------------------
    -- WINDOW UTILITIES
    ---------------------------------------------------------------------

    Window.Flags = {}
    Window.Connections = {}
    Window.Minimized = false
    
    local function Connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(Window.Connections, connection)
        return connection
    end
    
    ---------------------------------------------------------------------
    -- RESIZE HANDLE
    ---------------------------------------------------------------------
    local ResizeHandle = Instance.new("ImageButton")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.AnchorPoint = Vector2.new(1,1)
    ResizeHandle.Position = UDim2.new(1,-4,1,-4)
    ResizeHandle.Size = UDim2.fromOffset(18,18)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Image = GetLucideIcon("move-diagonal-2")
    ResizeHandle.ImageColor3 = Wolf.Theme.SubText
    ResizeHandle.Parent = MainFrame
    
    local resizing = false
    local resizeStart
    local startSize
    
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            
            local delta = input.Position - resizeStart

		    MainFrame.Size = UDim2.fromOffset(
			    math.clamp(startSize.X.Offset + delta.X, 560, 900),
			    math.clamp(startSize.Y.Offset + delta.Y, 360, 650)
		    )

	    end

    end)

    ---------------------------------------------------------------------
    -- MINIMIZE
    ---------------------------------------------------------------------

    local MinimizedHeight = 52
    local OriginalSize = MainFrame.Size

    function Window:Minimize(State)

	    if State == nil then
		    State = not self.Minimized
	    end

	    self.Minimized = State

	    if self.Minimized then

		    Tween(MainFrame,{
			    Size = UDim2.fromOffset(
				    MainFrame.AbsoluteSize.X,
				    MinimizedHeight
			    )
		    })

		    ContentArea.Visible = false
		    Sidebar.Visible = false
		    Footnote.Visible = false

		    ResizeHandle.Visible = false

		    ResizeIcon.Image = GetLucideIcon("chevron-up")

	    else

	    	ContentArea.Visible = true
	    	Sidebar.Visible = true
	    	Footnote.Visible = true

	    	ResizeHandle.Visible = true

	    	Tween(MainFrame,{
		    	Size = OriginalSize
		    })

		    ResizeIcon.Image = GetLucideIcon("chevron-down")

	    end

    end

    ResizeIcon.InputBegan:Connect(function(input)
    	if input.UserInputType == Enum.UserInputType.MouseButton1 then
	    	Window:Minimize()
	    end
    end)

    ---------------------------------------------------------------------
    -- TOGGLE UI (RIGHT SHIFT)
    ---------------------------------------------------------------------

    local ToggleKey = Enum.KeyCode.RightShift

    Connect(UserInputService.InputBegan,function(input,gpe)

	    if gpe then
		    return
	    end

	    if input.KeyCode == ToggleKey then
	    	WolfUI.Enabled = not WolfUI.Enabled
	    end

    end)

    function Window:SetToggleKey(Key)
    	ToggleKey = Key
    end

    ---------------------------------------------------------------------
    -- SEARCH IMPROVEMENT
    ---------------------------------------------------------------------

    local function SearchObject(Query)

    	Query = Query:lower()

    	for _,Page in pairs(Window.Pages) do

    		for _,Object in ipairs(Page:GetChildren()) do

    			if Object:IsA("GuiObject") then

    				local Found = Query == ""

    				if not Found then

    					for _,Descendant in ipairs(Object:GetDescendants()) do

    						if Descendant:IsA("TextLabel") then

    							if Descendant.Text:lower():find(Query,1,true) then
    								Found = true
    								break
    							end

        					end

        				end

    				Object.Visible = Found

    			end

    		end

    	end

    end

    Connect(SearchBox:GetPropertyChangedSignal("Text"),function()

    	SearchObject(SearchBox.Text)

    end)

    ---------------------------------------------------------------------
    -- THEME MANAGER HOOKS
    ---------------------------------------------------------------------

    function Window:RegisterTheme(ThemeManager)

    	if not ThemeManager then
    		return
    	end

    	local function Register(Object,Property,ThemeKey,Transparency)

    		if ThemeManager.Register then
		    	ThemeManager:Register(Object,Property,ThemeKey,Transparency)
	    	end

	    end

	    Register(MainFrame,"BackgroundColor3","Background")
	    Register(HeaderFrame,"BackgroundColor3","Header")
	    Register(Sidebar,"BackgroundColor3","Sidebar")
	    Register(ProfileCard,"BackgroundColor3","Card")

	    Register(HeaderTitle,"TextColor3","Accent")
	    Register(PlayerName,"TextColor3","Text")
	    Register(Username,"TextColor3","SubText")
	    Register(DeviceLabel,"TextColor3","SubText")

	    Register(SearchBox,"BackgroundColor3","Surface2")
	    Register(SearchBox,"TextColor3","Text")
	    Register(SearchBox,"PlaceholderColor3","SubText")

	    Register(LockButton,"BackgroundColor3","AccentDark")
	    Register(LockButton,"TextColor3","Text")

	    Register(FootText,"TextColor3","SubText")
	    Register(ResizeHandle,"ImageColor3","SubText")

    end

    ---------------------------------------------------------------------
    -- SAVE MANAGER HOOKS
    ---------------------------------------------------------------------

    function Window:RegisterSaveManager(SaveManager)

    	if not SaveManager then
    		return
    	end

    	self.SaveManager = SaveManager

    	if SaveManager.SetLibrary then
    		SaveManager:SetLibrary(Wolf)
    	end

    end

    function Window:SetFlag(Name,Value)

    	self.Flags[Name] = Value

    end

    function Window:GetFlag(Name)

    	return self.Flags[Name]

    end

    ---------------------------------------------------------------------
    -- NOTIFICATION SHORTCUTS
    ---------------------------------------------------------------------

    function Window:Success(Text)

    	self:Notify({
    		Title = "Success",
    		Content = Text,
    		Color = Color3.fromRGB(30,180,70)
    	})

    end

    function Window:Warning(Text)

    	self:Notify({
	    	Title = "Warning",
    		Content = Text,
	    	Color = Color3.fromRGB(255,190,0)
	    })

    end

    function Window:Error(Text)

    	self:Notify({
	    	Title = "Error",
	    	Content = Text,
	    	Color = Color3.fromRGB(255,60,60)
	    })

    end

    ---------------------------------------------------------------------
    -- WINDOW DESTROY
    ---------------------------------------------------------------------

    function Window:Destroy()

    	for _,Connection in ipairs(self.Connections) do
    		pcall(function()
    			Connection:Disconnect()
    		end)
    	end

    	self.Connections = {}

    	if WolfUI then
    		WolfUI:Destroy()
    	end

    end

    ---------------------------------------------------------------------
    -- WINDOW SHOW/HIDE
    ---------------------------------------------------------------------

    function Window:Show()
	    WolfUI.Enabled = true
    end

    function Window:Hide()
    	WolfUI.Enabled = false
    end

    ---------------------------------------------------------------------
    -- WINDOW SET TITLE / FOOTNOTE
    ---------------------------------------------------------------------

    function Window:SetTitle(Text)
    	HeaderTitle.Text = Text
    end

    function Window:SetFootnote(Text)
    	FootText.Text = Text
    end

	return Window
end

return Wolf
