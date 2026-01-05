-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --
local player = Players.LocalPlayer
local lastHit = 0
local MAX_RANGE = 16
local mobCache = {}

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/main/WorldTestFunctions.lua"))()

-- Functions --
local function getCoords(pos)
    if not pos then return 0, 0, 0 end
    return WorldFunctions.WorldToBlock(pos.X, pos.Y, pos.Z)
end

local function getClosestMob(playerPos)
    local closest, shortest = nil, MAX_RANGE
    local px, py, pz = getCoords(playerPos)
    
    for uuid, mob in pairs(mobCache) do
        if tick() - mob.t > 5 or (mob.h and mob.h <= 0) then
            mobCache[uuid] = nil
        else
            local mx, my, mz = unpack(mob.c)
            local dist = math.abs(mx - px) + math.abs(mz - pz)
            if dist <= shortest then
                shortest = dist
                closest = uuid
            end
        end
    end
    return closest
end

ReplicatedStorage.UpdateWorld.OnClientEvent:Connect(function(data)
    if data and data.chunks then
        for _, chunk in pairs(data.chunks) do
            if chunk[3] and chunk[3].entitydata then
                for _, e in pairs(chunk[3].entitydata) do
                    if e.id and e.id ~= "player" and e.id ~= "item" and e.UUID then
                        local cx, cy, cz = getCoords(e.Pos)
                        mobCache[tostring(e.UUID)] = {c = {cx, cy, cz}, h = e.Health, t = tick()}
                    end
                end
            end
        end
    end
end)

if not getgenv().mobKaHooked then
    getgenv().mobKaHooked = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and _G.mobKillaura and (method == "InvokeServer" or method == "invokeServer") and self.Name == "SendState" then
            local originalData = args[1]
            
            if type(originalData) == "table" and originalData.pos then
                local currentTime = tick()
                
                if (currentTime - lastHit) >= (_G.kaDelay or 0) then
                    local target = getClosestMob(originalData.pos)
                    
                    if target then
                        local newData = {}
                        for k, v in pairs(originalData) do newData[k] = v end
                        
                        newData.targetEntity = target
                        newData.iattack = true
                        
                        lastHit = currentTime
                        return self.InvokeServer(self, newData)
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end
