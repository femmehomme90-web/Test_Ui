-- ===============================================
-- 🎮 ROBLOX AUTO FARM SCRIPT
-- ===============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

local Networker = ReplicatedStorage.Shared.Packages.Networker
local PlaceEggRF = Networker["RF/PlaceEgg"]
local UpgradeBrainrotRF = Networker["RF/UpgradeBrainrot"]
local HatchEggRE = Networker["RE/HatchEgg"]
local PickupBrainrotRE = Networker["RE/PickupBrainrot"]
local PickupBoxesRE = Networker["RE/PickupBoxes"]
local RequestEggSpawnRF = Networker["RF/RequestEggSpawn"]

-- ===============================================
-- 📊 CONFIGURATION & VARIABLES
-- ===============================================

local Config = {
    AutoUpgrade = false,
    AutoHatch = false,
    AutoPlaceEgg = false,
    AutoCollectBoxes = false,
    AutoBuyEgg = false,
    BoxCollectDelay = 30,
    ActionDelay = 0.5,
    UpgradeDelay = 10
}

local LastBoxCollect = 0
local LastUpgrade = 0
local LastHatch = 0
local LastPlaceEgg = 0
local LastBuyEgg = 0

-- ===============================================
-- 🔧 UTILITY FUNCTIONS
-- ===============================================

local function getRebirths()
    local ClientUtils = require(ReplicatedStorage.Client.Modules.ClientUtils)
    local ProfileData = ClientUtils.ProfileData

    if ProfileData and ProfileData.leaderstats and ProfileData.leaderstats.Rebirths then
        return ProfileData.leaderstats.Rebirths
    end

    warn("Impossible de récupérer les Rebirths")
    return 0
end

local function getMyPlot()
    local Plots = workspace.CoreObjects.Plots

    for _, p in ipairs(Plots:GetChildren()) do
        local o, ov = p:GetAttribute("Owner"), p:FindFirstChild("Owner")
        if o == LocalPlayer.Name or o == LocalPlayer.UserId
        or (ov and (ov.Value == LocalPlayer.Name or ov.Value == LocalPlayer.UserId)) then
            return p
        end
    end

    warn("No plot")
end

local function getStandsFolder(plot)
    local stands = plot:FindFirstChild("Stands")
    if not stands then
        warn("No stands")
    end
    return stands
end

local function findEggTool()
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local attrs = tool:GetAttributes()
            if attrs and attrs.Egg == true then
                return tool
            end
        end
    end
end

local function equipTool(tool)
    if tool and LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        task.wait(0.15)
    end
end

local function isValidStandName(stand)
    local number = stand.Name:match("^Stand(%d+)$")
    number = tonumber(number)
    return number and number <= 50
end

local function canUseStand(stand, rebirths)
    local requirement = stand:GetAttribute("Requirement")
    return requirement == nil or (type(requirement) == "number" and requirement <= rebirths)
end

