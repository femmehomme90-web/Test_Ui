local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function parseEggPrice(text)
    if not text then return 0 end
    local cleaned = tostring(text):gsub(",", "")
    local num, suffix = cleaned:match("([%d%.]+)([KMBT]?)")
    if not num then return 0 end
    local value = tonumber(num) or 0
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
    if suffix and multipliers[suffix] then
        value = value * multipliers[suffix]
    end
    return value
end
local function parseCash(text)
    if not text then return 0 end
    local cleaned = tostring(text):gsub(",", "")
    local num, suffix = cleaned:match("([%d%.]+)([KMBT]?)")
    if not num then return 0 end
    local value = tonumber(num) or 0
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
    if suffix and multipliers[suffix] then
        value = value * multipliers[suffix]
    end
    return value
end
local function parseGain(text)
    if not text then return 0 end
    text = tostring(text)
    local value, suffix = text:match("%$([%d%.]+)%s*([MK]?)")
    if not value then return 0 end
    local num = tonumber(value)
    if not num then return 0 end
    if suffix == "M" then
        num *= 1_000_000
    elseif suffix == "K" then
        num *= 1_000
    end
    return num
end
local cash = 0
local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
if leaderstats and leaderstats:FindFirstChild("Cash") then
    cash = parseCash(leaderstats.Cash.Value)
else
    warn("[Cash] leaderstats.Cash introuvable")
end
print("===== 💰 CASH JOUEUR =====")
print("Cash :", cash)
local EggsFolder = workspace.CoreObjects.Eggs
local ConveyorEggs = {}
for _, eggFolder in ipairs(workspace.CoreObjects.Eggs:GetChildren()) do
    local eggModel =
        eggFolder:FindFirstChildWhichIsA("Model")
        or eggFolder:FindFirstChildWhichIsA("MeshPart")
    if not eggModel then
        warn("[Egg] Aucun model trouvé pour", eggFolder.Name)
        continue
    end
    local frame =
        eggModel:FindFirstChild("BillboardAttachment", true)
        and eggModel.BillboardAttachment:FindFirstChild("EggBillboard")
        and eggModel.BillboardAttachment.EggBillboard:FindFirstChild("Frame")
    if not frame then
        warn("[Egg] Frame introuvable pour", eggFolder.Name)
        continue
    end
    local priceLabel = frame:FindFirstChild("Price")
    local price = priceLabel and parseEggPrice(priceLabel.Text) or 0
end
local Plots = workspace.CoreObjects.Plots
local myPlot
for _, p in ipairs(Plots:GetChildren()) do
    local o, ov = p:GetAttribute("Owner"), p:FindFirstChild("Owner")
    if o == LocalPlayer.Name or o == LocalPlayer.UserId
        or (ov and (ov.Value == LocalPlayer.Name or ov.Value == LocalPlayer.UserId)) then
        myPlot = p
        break
    end
end
if not myPlot then
    warn("[Plot] Aucun plot trouvé")
    return
end
local stands = myPlot:FindFirstChild("Stands")
if not stands then
    warn("[Stands] Aucun stand trouvé")
    return
end
local totalGainPerSec = 0
for _, stand in ipairs(stands:GetChildren()) do
    local brainrot = stand:FindFirstChildOfClass("Model")
    local bb = brainrot
        and brainrot:FindFirstChild("HumanoidRootPart")
        and brainrot.HumanoidRootPart:FindFirstChild("BrainrotBillboard")
    if bb and bb:FindFirstChild("Multiplier") then
        local gain = parseGain(bb.Multiplier.Text)
        totalGainPerSec += gain
        print(
            stand.Name,
            "| Brainrot:", brainrot.Name,
            "| Rarity:", bb.Rarity.Text,
            "| Gain/sec:", gain
        )
    end
end
print("Gain/sec TOTAL :", totalGainPerSec)
for _, eggFolder in ipairs(workspace.CoreObjects.Eggs:GetChildren()) do
    local eggModel = eggFolder:FindFirstChildWhichIsA("Model") or eggFolder:FindFirstChildWhichIsA("MeshPart")
    if not eggModel then continue end
    
    local frame = eggModel:FindFirstChild("BillboardAttachment", true)
    frame = frame and frame.EggBillboard and frame.EggBillboard.Frame
    if not frame or not frame:FindFirstChild("Price") then continue end
    local price = parseEggPrice(frame.Price.Text)
    if price == 0 then continue end
    if cash >= price then
        print(string.format("✅ %s : ACHETABLE", eggFolder.Name))
    elseif totalGainPerSec > 0 then
        local t = (price - cash) / totalGainPerSec
        print(string.format("⏳ %s : %dh%dm%ds", eggFolder.Name, t/3600, (t%3600)/60, t%60))
    end
end