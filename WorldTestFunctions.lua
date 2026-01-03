local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:FindFirstChild("HumanoidRootPart")
local pos = hrp.Position

local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)
local IDInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("IDInfo"))

function getBlock(x, y, z)
    if env.getBlock then
        return env.getBlock(x, y, z)
    end
end

function convertBlockIdToBlockName(blockId)
    if blockId and IDInfo[blockId] then
        if IDInfo[blockId].block == true and not IDInfo[blockId].tool then
            return IDInfo[blockId].name
        else
            warn("Not a valid block")
        end
    end
end

function WorldToBlock(x, y, z)
    return math.floor(x/3 + 0.5),
           math.floor(y/3),
           math.floor(z/3 + 0.5)
end

local bx, by, bz = WorldToBlock(pos.X, pos.Y, pos.Z)
local block = getBlock(bx, by-1, bz)
local blockId = block and block.id

local blockName = convertBlockIdToBlockName(blockId)

-- print(blockName)
-- print(bx, by, bz)
