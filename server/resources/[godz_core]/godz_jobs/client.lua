
local isMenuOpen = false
local currentJob = nil
local missionData = nil
local missionStep = 0

-- Receber lista de jobs (cache local se precisar, ou apenas para abrir menu)
local availableJobs = {}

RegisterNetEvent("godz_jobs:receiveJobs")
AddEventHandler("godz_jobs:receiveJobs", function(jobs)
    availableJobs = jobs
    -- Abrir NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        jobs = jobs
    })
    isMenuOpen = true
end)

-- Loop de Markers para abrir menu
Citizen.CreateThread(function()
    while true do
        local idle = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Central de Empregos (Coordenada Fictícia, ajustar depois ou pegar de config)
        -- Vamos assumir que cada job tem seu marker se for modular Zirix Style
        -- Mas o pedido diz "Menu de Empregos (GODZ Signature)", sugerindo uma central ou markers individuais.
        -- Vou implementar markers individuais baseado no GodzJobs (precisaria ser compartilhado).
        -- Como client não tem acesso direto a GodzJobs (está no server), precisamos que o server envie as coords no init ou client tenha config.
        -- SOLUÇÃO: Criar um Config.lua compartilhado ou pedir coords ao conectar.
        
        -- Vamos usar o evento requestJobs ao pressionar uma tecla em local específico ou comando por enquanto,
        -- ou melhor: Um Config.lua compartilhado seria ideal.
    
        if not isMenuOpen then
            -- Para simplicidade, vamos por um blip na praça ou algo assim,
            -- OU melhor: fazer o server enviar os blips ao conectar.
        end
        
        Citizen.Wait(idle)
    end
end)

-- Como o fxmanifest tem shared_script 'config.lua', vamos usá-lo para coordenadas.

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb("ok")
end)

RegisterNUICallback("startJob", function(data, cb)
    TriggerServerEvent("godz_jobs:startJob", data.jobId)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb("ok")
end)

RegisterNetEvent("godz_jobs:startMission")
AddEventHandler("godz_jobs:startMission", function(jobId, context)
    currentJob = jobId
    missionStep = 1
    
    -- Notificação HUD
    SendNUIMessage({
        action = "showHUD",
        jobName = jobId, -- Idealmente o nome bonito
        context = context,
        progress = 0
    })
    
    -- Iniciar lógica específica do job (precisaria ter o código do job no client também)
    -- Como é modular, o arquivo job.lua também roda no client.
    -- Vamos disparar um evento que o job específico escuta.
    TriggerEvent("godz_jobs:client:start_" .. jobId, context)
end)

-- Atualizar HUD
RegisterNetEvent("godz_jobs:updateProgress")
AddEventHandler("godz_jobs:updateProgress", function(progress, text)
    SendNUIMessage({
        action = "updateHUD",
        progress = progress,
        text = text
    })
end)

-- Comando para abrir menu (para teste e facilidade)
RegisterCommand("empregos", function()
    TriggerServerEvent("godz_jobs:requestJobs")
end)
