--[[
    LOGIC.LUA - Logique métier pure
    Définit les actions appelées par l'UI
    AUCUNE CRÉATION D'UI ICI
]]

print("[LOGIC] Initialisation de la logique...")

-- Attendre que l'UI soit prêt
local maxWait = 100
local waited = 0
while not getgenv().UI and waited < maxWait do
    task.wait(0.1)
    waited = waited + 1
end

if not getgenv().UI then
    error("[LOGIC] getgenv().UI n'existe pas, impossible de continuer")
end

print("[LOGIC] ✓ Interface détectée, connexion des actions...")

-- ════════════════════════════════════════════
-- PAGE 1 - ACTIONS
-- ════════════════════════════════════════════
getgenv().UI.Actions.Page1_Button1 = function()
    print("[LOGIC] 🔘 Page1_Button1 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page1_Button2 = function()
    print("[LOGIC] 🔘 Page1_Button2 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page1_Slider = function(value)
    print("[LOGIC] 🎚️ Page1_Slider changé : " .. tostring(value))
    -- Votre logique ici
end

-- ════════════════════════════════════════════
-- PAGE 2 - ACTIONS
-- ════════════════════════════════════════════
getgenv().UI.Actions.Page2_Button1 = function()
    print("[LOGIC] 🔘 Page2_Button1 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page2_Button2 = function()
    print("[LOGIC] 🔘 Page2_Button2 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page2_Slider = function(value)
    print("[LOGIC] 🎚️ Page2_Slider changé : " .. tostring(value))
    -- Votre logique ici
end

-- ════════════════════════════════════════════
-- PAGE 3 - ACTIONS
-- ════════════════════════════════════════════
getgenv().UI.Actions.Page3_Button1 = function()
    print("[LOGIC] 🔘 Page3_Button1 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page3_Button2 = function()
    print("[LOGIC] 🔘 Page3_Button2 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page3_Slider = function(value)
    print("[LOGIC] 🎚️ Page3_Slider changé : " .. tostring(value))
    -- Votre logique ici
end

-- ════════════════════════════════════════════
-- PAGE 4 - ACTIONS
-- ════════════════════════════════════════════
getgenv().UI.Actions.Page4_Button1 = function()
    print("[LOGIC] 🔘 Page4_Button1 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page4_Button2 = function()
    print("[LOGIC] 🔘 Page4_Button2 pressé")
    -- Votre logique ici
end

getgenv().UI.Actions.Page4_Slider = function(value)
    print("[LOGIC] 🎚️ Page4_Slider changé : " .. tostring(value))
    -- Votre logique ici
end

print("[LOGIC] ✓ 12 actions connectées avec succès")
print("[LOGIC] Système opérationnel !")
```

---

## 📋 **Utilisation**

1. **Hébergez** `ui.lua` et `logic.lua` sur un service (GitHub Raw, Pastebin, etc.)
2. **Modifiez** les URLs dans `main.lua` (lignes 14-15)
3. **Exécutez** `main.lua` dans votre executor

## ✅ **Avantages de cette architecture**

- ✔️ **Séparation totale** UI/Logic
- ✔️ **Maintenance facile** : modifier la logique sans toucher l'UI
- ✔️ **Réutilisable** : changer l'UI (Rayfield → autre) sans toucher logic.lua
- ✔️ **Compatible executors** Android/PC
- ✔️ **Évolutif** : ajouter des pages/actions facilement

## 🎯 **Console attendue**
```
[MAIN] Jeu chargé, initialisation du système...
[MAIN] Chargement de UI...
[UI] Initialisation de l'interface...
[UI] Fenêtre Rayfield créée
[UI] ✓ 4 pages créées (12 actions configurées)
[MAIN] ✓ UI chargé avec succès
[MAIN] ✓ Interface utilisateur prête
[MAIN] Chargement de LOGIC...
[LOGIC] Initialisation de la logique...
[LOGIC] ✓ Interface détectée, connexion des actions...
[LOGIC] ✓ 12 actions connectées avec succès
[MAIN] ✓ LOGIC chargé avec succès
[MAIN] ════════════════════════════════════
[MAIN] Système opérationnel !
[MAIN] ════════════════════════════════════