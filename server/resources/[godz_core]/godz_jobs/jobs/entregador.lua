local JOB_ID = "entregador"

if IsDuplicityVersion() then -- SERVER
    GodzJobs[JOB_ID] = {
        name = "Entregador",
        description = "Entregue encomendas pela cidade.",
        payment = 150,
        icon = "fas fa-box-open",
        coords = vec3(-266.94, -960.74, 31.22), -- Central
        fallback_context = {
            "Entrega expressa solicitada pelo cliente VIP.",
            "Cuidado com a carga frágil, evite solavancos.",
            "O trânsito está caótico, encontre atalhos."
        }
    }
else -- CLIENT
    local inMission = false
    local currentBlip = nil
    
    -- Pontos de entrega fictícios
    local deliveryPoints = {
        vec3(-34.56, -110.12, 57.0),
        vec3(234.12, -1890.34, 30.0),
        vec3(-1234.56, -123.45, 10.0)
    }

    RegisterNetEvent("godz_jobs:client:start_" .. JOB_ID)
    AddEventHandler("godz_jobs:client:start_" .. JOB_ID, function(context)
        if inMission then 
            TriggerEvent("Notify", "negado", "Você já está em uma missão!")
            return 
        end
        
        inMission = true
        
        Citizen.CreateThread(function()
            local stepsTotal = 3
            local currentStep = 0
            
            while inMission and currentStep < stepsTotal do
                currentStep = currentStep + 1
                local dest = deliveryPoints[math.random(#deliveryPoints)]
                
                -- Atualizar HUD
                local progress = math.floor(((currentStep - 1) / stepsTotal) * 100)
                TriggerEvent("godz_jobs:updateProgress", progress, "Vá até o ponto de entrega " .. currentStep)
                
                -- Criar Blip
                if currentBlip then RemoveBlip(currentBlip) end
                currentBlip = AddBlipForCoord(dest)
                SetBlipSprite(currentBlip, 1)
                SetBlipColour(currentBlip, 5)
                SetBlipRoute(currentBlip, true)
                
                -- Loop de espera chegar
                local arrived = false
                while not arrived and inMission do
                    local ped = PlayerPedId()
                    local dist = #(GetEntityCoords(ped) - dest)
                    
                    if dist < 10.0 then
                        DrawMarker(1, dest.x, dest.y, dest.z - 1.0, 0,0,0, 0,0,0, 3.0,3.0,1.0, 212,175,55,100, false, true, 2, false, false, false, false)
                        if dist < 2.0 then
                            -- Texto 3D ou Hint
                            -- Assumindo draw text nativo ou vRP
                            if IsControlJustPressed(0, 38) then -- E
                                arrived = true
                                TriggerEvent("Notify", "sucesso", "Entrega realizada!")
                                -- Animação
                                TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
                                Citizen.Wait(3000)
                                ClearPedTasks(ped)
                            end
                        end
                    end
                    Citizen.Wait(0)
                end
                
                if not inMission then break end
            end
            
            if inMission then
                TriggerEvent("godz_jobs:updateProgress", 100, "Trabalho concluído!")
                TriggerServerEvent("godz_jobs:finishMission", JOB_ID, stepsTotal)
                if currentBlip then RemoveBlip(currentBlip) end
                inMission = false
                Citizen.Wait(5000)
                -- Ocultar HUD (opcional, ou deixar o último status)
            end
        end)
    end)
end
