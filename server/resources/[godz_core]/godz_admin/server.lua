local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local shield_alerts = {}

--[ COMMAND ]---------------------------------------------------------------------------------------------------

RegisterCommand('admin', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "admin.permissao") then
        TriggerClientEvent("godz_admin:open", source, shield_alerts)
    else
        TriggerClientEvent("Notify", source, "negado", "Você não tem permissão.")
    end
end)

--[ EVENTS ]----------------------------------------------------------------------------------------------------

RegisterServerEvent("godz_admin:action")
AddEventHandler("godz_admin:action", function(data)
    local source = source
    local user_id = vRP.getUserId(source)
    
    if not vRP.hasPermission(user_id, "admin.permissao") then 
        print("Unauthorized admin action attempt by user_id: " .. tostring(user_id))
        return 
    end

    if data.action == "ban" then
        local target_id = parseInt(data.target_id)
        local reason = data.reason or "Banido pelo Administrador"
        
        vRP.setBanned(target_id, true)
        -- Kick if online
        local target_source = vRP.getUserSource(target_id)
        if target_source then
            vRP.kick(target_source, reason)
        end
        TriggerClientEvent("Notify", source, "sucesso", "ID " .. target_id .. " banido.")

    elseif data.action == "unban" then
        local target_id = parseInt(data.target_id)
        vRP.setBanned(target_id, false)
        TriggerClientEvent("Notify", source, "sucesso", "ID " .. target_id .. " desbanido.")

    elseif data.action == "spawnVehicle" then
        local model = data.model
        if model then
            vRPclient.spawnVehicle(source, model)
            TriggerClientEvent("Notify", source, "sucesso", "Veículo " .. model .. " spawnado.")
        end

    elseif data.action == "giveItem" then
        local target_id = parseInt(data.target_id)
        local item = data.item
        local amount = parseInt(data.amount)
        
        if target_id and item and amount > 0 then
            vRP.giveInventoryItem(target_id, item, amount)
            TriggerClientEvent("Notify", source, "sucesso", "Enviado " .. amount .. "x " .. item .. " para ID " .. target_id)
        end

    elseif data.action == "revive" then
        local target_id = parseInt(data.target_id)
        local target_source = vRP.getUserSource(target_id)
        if target_source then
            vRPclient.killGod(target_source)
            vRPclient.setHealth(target_source, 400)
            TriggerClientEvent("Notify", source, "sucesso", "ID " .. target_id .. " revivido.")
        else
            TriggerClientEvent("Notify", source, "negado", "Jogador offline.")
        end
    end
end)

--[ SHIELD INTEGRATION ]----------------------------------------------------------------------------------------

RegisterServerEvent("godz_shield:alert")
AddEventHandler("godz_shield:alert", function(alertData)
    -- alertData expected: { type = "injection", user_id = 1, details = "..." }
    local alert = {
        time = os.date("%H:%M:%S"),
        type = alertData.type or "Unknown",
        user_id = alertData.user_id or "Unknown",
        details = alertData.details or "No details"
    }
    
    table.insert(shield_alerts, 1, alert)
    if #shield_alerts > 20 then table.remove(shield_alerts) end -- Keep last 20

    -- Broadcast to online admins
    local users = vRP.getUsers()
    for _, src in pairs(users) do
        local uid = vRP.getUserId(src)
        if vRP.hasPermission(uid, "admin.permissao") then
            TriggerClientEvent("godz_admin:newAlert", src, alert)
        end
    end
end)
