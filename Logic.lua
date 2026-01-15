-- Logic.lua - Logique complète du script Brainrot
-- À charger APRÈS UI.lua

print("[LOGIC] Démarrage du chargement de la logique...")

-- Charger l'UI
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua"))()

print("[LOGIC] UI chargé avec succès")

-- Marquer que la logique est chargée
_G.LogicLoaded = true

-- ====================================
-- SERVICES & RÉFÉRENCES
-- ====================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local Networker = ReplicatedStorage.Shared.Packages.Networker

-- Remotes
local SpawnEggRemote = Networker:FindFirstChild("RF/RequestEggSpawn")
local BuyEggRemote = Networker:FindFirstChild("RF/BuyEgg")
local PlaceEggRemote = Networker:FindFirstChild("RF/PlaceEgg")
local HatchEggRemote = Networker:FindFirstChild("RE/HatchEgg")
local PickupBrainrotRemote = Networker:FindFirstChild("RE/PickupBrainrot")
local PlaceBrainrotRemote = Networker:FindFirstChild("RF/PlaceBrainrot")
local PickupBoxesRemote = Networker:FindFirstChild("RE/PickupBoxes")
local BoxSoldRemote = Networker:FindFirstChild("RE/BoxSold")

-- ====================================
-- FONCTIONS UTILITAIRES
-- ====================================

-- Fonction pour envoyer une notification
local function sendNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

-- Fonction pour obtenir le nom du premier œuf dans l'inventaire
local function getFirstEggInInventory()
    local backpack = LocalPlayer.Backpack
    for _, item in pairs(backpack:GetChildren()) do
        -- Exclure les box (avec GUID) et chercher les œufs
        if not item.Name:match("^{.*}$") then
            return item.Name
        end
    end
    return nil
end

-- Fonction pour obtenir le premier œuf équipé
local function getEquippedEgg()
    local character = LocalPlayer.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and not item.Name:match("^{.*}$") then
                return item.Name
            end
        end
    end
    return nil
end

-- Fonction pour obtenir un œuf (équipé ou inventaire)
local function getAnyEgg()
    return getEquippedEgg() or getFirstEggInInventory()
end

-- Fonction pour obtenir le cash du joueur
local function getPlayerCash()
    if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash") then
        return LocalPlayer.leaderstats.Cash.Value
    end
    return 0
end

-- ====================================
-- ACTIONS PRINCIPALES
-- ====================================

-- 1. Montrer le nouveau brainrot (spawner un œuf)
local function requestEggSpawn()
    if not SpawnEggRemote then
        warn("❌ Remote 'RF/RequestEggSpawn' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return SpawnEggRemote:InvokeServer()
    end)
    
    if success then
        print("✅ Œuf spawné avec succès!")
        sendNotification("Spawn Egg", "Œuf spawné!", 2)
        return true
    else
        warn("❌ Erreur lors du spawn:", result)
        sendNotification("Erreur", "Échec du spawn", 2)
        return false
    end
end

-- 2. Acheter un œuf
local function buyEgg(eggName, quantity)
    eggName = eggName or "Gold Tim Cheese"
    quantity = quantity or 1
    
    if not BuyEggRemote then
        warn("❌ Remote 'RF/BuyEgg' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return BuyEggRemote:InvokeServer(eggName, quantity)
    end)
    
    if success then
        print("✅ Œuf acheté:", eggName)
        sendNotification("Achat", "Œuf acheté: " .. eggName, 2)
        return true
    else
        warn("❌ Erreur lors de l'achat:", result)
        sendNotification("Erreur", "Échec de l'achat", 2)
        return false
    end
end

-- 3. Placer un œuf
local function placeEgg(standName, eggName)
    standName = standName or "Stand3"
    eggName = eggName or getAnyEgg()
    
    if not eggName then
        warn("❌ Aucun œuf trouvé!")
        sendNotification("Erreur", "Aucun œuf disponible", 2)
        return false
    end
    
    if not PlaceEggRemote then
        warn("❌ Remote 'RF/PlaceEgg' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return PlaceEggRemote:InvokeServer(standName, eggName)
    end)
    
    if success then
        print("✅ Œuf placé:", eggName, "sur", standName)
        sendNotification("Placement", "Œuf placé sur " .. standName, 2)
        return true
    else
        warn("❌ Erreur lors du placement:", result)
        sendNotification("Erreur", "Échec du placement", 2)
        return false
    end
end

