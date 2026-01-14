-- Variables locales nécessaires
local config = getfenv().gui_config or nil
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nfpw/XXSCRIPT/refs/heads/main/Library/Module.lua"))()

-- Création de la fenêtre principale
local window = library:CreateWindow(config, gethui())
local window_name = library:SetWindowName("Mon Interface Script | " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

-- Création des onglets
local tabs = {
    page1 = window:CreateTab("Page 1"),
    page2 = window:CreateTab("Page 2"),
    settings = window:CreateTab("Paramètres")
}

-- Création des sections
local sections = {
    -- Page 1
    boutons_page1 = tabs.page1:CreateSection("Boutons", "left"),
    sliders_page1 = tabs.page1:CreateSection("Sliders", "right"),
    
    -- Page 2
    boutons_page2 = tabs.page2:CreateSection("Boutons", "left"),
    sliders_page2 = tabs.page2:CreateSection("Sliders", "right"),
    
    -- Paramètres
    gui_settings = tabs.settings:CreateSection("Interface", "left")
}

-- Fonction de notification
function notify(title, context, cooldown)
    window:Notify(title, context, cooldown)
end

-- ============================================
-- PAGE 1 - BOUTONS
-- ============================================

sections.boutons_page1:CreateToggle("bouton.Page1.1", false, function(value)
    library.flags.bouton_page1_1 = value
    if value then
        notify("Bouton", "bouton.Page1.1 activé", 3)
    else
        notify("Bouton", "bouton.Page1.1 désactivé", 3)
    end
end)

sections.boutons_page1:CreateToggle("bouton.Page1.2", false, function(value)
    library.flags.bouton_page1_2 = value
    if value then
        notify("Bouton", "bouton.Page1.2 activé", 3)
    end
end)

sections.boutons_page1:CreateToggle("bouton.Page1.3", false, function(value)
    library.flags.bouton_page1_3 = value
    if value then
        notify("Bouton", "bouton.Page1.3 activé", 3)
    end
end)

sections.boutons_page1:CreateButton("bouton.Page1.4", function()
    notify("Bouton", "bouton.Page1.4 cliqué!", 3)
end)

-- ============================================
-- PAGE 1 - SLIDERS
-- ============================================

sections.sliders_page1:CreateSlider("slider.Page1.1", 0, 100, 50, function(value)
    library.flags.slider_page1_1 = value
end)

sections.sliders_page1:CreateSlider("slider.Page1.2", 0, 200, 100, function(value)
    library.flags.slider_page1_2 = value
end)

sections.sliders_page1:CreateSlider("slider.Page1.3", 1, 50, 10, function(value)
    library.flags.slider_page1_3 = value
end)

-- ============================================
-- PAGE 2 - BOUTONS
-- ============================================

sections.boutons_page2:CreateToggle("bouton.Page2.1", false, function(value)
    library.flags.bouton_page2_1 = value
    if value then
        notify("Bouton", "bouton.Page2.1 activé", 3)
    end
end)

sections.boutons_page2:CreateToggle("bouton.Page2.2", false, function(value)
    library.flags.bouton_page2_2 = value
    if value then
        notify("Bouton", "bouton.Page2.2 activé", 3)
    end
end)

sections.boutons_page2:CreateButton("bouton.Page2.3", function()
    notify("Bouton", "bouton.Page2.3 cliqué!", 3)
end)

-- ============================================
-- PAGE 2 - SLIDERS
-- ============================================

sections.sliders_page2:CreateSlider("slider.Page2.1", 1, 100, 25, function(value)
    library.flags.slider_page2_1 = value
end)

sections.sliders_page2:CreateSlider("slider.Page2.2", 0, 500, 250, function(value)
    library.flags.slider_page2_2 = value
end)

-- ============================================
-- PARAMÈTRES
-- ============================================

sections.gui_settings:CreateToggle("Anti AFK", false, function(value)
    library.flags.anti_afk = value
    if value then
        notify("Paramètres", "Anti AFK activé", 3)
    else
        notify("Paramètres", "Anti AFK désactivé", 3)
    end
end)

sections.gui_settings:CreateButton("Réinitialiser l'interface", function()
    notify("Paramètres", "Interface réinitialisée!", 3)
end)

-- Anti AFK automatique
local virtual_user = game:GetService("VirtualUser")
local local_player = game:GetService("Players").LocalPlayer

local_player.Idled:Connect(function()
    if (library.flags.anti_afk) then
        virtual_user:CaptureController()
        virtual_user:ClickButton2(Vector2.new())
    end
end)

-- Notification de démarrage
notify("Interface", "Script chargé avec succès!", 5)

print("Interface chargée avec succès!")