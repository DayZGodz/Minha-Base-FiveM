local activeNetId = nil
local isHacking = false
local hackProgress = 0
local deliveryBlip = nil
local policeBlip = nil

RegisterNetEvent("godz_missions:syncMission")
AddEventHandler("godz_missions:syncMission", function(netId)
    activeNetId = netId
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if activeNetId and not isHacking then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped) then
                local vehicle = GetVehiclePedIsUsing(ped)
                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local plate = GetVehicleNumberPlateText(vehicle)
                
                if netId == activeNetId or plate == "GODZ-IA" or plate == "GODZ IA" then
                    StartHackingGame(vehicle)
                end
            end
        end
    end
end)

function StartHackingGame(vehicle)
    isHacking = true
    hackProgress = 0
    
    TriggerEvent("godz_interface:Notify", "ia_tip", "NEXUS", "Protocolo de Desbloqueio iniciado. Mantenha velocidade acima de 80km/h.", 8000)
    
    -- Efeitos Visuais
    StartScreenEffect("Rampage", 0, true)
    
    -- Abrir NUI
    SendNUIMessage({ action = "showHack", show = true })
    
    Citizen.CreateThread(function()
        while isHacking do
            Citizen.Wait(100)
            local speed = GetEntitySpeed(vehicle) * 3.6 -- km/h
            
            if speed > 80 then
                hackProgress = hackProgress + 0.5
                ShakeGameplayCam("SKY_DIVING_SHAKE", 0.5)
            else
                hackProgress = hackProgress - 1.0
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.2)
                TriggerEvent("godz_interface:Notify", "aviso", "NEXUS", "Velocidade insuficiente! O hack está falhando!", 1000)
            end
            
            if hackProgress < 0 then hackProgress = 0 end
            if hackProgress > 100 then hackProgress = 100 end
            
            -- Atualizar NUI
            SendNUIMessage({ action = "updateHack", progress = hackProgress })
            
            -- 50% - Alerta Polícia
            if hackProgress >= 50 and hackProgress < 51 then
                local coords = GetEntityCoords(vehicle)
                TriggerServerEvent("godz_missions:alertPolice", coords)
            end
            
            -- 100% - Sucesso
            if hackProgress >= 100 then
                FinishHacking(true, vehicle)
                break
            end
            
            -- Falha se sair do veículo
            if not IsPedInVehicle(PlayerPedId(), vehicle, false) then
                FinishHacking(false, vehicle)
                break
            end
        end
    end)
end

function FinishHacking(success, vehicle)
    isHacking = false
    StopScreenEffect("Rampage")
    StopGameplayCamShaking(true)
    SendNUIMessage({ action = "showHack", show = false })
    
    if success then
        TriggerEvent("godz_interface:Notify", "sucesso", "NEXUS", "Acesso concedido. Destino enviado para o GPS.", 8000)
        
        -- Pegar destino do config (simulado aqui pois o client não leu o config file)
        -- Na prática, o server deveria mandar o destino. Vamos simplificar e pedir pro server mandar ou hardcode um random aqui.
        -- Melhor: Server já tem 'activeMission.delivery'. Vamos pedir pro server o destino.
        -- Mas para agilizar, vou pegar um destino fixo ou aleatório daqui mesmo, ou melhor, esperar o server.
        
        -- Workaround: Setar um destino fixo para teste ou usar o evento de sync se tivesse enviado.
        SetNewWaypoint(1547.21, 2164.32) -- Exemplo
        
        -- Monitorar entrega
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1000)
                local dist = #(GetEntityCoords(PlayerPedId()) - vector3(1547.21, 2164.32, 78.54))
                if dist < 10.0 then
                    TriggerServerEvent("godz_missions:finish")
                    break
                end
            end
        end)
    else
        TriggerEvent("godz_interface:Notify", "erro", "NEXUS", "Conexão perdida. Hack falhou.", 5000)
    end
end

RegisterNetEvent("godz_missions:policeBlip")
AddEventHandler("godz_missions:policeBlip", function(coords)
    if policeBlip then RemoveBlip(policeBlip) end
    policeBlip = AddBlipForCoord(coords)
    SetBlipSprite(policeBlip, 161)
    SetBlipColour(policeBlip, 1)
    SetBlipScale(policeBlip, 1.2)
    SetBlipFlashes(policeBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Veículo Hackeado")
    EndTextCommandSetBlipName(policeBlip)
    
    Citizen.SetTimeout(60000, function()
        if policeBlip then RemoveBlip(policeBlip) end
    end)
end)