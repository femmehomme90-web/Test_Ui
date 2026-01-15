-- Logic.lua - Automatisation complète du processus
-- À charger APRÈS UI.lua

print("[LOGIC] Démarrage du chargement de la logique...")

-- Charger l'UI
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua"))()

print("[LOGIC] UI chargé avec succès")

-- Marquer que la logique est chargée
_G.LogicLoaded = true

-- ====================================
-- SERVICES
-- ====================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Networker = ReplicatedStorage.Shared.Packages.Networker

-- ====================================
-- REMOTES
-- ====================================
local Remotes = {
    SpawnEgg = Networker:FindFirstChild("RF/RequestEggSpawn"),
    BuyEgg = Networker:FindFirstChild("RF/BuyEgg"),
    PlaceEgg = Networker:FindFirstChild("RF/PlaceEgg"),
    HatchEgg = Networker:FindFirstChild("RE/HatchEgg"),
    PickupBrainrot = Networker:FindFirstChild("RE/PickupBrainrot"),
    PlaceBrainrot = Networker:FindFirstChild("RF/PlaceBrainrot"),
    PickupBoxes = Networker:FindFirstChild("RE/PickupBoxes"),
    BoxSold = Networker:FindFirstChild("RE/BoxSold"),
    GetBrainrotUpgradeCost = Networker:FindFirstChild("RF/GetBrainrotUpgradeCost")
}

-- ====================================
-- VARIABLES D'AUTOMATISATION
-- ====================================
local AutoFarmActive = false
local SpawnDelay = 0.5
local CurrentEggType = "Gold Tim Cheese" -- Type d'œuf par défaut
local CurrentStand = "Stand3" -- Stand par défaut
local CurrentEggName = "Lightning Tung Tung Sahur" -- Nom de l'œuf par défaut

-- ====================================
-- FONCTIONS UTILITAIRES
-- ====================================

-- Notification
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

-- Récupérer le cash du joueur
local function getCash()
    local success, cash = pcall(function()
        return LocalPlayer.leaderstats.Cash.Value
    end)
    return success and cash or 0
end

-- Vérifier si un œuf est dans l'inventaire
local function hasEggInInventory(eggName)
    return LocalPlayer.Backpack:FindFirstChild(eggName) ~= nil
end

-- Récupérer la liste des œufs dans l'inventaire
local function getInventoryEggs()
    local eggs = {}
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and not item.Name:match("^{") then -- Exclure les boxes
            table.insert(eggs, item.Name)
        end
    end
    return eggs
end

-- ====================================
-- PROCESSUS COMPLET D'AUTOMATISATION
-- ====================================

-- 1. Spawner un œuf
local function spawnEgg()
    if not Remotes.SpawnEgg then
        warn("❌ RemoteFunction 'RF/RequestEggSpawn' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return Remotes.SpawnEgg:InvokeServer()
    end)
    
    if success then
        print("✅ Œuf spawné avec succès!")
        return true
    else
        warn("❌ Erreur lors du spawn:", result)
        return false
    end
end

-- 2. Acheter un œuf
local function buyEgg(eggType, quantity)
    if not Remotes.BuyEgg then
        warn("❌ RemoteFunction 'RF/BuyEgg' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return Remotes.BuyEgg:InvokeServer(eggType or CurrentEggType, quantity or 1)
    end)
    
    if success then
        print("✅ Œuf acheté:", eggType or CurrentEggType)
        return true
    else
        warn("❌ Erreur lors de l'achat:", result)
        return false
    end
end

-- 3. Placer un œuf
local function placeEgg(stand, eggName)
    if not Remotes.PlaceEgg then
        warn("❌ RemoteFunction 'RF/PlaceEgg' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return Remotes.PlaceEgg:InvokeServer(stand or CurrentStand, eggName or CurrentEggName)
    end)
    
    if success then
        print("✅ Œuf placé sur:", stand or CurrentStand)
        return true
    else
        warn("❌ Erreur lors du placement:", result)
        return false
    end
end

-- 4. Ouvrir un œuf
local function hatchEgg(stand, eggName)
    if not Remotes.HatchEgg then
        warn("❌ RemoteEvent 'RE/HatchEgg' introuvable!")
        return false
    end
    
    local success = pcall(function()
        Remotes.HatchEgg:FireServer(stand or CurrentStand, eggName or CurrentEggName)
    end)
    
    if success then
        print("✅ Œuf ouvert sur:", stand or CurrentStand)
        return true
    else
        warn("❌ Erreur lors de l'ouverture")
        return false
    end
end

-- 5. Récupérer le brainrot
local function pickupBrainrot(stand)
    if not Remotes.PickupBrainrot then
        warn("❌ RemoteEvent 'RE/PickupBrainrot' introuvable!")
        return false
    end
    
    local success = pcall(function()
        Remotes.PickupBrainrot:FireServer(stand or CurrentStand)
    end)
    
    if success then
        print("✅ Brainrot récupéré de:", stand or CurrentStand)
        return true
    else
        warn("❌ Erreur lors de la récupération")
        return false
    end
