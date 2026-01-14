--[[
    MAIN.LUA - Orchestrateur principal
    Charge ui.lua puis logic.lua en cascade
    Compatible avec les executors Roblox (PC/Android)
]]

-- Attendre que le jeu soit complètement chargé
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("[MAIN] Jeu chargé, initialisation du système...")

-- Configuration des URLs des scripts
local SCRIPTS = {
    UI = "https://github.com/femmehomme90-web/Test_Ui/raw/refs/heads/main/Ui.lua",      -- Remplacer par votre URL
    LOGIC = "https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua" -- Remplacer par votre URL
}

-- Fonction de chargement sécurisé
local function loadScript(name, url)
    print("[MAIN] Chargement de " .. name .. "...")
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("[MAIN] ✓ " .. name .. " chargé avec succès")
        return true
    else
        warn("[MAIN] ✗ Erreur lors du chargement de " .. name .. ": " .. tostring(result))
        return false
    end
end

-- Étape 1 : Charger l'interface utilisateur
if not loadScript("UI", SCRIPTS.UI) then
    error("[MAIN] Impossible de continuer sans l'interface")
end

-- Étape 2 : Attendre que l'UI soit prêt
local maxWait = 100 -- 10 secondes max
local waited = 0
while not getgenv().UI and waited < maxWait do
    task.wait(0.1)
    waited = waited + 1
end

if not getgenv().UI then
    error("[MAIN] Timeout : l'UI n'a pas initialisé getgenv().UI")
end

print("[MAIN] ✓ Interface utilisateur prête")

-- Étape 3 : Charger la logique métier
if not loadScript("LOGIC", SCRIPTS.LOGIC) then
    warn("[MAIN] La logique n'a pas pu être chargée, l'UI restera non-fonctionnelle")
end

print("[MAIN] ════════════════════════════════════")
print("[MAIN] Système opérationnel !")
print("[MAIN] UI et Logique connectées")
print("[MAIN] ════════════════════════════════════")