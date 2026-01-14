-- UI.lua - Interface principale
-- À charger en PREMIER avec ton executor

print("[UI] Démarrage du chargement de l'interface...")

local UI = {}
UI.Callbacks = {}

print("[UI] Initialisation des callbacks...")

-- Initialisation des callbacks pour chaque page
for i = 1, 4 do
    UI.Callbacks["Page" .. i] = {
        Button1 = function() print("[UI] Page " .. i .. " - Button 1 non configuré") end,
        Button2 = function() print("[UI] Page " .. i .. " - Button 2 non configuré") end,
        Button3 = function() print("[UI] Page " .. i .. " - Button 3 non configuré") end,
        Slider = function(value) print("[UI] Page " .. i .. " - Slider: " .. value) end
    }
end

print("[UI] Callbacks initialisés pour 4 pages")

-- Création de l'interface (simple et compatible mobile)
print("[UI] Création des composants UI...")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local TabContainer = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local CloseButton = Instance.new("TextButton")

-- Configuration ScreenGui
ScreenGui.Name = "CustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protection
print("[UI] Tentative de parenting dans CoreGui...")
local success, parent = pcall(function()
    return game:GetService("CoreGui")
end)

if not success then
    print("[UI] CoreGui non accessible, utilisation de PlayerGui")
    parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
else
    print("[UI] CoreGui accessible")
end

ScreenGui.Parent = parent
print("[UI] ScreenGui créé et parenté avec succès")

-- Configuration MainFrame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

print("[UI] MainFrame configuré (draggable activé)")

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Custom Script UI"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18

-- Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 5)

CloseButton.MouseButton1Click:Connect(function()
    print("[UI] Bouton de fermeture cliqué - Destruction de l'interface")
    ScreenGui:Destroy()
end)

print("[UI] Bouton de fermeture créé")

-- Tab Container
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.Size = UDim2.new(1, -20, 0, 35)

-- Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.Size = UDim2.new(1, -20, 1, -100)

print("[UI] Containers créés")

-- Fonction pour créer un bouton de tab
local function createTab(pageNum, position)
    local tab = Instance.new("TextButton")
    tab.Name = "Tab" .. pageNum
    tab.Parent = TabContainer
    tab.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    tab.Position = UDim2.new(position, 0, 0, 0)
    tab.Size = UDim2.new(0.23, 0, 1, 0)
    tab.Font = Enum.Font.Gotham
    tab.Text = "Page " .. pageNum
    tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.TextSize = 14
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 5)
    print("[UI] Tab " .. pageNum .. " créé")
    return tab
end

-- Fonction pour créer le contenu d'une page
local function createPageContent(pageNum)
    print("[UI] Création du contenu de la Page " .. pageNum .. "...")
    
    local page = Instance.new("Frame")
    page.Name = "Page" .. pageNum
    page.Parent = ContentFrame
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    
    -- Création des 3 boutons
    for i = 1, 3 do
        local button = Instance.new("TextButton")
        button.Name = "Button" .. i
        button.Parent = page
        button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        button.Position = UDim2.new(0, 0, 0, (i-1) * 55)
        button.Size = UDim2.new(1, 0, 0, 45)
        button.Font = Enum.Font.GothamBold
        button.Text = "Button " .. i
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 15
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
        
        -- Connection au callback
        button.MouseButton1Click:Connect(function()
            print("[UI] Page " .. pageNum .. " - Button " .. i .. " cliqué")
            UI.Callbacks["Page" .. pageNum]["Button" .. i]()
        end)
    end
    
    print("[UI] 3 boutons créés pour Page " .. pageNum)
    
    -- Création du slider
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Parent = page
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderFrame.Position = UDim2.new(0, 0, 0, 175)
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = sliderFrame
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Text = "Slider: 0"
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextSize = 14
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "SliderBar"
    sliderBar.Parent = sliderFrame
    sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    sliderBar.Position = UDim2.new(0.05, 0, 0.5, 0)
    sliderBar.Size = UDim2.new(0.9, 0, 0, 8)
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Parent = sliderBar
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Parent = sliderBar
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Position = UDim2.new(0, -8, 0.5, -8)
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Text = ""
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local currentValue = 0
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(pos * 100)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderButton.Position = UDim2.new(pos, -8, 0.5, -8)
        sliderLabel.Text = "Slider: " .. currentValue
        UI.Callbacks["Page" .. pageNum].Slider(currentValue)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
        print("[UI] Page " .. pageNum .. " - Slider drag démarré")
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                print("[UI] Page " .. pageNum .. " - Slider drag terminé")
            end
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    print("[UI] Slider créé pour Page " .. pageNum)
    
    return page
end

-- Création des tabs et pages
print("[UI] Création des 4 pages et tabs...")

local tabs = {}
local pages = {}

for i = 1, 4 do
    tabs[i] = createTab(i, (i-1) * 0.25 + 0.01)
    pages[i] = createPageContent(i)
end

print("[UI] Toutes les pages créées avec succès")

-- Fonction pour changer de page
local currentPage = 1
local function switchPage(pageNum)
    print("[UI] Changement vers Page " .. pageNum)
    for i = 1, 4 do
        pages[i].Visible = false
        tabs[i].BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end
    pages[pageNum].Visible = true
    tabs[pageNum].BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    currentPage = pageNum
end

-- Connection des tabs
for i = 1, 4 do
    tabs[i].MouseButton1Click:Connect(function()
        switchPage(i)
    end)
end

print("[UI] Tabs connectés avec succès")

-- Afficher la première page par défaut
switchPage(1)

print("============================================")
print("[UI] ✅ INTERFACE CHARGÉE AVEC SUCCÈS !")
print("[UI] 📱 Interface visible à l'écran")
print("[UI] 🔧 Utilisez UI.Callbacks pour connecter vos fonctions")
print("[UI] 📄 4 pages disponibles avec 3 boutons + 1 slider chacune")
print("============================================")

-- Si lancé seul sans Logic.lua, afficher un message
if not _G.LogicLoaded then
    print("[UI] ⚠️  ATTENTION: Logic.lua n'est pas chargé")
    print("[UI] 💡 Les boutons utilisent les callbacks par défaut")
    print("[UI] 📝 Chargez Logic.lua pour activer vos fonctions personnalisées")
end

return UI