-- Services --
local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local xrayfolder = workspace:FindFirstChild("XrayFolder") or Instance.new("Folder", workspace)
xrayfolder.Name = "XrayFolder"

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/WorldTestFunctions.lua"))()

-- Functions --
local function makeVisual(color, part)
    if part:FindFirstChild("bulb") then return end
    local a = Instance.new("BillboardGui")
    local b = Instance.new("Frame")
    a.Name = "bulb"
    a.Parent = part
    a.Active = true
    a.AlwaysOnTop = true
    a.Size = UDim2.new(1, 0, 1, 0)
    
    b.Name = "b"
    b.Parent = a
    b.BackgroundColor3 = color
    b.BorderColor3 = Color3.fromRGB(31, 31, 31)
    b.BorderSizePixel = 4
    b.Position = UDim2.new(0.1, 0, 0.1, 0)
    b.Size = UDim2.new(0.8, 0, 0.8, 0)
end

local ores = {
    diamond = Color3.fromRGB(35, 207, 219),
    iron = Color3.fromRGB(110, 105, 105),
    gold = Color3.fromRGB(245, 242, 71),
    coal = Color3.fromRGB(56, 59, 56),
}

local visuals = {}
local chunksScanned = {}

local function scanLayer(chunk, yLevel)
    local coords = string.split(chunk.Name, "x")
    if #coords ~= 2 then return end
    
    local cx, cz = tonumber(coords[1]) * 16, tonumber(coords[2]) * 16

    for x = cx, cx + 15 do
        for z = cz, cz + 15 do
            local key = ("%d,%d,%d"):format(x, yLevel, z)
            if visuals[key] then continue end

            local blockID = WorldFunctions.getBlockID(x, yLevel, z)
            if blockID then
                local name = WorldFunctions.convertBlockIdToBlockName(blockID)
                if name then
                    local lowerName = string.lower(name)
                    local color = nil
                    for oreName, oreColor in pairs(ores) do
                        if string.find(lowerName, oreName) then
                            color = oreColor
                            break
                        end
                    end

                    if color or string.find(lowerName, "ore") then
                        color = color or Color3.new(1,1,1)
                        local part = Instance.new("Part")
                        part.Name = name
                        part.Anchored = true
                        part.CanCollide = false
                        part.CanTouch = false
                        part.Transparency = 1
                        part.Size = Vector3.new(3, 3, 3)
                        part.Position = Vector3.new(x * 3, yLevel * 3, z * 3)
                        part.Parent = xrayfolder

                        makeVisual(color, part)
                        visuals[key] = {Part = part, Chunk = chunk.Name}
                    end
                end
            end
        end
    end
end

local function scanFullChunk(chunk)
    if chunksScanned[chunk.Name] then return end
    chunksScanned[chunk.Name] = true
    
    for y = 1, 63 do
        scanLayer(chunk, y)
        
        if y % 10 == 0 then 
            task.wait() 
        end
        
        if not _G.xrayConn then break end
    end
end

local ChunksFolder = workspace:WaitForChild("Chunks")

ChunksFolder.ChildRemoved:Connect(function(chunk)
    chunksScanned[chunk.Name] = nil
    for key, data in pairs(visuals) do
        if data.Chunk == chunk.Name then
            if data.Part then data.Part:Destroy() end
            visuals[key] = nil
        end
    end
end)

task.spawn(function()
    while task.wait(0.69) do
        if _G.xrayConn then
            for _, chunk in ipairs(ChunksFolder:GetChildren()) do
                if not chunksScanned[chunk.Name] then
                    task.spawn(scanFullChunk, chunk)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not _G.xrayConn then
            if next(visuals) ~= nil then
                xrayfolder:ClearAllChildren()
                table.clear(visuals)
                table.clear(chunksScanned)
            end
            continue
        end

        for key, data in pairs(visuals) do
            local c = string.split(key, ",")
            local bx, by, bz = tonumber(c[1]), tonumber(c[2]), tonumber(c[3])
            
            local currentID = WorldFunctions.getBlockID(bx, by, bz)
            
            if currentID then
                local name = WorldFunctions.convertBlockIdToBlockName(currentID)
                if name then
                    local lowerName = string.lower(name)
                    local isOre = false
                    
                    for oreName in pairs(ores) do
                        if string.find(lowerName, oreName) then
                            isOre = true
                            break
                        end
                    end
                    
                    if not isOre and not string.find(lowerName, "ore") then
                        if data.Part then data.Part:Destroy() end
                        visuals[key] = nil
                    end
                else
                    if data.Part then data.Part:Destroy() end
                    visuals[key] = nil
                end
            else
                if data.Part then data.Part:Destroy() end
                visuals[key] = nil
            end
        end
    end
end)