-- 4. Ouvrir un œuf
local function hatchEgg(standName, eggName)
    standName = standName or "Stand3"
    eggName = eggName or getAnyEgg()
    
    if not eggName then
        warn("❌ Aucun œuf trouvé!")
        sendNotification("Erreur", "Aucun œuf disponible", 2)
        return false
    end
    
    if not HatchEggRemote then
        warn("❌ Remote 'RE/HatchEgg' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        HatchEggRemote:FireServer(standName, eggName)
    end)
    
    if success then
        print("✅ Œuf ouvert:", eggName, "sur", standName)
        sendNotification("Éclosion", "Œuf ouvert!", 2)
        return true
    else
        warn("❌ Erreur lors de l'ouverture:", result)
        sendNotification("Erreur", "Échec de l'ouverture", 2)
        return false
    end
end

-- 5. Récupérer le brainrot
local function pickupBrainrot(standName)
    standName = standName or "Stand3"
    
    if not PickupBrainrotRemote then
        warn("❌ Remote 'RE/PickupBrainrot' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        PickupBrainrotRemote:FireServer(standName)
    end)
    
    if success then
        print("✅ Brainrot récupéré de:", standName)
        sendNotification("Récupération", "Brainrot récupéré!", 2)
        return true
    else
        warn("❌ Erreur lors de la récupération:", result)
        sendNotification("Erreur", "Échec de la récupération", 2)
        return false
    end
end

-- 6. Placer le brainrot
local function placeBrainrot(standName, brainrotName)
    standName = standName or "Stand3"
    brainrotName = brainrotName or "Gold Tim Cheese"
    
    if not PlaceBrainrotRemote then
        warn("❌ Remote 'RF/PlaceBrainrot' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return PlaceBrainrotRemote:InvokeServer(standName, brainrotName)
    end)
    
    if success then
        print("✅ Brainrot placé:", brainrotName, "sur", standName)
        sendNotification("Placement", "Brainrot placé!", 2)
        return true
    else
        warn("❌ Erreur lors du placement:", result)
        sendNotification("Erreur", "Échec du placement", 2)
        return false
    end
end

-- 7. Récupérer les boxes
local function pickupBoxes()
    if not PickupBoxesRemote then
        warn("❌ Remote 'RE/PickupBoxes' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        PickupBoxesRemote:FireServer()
    end)
    
    if success then
        print("✅ Boxes récupérées!")
        sendNotification("Boxes", "Boxes récupérées!", 2)
        return true
    else
        warn("❌ Erreur lors de la récupération:", result)
        sendNotification("Erreur", "Échec récupération boxes", 2)
        return false
    end
end

-- 8. Fonction pour afficher les infos du joueur
local function showPlayerInfo()
    local cash = getPlayerCash()
    local egg = getAnyEgg()
    
    print("💰 Cash:", cash)
    print("🥚 Œuf disponible:", egg or "Aucun")
    
    sendNotification("Info Joueur", "Cash: " .. cash .. "\nŒuf: " .. (egg or "Aucun"), 5)
end

-- ====================================
-- VARIABLES AUTO FARM
-- ====================================
local AutoFarmActive = false
local AutoFarmDelay = 1
local CurrentStand = "Stand3"
local CurrentEgg = "Gold Tim Cheese"

-- Cycle complet d'auto farm
local function autoFarmCycle()
    print("🔄 Début du cycle auto farm...")
    
    -- 1. Acheter un œuf
    if buyEgg(CurrentEgg, 1) then
        wait(0.5)
        
        -- 2. Placer l'œuf
        if placeEgg(CurrentStand, CurrentEgg) then
            wait(2) -- Attendre que l'œuf soit prêt
            
            -- 3. Ouvrir l'œuf
            if hatchEgg(CurrentStand, CurrentEgg) then
                wait(1)
                
                -- 4. Récupérer le brainrot
                pickupBrainrot(CurrentStand)
                wait(0.5)
                
                -- 5. Récupérer les boxes
                pickupBoxes()
            end
        end
    end
    
    print("✅ Cycle auto farm terminé!")
end

-- Boucle d'auto farm
task.spawn(function()
    while true do
        if AutoFarmActive then
            autoFarmCycle()
        end
        wait(AutoFarmDelay)
    end
end)

-- ====================================
-- PAGE 1 - ACTIONS BASIQUES
-- ====================================

UI.Callbacks.Page1.Button1 = function()
    print("[LOGIC] Spawn Egg activé!")
    requestEggSpawn()
end

UI.Callbacks.Page1.Button2 = function()
    print("[LOGIC] Acheter Œuf activé!")
    buyEgg(CurrentEgg, 1)
end

UI.Callbacks.Page1.Button3 = function()
    print("[LOGIC] Placer Œuf activé!")
    placeEgg(CurrentStand, nil)
end

UI.Callbacks.Page1.Slider = function(value)
    -- Ajuster le stand (Stand1 à Stand10)
    local standNumber = math.floor(1 + (value / 100) * 9)
    CurrentStand = "Stand" .. standNumber
    print("[LOGIC] Stand sélectionné: " .. CurrentStand)
    sendNotification("Stand", "Stand" .. standNumber, 2)
