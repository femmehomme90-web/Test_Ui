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
local PrestigeRE = Networker["RE/Prestige"]
local GetProfileDataRF = Networker["RF/GetProfileData"]


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
    AutoPrestige = false,
    PrestigeDelay = 80,
    BoxCollectDelay = 30,
    ActionDelay = 0.5,
    UpgradeDelay = 0.5,
    TargetLevel = 45,
    PickupWorstDelay = 5,
    MinEggPrice = 0
}

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

local RarityConfig = {
    Divine = true,
    GOD = true,
    Admin = true,
    Event = true,
    Limited = true,
    OG = true,
    Exclusive = true,
    Exotic = true,
    secret = false,
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
-- 🏆 AUTO PRESTIGE (STAND 2 / 4 / 6)
-- ===============================================

-- ===============================================
-- 🧬 AUTO PRESTIGE SYSTEM (Stand 2 / 4 / 6)
-- ===============================================

local PrestigeRE = Networker["RE/Prestige"]

local prestigeLocks = {
    Stand2 = false,
    Stand4 = false,
    Stand6 = false,
}

local function getBrainrotDataFromProfile(standName)
    local GetProfileDataRF = Networker["RF/GetProfileData"]
    local profileData = GetProfileDataRF:InvokeServer()

    if not profileData or not profileData.PlotData 
    or not profileData.PlotData.Stands 
    or not profileData.PlotData.Stands[standName]
    or not profileData.PlotData.Stands[standName].BrainrotData then
        return nil
    end

    return profileData.PlotData.Stands[standName].BrainrotData
end

local function autoPrestige()
    if not Config.AutoPrestige then return end

    local myPlot = getMyPlot()
    if not myPlot then return end

    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end

    for standName, enabled in pairs(PRESTIGE_STANDS) do
        if not enabled then continue end
        if prestigeLocks[standName] then continue end

        local stand = standsFolder:FindFirstChild(standName)
        if not stand then continue end

        -- Vérifie qu'il y a un brainrot
        if getStandState(stand) ~= "Brainrot" then
            continue
        end

        local level = getBrainrotLevel(stand)
        if level < Config.PrestigeLevel then
            continue
        end

        prestigeLocks[standName] = true

        task.spawn(function()
            print("🌟 PRESTIGE :", standName)

            -- 🔍 Récupération ID depuis ProfileData
            local brData = getBrainrotDataFromProfile(standName)
            if not brData or not brData.Id then
                warn("❌ Impossible de récupérer l'ID pour", standName)
                prestigeLocks[standName] = false
                return
            end

            local brainrotId = brData.Id
            local brainrotName = brData.BrainrotName

            print("🧠 Brainrot:", brainrotName, "| ID:", brainrotId)

            -- ⭐ PRESTIGE
            pcall(function()
                PrestigeRE:FireServer(standName, brainrotId)
            end)

            print("✅ Prestige effectué :", standName)

            -- ⏱ petite sécurité
            task.wait(1)

            -- 🥚 L'œuf est dans la main → on le remet dans le backpack
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool.Parent = Backpack
                    end
                end
            end

            task.wait(0.5)

            -- 📦 Trouver l'œuf
            local eggTool = findEggTool()
            if not eggTool then
                warn("❌ Aucun œuf trouvé après prestige")
                prestigeLocks[standName] = false
                return
            end

            -- 🧱 Reposer sur le même stand
            equipTool(eggTool)

            pcall(function()
                PlaceEggRF:InvokeServer(standName, eggTool.Name)
            end)

            print("🥚 Œuf reposé sur", standName)

            -- ⏳ Attente incubation
            print("⏱ Incubation 80s sur", standName)
            task.wait(Config.PrestigeWait)

            -- 🐣 Hatch
            pcall(function()
                HatchEggRE:FireServer(standName, brainrotName)
            end)

            print("🐣 Hatch effectué sur", standName)

            prestigeLocks[standName] = false
        end)
    end
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
        print("❌ CHANGE → Prix trop bas ou égal (", egg.price, "<=", Config.MinEggPrice, ")")
        return "CHANGE"
    end
    
    -- Cas 3 : Cash suffisant → ACHETER
    if cash >= egg.price then
        print("✅ BUY → Cash suffisant")
        return "BUY"
    end
    
    -- Cas 4 : Pas de production → CHANGER
    if gainPerSec <= 0 then
        print("❌ CHANGE → Pas de production")
        return "CHANGE"
    end
    
    -- Cas 5 : Calculer le temps d'attente
    local waitTime = (egg.price - cash) / gainPerSec
    local hours = math.floor(waitTime / 3600)
    local minutes = math.floor((waitTime % 3600) / 60)
    local seconds = math.floor(waitTime % 60)
    
    print(string.format("⏳ Temps estimé : %dh %dm %ds", hours, minutes, seconds))
    
    -- Cas 6 : Temps d'attente trop long → CHANGER
    if waitTime > MAX_WAIT_SECONDS then
        print("❌ CHANGE → Attente trop longue")
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
    autoPrestige()
end)

