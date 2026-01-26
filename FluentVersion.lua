-- ===============================================
-- 🎮 ROBLOX AUTO FARM SCRIPT
-- ===============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

local Networker = ReplicatedStorage.Shared.Packages.Networker
local PlaceEggRF = Networker["RF/PlaceEgg"]
local UpgradeBrainrotRF = Networker["RF/UpgradeBrainrot"]
local HatchEggRE = Networker["RE/HatchEgg"]
local PickupBrainrotRE = Networker["RE/PickupBrainrot"]
local PickupBoxesRE = Networker["RE/PickupBoxes"]
local RequestEggSpawnRF = Networker["RF/RequestEggSpawn"]
local BuyEggRF = Networker["RF/BuyEgg"]

-- ===============================================
-- 📊 CONFIGURATION & VARIABLES
-- ===============================================

local Config = {
    AutoUpgrade = false,
    AutoHatch = false,
    AutoPlaceEgg = false,
    AutoCollectBoxes = false,
    AutoBuyEgg = false,
    AutoPickupWorst = false,
    BoxCollectDelay = 30,
    ActionDelay = 0.5,
    UpgradeDelay = 0.5,
    TargetLevel = 45,
    PickupWorstDelay = 5
    MinEggPrice = 0
}

local RarityConfig = {
    Divine = true,
    GOD = true,
    Admin = true,
    Event = true,
    Limited = true,
    OG = true,
    Exclusive = true,
    Exotic = true,
    Secret = false,
    Mythic = false,
    Legendary = false,
    Epic = false,
    Rare = false,
    Uncommon = false,
    Common = false,
    
}

local LastBoxCollect = 0
local LastUpgrade = 0
local LastHatch = 0
local LastPlaceEgg = 0
local LastBuyEgg = 0
local LastPickupWorst = 0

-- Juste après Config, ajoute :
local PricePresets = {
    ["Désactivé"] = 0,
    ["50M"] = 50000000,
    ["100M"] = 100000000,
    ["500M"] = 500000000,
    ["750M"] = 750000000,
    ["50B"] = 50000000000,
    ["100B"] = 100000000000,
    ["500B"] = 500000000000,
    ["750B"] = 750000000000,
    ["50T"] = 50000000000000,
    ["100T"] = 100000000000000,
    ["500T"] = 500000000000000,
    ["750T"] = 750000000000000,
    ["1Qa"] = 1000000000000000
}


local MAX_WAIT_SECONDS = 60 * 60 -- 30 minutes
local buyEggLocked = false
-- ===============================================
-- 🔧 UTILITY FUNCTIONS
-- ===============================================

local function getRebirths()
    local ClientUtils = require(ReplicatedStorage.Client.Modules.ClientUtils)
    local ProfileData = ClientUtils.ProfileData

    if ProfileData and ProfileData.leaderstats and ProfileData.leaderstats.Rebirths then
        return ProfileData.leaderstats.Rebirths
    end

    warn("Impossible de récupérer les Rebirths")
    return 0
end

local function getMyPlot()
    local Plots = workspace.CoreObjects.Plots

    for _, p in ipairs(Plots:GetChildren()) do
        local o, ov = p:GetAttribute("Owner"), p:FindFirstChild("Owner")
        if o == LocalPlayer.Name or o == LocalPlayer.UserId
        or (ov and (ov.Value == LocalPlayer.Name or ov.Value == LocalPlayer.UserId)) then
            return p
        end
    end

    warn("No plot")
end

local function getStandsFolder(plot)
    local stands = plot:FindFirstChild("Stands")
    if not stands then
        warn("No stands")
    end
    return stands
end

local function findEggTool()
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local attrs = tool:GetAttributes()
            if attrs and attrs.Egg == true then
                return tool
            end
        end
    end
end

local function equipTool(tool)
    if tool and LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        task.wait(0.15)
    end
end

local function isValidStandName(stand)
    local number = stand.Name:match("^Stand(%d+)$")
    number = tonumber(number)
    return number and number <= 50
end

