local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer
local MonNomDePlot = joueur:GetAttribute("InPlot") -- récupérer le plot du joueur
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

local function GetTousLesOeufs()
    wait(0.1)
    local EggFolder = workspace.CoreObjects.Eggs
    local oeufs = {}
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
                                table.insert(oeufs, {
                                    rarete = Rarity.Text,
                                    nom = model.Name
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    
    return oeufs
end
local function EstRareteRecherchee(rarete)
    for _, rareteRecherchee in ipairs(RaretesRecherchees) do
        if rarete == rareteRecherchee then
            return true
        end
    end
    return false
end
local function TrouverOeufsCompletsAvecRetry(maxTentatives)
    maxTentatives = maxTentatives or 5
    for tentative = 1, maxTentatives do
        local oeufs = GetTousLesOeufs()
        if #oeufs > 0 then 
            print("✅ Œuf(s) trouvé(s) (tentative " .. tentative .. "/" .. maxTentatives .. "):")
            for _, oeuf in ipairs(oeufs) do
                print("  -", oeuf.nom, "-", oeuf.rarete)
            end
            return oeufs
        end
        if tentative < maxTentatives then
            wait(0.1)
        end
    end
    
    return {}
end
local function AutoBuyEgg()
    while true do
        wait(0.1) 
        local oeufs = GetTousLesOeufs()
        if #oeufs == 0 then
            oeufs = TrouverOeufsCompletsAvecRetry(5)
        end
        if #oeufs > 0 then
            local oeufsRaresATrouves = {}
            -- Filtrer les œufs avec raretés recherchées
            for _, oeuf in ipairs(oeufs) do
                if EstRareteRecherchee(oeuf.rarete) then
                    table.insert(oeufsRaresATrouves, oeuf)
                end
            end
            -- Si on a trouvé des œufs rares
            if #oeufsRaresATrouves > 0 then
                print("")
                print("💎 ACHAT DE", #oeufsRaresATrouves, "ŒUF(S) RARE(S) | Cash:", Bank)
                for _, oeuf in ipairs(oeufsRaresATrouves) do
                    print("  - Achat:", oeuf.nom, "-", oeuf.rarete)
                    Networker["RF/BuyEgg"]:InvokeServer(oeuf.nom, 1)
                    Networker["RF/BuyEgg"]:InvokeServer(oeuf.nom, 1)
                end
                print("")
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            else
                -- Aucun œuf rare trouvé
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        else
            -- Aucun œuf trouvé du tout
            Networker["RF/RequestEggSpawn"]:InvokeServer()
        end
    end
end

AutoBuyEgg()