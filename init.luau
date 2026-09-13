local WolfTypes = require(script.Parent["globals.d"])

return {
    Library = (require(script.Parent.Library) :: any) :: WolfTypes.Library,
    Types = WolfTypes,
    SaveManager = require(script.Parent.SaveManager),
    ThemeManager = require(script.Parent.ThemeManager),
    Lucide = require(script.Parent.Lucide)
}
