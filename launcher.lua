--[[
 Auto Brainrot Hub (Executor)
 Features:
  - Auto Hatch (RequestEggSpawn + BuyEgg if available)
  - Auto Pickup & Sell Boxes (PickupBoxes + VirtualInput E)
  - Auto Upgrade Brainrot (best-effort, server dependent)
  - Replace low rarity Brainrot with rarer Eggs

 Notes:
  - Designed for executors
  - Requires Roblox window focused for VirtualInput
]]

-- =========================
-- Services
-- =========================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- =========================
-- Networker
-- =========================
local Networker = ReplicatedStorage.Shared.Packages.Networker
local RE_PickupBoxes = Networker["RE/PickupBoxes"]
local RE_PickupBrainrot = Networker["RE/PickupBrainrot"]
local RF_RequestEggSpawn = Networker["RF/RequestEggSpawn"]
local RF_BuyEgg = Networker:FindFirstChild("RF/BuyEgg")

-- =========================
-- UI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoBrainrotHub"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(360, 260)
frame.Position = UDim2.fromScale(0.02, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.fromOffset(10, 8)
title.Text = "Auto Brainrot Hub"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

type Toggle = {Button: TextButton, On: boolean}

local toggles = {}

local function makeToggle(text, y)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.fromOffset(10, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text .. " : OFF"
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local t = {Button = btn, On = false}
    btn.MouseButton1Click:Connect(function()
        t.On = not t.On
        btn.Text = text .. (t.On and " : ON" or " : OFF")
    end)
    table.insert(toggles, t)
    return t
end

local tAutoHatch = makeToggle("Auto Hatch", 56)
local tAutoSell = makeToggle("Auto Sell Boxes", 96)
local tAutoUpgrade = makeToggle("Auto Upgrade Brainrot", 136)
local tReplaceLow = makeToggle("Replace Low Rarity", 176)

-- =========================
-- Helpers
-- =========================
local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function pickupAndSell()
    RE_PickupBoxes:FireServer()
    task.wait(0.3)
    pressE()
end

local function requestEgg()
    pcall(function()
        RF_RequestEggSpawn:InvokeServer()
    end)
end

local function buyEggByName(eggName)
    if RF_BuyEgg and eggName then
        pcall(function()
            RF_BuyEgg:InvokeServer(eggName, 1)
        end)
    end
end

-- =========================
-- Brainrot / Stand utils (best-effort)
-- =========================
local function getMyPlot()
    local Plots = workspace.CoreObjects.Plots
    for _, p in ipairs(Plots:GetChildren()) do
        local o, ov = p:GetAttribute("Owner"), p:FindFirstChild("Owner")
        if o == LocalPlayer.Name or o == LocalPlayer.UserId
        or (ov and (ov.Value == LocalPlayer.Name or ov.Value == LocalPlayer.UserId)) then
            return p
        end
    end
end

local function getStands(plot)
    return plot and plot:FindFirstChild("Stands")
end

local function getStandRarity(stand)
    local brainrot = stand and stand:FindFirstChildOfClass("Model")
    local bb = brainrot and brainrot:FindFirstChild("HumanoidRootPart") and brainrot.HumanoidRootPart:FindFirstChild("BrainrotBillboard")
    return bb and bb:FindFirstChild("Rarity") and bb.Rarity.Text
end

local RARITY_ORDER = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
}

local function rarityValue(r)
    return RARITY_ORDER[r] or 0
end

local function pickupBrainrot(standName)
    pcall(function()
        RE_PickupBrainrot:FireServer(standName)
    end)
end

-- =========================
-- Loops
-- =========================
local last = 0
RunService.Heartbeat:Connect(function(dt)
    last += dt
    if last < 0.5 then return end
    last = 0

    if tAutoHatch.On then
        requestEgg()
    end

    if tAutoSell.On then
        pickupAndSell()
    end

    if tAutoUpgrade.On or tReplaceLow.On then
        local plot = getMyPlot()
        local stands = getStands(plot)
        if stands then
            for _, stand in ipairs(stands:GetChildren()) do
                if tAutoUpgrade.On then
                    -- Best-effort: press E on upgrade prompt if nearby
                    local up = stand:FindFirstChild("UpgradeButton") and stand.UpgradeButton:FindFirstChildOfClass("ProximityPrompt")
                    if up and up.Enabled then
                        pressE()
                    end
                end
                if tReplaceLow.On then
                    local r = getStandRarity(stand)
                    if r and rarityValue(r) <= rarityValue("Uncommon") then
                        pickupBrainrot(stand.Name)
                        task.wait(0.2)
                        requestEgg()
                    end
                end
            end
        end
    end
end)
