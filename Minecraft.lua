if not getgenv().Loaded then
  getgenv().Loaded = true

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

-- Functions --
local function WorldToBlock(x, y, z)
	return math.floor(x / 3 + 0.5),
		   math.floor(y / 3),
		   math.floor(z / 3 + 0.5)
end

local function getClosestPlayer()
    local closest = nil
    local shortest = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = plr
            end
        end
    end
    return closest
end

local bx, by, bz = WorldToBlock(pos.X, pos.Y, pos.Z)

end
