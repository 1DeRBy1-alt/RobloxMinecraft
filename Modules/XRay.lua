 -- Services --
local Players = game:GetService("Players")

 -- Variables --
local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local hrp = Character:FindFirstChild("HumanoidRootPart")
local pos = hrp.Position

 -- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/WorldTestFunctions.lua"))()

 -- Functions --
function getPosition()
    if WorldFunctions and WorldFunctions.WorldToBlock then
        return WorldFunctions.WorldToBlock(pos.X, pos.Y, pos.Z)
    end
end
