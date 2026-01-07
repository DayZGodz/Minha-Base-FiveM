local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

--[ CONFIG ]------------------------------------------------------------------------------------------------------

local AI_ENDPOINT = "http://localhost:5000/ai_assist"
local DEBUG_MODE = true

--[ FUNCTIONS ]---------------------------------------------------------------------------------------------------

local function analyzeDispatch(source, message, type)
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local identity = vRP.getUserIdentity(user_id)
    local name = identity and (identity.name .. " " .. identity.firstname) or "Cidadão Desconhecido"
    
    local x, y, z = vRPclient.getPosition(source)
    local locationInfo = "Localização: " .. string.format("%.2f, %.2f, %.2f", x, y, z)

    local prompt = "Analise este chamado de emergência (" .. type .. "): '" .. message .. "'. " ..
                   "Gere um resumo profissional curto para despacho policial/médico (max 1 frase) e classifique a prioridade (Baixa/Média/Alta). " ..
                   "Formato de resposta JSON: { \"summary\": \"...\", \"priority\": \"...\" }"

    if DEBUG_MODE then
        print("[GODZ Dispatch] Sending to AI: " .. prompt)
    end

    PerformHttpRequest(AI_ENDPOINT, function(err, text, headers)
        local summary = "Atenção unidades, chamado de " .. type .. ": " .. message
        local priority = "Média"

        if err == 200 and text then
            local data = json.decode(text)
            if data and data.summary and data.priority then
                summary = data.summary
                priority = data.priority
            end
        end

        local users = vRP.getUsers()
        for uid, src in pairs(users) do
            if vRP.hasPermission(uid, "policia.permissao") or vRP.hasPermission(uid, "paramedico.permissao") or vRP.hasPermission(uid, "admin.permissao") then
                TriggerClientEvent("godz_dispatch:show", src, {
                    summary = summary,
                    priority = priority,
                    type = type,
                    coords = {x = x, y = y, z = z},
                    caller = name
                })
            end
        end
    end, 'POST', json.encode({
        prompt = prompt
    }), { ["Content-Type"] = 'application/json' })
end

--[ COMMANDS ]----------------------------------------------------------------------------------------------------

RegisterCommand('911', function(source, args, rawCommand)
    local message = table.concat(args, " ")
    if message == "" then
        TriggerClientEvent("Notify", source, "aviso", "Use: /911 [mensagem]")
        return
    end
    
    TriggerClientEvent("Notify", source, "sucesso", "Chamado enviado! A IA está processando...")
    analyzeDispatch(source, message, "Denúncia Cidadão")
end)

--[ EVENTS ]------------------------------------------------------------------------------------------------------

RegisterServerEvent("godz_dispatch:triggerAlert")
AddEventHandler("godz_dispatch:triggerAlert", function(type, message)
    local source = source
    analyzeDispatch(source, message, type)
end)
