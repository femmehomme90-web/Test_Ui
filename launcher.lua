-- Script pour vérifier les stands occupés via attributes
-- À exécuter directement dans ton executor

local function checkStands()
    print("==============================================")
    print("🔍 VÉRIFICATION DES STANDS")
    print("==============================================")
    
    -- Accéder aux stands
    local workspace = game:GetService("Workspace")
    local standsFolder = workspace.CoreObjects.Plots.Plot1.Stands
    
    if not standsFolder then
        warn("❌ Dossier Stands introuvable!")
        return
    end
    
    print("📍 Parcours de:", standsFolder:GetFullName())
    print("----------------------------------------------")
    
    local occupiedCount = 0
    local freeCount = 0
    local totalCount = 0
    
    -- Parcourir tous les stands
    for _, stand in pairs(standsFolder:GetChildren()) do
        if stand.Name:match("^Stand%d+$") then
            totalCount = totalCount + 1
            
            -- Récupérer tous les attributes
            local attributes = stand:GetAttributes()
            
            -- Afficher les infos du stand
            print("\n🎯 " .. stand.Name .. ":")
            
            -- Vérifier si le stand a des attributes
            local hasAttributes = false
            for attrName, attrValue in pairs(attributes) do
                hasAttributes = true
                print("  📋 " .. attrName .. " = " .. tostring(attrValue))
                
                -- Déterminer si occupé basé sur certains attributes
                if attrName:lower():match("occupied") or 
                   attrName:lower():match("egg") or 
                   attrName:lower():match("brainrot") then
                    if attrValue == true or (type(attrValue) == "string" and attrValue ~= "") then
                        occupiedCount = occupiedCount + 1
                        print("  ✅ OCCUPÉ")
                    else
                        freeCount = freeCount + 1
                        print("  ❌ LIBRE")
                    end
                end
            end
            
            if not hasAttributes then
                print("  ℹ️ Aucun attribute trouvé (probablement LIBRE)")
                freeCount = freeCount + 1
            end
        end
    end
    
    print("\n==============================================")
    print("📊 RÉSUMÉ:")
    print("  Total: " .. totalCount .. " stands")
    print("  Occupés: " .. occupiedCount)
    print("  Libres: " .. freeCount)
    print("==============================================")
end

-- Exécuter la vérification
checkStands()

-- Fonction pour vérifier un stand spécifique
local function checkSpecificStand(standName)
    local workspace = game:GetService("Workspace")
    local stand = workspace.CoreObjects.Plots.Plot1.Stands:FindFirstChild(standName)
    
    if not stand then
        warn("❌ Stand '" .. standName .. "' introuvable!")
        return nil
    end
    
    print("\n🔎 Vérification de: " .. standName)
    print("----------------------------------------------")
    
    local attributes = stand:GetAttributes()
    
    if next(attributes) == nil then
        print("ℹ️ Aucun attribute (probablement LIBRE)")
        return false
    end
    
    for attrName, attrValue in pairs(attributes) do
        print("📋 " .. attrName .. " = " .. tostring(attrValue))
    end
    
    return attributes
end

-- Fonction pour obtenir le premier stand libre
local function getFirstFreeStand()
    local workspace = game:GetService("Workspace")
    local standsFolder = workspace.CoreObjects.Plots.Plot1.Stands
    
    for i = 1, 20 do
        local standName = "Stand" .. i
        local stand = standsFolder:FindFirstChild(standName)
        
        if stand then
            local attributes = stand:GetAttributes()
            
            -- Si aucun attribute ou tous vides, c'est libre
            local isFree = true
            for attrName, attrValue in pairs(attributes) do
                if attrName:lower():match("occupied") or 
                   attrName:lower():match("egg") or 
                   attrName:lower():match("brainrot") then
                    if attrValue == true or (type(attrValue) == "string" and attrValue ~= "") then
                        isFree = false
                        break
                    end
                end
            end
            
            if isFree then
                print("✅ Premier stand libre trouvé: " .. standName)
                return standName
            end
        end
    end
    
    print("❌ Aucun stand libre trouvé!")
    return nil
end

-- Exemples d'utilisation:
print("\n💡 Fonctions disponibles:")
print("  checkStands() - Vérifier tous les stands")
print("  checkSpecificStand('Stand1') - Vérifier un stand précis")
print("  getFirstFreeStand() - Trouver le premier stand libre")

-- Rendre les fonctions globales pour utilisation ultérieure
_G.checkStands = checkStands
_G.checkSpecificStand = checkSpecificStand
_G.getFirstFreeStand = getFirstFreeStand
