-- Logic.lua - Script complet avec auto farm
-- À charger APRÈS UI.lua

print("[LOGIC] Démarrage du chargement de la logique...")

-- Charger l'UI
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua"))()

print("[LOGIC] UI chargé avec succès")

-- Marquer que la logique est chargée
_G.LogicLoaded = true

-- ====================================
-- SERVICES ET RÉFÉRENCES
-- ====================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Networker = ReplicatedStorage.Shared.Packages.Networker

-- Remote Events
local SpawnEggRemote = Networker:FindFirstChild("RF/RequestEggSpawn")
local BuyEggRemote = Networker:FindFirstChild("RF/BuyEgg")
local PlaceEggRemote = Networker:FindFirstChild("RF/PlaceEgg")

-- Paths
local EggsPath = Workspace.CoreObjects.Eggs
local StandsPath = Workspace.CoreObjects.Plots.Plot1.Stands

-- ====================================
-- VARIABLES GLOBALES
-- ====================================
local AutoSpawnActive = false
local AutoBuyActive = false
local AutoPlaceActive = false
local SpawnDelay = 0.5

-- ====================================
-- FONCTIONS UTILITAIRES
-- ====================================

-- Fonction pour obtenir le joueur dans workspace
local function getPlayerInWorkspace()
    return Workspace:FindFirstChild(LocalPlayer.Name)
end

-- Fonction pour vérifier ce que le joueur a en main
local function getItemInHand()
    local character = getPlayerInWorkspace()
    if not character then return nil end
    
    -- Chercher un outil de type "Egg" ou "Brainrot"
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            if item.Name:find("Egg") then
                return "Egg", item.Name
            elseif item.Name:find("Brainrot") then
                return "Brainrot", item.Name
            end
        end
    end
    
    return nil
end

-- Fonction pour obtenir les infos de l'œuf sur le convoyeur
local function getEggInfo()
    local eggs = EggsPath:GetChildren()
    
    for _, eggFolder in pairs(eggs) do
        if eggFolder:IsA("Folder") or eggFolder:IsA("Model") then
            -- Chercher le BillboardAttachment
            local eggModel = eggFolder:FindFirstChild(eggFolder.Name)
            if eggModel then
                local billboard = eggModel:FindFirstChild("BillboardAttachment")
                if billboard then
                    local eggBillboard = billboard:FindFirstChild("EggBillboard")
                    if eggBillboard then
                        local frame = eggBillboard:FindFirstChild("Frame")
                        if frame then
                            local name = frame:FindFirstChild("EggName")
                            local price = frame:FindFirstChild("Price")
                            local rarity = frame:FindFirstChild("rarity")
                            
                            return {
                                Name = name and name.Text or "Unknown",
                                Price = price and price.Text or "0",
                                Rarity = rarity and rarity.Text or "Unknown",
                                EggNumber = eggFolder.Name
                            }
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Fonction pour trouver un stand libre
local function findFreeStand()
    for i = 1, 50 do
        local stand = StandsPath:FindFirstChild("Stand" .. i)
        if stand then
            local occupied = stand:GetAttribute("occupied")
            if not occupied or occupied == false then
                return "Stand" .. i, stand
            end
        end
    end
    return nil
end

-- ====================================
-- FONCTIONS PRINCIPALES
-- ====================================

-- Fonction pour spawner un œuf
local function spawnEgg()
    if not SpawnEggRemote then
        warn("❌ RemoteFunction 'RF/RequestEggSpawn' introuvable!")
        return false
    end
    
    local success, result = pcall(function()
        return SpawnEggRemote:InvokeServer()
    end)
    
    if success then
        print("✅ Œuf spawné avec succès!")
        return true
    else
        warn("❌ Erreur lors du spawn:", result)
        return false
    end
end

