local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = ReplicatedStorage.Shared.Packages.Networker

local function AutobuyFood()
    while true do
        -- Premier check
        local foodData = Networker["RF/GetFoodShopData"]:InvokeServer()
        
        if foodData and foodData.Stock then
            for foodName, quantity in pairs(foodData.Stock) do
                if quantity > 0 then
                    for i = 1, quantity + 1 do
                        Networker["RF/BuyFood"]:InvokeServer(foodName)
                    end
                    print("Nourriture achetée : " .. (quantity + 1) .. " " .. foodName)
                end
            end
        end
        
        -- Attendre 10 secondes
        wait(10)
        
        -- Deuxième check
        foodData = Networker["RF/GetFoodShopData"]:InvokeServer()
        
        if foodData and foodData.Stock then
            for foodName, quantity in pairs(foodData.Stock) do
                if quantity > 0 then
                    for i = 1, quantity + 1 do
                        Networker["RF/BuyFood"]:InvokeServer(foodName)
                    end
                    print("Nourriture achetée : " .. (quantity + 1) .. " " .. foodName)
                end
            end
        end
        
        -- Attendre 5 minutes moins les 10 secondes déjà écoulées (290 secondes)
        wait(290)
    end
end

AutobuyFood()