-- Services --
local Players = game:GetService("Players")
-- Variables --
local player = Players.LocalPlayer

-- local char = player.Character or player.CharacterAdded:Wait()
-- local hrp = char:FindFirstChild("HumanoidRootPart")
-- local pos = hrp.Position

local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)
local IDInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("IDInfo"))
-- Functions --

function getBlock(x, y, z)
    if not env.getBlock then return nil end
    return env.getBlock(x, y, z)
end

function getBlockID(x, y, z)
    if not env.getBlock then return nil end
    local block = env.getBlock(x, y, z)
    if block == nil then return nil end
    if type(block) == "number" then return block end
    if type(block) == "table" then return block.id end
    return nil
end

function convertBlockIdToBlockName(blockId)
    if type(blockId) ~= "number" then return nil end
    local info = IDInfo[blockId]
    if not info then return nil end
    if info.block ~= true then return nil end
    if info.tool then return nil end
    return info.name
end

function WorldToBlock(x, y, z)
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        return nil
    end
    return
        math.floor(x / 3 + 0.5),
        math.floor(y / 3),
        math.floor(z / 3 + 0.5)
end

-- local bx, by, bz = WorldToBlock(pos.X, pos.Y, pos.Z)
-- local blockId = getBlockID(bx, by-1, bz)
-- local blockName = convertBlockIdToBlockName(blockId)
-- print(blockName)
-- print(bx, by, bz)

return {
    getBlock = getBlock,
    getBlockID = getBlockID,
    convertBlockIdToBlockName = convertBlockIdToBlockName,
    WorldToBlock = WorldToBlock
}
