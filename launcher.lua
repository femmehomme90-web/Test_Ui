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
    BoxCollectDelay = 30,
    ActionDelay = 0.5,
    UpgradeDelay = 0.5,
    TargetLevel = 45
}

local RarityConfig = {
    Admin = true,
    Common = false,
    Divine = true,
    Epic = false,
    Event = true,
    Exclusive = true,
    Exotic = true,
    GOD = true,
    Legendary = false,
    Limited = true,
    Mythic = false,
    OG = true,
    Rare = false,
    Secret = false,
    Uncommon = false
}

local LastBoxCollect = 0
local LastUpgrade = 0
local LastHatch = 0
local LastPlaceEgg = 0
local LastBuyEgg = 0

-- Variables pour Auto Buy Egg
local MAX_WAIT_SECONDS = 30 * 60 -- 30 minutes
local buyEggLocked = false
local lastEggName = nil
local sameEggCount = 0
local MAX_SAME_EGG = 3

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
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🥚 Œuf :", egg.name)
    print("🎯 Rareté :", egg.rarity)
    print("💰 Prix :", egg.price)
    print("💵 Cash :", cash)
    print("⚙️ Gain/sec :", gainPerSec)
    
    -- Cas 1 : Rareté non autorisée → CHANGER
    if not RarityConfig[egg.rarity] then
        print("❌ CHANGE → Rareté non autorisée")
        return "CHANGE"
    end
    
    -- Cas 2 : Cash suffisant → ACHETER
    if cash >= egg.price then
        print("✅ BUY → Cash suffisant")
        return "BUY"
    end
    
    -- Cas 3 : Pas de production → CHANGER
    if gainPerSec <= 0 then
        print("❌ CHANGE → Aucune production")
        return "CHANGE"
    end
    
    -- Cas 4 : Calculer le temps d'attente
    local waitTime = (egg.price - cash) / gainPerSec
    local hours = math.floor(waitTime / 3600)
    local minutes = math.floor((waitTime % 3600) / 60)
    local seconds = math.floor(waitTime % 60)
    
    print(string.format("⏳ Temps estimé : %dh %dm %ds", hours, minutes, seconds))
    
    -- Cas 5 : Temps d'attente trop long → CHANGER
    if waitTime > MAX_WAIT_SECONDS then
        print("❌ CHANGE → Attente > 30 min")
        return "CHANGE"
    end
    
    -- Cas 6 : Temps acceptable → ATTENDRE
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
        lastEggName = nil
        sameEggCount = 0
        LastBuyEgg = tick()
        return
    end
    
    -- Détection du même œuf
    if egg.name == lastEggName then
        sameEggCount += 1
    else
        sameEggCount = 0
        lastEggName = egg.name
    end
    
    sameEggCount = tonumber(sameEggCount) or 0
    
    -- Même œuf bloqué
    if sameEggCount >= MAX_SAME_EGG then
        print("⚠️ Même œuf détecté 3 fois → SKIP FORCÉ")
        buyEggLocked = true
        changeEgg()
        task.wait(0.5)
        buyEggLocked = false
        sameEggCount = 0
        lastEggName = ""
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
        sameEggCount = 0
        lastEggName = nil
        
    elseif action == "CHANGE" then
        buyEggLocked = true
        changeEgg()
        task.wait(0.5)
        buyEggLocked = false
        sameEggCount = 0
        lastEggName = nil
        
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
-- 🎨 GUI CREATION
-- ===============================================

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "AutoFarmGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎮 AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.Size = UDim2.new(1, -20, 1, -70)

UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local function createToggle(name, configKey, order)
    local ToggleFrame = Instance.new("Frame")
    local ToggleLabel = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local ButtonCorner = Instance.new("UICorner")
    
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Parent = ContentFrame
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.LayoutOrder = order
    
    ToggleLabel.Name = "Label"
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleButton.Name = "Button"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ToggleButton.Position = UDim2.new(0.65, 0, 0, 0)
    ToggleButton.Size = UDim2.new(0.35, 0, 1, 0)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        
        if Config[configKey] then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            ToggleButton.Text = "ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ToggleButton.Text = "OFF"
        end
    end)
end
-- Séparateur
local SeparatorFrame = Instance.new("Frame")
SeparatorFrame.Name = "Separator"
SeparatorFrame.Parent = ContentFrame
SeparatorFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SeparatorFrame.BorderSizePixel = 0
SeparatorFrame.Size = UDim2.new(1, 0, 0, 2)
SeparatorFrame.LayoutOrder = 6

