if getgenv().xrayLoaded == true then
    return
end

getgenv().xrayLoaded = true

-- Services --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
local scanning = {}

local function scanLayer(chunk, yLevel)
    local coords = string.split(chunk.Name, "x")
    if #coords ~= 2 then return end
    
    local cx, cz = tonumber(coords[1]) * 16, tonumber(coords[2]) * 16

    for x = cx, cx + 15 do
        for z = cz, cz + 15 do
            local key = x + (yLevel * 1000000) + (z * 1000)
            if visuals[key] then continue end

            local blockID = WorldFunctions.getBlockID(x, yLevel, z)
            if blockID and blockID ~= 0 then
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
                        visuals[key] = {Part = part, Chunk = chunk.Name, X = x, Y = yLevel, Z = z}
                    end
                end
            end
        end
    end
end

local function scanFullChunk(chunk)
    if chunksScanned[chunk.Name] or scanning[chunk.Name] then return end
    scanning[chunk.Name] = true
    
    for y = 1, 63 do
        scanLayer(chunk, y)
        
        if y % 8 == 0 then 
            RunService.Heartbeat:Wait() 
        end
        
        if not _G.xrayConn then break end
    end
    
    chunksScanned[chunk.Name] = true
    scanning[chunk.Name] = nil
end

local ChunksFolder = workspace:WaitForChild("Chunks")

ChunksFolder.ChildRemoved:Connect(function(chunk)
    chunksScanned[chunk.Name] = nil
    scanning[chunk.Name] = nil
    for key, data in pairs(visuals) do
        if data.Chunk == chunk.Name then
            if data.Part then data.Part:Destroy() end
            visuals[key] = nil
        end
    end
end)

task.spawn(function()
    while task.wait(0.7) do
        if _G.xrayConn then
            for _, chunk in ipairs(ChunksFolder:GetChildren()) do
                if not chunksScanned[chunk.Name] and not scanning[chunk.Name] then
                    task.spawn(scanFullChunk, chunk)
                end
            end
        end
    end
end)

task.spawn(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local lastCleanup = 0
    
    while task.wait(0.2) do
        if not _G.xrayConn then
            if next(visuals) ~= nil then
                xrayfolder:ClearAllChildren()
                table.clear(visuals)
                table.clear(chunksScanned)
                table.clear(scanning)
            end
            continue
        end

        char = player.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        local currentTime = tick()
        
        if hrp and currentTime - lastCleanup > 0.7 then
            local px, py, pz = hrp.Position.X / 3, hrp.Position.Y / 3, hrp.Position.Z / 3
            
            for key, data in pairs(visuals) do
                local bx, by, bz = data.X, data.Y, data.Z
                local dist = math.abs(bx - px) + math.abs(by - py) + math.abs(bz - pz)
                
                if dist > 50 then continue end
                
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
            lastCleanup = currentTime
        end
    end
end)
