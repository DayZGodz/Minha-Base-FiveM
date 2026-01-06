local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
server = Tunnel.getInterface("godz_jobs")

local currentJob = nil
local currentBlip = nil
local destination = nil

-- Spawn NPCs
Citizen.CreateThread(function()
    for k, v in pairs(Config.Jobs) do
        local hash = GetHashKey(v.npc.model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Citizen.Wait(10) end
        
        local npc = CreatePed(4, hash, v.npc.coords.x, v.npc.coords.y, v.npc.coords.z - 1.0, v.npc.coords.w, false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        if exports["godz_target"] then
            exports["godz_target"]:AddTargetEntity(npc, {
                options = {
                    {
                        event = "godz_jobs:openMenu",
                        icon = v.icon,
                        label = "Central: " .. v.label,
                        jobKey = k
                    }
                },
                distance = 2.0
            })
        end
    end
end)

RegisterNetEvent("godz_jobs:openMenu")
AddEventHandler("godz_jobs:openMenu", function(data)
    server.getAllJobsData({}, function(jobsData)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "open",
            jobs = Config.Jobs,
            data = jobsData
        })
    end)
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startJob", function(data, cb)
    SetNuiFocus(false, false)
    StartRoute(data.jobKey)
    cb("ok")
end)

function StartRoute(jobKey)
    if currentJob then 
        TriggerEvent("godz_notify:notify", "aviso", "Atenção", "Você já está em serviço.")
        return 
    end
    
    currentJob = jobKey
    local points = Config.Routes
    destination = points[math.random(#points)]
    
    -- Set Blip
    currentBlip = AddBlipForCoord(destination.x, destination.y, destination.z)
    SetBlipSprite(currentBlip, 1)
    SetBlipColour(currentBlip, 5)
    SetBlipRoute(currentBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destino do Trabalho")
    EndTextCommandSetBlipName(currentBlip)
    
    TriggerEvent("godz_notify:notify", "sucesso", "Serviço Iniciado", "Vá até o destino marcado no GPS.")
    
    -- Monitor
    Citizen.CreateThread(function()
        while currentJob == jobKey do
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - destination)
            
            if dist < 10.0 then
                -- Finish
                TriggerServerEvent("godz_jobs:finishRoute", currentJob)
                RemoveBlip(currentBlip)
                currentJob = nil
                currentBlip = nil
                destination = nil
                TriggerEvent("godz_notify:notify", "sucesso", "Concluído", "Rota finalizada.")
                break
            end
            
            Citizen.Wait(1000)
        end
    end)
end
