local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))()
if getgenv().Loaded then 
    AkaliNotif.Notify({
        Title = "Spectra Hub",
        Description = "Script is already loaded!",
        Duration = 5
    })
    return 
end

getgenv().Loaded = true
_G.kaDelay = 0
_G.xrayConn = false

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services --
local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local hrp = Character:WaitForChild("HumanoidRootPart")

local pos = hrp.Position

local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)

local kaConn

local Window = Fluent:CreateWindow({
    Title = "Minecraft (Spectra Hub) v1.0",
    SubTitle = "by 1DeRBy1",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 300),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftShift
})

local Tabs = {
    Credits = Window:AddTab({ Title = "Credits", Icon = "info" }),
    cs = Window:AddTab({ Title = "Combat", Icon = "swords" }),
	vs = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    st = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua",true))()
  wait()
  -- Anti Kick --
  
  local oldhmmi
  local oldhmmnc
  oldhmmi = hookmetamethod(game, "__index", function(self, method)
    if self == player and method:lower() == "kick" then
      return error("Expected ':' not '.' calling member function Kick", 2)
    end
    return oldhmmi(self, method)
  end)
  oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
    if self == player and getnamecallmethod():lower() == "kick" then
      return
    end
    return oldhmmnc(self, ...)
  end)

-- Functions --
local function WorldToBlock(x, y, z)
	return math.floor(x / 3 + 0.5),
		   math.floor(y / 3),
		   math.floor(z / 3 + 0.5)
end

local bx, by, bz = WorldToBlock(pos.X, pos.Y, pos.Z)

Tabs.Credits:AddParagraph({
    Title = "Credits",
    Content = "Made by 1DeRBy1\nCredits to PurpleApple for some functions\nUI Library: Fluent"
})

local kaToggle = Tabs.cs:AddToggle("kaToggle", {
    Title = "Kill Aura",
    Description = "Automatically attacks nearby players",
    Default = false,
    Callback = function(t)
        _G.kaConn = t
        if _G.kaConn then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/Modules/Killaura.lua"))()
        end
    end
})

local xrayToggle = Tabs.vs:AddToggle("xrayToggle", {
    Title = "X-Ray",
    Description = "ESP for ores",
    Default = false,
    Callback = function(t)
        _G.xrayConn = t
        if _G.xrayConn then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/Modules/Xray.lua"))()
        end
    end
})

local kadelay = Tabs.st:AddInput("kadelay", {
    Title = "Kill Aura Delay",
    Description = "Seconds between each hit (Default: 0)",
    Default = "0",
    Placeholder = "Enter a number",
    Numeric = true,
    Finished = false,
    Callback = function(kad)
      local newDelay = tonumber(kad)
      if newDelay then
        _G.kaDelay = newDelay
        Fluent:Notify({
          Title = "Success!",
          Content = "Successfully edited delay",
          SubContent = "Delay: " .. newDelay,
          Duration = 3
        })
      else
        Fluent:Notify({
          Title = "Error",
          Content = "Invalid Delay:" .. kad,
          SubContent = "Please enter a number",
          Duration = 3
        })
      end
    end
})

Tabs.st:AddDropdown("InterfaceTheme", {
    Title = "Theme",
    Description = "Changes the interface theme.",
    Values = Fluent.Themes,
    Default = Fluent.Theme,
    Callback = function(Value)
        Fluent:SetTheme(Value)
    end
})

Tabs.st:AddToggle("TransparentToggle", {
    Title = "Transparency",
    Description = "Makes the interface transparent.",
    Default = Fluent.Transparency,
    Callback = function(Value)
        Fluent:ToggleTransparency(Value)
    end
})

Window:SelectTab(1)
