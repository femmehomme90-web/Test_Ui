-- Logic.lua - Ta logique de script
-- À charger APRÈS UI.lua

print("[LOGIC] Démarrage du chargement de la logique...")

-- Charger l'UI (remplace le chemin par ton vrai chemin ou utilise loadstring)
loadstring(game:HttpGet('loadstring(game:HttpGet('https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua')'))()

print("[LOGIC] UI chargé avec succès")

-- Marquer que la logique est chargée
_G.LogicLoaded = true

-- ====================================
-- PAGE 1 - CONFIGURATION
-- ====================================

UI.Callbacks.Page1.Button1 = function()
    print("[LOGIC] Page 1 - Bouton 1 activé !")
    -- Ta logique ici
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Button 1",
        Text = "Page 1 activée !",
        Duration = 3
    })
end

UI.Callbacks.Page1.Button2 = function()
    print("[LOGIC] Page 1 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page1.Button3 = function()
    print("[LOGIC] Page 1 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page1.Slider = function(value)
    print("[LOGIC] Page 1 - Slider valeur: " .. value)
    -- Ta logique avec la valeur du slider
    -- Exemple: modifier la vitesse du joueur
    -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 + value
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
print("[LOGIC] 🎯 Tous les callbacks sont configurés")
print("[LOGIC] 🔥 Prêt à l'emploi !")
print("============================================")

-- ====================================
-- EXEMPLE D'UTILISATION AVANCÉE
-- ====================================

--[[
-- Tu peux aussi créer des fonctions réutilisables :

local function teleportPlayer(x, y, z)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

UI.Callbacks.Page1.Button1 = function()
    teleportPlayer(0, 50, 0)
end

-- Ou stocker des valeurs de slider :
local sliderValues = {}

UI.Callbacks.Page1.Slider = function(value)
    sliderValues.page1 = value
    print("Valeur stockée: " .. sliderValues.page1)
end
]]
