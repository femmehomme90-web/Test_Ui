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
    "Divine",
    "GOD",
    "Admin",
    "Event",
    "Limited",
    "OG",
    "Exclusive",
    "Exotic",
    "secret",
    "Mythic",
    "Legendary",
    "Epic",
    "Rare",
    "Uncommon",
    "Common",
}

local RarityConfig = {
    Divine = true,
    GOD = true,
    Admin = true,
    Event = false,
    Limited = true,
    OG = false,
    Exclusive = true,
    Exotic = false,
    secret = false,
    Mythic = false,
    Legendary = false,
    Epic = false,
    Rare = false,
    Uncommon = false,
    Common = false,
}

-- Couleurs pour chaque rareté
local RarityColors = {
    Divine = Color3.fromRGB(255, 215, 0),      -- Or
    GOD = Color3.fromRGB(138, 43, 226),        -- Violet
    Admin = Color3.fromRGB(255, 0, 0),         -- Rouge vif
    Event = Color3.fromRGB(0, 191, 255),       -- Bleu ciel
    Limited = Color3.fromRGB(255, 105, 180),   -- Rose
    OG = Color3.fromRGB(255, 140, 0),          -- Orange foncé
    Exclusive = Color3.fromRGB(147, 112, 219), -- Violet clair
    Exotic = Color3.fromRGB(0, 255, 127),      -- Vert menthe
    secret = Color3.fromRGB(64, 64, 64),       -- Gris foncé
    Mythic = Color3.fromRGB(255, 20, 147),     -- Rose foncé
    Legendary = Color3.fromRGB(255, 165, 0),   -- Orange
    Epic = Color3.fromRGB(148, 0, 211),        -- Violet foncé
    Rare = Color3.fromRGB(0, 112, 221),        -- Bleu
    Uncommon = Color3.fromRGB(30, 255, 0),     -- Vert
    Common = Color3.fromRGB(155, 155, 155),    -- Gris
}

-- Liste des prix disponibles (en ordre croissant)
local PriceOptions = {
    {text = "Aucun minimum", value = 0},
    {text = "$1M", value = 1000000},
    {text = "$10M", value = 10000000},
    {text = "$50M", value = 50000000},
    {text = "$100M", value = 100000000},
    {text = "$500M", value = 500000000},
    {text = "$1B", value = 1000000000},
    {text = "$10B", value = 10000000000},
    {text = "$50B", value = 50000000000},
    {text = "$100B", value = 100000000000},
    {text = "$500B", value = 500000000000},
    {text = "$1T", value = 1000000000000},
    {text = "$10T", value = 10000000000000},
    {text = "$50T", value = 50000000000000},
    {text = "$100T", value = 100000000000000},
    {text = "$500T", value = 500000000000000},
    {text = "$1Qa", value = 1000000000000000},
    {text = "$10Qa", value = 10000000000000000},
    {text = "$50Qa", value = 50000000000000000},
    {text = "$100Qa", value = 100000000000000000},
    {text = "$500Qa", value = 500000000000000000},
    {text = "$1Qi", value = 1000000000000000000},
}

-- Variable pour stocker le prix minimum sélectionné
local PrixMinimum = 0

-- Fonction pour convertir le texte du prix en nombre
local function ConvertirPrixEnNombre(prixTexte)
    if not prixTexte or prixTexte == "N/A" then
        return 0
    end
    
    -- Enlever le symbole $
    prixTexte = prixTexte:gsub("%$", "")
    
    -- Dictionnaire des suffixes
    local suffixes = {
        ["K"] = 1000,
        ["M"] = 1000000,
        ["B"] = 1000000000,
        ["T"] = 1000000000000,
        ["Qa"] = 1000000000000000,
        ["Qi"] = 1000000000000000000,
    }
    
    -- Extraire le nombre et le suffixe
    local nombre = tonumber(prixTexte:match("^[%d%.]+"))
    local suffixe = prixTexte:match("[KMBTQ][ai]?$")
    
    if not nombre then
        return 0
    end
    
    if suffixe and suffixes[suffixe] then
        return nombre * suffixes[suffixe]
    end
    
    return nombre
end

-- Variable de contrôle
local ScriptActif = false

