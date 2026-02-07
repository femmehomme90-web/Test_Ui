-- ========================================
-- AUTO BUY EGG - VERSION LINORIALIB
-- ========================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer
local MonNomDePlot = joueur:GetAttribute("InPlot")
local MonPlot = workspace.CoreObjects.Plots:FindFirstChild(MonNomDePlot)
local Bank = joueur.leaderstats.Cash:GetAttribute("ExactValue")
local ClientUtils = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("ClientUtils"))
local rebirths = (ClientUtils.ProfileData and ClientUtils.ProfileData.leaderstats and ClientUtils.ProfileData.leaderstats.Rebirths) or 0
local Networker = ReplicatedStorage.Shared.Packages.Networker

-- ========================================
-- CONFIGURATION
-- ========================================

-- Configuration des raretés (ORDRE IMPORTANT)
local RarityOrder = {
    "Divine", "GOD", "Admin", "Event", "Limited", "OG", "Exclusive",
    "Exotic", "secret", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

local RarityConfig = {
    Divine = true, GOD = true, Admin = true, Event = false, Limited = true,
    OG = false, Exclusive = true, Exotic = false, secret = false, Mythic = false,
    Legendary = false, Epic = false, Rare = false, Uncommon = false, Common = false
}

local RarityColors = {
    Divine = Color3.fromRGB(255, 215, 0), GOD = Color3.fromRGB(138, 43, 226),
    Admin = Color3.fromRGB(255, 0, 0), Event = Color3.fromRGB(0, 191, 255),
    Limited = Color3.fromRGB(255, 105, 180), OG = Color3.fromRGB(255, 140, 0),
    Exclusive = Color3.fromRGB(147, 112, 219), Exotic = Color3.fromRGB(0, 255, 127),
    secret = Color3.fromRGB(64, 64, 64), Mythic = Color3.fromRGB(255, 20, 147),
    Legendary = Color3.fromRGB(255, 165, 0), Epic = Color3.fromRGB(148, 0, 211),
    Rare = Color3.fromRGB(0, 112, 221), Uncommon = Color3.fromRGB(30, 255, 0),
    Common = Color3.fromRGB(155, 155, 155)
}

local PrixMinimum = 0
local ScriptActif = false

-- ========================================
-- CHARGEMENT LINORIALIB
-- ========================================

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()

-- ========================================
-- CRÉATION DE L'INTERFACE
-- ========================================

local Window = Library:CreateWindow({
    Title = '🥚 Auto Buy Egg',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Création des onglets
local Tabs = {
    Main = Window:AddTab('Principal'),
    Config = Window:AddTab('Raretés'),
    Settings = Window:AddTab('Paramètres')
}

-- ========================================
-- ONGLET PRINCIPAL
-- ========================================

local MainGroup = Tabs.Main:AddLeftGroupbox('Contrôles')

-- Toggle Start/Stop
MainGroup:AddToggle('ScriptToggle', {
    Text = 'Activer le script',
    Default = false,
    Tooltip = 'Démarre ou arrête l\'achat automatique',
    
    Callback = function(Value)
        ScriptActif = Value
        print(Value and "✅ Script démarré" or "⏸ Script arrêté")
    end
})

-- Divider
MainGroup:AddDivider()

-- Label pour afficher le prix minimum actuel
local PrixLabel = MainGroup:AddLabel('Prix minimum: $0', true)

-- Slider pour le nombre de base
local SliderValue = 0
MainGroup:AddSlider('PrixNombre', {
    Text = 'Nombre',
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    
    Callback = function(Value)
        SliderValue = Value
    end
})

-- Dropdown pour le multiplicateur
local Multiplicateurs = {
    {name = 'Aucun (x1)', value = 1},
    {name = 'K - Mille (x1,000)', value = 1e3},
    {name = 'M - Million (x1,000,000)', value = 1e6},
    {name = 'B - Milliard (x1,000,000,000)', value = 1e9},
    {name = 'T - Trillion', value = 1e12},
    {name = 'Qa - Quadrillion', value = 1e15},
    {name = 'Qi - Quintillion', value = 1e18}
}

local MultNames = {}
local MultValues = {}
for _, mult in ipairs(Multiplicateurs) do
    table.insert(MultNames, mult.name)
    MultValues[mult.name] = mult.value
end

MainGroup:AddDropdown('Multiplicateur', {
    Values = MultNames,
    Default = 1,
    Multi = false,
    Text = 'Multiplicateur',
    Tooltip = 'Choisissez le multiplicateur (K, M, B, T, etc.)',
    
    Callback = function(Value)
        local multiplier = MultValues[Value] or 1
        PrixMinimum = SliderValue * multiplier
        
        -- Mise à jour du label
        local function FormatNumber(num)
            if num >= 1e18 then return string.format("%.1fQi", num/1e18)
            elseif num >= 1e15 then return string.format("%.1fQa", num/1e15)
            elseif num >= 1e12 then return string.format("%.1fT", num/1e12)
            elseif num >= 1e9 then return string.format("%.1fB", num/1e9)
            elseif num >= 1e6 then return string.format("%.1fM", num/1e6)
            elseif num >= 1e3 then return string.format("%.1fK", num/1e3)
            else return tostring(num) end
        end
        
        PrixLabel:SetValue('Prix minimum: $' .. FormatNumber(PrixMinimum))
    end
})

-- Boutons rapides
local QuickGroup = Tabs.Main:AddRightGroupbox('Prix rapides')

local QuickPrices = {
    {text = "$1M", value = 1e6},
    {text = "$10M", value = 1e7},
    {text = "$100M", value = 1e8},
    {text = "$1B", value = 1e9},
    {text = "$10B", value = 1e10},
    {text = "$100B", value = 1e11},
    {text = "$1T", value = 1e12},
    {text = "$10T", value = 1e13},
    {text = "$100T", value = 1e14},
}

for _, quick in ipairs(QuickPrices) do
    QuickGroup:AddButton({
        Text = quick.text,
        Func = function()
            PrixMinimum = quick.value
            PrixLabel:SetValue('Prix minimum: ' .. quick.text)
            print("Prix minimum défini à:", quick.text)
        end,
        DoubleClick = false,
        Tooltip = 'Définir le prix minimum à ' .. quick.text
    })
end

-- ========================================
-- ONGLET RARETÉS
-- ========================================

local RareGroup = Tabs.Config:AddLeftGroupbox('Raretés Premium')
local CommonGroup = Tabs.Config:AddRightGroupbox('Raretés Standard')

-- Fonction pour créer les toggles de rareté
local function CreateRarityToggle(group, rarity)
    group:AddToggle('Rarity_' .. rarity, {
        Text = rarity,
        Default = RarityConfig[rarity],
        Tooltip = 'Acheter les œufs de rareté ' .. rarity,
        
        Callback = function(Value)
            RarityConfig[rarity] = Value
        end
    })
end

-- Raretés premium (groupe gauche)
local PremiumRarities = {"Divine", "GOD", "Admin", "Event", "Limited", "OG", "Exclusive", "Exotic"}
for _, rarity in ipairs(PremiumRarities) do
    CreateRarityToggle(RareGroup, rarity)
end

-- Raretés standard (groupe droit)
local StandardRarities = {"secret", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
for _, rarity in ipairs(StandardRarities) do
    CreateRarityToggle(CommonGroup, rarity)
end

-- Boutons de sélection rapide
RareGroup:AddDivider()
RareGroup:AddButton({
    Text = 'Tout sélectionner',
    Func = function()
        for _, rarity in ipairs(RarityOrder) do
            RarityConfig[rarity] = true
            if Library.Toggles['Rarity_' .. rarity] then
                Library.Toggles['Rarity_' .. rarity]:SetValue(true)
            end
        end
    end,
    DoubleClick = false,
})

RareGroup:AddButton({
    Text = 'Tout désélectionner',
    Func = function()
        for _, rarity in ipairs(RarityOrder) do
            RarityConfig[rarity] = false
            if Library.Toggles['Rarity_' .. rarity] then
                Library.Toggles['Rarity_' .. rarity]:SetValue(false)
            end
        end
    end,
    DoubleClick = false,
})

-- ========================================
-- ONGLET PARAMÈTRES
-- ========================================

local UISettings = Tabs.Settings:AddLeftGroupbox('Interface')

UISettings:AddButton({
    Text = 'Décharger le script',
    Func = function()
        Library:Unload()
        ScriptActif = false
        print("Script déchargé")
    end,
    DoubleClick = true,
    Tooltip = 'Double-cliquez pour fermer complètement le script'
})

UISettings:AddLabel('Version: 2.0 - LinoriaLib')
UISettings:AddLabel('Crédits: Auto Buy Egg Script')

-- ========================================
-- GESTION DES THÈMES ET SAUVEGARDES
-- ========================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignorer les thèmes si vous voulez juste une interface simple
-- ThemeManager:SetFolder('AutoBuyEgg')
-- ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:SetFolder('AutoBuyEgg/configs')
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- ========================================
-- FONCTION DE CONVERSION DE PRIX
-- ========================================

local function ConvertirPrixEnNombre(prixTexte)
    if not prixTexte or prixTexte == "N/A" then 
        return 0 
    end
    
    -- Enlever le symbole $ et les espaces
    prixTexte = prixTexte:gsub("%$", ""):gsub("%s+", "")
    
    -- Vérifier si c'est un format avec virgules (ex: 2,500,000)
    if prixTexte:match("^[%d,]+$") then
        local prixSansVirgules = prixTexte:gsub(",", "")
        local nombre = tonumber(prixSansVirgules)
        if nombre then
            return nombre
        end
    end
    
    -- Format avec suffixe (ex: 2.5M, 100K)
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
        return 0
    end
    
    local resultat = nombre
    if suffixe and suffixes[suffixe] then
        resultat = nombre * suffixes[suffixe]
    end
    
    return resultat
end

-- ========================================
-- LOGIQUE PRINCIPALE
-- ========================================

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

-- ========================================
-- DÉMARRAGE
-- ========================================

print("🥚 Auto Buy Egg - LinoriaLib Edition")
print("Interface chargée avec succès!")

-- Lancer la boucle principale
task.spawn(AutoBuyEgg)