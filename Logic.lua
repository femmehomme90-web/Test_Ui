--[[
    Fichier de logique - Exemple d'utilisation
    Focus uniquement sur la logique, l'UI est gérée automatiquement
]]
-- Services (nécessaires pour Rayfield)
local players = game:GetService("Players")
local local_player = players.LocalPlayer

-- Charger l'UI générique
local GenericUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/femmehomme90-web/Test_Ui/refs/heads/main/Ui.lua'))()

-- Créer l'instance UI
local UI = GenericUI.new("🎀 CuddlyTrain", "by AK♥")

-- ============================================
-- VARIABLES DE LOGIQUE
-- ============================================

local auto_trade_enabled = false
local auto_trade_delay = 1
local auto_collect_cash = false
local collect_delay = 1

-- ============================================
-- FONCTIONS DE LOGIQUE
-- ============================================

local function start_auto_trade()
    spawn(function()
        while auto_trade_enabled do
            print("🔄 Executing trade...")
            -- Ta logique de trade ici
            
            task.wait(auto_trade_delay)
        end
    end)
end

local function collect_cash()
    print("💰 Collecting cash...")
    -- Ta logique de collecte ici
end

local function sell_held_brainrot()
    print("🛒 Selling held brainrot...")
    -- Ta logique de vente ici
end

local function sell_all_brainrots()
    print("🛒 Selling all brainrots...")
    -- Ta logique de vente totale ici
end

local function start_auto_buy_eggs()
    print("🥚 Starting auto buy eggs...")
    -- Ta logique d'achat d'œufs ici
end

local function anti_afk()
    print("😴 Anti AFK activated...")
    -- Ta logique anti-AFK ici
end

-- ============================================
-- CONFIGURATION DE L'UI
-- ============================================

-- PAGE 1 - Trading & Cash
UI:SetButton(1, 1, "🔄 Toggle Auto Trade", function()
    auto_trade_enabled = not auto_trade_enabled
    UI:Notify("Auto Trade", auto_trade_enabled and "Enabled" or "Disabled", 3)
    if auto_trade_enabled then
        start_auto_trade()
    end
end)

UI:SetButton(1, 2, "💰 Toggle Auto Collect Cash", function()
    auto_collect_cash = not auto_collect_cash
    UI:Notify("Auto Collect", auto_collect_cash and "Enabled" or "Disabled", 3)
end)

UI:SetButton(1, 3, "🛒 Sell Held Brainrot", sell_held_brainrot)

UI:SetButton(1, 4, "🛒 Sell All Brainrots", sell_all_brainrots)

UI:SetButton(1, 5, "📊 Show Stats", function()
    print("📊 Showing stats...")
    -- Ta logique de stats ici
end)

UI:SetButton(1, 6, "🔄 Reset Settings", function()
    auto_trade_enabled = false
    auto_collect_cash = false
    UI:Notify("Reset", "All settings reset", 3)
end)

UI:SetSlider(1, 1, {
    name = "Auto Trade Delay (seconds)",
    range = {0.5, 10},
    increment = 0.5,
    default = 1,
    callback = function(value)
        auto_trade_delay = value
        print("⏱️ Trade delay set to:", value)
    end
})

UI:SetSlider(1, 2, {
    name = "Collect Cash Delay (seconds)",
    range = {1, 60},
    increment = 1,
    default = 1,
    callback = function(value)
        collect_delay = value
        print("⏱️ Collect delay set to:", value)
    end
})

-- PAGE 2 - Eggs
UI:SetButton(2, 1, "🥚 Toggle Auto Buy Eggs", function()
    print("🥚 Toggle auto buy eggs")
    start_auto_buy_eggs()
end)

UI:SetButton(2, 2, "🥚 Buy Egg 1", function()
    print("🥚 Buying Egg 1...")
end)

UI:SetButton(2, 3, "🥚 Buy Egg 2", function()
    print("🥚 Buying Egg 2...")
end)

UI:SetButton(2, 4, "🥚 Buy Egg 3", function()
    print("🥚 Buying Egg 3...")
end)

UI:SetSlider(2, 1, {
    name = "Egg Buy Delay",
    range = {1, 60},
    increment = 1,
    default = 1,
    callback = function(value)
        print("🥚 Egg delay:", value)
    end
})

-- PAGE 3 - Player
UI:SetButton(3, 1, "😴 Toggle Anti AFK", anti_afk)

UI:SetButton(3, 2, "🎡 Auto Wheel Spin", function()
    print("🎡 Starting auto wheel spin...")
end)

UI:SetButton(3, 3, "📍 Teleport to Plot", function()
    print("📍 Teleporting to plot...")
end)

-- PAGE 4 - Settings & Debug
UI:SetButton(4, 1, "💵 Show Money", function()
    print("💵 Current money: [TODO]")
end)

UI:SetButton(4, 2, "📦 Dump Trade Contents", function()
    print("📦 Dumping trade contents...")
end)

UI:SetButton(4, 3, "💥 Destroy UI", function()
    UI:Destroy()
end)

-- ============================================
-- BOUCLE PRINCIPALE (Auto tasks)
-- ============================================

spawn(function()
    while true do
        if auto_collect_cash then
            collect_cash()
        end
        
        task.wait(collect_delay)
    end
end)

-- Notification de chargement
UI:Notify("✅ Loaded", "Script ready to use!", 5)

print("✨ Logique chargée! L'UI est séparée et réutilisable.")