-- Fonction pour acheter l'œuf sur le convoyeur
local function buyEgg()
    if not BuyEggRemote then
        warn("❌ RemoteFunction 'RF/BuyEgg' introuvable!")
        return false
    end
    
    local eggInfo = getEggInfo()
    if not eggInfo then
        warn("❌ Aucun œuf trouvé sur le convoyeur!")
        return false
    end
    
    local success, result = pcall(function()
        return BuyEggRemote:InvokeServer(eggInfo.Name, 1)
    end)
    
    if success then
        print("✅ Œuf acheté:", eggInfo.Name)
        return true
    else
        warn("❌ Erreur lors de l'achat:", result)
        return false
    end
end

-- Fonction pour placer l'œuf sur un stand
local function placeEgg()
    if not PlaceEggRemote then
        warn("❌ RemoteFunction 'RF/PlaceEgg' introuvable!")
        return false
    end
    
    -- Vérifier ce que le joueur a en main
    local itemType, itemName = getItemInHand()
    if itemType ~= "Egg" then
        warn("❌ Aucun œuf en main!")
        return false
    end
    
    -- Trouver un stand libre
    local standName, stand = findFreeStand()
    if not standName then
        warn("❌ Aucun stand libre disponible!")
        return false
    end
    
    local success, result = pcall(function()
        return PlaceEggRemote:InvokeServer(standName, itemName)
    end)
    
    if success then
        print("✅ Œuf placé sur:", standName)
        return true
    else
        warn("❌ Erreur lors du placement:", result)
        return false
    end
end

-- ====================================
-- BOUCLE AUTO FARM COMPLÈTE
-- ====================================
task.spawn(function()
    while true do
        if AutoSpawnActive then
            -- 1. Spawner un œuf
            spawnEgg()
            wait(0.5) -- Attendre que l'œuf apparaisse
            
            -- 2. Acheter l'œuf si auto buy est activé
            if AutoBuyActive then
                buyEgg()
                wait(0.5) -- Attendre que l'œuf soit en main
                
                -- 3. Placer l'œuf si auto place est activé
                if AutoPlaceActive then
                    placeEgg()
                    wait(0.2)
                end
            end
        end
        wait(SpawnDelay)
    end
end)

-- ====================================
-- PAGE 1 - AUTO SPAWN & AUTO BUY
-- ====================================

UI.Callbacks.Page1.Button1 = function()
    AutoSpawnActive = not AutoSpawnActive
    
    local status = AutoSpawnActive and "ACTIVÉ ✅" or "DÉSACTIVÉ ❌"
    print("[LOGIC] Auto Spawn Egg:", status)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Spawn Egg",
        Text = status,
        Duration = 3
    })
end

UI.Callbacks.Page1.Button2 = function()
    AutoBuyActive = not AutoBuyActive
    
    local status = AutoBuyActive and "ACTIVÉ ✅" or "DÉSACTIVÉ ❌"
    print("[LOGIC] Auto Buy Egg:", status)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Buy Egg",
        Text = status,
        Duration = 3
    })
end

UI.Callbacks.Page1.Button3 = function()
    AutoPlaceActive = not AutoPlaceActive
    
    local status = AutoPlaceActive and "ACTIVÉ ✅" or "DÉSACTIVÉ ❌"
    print("[LOGIC] Auto Place Egg:", status)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Place Egg",
        Text = status,
        Duration = 3
    })
end

UI.Callbacks.Page1.Slider = function(value)
    -- Ajuster le délai entre les spawns (0.1 à 5 secondes)
    SpawnDelay = 0.1 + (value / 100) * 4.9
    print("[LOGIC] Délai de spawn ajusté à : " .. string.format("%.2f", SpawnDelay) .. "s")
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Délai Spawn",
        Text = string.format("%.2f secondes", SpawnDelay),
        Duration = 2
    })
end

-- ====================================
-- PAGE 2 - ACTIONS MANUELLES
-- ====================================

UI.Callbacks.Page2.Button1 = function()
    print("[LOGIC] Spawn Manuel")
    spawnEgg()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Spawn Manuel",
        Text = "Œuf spawné!",
        Duration = 2
    })
