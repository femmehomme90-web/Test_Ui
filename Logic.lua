-- Logic.lua - Ta logique de script
-- À charger APRÈS UI.lua

-- Charger l'UI (remplace le chemin par ton vrai chemin ou utilise loadstring)
local UI = loadfile("UI.lua")() -- ou utilise ton système de chargement Codex

-- ====================================
-- PAGE 1 - CONFIGURATION
-- ====================================

UI.Callbacks.Page1.Button1 = function()
    print("Page 1 - Bouton 1 activé !")
    -- Ta logique ici
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Button 1",
        Text = "Page 1 activée !",
        Duration = 3
    })
end

UI.Callbacks.Page1.Button2 = function()
    print("Page 1 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page1.Button3 = function()
    print("Page 1 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page1.Slider = function(value)
    print("Page 1 - Slider valeur: " .. value)
    -- Ta logique avec la valeur du slider
    -- Exemple: modifier la vitesse du joueur
    -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 + value
end

-- ====================================
-- PAGE 2 - CONFIGURATION
-- ====================================

UI.Callbacks.Page2.Button1 = function()
    print("Page 2 - Bouton 1 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page2.Button2 = function()
    print("Page 2 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page2.Button3 = function()
    print("Page 2 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page2.Slider = function(value)
    print("Page 2 - Slider valeur: " .. value)
    -- Ta logique ici
end

-- ====================================
-- PAGE 3 - CONFIGURATION
-- ====================================

UI.Callbacks.Page3.Button1 = function()
    print("Page 3 - Bouton 1 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page3.Button2 = function()
    print("Page 3 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page3.Button3 = function()
    print("Page 3 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page3.Slider = function(value)
    print("Page 3 - Slider valeur: " .. value)
    -- Ta logique ici
end

-- ====================================
-- PAGE 4 - CONFIGURATION
-- ====================================

UI.Callbacks.Page4.Button1 = function()
    print("Page 4 - Bouton 1 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page4.Button2 = function()
    print("Page 4 - Bouton 2 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page4.Button3 = function()
    print("Page 4 - Bouton 3 activé !")
    -- Ta logique ici
end

UI.Callbacks.Page4.Slider = function(value)
    print("Page 4 - Slider valeur: " .. value)
    -- Ta logique ici
end

print("Logique chargée avec succès !")

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