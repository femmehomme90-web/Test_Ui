--[[
    UI Générique Modulaire pour Roblox
    Sépare complètement l'UI de la logique
]]

-- Services (nécessaires pour Rayfield)
local players = game:GetService("Players")
local local_player = players.LocalPlayer

local GenericUI = {}
GenericUI.__index = GenericUI

-- Configuration de l'UI
local UI_CONFIG = {
    buttons_per_page = 6,
    sliders_per_page = 2,
    pages = {
        {name = "Page 1", icon = 4483362458},
        {name = "Page 2", icon = 4483362458},
        {name = "Page 3", icon = 4483362458},
        {name = "Page 4", icon = 4483362458}
    }
}

-- Créer une nouvelle instance d'UI
function GenericUI.new(title, subtitle)
    local self = setmetatable({}, GenericUI)
    
    self.title = title or "Generic UI"
    self.subtitle = subtitle or "by AK♥"
    self.pages = {}
    self.buttons = {}
    self.sliders = {}
    self.toggles = {}
    
    self:_initialize()
    
    return self
end

-- Initialiser Rayfield
function GenericUI:_initialize()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    self.Window = Rayfield:CreateWindow({
        Name = self.title,
        LoadingTitle = "Generic UI",
        LoadingSubtitle = self.subtitle,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "GenericUI",
            FileName = "Config"
        },
        Discord = {Enabled = false},
        KeySystem = false
    })
    
    self.Rayfield = Rayfield
    
    -- Créer les pages
    for i, page_config in ipairs(UI_CONFIG.pages) do
        local tab = self.Window:CreateTab(page_config.name, page_config.icon)
        
        self.pages[i] = {
            tab = tab,
            buttons = {},
            sliders = {},
            toggles = {}
        }
        
        -- Créer les boutons par défaut
        for j = 1, UI_CONFIG.buttons_per_page do
            local btn = tab:CreateButton({
                Name = "Button " .. j .. " (not configured)",
                Callback = function()
                    print("[Page " .. i .. " - Button " .. j .. "] Not configured")
                end
            })
            self.pages[i].buttons[j] = btn
        end
        
        -- Créer les sliders par défaut
        for j = 1, UI_CONFIG.sliders_per_page do
            local slider = tab:CreateSlider({
                Name = "Slider " .. j .. " (not configured)",
                Range = {0, 100},
                Increment = 1,
                CurrentValue = 50,
                Flag = "Page" .. i .. "Slider" .. j,
                Callback = function(value)
                    print("[Page " .. i .. " - Slider " .. j .. "] Value:", value)
                end
            })
            self.pages[i].sliders[j] = slider
        end
    end
    
    -- Créer le bouton toggle
    self:_create_toggle_button()
end

-- Créer le bouton de toggle mobile
function GenericUI:_create_toggle_button()
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "GenericUIToggle"
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
    
    button.Activated:Connect(function()
        self.Rayfield:Toggle()
        button.Size = UDim2.new(0, 55, 0, 55)
        task.wait(0.1)
        button.Size = UDim2.new(0, 60, 0, 60)
    end)
    
    -- Drag functionality
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
    
    self.toggle_gui = screen_gui
end

-- ============================================
-- API PUBLIQUE POUR CONFIGURER L'UI
-- ============================================

-- Configurer un bouton
function GenericUI:SetButton(page, button_num, name, callback)
    if not self.pages[page] or not self.pages[page].buttons[button_num] then
        warn("Invalid page or button number")
        return
    end
    
    -- Recréer le bouton avec la nouvelle config
    local tab = self.pages[page].tab
    local section = tab:CreateSection(name)
    
    self.pages[page].buttons[button_num] = tab:CreateButton({
        Name = name,
        Callback = callback
    })
end

-- Configurer un slider
function GenericUI:SetSlider(page, slider_num, config)
    if not self.pages[page] or not self.pages[page].sliders[slider_num] then
        warn("Invalid page or slider number")
        return
    end
    
    local tab = self.pages[page].tab
    
    self.pages[page].sliders[slider_num] = tab:CreateSlider({
        Name = config.name or "Slider",
        Range = config.range or {0, 100},
        Increment = config.increment or 1,
        CurrentValue = config.default or 50,
        Flag = config.flag or ("P" .. page .. "S" .. slider_num),
        Callback = config.callback or function() end
    })
end

-- Ajouter un toggle (bonus)
function GenericUI:AddToggle(page, name, callback, default)
    if not self.pages[page] then
        warn("Invalid page number")
        return
    end
    
    local tab = self.pages[page].tab
    return tab:CreateToggle({
        Name = name,
        CurrentValue = default or false,
        Flag = name:gsub(" ", ""),
        Callback = callback
    })
end

-- Notification
function GenericUI:Notify(title, content, duration)
    self.Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 5,
        Image = 4483362458
    })
end

-- Détruire l'UI
function GenericUI:Destroy()
    if self.toggle_gui then
        self.toggle_gui:Destroy()
    end
    self.Rayfield:Destroy()
end

return GenericUI