end

-- 6. Placer le brainrot
local function placeBrainrot(stand, brainrotName)
    if not Remotes.PlaceBrainrot then
        warn("❌ RemoteFunction 'RF/PlaceBrainrot' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return Remotes.PlaceBrainrot:InvokeServer(stand or CurrentStand, brainrotName or CurrentEggType)
    end)
    
    if success then
        print("✅ Brainrot placé sur:", stand or CurrentStand)
        return true
    else
        warn("❌ Erreur lors du placement du brainrot:", result)
        return false
    end
end

-- 7. Récupérer les boxes
local function pickupBoxes()
    if not Remotes.PickupBoxes then
        warn("❌ RemoteEvent 'RE/PickupBoxes' introuvable!")
        return false
    end
    
    local success = pcall(function()
        Remotes.PickupBoxes:FireServer()
    end)
    
    if success then
        print("✅ Boxes récupérées")
        return true
    else
        warn("❌ Erreur lors de la récupération des boxes")
        return false
    end
end

-- ====================================
-- CYCLE COMPLET AUTOMATISÉ
-- ====================================
local function fullAutoCycle()
    print("🔄 Démarrage du cycle automatique...")
    
    -- Étape 1: Spawner l'œuf
    if not spawnEgg() then
        warn("⚠️ Échec du spawn, arrêt du cycle")
        return false
    end
    wait(SpawnDelay)
    
    -- Étape 2: Acheter l'œuf
    if not buyEgg(CurrentEggType, 1) then
        warn("⚠️ Échec de l'achat, arrêt du cycle")
        return false
    end
    wait(SpawnDelay)
    
    -- Étape 3: Placer l'œuf
    if not placeEgg(CurrentStand, CurrentEggName) then
        warn("⚠️ Échec du placement, arrêt du cycle")
        return false
    end
    wait(SpawnDelay)
    
    -- Étape 4: Ouvrir l'œuf
    if not hatchEgg(CurrentStand, CurrentEggName) then
        warn("⚠️ Échec de l'ouverture, arrêt du cycle")
        return false
    end
    wait(SpawnDelay * 2) -- Attendre un peu plus pour l'ouverture
    
    -- Étape 5: Récupérer le brainrot
    if not pickupBrainrot(CurrentStand) then
        warn("⚠️ Échec de la récupération du brainrot, arrêt du cycle")
        return false
    end
    wait(SpawnDelay)
    
    -- Étape 6: Placer le brainrot
    if not placeBrainrot(CurrentStand, CurrentEggType) then
        warn("⚠️ Échec du placement du brainrot, arrêt du cycle")
        return false
    end
    wait(SpawnDelay)
    
    -- Étape 7: Récupérer les boxes
    pickupBoxes()
    
    print("✅ Cycle automatique terminé avec succès!")
    return true
end

-- Boucle d'auto farm
task.spawn(function()
    while true do
        if AutoFarmActive then
            local success = fullAutoCycle()
            if not success then
                notify("Auto Farm", "❌ Erreur dans le cycle", 3)
            end
        end
        wait(SpawnDelay)
    end
end)

-- ====================================
-- PAGE 1 - AUTO FARM COMPLET
-- ====================================

UI.Callbacks.Page1.Button1 = function()
    AutoFarmActive = not AutoFarmActive
    
    local status = AutoFarmActive and "ACTIVÉ ✅" or "DÉSACTIVÉ ❌"
    print("[LOGIC] Auto Farm Complet:", status)
    
    notify("Auto Farm Complet", status, 3)
end

UI.Callbacks.Page1.Button2 = function()
    print("[LOGIC] Cycle manuel lancé")
    notify("Cycle Manuel", "Démarrage...", 2)
    
    task.spawn(function()
        local success = fullAutoCycle()
        if success then
            notify("Cycle Manuel", "✅ Terminé avec succès!", 3)
        else
            notify("Cycle Manuel", "❌ Échec du cycle", 3)
        end
    end)
end

UI.Callbacks.Page1.Button3 = function()
    print("[LOGIC] Récupération des boxes")
    pickupBoxes()
    notify("Boxes", "Boxes récupérées!", 2)
end

UI.Callbacks.Page1.Slider = function(value)
    -- Ajuster le délai entre les étapes (0.1 à 5 secondes)
    SpawnDelay = 0.1 + (value / 100) * 4.9
    print("[LOGIC] Délai ajusté à: " .. string.format("%.2f", SpawnDelay) .. "s")
    
    notify("Délai du Cycle", string.format("%.2f secondes", SpawnDelay), 2)
end

-- ====================================
-- PAGE 2 - CONFIGURATION DES ŒUFS
-- ====================================

