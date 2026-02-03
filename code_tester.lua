local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer
local MonNomDePlot = joueur:GetAttribute("InPlot") -- recupérer le plot du joueur
local MonPlot = workspace.CoreObjects.Plots:FindFirstChild(MonNomDePlot) --transformation en format utilisable
local Bank = joueur.leaderstats.Cash:GetAttribute("ExactValue") --récupérer le cash du joueur et c'est un forma chiffres   
local ClientUtils = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("ClientUtils")) --avec ca on récupere pleins de choses importantes 
local rebirths = (ClientUtils.ProfileData and ClientUtils.ProfileData.leaderstats and ClientUtils.ProfileData.leaderstats.Rebirths) or 0
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = ReplicatedStorage.Shared.Packages.Networker

local RaretesRecherchees = {
    "Mythical",
    "Legendary",
    "Epic"
    -- Ajoute d'autres raretés si besoin
}


local function GetStands(MonPlot) -- ici, on a une sort une table 
    local stand_folder = MonPlot:FindFirstChild("Stands") -- ici on recupere juste le fichier Stands
    if not stand_folder then
        warn("Pas de dossier Stands dans le plot ?????")
        return {}
    end

    local stands = {}
    for _,obj in ipairs(stand_folder:GetChildren()) do

        if obj.Name:match("^Stand%d+$") then
        table.insert(stands, obj)
        end
    end
    return stands
end


local function GetStandsValide(MonPlot)
    local stands = GetStands(MonPlot) 
    local standsInfo = {}

    for _, stand in pairs(stands) do
    local requirement = tonumber(stand:GetAttribute("Requirement"))
    local occupied = stand:GetAttribute("Occupied")
    local type = stand:GetAttribute("Type")

    table.insert(standsInfo, { ---table tres pratique on va ajouté en plus, vide ou pas, si c'est un brainrot ou un oeuf.
            nom = stand.Name,
            objet = stand,
            requirement = requirement or 0,
            valide = (requirement == nil or requirement <= rebirths),
            libre = not occupied, 
            type = type --- si nil alors le stand est vide comme audessus
        })
    end
    
    return standsInfo
end

-- Auto FEED --

local FOOD_PRIORITY = {"Pizza", "Burger", "Hotdog", "Ham", "Fries"} 
local CHECK_INTERVAL = 360 -- toute les 5 minuscule

local function GetFoodShopInfo()
    local success, data = pcall(function ()
        return Networker["RF/GetFoodShopData"]:InvokeServer()        
    end)

    if success and data then
        print(data)
        return data
    end
    return nil
end

local function BuyFood(foodName)

    local success, result = pcall(function()
        return Networker["RF/BuyFood"]:InvokeServer(foodName)
    end)
    if success then
        print("Acheté", foodName)
        return true

    else warn("echecs", foodName)
        return false
    end
end

local function EquipeFood(foodName)
    local backpack = LocalPlayer.backpack
    local foodItem = backpack:FindFirstChild(foodName)

    if foodItem then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:EquipTool(foodItem)
            return true
        end

    end
    return false
end

local function Feeder()
    task.wait(0.5) 

    local success, result = pcall(function()
        return Networker["RF/Feed"]:InvokeServer()
    end)
    
    if success then
        print("Pêcheur nourri avec succès!")
        return true
    else
        warn("Échec du nourrissage")
        return false
    end
end

local function UnequipCurrentTool()
    local character = LocalPlayer.Character
    if character then
        local currentTool = character:FindFirstChildOfClass("Tool")
        if currentTool then
            currentTool.Parent = LocalPlayer.Backpack
        end
    end
end

local function BuyAndFeedAutomatically()
    local shopData = GetFoodShopInfo()
    
    if not shopData or not shopData.Stock then
        warn("Impossible d'obtenir les données du shop")
        return false
    end
    
    print("Stock disponible:", shopData.Stock)
    
    -- Chercher la meilleure nourriture disponible selon la priorité
    local foodToBuy = nil
    for _, foodName in ipairs(FOOD_PRIORITY) do
        if shopData.Stock[foodName] and shopData.Stock[foodName] > 0 then
            foodToBuy = foodName
            break
        end
    end
    
    if not foodToBuy then
        warn("Aucune nourriture disponible en stock!")
        return false
    end
    
    print("Tentative d'achat de:", foodToBuy)
    
    
    if BuyFood(foodToBuy) then
        task.wait(0.3) 
        
      
        UnequipCurrentTool()
        task.wait(0.2)
        
      
        if EquipeFood(foodToBuy) then
            print("Nourriture équipée:", foodToBuy)
            
            if Feeder() then
                task.wait(1)
                UnequipCurrentTool()
                return true
            end
        else
            warn("Impossible d'équiper:", foodToBuy)
        end
    end
    
    return false
end

print("🍕 Script de nourriture automatique démarré!")
while true do
    local success = BuyAndFeedAutomatically()
    
    if success then
        print("✅ Cycle terminé avec succès")
    else
        warn("❌ Échec du cycle")
    end
    
    task.wait(CHECK_INTERVAL)
end
    































local function GetConvoyeurInfo()
    local EggFolder = workspace.CoreObjects.Eggs

    for _, model in ipairs (EggFolder:GetChildren()) do
        if model:GetAttribute("CurrentEgg") then
            print("Brainrot sur le convoyeur trouvé", model.Name)
            
            for _, meshFolder in ipairs (model:GetChildren()) do
            if meshFolder.Name:match("^Meshes/") then
                print("meshFolder")
            local billboard = meshFolder:FindFirstChild("BillboardAttachment")
                    if billboard then
                        print("billboard")
                    local eggBillboard = billboard:FindFirstChild("EggBillboard")
                        if eggBillboard then
                            print("eggBillboard")
                        local EggFrame = eggBillboard:FindFirstChild("Frame")
                            if EggFrame then 
                                print("EggFrame")
                            local Rarity = EggFrame:FindFirstChild("Rarity")
                                if Rarity and Rarity:IsA("TextLabel") then
                                    return Rarity.Text, model.Name
                                end
                            end
                        end
                    end

                            
                end
            end

        end
    end
    warn("Impossible de trouver la rareté du brainrot")
    return nil, nil
end

local function EstRareteRecherchee(rarete)
    for _, rareteRecherchee in ipairs(RaretesRecherchees) do
        if rarete == rareteRecherchee then
            return true
        end
    end
    return false
end

local function AutoBuyEgg()
    while true do
        wait(0.1) -- Attendre 0.1 seconde entre chaque vérification
        
        local rarityText, brainrotName = GetConvoyeurInfo()
        
        if rarityText and brainrotName then
            -- Un œuf est sur le convoyeur
            print("Œuf détecté:", brainrotName, "| Rareté:", rarityText)
            
            if EstRareteRecherchee(rarityText) then
                -- La rareté correspond ! On achète l'œuf
                print("✅ RARETÉ TROUVÉE ! Achat de:", brainrotName)
                Networker["RF/BuyEgg"]:InvokeServer(brainrotName, 1)
                wait(0.02) -- Attendre 1 seconde après l'achat
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            else
                -- La rareté ne correspond pas, on change d'œuf
                print("❌ Rareté non recherchée, changement d'œuf...")
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        else
            -- Pas d'œuf sur le convoyeur, on en demande un
            print("⚠️ Aucun œuf sur le convoyeur, demande d'un nouvel œuf...")
            Networker["RF/RequestEggSpawn"]:InvokeServer()
        end
    end
end

AutoBuyEgg()







