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
    --"God",
    --"Event",
    --"Divine",
    --"Admin",
    --"Exclusive",
}
local function GetConvoyeurInfo()
    wait(0.1)
    local EggFolder = workspace.CoreObjects.Eggs
    for _, model in ipairs(EggFolder:GetChildren()) do
        if model:GetAttribute("CurrentEgg") then

            local meshPart = model:GetChildren()[1]
            
            if meshPart and meshPart:IsA("MeshPart") then
                local billboard = meshPart:FindFirstChild("BillboardAttachment")
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

local function TrouverOeufCompletAvecRetry(maxTentatives)
    maxTentatives = maxTentatives or 5 -- Par défaut 5 tentatives
    
    for tentative = 1, maxTentatives do
        local rarityText, brainrotName = GetConvoyeurInfo()

        if rarityText and brainrotName then 
            print("✅ Œuf trouvé (tentative " .. tentative .. "/" .. maxTentatives .. "):", brainrotName, "-", rarityText)
            return rarityText, brainrotName
        end
        if tentative < maxTentatives then
            wait(0.1)
        end
    end
    return nil, nil
end

local function AutoBuyEgg()
    while true do
        wait(0.1) 
        local rarityText, brainrotName = GetConvoyeurInfo()
        if not brainrotName or not rarityText then
            rarityText, brainrotName = TrouverOeufCompletAvecRetry(5)
        end

        if brainrotName and rarityText then
            if EstRareteRecherchee(rarityText) then
                print("")
                print("💎 ACHAT:", brainrotName, "-", rarityText, "| Cash:", Bank)
                print("")
                Networker["RF/BuyEgg"]:InvokeServer(brainrotName, 1)
                Networker["RF/BuyEgg"]:InvokeServer(brainrotName, 1)
                Networker["RF/BuyEgg"]:InvokeServer(brainrotName, 1)
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            else     
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        else
            Networker["RF/RequestEggSpawn"]:InvokeServer()
        end
    end
end

AutoBuyEgg()