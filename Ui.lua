local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Net = RS.Shared.Packages.Networker
local UpgradeRF = Net["RF/UpgradeBrainrot"]
local PrestigeRE = Net["RE/Prestige"]
local PickupRE = Net["RE/PickupBrainrot"]
local PlaceEggRF = Net["RF/PlaceEgg"]
local GetProfileDataRF = Net["RF/GetProfileData"]
local TARGET = {Stand2=true, Stand4=true, Stand6=true, Stand1=true, Stand3=true, Stand5=true, Stand7=true, Stand8=true}
local lastPrestige = {}
local PRESTIGE_WAIT = 80
local levelCache = {}
local function getPlot()
    for _, p in ipairs(workspace.CoreObjects.Plots:GetChildren()) do
        if p:GetAttribute("Owner") == LP.Name or p:GetAttribute("Owner") == LP.UserId then
            return p
        end
    end
end
local function getEgg()
    for _, t in ipairs(LP.Backpack:GetChildren()) do
        if t:IsA("Tool") and t:GetAttribute("Egg") == true then
            return t
        end
    end
end
local function upgradeAllSafe(stands)
    local upgraded = 0
    for _, stand in ipairs(stands) do
        if not TARGET[stand.Name] then continue end
        local model = stand:FindFirstChildOfClass("Model")
        if not model then continue end
        local level = model:GetAttribute("Level")
        if level and level > 0 and level < 50 then
            local cachedLevel = levelCache[stand.Name] or 0
            
            if cachedLevel >= 50 then
                warn("⚠️ Cache dit 50+ pour", stand.Name, "→ SKIP")
                continue
            end
            -- Upgrade
            local success = pcall(function()
                UpgradeRF:InvokeServer(stand.Name)
            end)
            if success then
                levelCache[stand.Name] = level + 1
                upgraded = upgraded + 1
                if level >= 48 then
                    task.wait(0.1) 
                end
            end
        else
            levelCache[stand.Name] = level or 0
        end
    end
    return upgraded
end
local function handlePrestigeAndSwap(stands)
    for _, stand in ipairs(stands) do
        if not TARGET[stand.Name] then continue end
        local model = stand:FindFirstChildOfClass("Model")
        if not model then continue end
        local level = model:GetAttribute("Level")
        local rank = model:GetAttribute("Rank")
        if rank == 4 then
            PickupRE:FireServer(stand.Name)
            task.wait(0.3)
            local egg = getEgg()
            if egg then
                egg.Parent = LP.Character
                task.wait(0.1)
                PlaceEggRF:InvokeServer(stand.Name, egg.Name)
            end
            levelCache[stand.Name] = 0 -- Reset cache
            return true
        end
        if level and level >= 50 then
            if lastPrestige[stand.Name] and tick() - lastPrestige[stand.Name] < PRESTIGE_WAIT then
                continue
            end
            local profile = GetProfileDataRF:InvokeServer()
            local br = profile and profile.PlotData and profile.PlotData.Stands
                and profile.PlotData.Stands[stand.Name]
                and profile.PlotData.Stands[stand.Name].BrainrotData
            
            if br and br.Id then
                PrestigeRE:FireServer(stand.Name, br.Id)
                task.wait(0.4)
                local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if tool then
                    PlaceEggRF:InvokeServer(stand.Name, tool.Name)
                end
                lastPrestige[stand.Name] = tick()
                levelCache[stand.Name] = 0 -- Reset cache
                return true
            end
        end
    end
    return false
end
print("🚀 Prestige Bot Ultra-Rapide démarré!")
while task.wait(0.1) do -- Loop rapide
    local plot = getPlot()
    if not plot then continue end
    local stands = plot:FindFirstChild("Stands")
    if not stands then continue end
    local standsArray = stands:GetChildren()
    local upgraded = upgradeAllSafe(standsArray)
    if upgraded > 0 then
        print("✅ Upgradé", upgraded, "stands")
    end
    local actionDone = handlePrestigeAndSwap(standsArray)
    if actionDone then
        task.wait(0.5)
    end
end