local function canUseStand(stand, rebirths)
    local requirement = stand:GetAttribute("Requirement")
    return requirement == nil or (type(requirement) == "number" and requirement <= rebirths)
end

local function getStandState(stand)
    if stand:FindFirstChildOfClass("Model") then
        return "Brainrot"
    end

    for _, d in ipairs(stand:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "Timer" then
            return "Egg"
        end
    end

    return "Empty"
end

local function getBrainrotLevel(stand)
    for _, child in ipairs(stand:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            local level = child:GetAttribute("Level")
            if level ~= nil then
                return tonumber(level) or 0
            end
        end
    end
    return 0
end

local function isStandEmpty(stand)
    return getStandState(stand) == "Empty"
end

local function findEmptyUsableStand(standsFolder, rebirths)
    for _, stand in ipairs(standsFolder:GetChildren()) do
        if isValidStandName(stand)
        and canUseStand(stand, rebirths)
        and isStandEmpty(stand) then
            return stand
        end
    end
end

local function readStandContent(stand)
    local state = getStandState(stand)

    local data = {
        State = state,
        Name = nil,
        Rarity = nil,
        GainPerSec = nil,
        Timer = nil
    }

    if state == "Brainrot" then
        local brainrot = stand:FindFirstChildOfClass("Model")
        local bb = brainrot
            and brainrot:FindFirstChild("HumanoidRootPart")
            and brainrot.HumanoidRootPart:FindFirstChild("BrainrotBillboard")

        if brainrot then
            data.Name = brainrot.Name
        end

        if bb then
            data.Rarity = bb.Rarity.Text
            data.GainPerSec = bb.Multiplier.Text
        end
    end

    if state == "Egg" then
        for _, d in ipairs(stand:GetDescendants()) do
            if d:IsA("TextLabel") and d.Name == "Timer" then
                data.Timer = d.Text
                break
            end
        end
    end

    return data
end

local function parseGainPerSec(gainText)
    if not gainText then return 0 end
    
    local num = gainText:match("([%d%.]+)")
    num = tonumber(num) or 0
    
    if gainText:find("K") then
        num = num * 1000
    elseif gainText:find("M") then
        num = num * 1000000
    elseif gainText:find("B") then
        num = num * 1000000000
    end
    
    return num
end

local function findWorstBrainrot(standsFolder)
    local worstStand = nil
    local worstGain = math.huge
    
    for _, stand in ipairs(standsFolder:GetChildren()) do
        if not isValidStandName(stand) then continue end
        
        local state = getStandState(stand)
        
        -- On ignore les stands vides et ceux avec des œufs
        if state ~= "Brainrot" then continue end
        
        -- Lire le gain/sec du brainrot
        local data = readStandContent(stand)
        local gain = parseGainPerSec(data.GainPerSec)
        
        -- Trouver le pire
        if gain < worstGain then
            worstGain = gain
            worstStand = stand
        end
    end
    
    return worstStand, worstGain
end

local function autoPickupWorst()
    if not Config.AutoPickupWorst then return end
    
    local currentTime = tick()
    if currentTime - LastPickupWorst < Config.PickupWorstDelay then
        return
    end
    
    -- Vérifier s'il reste de la place
    local myPlot = getMyPlot()
    if not myPlot then return end
    
    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end
    
    local rebirths = getRebirths()
    local emptyStand = findEmptyUsableStand(standsFolder, rebirths)
    
    -- Si on a encore de la place, pas besoin de pickup
    if emptyStand then return end
    
    -- Sinon, trouver le pire brainrot
    local worstStand, worstGain = findWorstBrainrot(standsFolder)
    
    if worstStand then
        print("🗑️ Pickup du pire brainrot:", worstStand.Name, "| Gain:", worstGain)
        
        local success, err = pcall(function()
            PickupBrainrotRE:FireServer(worstStand.Name)
        end)
        
        if not success then
            warn("❌ Erreur pickup:", err)
        end
    end
    
    LastPickupWorst = currentTime
end

-- ===============================================
-- 💰 AUTO BUY EGG FUNCTIONS
-- ===============================================

local function parseEggPrice(text)
    if not text then return 0 end
    local cleaned = tostring(text):gsub(",", "")
    local num, suffix = cleaned:match("([%d%.]+)([KMBT]?)")
    if not num then return 0 end
    local value = tonumber(num) or 0
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
    if suffix and multipliers[suffix] then
        value = value * multipliers[suffix]
    end
    return value
end

local function parseCash(text)
    if not text then return 0 end
    local cleaned = tostring(text):gsub(",", "")
    local num, suffix = cleaned:match("([%d%.]+)([KMBT]?)")
    if not num then return 0 end
    local value = tonumber(num) or 0
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
    if suffix and multipliers[suffix] then
        value = value * multipliers[suffix]
    end
    return value
end

local function parseGain(text)
    if not text then return 0 end
    text = tostring(text)
    local value, suffix = text:match("%$([%d%.]+)%s*([MK]?)")
    if not value then return 0 end
    local num = tonumber(value)
    if not num then return 0 end
    if suffix == "M" then
        num *= 1_000_000
    elseif suffix == "K" then
        num *= 1_000
    end
    return num
end

local function getCash()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Cash") then
        return parseCash(leaderstats.Cash.Value)
    end
    warn("[Cash] leaderstats.Cash introuvable")
    return 0
end

local function calculateTotalGainPerSec()
    local myPlot = getMyPlot()
    if not myPlot then
        warn("[Plot] Aucun plot trouvé")
        return 0
    end

    local stands = myPlot:FindFirstChild("Stands")
    if not stands then
        warn("[Stands] Aucun stand trouvé")
        return 0
    end

    local totalGainPerSec = 0
    for _, stand in ipairs(stands:GetChildren()) do
        local brainrot = stand:FindFirstChildOfClass("Model")
        local bb = brainrot
            and brainrot:FindFirstChild("HumanoidRootPart")
            and brainrot.HumanoidRootPart:FindFirstChild("BrainrotBillboard")
        if bb and bb:FindFirstChild("Multiplier") then
            local gain = parseGain(bb.Multiplier.Text)
            totalGainPerSec += gain
        end
    end

    return totalGainPerSec
end

local function getCurrentEgg()
    for _, eggFolder in ipairs(workspace.CoreObjects.Eggs:GetChildren()) do
        if eggFolder:GetAttribute("CurrentEgg") then
            local eggModel = eggFolder:FindFirstChildWhichIsA("Model") 
                or eggFolder:FindFirstChildWhichIsA("MeshPart")
            
            if not eggModel then continue end
            
            local frame = eggModel:FindFirstChild("BillboardAttachment", true)
            frame = frame and frame.EggBillboard and frame.EggBillboard.Frame
            
            if not frame then continue end
            
            local priceLabel = frame:FindFirstChild("Price")
            local rarityLabel = frame:FindFirstChild("Rarity")
            
            if not priceLabel or not rarityLabel then continue end
            
            return {
                name = eggFolder.Name,
                price = parseEggPrice(priceLabel.Text),
                rarity = rarityLabel.Text
            }
        end
    end
    return nil
end

local function changeEgg()
    print("🔄 Changement d'œuf...")
    local success, err = pcall(function()
        RequestEggSpawnRF:InvokeServer()
    end)
    if not success then
        warn("[ChangeEgg] Erreur :", err)
    end
    return success
end

local function buyEgg(eggName)
    print("💳 Achat de l'œuf :", eggName)
    local success, err = pcall(function()
        BuyEggRF:InvokeServer(eggName, 1)
    end)
    if not success then
        warn("[BuyEgg] Erreur :", err)
    end
    return success
end

local function decideAction(egg, cash, gainPerSec)
    
    print("🔍 DEBUG - Rareté:", egg.rarity, "| Autorisée?", RarityConfig[egg.rarity])
    print("💰 DEBUG - Prix œuf:", egg.price, "| Prix min config:", Config.MinEggPrice)
    
    -- Cas 1 : Rareté non autorisée → CHANGER
    if not RarityConfig[egg.rarity] then
        print("❌ CHANGE → Rareté non autorisée")
        return "CHANGE"
    end
    
    -- Cas 2 : Prix pas assez élevé (strictement supérieur) → CHANGER
    if Config.MinEggPrice > 0 and egg.price <= Config.MinEggPrice then
        return "CHANGE"
    end
    
    -- Cas 3 : Cash suffisant → ACHETER
    if cash >= egg.price then
        return "BUY"
    end
    
    -- Cas 4 : Pas de production → CHANGER
    if gainPerSec <= 0 then
        return "CHANGE"
    end
    
    -- Cas 5 : Calculer le temps d'attente
    local waitTime = (egg.price - cash) / gainPerSec
    local hours = math.floor(waitTime / 3600)
    local minutes = math.floor((waitTime % 3600) / 60)
    local seconds = math.floor(waitTime % 60)
        
    -- Cas 6 : Temps d'attente trop long → CHANGER
    if waitTime > MAX_WAIT_SECONDS then
        return "CHANGE"
    end
    
    -- Cas 7 : Temps acceptable → ATTENDRE
    print(string.format("⏰ WAIT → Attente de %dh %dm %ds", hours, minutes, seconds))
    return "WAIT", waitTime
end

local function autoBuyEgg()
    if not Config.AutoBuyEgg then return end
    if buyEggLocked then return end
    
    local currentTime = tick()
    if currentTime - LastBuyEgg < 1 then
        return
    end
    
    local cash = getCash()
    local gainPerSec = calculateTotalGainPerSec()
    local egg = getCurrentEgg()
    
    -- Aucun œuf détecté
    if not egg then
        print("❌ Aucun œuf détecté → changement")
        buyEggLocked = true
        changeEgg()
        task.wait(0.5)
        buyEggLocked = false
        LastBuyEgg = tick()
        return
    end
    
    -- Décision logique
    local action, waitTime = decideAction(egg, cash, gainPerSec)
    
    if action == "BUY" then
        buyEggLocked = true
        buyEgg(egg.name)
        
        -- Après un achat → passer à l'œuf suivant
        task.wait(1)
        changeEgg()
        
        task.wait(0.5)
        buyEggLocked = false
        
    elseif action == "CHANGE" then
        buyEggLocked = true
        changeEgg()
        task.wait(0.5)
        buyEggLocked = false
        
    elseif action == "WAIT" then
        -- Attente douce, jamais trop longue
        task.wait(math.min(waitTime or 1, 2))
    end
    
    LastBuyEgg = tick()
end

-- ===============================================
-- 🎯 AUTO FUNCTIONS
-- ===============================================

task.spawn(function()
    while true do
        task.wait(Config.UpgradeDelay)
        
        if not Config.AutoUpgrade then
            continue
        end
        
        local myPlot = getMyPlot()
        if not myPlot then continue end
        
        local standsFolder = getStandsFolder(myPlot)
        if not standsFolder then continue end
        
        for _, stand in ipairs(standsFolder:GetChildren()) do
            if not isValidStandName(stand) then
                continue
            end
            
            local level = getBrainrotLevel(stand)
            
            if level > 0 and level < Config.TargetLevel then
                local success, err = pcall(function()
                    UpgradeBrainrotRF:InvokeServer(stand.Name)
                end)
                
                if success then
                    print("✅ Upgraded", stand.Name, "| Niveau:", level, "→", level + 1)
                else
                    warn("❌ Erreur upgrade:", err)
                end
                
                task.wait(Config.ActionDelay)
                break  -- Un seul upgrade par cycle
            end
        end
    end
end)

local function autoHatch()
    if not Config.AutoHatch then return end
    
    local currentTime = tick()
    if currentTime - LastHatch < Config.ActionDelay then
        return
    end
    
    local myPlot = getMyPlot()
    if not myPlot then return end
    
    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end
    
    for _, stand in ipairs(standsFolder:GetChildren()) do
        if isValidStandName(stand) then
            local timer = nil
            for _, d in ipairs(stand:GetDescendants()) do
                if d:IsA("TextLabel") and d.Name == "Timer" then
                    timer = d.Text
                    break
                end
            end
            
            if timer and timer == "READY!" then
                local brainrotModel = stand:FindFirstChildOfClass("Model")
                
                if brainrotModel then
                    local brainrotName = brainrotModel.Name
                    
                    local success, err = pcall(function()
                        HatchEggRE:FireServer(stand.Name, brainrotName)
                    end)
                    
                    if not success then
                        warn("❌ Erreur lors de l'éclosion:", err)
                    else
                        print("✅ Œuf éclos:", stand.Name, "| Brainrot:", brainrotName)
                    end
                    
                    LastHatch = tick()
                    task.wait(Config.ActionDelay)
                    
                    return
                else
                    warn("⚠️ Timer READY! mais Model introuvable pour:", stand.Name)
                end
            end
        end
    end
    
    LastHatch = currentTime
end

local function autoPlaceEgg()
    if not Config.AutoPlaceEgg then return end
    
    local currentTime = tick()
    if currentTime - LastPlaceEgg < Config.ActionDelay then
        return
    end
    
    local eggTool = findEggTool()
    if not eggTool then return end
    
    local myPlot = getMyPlot()
    if not myPlot then return end
    
    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end
    
    local rebirths = getRebirths()
    local stand = findEmptyUsableStand(standsFolder, rebirths)
    
    if not stand then return end
    
    equipTool(eggTool)
    
    pcall(function()
        PlaceEggRF:InvokeServer(stand.Name, eggTool.Name)
    end)
    
    LastPlaceEgg = currentTime
    task.wait(Config.ActionDelay)
end

local function autoCollectBoxes()
    if not Config.AutoCollectBoxes then return end
    
    local currentTime = tick()
    if currentTime - LastBoxCollect < Config.BoxCollectDelay then
        return
    end
    
    pcall(function()
        PickupBoxesRE:FireServer()
    end)
    
    task.wait(0.3)
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    LastBoxCollect = currentTime
end

--PickUpWorst
task.spawn(function()
    while true do
        task.wait(Config.PickupWorstDelay)
        autoPickupWorst()
    end
end)

-- ===============================================
-- 🔄 MAIN LOOP
-- ===============================================

RunService.Heartbeat:Connect(function()
    autoHatch()
    autoPlaceEgg()
    autoCollectBoxes()
    autoBuyEgg()
end)

-- ===============================================
-- 🎨 GUI CREATION (FLUENT UI)
-- ===============================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "🎮 CuddlyTrain Auto Farm",
    SubTitle = "by AK♥",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Effet blur moderne
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ===============================================
-- 📁 TABS
-- ===============================================

local Tabs = {
    Main = Window:AddTab({ Title = "🏠 Principal", Icon = "home" }),
    Rarity = Window:AddTab({ Title = "🎯 Raretés", Icon = "star" }),
    Settings = Window:AddTab({ Title = "⚙️ Paramètres", Icon = "settings" })
}

-- ===============================================
-- 🏠 ONGLET PRINCIPAL
-- ===============================================

Tabs.Main:AddParagraph({
    Title = "Automatisations",
    Content = "Activez les fonctionnalités d'auto-farm"
})

local AutoUpgradeToggle = Tabs.Main:AddToggle("AutoUpgrade", {
    Title = "Auto Upgrade",
    Description = "Améliore automatiquement les brainrots",
    Default = false,
    Callback = function(Value)
        Config.AutoUpgrade = Value
    end
})

local AutoHatchToggle = Tabs.Main:AddToggle("AutoHatch", {
    Title = "Auto Hatch",
    Description = "Fait éclore les œufs automatiquement",
    Default = false,
    Callback = function(Value)
        Config.AutoHatch = Value
    end
})

local AutoPlaceEggToggle = Tabs.Main:AddToggle("AutoPlaceEgg", {
    Title = "Auto Place Egg",
    Description = "Place les œufs sur les stands vides",
    Default = false,
    Callback = function(Value)
        Config.AutoPlaceEgg = Value
    end
})

local AutoCollectBoxesToggle = Tabs.Main:AddToggle("AutoCollectBoxes", {
    Title = "Auto Collect Boxes",
    Description = "Collecte les boîtes automatiquement",
    Default = false,
    Callback = function(Value)
        Config.AutoCollectBoxes = Value
    end
})

local AutoBuyEggToggle = Tabs.Main:AddToggle("AutoBuyEgg", {
    Title = "Auto Buy Egg",
    Description = "Achète les œufs selon les critères définis",
    Default = false,
    Callback = function(Value)
        Config.AutoBuyEgg = Value
    end
})

local AutoPickupWorstToggle = Tabs.Main:AddToggle("AutoPickupWorst", {
    Title = "Auto Pickup Worst",
    Description = "Ramasse le pire brainrot quand il n'y a plus de place",
    Default = false,
    Callback = function(Value)
        Config.AutoPickupWorst = Value
    end
})

-- ===============================================
-- 🎯 ONGLET RARETÉS
-- ===============================================

Tabs.Rarity:AddParagraph({
    Title = "Raretés à acheter",
    Content = "Sélectionnez les raretés d'œufs que vous voulez acheter"
})

-- Raretés Premium
Tabs.Rarity:AddToggle("RarityAdmin", {
    Title = "Admin",
    Default = RarityConfig.Admin,
    Callback = function(Value)
        RarityConfig.Admin = Value
    end
})

Tabs.Rarity:AddToggle("RarityDivine", {
    Title = "Divine",
    Default = RarityConfig.Divine,
    Callback = function(Value)
        RarityConfig.Divine = Value
    end
})

Tabs.Rarity:AddToggle("RarityGOD", {
    Title = "GOD",
    Default = RarityConfig.GOD,
    Callback = function(Value)
        RarityConfig.GOD = Value
    end
})

Tabs.Rarity:AddToggle("RarityEvent", {
    Title = "Event",
    Default = RarityConfig.Event,
    Callback = function(Value)
        RarityConfig.Event = Value
    end
})

Tabs.Rarity:AddToggle("RarityLimited", {
    Title = "Limited",
    Default = RarityConfig.Limited,
    Callback = function(Value)
        RarityConfig.Limited = Value
    end
})

Tabs.Rarity:AddToggle("RarityOG", {
    Title = "OG",
    Default = RarityConfig.OG,
    Callback = function(Value)
        RarityConfig.OG = Value
    end
})

Tabs.Rarity:AddToggle("RarityExclusive", {
    Title = "Exclusive",
    Default = RarityConfig.Exclusive,
    Callback = function(Value)
        RarityConfig.Exclusive = Value
    end
})

Tabs.Rarity:AddToggle("RarityExotic", {
    Title = "Exotic",
    Default = RarityConfig.Exotic,
    Callback = function(Value)
        RarityConfig.Exotic = Value
    end
})

-- Raretés Standard
Tabs.Rarity:AddToggle("RaritySecret", {
    Title = "Secret",
    Default = RarityConfig.secret,
    Callback = function(Value)
        RarityConfig.secret = Value
    end
})

Tabs.Rarity:AddToggle("RarityMythic", {
    Title = "Mythic",
    Default = RarityConfig.Mythic,
    Callback = function(Value)
        RarityConfig.Mythic = Value
    end
})

Tabs.Rarity:AddToggle("RarityLegendary", {
    Title = "Legendary",
    Default = RarityConfig.Legendary,
    Callback = function(Value)
        RarityConfig.Legendary = Value
    end
})

Tabs.Rarity:AddToggle("RarityEpic", {
    Title = "Epic",
    Default = RarityConfig.Epic,
    Callback = function(Value)
        RarityConfig.Epic = Value
    end
})

Tabs.Rarity:AddToggle("RarityRare", {
    Title = "Rare",
    Default = RarityConfig.Rare,
    Callback = function(Value)
        RarityConfig.Rare = Value
    end
})

Tabs.Rarity:AddToggle("RarityUncommon", {
    Title = "Uncommon",
    Default = RarityConfig.Uncommon,
    Callback = function(Value)
        RarityConfig.Uncommon = Value
    end
})

Tabs.Rarity:AddToggle("RarityCommon", {
    Title = "Common",
    Default = RarityConfig.Common,
    Callback = function(Value)
        RarityConfig.Common = Value
    end
})

-- ===============================================
-- ⚙️ ONGLET PARAMÈTRES
-- ===============================================

Tabs.Settings:AddParagraph({
    Title = "Délais",
    Content = "Configurez les délais entre les actions"
})

local BoxCollectDelaySlider = Tabs.Settings:AddSlider("BoxCollectDelay", {
    Title = "Box Collect Delay",
    Description = "Délai entre chaque collecte de boîtes (secondes)",
    Default = 30,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        Config.BoxCollectDelay = Value
    end
})

local ActionDelaySlider = Tabs.Settings:AddSlider("ActionDelay", {
    Title = "Action Delay",
    Description = "Délai entre les actions générales (secondes)",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        Config.ActionDelay = Value
    end
})

local UpgradeDelaySlider = Tabs.Settings:AddSlider("UpgradeDelay", {
    Title = "Upgrade Delay",
    Description = "Délai entre chaque amélioration (secondes)",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        Config.UpgradeDelay = Value
    end
})

local PickupWorstDelaySlider = Tabs.Settings:AddSlider("PickupWorstDelay", {
    Title = "Pickup Worst Delay",
    Description = "Délai entre chaque pickup du pire brainrot (secondes)",
    Default = 5,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        Config.PickupWorstDelay = Value
    end
})

-- Prix des œufs
Tabs.Settings:AddParagraph({
    Title = "Prix des œufs",
    Content = "Définissez le prix minimum pour acheter les œufs"
})

local MinEggPriceDropdown = Tabs.Settings:AddDropdown("MinEggPrice", {
    Title = "Prix minimum œuf",
    Description = "Les œufs doivent coûter PLUS que cette valeur",
    Values = {
        "Désactivé",
        "50M",
        "100M",
        "500M",
        "750M",
        "50B",
        "100B",
        "500B",
        "750B",
        "50T",
        "100T",
        "500T",
        "750T",
        "1Qa"
    },
    Multi = false,
    Default = 1,
    Callback = function(Value)
        local selectedPrice = PricePresets[Value] or 0
        Config.MinEggPrice = selectedPrice
        
        if selectedPrice > 0 then
            Fluent:Notify({
                Title = "Prix minimum activé",
                Content = Value .. " = " .. selectedPrice,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Prix minimum désactivé",
                Content = "Tous les prix sont acceptés",
                Duration = 3
            })
        end
    end
})

-- Niveaux
Tabs.Settings:AddParagraph({
    Title = "Niveaux",
    Content = "Configurez le niveau cible pour les upgrades"
})

local TargetLevelSlider = Tabs.Settings:AddSlider("TargetLevel", {
    Title = "Target Level",
    Description = "Niveau maximum pour les upgrades automatiques",
    Default = 45,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        Config.TargetLevel = Value
    end
})

-- Utilitaires
Tabs.Settings:AddParagraph({
    Title = "Utilitaires",
    Content = "Actions diverses"
})

Tabs.Settings:AddButton({
    Title = "Détruire l'UI",
    Description = "Ferme complètement l'interface",
    Callback = function()
        Fluent:Destroy()
    end
})

-- ===============================================
-- 🔧 SAVE MANAGER & INTERFACE MANAGER
-- ===============================================

SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("CuddlyTrain/AutoFarm")
SaveManager:BuildConfigSection(Tabs.Settings)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("CuddlyTrain")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

-- ===============================================
-- 🎉 NOTIFICATION DE DÉMARRAGE
-- ===============================================

Fluent:Notify({
    Title = "Script chargé !",
    Content = "CuddlyTrain Auto Farm activé avec succès",
    Duration = 5
})