-- ===============================================
-- 🎨 GUI CREATION
-- ===============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎮 CuddlyTrain",
   LoadingTitle = "loading",
   LoadingSubtitle = "by AK♥",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AutoFarmConfig",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- ===============================================
-- 📁 TABS
-- ===============================================

local MainTab = Window:CreateTab("🏠 Principal", 4483362458)
local RarityTab = Window:CreateTab("🎯 Raretés", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Paramètres", 4483362458)

-- ===============================================
-- 🏠 ONGLET PRINCIPAL
-- ===============================================

local MainSection = MainTab:CreateSection("Automatisations")

MainTab:CreateToggle({
   Name = "Auto Upgrade",
   CurrentValue = false,
   Flag = "AutoUpgrade",
   Callback = function(Value)
      Config.AutoUpgrade = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Hatch",
   CurrentValue = false,
   Flag = "AutoHatch",
   Callback = function(Value)
      Config.AutoHatch = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Place Egg",
   CurrentValue = false,
   Flag = "AutoPlaceEgg",
   Callback = function(Value)
      Config.AutoPlaceEgg = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Collect Boxes",
   CurrentValue = false,
   Flag = "AutoCollectBoxes",
   Callback = function(Value)
      Config.AutoCollectBoxes = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Buy Egg",
   CurrentValue = false,
   Flag = "AutoBuyEgg",
   Callback = function(Value)
      Config.AutoBuyEgg = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Pickup Worst",
   CurrentValue = false,
   Flag = "AutoPickupWorst",
   Callback = function(Value)
      Config.AutoPickupWorst = Value
   end,
})

MainTab:CreateToggle({
   Name = "Auto Prestige",
   CurrentValue = false,
   Flag = "AutoPrestige",
   Callback = function(Value)
      Config.AutoPrestige = Value
   end,
})

-- ===============================================
-- 🎯 ONGLET RARETÉS
-- ===============================================

local RaritySection = RarityTab:CreateSection("Raretés à acheter")

RarityTab:CreateToggle({
   Name = "Admin",
   CurrentValue = RarityConfig.Admin, -- ✅ Utilise la valeur du code
   Flag = "RarityAdmin",
   Callback = function(Value)
      RarityConfig.Admin = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Common",
   CurrentValue = RarityConfig.Common,
   Flag = "RarityCommon",
   Callback = function(Value)
      RarityConfig.Common = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Divine",
   CurrentValue = RarityConfig.Divine,
   Flag = "RarityDivine",
   Callback = function(Value)
      RarityConfig.Divine = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Epic",
   CurrentValue = RarityConfig.Epic,
   Flag = "RarityEpic",
   Callback = function(Value)
      RarityConfig.Epic = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Event",
   CurrentValue = RarityConfig.Event,
   Flag = "RarityEvent",
   Callback = function(Value)
      RarityConfig.Event = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Exclusive",
   CurrentValue = RarityConfig.Exclusive,
   Flag = "RarityExclusive",
   Callback = function(Value)
      RarityConfig.Exclusive = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Exotic",
   CurrentValue = RarityConfig.Exotic,
   Flag = "RarityExotic",
   Callback = function(Value)
      RarityConfig.Exotic = Value
   end,
})

RarityTab:CreateToggle({
   Name = "GOD",
   CurrentValue = RarityConfig.GOD,
   Flag = "RarityGOD",
   Callback = function(Value)
      RarityConfig.GOD = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Legendary",
   CurrentValue = RarityConfig.Legendary,
   Flag = "RarityLegendary",
   Callback = function(Value)
      RarityConfig.Legendary = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Limited",
   CurrentValue = RarityConfig.Limited,
   Flag = "RarityLimited",
   Callback = function(Value)
      RarityConfig.Limited = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Mythic",
   CurrentValue = RarityConfig.Mythic,
   Flag = "RarityMythic",
   Callback = function(Value)
      RarityConfig.Mythic = Value
   end,
})

RarityTab:CreateToggle({
   Name = "OG",
   CurrentValue = RarityConfig.OG,
   Flag = "RarityOG",
   Callback = function(Value)
      RarityConfig.OG = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Rare",
   CurrentValue = RarityConfig.Rare,
   Flag = "RarityRare",
   Callback = function(Value)
      RarityConfig.Rare = Value
   end,
})

RarityTab:CreateToggle({
   Name = "Secret",
   CurrentValue = RarityConfig.secret, -- ⚠️ Attention : "secret" en minuscule dans ton code
   Flag = "RaritySecret",
   Callback = function(Value)
      RarityConfig.secret = Value -- Garde la cohérence avec ton code
   end,
})

RarityTab:CreateToggle({
   Name = "Uncommon",
   CurrentValue = RarityConfig.Uncommon,
   Flag = "RarityUncommon",
   Callback = function(Value)
      RarityConfig.Uncommon = Value
   end,
})

-- ===============================================
-- ⚙️ ONGLET PARAMÈTRES
-- ===============================================

local DelaySection = SettingsTab:CreateSection("Délais")

SettingsTab:CreateSlider({
   Name = "Box Collect Delay (s)",
   Range = {1, 120},
   Increment = 1,
   CurrentValue = 30,
   Flag = "BoxCollectDelay",
   Callback = function(Value)
      Config.BoxCollectDelay = Value
   end,
})

SettingsTab:CreateSlider({
   Name = "Action Delay (s)",
   Range = {0.1, 5},
   Increment = 0.1,
   CurrentValue = 0.5,
   Flag = "ActionDelay",
   Callback = function(Value)
      Config.ActionDelay = Value
   end,
})



SettingsTab:CreateSlider({
   Name = "Upgrade Delay (s)",
   Range = {0.1, 5},
   Increment = 0.1,
   CurrentValue = 0.5,
   Flag = "UpgradeDelay",
   Callback = function(Value)
      Config.UpgradeDelay = Value
   end,
})

SettingsTab:CreateSlider({
   Name = "Pickup Worst Delay (s)",
   Range = {1, 30},
   Increment = 1,
   CurrentValue = 5,
   Flag = "PickupWorstDelay",
   Callback = function(Value)
      Config.PickupWorstDelay = Value
   end,
})

local LevelSection = SettingsTab:CreateSection("Niveaux")

SettingsTab:CreateSlider({
   Name = "Target Level",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 45,
   Flag = "TargetLevel",
   Callback = function(Value)
      Config.TargetLevel = Value
   end,
})

local PriceSection = SettingsTab:CreateSection("Prix des œufs")

SettingsTab:CreateDropdown({
   Name = "Prix minimum œuf",
   Options = {
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
   CurrentOption = {"Désactivé"},
   MultipleOptions = false,
   Flag = "MinEggPriceDropdown",
   Callback = function(Option)
      local selectedPrice = PricePresets[Option[1]] or 0
      Config.MinEggPrice = selectedPrice
      
      if selectedPrice > 0 then
         print("💰 Prix minimum activé:", Option[1], "=", selectedPrice)
      else
         print("💰 Prix minimum désactivé")
      end
   end,
})

local UtilitySection = SettingsTab:CreateSection("Utilitaires")

SettingsTab:CreateButton({
   Name = "Détruire l'UI",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "Script chargé !",
   Content = "Auto Farm Ultimate activé",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "OK",
         Callback = function()
            print("Notification fermée")
         end
      },
   },
})
