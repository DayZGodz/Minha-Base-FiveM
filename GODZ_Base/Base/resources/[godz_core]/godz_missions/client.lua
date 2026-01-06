local currentMission = nil
local missionBlip = nil

Citizen.CreateThread(function()
    -- Spawnar NPCs
    for _, npc in pairs(Config.NPCs) do
        RequestModel(GetHashKey(npc.model))
        while not HasModelLoaded(GetHashKey(npc.model)) do
            Citizen.Wait(1)
        end
        
        local ped = CreatePed(4, GetHashKey(npc.model), npc.coords.x, npc.coords.y, npc.coords.z, npc.coords.w, false, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        if npc.anim then
            TaskStartScenarioInPlace(ped, npc.anim, 0, true)
        end
        
        -- Adicionar Target
        if exports.godz_target then
            exports.godz_target:AddTargetEntity(ped, {
                options = {
                    {
                        event = "godz_missions:ask",
                        icon = "fas fa-tasks",
                        label = "Solicitar Missão"
                    }
                },
                distance = 2.0
            })
        end
    end
end)

RegisterNetEvent('godz_missions:ask')
AddEventHandler('godz_missions:ask', function()
    if currentMission then
        TriggerEvent("Notify", "negado", "Você já possui uma missão ativa.")
        return
    end
    TriggerServerEvent('godz_missions:requestMission')
end)

RegisterNetEvent('godz_missions:receiveMission')
AddEventHandler('godz_missions:receiveMission', function(mission)
    currentMission = mission
    
    -- Abrir NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        mission = mission
    })
    
    -- Criar Blip (Simulação de local aleatório próximo para teste, na real usaria coordenadas do backend)
    -- Como o backend só mandou o nome do local, vamos simular uma coordenada para o blip
    -- Num sistema real, o backend mandaria x,y,z
    local targetCoords = vector3(100.0, 100.0, 100.0) -- Placeholder
    
    missionBlip = AddBlipForCoord(targetCoords)
    SetBlipSprite(missionBlip, 1)
    SetBlipColour(missionBlip, 5)
    SetBlipRoute(missionBlip, true)
    
    TriggerEvent("Notify", "sucesso", "Missão recebida! Verifique o GPS.")
end)

RegisterNUICallback('accept', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    -- Iniciar contador de tempo, threads de verificação de distância, etc.
    StartMissionThread()
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    currentMission = nil
    if missionBlip then RemoveBlip(missionBlip) end
    cb('ok')
end)

function StartMissionThread()
    Citizen.CreateThread(function()
        while currentMission do
            Citizen.Wait(1000)
            -- Lógica simplificada de conclusão (ex: chegar no blip)
            local plyCoords = GetEntityCoords(PlayerPedId())
            local dist = #(plyCoords - vector3(100.0, 100.0, 100.0)) -- Placeholder coords
            
            if dist < 10.0 then
                TriggerServerEvent('godz_missions:completeMission', currentMission)
                if missionBlip then RemoveBlip(missionBlip) end
                currentMission = nil
                break
            end
        end
    end)
end
