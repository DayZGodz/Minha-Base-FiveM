local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local cfg = {}

local laundry = { commission_rate = 0.2, police_radius = 50.0, location = {x=0,y=0,z=0} }
local black_market = { open_hour = 21, close_hour = 5, items = {}, locations = {} }

Citizen.CreateThread(function()
    local attempts = 0
    while GetResourceState("godz_tuning") ~= "started" and attempts < 100 do
        attempts = attempts + 1
        Wait(200)
    end

    local data = nil
    if GetResourceState("godz_tuning") == "started" then
        local ok, res = pcall(function()
            return exports["godz_tuning"]:GetMasterConfig()
        end)
        if ok then data = res end
    end

    if data then
        cfg = data
        laundry = cfg.LAUNDRY or laundry
        black_market = cfg.BLACK_MARKET or black_market
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER: POLICE CHECK
-----------------------------------------------------------------------------------------------------------------------------------------
function checkPoliceNear(coords, radius)
    local police_users = vRP.getUsersByPermission("policia.permissao")
    for k,v in pairs(police_users) do
        local player = vRP.getUserSource(v)
        if player then
            local ped = GetPlayerPed(player)
            local pCoords = GetEntityCoords(ped)
            if #(vector3(coords.x, coords.y, coords.z) - pCoords) <= radius then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEY LAUNDRY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("godz_illegal:washMoney")
AddEventHandler("godz_illegal:washMoney", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local loc = laundry.location
        if checkPoliceNear(loc, laundry.police_radius) then
            TriggerClientEvent("Notify", source, "negado", "Atenção: Atividade policial detectada nas imediações. Operação abortada.")
            return
        end

        local dirty_money = vRP.getInventoryItemAmount(user_id, "dinheirosujo")
        if dirty_money > 0 then
            if vRP.tryGetInventoryItem(user_id, "dinheirosujo", dirty_money) then
                local commission = laundry.commission_rate
                local clean_money = math.floor(dirty_money * (1 - commission))
                
                vRP.giveMoney(user_id, clean_money)
                TriggerClientEvent("Notify", source, "sucesso", "Lavagem concluída. Recebido: $"..vRP.format(clean_money).." (Taxa: ".. (commission*100) .."%)")
                
                -- Webhook Log (if configured)
                -- SendWebhookMessage(cfg.WEBHOOKS.audit, "LAVAGEM: ID "..user_id.." lavou $"..dirty_money)
            else
                TriggerClientEvent("Notify", source, "negado", "Erro na transação.")
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Você não possui dinheiro sujo.")
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACK MARKET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("godz_illegal:buyItem")
AddEventHandler("godz_illegal:buyItem", function(itemIndex)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local itemData = black_market.items[itemIndex]
        if itemData then
            if vRP.tryGetInventoryItem(user_id, "dinheirosujo", itemData.price) then
                vRP.giveInventoryItem(user_id, itemData.item, 1)
                TriggerClientEvent("Notify", source, "sucesso", "Você comprou "..itemData.item.." por $"..vRP.format(itemData.price))
            else
                TriggerClientEvent("Notify", source, "negado", "Dinheiro sujo insuficiente.")
            end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACK MARKET MENU
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("godz_illegal:openMenu")
AddEventHandler("godz_illegal:openMenu", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local menu = {name="Mercado Negro", css={top="75px",header_color="rgba(0,0,0,0.75)"}}
        
        for k,v in pairs(black_market.items) do
            local name = vRP.getItemName(v.item)
            local price = v.price
            
            menu[name] = {function(player,choice)
                if vRP.tryGetInventoryItem(user_id, "dinheirosujo", price) then
                    vRP.giveInventoryItem(user_id, v.item, 1)
                    TriggerClientEvent("Notify", source, "sucesso", "Comprou "..name)
                else
                    TriggerClientEvent("Notify", source, "negado", "Dinheiro sujo insuficiente.")
                end
            end, "Preço: $"..vRP.format(price).." (Sujo)"}
        end

        vRP.openMenu(source, menu)
    end
end)

-- Send Config to Client
RegisterServerEvent("godz_illegal:requestConfig")
AddEventHandler("godz_illegal:requestConfig", function()
    local source = source
    TriggerClientEvent("godz_illegal:receiveConfig", source, laundry, black_market)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- POLICE SEIZE (/apreender)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("apreender", function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasGroup(user_id, "policia") then
        local nplayer = vRPclient.getNearestPlayer(source, 2)
        if nplayer then
            local nuser_id = vRP.getUserId(nplayer)
            if nuser_id then
                local amount = vRP.getInventoryItemAmount(nuser_id, "dinheirosujo")
                if amount > 0 then
                    if vRP.tryGetInventoryItem(nuser_id, "dinheirosujo", amount) then
                        local bonus = math.floor(amount * 0.10) -- 10% bonus
                        vRP.giveBankMoney(user_id, bonus)
                        TriggerClientEvent("Notify", source, "sucesso", "Apreendido $"..vRP.format(amount).." (Bônus: $"..vRP.format(bonus)..")")
                        TriggerClientEvent("Notify", nplayer, "negado", "Seu dinheiro sujo foi apreendido pela polícia.")
                    end
                else
                    TriggerClientEvent("Notify", source, "aviso", "O cidadão não possui dinheiro sujo.")
                end
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Nenhum cidadão próximo.")
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NEXUS NOTIFICATION (FACTION BLIP)
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Check every 10s if we need to send, but actually just send on join is enough + periodic reminder
        -- This logic is better handled by just notifying on login for simplicity, 
        -- or a command. For now, we rely on the client requesting config and setting blips if they have permission.
        break -- Run once
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        -- Check if user is in a faction (generic perm check or group check)
        -- Assuming 'ilegal.acesso' permission for bad guys
        if vRP.hasPermission(user_id, "ilegal.acesso") then 
            TriggerClientEvent("Notify", source, "importante", "[NEXUS]: Protocolo de limpeza ativo. Localização da lavanderia foi atualizada no seu GPS.")
        end
    end
end)
