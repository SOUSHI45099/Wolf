--//====================================================================--
--// Wolf UI Library - SaveManager
--// Compatible with Wolf Library V2
--//====================================================================--

local cloneref = cloneref or clonereference or function(i)
	return i
end

local clonefunction = clonefunction or copyfunction or function(f)
	return f
end

local HttpService = cloneref(game:GetService("HttpService"))

---------------------------------------------------------------------
-- EXPLOIT FIXES
---------------------------------------------------------------------

local isfolder = clonefunction(isfolder or function() return false end)
local isfile = clonefunction(isfile or function() return false end)
local listfiles = clonefunction(listfiles or function() return {} end)

local makefolder = makefolder or function() end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local delfile = delfile or function() end

---------------------------------------------------------------------
-- MANAGER
---------------------------------------------------------------------

local SaveManager = {
	Library = nil,

	Folder = "Wolf",
	SubFolder = "Configs",

	Ignore = {},
	LoadingOrder = {},
	UseLoadingOrder = false,

	AutoloadConfig = "autoload.json"
}

---------------------------------------------------------------------
-- LIBRARY
---------------------------------------------------------------------

function SaveManager:SetLibrary(Library)
	self.Library = Library
end

---------------------------------------------------------------------
-- PATHS
---------------------------------------------------------------------

function SaveManager:GetFolder()
	return self.Folder.."/"..self.SubFolder
end

function SaveManager:SetFolder(Name)
	self.Folder = Name
end

function SaveManager:SetSubFolder(Name)
	self.SubFolder = Name
end

function SaveManager:EnsureFolder()

	if not isfolder(self.Folder) then
		makefolder(self.Folder)
	end

	if not isfolder(self:GetFolder()) then
		makefolder(self:GetFolder())
	end

end

---------------------------------------------------------------------
-- FLAGS
---------------------------------------------------------------------

function SaveManager:SetIgnoreIndexes(List)

	for _,Flag in ipairs(List) do
		self.Ignore[Flag] = true
	end

end

local function DeepCopy(Table)

	local Copy = {}

	for Key,Value in pairs(Table) do
		if typeof(Value) == "table" then
			Copy[Key] = DeepCopy(Value)
		else
			Copy[Key] = Value
		end
	end

	return Copy

end

function SaveManager:GetFlags()

	local Flags = {}

	if not self.Library then
		return Flags
	end

	local WindowFlags = self.Library.Flags or {}

	for Name,Value in pairs(WindowFlags) do

		if not self.Ignore[Name] then
			Flags[Name] = DeepCopy(Value)
		end

	end

	return Flags

end

---------------------------------------------------------------------
-- SAVE CONFIG
---------------------------------------------------------------------

function SaveManager:Save(Name)

	self:EnsureFolder()

	Name = Name or "Default"

	local Data = {
		Flags = self:GetFlags()
	}

	local Success, Encoded = pcall(function()
		return HttpService:JSONEncode(Data)
	end)

	if Success then
		writefile(self:GetFolder().."/"..Name..".json",Encoded)
	end

end

---------------------------------------------------------------------
-- LOAD CONFIG
---------------------------------------------------------------------

function SaveManager:Load(Name)

	if not self.Library then
		return
	end

	Name = Name or "Default"

	local Path = self:GetFolder().."/"..Name..".json"

	if not isfile(Path) then
		return
	end

	local Success, Data = pcall(function()
		return HttpService:JSONDecode(readfile(Path))
	end)

	if not Success then
		return
	end

	if not Data.Flags then
		return
	end

	local Flags = self.Library.Flags or {}

	for Name,Value in pairs(Data.Flags) do

		if Flags[Name] ~= nil then
			Flags[Name] = Value
		end

	end

	if self.Library.ApplyFlags then
		self.Library:ApplyFlags()
	end

end

---------------------------------------------------------------------
-- DELETE CONFIG
---------------------------------------------------------------------

function SaveManager:Delete(Name)

	local Path = self:GetFolder().."/"..Name..".json"

	if isfile(Path) then
		delfile(Path)
	end