local function getStandState(stand)
    if stand:FindFirstChildOfClass("Model") then
        return "Brainrot"
    end

    for _, d in ipairs(stand:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "Timer" then
            return "Egg"
        end
    end

    return "Empty"
end

local function isStandEmpty(stand)
    return getStandState(stand) == "Empty"
end

local function findEmptyUsableStand(standsFolder, rebirths)
    for _, stand in ipairs(standsFolder:GetChildren()) do
        if isValidStandName(stand)
        and canUseStand(stand, rebirths)
        and isStandEmpty(stand) then
            return stand
        end
    end
end

local function readStandContent(stand)
    local state = getStandState(stand)

    local data = {
        State = state,
        Name = nil,
        Rarity = nil,
        GainPerSec = nil,
        Timer = nil
    }

    if state == "Brainrot" then
        local brainrot = stand:FindFirstChildOfClass("Model")
        local bb = brainrot
            and brainrot:FindFirstChild("HumanoidRootPart")
            and brainrot.HumanoidRootPart:FindFirstChild("BrainrotBillboard")

        if brainrot then
            data.Name = brainrot.Name
        end

        if bb then
            data.Rarity = bb.Rarity.Text
            data.GainPerSec = bb.Multiplier.Text
        end
    end

    if state == "Egg" then
        for _, d in ipairs(stand:GetDescendants()) do
            if d:IsA("TextLabel") and d.Name == "Timer" then
                data.Timer = d.Text
                break
            end
        end
    end

    return data
end

local function parseGainPerSec(gainText)
    if not gainText then return 0 end
    
    local num = gainText:match("([%d%.]+)")
    num = tonumber(num) or 0
    
    if gainText:find("K") then
        num = num * 1000
    elseif gainText:find("M") then
        num = num * 1000000
    elseif gainText:find("B") then
        num = num * 1000000000
    end
    
    return num
end

-- ===============================================
-- 🤖 AUTO FUNCTIONS
-- ===============================================

local function autoUpgrade()
    if not Config.AutoUpgrade then return end
    
    local currentTime = tick()
    if currentTime - LastUpgrade < Config.UpgradeDelay then
        return
    end
    
    local myPlot = getMyPlot()
    if not myPlot then return end
    
    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end
    
    local brainrotStands = {}
    
    for _, stand in ipairs(standsFolder:GetChildren()) do
        if isValidStandName(stand) then
            local state = getStandState(stand)
            if state == "Brainrot" then
                local data = readStandContent(stand)
                table.insert(brainrotStands, {
                    Stand = stand,
                    Data = data,
                    Gain = parseGainPerSec(data.GainPerSec)
                })
            end
        end
    end
    
    table.sort(brainrotStands, function(a, b)
        return a.Gain > b.Gain
    end)
    
    for _, info in ipairs(brainrotStands) do
        pcall(function()
            UpgradeBrainrotRF:InvokeServer(info.Stand.Name)
        end)
        
        task.wait(Config.ActionDelay)
    end
    
    LastUpgrade = currentTime
end

local function autoHatch()
    if not Config.AutoHatch then return end
    
    local currentTime = tick()
    if currentTime - LastHatch < Config.ActionDelay then
        return
    end
    
    local myPlot = getMyPlot()
    if not myPlot then return end
    
    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end
    
    for _, stand in ipairs(standsFolder:GetChildren()) do
        if isValidStandName(stand) then
            local state = getStandState(stand)
            if state == "Egg" then
                local data = readStandContent(stand)
                if data.Timer and (data.Timer == "0s" or data.Timer == "Ready" or data.Timer:find("^0")) then
                    local brainrotName = stand:FindFirstChildOfClass("Model")
                    if brainrotName then
                        brainrotName = brainrotName.Name
                    else
                        brainrotName = "Unknown"
                    end
                    
                    pcall(function()
                        HatchEggRE:FireServer(stand.Name, brainrotName)
                    end)
                    
                    task.wait(Config.ActionDelay)
                end
            end
        end
    end
    
    LastHatch = currentTime
end

local function autoPlaceEgg()
    if not Config.AutoPlaceEgg then return end
    
    local currentTime = tick()
    if currentTime - LastPlaceEgg < Config.ActionDelay then
        return
    end
    
    local eggTool = findEggTool()
    if not eggTool then return end
    
    local myPlot = getMyPlot()
    if not myPlot then return end
    
    local standsFolder = getStandsFolder(myPlot)
    if not standsFolder then return end
    
    local rebirths = getRebirths()
    local stand = findEmptyUsableStand(standsFolder, rebirths)
    
    if not stand then return end
    
    equipTool(eggTool)
    
    pcall(function()
        PlaceEggRF:InvokeServer(stand.Name, eggTool.Name)
    end)
    
    LastPlaceEgg = currentTime
    task.wait(Config.ActionDelay)
end

local function autoCollectBoxes()
    if not Config.AutoCollectBoxes then return end
    
    local currentTime = tick()
    if currentTime - LastBoxCollect < Config.BoxCollectDelay then
        return
    end
    
    pcall(function()
        PickupBoxesRE:FireServer()
    end)
    
    task.wait(0.3)
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    LastBoxCollect = currentTime
end

local function autoBuyEgg()
    if not Config.AutoBuyEgg then return end
    
    local currentTime = tick()
    if currentTime - LastBuyEgg < Config.ActionDelay then
        return
    end
    
    pcall(function()
        RequestEggSpawnRF:InvokeServer()
    end)
    
    LastBuyEgg = currentTime
    task.wait(Config.ActionDelay)
end

-- ===============================================
-- 🎨 GUI CREATION
-- ===============================================

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "AutoFarmGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎮 AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.Size = UDim2.new(1, -20, 1, -70)

UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local function createToggle(name, configKey, order)
    local ToggleFrame = Instance.new("Frame")
    local ToggleLabel = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local ButtonCorner = Instance.new("UICorner")
    
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Parent = ContentFrame
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.LayoutOrder = order
    
    ToggleLabel.Name = "Label"
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleButton.Name = "Button"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ToggleButton.Position = UDim2.new(0.65, 0, 0, 0)
    ToggleButton.Size = UDim2.new(0.35, 0, 1, 0)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        
        if Config[configKey] then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            ToggleButton.Text = "ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ToggleButton.Text = "OFF"
        end
    end)
end

local function createSlider(name, configKey, min, max, order)
    local SliderFrame = Instance.new("Frame")
    local SliderLabel = Instance.new("TextLabel")
    local SliderBar = Instance.new("Frame")
    local SliderFill = Instance.new("Frame")
    local SliderButton = Instance.new("TextButton")
    local ValueLabel = Instance.new("TextLabel")
    
    SliderFrame.Name = name .. "Frame"
    SliderFrame.Parent = ContentFrame
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.LayoutOrder = order
    
    SliderLabel.Name = "Label"
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ValueLabel.Name = "Value"
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0, 0, 0, 0)
    ValueLabel.Size = UDim2.new(1, 0, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = Config[configKey] .. "s"
    ValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    SliderBar.Name = "Bar"
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Position = UDim2.new(0, 0, 0, 25)
    SliderBar.Size = UDim2.new(1, 0, 0, 20)
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 10)
    BarCorner.Parent = SliderBar
    
    SliderFill.Name = "Fill"
    SliderFill.Parent = SliderBar
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = SliderFill
    
    SliderButton.Name = "Button"
    SliderButton.Parent = SliderBar
    SliderButton.BackgroundTransparency = 1
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.Text = ""
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local barPos = SliderBar.AbsolutePosition.X
            local barSize = SliderBar.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            Config[configKey] = value
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueLabel.Text = value .. "s"
        end
    end)
end

createToggle("Auto Upgrade", "AutoUpgrade", 1)
createToggle("Auto Hatch", "AutoHatch", 2)
createToggle("Auto Place Egg", "AutoPlaceEgg", 3)
createToggle("Auto Collect Boxes", "AutoCollectBoxes", 4)
createToggle("Auto Buy Egg", "AutoBuyEgg", 5)
createSlider("Box Delay", "BoxCollectDelay", 1, 120, 6)

-- ===============================================
-- 🔄 MAIN LOOP
-- ===============================================

RunService.Heartbeat:Connect(function()
    autoUpgrade()
    autoHatch()
    autoPlaceEgg()
    autoCollectBoxes()
    autoBuyEgg()
end)