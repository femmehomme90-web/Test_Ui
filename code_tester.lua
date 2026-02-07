local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer
local MonNomDePlot = joueur:GetAttribute("InPlot")
local MonPlot = workspace.CoreObjects.Plots:FindFirstChild(MonNomDePlot)
local Bank = joueur.leaderstats.Cash:GetAttribute("ExactValue")
local ClientUtils = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("ClientUtils"))
local rebirths = (ClientUtils.ProfileData and ClientUtils.ProfileData.leaderstats and ClientUtils.ProfileData.leaderstats.Rebirths) or 0
local Networker = ReplicatedStorage.Shared.Packages.Networker

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

-- Fonction utilitaire pour créer des éléments UI
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop == "Parent" then
            continue
        end
        element[prop] = value
    end
    if properties.Parent then
        element.Parent = properties.Parent
    end
    return element
end

-- Fonction pour ajouter un corner arrondi
local function AddCorner(parent, radius)
    return CreateElement("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

-- Fonction pour convertir le texte du prix en nombre
local function ConvertirPrixEnNombre(prixTexte)
    if not prixTexte or prixTexte == "N/A" then return 0 end
    prixTexte = prixTexte:gsub("%$", "")
    local suffixes = {["K"] = 1e3, ["M"] = 1e6, ["B"] = 1e9, ["T"] = 1e12, ["Qa"] = 1e15, ["Qi"] = 1e18}
    local nombre = tonumber(prixTexte:match("^[%d%.]+"))
    local suffixe = prixTexte:match("[KMBTQ][ai]?$")
    if not nombre then return 0 end
    return suffixe and suffixes[suffixe] and (nombre * suffixes[suffixe]) or nombre
end

-- Création de l'interface SIMPLIFIÉE
local function CreerInterface()
    local gui = CreateElement("ScreenGui", {
        Name = "AutoBuyEggGUI",
        ResetOnSpawn = false,
        Parent = joueur:WaitForChild("PlayerGui")
    })
    
    -- Frame principale
    local main = CreateElement("Frame", {
        Size = UDim2.new(0, 380, 0, 520),
        Position = UDim2.new(0.5, -190, 0.5, -260),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BorderSizePixel = 0,
        Parent = gui
    })
    AddCorner(main, 12)
    
    -- Titre
    local title = CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        Text = "🥚 Auto Buy Egg",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = main
    })
    AddCorner(title, 12)
    
    -- Bouton Start/Stop
    local toggleBtn = CreateElement("TextButton", {
        Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 15, 0, 60),
        BackgroundColor3 = Color3.fromRGB(40, 180, 40),
        Text = "▶ DEMARRER",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Parent = main
    })
    AddCorner(toggleBtn, 8)
    
    -- Label prix minimum
    CreateElement("TextLabel", {
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 110),
        BackgroundTransparency = 1,
        Text = "Prix minimum :",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = main
    })
    
    -- Dropdown prix
    local dropdownBtn = CreateElement("TextButton", {
        Size = UDim2.new(1, -30, 0, 35),
        Position = UDim2.new(0, 15, 0, 133),
        BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        Text = "Aucun minimum ▼",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Parent = main
    })
    AddCorner(dropdownBtn, 6)
    
    -- Menu dropdown (caché par défaut)
    local dropdownMenu = CreateElement("Frame", {
        Size = UDim2.new(1, -30, 0, 150),
        Position = UDim2.new(0, 15, 0, 170),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
        Parent = main
    })
    AddCorner(dropdownMenu, 6)
    
    local dropdownScroll = CreateElement("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, #PriceOptions * 30),
        Parent = dropdownMenu
    })
    
    -- Créer les options du dropdown
    for i, option in ipairs(PriceOptions) do
        local optionBtn = CreateElement("TextButton", {
            Size = UDim2.new(1, -10, 0, 28),
            Position = UDim2.new(0, 5, 0, (i-1) * 30),
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            Text = option.text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Parent = dropdownScroll
        })
        AddCorner(optionBtn, 4)
        
        optionBtn.MouseButton1Click:Connect(function()
            PrixMinimum = option.value
            dropdownBtn.Text = option.text .. " ▼"
            dropdownMenu.Visible = false
        end)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
    end)
    
    -- Label raretés
    CreateElement("TextLabel", {
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 180),
        BackgroundTransparency = 1,
        Text = "Raretés à acheter :",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = main
    })
    
    -- Scroll frame pour raretés
    local scroll = CreateElement("ScrollingFrame", {
        Size = UDim2.new(1, -30, 0, 240),
        Position = UDim2.new(0, 15, 0, 205),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        Parent = main
    })
    AddCorner(scroll, 6)
    
    local buttons = {}
    local yPos = 0
    
    for _, rarity in ipairs(RarityOrder) do
        local frame = CreateElement("Frame", {
            Size = UDim2.new(1, -10, 0, 35),
            Position = UDim2.new(0, 5, 0, yPos),
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            Parent = scroll
        })
        AddCorner(frame, 6)
        
        local checkbox = CreateElement("TextButton", {
            Size = UDim2.new(0, 25, 0, 25),
            Position = UDim2.new(0, 5, 0.5, -12.5),
            BackgroundColor3 = RarityConfig[rarity] and RarityColors[rarity] or Color3.fromRGB(60, 60, 65),
            Text = RarityConfig[rarity] and "✓" or "",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            Parent = frame
        })
        AddCorner(checkbox, 4)
        
        CreateElement("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = rarity,
            TextColor3 = RarityColors[rarity],
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        buttons[rarity] = checkbox
        
        checkbox.MouseButton1Click:Connect(function()
            RarityConfig[rarity] = not RarityConfig[rarity]
            checkbox.BackgroundColor3 = RarityConfig[rarity] and RarityColors[rarity] or Color3.fromRGB(60, 60, 65)
            checkbox.Text = RarityConfig[rarity] and "✓" or ""
        end)
        
        yPos = yPos + 40
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
    
    -- Bouton fermer
    local closeBtn = CreateElement("TextButton", {
        Size = UDim2.new(1, -30, 0, 35),
        Position = UDim2.new(0, 15, 1, -45),
        BackgroundColor3 = Color3.fromRGB(180, 40, 40),
        Text = "✕ FERMER",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = main
    })
    AddCorner(closeBtn, 8)
    
    -- Système de drag
    local dragging, dragInput, mousePos, framePos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = main.Position
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    
    return gui, toggleBtn, buttons, closeBtn
end

local GUI, ToggleBtn, RarityButtons, CloseBtn = CreerInterface()

-- Fermer l'interface
CloseBtn.MouseButton1Click:Connect(function()
    ScriptActif = false
    GUI:Destroy()
end)

-- Toggle du script
ToggleBtn.MouseButton1Click:Connect(function()
    ScriptActif = not ScriptActif
    if ScriptActif then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleBtn.Text = "⏸ ARRETER"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        ToggleBtn.Text = "▶ DEMARRER"
    end
end)

-------- Logique (identique à l'original)

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
                if EstRareteRecherchee(oeuf.rarete) and EstPrixSuffisant(oeuf.prixNombre) then
                    table.insert(oeufsRaresATrouves, oeuf)
                elseif EstRareteRecherchee(oeuf.rarete) and not EstPrixSuffisant(oeuf.prixNombre) then
                    print("⚠️ Œuf ignoré (prix trop bas):", oeuf.nom, "-", oeuf.rarete, "-", oeuf.prixTexte)
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

AutoBuyEgg()