local RarityTitle = Instance.new("TextLabel")
RarityTitle.Name = "RarityTitle"
RarityTitle.Parent = ContentFrame
RarityTitle.BackgroundTransparency = 1
RarityTitle.Size = UDim2.new(1, 0, 0, 30)
RarityTitle.Font = Enum.Font.GothamBold
RarityTitle.Text = "🎯 RARETÉS À ACHETER"
RarityTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
RarityTitle.TextSize = 14
RarityTitle.TextXAlignment = Enum.TextXAlignment.Left
RarityTitle.LayoutOrder = 7

-- Fonction pour créer un toggle de rareté (plus compact)
local function createRarityToggle(rarityName, order)
    local ToggleFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local ButtonCorner = Instance.new("UICorner")
    
    ToggleFrame.Name = rarityName .. "Frame"
    ToggleFrame.Parent = ContentFrame
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(0.48, 0, 0, 35)
    ToggleFrame.LayoutOrder = order
    
    ToggleButton.Name = "Button"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = rarityName
    ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleButton.TextSize = 12
    
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        RarityConfig[rarityName] = not RarityConfig[rarityName]
        
        if RarityConfig[rarityName] then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
end

-- Ajuste la taille du MainFrame pour contenir les raretés
MainFrame.Size = UDim2.new(0, 300, 0, 650)

-- Utilise un GridLayout pour les raretés
local RarityGrid = Instance.new("UIGridLayout")
RarityGrid.Parent = ContentFrame
RarityGrid.SortOrder = Enum.SortOrder.LayoutOrder
RarityGrid.CellPadding = UDim2.new(0, 5, 0, 5)
RarityGrid.CellSize = UDim2.new(0.48, 0, 0, 35)
RarityGrid.FillDirectionMaxCells = 2

-- Change UIListLayout à LayoutOrder 99 pour qu'il ne s'applique pas aux raretés
UIListLayout.Parent = nil

-- Crée les toggles de rareté
local rarities = {"Admin", "Common", "Divine", "Epic", "Event", "Exclusive", "Exotic", "GOD", 
                  "Legendary", "Limited", "Mythic", "OG", "Rare", "Secret", "Uncommon"}

for i, rarity in ipairs(rarities) do
    createRarityToggle(rarity, 7 + i)
end

local function createSlider(name, configKey, min, max, order)
    local SliderFrame = Instance.new("Frame")
    local SliderLabel = Instance.new("TextLabel")
    local SliderBar = Instance.new("Frame")
    local SliderFill = Instance.new("Frame")
    local SliderButton = Instance.new("TextButton")
    local ValueLabel = Instance.new("TextLabel")
    
    SliderFrame.Name = name .. "Frame"
    SliderFrame.Parent = ContentFrame
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.LayoutOrder = order
    
    SliderLabel.Name = "Label"
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ValueLabel.Name = "Value"
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0, 0, 0, 0)
    ValueLabel.Size = UDim2.new(1, 0, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = Config[configKey] .. "s"
    ValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    SliderBar.Name = "Bar"
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Position = UDim2.new(0, 0, 0, 25)
    SliderBar.Size = UDim2.new(1, 0, 0, 20)
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 10)
    BarCorner.Parent = SliderBar
    
    SliderFill.Name = "Fill"
    SliderFill.Parent = SliderBar
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = SliderFill
    
    SliderButton.Name = "Button"
    SliderButton.Parent = SliderBar
    SliderButton.BackgroundTransparency = 1
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.Text = ""
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local barPos = SliderBar.AbsolutePosition.X
            local barSize = SliderBar.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            Config[configKey] = value
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueLabel.Text = value .. "s"
        end
    end)
end

createToggle("Auto Upgrade", "AutoUpgrade", 1)
createToggle("Auto Hatch", "AutoHatch", 2)
createToggle("Auto Place Egg", "AutoPlaceEgg", 3)
createToggle("Auto Collect Boxes", "AutoCollectBoxes", 4)
createToggle("Auto Buy Egg", "AutoBuyEgg", 5)
createSlider("Box Delay", "BoxCollectDelay", 1, 120, 6)
createSlider("Target Level", "TargetLevel", 1, 100, 7)

-- ===============================================
-- 🔄 MAIN LOOP
-- ===============================================

RunService.Heartbeat:Connect(function()
    autoHatch()
    autoPlaceEgg()
    autoCollectBoxes()
    autoBuyEgg()
end)