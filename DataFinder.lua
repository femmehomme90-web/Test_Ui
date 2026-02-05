-- Récupérer le module LootPlan
local LootPlan = game:GetService("ReplicatedStorage").Shared.Packages.LootPlan

-- Configuration
local LUCK_MULTIPLIER = 100  -- Augmente tes chances (1 = normal, 100 = x100)
local LOG_ENABLED = true      -- Activer/désactiver les logs

-- Fonction de log
local function log(...)
    if LOG_ENABLED then
        print(...)
    end
end

-- Sauvegarder les fonctions originales
local original_newSingle = LootPlan.newSingle
local original_newMulti = LootPlan.newMulti

-- Table pour stocker toutes les instances créées
local tracked_instances = {}

-- Hook newSingle
LootPlan.newSingle = function(seed)
    log("=== Nouvelle instance LootPlan (Single) créée ===")
    log("Seed:", seed)
    
    local instance = original_newSingle(seed)
    table.insert(tracked_instances, instance)
    
    -- Hook GetRandomLoot
    local original_GetRandomLoot = instance.GetRandomLoot
    instance.GetRandomLoot = function(self, luckMultiplier)
        log("\n[SINGLE] GetRandomLoot appelé")
        log("├─ Luck Multiplier original:", luckMultiplier or 1)
        log("├─ Total Weight:", self.TotalWeight)
        log("├─ Loot Count:", self.LootCount)
        
        -- Afficher tous les loots disponibles avec leurs chances
        if self.Loot then
            log("├─ Loots disponibles:")
            for name, data in pairs(self.Loot) do
                local chance = (data.weight / self.TotalWeight * 100)
                log("│  ├─", name, "| Weight:", data.weight, "| Chance:", string.format("%.2f%%", chance))
            end
        end
        
        -- MODIFICATION : Augmenter le luck multiplier
        local boosted_luck = (luckMultiplier or 1) * LUCK_MULTIPLIER
        log("└─ Luck Multiplier BOOSTÉ:", boosted_luck)
        
        local result = original_GetRandomLoot(self, boosted_luck)
        log("✓ Résultat obtenu:", result)
        log("=====================================\n")
        
        return result
    end
    
    -- Hook AddLoot pour voir quand du loot est ajouté
    local original_AddLoot = instance.AddLoot
    instance.AddLoot = function(self, name, weight)
        log("[SINGLE] AddLoot:", name, "| Weight:", weight)
        return original_AddLoot(self, name, weight)
    end
    
    -- Hook ChangeLootWeight
    local original_ChangeLootWeight = instance.ChangeLootWeight
    instance.ChangeLootWeight = function(self, name, newWeight)
        log("[SINGLE] ChangeLootWeight:", name, "| New Weight:", newWeight)
        return original_ChangeLootWeight(self, name, newWeight)
    end
    
    log("Instance Single hookée avec succès!\n")
    return instance
end

-- Hook newMulti
LootPlan.newMulti = function(seed)
    log("=== Nouvelle instance LootPlan (Multi) créée ===")
    log("Seed:", seed)
    
    local instance = original_newMulti(seed)
    table.insert(tracked_instances, instance)
    
    -- Hook GetRandomLoot
    local original_GetRandomLoot = instance.GetRandomLoot
    instance.GetRandomLoot = function(self, luckMultiplier, attempts)
        log("\n[MULTI] GetRandomLoot appelé")
        log("├─ Luck Multiplier original:", luckMultiplier or 1)
        log("├─ Attempts:", attempts or 1)
        
        -- Afficher tous les loots avec leurs chances
        if self.Loot then
            log("├─ Loots disponibles:")
            for name, data in pairs(self.Loot) do
                log("│  ├─", name, "| Chance:", string.format("%.2f%%", data.chance))
            end
        end
        
        -- MODIFICATION : Augmenter le luck multiplier
        local boosted_luck = (luckMultiplier or 1) * LUCK_MULTIPLIER
        log("└─ Luck Multiplier BOOSTÉ:", boosted_luck)
        
        local result = original_GetRandomLoot(self, boosted_luck, attempts)
        
        -- Afficher les résultats
        log("✓ Résultats obtenus:")
        for name, count in pairs(result) do
            log("  ├─", name, "x", count)
        end
        log("=====================================\n")
        
        return result
    end
    
    -- Hook AddLoot
    local original_AddLoot = instance.AddLoot
    instance.AddLoot = function(self, name, chance)
        log("[MULTI] AddLoot:", name, "| Chance:", chance, "%")
        return original_AddLoot(self, name, chance)
    end
    
    -- Hook ChangeLootChance
    local original_ChangeLootChance = instance.ChangeLootChance
    instance.ChangeLootChance = function(self, name, newChance)
        log("[MULTI] ChangeLootChance:", name, "| New Chance:", newChance, "%")
        return original_ChangeLootChance(self, name, newChance)
    end
    
    log("Instance Multi hookée avec succès!\n")
    return instance
end

print("✓ LootPlan hooks installés avec succès!")
print("✓ Luck Multiplier configuré à:", LUCK_MULTIPLIER)
print("✓ Logging:", LOG_ENABLED and "ACTIVÉ" or "DÉSACTIVÉ")
print("\n[Commandes disponibles]")
print("- Pour changer le multiplier: LUCK_MULTIPLIER = 200")
print("- Pour désactiver les logs: LOG_ENABLED = false")
print("- Pour voir les instances: #tracked_instances")