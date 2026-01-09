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
    if type(pos) == "table" then
        return WorldFunctions.WorldToBlock(pos[1], pos[2], pos[3])
    end
    return WorldFunctions.WorldToBlock(pos.X, pos.Y, pos.Z)
end

local function getClosestMob(playerPos)
    local closest = nil
    local shortest = MAX_RANGE
    local px, py, pz = getCoords(playerPos)
    
    for uuid, mob in pairs(mobCache) do
        if tick() - mob.t < 5 and (not mob.h or mob.h > 0) then
            local mx, my, mz = mob.c[1], mob.c[2], mob.c[3]
            local dist = math.sqrt((mx - px)^2 + (mz - pz)^2)
            if dist <= shortest then
                shortest = dist
                closest = uuid
            end
        else
            mobCache[uuid] = nil
        end
    end
    return closest
end

ReplicatedStorage.UpdateWorld.OnClientEvent:Connect(function(data)
    if data and data.chunks then
        for _, chunk in pairs(data.chunks) do
            if chunk[3] and chunk[3].entitydata then
                for _, e in pairs(chunk[3].entitydata) do
                    if e.UUID and e.id ~= "player" and e.id ~= "item" then
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
            local data = args[1]
            if type(data) == "table" then
                local currentTime = tick()
                local delayTime = _G.kaDelay or 0
                
               if (data.ibreak or data.ibroken or data.iplace or data.iinteract or data.ieat or data.ieaten or data.iuse or data.icraft or data.targetEntity) then
                return oldNamecall(self, ...)
               end

                if (currentTime - lastHit) >= delayTime then
                    local closestUUID = getClosestMob(data.pos)
                    if closestUUID and not data.targetEntity then
                        data.targetEntity = closestUUID
                        data.iattack = true
                        lastHit = currentTime
                    end
                end
                
                return self.InvokeServer(self, data)
            end
        end

        return oldNamecall(self, ...)
    end)
end
