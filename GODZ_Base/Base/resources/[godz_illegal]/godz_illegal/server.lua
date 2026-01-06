local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local src = {}
Tunnel.bindInterface("godz_illegal", src)

-- Drug Processing
function src.processDrug(type)
    local source = source
    local user_id = vRP.getUserId(source)
    local drug = Config.Drugs[type]

    if not drug then return false end

    if vRP.tryGetInventoryItem(user_id, drug.input, drug.amountInput) then
        vRP.giveInventoryItem(user_id, drug.output, drug.amountOutput)
        
        -- Log
        TriggerEvent("godz_logs:send", "Inventory", "Drogas", "O jogador " .. user_id .. " processou " .. drug.output, Config.Colors.Red, source)
        return true
    else
        TriggerClientEvent("godz:notify", source, "error", "Você não tem " .. drug.input .. " suficiente.", 5000)
        return false
    end
end

-- Chop Shop
function src.dismantlePart(partName, plate)
    local source = source
    local user_id = vRP.getUserId(source)
    
    -- In a real scenario, check if vehicle is owned by someone else or stolen.
    -- Assuming client validation for existence.
    
    local item = nil
    for _, p in ipairs(Config.ChopShop.parts) do
        if p.name == partName then
            item = p.item
            break
        end
    end

    if item then
        vRP.giveInventoryItem(user_id, item, 1)
        
        -- Log
        TriggerEvent("godz_logs:send", "Inventory", "Desmanche", "O jogador " .. user_id .. " desmanchou " .. partName .. " do veículo " .. plate, Config.Colors.Orange, source)
        return true
    end
    return false
end

function src.finishChopShop(plate, vehicleModel)
    local source = source
    local user_id = vRP.getUserId(source)
    
    -- Reward for destroying the chassis/finalizing
    local reward = math.random(1000, 5000) -- Dirty money or scrap
    vRP.giveInventoryItem(user_id, "dinheiro_sujo", reward)
    
    TriggerEvent("godz_logs:send", "Inventory", "Desmanche Finalizado", "O jogador " .. user_id .. " finalizou o veículo " .. plate, Config.Colors.Red, source)
    TriggerClientEvent("godz:notify", source, "success", "Veículo desmanchado. Recebeu $"..reward, 5000)
end

-- Faction Panel
function src.getFactionData()
    local source = source
    local user_id = vRP.getUserId(source)
    
    -- Get user group to identify faction
    -- Assuming vRP groups system. This logic depends on how groups are named.
    -- Simple check for known factions in Config
    
    local myFaction = nil
    for fac, data in pairs(Config.Factions) do
        if vRP.hasGroup(user_id, fac) then
            myFaction = fac
            break
        end
    end

    if myFaction then
        -- Fetch members (This is heavy in standard vRP, normally requires DB query on users table joined with groups)
        -- Simplified: Current online members
        local members = {}
        local users = vRP.getUsers()
        for id, src in pairs(users) do
            if vRP.hasGroup(id, myFaction) then
                local identity = vRP.getUserIdentity(id)
                table.insert(members, {
                    user_id = id,
                    name = identity.name .. " " .. identity.firstname,
                    online = true
                })
            end
        end
        
        -- Org Balance (Fake or integrated if custom table exists)
        -- Assuming a global variable or storage for now.
        local balance = 0 -- Replace with vRP.getBankMoney(org_id) if exists
        
        return {
            name = myFaction,
            balance = balance,
            members = members,
            history = {} -- Placeholder for delivery history
        }
    end
    return nil
end
