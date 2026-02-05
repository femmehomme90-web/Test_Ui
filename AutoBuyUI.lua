local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local joueur = Players.LocalPlayer
local MonNomDePlot = joueur:GetAttribute("InPlot")
local MonPlot = workspace.CoreObjects.Plots:FindFirstChild(MonNomDePlot)
local Bank = joueur.leaderstats.Cash:GetAttribute("ExactValue")
local ClientUtils = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("ClientUtils"))
local rebirths = (ClientUtils.ProfileData and ClientUtils.ProfileData.leaderstats and ClientUtils.ProfileData.leaderstats.Rebirths) or 0
local Networker = ReplicatedStorage.Shared.Packages.Networker

-- Configuration des raretés
local RarityConfig = {
    Divine = true,
    GOD = true,
    Admin = true,
    Event = true,
    Limited = true,
    OG = true,
    Exclusive = true,
    Exotic = true,
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

-- Variable de contrôle
local ScriptActif = false

-- Création de l'interface
local function CreerInterface()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoBuyEggGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = joueur:WaitForChild("PlayerGui")
    
    -- Frame principale
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
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
    ToggleButton.Text = "▶  DÉMARRER LE SCRIPT"
    ToggleButton.TextColor3 = Color3.fromRGB(100, 220, 100)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(100, 220, 100)
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleButton
    
    -- Label "Sélectionner les raretés"
    local RarityLabel = Instance.new("TextLabel")
    RarityLabel.Size = UDim2.new(0, 380, 0, 30)
    RarityLabel.Position = UDim2.new(0, 20, 0, 120)
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
    ScrollFrame.Size = UDim2.new(0, 380, 0, 280)
    ScrollFrame.Position = UDim2.new(0, 20, 0, 155)
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
    
    -- Création des boutons de rareté
    local yOffset = 0
    local buttons = {}
    
    for rarity, enabled in pairs(RarityConfig) do
        local RarityFrame = Instance.new("Frame")
        RarityFrame.Name = rarity
        RarityFrame.Size = UDim2.new(1, -20, 0, 40)
        RarityFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        RarityFrame.BorderSizePixel = 0
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
        
        -- Checkbox
        local Checkbox = Instance.new("Frame")
        Checkbox.Name = "Checkbox"
        Checkbox.Size = UDim2.new(0, 24, 0, 24)
        Checkbox.Position = UDim2.new(1, -35, 0.5, -12)
        Checkbox.BackgroundColor3 = enabled and (RarityColors[rarity] or Color3.fromRGB(100, 220, 100)) or Color3.fromRGB(60, 60, 70)
        Checkbox.BorderSizePixel = 0
        Checkbox.Parent = RarityFrame
        
        local CheckboxCorner = Instance.new("UICorner")
        CheckboxCorner.CornerRadius = UDim.new(0, 6)
        CheckboxCorner.Parent = Checkbox
        
        local CheckboxStroke = Instance.new("UIStroke")
        CheckboxStroke.Color = Color3.fromRGB(80, 80, 90)
        CheckboxStroke.Thickness = 1
        CheckboxStroke.Parent = Checkbox
        
        -- Icône check
        local CheckIcon = Instance.new("TextLabel")
        CheckIcon.Name = "CheckIcon"
        CheckIcon.Size = UDim2.new(1, 0, 1, 0)
        CheckIcon.BackgroundTransparency = 1
        CheckIcon.Text = enabled and "✓" or ""
        CheckIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        CheckIcon.TextSize = 18
        CheckIcon.Font = Enum.Font.GothamBold
        CheckIcon.Parent = Checkbox
        
        local RarityButton = Instance.new("TextButton")
        RarityButton.Name = "Button"
        RarityButton.Size = UDim2.new(1, 0, 1, 0)
        RarityButton.BackgroundTransparency = 1
        RarityButton.Text = ""
        RarityButton.Parent = RarityFrame
        
        local RarityText = Instance.new("TextLabel")
        RarityText.Size = UDim2.new(1, -80, 1, 0)
        RarityText.Position = UDim2.new(0, 20, 0, 0)
        RarityText.BackgroundTransparency = 1
        RarityText.Text = rarity
        RarityText.TextColor3 = Color3.fromRGB(255, 255, 255)
        RarityText.TextSize = 15
        RarityText.Font = Enum.Font.GothamMedium
        RarityText.TextXAlignment = Enum.TextXAlignment.Left
        RarityText.Parent = RarityFrame
        
        buttons[rarity] = {frame = RarityFrame, checkbox = Checkbox, icon = CheckIcon}
        
        RarityButton.MouseButton1Click:Connect(function()
            RarityConfig[rarity] = not RarityConfig[rarity]
            
            if RarityConfig[rarity] then
                Checkbox.BackgroundColor3 = RarityColors[rarity] or Color3.fromRGB(100, 220, 100)
                CheckIcon.Text = "✓"
                
                -- Animation
                local TweenService = game:GetService("TweenService")
                local tween = TweenService:Create(Checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
    CloseButton.Position = UDim2.new(0, 20, 0, 445)
    CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    CloseButton.Text = "✕  FERMER"
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = Color3.fromRGB(80, 80, 90)
    CloseStroke.Thickness = 1
    CloseStroke.Parent = CloseButton
    
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
    
    return ScreenGui, ToggleButton, ToggleStroke, buttons, CloseButton
end

local GUI, ToggleBtn, ToggleStroke, RarityButtons, CloseBtn = CreerInterface()

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
        ToggleBtn.Text = "⏸  SCRIPT EN COURS..."
        ToggleBtn.TextColor3 = Color3.fromRGB(100, 220, 100)
        ToggleStroke.Color = Color3.fromRGB(100, 220, 100)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        ToggleBtn.Text = "▶  DÉMARRER LE SCRIPT"
        ToggleBtn.TextColor3 = Color3.fromRGB(100, 220, 100)
        ToggleStroke.Color = Color3.fromRGB(100, 220, 100)
    end
end)

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
    return RarityConfig[rarete] == true
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
                    table.insert(oeufsRaresATrouves, oeuf)
                end
            end
            
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
                Networker["RF/RequestEggSpawn"]:InvokeServer()
            end
        else
            Networker["RF/RequestEggSpawn"]:InvokeServer()
        end
    end
end

AutoBuyEgg()