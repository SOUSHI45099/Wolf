local BASE_URL = "https://raw.githubusercontent.com/SOUSHI45099/Wolf/main/"

local function loadModule(path: string)
    local source = game:HttpGet(BASE_URL .. path)
    local loadedFunction, syntaxError = loadstring(source)
    
    if not loadedFunction then
        error("[Wolf Loader] Failed to load module '" .. path .. "': " .. tostring(syntaxError))
    end
    
    return loadedFunction()
end

-- Load the runtime logic (omitting globals.d.luau)
local Library = loadModule("Library.lua")
local SaveManager = loadModule("addons/Savemanager.lua")
local ThemeManager = loadModule("addons/ThemeManager.lua")

-- Return the exact exported structure your library expects
return {
    Library = Library,
    SaveManager = SaveManager,
    ThemeManager = ThemeManager
}
