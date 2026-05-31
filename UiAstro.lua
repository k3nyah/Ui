-- astro 1.0 | by 0_kenyah, 0_gonza

local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library      = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager  = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles

-- window
local Window = Library:CreateWindow({
    Title                = 'Astro 1.0',
    Center               = true,
    AutoShow             = true,
    Resizable            = false,
    ShowCustomCursor     = true,
    UnlockMouseWhileOpen = true,
    TabPadding           = 6,
    MenuFadeTime         = 0.15,
})

-- tabs
local Tabs = {
    Info        = Window:AddTab('Info'),
    Reach       = Window:AddTab('Reach 1.0'),
    Reacts      = Window:AddTab('Reacts 1.0'),
    Helpers     = Window:AddTab('Helpers 1.0'),
    Settings    = Window:AddTab('Settings'),
}

-- info tab
local InfoBox = Tabs.Info:AddLeftGroupbox('Astro 1.0')

InfoBox:AddLabel('Astro 1.0')
InfoBox:AddLabel('. The Best Script In Process .')
InfoBox:AddDivider()
InfoBox:AddLabel('Made by: 0_Kenyah, 0_Gonza')

-- reach tab (ready for content)
local ReachLeft  = Tabs.Reach:AddLeftGroupbox('Reach Settings')
local ReachRight = Tabs.Reach:AddRightGroupbox('Reach Options')

-- reacts tab (ready for content)
local ReactsLeft  = Tabs.Reacts:AddLeftGroupbox('Reacts Settings')
local ReactsRight = Tabs.Reacts:AddRightGroupbox('Reacts Options')

-- helpers tab (ready for content)
local HelpersLeft  = Tabs.Helpers:AddLeftGroupbox('Helpers Settings')
local HelpersRight = Tabs.Helpers:AddRightGroupbox('Helpers Options')

-- settings tab
local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')

MenuGroup:AddButton({
    Text = 'Unload',
    Func = function()
        Library:Unload()
    end,
})

MenuGroup:AddLabel('Menu keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI    = true,
    Text    = 'Menu keybind',
})

Library.ToggleKeybind = Options.MenuKeybind

-- theme + save managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('AstroHub')
SaveManager:SetFolder('AstroHub/configs')

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- custom colors | negro / fucsia / verde
ThemeManager:ApplyCustomTheme({
    Background        = Color3.fromRGB(5,   5,   5),
    Darker            = Color3.fromRGB(0,   0,   0),
    Light             = Color3.fromRGB(18,  18,  18),
    Main              = Color3.fromRGB(200, 0,   150),
    MainDark          = Color3.fromRGB(140, 0,   100),
    Accent            = Color3.fromRGB(0,   220, 80),
    Text              = Color3.fromRGB(255, 255, 255),
    SubText           = Color3.fromRGB(150, 150, 150),
    OuterBorder       = Color3.fromRGB(200, 0,   150),
    InnerBorder       = Color3.fromRGB(30,  30,  30),
    ElementBackground = Color3.fromRGB(15,  15,  15),
    ElementBorder     = Color3.fromRGB(0,   220, 80),
    ElementOutside    = Color3.fromRGB(10,  10,  10),
})

-- watermark
Library:SetWatermarkVisibility(true)
Library:SetWatermark('Astro 1.0 | 0_Kenyah & 0_Gonza')task.defer(function()
    local theme = {
        Background        = Color3.fromRGB(5,   5,   5),
        Darker            = Color3.fromRGB(0,   0,   0),
        Light             = Color3.fromRGB(18,  18,  18),
        Main              = Color3.fromRGB(200, 0,   150),
        MainDark          = Color3.fromRGB(140, 0,   100),
        Accent            = Color3.fromRGB(0,   220, 80),
        Text              = Color3.fromRGB(255, 255, 255),
        SubText           = Color3.fromRGB(150, 150, 150),
        OuterBorder       = Color3.fromRGB(200, 0,   150),
        InnerBorder       = Color3.fromRGB(30,  30,  30),
        ElementBackground = Color3.fromRGB(15,  15,  15),
        ElementBorder     = Color3.fromRGB(0,   220, 80),
        ElementOutside    = Color3.fromRGB(10,  10,  10),
    }

    for key, color in next, theme do
        if Library.Theme[key] ~= nil then
            Library.Theme[key] = color
        end
    end

    Library:UpdateColorsUsingTheme()
end)

-- watermark
Library:SetWatermarkVisibility(true)
Library:SetWatermark('Astro 1.0 | 0_Kenyah & 0_Gonza')
