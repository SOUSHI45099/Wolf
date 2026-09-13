--//====================================================================--
--// WolfTool Fluent ThemeManager
--// Complete Theme Manager (Drop-In)
--//====================================================================--

local ThemeManager = {}
ThemeManager.Library = nil
ThemeManager.CurrentTheme = "Default"
ThemeManager.Registered = {}

---------------------------------------------------------------------
-- THEMES
---------------------------------------------------------------------

ThemeManager.Themes = {
    Default = {
        Background = Color3.fromRGB(15,15,17),
        Surface = Color3.fromRGB(23,23,25),
        Surface2 = Color3.fromRGB(30,30,33),
        Sidebar = Color3.fromRGB(18,18,20),
        Header = Color3.fromRGB(20,20,22),
        Card = Color3.fromRGB(28,28,31),
        Accent = Color3.fromRGB(135,0,0),
        AccentDark = Color3.fromRGB(90,0,0),
        AccentLight = Color3.fromRGB(180,35,35),
        Text = Color3.fromRGB(240,240,240),
        SubText = Color3.fromRGB(170,170,175),
        Border = Color3.fromRGB(45,45,48),
        Hover = Color3.fromRGB(35,35,39),
        ToggleOff = Color3.fromRGB(70,70,75)
    },

    Milk = {
        Background = Color3.fromRGB(245,245,245),
        Surface = Color3.fromRGB(235,235,235),
        Surface2 = Color3.fromRGB(225,225,225),
        Sidebar = Color3.fromRGB(250,250,250),
        Header = Color3.fromRGB(255,255,255),
        Card = Color3.fromRGB(238,238,238),
        Accent = Color3.fromRGB(175,175,175),
        AccentDark = Color3.fromRGB(120,120,120),
        AccentLight = Color3.fromRGB(255,255,255),
        Text = Color3.fromRGB(30,30,30),
        SubText = Color3.fromRGB(90,90,90),
        Border = Color3.fromRGB(200,200,200),
        Hover = Color3.fromRGB(225,225,225),
        ToggleOff = Color3.fromRGB(180,180,180)
    },

    Charcoal = {
        Background = Color3.fromRGB(22,22,24),
        Surface = Color3.fromRGB(34,34,36),
        Surface2 = Color3.fromRGB(40,40,43),
        Sidebar = Color3.fromRGB(28,28,30),
        Header = Color3.fromRGB(30,30,32),
        Card = Color3.fromRGB(36,36,39),
        Accent = Color3.fromRGB(110,110,115),
        AccentDark = Color3.fromRGB(70,70,70),
        AccentLight = Color3.fromRGB(160,160,160),
        Text = Color3.fromRGB(245,245,245),
        SubText = Color3.fromRGB(180,180,180),
        Border = Color3.fromRGB(60,60,65),
        Hover = Color3.fromRGB(48,48,52),
        ToggleOff = Color3.fromRGB(90,90,95)
    },

    Ocean = {
        Background = Color3.fromRGB(12,20,28),
        Surface = Color3.fromRGB(20,32,42),
        Surface2 = Color3.fromRGB(26,40,52),
        Sidebar = Color3.fromRGB(18,28,38),
        Header = Color3.fromRGB(15,35,45),
        Card = Color3.fromRGB(22,38,48),
        Accent = Color3.fromRGB(0,170,255),
        AccentDark = Color3.fromRGB(0,120,190),
        AccentLight = Color3.fromRGB(90,200,255),
        Text = Color3.fromRGB(240,250,255),
        SubText = Color3.fromRGB(150,200,220),
        Border = Color3.fromRGB(45,70,90),
        Hover = Color3.fromRGB(28,55,70),
        ToggleOff = Color3.fromRGB(60,90,110)
    },

    Blood = {
        Background = Color3.fromRGB(18,10,12),
        Surface = Color3.fromRGB(28,14,18),
        Surface2 = Color3.fromRGB(34,18,22),
        Sidebar = Color3.fromRGB(22,12,15),
        Header = Color3.fromRGB(24,14,17),
        Card = Color3.fromRGB(30,16,20),
        Accent = Color3.fromRGB(190,20,50),
        AccentDark = Color3.fromRGB(120,10,30),
        AccentLight = Color3.fromRGB(255,80,120),
        Text = Color3.fromRGB(255,240,245),
        SubText = Color3.fromRGB(200,150,165),
        Border = Color3.fromRGB(70,25,35),
        Hover = Color3.fromRGB(48,18,24),
        ToggleOff = Color3.fromRGB(80,35,40)
    },

    Rose = {
        Background = Color3.fromRGB(22,12,20),
        Surface = Color3.fromRGB(34,20,30),
        Surface2 = Color3.fromRGB(42,24,36),
        Sidebar = Color3.fromRGB(26,16,24),
        Header = Color3.fromRGB(30,18,28),
        Card = Color3.fromRGB(36,20,30),
        Accent = Color3.fromRGB(255,70,170),
        AccentDark = Color3.fromRGB(190,35,120),
        AccentLight = Color3.fromRGB(255,145,210),
        Text = Color3.fromRGB(255,240,248),
        SubText = Color3.fromRGB(225,180,205),
        Border = Color3.fromRGB(80,40,60),
        Hover = Color3.fromRGB(50,24,40),
        ToggleOff = Color3.fromRGB(90,55,70)
    },

    Cyber = {
        Background = Color3.fromRGB(10,10,15),
        Surface = Color3.fromRGB(18,18,25),
        Surface2 = Color3.fromRGB(26,26,34),
        Sidebar = Color3.fromRGB(14,14,20),
        Header = Color3.fromRGB(16,16,22),
        Card = Color3.fromRGB(20,20,28),
        Accent = Color3.fromRGB(0,255,200),
        AccentDark = Color3.fromRGB(0,180,145),
        AccentLight = Color3.fromRGB(100,255,225),
        Text = Color3.fromRGB(235,255,250),
        SubText = Color3.fromRGB(130,220,205),
        Border = Color3.fromRGB(30,90,80),
        Hover = Color3.fromRGB(18,40,38),
        ToggleOff = Color3.fromRGB(45,70,70)
    },

    Sun = {
        Background = Color3.fromRGB(32,24,8),
        Surface = Color3.fromRGB(45,34,12),
        Surface2 = Color3.fromRGB(55,42,18),
        Sidebar = Color3.fromRGB(40,28,10),
        Header = Color3.fromRGB(46,34,12),
        Card = Color3.fromRGB(52,38,14),
        Accent = Color3.fromRGB(255,200,0),
        AccentDark = Color3.fromRGB(205,150,0),
        AccentLight = Color3.fromRGB(255,235,120),
        Text = Color3.fromRGB(255,250,225),
        SubText = Color3.fromRGB(235,215,150),
        Border = Color3.fromRGB(90,70,20),
        Hover = Color3.fromRGB(65,48,16),
        ToggleOff = Color3.fromRGB(90,80,30)
    },

    Toxic = {
        Background = Color3.fromRGB(10,14,10),
        Surface = Color3.fromRGB(18,24,18),
        Surface2 = Color3.fromRGB(24,30,24),
        Sidebar = Color3.fromRGB(14,18,14),
        Header = Color3.fromRGB(16,20,16),
        Card = Color3.fromRGB(20,28,20),
        Accent = Color3.fromRGB(57,255,20),
        AccentDark = Color3.fromRGB(20,170,0),
        AccentLight = Color3.fromRGB(120,255,90),
        Text = Color3.fromRGB(235,255,235),
        SubText = Color3.fromRGB(150,210,150),
        Border = Color3.fromRGB(35,80,35),
        Hover = Color3.fromRGB(28,45,28),
        ToggleOff = Color3.fromRGB(55,75,55)
    }
}

