-- Remote Spy Interface pour Roblox Executor
-- Créé pour Codex

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Utiliser gethui() ou PlayerGui selon l'executor
local function getGuiParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
        return game:GetService("CoreGui")
    else
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

local GuiParent = getGuiParent()

-- Variables globales
local RemoteSpy = {}
RemoteSpy.Scanning = true
RemoteSpy.Remotes = {}
RemoteSpy.BannedRemotes = {}
RemoteSpy.ActiveTab = "live"

-- Créer l'interface
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RemoteSpyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = GuiParent

    -- Frame principale
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔍 Remote Spy"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Boutons de contrôle
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, -20, 0, 40)
    ControlsFrame.Position = UDim2.new(0, 10, 0, 60)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Parent = MainFrame

    local function createButton(name, text, position, color, parent)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 120, 0, 35)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.GothamBold
        button.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        return button
    end

    local PauseButton = createButton("PauseButton", "⏸ Pause", UDim2.new(0, 0, 0, 0), Color3.fromRGB(200, 150, 0), ControlsFrame)
    local ClearButton = createButton("ClearButton", "🗑 Clear", UDim2.new(0, 130, 0, 0), Color3.fromRGB(200, 50, 50), ControlsFrame)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0, 150, 0, 35)
    StatusLabel.Position = UDim2.new(1, -150, 0, 0)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    StatusLabel.BorderSizePixel = 0
    StatusLabel.Text = "● Scanning"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = ControlsFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = StatusLabel

    -- Tabs
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Name = "TabsFrame"
    TabsFrame.Size = UDim2.new(1, -20, 0, 40)
    TabsFrame.Position = UDim2.new(0, 10, 0, 110)
    TabsFrame.BackgroundTransparency = 1
    TabsFrame.Parent = MainFrame

    local LiveTab = createButton("LiveTab", "📡 Live Remotes (0)", UDim2.new(0, 0, 0, 0), Color3.fromRGB(60, 120, 200), TabsFrame)
    LiveTab.Size = UDim2.new(0.48, 0, 0, 35)
    
    local BannedTab = createButton("BannedTab", "🚫 Banned (0)", UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(60, 60, 70), TabsFrame)
    BannedTab.Size = UDim2.new(0.48, 0, 0, 35)

    -- Liste des remotes
    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Name = "ListFrame"
    ListFrame.Size = UDim2.new(1, -20, 1, -220)
    ListFrame.Position = UDim2.new(0, 10, 0, 160)
    ListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 6
    ListFrame.Parent = MainFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = ListFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = ListFrame

    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingTop = UDim.new(0, 5)
    ListPadding.PaddingBottom = UDim.new(0, 5)
    ListPadding.PaddingLeft = UDim.new(0, 5)
    ListPadding.PaddingRight = UDim.new(0, 5)
    ListPadding.Parent = ListFrame

    -- Info footer
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Name = "InfoFrame"
    InfoFrame.Size = UDim2.new(1, -20, 0, 50)
    InfoFrame.Position = UDim2.new(0, 10, 1, -60)
    InfoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    InfoFrame.BorderSizePixel = 0
    InfoFrame.Parent = MainFrame

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = InfoFrame

    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -10, 1, -10)
    InfoText.Position = UDim2.new(0, 5, 0, 5)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "🟢 Copier | 🔴 Ban | 🔵 Unban | ⏸ Pause/Play | 🗑 Clear"
    InfoText.TextColor3 = Color3.fromRGB(180, 180, 180)
    InfoText.TextSize = 12
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextWrapped = true
    InfoText.Parent = InfoFrame

    return ScreenGui, MainFrame, ListFrame, PauseButton, ClearButton, StatusLabel, LiveTab, BannedTab
end

