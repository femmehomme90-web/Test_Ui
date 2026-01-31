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







