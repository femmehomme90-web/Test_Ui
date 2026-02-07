local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer
local MonNomDePlot = joueur:GetAttribute("InPlot")
local MonPlot = workspace.CoreObjects.Plots:FindFirstChild(MonNomDePlot)
local Bank = joueur.leaderstats.Cash:GetAttribute("ExactValue")
local ClientUtils = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("ClientUtils"))
local rebirths = (ClientUtils.ProfileData and ClientUtils.ProfileData.leaderstats and ClientUtils.ProfileData.leaderstats.Rebirths) or 0
local Networker = ReplicatedStorage.Shared.Packages.Networker

-- Chargement de Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration des raretés (ORDRE IMPORTANT) - NOUVELLE RARETÉ "???" AJOUTÉE
local RarityOrder = {
    "???", "Divine", "GOD", "Admin", "Event", "Limited", "OG", "Exclusive",
    "Exotic", "secret", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

local RarityConfig = {
    ["???"] = true, -- Nouvelle rareté activée par défaut
    Divine = true, GOD = true, Admin = true, Event = false, Limited = true,
    OG = false, Exclusive = true, Exotic = false, secret = false, Mythic = false,
    Legendary = false, Epic = false, Rare = false, Uncommon = false, Common = false
}

local RarityColors = {
    ["???"] = Color3.fromRGB(0, 255, 255), -- Couleur cyan pour "???"
    Divine = Color3.fromRGB(255, 215, 0), GOD = Color3.fromRGB(138, 43, 226),
    Admin = Color3.fromRGB(255, 0, 0), Event = Color3.fromRGB(0, 191, 255),
    Limited = Color3.fromRGB(255, 105, 180), OG = Color3.fromRGB(255, 140, 0),
    Exclusive = Color3.fromRGB(147, 112, 219), Exotic = Color3.fromRGB(0, 255, 127),
    secret = Color3.fromRGB(64, 64, 64), Mythic = Color3.fromRGB(255, 20, 147),
    Legendary = Color3.fromRGB(255, 165, 0), Epic = Color3.fromRGB(148, 0, 211),
    Rare = Color3.fromRGB(0, 112, 221), Uncommon = Color3.fromRGB(30, 255, 0),
    Common = Color3.fromRGB(155, 155, 155)
}

local PriceOptions = {
    {text = "Aucun", value = 0}, {text = "$1M", value = 1e6}, {text = "$10M", value = 1e7},
    {text = "$50M", value = 5e7}, {text = "$100M", value = 1e8}, {text = "$500M", value = 5e8},
    {text = "$1B", value = 1e9}, {text = "$10B", value = 1e10}, {text = "$50B", value = 5e10},
    {text = "$100B", value = 1e11}, {text = "$500B", value = 5e11}, {text = "$1T", value = 1e12},
    {text = "$10T", value = 1e13}, {text = "$50T", value = 5e13}, {text = "$100T", value = 1e14},
    {text = "$500T", value = 5e14}, {text = "$1Qa", value = 1e15}, {text = "$10Qa", value = 1e16},
    {text = "$50Qa", value = 5e16}, {text = "$100Qa", value = 1e17}, {text = "$500Qa", value = 5e17},
    {text = "$1Qi", value = 1e18}
}

local PrixMinimum = 0
local ScriptActif = false

-- Fonction pour convertir le texte du prix en nombre
local function ConvertirPrixEnNombre(prixTexte)
    if not prixTexte or prixTexte == "N/A" then 
        return 0 
    end
    
    prixTexte = prixTexte:gsub("%$", ""):gsub("%s+", "")
    
    if prixTexte:match("^[%d,]+$") then
        local prixSansVirgules = prixTexte:gsub(",", "")
        local nombre = tonumber(prixSansVirgules)
        if nombre then
            return nombre
        end
    end
    
    local suffixes = {
        ["K"] = 1e3,
        ["M"] = 1e6,
        ["B"] = 1e9,
        ["T"] = 1e12,
        ["Qa"] = 1e15,
        ["Qi"] = 1e18,
    }
    
    local nombre = tonumber(prixTexte:match("^[%d%.]+"))
    local suffixe = prixTexte:match("[KMBTQ][ai]?$")
    
    if not nombre then
        print("❌ Impossible d'extraire le nombre de:", prixTexte)
        return 0
    end
    
    local resultat = nombre
    if suffixe and suffixes[suffixe] then
        resultat = nombre * suffixes[suffixe]
    end
    
    return resultat
end

-- Création de l'interface Rayfield
local Window = Rayfield:CreateWindow({
    Name = "🥚 Auto Buy Egg",
    LoadingTitle = "Chargement de l'interface",
    LoadingSubtitle = "par votre script",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AutoBuyEggConfig",
        FileName = "config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Onglet Principal
local MainTab = Window:CreateTab("🏠 Principal", nil)
local MainSection = MainTab:CreateSection("Contrôles")

-- Toggle pour activer/désactiver le script
local ToggleScript = MainTab:CreateToggle({
    Name = "▶ Activer le script",
    CurrentValue = false,
    Flag = "ToggleScript",
    Callback = function(Value)
        ScriptActif = Value
        if Value then
            Rayfield:Notify({
                Title = "Script activé",
                Content = "L'auto-achat est maintenant actif",
                Duration = 3,
                Image = nil,
            })
        else
            Rayfield:Notify({
                Title = "Script désactivé",
                Content = "L'auto-achat est maintenant inactif",
                Duration = 3,
                Image = nil,
            })
        end
    end,
})

-- Section Prix
local PriceSection = MainTab:CreateSection("💰 Configuration du prix minimum")

-- Input pour prix personnalisé
local PriceInput = MainTab:CreateInput({
    Name = "Prix minimum personnalisé",
    PlaceholderText = "Entrer un montant (ex: 1000000)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local nombre = tonumber(Text)
        if nombre then
            PrixMinimum = nombre
            Rayfield:Notify({
                Title = "Prix minimum défini",
                Content = "Nouveau prix: $" .. Text,
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Veuillez entrer un nombre valide",
                Duration = 3,
            })
        end
    end,
})

-- Dropdown pour prix prédéfinis
local PriceDropdown = MainTab:CreateDropdown({
    Name = "Prix minimum rapide",
    Options = {"Aucun", "$1M", "$10M", "$50M", "$100M", "$500M", "$1B", "$10B", "$50B", "$100B", "$500B", "$1T", "$10T", "$50T", "$100T", "$500T", "$1Qa", "$10Qa", "$50Qa", "$100Qa", "$500Qa", "$1Qi"},
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Flag = "PriceDropdown",
    Callback = function(Option)
        for _, priceOption in ipairs(PriceOptions) do
            if priceOption.text == Option then
                PrixMinimum = priceOption.value
                Rayfield:Notify({
                    Title = "Prix minimum défini",
                    Content = Option,
                    Duration = 3,
                })
                break
            end
        end
    end,
})

-- Onglet Raretés
local RarityTab = Window:CreateTab("✨ Raretés", nil)
local RaritySection = RarityTab:CreateSection("Sélection des raretés à acheter")

-- Créer un toggle pour chaque rareté
for _, rarity in ipairs(RarityOrder) do
    RarityTab:CreateToggle({
        Name = rarity,
        CurrentValue = RarityConfig[rarity],
        Flag = "Rarity_" .. rarity,
        Callback = function(Value)
            RarityConfig[rarity] = Value
            print("Rareté " .. rarity .. ":", Value and "activée" or "désactivée")
        end,
    })
end

-- Onglet Statistiques
local StatsTab = Window:CreateTab("📊 Statistiques", nil)
local StatsSection = StatsTab:CreateSection("Informations")

local StatsLabel = StatsTab:CreateLabel("En attente de données...")

-- Mettre à jour les stats périodiquement
task.spawn(function()
    while true do
        wait(2)
        if ScriptActif then
            local oeufs = GetTousLesOeufs()
            StatsLabel:Set("Œufs disponibles: " .. #oeufs .. " | Prix min: $" .. tostring(PrixMinimum))
        end
    end
end)

-------- Logique d'achat (identique à l'original)

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
                            local EggName = EggFrame:FindFirstChild("EggName")
                            local Price = EggFrame:FindFirstChild("Price")
                            
                            if Rarity and Rarity:IsA("TextLabel") then
                                local prixTexte = Price and Price.Text or "N/A"
                                local prixNombre = ConvertirPrixEnNombre(prixTexte)
                                
                                table.insert(oeufs, {
                                    rarete = Rarity.Text,
                                    nom = model.Name,
                                    nomAffiche = EggName and EggName.Text or "N/A",
                                    prixTexte = prixTexte,
                                    prixNombre = prixNombre
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
    return RarityConfig[rarete] == true
end

local function EstPrixSuffisant(prixNombre)
    return prixNombre >= PrixMinimum
end

local function TrouverOeufsCompletsAvecRetry(maxTentatives)
    maxTentatives = maxTentatives or 5
    
    for tentative = 1, maxTentatives do
        local oeufs = GetTousLesOeufs()

        if #oeufs > 0 then 
            print("✅ Œuf(s) trouvé(s) (tentative " .. tentative .. "/" .. maxTentatives .. "):")
            for _, oeuf in ipairs(oeufs) do
                print("  -", oeuf.nom, "-", oeuf.rarete, "-", oeuf.prixTexte)
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
        
        if not ScriptActif then
            wait(1)
            continue
        end
        
        local oeufs = GetTousLesOeufs()
        
        if #oeufs == 0 then
            oeufs = TrouverOeufsCompletsAvecRetry(5)
        end

        if #oeufs > 0 then
            local oeufsRaresATrouves = {}
            
            for _, oeuf in ipairs(oeufs) do
                if EstRareteRecherchee(oeuf.rarete) then
                    if EstPrixSuffisant(oeuf.prixNombre) then
                        table.insert(oeufsRaresATrouves, oeuf)
                    end
                end
            end
            
            if #oeufsRaresATrouves > 0 then              
                for _, oeuf in ipairs(oeufsRaresATrouves) do
                    print("✅ Achat:", oeuf.nom, "-", oeuf.rarete, "-", oeuf.prixTexte)
                    Networker["RF/BuyEgg"]:InvokeServer(oeuf.nom, 1)
                    Networker["RF/BuyEgg"]:InvokeServer(oeuf.nom, 1)
                end
                
                print("")
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            else
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        else
            Networker["RF/RequestEggSpawn"]:InvokeServer()
        end
    end
end

-- Démarrer le script d'achat automatique
task.spawn(AutoBuyEgg)

Rayfield:LoadConfiguration()