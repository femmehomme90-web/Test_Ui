-- ======================================================
-- 🔧 SERVICES & VARIABLES DE BASE
-- ======================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer

local Networker = ReplicatedStorage.Shared.Packages.Networker
local ClientUtils = require(ReplicatedStorage.Client.Modules.ClientUtils)

local PrixMinimum = 0
local ScriptActif = false
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rayfield-Development/Rayfield/master/source"))()

-- ======================================================
-- 🧬 RARETÉS
-- ======================================================
local RarityOrder = {
    "Divine","GOD","Admin","Event","Limited","OG","Exclusive",
    "Exotic","secret","Mythic","Legendary","Epic","Rare","Uncommon","Common"
}

local RarityConfig = {
    Divine = true, GOD = true, Admin = true, Event = false, Limited = true,
    OG = false, Exclusive = true, Exotic = false, secret = false,
    Mythic = false, Legendary = false, Epic = false, Rare = false,
    Uncommon = false, Common = false
}

-- ======================================================
-- 💰 PRIX RAPIDES
-- ======================================================
local PriceOptions = {
    {text="Aucun",value=0},{text="$1M",value=1e6},{text="$10M",value=1e7},
    {text="$50M",value=5e7},{text="$100M",value=1e8},{text="$500M",value=5e8},
    {text="$1B",value=1e9},{text="$10B",value=1e10},{text="$50B",value=5e10},
    {text="$100B",value=1e11},{text="$500B",value=5e11},{text="$1T",value=1e12},
    {text="$10T",value=1e13},{text="$50T",value=5e13},{text="$100T",value=1e14},
    {text="$500T",value=5e14},{text="$1Qa",value=1e15},{text="$10Qa",value=1e16},
    {text="$50Qa",value=5e16},{text="$100Qa",value=1e17},{text="$500Qa",value=5e17},
    {text="$1Qi",value=1e18}
}

-- ======================================================
-- 🧮 CONVERSION PRIX TEXTE → NOMBRE
-- ======================================================
local function ConvertirPrixEnNombre(prixTexte)
    if not prixTexte or prixTexte == "N/A" then return 0 end
    prixTexte = prixTexte:gsub("%$",""):gsub("%s+","")

    if prixTexte:match("^[%d,]+$") then
        return tonumber(prixTexte:gsub(",","")) or 0
    end

    local suffixes = {
        K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18
    }

    local n = tonumber(prixTexte:match("^[%d%.]+"))
    local s = prixTexte:match("[KMBTQ][ai]?$")
    if not n then return 0 end

    return s and suffixes[s] and n * suffixes[s] or n
end

-- ======================================================
-- 🖥️ RAYFIELD UI
-- ======================================================


local Window = Rayfield:CreateWindow({
    Name = "🥚 Auto Buy Egg",
    LoadingTitle = "Auto Buy Egg",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AutoBuyEgg",
        FileName = "config"
    },
    KeySystem = false
})

-- ======================================================
-- 🏠 ONGLET PRINCIPAL
-- ======================================================
local MainTab = Window:CreateTab("🏠 Principal")

MainTab:CreateToggle({
    Name = "▶ Activer l'auto-buy",
    CurrentValue = false,
    Callback = function(v)
        ScriptActif = v
        Rayfield:Notify({
            Title = v and "Activé" or "Désactivé",
            Content = v and "Auto-buy en cours" or "Auto-buy arrêté",
            Duration = 2
        })
    end
})

-- ======================================================
-- 💰 PRIX PERSONNALISÉ
-- ======================================================
local CustomValue = 0
local CustomMultiplier = 1

local function UpdatePrix()
    PrixMinimum = CustomValue * CustomMultiplier
    print("💰 Prix minimum =", PrixMinimum)
end

MainTab:CreateInput({
    Name = "Valeur du prix",
    PlaceholderText = "Ex: 8",
    Callback = function(text)
        CustomValue = tonumber(text) or 0
        UpdatePrix()
    end
})

MainTab:CreateDropdown({
    Name = "Suffixe",
    Options = {"x1","K","M","B","T","Qa","Qi"},
    CurrentOption = {"x1"},
    MultipleOptions = false,
    Callback = function(opt)
        local s = opt[1]
        local map = {
            ["x1"]=1, K=1e3, M=1e6, B=1e9, T=1e12, Qa=1e15, Qi=1e18
        }
        CustomMultiplier = map[s] or 1
        UpdatePrix()
    end
})

-- ======================================================
-- ⚡ PRIX RAPIDES
-- ======================================================
local quick = {}
for _,p in ipairs(PriceOptions) do table.insert(quick,p.text) end

MainTab:CreateDropdown({
    Name = "Prix minimum rapide",
    Options = quick,
    CurrentOption = {"Aucun"},
    MultipleOptions = false,
    Callback = function(opt)
        local selected = opt[1]
        for _,p in ipairs(PriceOptions) do
            if p.text == selected then
                PrixMinimum = p.value
                Rayfield:Notify({
                    Title = "Prix défini",
                    Content = selected,
                    Duration = 2
                })
                break
            end
        end
    end
})

-- ======================================================
-- ✨ ONGLET RARETÉS
-- ======================================================
local RarityTab = Window:CreateTab("✨ Raretés")

for _,r in ipairs(RarityOrder) do
    RarityTab:CreateToggle({
        Name = r,
        CurrentValue = RarityConfig[r],
        Callback = function(v)
            RarityConfig[r] = v
        end
    })
end

-- ======================================================
-- 📊 ONGLET STATS
-- ======================================================
local StatsTab = Window:CreateTab("📊 Stats")
local StatsLabel = StatsTab:CreateLabel("En attente...")

task.spawn(function()
    while true do
        task.wait(1)
        StatsLabel:Set(
            "Actif : "..tostring(ScriptActif)..
            "\nPrix min : $"..tostring(PrixMinimum)
        )
    end
end)

-- ======================================================
-- 🤖 LOGIQUE AUTO BUY (INCHANGÉE)
-- ======================================================
local function GetTousLesOeufs()
    local EggFolder = workspace.CoreObjects.Eggs
    local oeufs = {}

    for _,model in ipairs(EggFolder:GetChildren()) do
        if model:GetAttribute("CurrentEgg") then
            local part = model:GetChildren()[1]
            local billboard = part and part:FindFirstChild("BillboardAttachment")
            local frame = billboard and billboard:FindFirstChild("EggBillboard")
                and billboard.EggBillboard:FindFirstChild("Frame")

            if frame then
                local Rarity = frame:FindFirstChild("Rarity")
                local Name = frame:FindFirstChild("EggName")
                local Price = frame:FindFirstChild("Price")

                if Rarity then
                    local ptxt = Price and Price.Text or "N/A"
                    table.insert(oeufs,{
                        nom=model.Name,
                        rarete=Rarity.Text,
                        prixTexte=ptxt,
                        prixNombre=ConvertirPrixEnNombre(ptxt)
                    })
                end
            end
        end
    end
    return oeufs
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not ScriptActif then continue end

        for _,oeuf in ipairs(GetTousLesOeufs()) do
            if RarityConfig[oeuf.rarete] and oeuf.prixNombre >= PrixMinimum then
                Networker["RF/BuyEgg"]:InvokeServer(oeuf.nom,1)
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        end
    end
end)
