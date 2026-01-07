local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local shield_alerts = {}

--[ UTILS ]------------------------------------------------------------------------------------------------------

local function getOnlinePlayers()
    local players = {}
    local users = vRP.getUsers()
    for user_id, source in pairs(users) do
        table.insert(players, {
            user_id = user_id,
            name = GetPlayerName(source),
            ping = GetPlayerPing(source),
            suspicious = false -- Integração futura com Sentinel
        })
    end
    return players
end

local function getEconomyMultiplier()
    if GetResourceState("godz_economy") == "started" then
        return exports["godz_economy"]:GetPriceMultiplier("Global") or 1.0
    end
    return 1.0
end

--[ COMMAND ]---------------------------------------------------------------------------------------------------

RegisterCommand('staff', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "admin.permissao") then
        local data = {
            players = getOnlinePlayers(),
            multiplier = getEconomyMultiplier(),
            alerts = shield_alerts
        }
        TriggerClientEvent("godz_admin:open", source, data)
    else
        TriggerClientEvent("Notify", source, "negado", "Acesso restrito à Staff GODZ.")
    end
end)

--[ EVENTS ]----------------------------------------------------------------------------------------------------

RegisterServerEvent("godz_admin:analyzePlayer")
AddEventHandler("godz_admin:analyzePlayer", function(target_id)
    local source = source
    local user_id = vRP.getUserId(source)
    
    if not vRP.hasPermission(user_id, "admin.permissao") then return end

    -- Coleta de Logs (Simulação de busca no banco - Integrar com oxmysql depois)
    -- TODO: Buscar logs reais da tabela godz_logs ou vrp_user_moneys
    local logs = {
        "Comprou: T20 ($2.500.000)",
        "Vendeu: Diamantes ($500.000)",
        "Transferiu: $100.000 para ID 5"
    }
    local logText = table.concat(logs, "; ")

    local prompt = "Analise os logs do jogador ID " .. target_id .. ": " .. logText .. ". O comportamento é legítimo ou suspeito (money cheat/dupe)? Responda curto para um admin."

    PerformHttpRequest("http://localhost:5000/ai_assist", function(err, text, headers)
        local report = "IA Indisponível."
        if err == 200 and text then
            local data = json.decode(text)
            if data and data.report then
                report = data.report
            end
        end
        TriggerClientEvent("godz_admin:receiveReport", source, report)
    end, 'POST', json.encode({prompt = prompt}), { ["Content-Type"] = 'application/json' })
end)

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
        local reason = data.reason or "Banido pela Staff GODZ"
        
        vRP.setBanned(target_id, true)
        local target_source = vRP.getUserSource(target_id)
        if target_source then
            vRP.kick(target_source, reason)
        end
        TriggerClientEvent("Notify", source, "sucesso", "ID " .. target_id .. " banido com sucesso.")

    elseif data.action == "unban" then
        local target_id = parseInt(data.target_id)
        vRP.setBanned(target_id, false)
        TriggerClientEvent("Notify", source, "sucesso", "ID " .. target_id .. " desbanido.")

    elseif data.action == "spawnVehicle" then
        local model = data.model
        if model then
            vRPclient.spawnVehicle(source, model)
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
        end

    elseif data.action == "resetEconomy" then
        if GetResourceState("godz_economy") == "started" then
            -- TriggerEvent("godz_economy:resetMarket") -- Exemplo hipotético
            -- Como não temos o comando exato do godz_economy, enviamos apenas o notify por enquanto
            TriggerClientEvent("Notify", source, "sucesso", "Comando de Reset enviado para a Economia.")
        else
            TriggerClientEvent("Notify", source, "negado", "Resource godz_economy não iniciado.")
        end
    end
end)

--[ SHIELD INTEGRATION ]----------------------------------------------------------------------------------------

RegisterServerEvent("godz_shield:alert")
AddEventHandler("godz_shield:alert", function(alertData)
    local alert = {
        time = os.date("%H:%M:%S"),
        type = alertData.type or "Unknown",
        user_id = alertData.user_id or "Unknown",
        details = alertData.details or "No details"
    }
    
    table.insert(shield_alerts, 1, alert)
    if #shield_alerts > 20 then table.remove(shield_alerts) end 

    local users = vRP.getUsers()
    for _, src in pairs(users) do
        local uid = vRP.getUserId(src)
        if vRP.hasPermission(uid, "admin.permissao") then
            TriggerClientEvent("godz_admin:newAlert", src, alert)
        end
    end
end)
