local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Networker = ReplicatedStorage.Shared.Packages.Networker

-- Fonctions de parsing
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

-- Configuration
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

local MAX_WAIT_SECONDS = 30 * 60 -- 30 minutes

-- Fonctions d'action
local function changeEgg()
    print("🔄 Changement d'œuf...")
    local success, err = pcall(function()
        Networker["RF/RequestEggSpawn"]:InvokeServer()
    end)
    if not success then
        warn("[ChangeEgg] Erreur :", err)
    end
    return success
end

local function buyEgg(eggName)
    print("💳 Achat de l'œuf :", eggName)
    local success, err = pcall(function()
        Networker["RF/BuyEgg"]:InvokeServer(eggName, 1)
    end)
    if not success then
        warn("[BuyEgg] Erreur :", err)
    end
    return success
end

-- Récupération du cash
local function getCash()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Cash") then
        return parseCash(leaderstats.Cash.Value)
    end
    warn("[Cash] leaderstats.Cash introuvable")
    return 0
end

-- Calcul du gain par seconde
local function calculateTotalGainPerSec()
    local myPlot
    for _, p in ipairs(workspace.CoreObjects.Plots:GetChildren()) do
        local o, ov = p:GetAttribute("Owner"), p:FindFirstChild("Owner")
        if o == LocalPlayer.Name or o == LocalPlayer.UserId
            or (ov and (ov.Value == LocalPlayer.Name or ov.Value == LocalPlayer.UserId)) then
            myPlot = p
            break
        end
    end

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

    print("💰 Gain/sec TOTAL :", totalGainPerSec)
    return totalGainPerSec
end

-- Récupération de l'œuf actuel sur le convoyeur
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

-- Logique de décision principale
local function decideAction(egg, cash, gainPerSec)
    print("──────────────────────────────")
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

-- Boucle principale
local function mainLoop()
    print("\n===== 🚀 DÉMARRAGE AUTO-ACHAT (SAFE OU PAS MDRRRR) =====\n")

    local LOOP_DELAY = 1
    local POST_CHANGE_DELAY = 0.5
    local POST_BUY_DELAY = 1
    local MAX_SAME_EGG = 3


    while true do
        if locked then
            task.wait(LOOP_DELAY)
            continue
        end

        local cash = getCash()
        local gainPerSec = calculateTotalGainPerSec()
        local egg = getCurrentEgg()

        -- Aucun œuf détecté
        if not egg then
            print("❌ Aucun œuf détecté → changement")
            locked = true
            changeEgg()
            task.wait(POST_CHANGE_DELAY)
            locked = false
            lastEggName = nil
            sameEggCount = 0
            continue
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
        locked = true
        changeEgg()
        task.wait(POST_CHANGE_DELAY)
        locked = false
        sameEggCount = 0
        lastEggName = ""
        continue
end

        -- Décision logique
        local action, waitTime = decideAction(egg, cash, gainPerSec)

        if action == "BUY" then
            locked = true
            buyEgg(egg.name)

            -- IMPORTANT : après un achat → on passe TOUJOURS à l’œuf suivant
            task.wait(POST_BUY_DELAY)
            changeEgg()

            task.wait(POST_CHANGE_DELAY)
            locked = false
            sameEggCount = 0
            lastEggName = nil

        elseif action == "CHANGE" then
            locked = true
            changeEgg()
            task.wait(POST_CHANGE_DELAY)
            locked = false
            sameEggCount = 0
            lastEggName = nil

        elseif action == "WAIT" then
            -- attente douce, jamais trop longue
            task.wait(math.min(waitTime or 1, 2))
        end

        task.wait(LOOP_DELAY)
    end
end


-- Lancement avec gestion d'erreur
local success, err = pcall(mainLoop)
if not success then
    warn("[MainLoop] Erreur critique :", err)
end