UI.Callbacks.Page2.Button1 = function()
    -- Changer le type d'œuf
    local eggTypes = {"Gold Tim Cheese", "Lightning Tung Tung Sahur", "Capuchino Assasino"}
    local currentIndex = 1
    
    for i, egg in ipairs(eggTypes) do
        if egg == CurrentEggType then
            currentIndex = i
            break
        end
    end
    
    currentIndex = (currentIndex % #eggTypes) + 1
    CurrentEggType = eggTypes[currentIndex]
    
    print("[LOGIC] Type d'œuf changé:", CurrentEggType)
    notify("Type d'Œuf", CurrentEggType, 3)
end

UI.Callbacks.Page2.Button2 = function()
    -- Acheter un œuf manuellement
    if buyEgg(CurrentEggType, 1) then
        notify("Achat", "✅ Œuf acheté!", 2)
    else
        notify("Achat", "❌ Échec de l'achat", 2)
    end
end

UI.Callbacks.Page2.Button3 = function()
    -- Afficher l'inventaire
    local eggs = getInventoryEggs()
    print("[LOGIC] Œufs dans l'inventaire:", table.concat(eggs, ", "))
    notify("Inventaire", #eggs .. " œufs", 2)
end

UI.Callbacks.Page2.Slider = function(value)
    print("[LOGIC] Page 2 - Slider valeur: " .. value)
    -- Peut être utilisé pour changer le nombre d'œufs à acheter
end

-- ====================================
-- PAGE 3 - CONFIGURATION DES STANDS
-- ====================================

UI.Callbacks.Page3.Button1 = function()
    -- Changer le stand
    local stands = {"Stand1", "Stand2", "Stand3", "Stand4"}
    local currentIndex = 1
    
    for i, stand in ipairs(stands) do
        if stand == CurrentStand then
            currentIndex = i
            break
        end
    end
    
    currentIndex = (currentIndex % #stands) + 1
    CurrentStand = stands[currentIndex]
    
    print("[LOGIC] Stand changé:", CurrentStand)
    notify("Stand", CurrentStand, 3)
end

UI.Callbacks.Page3.Button2 = function()
    print("[LOGIC] Placer un œuf manuellement")
    if placeEgg(CurrentStand, CurrentEggName) then
        notify("Placement", "✅ Œuf placé!", 2)
    else
        notify("Placement", "❌ Échec du placement", 2)
    end
end

UI.Callbacks.Page3.Button3 = function()
    print("[LOGIC] Ouvrir un œuf manuellement")
    if hatchEgg(CurrentStand, CurrentEggName) then
        notify("Ouverture", "✅ Œuf ouvert!", 2)
    else
        notify("Ouverture", "❌ Échec de l'ouverture", 2)
    end
end

UI.Callbacks.Page3.Slider = function(value)
    print("[LOGIC] Page 3 - Slider valeur: " .. value)
end

-- ====================================
-- PAGE 4 - STATISTIQUES & INFOS
-- ====================================

UI.Callbacks.Page4.Button1 = function()
    -- Afficher le cash
    local cash = getCash()
    print("[LOGIC] Cash du joueur:", cash)
    notify("Cash", tostring(cash) .. " 💰", 3)
end

UI.Callbacks.Page4.Button2 = function()
    -- Récupérer tous les brainrots
    print("[LOGIC] Récupération de tous les brainrots")
    for i = 1, 4 do
        pickupBrainrot("Stand" .. i)
        wait(0.1)
    end
    notify("Brainrots", "Tous récupérés!", 2)
end

UI.Callbacks.Page4.Button3 = function()
    print("[LOGIC] Reset de la configuration")
    CurrentEggType = "Gold Tim Cheese"
    CurrentStand = "Stand3"
    CurrentEggName = "Lightning Tung Tung Sahur"
    SpawnDelay = 0.5
    notify("Reset", "Configuration réinitialisée", 2)
end

UI.Callbacks.Page4.Slider = function(value)
    print("[LOGIC] Page 4 - Slider valeur: " .. value)
end

print("============================================")
print("[LOGIC] ✅ LOGIQUE CHARGÉE AVEC SUCCÈS !")
print("[LOGIC] 🎯 Auto Farm Complet configuré")
print("[LOGIC] 📋 PAGE 1 - Auto Farm")
print("[LOGIC]    Button 1: Toggle Auto Farm")
print("[LOGIC]    Button 2: Cycle Manuel")
print("[LOGIC]    Button 3: Récupérer Boxes")
print("[LOGIC]    Slider: Délai entre étapes")
print("[LOGIC] 📋 PAGE 2 - Configuration Œufs")
print("[LOGIC] 📋 PAGE 3 - Configuration Stands")
print("[LOGIC] 📋 PAGE 4 - Statistiques")
print("[LOGIC] 🔥 Prêt à l'emploi !")
print("============================================")