---------------------------------------------------------------------
-- LIBRARY CONNECTION
---------------------------------------------------------------------

function ThemeManager:SetLibrary(Library)
    self.Library = Library
    self:ApplyTheme(self.CurrentTheme)
end

---------------------------------------------------------------------
-- REGISTER GUI OBJECT
---------------------------------------------------------------------

function ThemeManager:Register(Object, Property, ThemeKey)
    if not Object then return end

    table.insert(self.Registered, {
        Object = Object,
        Property = Property,
        ThemeKey = ThemeKey,
    })

    local Theme = self.Themes[self.CurrentTheme]
    pcall(function()
        Object[Property] = Theme[ThemeKey]
    end)
end

---------------------------------------------------------------------
-- APPLY THEME
---------------------------------------------------------------------

function ThemeManager:ApplyTheme(Name)
    if not self.Themes[Name] then
        warn("Theme does not exist:", Name)
        return
    end

    self.CurrentTheme = Name

    local Theme = self.Themes[Name]

    if self.Library then
        self.Library.Theme = Theme
    end

    for _, Item in ipairs(self.Registered) do
        if Item.Object and Item.Object.Parent then
            pcall(function()
                Item.Object[Item.Property] = Theme[Item.ThemeKey]
            end)
        end
    end
end

---------------------------------------------------------------------
-- GET THEMES
---------------------------------------------------------------------

