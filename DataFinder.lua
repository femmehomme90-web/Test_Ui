-- Script d'exploration d'objets Roblox avec interface
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local PathInput = Instance.new("TextBox")
local ScanButton = Instance.new("TextButton")
local ClearButton = Instance.new("TextButton")
local CopyButton = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local OutputLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

-- Protection contre les anticheat
ScreenGui.Name = "ExplorerGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principale
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true

-- Coins arrondis
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Titre
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "📦 Object Explorer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18

-- Input pour le path
PathInput.Name = "PathInput"
PathInput.Parent = MainFrame
PathInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PathInput.BorderSizePixel = 0
PathInput.Position = UDim2.new(0.05, 0, 0, 50)
PathInput.Size = UDim2.new(0.9, 0, 0, 35)
PathInput.Font = Enum.Font.Gotham
PathInput.PlaceholderText = "Exemple: game.Workspace.Plots"
PathInput.Text = ""
PathInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PathInput.TextSize = 14
PathInput.ClearTextOnFocus = false

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = PathInput

-- Bouton Scan
ScanButton.Name = "ScanButton"
ScanButton.Parent = MainFrame
ScanButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
ScanButton.BorderSizePixel = 0
ScanButton.Position = UDim2.new(0.05, 0, 0, 95)
ScanButton.Size = UDim2.new(0.9, 0, 0, 35)
ScanButton.Font = Enum.Font.GothamBold
ScanButton.Text = "🔍 SCANNER"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.TextSize = 14

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 6)
ScanCorner.Parent = ScanButton

-- Frame de scroll pour l'output
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 140)
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 270)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollFrame

-- Label pour l'output
OutputLabel.Name = "OutputLabel"
OutputLabel.Parent = ScrollFrame
OutputLabel.BackgroundTransparency = 1
OutputLabel.Size = UDim2.new(1, -10, 1, 0)
OutputLabel.Position = UDim2.new(0, 5, 0, 5)
OutputLabel.Font = Enum.Font.Code
OutputLabel.Text = "Entrez un path et cliquez sur SCANNER"
OutputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
OutputLabel.TextSize = 12
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.TextYAlignment = Enum.TextYAlignment.Top
OutputLabel.TextWrapped = true

-- Bouton Clear
ClearButton.Name = "ClearButton"
ClearButton.Parent = MainFrame
ClearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearButton.BorderSizePixel = 0
ClearButton.Position = UDim2.new(0.05, 0, 0, 420)
ClearButton.Size = UDim2.new(0.43, 0, 0, 35)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Text = "🗑️ EFFACER"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 13

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearButton

-- Bouton Copy
CopyButton.Name = "CopyButton"
CopyButton.Parent = MainFrame
CopyButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
CopyButton.BorderSizePixel = 0
CopyButton.Position = UDim2.new(0.52, 0, 0, 420)
CopyButton.Size = UDim2.new(0.43, 0, 0, 35)
CopyButton.Font = Enum.Font.GothamBold
CopyButton.Text = "📋 COPIER"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 13

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyButton

-- Bouton fermer
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Variable globale pour stocker le résultat
local currentOutput = ""

-- Fonction pour obtenir un objet depuis un path
local function getObjectFromPath(path)
    local success, result = pcall(function()
        return loadstring("return " .. path)()
    end)
    
    if success then
        return result
    else
        return nil
    end
end

-- Fonction pour scanner l'objet
local function scanObject(obj)
    if not obj then
        return "❌ ERREUR: Objet introuvable !\n"
    end
    
    local output = ""
    output = output .. "═══════════════════════════════════════\n"
    output = output .. "📦 OBJET: " .. tostring(obj) .. "\n"
    output = output .. "🏷️  NOM: " .. obj.Name .. "\n"
    output = output .. "📂 CLASSE: " .. obj.ClassName .. "\n"
    output = output .. "═══════════════════════════════════════\n\n"
    
    -- Propriétés
    output = output .. "⚙️  PROPRIÉTÉS:\n"
    output = output .. "───────────────────────────────────────\n"
    
    local properties = {}
    for _, prop in pairs({"Name", "ClassName", "Parent", "Archivable"}) do
        pcall(function()
            local value = obj[prop]
            table.insert(properties, {prop, tostring(value)})
        end)
    end
    
    -- Essayer d'obtenir d'autres propriétés communes
    local commonProps = {
        "Value", "Position", "Size", "Color", "Transparency", 
        "Material", "BrickColor", "Anchored", "CanCollide",
        "CFrame", "Orientation", "Visible", "Text", "TextColor3",
        "BackgroundColor3", "Owner", "MaxHealth", "Health"
    }
    
    for _, prop in pairs(commonProps) do
        pcall(function()
            local value = obj[prop]
            table.insert(properties, {prop, tostring(value)})
        end)
    end
    
    for _, propData in pairs(properties) do
        output = output .. "  • " .. propData[1] .. " = " .. propData[2] .. "\n"
    end
    
    -- Enfants
    output = output .. "\n👶 ENFANTS (" .. #obj:GetChildren() .. "):\n"
    output = output .. "───────────────────────────────────────\n"
    
    local children = obj:GetChildren()
    if #children == 0 then
        output = output .. "  (aucun enfant)\n"
    else
        for i, child in pairs(children) do
            output = output .. string.format("  [%d] %s (%s)\n", i, child.Name, child.ClassName)
            output = output .. "      ↳ Path: " .. child:GetFullName() .. "\n"
        end
    end
    
    output = output .. "\n═══════════════════════════════════════\n"
    
    return output
end

-- Bouton Scan
ScanButton.MouseButton1Click:Connect(function()
    local path = PathInput.Text
    
    if path == "" then
        OutputLabel.Text = "⚠️  Veuillez entrer un path !"
        return
    end
    
    OutputLabel.Text = "⏳ Scan en cours..."
    wait(0.1)
    
    local obj = getObjectFromPath(path)
    currentOutput = scanObject(obj)
    OutputLabel.Text = currentOutput
    
    -- Ajuster la taille du canvas
    local textSize = game:GetService("TextService"):GetTextSize(
        currentOutput,
        OutputLabel.TextSize,
        OutputLabel.Font,
        Vector2.new(ScrollFrame.AbsoluteSize.X - 10, math.huge)
    )
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
end)

-- Bouton Clear
ClearButton.MouseButton1Click:Connect(function()
    OutputLabel.Text = "Entrez un path et cliquez sur SCANNER"
    currentOutput = ""
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Bouton Copy (compatible Android)
CopyButton.MouseButton1Click:Connect(function()
    if currentOutput == "" then
        OutputLabel.Text = "⚠️  Rien à copier !"
        return
    end
    
    -- Méthode pour Android/Mobile
    pcall(function()
        setclipboard(currentOutput)
    end)
    
    -- Feedback visuel
    local originalText = CopyButton.Text
    CopyButton.Text = "✅ COPIÉ!"
    wait(1.5)
    CopyButton.Text = originalText
end)

-- Bouton Close
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("✅ Object Explorer chargé avec succès!")