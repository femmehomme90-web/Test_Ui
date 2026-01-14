--[[
    Interface Only - Rayfield UI
    Juste les boutons avec prints console
]]

local start_tick = tick()

-- Services (nécessaires pour Rayfield)
local players = game:GetService("Players")
local local_player = players.LocalPlayer

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎀 CuddlyTrain - Steal A Brainrot",
    LoadingTitle = "CuddlyTrain Ware",
    LoadingSubtitle = "by AK♥",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AstolfoWare",
        FileName = "SAB_Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Créer un bouton toggle visible (pour mobile)
local function create_toggle_button()
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "AstolfoToggleButton"
    screen_gui.ResetOnSpawn = false
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen_gui.Parent = game:GetService("CoreGui")
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(1, -70, 0.5, -30)
    button.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = "🎀"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 30
    button.Parent = screen_gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 150, 160)
    stroke.Thickness = 3
    stroke.Parent = button
    
    -- Toggle l'UI Rayfield (compatible mobile)
    button.Activated:Connect(function()
        Rayfield:Toggle()
        print("🎀 UI toggled!")
        
        -- Animation
        button.Size = UDim2.new(0, 55, 0, 55)
        task.wait(0.1)
        button.Size = UDim2.new(0, 60, 0, 60)
    end)
    
    -- Feedback visuel
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(230, 170, 180)
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
    end)
    
    -- Drag (mobile + PC)
    local dragging = false
    local drag_input, drag_start, start_pos
    
    local function update(input)
        local delta = input.Position - drag_start
        button.Position = UDim2.new(
            start_pos.X.Scale,
            start_pos.X.Offset + delta.X,
            start_pos.Y.Scale,
            start_pos.Y.Offset + delta.Y
        )
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            update(input)
        end
    end)
    
    return screen_gui
end

local toggle_button_gui = create_toggle_button()

print("🎀 ASTOLFO WARE LOADED! Tap the pink button to toggle UI!")

-- Tabs
local MainTab = Window:CreateTab("🎯 Main", 4483362458)
local EggTab = Window:CreateTab("🥚 Eggs", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- ============================================
-- MAIN TAB
-- ============================================

-- Trade Section
local TradeSection = MainTab:CreateSection("Trade Automation")

MainTab:CreateToggle({
    Name = "Auto Trade",
    CurrentValue = false,
    Flag = "AutoTrade",
    Callback = function(value)
        print("🔄 Auto Trade:", value)
    end,
})

MainTab:CreateToggle({
    Name = "Accept 2+ NPC Brainrots",
    CurrentValue = false,
    Flag = "AcceptMultipleNPC",
    Callback = function(value)
        print("🎁 Accept Multiple NPC:", value)
    end,
})

MainTab:CreateToggle({
    Name = "Accept 2+ My Brainrots",
    CurrentValue = false,
    Flag = "AcceptMultipleMine",
    Callback = function(value)
        print("💼 Accept Multiple Mine:", value)
    end,
})

MainTab:CreateSlider({
    Name = "Auto Trade Delay (seconds)",
    Range = {0.5, 10},
    Increment = 0.5,
    CurrentValue = 1,
    Flag = "AutoTradeDelay",
    Callback = function(value)
        print("⏱️ Trade Delay:", value)
    end,
})

-- Plot Section
local PlotSection = MainTab:CreateSection("Plot Management")

MainTab:CreateToggle({
    Name = "Auto Collect Cash",
    CurrentValue = false,
    Flag = "AutoCollectCash",
    Callback = function(value)
        print("💰 Auto Collect Cash:", value)
    end,
})

MainTab:CreateSlider({
    Name = "Collect Cash Delay (seconds)",
    Range = {1, 60},
    Increment = 1,
    CurrentValue = 1,
    Flag = "CollectDelay",
    Callback = function(value)
        print("⏱️ Collect Delay:", value)
    end,
})

-- Sell Section
local SellSection = MainTab:CreateSection("Sell Brainrots")

MainTab:CreateButton({
    Name = "Sell Held Brainrot",
    Callback = function()
        print("🛒 Sell Held Brainrot clicked!")
    end,
})

MainTab:CreateButton({
    Name = "Sell All Brainrots",
    Callback = function()
        print("🛒 Sell All Brainrots clicked!")
    end,
})

-- ============================================
-- EGG TAB
-- ============================================

local EggSection = EggTab:CreateSection("Egg Automation")

EggTab:CreateToggle({
    Name = "Auto Buy Eggs",
    CurrentValue = false,
    Flag = "AutoBuyEggs",
    Callback = function(value)
        print("🥚 Auto Buy Eggs:", value)
    end,
})

EggTab:CreateSlider({
    Name = "Buy Eggs Delay (seconds)",
    Range = {1, 60},
    Increment = 1,
    CurrentValue = 1,
    Flag = "EggDelay",
    Callback = function(value)
        print("⏱️ Egg Delay:", value)
    end,
})

EggTab:CreateDropdown({
    Name = "Select Eggs to Buy",
    Options = {"Egg1", "Egg2", "Egg3"}, -- Liste vide pour l'instant
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SelectedEggs",
    Callback = function(options)
        print("🥚 Selected Eggs:", table.concat(options, ", "))
    end,
})

-- ============================================
-- PLAYER TAB
-- ============================================

local PlayerSection = PlayerTab:CreateSection("Player Settings")

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(value)
        print("😴 Anti AFK:", value)
    end,
})

PlayerTab:CreateInput({
    Name = "Join Private Server",
    PlaceholderText = "Enter server code",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        print("🔗 Join Server Code:", text)
    end,
})

-- Misc Section
local MiscSection = PlayerTab:CreateSection("Miscellaneous")

PlayerTab:CreateToggle({
    Name = "Auto Wheel Spin",
    CurrentValue = false,
    Flag = "AutoWheel",
    Callback = function(value)
        print("🎡 Auto Wheel Spin:", value)
    end,
})

-- ============================================
-- SETTINGS TAB
-- ============================================

local InfoSection = SettingsTab:CreateSection("Information")

SettingsTab:CreateParagraph({
    Title = "🎀 Astolfo Ware",
    Content = "Steal A Brainrot automation script. Configure your settings in the Main and Eggs tabs."
})

SettingsTab:CreateButton({
    Name = "Show Current Money",
    Callback = function()
        print("💵 Show Money clicked!")
    end,
})

-- Debug Section
local DebugSection = SettingsTab:CreateSection("Debug Tools")

SettingsTab:CreateButton({
    Name = "Dump Trade Contents",
    Callback = function()
        print("📦 Dump Trade clicked!")
    end,
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        print("💥 Destroying UI...")
        if toggle_button_gui then toggle_button_gui:Destroy() end
        Rayfield:Destroy()
    end,
})

-- Load notification
Rayfield:Notify({
    Title = "✅ Loaded Successfully",
    Content = "Script loaded in " .. string.format("%.2f", tick() - start_tick) .. " seconds",
    Duration = 5,
    Image = 4483362458,
})

print("✨ Interface chargée! Tous les boutons affichent des prints dans la console.")