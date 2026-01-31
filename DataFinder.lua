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
    "Divine",
    "GOD",
    "Admin",
    "Event",
    "Limited",
    "OG",
    "Exclusive",
}





local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = ReplicatedStorage.Shared.Packages.Networker

-- Liste des raretés recherchées (tu peux modifier cette liste)
local RaretesRecherchees = {
    "Mythical",
    "Legendary",
    "Epic"
    -- Ajoute d'autres raretés si besoin
}
local function GetConvoyeurInfo()
    local EggFolder = workspace.CoreObjects.Eggs

    for _, model in ipairs(EggFolder:GetChildren()) do
        if model:GetAttribute("CurrentEgg") then
            
            for _, meshFolder in ipairs(model:GetChildren()) do
                if meshFolder.Name:match("^Meshes/") then
                    local billboard = meshFolder:FindFirstChild("BillboardAttachment")
                    if billboard then
                        local eggBillboard = billboard:FindFirstChild("EggBillboard")
                        if eggBillboard then
                            local EggFrame = eggBillboard:FindFirstChild("Frame")
                            if EggFrame then 
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
local function TrouverRareteAvecRetry(brainrotName, maxTentatives)
    maxTentatives = maxTentatives or 3 -- Par défaut 3 tentatives
    for tentative = 1, maxTentatives do
        local rarityText, _ = GetConvoyeurInfo()
        if rarityText then 
            return rarityText
        else
            if tentative < maxTentatives then
                wait(0.2) -- Attendre 0.2s avant de réessayer
            end
        end
    end
    
    warn("⚠️ Impossible de trouver la rareté après", maxTentatives, "tentatives")
    return nil
end
local function AutoBuyEgg()
    while true do
        wait(0.1) -- Attendre 0.1 seconde entre chaque vérification
        local rarityText, brainrotName = GetConvoyeurInfo()
        if brainrotName then
            if not rarityText then
                rarityText = TrouverRareteAvecRetry(brainrotName, 3)
            end
            if rarityText then   
                if EstRareteRecherchee(rarityText) then
                    Networker["RF/BuyEgg"]:InvokeServer(brainrotName, 1)
                    Networker["RF/RequestEggSpawn"]:InvokeServer()
                    wait(0.2) -- Attendre 1 seconde après l'achat
                else               
                    Networker["RF/RequestEggSpawn"]:InvokeServer()
                end
            else
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        else
            Networker["RF/RequestEggSpawn"]:InvokeServer()
        end
    end
end
AutoBuyEgg()