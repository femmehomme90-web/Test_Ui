local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Net = RS.Shared.Packages.Networker

local UpgradeRF = Net["RF/UpgradeBrainrot"]
local PrestigeRE = Net["RE/Prestige"]
local PickupRE = Net["RE/PickupBrainrot"]
local GetProfileDataRF = Net["RF/GetProfileData"]

local TARGET = {Stand2=true, Stand4=true, Stand6=true, Stand1=true, Stand3=true, Stand5=true, Stand7=true, Stand8=true}
local lastPrestige = {}
local PRESTIGE_WAIT = 80

-- ✅ CACHE DES NIVEAUX pour éviter de dépasser 50
local levelCache = {}
local lastCacheClear = tick()
local CACHE_CLEAR_INTERVAL = 60 -- Nettoyage toutes les 60 secondes

-- 🎲 FONCTION DE RANDOMISATION ANTI-DÉTECTION
local function randomWait(min, max)
    task.wait(math.random(min * 100, max * 100) / 100)
end

-- 🧹 NETTOYAGE AUTOMATIQUE DU CACHE
local function clearCacheIfNeeded()
    if tick() - lastCacheClear >= CACHE_CLEAR_INTERVAL then
        local count = 0
        for k, _ in pairs(levelCache) do
            levelCache[k] = nil
            count = count + 1
        end
        lastCacheClear = tick()
        print("🧹 Cache nettoyé (" .. count .. " entrées supprimées)")
    end
end

local function getPlot()
    for _, p in ipairs(workspace.CoreObjects.Plots:GetChildren()) do
        if p:GetAttribute("Owner") == LP.Name or p:GetAttribute("Owner") == LP.UserId then
            return p
        end
    end
end

-- ✅ UPGRADE BATCH RAPIDE (tous les stands d'un coup)
local function upgradeAllSafe(stands)
    local upgraded = 0
    
    for _, stand in ipairs(stands) do
        if not TARGET[stand.Name] then continue end
        
        local model = stand:FindFirstChildOfClass("Model")
        if not model then continue end
        
        local level = model:GetAttribute("Level")
        
        -- 🛡️ SÉCURITÉ ANTI-DÉPASSEMENT
        if level and level > 0 and level < 50 then
            -- Double vérif avec le cache
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
                -- Mise à jour du cache
                levelCache[stand.Name] = level + 1
                upgraded = upgraded + 1
                
                -- Si on approche 50, on ralentit
                if level >= 48 then
                    randomWait(0.1, 0.15) -- Sécurité supplémentaire près de 50
                elseif upgraded % 3 == 0 then
                    -- Délai aléatoire tous les 3 upgrades pour paraître humain
                    randomWait(0.05, 0.1)
                end
            end
        else
            -- Mise à jour cache même si pas upgrade
            levelCache[stand.Name] = level or 0
        end
    end
    
    return upgraded
end

-- ✅ GESTION PRESTIGE/SWAP (sans placement d'œuf)
local function handlePrestigeAndSwap(stands)
    for _, stand in ipairs(stands) do
        if not TARGET[stand.Name] then continue end
        
        local model = stand:FindFirstChildOfClass("Model")
        if not model then continue end
        
        local level = model:GetAttribute("Level")
        local rank = model:GetAttribute("Rank")
        
        -- 🔁 RANK 4 → PICKUP SEULEMENT
        if rank == 4 then
            PickupRE:FireServer(stand.Name)
            randomWait(0.25, 0.35) -- Délai randomisé
            levelCache[stand.Name] = 0 -- Reset cache
            print("🗑️ Pickup Rank 4:", stand.Name)
            return true
        end
        
        -- 🏆 PRESTIGE (niveau 50+)
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
                randomWait(0.35, 0.5) -- Délai randomisé
                lastPrestige[stand.Name] = tick()
                levelCache[stand.Name] = 0 -- Reset cache
                print("🏆 Prestige:", stand.Name)
                return true
            end
        end
    end
    
    return false
end

-- ===============================================
-- 🔥 MAIN LOOP ULTRA-RAPIDE AVEC RANDOMISATION
-- ===============================================

print("🚀 Prestige Bot Ultra-Rapide démarré!")
print("🎲 Randomisation activée pour éviter la détection")
print("🧹 Nettoyage de cache automatique toutes les 60 secondes")

while true do
    randomWait(0.08, 0.15) -- Loop randomisée (au lieu de 0.1 fixe)
    
    -- 🧹 Nettoyage périodique du cache
    clearCacheIfNeeded()
    
    local plot = getPlot()
    if not plot then continue end
    
    local stands = plot:FindFirstChild("Stands")
    if not stands then continue end
    
    local standsArray = stands:GetChildren()
    
    -- 🔼 PHASE 1 : UPGRADE BATCH (tous en même temps)
    local upgraded = upgradeAllSafe(standsArray)
    
    if upgraded > 0 then
        print("✅ Upgradé", upgraded, "stands")
    end
    
    -- 🔁 PHASE 2 : PRESTIGE/SWAP (un à la fois)
    local actionDone = handlePrestigeAndSwap(standsArray)
    
    if actionDone then
        randomWait(0.4, 0.6) -- Petite pause randomisée après prestige/swap
    end
end