-- Création de l'interface
local function CreerInterface()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoBuyEggGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = joueur:WaitForChild("PlayerGui")
    
    -- Frame principale (augmenté pour le dropdown)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Ombre
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.Parent = MainFrame
    
    -- Titre
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Title.Text = "🥚 Auto Buy Egg"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Ligne de séparation
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(1, -40, 0, 2)
    Separator.Position = UDim2.new(0, 20, 0, 50)
    Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Separator.BorderSizePixel = 0
    Separator.Parent = MainFrame
    
    -- Bouton Start/Stop
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 380, 0, 45)
    ToggleButton.Position = UDim2.new(0, 20, 0, 65)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ToggleButton.Text = "DEMARRER LE SCRIPT"
    ToggleButton.TextColor3 = Color3.fromRGB(100, 220, 100)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(100, 220, 100)
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleButton
    
    -- Icône pour le bouton
    local ToggleIcon = Instance.new("TextLabel")
    ToggleIcon.Name = "Icon"
    ToggleIcon.Size = UDim2.new(0, 30, 1, 0)
    ToggleIcon.Position = UDim2.new(0, 10, 0, 0)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Text = "▶"
    ToggleIcon.TextColor3 = Color3.fromRGB(100, 220, 100)
    ToggleIcon.TextSize = 18
    ToggleIcon.Font = Enum.Font.Gotham
    ToggleIcon.Parent = ToggleButton
    
    -- Label "Prix minimum"
    local PriceLabel = Instance.new("TextLabel")
    PriceLabel.Size = UDim2.new(0, 380, 0, 25)
    PriceLabel.Position = UDim2.new(0, 20, 0, 120)
    PriceLabel.BackgroundTransparency = 1
    PriceLabel.Text = "Prix minimum de l'œuf :"
    PriceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PriceLabel.TextSize = 14
    PriceLabel.Font = Enum.Font.Gotham
    PriceLabel.TextXAlignment = Enum.TextXAlignment.Left
    PriceLabel.Parent = MainFrame
    
    -- Dropdown pour le prix
    local PriceDropdown = Instance.new("TextButton")
    PriceDropdown.Name = "PriceDropdown"
    PriceDropdown.Size = UDim2.new(0, 380, 0, 40)
    PriceDropdown.Position = UDim2.new(0, 20, 0, 150)
    PriceDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    PriceDropdown.Text = "  " .. PriceOptions[1].text
    PriceDropdown.TextColor3 = Color3.fromRGB(220, 220, 220)
    PriceDropdown.TextSize = 14
    PriceDropdown.Font = Enum.Font.Gotham
    PriceDropdown.TextXAlignment = Enum.TextXAlignment.Left
    PriceDropdown.Parent = MainFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = PriceDropdown
    
    local DropdownStroke = Instance.new("UIStroke")
    DropdownStroke.Color = Color3.fromRGB(80, 80, 90)
    DropdownStroke.Thickness = 1
    DropdownStroke.Parent = PriceDropdown
    
    -- Icône flèche pour le dropdown
    local DropdownArrow = Instance.new("TextLabel")
    DropdownArrow.Name = "Arrow"
    DropdownArrow.Size = UDim2.new(0, 30, 1, 0)
    DropdownArrow.Position = UDim2.new(1, -35, 0, 0)
    DropdownArrow.BackgroundTransparency = 1
    DropdownArrow.Text = "▼"
    DropdownArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropdownArrow.TextSize = 12
    DropdownArrow.Font = Enum.Font.Gotham
    DropdownArrow.Parent = PriceDropdown
    
    -- Frame pour les options du dropdown (initialement invisible)
    local DropdownOptions = Instance.new("ScrollingFrame")
    DropdownOptions.Name = "Options"
    DropdownOptions.Size = UDim2.new(0, 380, 0, 0)
    DropdownOptions.Position = UDim2.new(0, 20, 0, 195)
    DropdownOptions.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    DropdownOptions.BorderSizePixel = 0
    DropdownOptions.ScrollBarThickness = 4
    DropdownOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    DropdownOptions.Visible = false
    DropdownOptions.ClipsDescendants = true
    DropdownOptions.ZIndex = 10
    DropdownOptions.Parent = MainFrame
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 8)
    OptionsCorner.Parent = DropdownOptions
    
    local OptionsStroke = Instance.new("UIStroke")
    OptionsStroke.Color = Color3.fromRGB(80, 80, 90)
    OptionsStroke.Thickness = 1
    OptionsStroke.Parent = DropdownOptions
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Padding = UDim.new(0, 2)
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Parent = DropdownOptions
    
    -- Créer les options du dropdown
    for index, option in ipairs(PriceOptions) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = "Option" .. index
        OptionButton.Size = UDim2.new(1, -10, 0, 35)
        OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        OptionButton.Text = "  " .. option.text
        OptionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        OptionButton.TextSize = 13
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.LayoutOrder = index
        OptionButton.Parent = DropdownOptions
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 6)
        OptionCorner.Parent = OptionButton
        
        -- Effet hover
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end)
        
        -- Sélection
        OptionButton.MouseButton1Click:Connect(function()
            PrixMinimum = option.value
            PriceDropdown.Text = "  " .. option.text
            DropdownOptions.Visible = false
            DropdownArrow.Text = "▼"
            print("💰 Prix minimum configuré:", option.text, "(" .. option.value .. ")")
        end)
    end
    
    DropdownOptions.CanvasSize = UDim2.new(0, 0, 0, #PriceOptions * 37)
    
    -- Toggle du dropdown
    local dropdownOpen = false
    PriceDropdown.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        if dropdownOpen then
            DropdownOptions.Size = UDim2.new(0, 380, 0, 200)
            DropdownOptions.Visible = true
            DropdownArrow.Text = "▲"
        else
            DropdownOptions.Size = UDim2.new(0, 380, 0, 0)
            DropdownOptions.Visible = false
            DropdownArrow.Text = "▼"
        end
    end)
    
    -- Label "Sélectionner les raretés"
    local RarityLabel = Instance.new("TextLabel")
    RarityLabel.Size = UDim2.new(0, 380, 0, 25)
    RarityLabel.Position = UDim2.new(0, 20, 0, 200)
    RarityLabel.BackgroundTransparency = 1
    RarityLabel.Text = "Sélectionner les raretés à acheter :"
    RarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    RarityLabel.TextSize = 14
    RarityLabel.Font = Enum.Font.Gotham
    RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    RarityLabel.Parent = MainFrame
    
    -- ScrollFrame pour les raretés
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "RarityScroll"
    ScrollFrame.Size = UDim2.new(0, 380, 0, 240)
    ScrollFrame.Position = UDim2.new(0, 20, 0, 230)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    ScrollFrame.Parent = MainFrame
    
    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 10)
    ScrollCorner.Parent = ScrollFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollFrame
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    UIPadding.Parent = ScrollFrame
    
    -- Création des boutons de rareté DANS L'ORDRE
    local yOffset = 0
    local buttons = {}
    
    for index, rarity in ipairs(RarityOrder) do
        local enabled = RarityConfig[rarity]
        
        local RarityFrame = Instance.new("Frame")
        RarityFrame.Name = rarity
        RarityFrame.Size = UDim2.new(1, -20, 0, 40)
        RarityFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        RarityFrame.BorderSizePixel = 0
        RarityFrame.LayoutOrder = index
        RarityFrame.Parent = ScrollFrame
        
        local RarityCorner = Instance.new("UICorner")
        RarityCorner.CornerRadius = UDim.new(0, 8)
        RarityCorner.Parent = RarityFrame
        
        -- Indicateur coloré sur le côté gauche
        local ColorIndicator = Instance.new("Frame")
        ColorIndicator.Name = "ColorIndicator"
        ColorIndicator.Size = UDim2.new(0, 5, 1, -10)
        ColorIndicator.Position = UDim2.new(0, 5, 0, 5)
        ColorIndicator.BackgroundColor3 = RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
        ColorIndicator.BorderSizePixel = 0
        ColorIndicator.Parent = RarityFrame
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 3)
        IndicatorCorner.Parent = ColorIndicator
        
        local RarityText = Instance.new("TextLabel")
        RarityText.Name = "RarityText"
        RarityText.Size = UDim2.new(1, -80, 1, 0)
        RarityText.Position = UDim2.new(0, 20, 0, 0)
        RarityText.BackgroundTransparency = 1
        RarityText.Text = rarity
        RarityText.TextColor3 = Color3.fromRGB(220, 220, 220)
        RarityText.TextSize = 14
        RarityText.Font = Enum.Font.Gotham
        RarityText.TextXAlignment = Enum.TextXAlignment.Left
        RarityText.Parent = RarityFrame
        
        local Checkbox = Instance.new("Frame")
        Checkbox.Name = "Checkbox"
        Checkbox.Size = UDim2.new(0, 24, 0, 24)
        Checkbox.Position = UDim2.new(1, -35, 0.5, -12)
        Checkbox.BackgroundColor3 = enabled and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(60, 60, 70)
        Checkbox.BorderSizePixel = 0
        Checkbox.Parent = RarityFrame
        
        local CheckCorner = Instance.new("UICorner")
        CheckCorner.CornerRadius = UDim.new(0, 6)
        CheckCorner.Parent = Checkbox
        
        local CheckIcon = Instance.new("TextLabel")
        CheckIcon.Name = "CheckIcon"
        CheckIcon.Size = UDim2.new(1, 0, 1, 0)
        CheckIcon.BackgroundTransparency = 1
        CheckIcon.Text = enabled and "✓" or ""
        CheckIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        CheckIcon.TextSize = 16
        CheckIcon.Font = Enum.Font.GothamBold
        CheckIcon.Parent = Checkbox
        
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.Parent = RarityFrame
        
        buttons[rarity] = Button
        
        Button.MouseEnter:Connect(function()
            RarityFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end)
        
        Button.MouseLeave:Connect(function()
            RarityFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end)
        
        Button.MouseButton1Click:Connect(function()
            RarityConfig[rarity] = not RarityConfig[rarity]
            if RarityConfig[rarity] then
                Checkbox.BackgroundColor3 = Color3.fromRGB(100, 220, 100)
                CheckIcon.Text = "✓"
                
                local TweenService = game:GetService("TweenService")
                local tween = TweenService:Create(Checkbox, TweenInfo.new(0.1), {
                    Size = UDim2.new(0, 28, 0, 28)
                })
                tween:Play()
                tween.Completed:Connect(function()
                    TweenService:Create(Checkbox, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 24, 0, 24)
                    }):Play()
                end)
            else
                Checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                CheckIcon.Text = ""
            end
        end)
        
        yOffset = yOffset + 48
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    -- Bouton Fermer
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 380, 0, 40)
    CloseButton.Position = UDim2.new(0, 20, 0, 525)
    CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    CloseButton.Text = "FERMER"
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = Color3.fromRGB(80, 80, 90)
    CloseStroke.Thickness = 1
    CloseStroke.Parent = CloseButton
    
    local CloseIcon = Instance.new("TextLabel")
    CloseIcon.Name = "CloseIcon"
    CloseIcon.Size = UDim2.new(0, 30, 1, 0)
    CloseIcon.Position = UDim2.new(0, 10, 0, 0)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Text = "✕"
    CloseIcon.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseIcon.TextSize = 16
    CloseIcon.Font = Enum.Font.Gotham
    CloseIcon.Parent = CloseButton
    
    -- Rendre draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    return ScreenGui, ToggleButton, ToggleIcon, ToggleStroke, buttons, CloseButton
end

local GUI, ToggleBtn, ToggleIcon, ToggleStroke, RarityButtons, CloseBtn = CreerInterface()

-- Fermer l'interface
CloseBtn.MouseButton1Click:Connect(function()
    ScriptActif = false
    GUI:Destroy()
end)

-- Toggle du script
ToggleBtn.MouseButton1Click:Connect(function()
    ScriptActif = not ScriptActif
    if ScriptActif then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
        ToggleBtn.Text = "SCRIPT EN COURS..."
        ToggleBtn.TextColor3 = Color3.fromRGB(100, 220, 100)
        ToggleStroke.Color = Color3.fromRGB(100, 220, 100)
        ToggleIcon.Text = "⏸"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        ToggleBtn.Text = "DEMARRER LE SCRIPT"
        ToggleBtn.TextColor3 = Color3.fromRGB(100, 220, 100)
        ToggleStroke.Color = Color3.fromRGB(100, 220, 100)
        ToggleIcon.Text = "▶"
    end
end)


-------- Logique

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
                -- Vérifier d'abord la rareté, puis le prix
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