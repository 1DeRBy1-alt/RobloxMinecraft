local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))()

if getgenv().Loaded then 
    AkaliNotif.Notify({
        Title = "Spectra Client",
        Description = "Script is already loaded!",
        Duration = 5
    })
    return 
end

-- Anti Kick --
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua",true))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/refs/heads/main/Modules/anti_kick.lua", true))()

repeat task.wait(1) until workspace:FindFirstChild("Chunks") and workspace:FindFirstChild("Entities")

-- Globals --
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/refs/heads/main/Modules/globals.lua", true))()

-- Modules --
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/Modules/XRay.lua", true))() -- XRay
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/Modules/Killaura.lua", true))() -- Killaura
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/refs/heads/main/Modules/Mob%20Killaura.lua", true))() -- Mob Killaura
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/refs/heads/main/Modules/hitbox_expander.lua", true))() -- Hitbox Expander
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/Modules/Movement/init.lua", true))() -- Movement Hook

-- UI Library --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services --
local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
--[[
local Character = player.Character or player.CharacterAdded:Wait()
local hrp = Character:WaitForChild("HumanoidRootPart")
local pos = hrp.Position
local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)
]]

local Window = Fluent:CreateWindow({
    Title = "Minecraft (Spectra Client) v1.1.1",
    SubTitle = "by 1DeRBy1",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 340),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Credits = Window:AddTab({ Title = "Credits", Icon = "info" }),
    cs = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    lp = Window:AddTab({ Title = "Player", Icon = "user" }),
	vs = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    st = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/refs/heads/main/WorldTestFunctions.lua"))()

-- Credits Tab --
Tabs.Credits:AddParagraph({
    Title = "Credits",
    Content = "Made by 1DeRBy1\nCredits: PurpleApple for some functions\nUI Library: Fluent"
})

-- Combat Tab --
local kaToggle = Tabs.cs:AddToggle("kaToggle", {
    Title = "Kill Aura",
    Description = "Automatically attacks nearby players",
    Default = false,
    Callback = function(t) _G.kaConn = t end
})

local mobKaToggle = Tabs.cs:AddToggle("mobKaToggle", {
    Title = "Mob Killaura",
    Description = "Automatically attacks nearby mobs",
    Default = false,
    Callback = function(t) _G.mobKillaura = t end
})

local hbToggle = Tabs.cs:AddToggle("hbToggle", {
    Title = "Hitbox Expander",
    Description = "Automatically expands all player hitboxes (W.I.P)",
    Default = false,
    Callback = function(t) _G.hitboxConn = t end
})

-- Player Tab --
local flyToggle = Tabs.lp:AddToggle("flyToggle", {
    Title = "Fly",
    Description = "Allows you to fly around the map",
    Default = false,
    Callback = function(t) _G.Movement.Fly = t end
})

local noclipToggle = Tabs.lp:AddToggle("noclipToggle", {
    Title = "Noclip",
    Description = "Like flying, but through walls.",
    Default = false,
    Callback = function(t) _G.Movement.Noclip = t end
})

local noFallToggle = Tabs.lp:AddToggle("nofallToggle", {
    Title = "No Fall",
    Description = "Removes fall damage",
    Default = false,
    Callback = function(t) _G.Movement.NoFall = t end
})

-- Visuals Tab --
local xrayToggle = Tabs.vs:AddToggle("xrayToggle", {
    Title = "X-Ray",
    Description = "ESP for ores.",
    Default = false,
    Callback = function(t) _G.xrayConn = t end
})

local blackCoverToggle = Tabs.vs:AddToggle("blackCoverToggle", {
    Title = "No Black Cover",
    Description = "Hides that annoying UI blacking out your screen",
    Default = false,
    Callback = function(t)
        _G.BlackCover = t
        local playerGui = player.PlayerGui
        if playerGui and playerGui:FindFirstChild("MainGui") and playerGui.MainGui:FindFirstChild("BlackCover") then
            playerGui.MainGui.BlackCover.BackgroundTransparency = t and 1 or 0
        end
    end
})

-- Settings Tab --
local kadelay = Tabs.st:AddInput("kadelay", {
    Title = "Kill Aura Delay",
    Description = "Seconds between each hit",
    Default = "0.02",
    Placeholder = "Enter a number",
    Numeric = true,
    Finished = false,
    Callback = function(kad)
        local newDelay = tonumber(kad)
        if newDelay then
            _G.kaDelay = newDelay
            Fluent:Notify({Title = "Success!", Content = "Delay set to: " .. newDelay, Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Please enter a valid number", Duration = 3})
        end
    end
})

local hbSize = Tabs.st:AddSlider("hbSize", {
    Title = "Hitbox Size",
    Description = "Adjust the size of the expanded hitboxes",
    Default = 9,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(hbs)
        _G.hitboxSize = hbs
    end
})

Tabs.st:AddSlider("flySpeed", {
    Title = "Fly Speed",
    Description = "Change your flying speed",
    Default = 0.4,
    Min = 0.1,
    Max = 0.9,
    Rounding = 1,
    Callback = function(fs)
        _G.Movement.FlySpeed = fs
    end
})

Tabs.st:AddSlider("noclipSpeed", {
    Title = "Noclip Speed",
    Description = "Change your noclip speed",
    Default = 0.8,
    Min = 0.1,
    Max = 0.9,
    Rounding = 1,
    Callback = function(ns)
        _G.Movement.NoclipSpeed = ns
    end
})

Tabs.st:AddDropdown("InterfaceTheme", {
    Title = "Theme",
    Description = "Changes the interface theme.",
    Values = Fluent.Themes,
    Default = Fluent.Theme,
    Callback = function(theme)
        Fluent:SetTheme(theme)
    end
})

Tabs.st:AddToggle("TransparentToggle", {
    Title = "Transparency",
    Description = "Makes the interface transparent.",
    Default = Fluent.Transparency,
    Callback = function(t)
        Fluent:ToggleTransparency(t)
    end
})

Window:SelectTab(1)
