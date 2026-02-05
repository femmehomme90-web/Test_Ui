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
    Divine = false,
    GOD = false,
    Admin = false,
    Event = false,
    Limited = false,
    OG = false,
    Exclusive = false,
    Exotic = false,
    secret = false,
    Mythic = false,
    Legendary = false,
    Epic = false,
    Rare = false,
    Uncommon = false,
    Common = false,
}

-- Statistiques des œufs
local StatsOeufs = {}
local TotalOeufs = 0

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
    MainFrame.Size = UDim2.new(0, 400, 0, 550)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Titre
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.Text = "🥚 Auto Buy Egg"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Bouton Start/Stop
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 360, 0, 40)
    ToggleButton.Position = UDim2.new(0, 20, 0, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    ToggleButton.Text = "▶️ DÉMARRER"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 18
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton
    
    -- ScrollFrame pour les raretés
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "RarityScroll"
    ScrollFrame.Size = UDim2.new(0, 360, 0, 300)
    ScrollFrame.Position = UDim2.new(0, 20, 0, 100)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = MainFrame
    
    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 8)
    ScrollCorner.Parent = ScrollFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollFrame
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)
    UIPadding.Parent = ScrollFrame
    
    -- Création des boutons de rareté
    local yOffset = 0
    local buttons = {}
    
    for rarity, enabled in pairs(RarityConfig) do
        local RarityFrame = Instance.new("Frame")
        RarityFrame.Name = rarity
        RarityFrame.Size = UDim2.new(1, -10, 0, 35)
        RarityFrame.BackgroundColor3 = enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        RarityFrame.BorderSizePixel = 0
        RarityFrame.Parent = ScrollFrame
        
        local RarityCorner = Instance.new("UICorner")
        RarityCorner.CornerRadius = UDim.new(0, 6)
        RarityCorner.Parent = RarityFrame
        
        local RarityButton = Instance.new("TextButton")
        RarityButton.Name = "Button"
        RarityButton.Size = UDim2.new(1, 0, 1, 0)
        RarityButton.BackgroundTransparency = 1
        RarityButton.Text = rarity .. (enabled and " ✓" or " ✗")
        RarityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        RarityButton.TextSize = 16
        RarityButton.Font = Enum.Font.Gotham
        RarityButton.Parent = RarityFrame
        
        local StatsLabel = Instance.new("TextLabel")
        StatsLabel.Name = "Stats"
        StatsLabel.Size = UDim2.new(0, 80, 1, 0)
        StatsLabel.Position = UDim2.new(1, -85, 0, 0)
        StatsLabel.BackgroundTransparency = 1
        StatsLabel.Text = "0 (0%)"
        StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        StatsLabel.TextSize = 14
        StatsLabel.Font = Enum.Font.Gotham
        StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
        StatsLabel.Parent = RarityFrame
        
        buttons[rarity] = {frame = RarityFrame, button = RarityButton, stats = StatsLabel}
        
        RarityButton.MouseButton1Click:Connect(function()
            RarityConfig[rarity] = not RarityConfig[rarity]
            RarityFrame.BackgroundColor3 = RarityConfig[rarity] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
            RarityButton.Text = rarity .. (RarityConfig[rarity] and " ✓" or " ✗")
        end)
        
        yOffset = yOffset + 40
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    -- Label de stats totales
    local TotalStatsLabel = Instance.new("TextLabel")
    TotalStatsLabel.Name = "TotalStats"
    TotalStatsLabel.Size = UDim2.new(0, 360, 0, 30)
    TotalStatsLabel.Position = UDim2.new(0, 20, 0, 410)
    TotalStatsLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TotalStatsLabel.Text = "Total: 0 œufs scannés"
    TotalStatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TotalStatsLabel.TextSize = 14
    TotalStatsLabel.Font = Enum.Font.GothamBold
    TotalStatsLabel.Parent = MainFrame
    
    local TotalCorner = Instance.new("UICorner")
    TotalCorner.CornerRadius = UDim.new(0, 6)
    TotalCorner.Parent = TotalStatsLabel
    
    -- Bouton Reset Stats
    local ResetButton = Instance.new("TextButton")
    ResetButton.Name = "ResetButton"
    ResetButton.Size = UDim2.new(0, 360, 0, 35)
    ResetButton.Position = UDim2.new(0, 20, 0, 450)
    ResetButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ResetButton.Text = "🔄 Réinitialiser les stats"
    ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetButton.TextSize = 14
    ResetButton.Font = Enum.Font.Gotham
    ResetButton.Parent = MainFrame
    
    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetButton
    
    -- Bouton Fermer
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 360, 0, 35)
    CloseButton.Position = UDim2.new(0, 20, 0, 495)
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    CloseButton.Text = "❌ Fermer"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
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
    
    return ScreenGui, ToggleButton, buttons, TotalStatsLabel, ResetButton, CloseButton
end

local GUI, ToggleBtn, RarityButtons, TotalLabel, ResetBtn, CloseBtn = CreerInterface()

-- Fonction de mise à jour des stats
local function MettreAJourStats()
    for rarity, data in pairs(RarityButtons) do
        local count = StatsOeufs[rarity] or 0
        local percentage = TotalOeufs > 0 and math.floor((count / TotalOeufs) * 100) or 0
        data.stats.Text = count .. " (" .. percentage .. "%)"
    end
    TotalLabel.Text = "Total: " .. TotalOeufs .. " œufs scannés"
end

-- Reset des stats
ResetBtn.MouseButton1Click:Connect(function()
    StatsOeufs = {}
    TotalOeufs = 0
    MettreAJourStats()
end)

-- Fermer l'interface
CloseBtn.MouseButton1Click:Connect(function()
    ScriptActif = false
    GUI:Destroy()
end)

-- Toggle du script
ToggleBtn.MouseButton1Click:Connect(function()
    ScriptActif = not ScriptActif
    if ScriptActif then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        ToggleBtn.Text = "⏸️ ARRÊTER"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        ToggleBtn.Text = "▶️ DÉMARRER"
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
                                
                                -- Mise à jour des stats
                                if not StatsOeufs[Rarity.Text] then
                                    StatsOeufs[Rarity.Text] = 0
                                end
                                StatsOeufs[Rarity.Text] = StatsOeufs[Rarity.Text] + 1
                                TotalOeufs = TotalOeufs + 1
                                MettreAJourStats()
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