local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

GodzJobs = {}
JobsConfig = {}

-- Evento para receber configurações dos módulos
-- Como os scripts são carregados no mesmo ambiente, eles podem acessar GodzJobs diretamente se for global.
-- Mas vamos garantir inicialização.

Citizen.CreateThread(function()
    print("^2[GODZ JOBS] Sistema modular iniciado.^0")
    print("^2[GODZ JOBS] Carregando " .. GetTableSize(GodzJobs) .. " empregos.^0")
end)

function GetTableSize(t)
    local c = 0
    for _,_ in pairs(t) do c = c + 1 end
    return c
end

-- Rota para Client pegar jobs
RegisterNetEvent("godz_jobs:requestJobs")
AddEventHandler("godz_jobs:requestJobs", function()
    local source = source
    local jobsList = {}
    
    for k, v in pairs(GodzJobs) do
        table.insert(jobsList, {
            id = k,
            name = v.name,
            description = v.description,
            icon = v.icon or "fas fa-briefcase",
            coords = v.coords
        })
    end
    
    TriggerClientEvent("godz_jobs:receiveJobs", source, jobsList)
end)

-- Iniciar Missão (IA Integration)
RegisterNetEvent("godz_jobs:startJob")
AddEventHandler("godz_jobs:startJob", function(jobId)
    local source = source
    local user_id = vRP.getUserId(source)
    local job = GodzJobs[jobId]
    
    if job then
        -- Gerar contexto via IA
        local prompt = "Gere um contexto de missão curto (max 15 palavras) para um emprego de " .. job.name .. ". Exemplo: 'Entrega urgente no hospital'."
        
        -- Simulando ou chamando endpoint real
        PerformHttpRequest("http://localhost:5000/ai_assist", function(err, text, headers)
            local context = "Missão iniciada. Siga os objetivos."
            
            if err == 200 and text then
                local data = json.decode(text)
                if data and data.report then
                    context = data.report
                end
            else
                -- Fallback
                if job.fallback_context then
                    context = job.fallback_context[math.random(#job.fallback_context)]
                end
            end
            
            TriggerClientEvent("godz_jobs:startMission", source, jobId, context)
            TriggerClientEvent("Notify", source, "ia_tip", "IA Mission: " .. context)
        end, 'POST', json.encode({prompt = prompt}), { ["Content-Type"] = 'application/json' })
    end
end)

-- Pagamento
RegisterNetEvent("godz_jobs:finishMission")
AddEventHandler("godz_jobs:finishMission", function(jobId, steps)
    local source = source
    local user_id = vRP.getUserId(source)
    local job = GodzJobs[jobId]
    
    if job then
        local basePayment = job.payment or 100
        
        -- Integração Economia
        local multiplier = 1.0
        if GetResourceState("godz_economy") == "started" then
            multiplier = exports["godz_economy"]:GetPriceMultiplier("Jobs") or 1.0
        end
        
        local finalPayment = math.floor(basePayment * multiplier * (steps or 1))
        
        vRP.giveMoney(user_id, finalPayment)
        TriggerClientEvent("Notify", source, "sucesso", "Você recebeu $" .. finalPayment)
        
        if multiplier > 1.2 then
             TriggerClientEvent("Notify", source, "aviso", "Bônus de alta demanda aplicado!")
        elseif multiplier < 0.8 then
             TriggerClientEvent("Notify", source, "aviso", "Pagamento reduzido devido à crise econômica.")
        end
    end
end)
