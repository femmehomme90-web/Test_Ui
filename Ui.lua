-- Chargement de la bibliothèque Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Création de la fenêtre principale
local Window = Rayfield:CreateWindow({
   Name = "Mon Script Interface",
   LoadingTitle = "Chargement de l'interface...",
   LoadingSubtitle = "by Votre Nom",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MonScriptConfig",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Modification du thème (changez "Default" par le thème souhaité)
-- Thèmes disponibles: Default, AmberGlow, Amethyst, Bloom, DarkBlue, Green, Light, Ocean, Serenity
Window:ModifyTheme('Ocean')

-- Création de l'onglet Page 1
local Page1 = Window:CreateTab("Page 1", 4483362458)

-- Section pour les boutons
local Section1 = Page1:CreateSection("Boutons")

-- Boutons Page 1
local Bouton_Page1_1 = Page1:CreateButton({
   Name = "bouton.Page1.1",
   Callback = function()
      print("bouton.Page1.1 cliqué")
   end,
})

local Bouton_Page1_2 = Page1:CreateButton({
   Name = "bouton.Page1.2",
   Callback = function()
      print("bouton.Page1.2 cliqué")
   end,
})

local Bouton_Page1_3 = Page1:CreateButton({
   Name = "bouton.Page1.3",
   Callback = function()
      print("bouton.Page1.3 cliqué")
   end,
})

-- Section pour les sliders
local Section2 = Page1:CreateSection("Sliders")

-- Sliders Page 1
local Slider_Page1_1 = Page1:CreateSlider({
   Name = "slider.Page1.1",
   Range = {0, 100},
   Increment = 1,
   Suffix = "%",
   CurrentValue = 50,
   Flag = "Slider1",
   Callback = function(Value)
      print("slider.Page1.1 valeur:", Value)
   end,
})

local Slider_Page1_2 = Page1:CreateSlider({
   Name = "slider.Page1.2",
   Range = {0, 200},
   Increment = 5,
   Suffix = " units",
   CurrentValue = 100,
   Flag = "Slider2",
   Callback = function(Value)
      print("slider.Page1.2 valeur:", Value)
   end,
})

-- Création de l'onglet Page 2
local Page2 = Window:CreateTab("Page 2", 4483362458)

-- Section pour les boutons
local Section3 = Page2:CreateSection("Boutons")

-- Boutons Page 2
local Bouton_Page2_1 = Page2:CreateButton({
   Name = "bouton.Page2.1",
   Callback = function()
      print("bouton.Page2.1 cliqué")
   end,
})

local Bouton_Page2_2 = Page2:CreateButton({
   Name = "bouton.Page2.2",
   Callback = function()
      print("bouton.Page2.2 cliqué")
   end,
})

-- Section pour les sliders
local Section4 = Page2:CreateSection("Sliders")

-- Sliders Page 2
local Slider_Page2_1 = Page2:CreateSlider({
   Name = "slider.Page2.1",
   Range = {1, 50},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 10,
   Flag = "Slider3",
   Callback = function(Value)
      print("slider.Page2.1 valeur:", Value)
   end,
})

-- Création de l'onglet Paramètres
local Settings = Window:CreateTab("Paramètres", 4483362458)

local Section5 = Settings:CreateSection("Thème")

-- Bouton pour changer le thème
local ThemeButton = Settings:CreateButton({
   Name = "Changer le thème (Ocean)",
   Callback = function()
      Window:ModifyTheme('Ocean')
      Rayfield:Notify({
         Title = "Thème changé",
         Content = "Le thème Ocean a été appliqué",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- Notification de bienvenue
Rayfield:Notify({
   Title = "Interface chargée",
   Content = "L'interface a été chargée avec succès!",
   Duration = 5,
   Image = 4483362458,
})

print("Script chargé avec succès!")