if getgenv().scaffoldLoaded == true then
    return
end
getgenv().scaffoldLoaded = true

-- Services --
local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local SendState = game:GetService("ReplicatedStorage"):WaitForChild("SendState")
local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraft/refs/heads/main/WorldTestFunctions.lua"))()
local getBlockID = WorldFunctions.getBlockID
local WorldToBlock = WorldFunctions.WorldToBlock
local convertBlockIdToBlockName = WorldFunctions.convertBlockIdToBlockName

local lastPlace = 0
local currentHeldItem = {id = 0}

local handFuncNames = {"newHand", "renderHand", "updateHandTransition", "it"}
local handFunc = nil
for _, name in handFuncNames do
    if env[name] and type(env[name]) == "function" then
        handFunc = env[name]
        break
    end
end

if handFunc then
    local oldNamecallHand
    oldNamecallHand = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if self == handFunc and (method == "Call" or method == "Invoke") then
            for _, arg in args do
                if typeof(arg) == "table" and arg.id and type(arg.id) == "number" then
                    currentHeldItem = arg
                    break
                end
            end
        end
        
        return oldNamecallHand(self, ...)
    end)
end

local function getHeldItemID()
    if currentHeldItem.id and type(currentHeldItem.id) == "number" and currentHeldItem.id > 0 then
        local id = currentHeldItem.id
        if convertBlockIdToBlockName(id) then
            return id
        end
    end
    
    if handFunc then
        local ups = debug.getupvalues(handFunc)
        for _, up in ups do
            if typeof(up) == "table" and up.id and type(up.id) == "number" then
                local id = up.id
                if id > 0 and convertBlockIdToBlockName(id) then
                    return id
                end
            end
        end
    end
    
    return nil
end

local function getPlacePos()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local x, y, z = WorldToBlock(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
    local id = getBlockID(x, y - 1, z)
    
    if id == 0 or not id then
        return Vector3.new(x, y - 1, z), Vector3.new(0, 0, 0)
    end
end

if not getgenv().scaffoldHooked then
    getgenv().scaffoldHooked = true
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if not checkcaller() and (method == "InvokeServer" or method == "invokeServer") and self == SendState then
            local data = args[1]
            
            if type(data) == "table" then
                if (data.ibreak or data.ibroken or data.ieaten or data.iuse or data.iinteract or data.icraft) then
                    return oldNamecall(self, ...)
                end
                
                if _G.scaffoldEnabled then
                    local now = tick()
                    
                    if now - lastPlace >= (_G.scaffoldDelay or 0.01) then
                        local blockId = getHeldItemID()
                        
                        if blockId then
                            local pos, nor = getPlacePos()
                            
                            if pos then
                                data.iplace = true
                                data.targetBlock = pos
                                data.targetBlockNor = nor
                                lastPlace = now
                                
                                local cX = math.floor(pos.X / 16)
                                local cZ = math.floor(pos.Z / 16)
                                local chunk = env.getChunk and env.getChunk(cX, cZ)
                                
                                if chunk then
                                    chunk:Set(pos.X % 16, pos.Y, pos.Z % 16, {id = blockId}, true)
                                end
                            end
                        end
                    end
                end
                
                return self.InvokeServer(self, data)
            end
        end
        
        return oldNamecall(self, ...)
    end)
end
