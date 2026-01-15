-- Logic.lua - Ta logique de script
-- À charger APRÈS UI.lua

print("[LOGIC] Démarrage du chargement de la logique...")

-- Charger l'UI
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua"))()

print("[LOGIC] UI chargé avec succès")

-- Marquer que la logique est chargée
_G.LogicLoaded = true

-- ====================================
-- VARIABLES GLOBALES AUTO SPAWN
-- ====================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = ReplicatedStorage.Shared.Packages.Networker
local SpawnEggRemote = Networker:FindFirstChild("RF/RequestEggSpawn")

local AutoSpawnActive = false
local SpawnDelay = 0.5

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

-- Boucle d'auto spawn
task.spawn(function()
    while true do
        if AutoSpawnActive then
            spawnEgg()
        end
        wait(SpawnDelay)
    end
end)

-- ====================================
-- PAGE 1 - AUTO SPAWN EGG
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
    print("[LOGIC] Page 1 - Bouton 2 activé !")
    -- Spawn manuel d'un œuf
    spawnEgg()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Spawn Manuel",
        Text = "Œuf spawné manuellement !",
        Duration = 2
    })
end

UI.Callbacks.Page1.Button3 = function()
    print("[LOGIC] Page 1 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page1.Slider = function(value)
    -- Ajuster le délai entre les spawns (0.1 à 5 secondes)
    SpawnDelay = 0.1 + (value / 100) * 4.9
    print("[LOGIC] Délai de spawn ajusté à: " .. string.format("%.2f", SpawnDelay) .. "s")
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Délai Spawn",
        Text = string.format("%.2f secondes", SpawnDelay),
        Duration = 2
    })
end

-- ====================================
-- PAGE 2 - CONFIGURATION
-- ====================================

UI.Callbacks.Page2.Button1 = function()
    print("[LOGIC] Page 2 - Bouton 1 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page2.Button2 = function()
    print("[LOGIC] Page 2 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page2.Button3 = function()
    print("[LOGIC] Page 2 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page2.Slider = function(value)
    print("[LOGIC] Page 2 - Slider valeur: " .. value)
    -- Ta logique ici
end

-- ====================================
-- PAGE 3 - CONFIGURATION
-- ====================================

UI.Callbacks.Page3.Button1 = function()
    print("[LOGIC] Page 3 - Bouton 1 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page3.Button2 = function()
    print("[LOGIC] Page 3 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page3.Button3 = function()
    print("[LOGIC] Page 3 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page3.Slider = function(value)
    print("[LOGIC] Page 3 - Slider valeur: " .. value)
    -- Ta logique ici
end

-- ====================================
-- PAGE 4 - CONFIGURATION
-- ====================================

UI.Callbacks.Page4.Button1 = function()
    print("[LOGIC] Page 4 - Bouton 1 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page4.Button2 = function()
    print("[LOGIC] Page 4 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page4.Button3 = function()
    print("[LOGIC] Page 4 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page4.Slider = function(value)
    print("[LOGIC] Page 4 - Slider valeur: " .. value)
    -- Ta logique ici
end

print("============================================")
print("[LOGIC] ✅ LOGIQUE CHARGÉE AVEC SUCCÈS !")
print("[LOGIC] 🎯 Auto Spawn Egg configuré sur Page 1")
print("[LOGIC] 📋 Button 1: Toggle Auto Spawn")
print("[LOGIC] 📋 Button 2: Spawn Manuel")
print("[LOGIC] 📋 Slider: Délai entre spawns")
print("[LOGIC] 🔥 Prêt à l'emploi !")
print("============================================")