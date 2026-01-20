-- AutoUpgradeBrainrot.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Networker = ReplicatedStorage.Shared.Packages.Networker
local UpgradeRF = Networker["RF/UpgradeBrainrot"]

-- ✅ ACTIVÉ PAR DÉFAUT
local Config = {
    Enabled = true,  -- ← CHANGÉ ICI
    TargetLevel = 45,
    LoopDelay = 0.4,
    UpgradeDelay = 0.4
}

local lastAction = 0

local function getMyPlot()
    local plots = workspace:FindFirstChild("CoreObjects")
    if not plots then return nil end
    plots = plots:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, p in ipairs(plots:GetChildren()) do
        local owner = p:GetAttribute("Owner")
        local ov = p:FindFirstChild("Owner")
        if owner == LocalPlayer.Name or owner == LocalPlayer.UserId
            or (ov and (ov.Value == LocalPlayer.Name or ov.Value == LocalPlayer.UserId)) then
            return p
        end
    end
    return nil
end

local function getBrainrotLevel(stand)
    for _, child in ipairs(stand:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            local level = child:GetAttribute("Level")
            if level ~= nil then
                return tonumber(level) or 0
            end
        end
    end
    return 0
end

-- ✅ AFFICHAGE DANS LA CONSOLE
print("🔥 AutoUpgrade Brainrot démarré!")
print("📊 Niveau cible:", Config.TargetLevel)

-- Boucle principale
task.spawn(function()
    while true do
        task.wait(Config.LoopDelay)
        
        if not Config.Enabled then
            continue
        end

        if tick() - lastAction < Config.LoopDelay then
            continue
        end

        local plot = getMyPlot()
        if not plot then
            warn("⚠️ Aucun plot trouvé")
            task.wait(2)
            continue
        end

        local stands = plot:FindFirstChild("Stands")
        if not stands then
            task.wait(1)
            continue
        end

        local upgraded = false
        for _, stand in ipairs(stands:GetChildren()) do
            local level = getBrainrotLevel(stand)

            if level > 0 and level < Config.TargetLevel then
                local success, err = pcall(function()
                    UpgradeRF:InvokeServer(stand.Name)
                end)
                
                if success then
                    print("✅ Upgraded", stand.Name, "| Niveau:", level)
                else
                    warn("❌ Erreur upgrade:", err)
                end

                lastAction = tick()
                upgraded = true
                task.wait(Config.UpgradeDelay)
                break
            end
        end
        
        if not upgraded then
            print("✔️ Tous les stands sont au niveau max!")
        end
    end
end)

-- ✅ GARDE LE SCRIPT ACTIF
print("✅ Script chargé avec succès")