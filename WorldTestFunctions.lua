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
    if env.getBlock then
     if env.getBlock(x, y, z) ~= nil then
         return env.getBlock(x, y, z)
       end
    end
end

function getBlockID(x, y, z)
    if env.getBlock then
        local block = env.getBlock(x, y, z)
        if block ~= nil then
            if type(block) == "table" then
                return block.id
            elseif type(block) == "number" then
                return block
            end
        end
    end
    return nil
end

function convertBlockIdToBlockName(blockId)
    if not blockId or type(blockId) ~= "number" then 
        return nil 
    end
    
    local info = IDInfo[blockId]
    if info then
        if info.block == true and not info.tool then
            return info.name
        end
    end
    return nil
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