end

---------------------------------------------------------------------
-- LIST CONFIGS
---------------------------------------------------------------------

function SaveManager:RefreshConfigList()

	self:EnsureFolder()

	local Files = {}

	for _,File in ipairs(listfiles(self:GetFolder())) do

		local Name = File:match("([^/\\]+)%.json$")

		if Name and Name ~= "autoload" then
			table.insert(Files,Name)
		end

	end

	table.sort(Files)

	return Files

end

---------------------------------------------------------------------
-- AUTOLOAD
---------------------------------------------------------------------

function SaveManager:SetAutoload(Name)

	self:EnsureFolder()

	writefile(
		self:GetFolder().."/"..self.AutoloadConfig,
		HttpService:JSONEncode({
			Config = Name
		})
	)

end

function SaveManager:LoadAutoload()

	local Path = self:GetFolder().."/"..self.AutoloadConfig

	if not isfile(Path) then
		return
	end

	local Success, Data = pcall(function()
		return HttpService:JSONDecode(readfile(Path))
	end)

	if Success and Data.Config then
		self:Load(Data.Config)
	end

end

---------------------------------------------------------------------
-- CONFIG UI (Fluent Style)
---------------------------------------------------------------------

function SaveManager:BuildConfigSection(Tab)

	local Section = Tab:AddSection({
		Title = "Configuration",
		Icon = "folder-open",
		Open = true
	})

	local CurrentConfig = "Default"

	local Dropdown

	local function Refresh()

		if Dropdown then
			Dropdown:SetValues(self:RefreshConfigList())
		end

	end

	Dropdown = Section:AddDropdown({
		Title = "Configs",
		Icon = "folder",

		Values = self:RefreshConfigList(),

		Default = "Default",

		Callback = function(Value)
			CurrentConfig = Value
		end
	})

	Section:AddTextbox({
		Title = "Config Name",
		Placeholder = "MyConfig",

		Callback = function(Text)
			if Text ~= "" then
				CurrentConfig = Text
			end
		end
	})

	Section:AddDivider("Manage")

	Section:AddButton({
		Title = "Save Config",
		Icon = "save",

		Callback = function()

			self:Save(CurrentConfig)

			Refresh()

			if self.Library.Notify then
				self.Library:Notify({
					Title = "SaveManager",
					Content = "Saved "..CurrentConfig
				})
			end

		end
	})

	Section:AddButton({
		Title = "Load Config",
		Icon = "upload",

		Callback = function()

			self:Load(CurrentConfig)

			if self.Library.Notify then
				self.Library:Notify({
					Title = "SaveManager",
					Content = "Loaded "..CurrentConfig
				})
			end

		end
	})

	Section:AddButton({
		Title = "Delete Config",
		Icon = "trash-2",

		Callback = function()

			self:Delete(CurrentConfig)

			Refresh()

			if self.Library.Notify then
				self.Library:Notify({
					Title = "SaveManager",
					Content = "Deleted "..CurrentConfig
				})
			end

		end
	})

	Section:AddDivider("Autoload")

	Section:AddButton({
		Title = "Set Autoload",
		Icon = "check-circle",

		Callback = function()

			self:SetAutoload(CurrentConfig)

			if self.Library.Notify then
				self.Library:Notify({
					Title = "SaveManager",
					Content = "Autoload set to "..CurrentConfig
				})
			end

		end
	})

	Section:AddButton({
		Title = "Load Autoload",
		Icon = "refresh-ccw",

		Callback = function()

			self:LoadAutoload()

			if self.Library.Notify then
				self.Library:Notify({
					Title = "SaveManager",
					Content = "Autoload Loaded"
				})
			end

		end
	})

	return Section

end

---------------------------------------------------------------------
-- UTILITIES
---------------------------------------------------------------------

function SaveManager:GetConfigNames()
	return self:RefreshConfigList()
end

function SaveManager:ConfigExists(Name)
	return isfile(self:GetFolder().."/"..Name..".json")
end

return SaveManager