function ThemeManager:GetThemes()
    local List = {}

    for Name in pairs(self.Themes) do
        table.insert(List, Name)
    end

    table.sort(List)

    return List
end

function ThemeManager:GetCurrentTheme()
    return self.CurrentTheme
end

---------------------------------------------------------------------
-- ADD CUSTOM THEME
---------------------------------------------------------------------

function ThemeManager:AddTheme(Name, ThemeTable)
    self.Themes[Name] = ThemeTable
end

---------------------------------------------------------------------
-- APPLY TO SETTINGS TAB (MISSING FUNCTION)
---------------------------------------------------------------------

function ThemeManager:ApplyToTab(Tab, IconName)

    IconName = IconName or "palette"

    local Section = Tab:AddSection({
        Title = "Theme",
        Icon = IconName,
        Open = true,
    })

    Section:AddDropdown({
        Title = "Current Theme",
        Icon = "paintbrush",
        Values = self:GetThemes(),
        Default = self.CurrentTheme,
        Callback = function(Value)
            self:ApplyTheme(Value)
        end,
    })

    Section:AddButton({
        Title = "Default Theme",
        Icon = "rotate-ccw",
        Callback = function()
            self:ApplyTheme("Default")
        end,
    })

    Section:AddButton({
        Title = "Milk / Snow Theme",
        Icon = "snowflake",
        Callback = function()
            self:ApplyTheme("Milk")
        end,
    })

    Section:AddButton({
        Title = "Charcoal Theme",
        Icon = "moon",
        Callback = function()
            self:ApplyTheme("Charcoal")
        end,
    })

    Section:AddButton({
        Title = "Ocean Theme",
        Icon = "waves",
        Callback = function()
            self:ApplyTheme("Ocean")
        end,
    })

    Section:AddButton({
        Title = "Blood Theme",
        Icon = "droplet",
        Callback = function()
            self:ApplyTheme("Blood")
        end,
    })

    Section:AddButton({
        Title = "Rose Theme",
        Icon = "flower-2",
        Callback = function()
            self:ApplyTheme("Rose")
        end,
    })

    Section:AddButton({
        Title = "Cyber Theme",
        Icon = "cpu",
        Callback = function()
            self:ApplyTheme("Cyber")
        end,
    })

    Section:AddButton({
        Title = "Sun Theme",
        Icon = "sun",
        Callback = function()
            self:ApplyTheme("Sun")
        end,
    })

    Section:AddButton({
        Title = "Toxic Theme",
        Icon = "leaf",
        Callback = function()
            self:ApplyTheme("Toxic")
        end,
    })

    return Section
end

return ThemeManager
