
local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")

-- Configuração dos Webhooks (Preencha com URLs reais)
local webhooks = {
    ["entrada"] = "", 
    ["saida"] = "",
    ["mortes"] = "",
    ["chat"] = "",
    ["compras"] = "",
    ["admin"] = "",
    ["injector"] = "" -- Log específico para suspeita de injector
}

-- Cores para os Embeds
local colors = {
    ["entrada"] = 3066993, -- Verde
    ["saida"] = 15158332, -- Vermelho
    ["mortes"] = 0, -- Preto
    ["chat"] = 3447003, -- Azul
    ["compras"] = 15844367, -- Dourado
    ["admin"] = 10181046, -- Roxo
    ["injector"] = 16711680 -- Vermelho Sangue
}

function vRP.sendLog(type, title, message, user_id)
    local webhook = webhooks[type]
    
    -- Se não tiver webhook configurado, imprime no console para debug
    if not webhook or webhook == "" then 
        print("[vRP Logs] Webhook não configurado para: " .. type)
        print("[vRP Logs] " .. title .. ": " .. message)
        return 
    end

    local color = colors[type] or 16777215 -- Branco padrão
    
    local embed = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Godz Roleplay • " .. os.date("%d/%m/%Y %H:%M:%S"),
            },
        }
    }

    if user_id then
        local source = vRP.getUserSource(user_id)
        local ip = "Desconhecido"
        local steam = "N/A"
        local discord = "N/A"
        local license = "N/A"

        if source then
            ip = GetPlayerEndpoint(source) or "Desconhecido"
            local identifiers = GetPlayerIdentifiers(source)
            for _, v in pairs(identifiers) do
                if string.find(v, "steam:") then
                    steam = v
                elseif string.find(v, "discord:") then
                    discord = v
                elseif string.find(v, "license:") then
                    license = v
                end
            end
        else
            -- Tenta pegar do banco se o player estiver offline (opcional, requer query extra)
            -- Por enquanto, mantém simples para performance
        end

        embed[1]["fields"] = {
            { ["name"] = "ID", ["value"] = tostring(user_id), ["inline"] = true },
            { ["name"] = "IP", ["value"] = tostring(ip), ["inline"] = true },
            { ["name"] = "Steam", ["value"] = tostring(steam), ["inline"] = true },
            { ["name"] = "Discord", ["value"] = tostring(discord), ["inline"] = true }
        }
    end

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Godz Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Evento para uso externo (Client ou outros scripts)
RegisterNetEvent("vRP:sendLog")
AddEventHandler("vRP:sendLog", function(type, title, message, user_id)
    -- Proteção básica para evitar spam de logs via client (opcional)
    local source = source
    if user_id == nil and source then
        user_id = vRP.getUserId(source)
    end
    vRP.sendLog(type, title, message, user_id)
end)

-- Export para facilitar uso em outros scripts
exports('sendLog', vRP.sendLog)
