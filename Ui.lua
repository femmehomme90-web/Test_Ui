--[[
    UI.LUA - Interface utilisateur avec Rayfield
    Crée 4 pages avec 2 boutons + 1 slider chacune
    AUCUNE LOGIQUE MÉTIER ICI
]]

print("[UI] Initialisation de l'interface...")

-- Créer l'espace global pour l'UI
getgenv().UI = {
    Actions = {},  -- Sera rempli par logic.lua
    Window = nil,
    Tabs = {}
}

-- Charger Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Créer la fenêtre principale
getgenv().UI.Window = Rayfield:CreateWindow({
    Name = "Script Executor Template",
    LoadingTitle = "Chargement du système...",
    LoadingSubtitle = "by Architecture Pattern",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

print("[UI] Fenêtre Rayfield créée")

-- Helper pour exécuter une action
local function executeAction(actionName)
    if getgenv().UI.Actions[actionName] then
        getgenv().UI.Actions[actionName]()
    else
        warn("[UI] Action non définie : " .. actionName)
    end
end

-- ════════════════════════════════════════════
-- PAGE 1
-- ════════════════════════════════════════════
local Tab1 = getgenv().UI.Window:CreateTab("Page 1", 4483362458)
getgenv().UI.Tabs.Page1 = Tab1

Tab1:CreateButton({
    Name = "Bouton 1 - Page 1",
    Callback = function()
        executeAction("Page1_Button1")
    end,
})

Tab1:CreateButton({
    Name = "Bouton 2 - Page 1",
    Callback = function()
        executeAction("Page1_Button2")
    end,
})

Tab1:CreateSlider({
    Name = "Slider Page 1",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "Page1Slider",
    Callback = function(value)
        if getgenv().UI.Actions.Page1_Slider then
            getgenv().UI.Actions.Page1_Slider(value)
        end
    end,
})

-- ════════════════════════════════════════════
-- PAGE 2
-- ════════════════════════════════════════════
local Tab2 = getgenv().UI.Window:CreateTab("Page 2", 4483362458)
getgenv().UI.Tabs.Page2 = Tab2

Tab2:CreateButton({
    Name = "Bouton 1 - Page 2",
    Callback = function()
        executeAction("Page2_Button1")
    end,
})

Tab2:CreateButton({
    Name = "Bouton 2 - Page 2",
    Callback = function()
        executeAction("Page2_Button2")
    end,
})

Tab2:CreateSlider({
    Name = "Slider Page 2",
    Range = {0, 200},
    Increment = 5,
    Suffix = " unités",
    CurrentValue = 100,
    Flag = "Page2Slider",
    Callback = function(value)
        if getgenv().UI.Actions.Page2_Slider then
            getgenv().UI.Actions.Page2_Slider(value)
        end
    end,
})

-- ════════════════════════════════════════════
-- PAGE 3
-- ════════════════════════════════════════════
local Tab3 = getgenv().UI.Window:CreateTab("Page 3", 4483362458)
getgenv().UI.Tabs.Page3 = Tab3

Tab3:CreateButton({
    Name = "Bouton 1 - Page 3",
    Callback = function()
        executeAction("Page3_Button1")
    end,
})

Tab3:CreateButton({
    Name = "Bouton 2 - Page 3",
    Callback = function()
        executeAction("Page3_Button2")
    end,
})

Tab3:CreateSlider({
    Name = "Slider Page 3",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 5,
    Flag = "Page3Slider",
    Callback = function(value)
        if getgenv().UI.Actions.Page3_Slider then
            getgenv().UI.Actions.Page3_Slider(value)
        end
    end,
})

-- ════════════════════════════════════════════
-- PAGE 4
-- ════════════════════════════════════════════
local Tab4 = getgenv().UI.Window:CreateTab("Page 4", 4483362458)
getgenv().UI.Tabs.Page4 = Tab4

Tab4:CreateButton({
    Name = "Bouton 1 - Page 4",
    Callback = function()
        executeAction("Page4_Button1")
    end,
})

Tab4:CreateButton({
    Name = "Bouton 2 - Page 4",
    Callback = function()
        executeAction("Page4_Button2")
    end,
})

Tab4:CreateSlider({
    Name = "Slider Page 4",
    Range = {-50, 50},
    Increment = 10,
    Suffix = " points",
    CurrentValue = 0,
    Flag = "Page4Slider",
    Callback = function(value)
        if getgenv().UI.Actions.Page4_Slider then
            getgenv().UI.Actions.Page4_Slider(value)
        end
    end,
})

print("[UI] ✓ 4 pages créées (12 actions configurées)")
print("[UI] En attente de la logique métier...")