-- Créer un item de remote
local function createRemoteItem(remoteName, remotePath, timestamp, isBanned, parent)
    local Item = Instance.new("Frame")
    Item.Name = "RemoteItem"
    Item.Size = UDim2.new(1, -10, 0, 60)
    Item.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Item.BorderSizePixel = 0
    Item.Parent = parent

    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = Item

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -130, 0, 25)
    NameLabel.Position = UDim2.new(0, 10, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = remoteName
    NameLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    NameLabel.TextSize = 13
    NameLabel.Font = Enum.Font.Code
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = Item

    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Size = UDim2.new(1, -130, 0, 20)
    TimeLabel.Position = UDim2.new(0, 10, 0, 30)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = timestamp
    TimeLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    TimeLabel.TextSize = 11
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeLabel.Parent = Item

    if not isBanned then
        -- Bouton Copier
        local CopyButton = Instance.new("TextButton")
        CopyButton.Name = "CopyButton"
        CopyButton.Size = UDim2.new(0, 50, 0, 50)
        CopyButton.Position = UDim2.new(1, -110, 0, 5)
        CopyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        CopyButton.BorderSizePixel = 0
        CopyButton.Text = "📋"
        CopyButton.TextSize = 18
        CopyButton.Parent = Item

        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = CopyButton

        -- Bouton Ban
        local BanButton = Instance.new("TextButton")
        BanButton.Name = "BanButton"
        BanButton.Size = UDim2.new(0, 50, 0, 50)
        BanButton.Position = UDim2.new(1, -55, 0, 5)
        BanButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BanButton.BorderSizePixel = 0
        BanButton.Text = "🚫"
        BanButton.TextSize = 18
        BanButton.Parent = Item

        local banCorner = Instance.new("UICorner")
        banCorner.CornerRadius = UDim.new(0, 6)
        banCorner.Parent = BanButton

        return Item, CopyButton, BanButton
    else
        -- Bouton Unban
        local UnbanButton = Instance.new("TextButton")
        UnbanButton.Name = "UnbanButton"
        UnbanButton.Size = UDim2.new(0, 50, 0, 50)
        UnbanButton.Position = UDim2.new(1, -55, 0, 5)
        UnbanButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        UnbanButton.BorderSizePixel = 0
        UnbanButton.Text = "👁"
        UnbanButton.TextSize = 18
        UnbanButton.Parent = Item

        local unbanCorner = Instance.new("UICorner")
        unbanCorner.CornerRadius = UDim.new(0, 6)
        unbanCorner.Parent = UnbanButton

        return Item, nil, nil, UnbanButton
    end
end

-- Mettre à jour la liste
local function updateList(listFrame, remotes, isBanned)
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, remote in ipairs(remotes) do
        local item, copyBtn, banBtn, unbanBtn = createRemoteItem(
            remote.name,
            remote.path,
            remote.timestamp,
            isBanned,
            listFrame
        )

        if copyBtn then
            copyBtn.MouseButton1Click:Connect(function()
                setclipboard(remote.path)
                copyBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                copyBtn.Text = "✓"
                wait(1)
                copyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                copyBtn.Text = "📋"
            end)
        end

        if banBtn then
            banBtn.MouseButton1Click:Connect(function()
                table.insert(RemoteSpy.BannedRemotes, remote)
                for i, r in ipairs(RemoteSpy.Remotes) do
                    if r == remote then
                        table.remove(RemoteSpy.Remotes, i)
                        break
                    end
                end
                updateList(listFrame, RemoteSpy.ActiveTab == "live" and RemoteSpy.Remotes or RemoteSpy.BannedRemotes, RemoteSpy.ActiveTab == "banned")
                updateCounts()
            end)
        end

        if unbanBtn then
            unbanBtn.MouseButton1Click:Connect(function()
                table.insert(RemoteSpy.Remotes, remote)
                for i, r in ipairs(RemoteSpy.BannedRemotes) do
                    if r == remote then
                        table.remove(RemoteSpy.BannedRemotes, i)
                        break
                    end
                end
                updateList(listFrame, RemoteSpy.ActiveTab == "live" and RemoteSpy.Remotes or RemoteSpy.BannedRemotes, RemoteSpy.ActiveTab == "banned")
                updateCounts()
            end)
        end
    end

    listFrame.CanvasSize = UDim2.new(0, 0, 0, listFrame.UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Mettre à jour les compteurs
local function updateCounts()
    local gui = GuiParent:FindFirstChild("RemoteSpyUI")
    if gui then
        local liveTab = gui.MainFrame.TabsFrame.LiveTab
        local bannedTab = gui.MainFrame.TabsFrame.BannedTab
        
        liveTab.Text = "📡 Live Remotes (" .. #RemoteSpy.Remotes .. ")"
        bannedTab.Text = "🚫 Banned (" .. #RemoteSpy.BannedRemotes .. ")"
    end
end

-- Scanner les remotes
local function scanRemotes()
    local namecallHook
    namecallHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if (method == "FireServer" or method == "InvokeServer") and RemoteSpy.Scanning then
            local remotePath = self:GetFullName()
            local remoteName = self.Name
            local timestamp = os.date("%H:%M:%S")
            
            -- Vérifier si déjà banni
            local isBanned = false
            for _, banned in ipairs(RemoteSpy.BannedRemotes) do
                if banned.name == remoteName then
                    isBanned = true
                    break
                end
            end
            
            if not isBanned then
                local fullPath = 'game:GetService("' .. remotePath:split(".")[1] .. '").' .. remotePath:gsub("^[^%.]+%.", ""):gsub("%.", ":FindFirstChild(\"") .. "\")"
                fullPath = fullPath:gsub(":FindFirstChild", "", 1)
                
                table.insert(RemoteSpy.Remotes, {
                    name = remoteName,
                    path = fullPath,
                    timestamp = timestamp
                })
                
                if RemoteSpy.ActiveTab == "live" then
                    local gui = GuiParent:FindFirstChild("RemoteSpyUI")
                    if gui then
                        updateList(gui.MainFrame.ListFrame, RemoteSpy.Remotes, false)
                        updateCounts()
                    end
                end
            end
        end
        
        return namecallHook(self, ...)
    end)
end

-- Initialiser l'UI
local function init()
    local gui, mainFrame, listFrame, pauseBtn, clearBtn, statusLabel, liveTab, bannedTab = createUI()
    
    -- Rendre draggable
    local dragging, dragInput, dragStart, startPos
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Bouton Pause
    pauseBtn.MouseButton1Click:Connect(function()
        RemoteSpy.Scanning = not RemoteSpy.Scanning
        if RemoteSpy.Scanning then
            pauseBtn.Text = "⏸ Pause"
            pauseBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            statusLabel.Text = "● Scanning"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            pauseBtn.Text = "▶ Play"
            pauseBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            statusLabel.Text = "⏸ Paused"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
    end)
    
    -- Bouton Clear
    clearBtn.MouseButton1Click:Connect(function()
        RemoteSpy.Remotes = {}
        updateList(listFrame, RemoteSpy.Remotes, false)
        updateCounts()
    end)
    
    -- Tab Live
    liveTab.MouseButton1Click:Connect(function()
        RemoteSpy.ActiveTab = "live"
        liveTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        bannedTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        updateList(listFrame, RemoteSpy.Remotes, false)
    end)
    
    -- Tab Banned
    bannedTab.MouseButton1Click:Connect(function()
        RemoteSpy.ActiveTab = "banned"
        liveTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        bannedTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        updateList(listFrame, RemoteSpy.BannedRemotes, true)
    end)
    
    -- Démarrer le scanner
    scanRemotes()
    
    print("✅ Remote Spy chargé avec succès!")
end

-- Lancer l'interface
init()