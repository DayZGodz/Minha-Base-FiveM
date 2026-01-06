local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- SEND LOG FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------------
function SendLog(webhookType, title, message, color, pSource)
    local webhook = Config.Webhooks[webhookType]
    if not webhook or webhook == "" then return end

    if pSource and Config.LogIP then
        local ip = GetPlayerEndpoint(pSource)
        if ip then
            message = message .. "\n**IP:** " .. ip
        end
    end

    local embed = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Unity Logs • " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Unity Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Export para ser usado por outros scripts (ex: Zirix)
exports('SendLog', SendLog)

-- Evento para ser chamado via TriggerServerEvent
RegisterNetEvent("unity_logs:send")
AddEventHandler("unity_logs:send", function(webhookType, title, message, color, pSource)
    -- Se pSource não for passado, tenta pegar o source global se vier de um evento de cliente
    if not pSource and source and source > 0 then
        pSource = source
    end
    SendLog(webhookType, title, message, color, pSource)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- JOIN / LEAVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local id_msg = ""
    for _, v in pairs(identifiers) do
        id_msg = id_msg .. "\n" .. v
    end

    local message = "**Nome:** " .. name .. "\n**Identificadores:**" .. id_msg
    if Config.LogIP then
        message = message .. "\n**IP:** " .. GetPlayerEndpoint(source)
    end

    SendLog("JoinLeave", "Conexão Iniciada", message, Config.Colors.Green)
end)

AddEventHandler("playerDropped", function(reason)
    local source = source
    local user_id = vRP.getUserId(source)
    local name = GetPlayerName(source)
    
    local message = "**Nome:** " .. name .. "\n**ID:** " .. (user_id or "N/A") .. "\n**Motivo:** " .. reason
    SendLog("JoinLeave", "Desconexão", message, Config.Colors.Red)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('chatMessage', function(source, name, message)
    local user_id = vRP.getUserId(source)
    local logMsg = "**ID:** " .. (user_id or "?") .. "\n**Nome:** " .. name .. "\n**Mensagem:** " .. message
    SendLog("Chat", "Mensagem no Chat", logMsg, Config.Colors.Blue)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEATHS (Using baseevents)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
    local source = source
    local user_id = vRP.getUserId(source)
    SendLog("Deaths", "Morte", "O jogador ID " .. (user_id or "?") .. " morreu.", Config.Colors.Red)
end)

RegisterNetEvent('baseevents:onPlayerKilled')
AddEventHandler('baseevents:onPlayerKilled', function(killerId, data)
    local source = source
    local user_id = vRP.getUserId(source)
    local killer_id = vRP.getUserId(killerId)
    SendLog("Deaths", "Homicídio", "O jogador ID " .. (user_id or "?") .. " foi morto pelo ID " .. (killer_id or "?"), Config.Colors.Orange)
end)