end

-- ====================================
-- PAGE 2 - GESTION BRAINROT
-- ====================================

UI.Callbacks.Page2.Button1 = function()
    print("[LOGIC] Ouvrir Œuf activé!")
    hatchEgg(CurrentStand, nil)
end

UI.Callbacks.Page2.Button2 = function()
    print("[LOGIC] Récupérer Brainrot activé!")
    pickupBrainrot(CurrentStand)
end

UI.Callbacks.Page2.Button3 = function()
    print("[LOGIC] Placer Brainrot activé!")
    placeBrainrot(CurrentStand, CurrentEgg)
end

UI.Callbacks.Page2.Slider = function(value)
    print("[LOGIC] Page 2 - Slider valeur: " .. value)
end

-- ====================================
-- PAGE 3 - AUTO FARM
-- ====================================

UI.Callbacks.Page3.Button1 = function()
    AutoFarmActive = not AutoFarmActive
    
    local status = AutoFarmActive and "ACTIVÉ ✅" or "DÉSACTIVÉ ❌"
    print("[LOGIC] Auto Farm:", status)
    
    sendNotification("Auto Farm", status, 3)
end

UI.Callbacks.Page3.Button2 = function()
    print("[LOGIC] Cycle Manuel activé!")
    task.spawn(autoFarmCycle)
end

UI.Callbacks.Page3.Button3 = function()
    print("[LOGIC] Récupérer Boxes activé!")
    pickupBoxes()
end

UI.Callbacks.Page3.Slider = function(value)
    -- Ajuster le délai d'auto farm (0.5 à 10 secondes)
    AutoFarmDelay = 0.5 + (value / 100) * 9.5
    print("[LOGIC] Délai auto farm: " .. string.format("%.1f", AutoFarmDelay) .. "s")
    sendNotification("Délai", string.format("%.1fs", AutoFarmDelay), 2)
end

-- ====================================
-- PAGE 4 - UTILITAIRES
-- ====================================

UI.Callbacks.Page4.Button1 = function()
    print("[LOGIC] Afficher Info Joueur activé!")
    showPlayerInfo()
end

UI.Callbacks.Page4.Button2 = function()
    print("[LOGIC] Liste Inventaire activé!")
    
    local backpack = LocalPlayer.Backpack
    print("📦 === INVENTAIRE ===")
    for _, item in pairs(backpack:GetChildren()) do
        print("  - " .. item.Name)
    end
    print("📦 ===================")
    
    sendNotification("Inventaire", "Liste dans la console (F9)", 3)
end

UI.Callbacks.Page4.Button3 = function()
    print("[LOGIC] Changer Œuf activé!")
    
    -- Cycle entre différents types d'œufs
    local eggTypes = {"Gold Tim Cheese", "Capuchino Assasino"}
    local currentIndex = 1
    
    for i, egg in ipairs(eggTypes) do
        if egg == CurrentEgg then
            currentIndex = i
            break
        end
    end
    
    currentIndex = (currentIndex % #eggTypes) + 1
    CurrentEgg = eggTypes[currentIndex]
    
    print("[LOGIC] Œuf sélectionné: " .. CurrentEgg)
    sendNotification("Œuf", CurrentEgg, 2)
end

UI.Callbacks.Page4.Slider = function(value)
    print("[LOGIC] Page 4 - Slider valeur: " .. value)
end

-- ====================================
-- INFORMATIONS DE DÉMARRAGE
-- ====================================
print("============================================")
print("[LOGIC] ✅ LOGIQUE CHARGÉE AVEC SUCCÈS !")
print("============================================")
print("[PAGE 1] 🥚 ACTIONS BASIQUES")
print("  Button 1: Spawn Egg")
print("  Button 2: Acheter Œuf")
print("  Button 3: Placer Œuf")
print("  Slider: Sélection Stand (1-10)")
print("--------------------------------------------")
print("[PAGE 2] 🧠 GESTION BRAINROT")
print("  Button 1: Ouvrir Œuf")
print("  Button 2: Récupérer Brainrot")
print("  Button 3: Placer Brainrot")
print("--------------------------------------------")
print("[PAGE 3] 🤖 AUTO FARM")
print("  Button 1: Toggle Auto Farm")
print("  Button 2: Cycle Manuel")
print("  Button 3: Récupérer Boxes")
print("  Slider: Délai Auto Farm")
print("--------------------------------------------")
print("[PAGE 4] 🛠️ UTILITAIRES")
print("  Button 1: Info Joueur")
print("  Button 2: Liste Inventaire")
print("  Button 3: Changer Type Œuf")
print("============================================")
print("[LOGIC] 🔥 Prêt à l'emploi !")
print("============================================")