end

UI.Callbacks.Page2.Button2 = function()
    print("[LOGIC] Achat Manuel")
    buyEgg()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Achat Manuel",
        Text = "Œuf acheté!",
        Duration = 2
    })
end

UI.Callbacks.Page2.Button3 = function()
    print("[LOGIC] Placement Manuel")
    placeEgg()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Placement Manuel",
        Text = "Œuf placé!",
        Duration = 2
    })
end

UI.Callbacks.Page2.Slider = function(value)
    print("[LOGIC] Page 2 - Slider valeur: " .. value)
end

-- ====================================
-- PAGE 3 - INFORMATIONS
-- ====================================

UI.Callbacks.Page3.Button1 = function()
    print("[LOGIC] Afficher infos œuf")
    
    local eggInfo = getEggInfo()
    if eggInfo then
        local message = string.format(
            "Nom: %s\nPrix: %s\nRareté: %s",
            eggInfo.Name,
            eggInfo.Price,
            eggInfo.Rarity
        )
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Info Œuf",
            Text = message,
            Duration = 5
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Info Œuf",
            Text = "Aucun œuf sur le convoyeur",
            Duration = 3
        })
    end
end

UI.Callbacks.Page3.Button2 = function()
    print("[LOGIC] Vérifier stands libres")
    
    local freeCount = 0
    for i = 1, 50 do
        local stand = StandsPath:FindFirstChild("Stand" .. i)
        if stand then
            local occupied = stand:GetAttribute("occupied")
            if not occupied or occupied == false then
                freeCount = freeCount + 1
            end
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Stands Libres",
        Text = freeCount .. " / 50 stands disponibles",
        Duration = 3
    })
end

UI.Callbacks.Page3.Button3 = function()
    print("[LOGIC] Vérifier item en main")
    
    local itemType, itemName = getItemInHand()
    local message = itemType and (itemType .. ": " .. itemName) or "Rien en main"
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Item en Main",
        Text = message,
        Duration = 3
    })
end

UI.Callbacks.Page3.Slider = function(value)
    print("[LOGIC] Page 3 - Slider valeur: " .. value)
end

-- ====================================
-- PAGE 4 - CONFIGURATION
-- ====================================

UI.Callbacks.Page4.Button1 = function()
    print("[LOGIC] Page 4 - Bouton 1 activé !")
end

UI.Callbacks.Page4.Button2 = function()
    print("[LOGIC] Page 4 - Bouton 2 activé !")
end

UI.Callbacks.Page4.Button3 = function()
    print("[LOGIC] Page 4 - Bouton 3 activé !")
end

UI.Callbacks.Page4.Slider = function(value)
    print("[LOGIC] Page 4 - Slider valeur: " .. value)
end

print("============================================")
print("[LOGIC] ✅ LOGIQUE CHARGÉE AVEC SUCCÈS !")
print("[LOGIC] 🎯 Auto Farm Complet Configuré")
print("[LOGIC] PAGE 1 - AUTO FARM:")
print("[LOGIC]   📋 Button 1: Toggle Auto Spawn")
print("[LOGIC]   📋 Button 2: Toggle Auto Buy")
print("[LOGIC]   📋 Button 3: Toggle Auto Place")
print("[LOGIC]   📋 Slider: Délai entre spawns")
print("[LOGIC] PAGE 2 - MANUEL:")
print("[LOGIC]   📋 Button 1: Spawn Manuel")
print("[LOGIC]   📋 Button 2: Buy Manuel")
print("[LOGIC]   📋 Button 3: Place Manuel")
print("[LOGIC] PAGE 3 - INFOS:")
print("[LOGIC]   📋 Button 1: Info Œuf")
print("[LOGIC]   📋 Button 2: Stands Libres")
print("[LOGIC]   📋 Button 3: Item en Main")
print("[LOGIC] 🔥 Prêt à l'emploi !")
print("============================================")