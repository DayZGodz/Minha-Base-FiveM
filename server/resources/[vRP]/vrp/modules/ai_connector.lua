
-- GODZ AI CONNECTOR
-- Módulo responsável pela comunicação entre o servidor FiveM e a API Python (Godz AI Bridge)

local API_URL = "http://127.0.0.1:5000"
local API_KEY = "godz_secret_key_123"

-- Função Global de Requisição com Retry Automático
function vRP.askGodzAI(endpoint, data, callback, attempt)
    local currentAttempt = attempt or 1
    local maxAttempts = 2

    print("[GODZ] Tentando conectar com a IA (Tentativa " .. currentAttempt .. ")...")
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. API_KEY
    }
    
    PerformHttpRequest(API_URL .. endpoint, function(errorCode, resultData, resultHeaders)
        -- Se der erro 0 (Connection Refused) e ainda tiver tentativas
        if (errorCode == 0 or errorCode == 404 or errorCode == 500) and currentAttempt < maxAttempts then
            print("[NEXUS] Tentando reconectar ao cérebro... (Tentativa " .. currentAttempt .. ")")
            SetTimeout(5000, function()
                vRP.askGodzAI(endpoint, data, callback, currentAttempt + 1)
            end)
            return
        end

        if callback then
            callback(errorCode, resultData, resultHeaders)
        end
    end, 'POST', json.encode(data), headers)
end

-- Comando /ajuda
RegisterCommand('ajuda', function(source, args, rawCommand)
    local question = table.concat(args, " ")
    if question == "" then
        TriggerClientEvent("Notify", source, "negado", "Digite uma pergunta. Ex: /ajuda Como comprar um carro?")
        return
    end

    local user_id = vRP.getUserId(source)

    -- Health Check antes de enviar
    PerformHttpRequest(API_URL .. "/health", function(err, text, headers)
        if err ~= 200 then
             TriggerClientEvent("Notify", source, "negado", "O suporte inteligente está offline no momento.")
             return
        end

        TriggerClientEvent("Notify", source, "importante", "Aguarde, o Godz AI está pensando...")

        -- Envia pergunta para a IA
        vRP.askGodzAI("/ai_assist", {
            question = question,
            user_id = user_id
        }, function(code, res, headers)
            if code == 200 then
                local body = json.decode(res)
                if body and body.response then
                    TriggerClientEvent("Notify", source, "sucesso", "IA: " .. body.response)
                else
                    TriggerClientEvent("Notify", source, "negado", "A IA não conseguiu responder agora.")
                end
            else
                TriggerClientEvent("Notify", source, "negado", "Erro ao comunicar com a IA.")
            end
        end)
    end, 'GET')
end)

-- Sentinel System (Anti-Cheat Comportamental)
AddEventHandler("vRP:playerJoin", function(user_id, source, name)
    local ip = GetPlayerEndpoint(source)
    
    -- Envia dados para análise assim que o jogador entra
    vRP.askGodzAI("/sentinel_check", {
        user_id = user_id,
        ip = ip,
        name = name,
        flag_type = "connection_check",
        details = "Verificação de entrada do jogador (IP/ID)"
    }, function(code, res, headers)
        -- O Python já lida com o log no Discord se houver flag de perigo
        if code == 200 then
            local body = json.decode(res)
            if body.status == "alert_sent" then
                print("[GODZ AI] Sentinel Alert disparado para User ID: " .. user_id)
            end
        end
    end)
end)
