local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local activeMission = nil
local missionConfig = nil

-- Carregar Configuração
Citizen.CreateThread(function()
    local config = LoadResourceFile(GetCurrentResourceName(), "godz_tuning/GODZ_MASTER_CONFIG.json") -- Tenta ler local se path relativo
    -- Fallback para leitura do arquivo se estiver em outro resource (vRP geralmente tem LoadResourceFile)
    -- Assumindo que GODZ_MASTER_CONFIG está acessível ou copiamos os valores.
    -- Para garantir, vamos ler via io se necessário ou assumir que o client mandou.
    -- Mas melhor: ler direto do arquivo físico já que estamos no server.
    
    local loadFile = LoadResourceFile("godz_core", "godz_tuning/GODZ_MASTER_CONFIG.json")
    if loadFile then
        local data = json.decode(loadFile)
        if data and data.MISSIONS then
            missionConfig = data.MISSIONS
            print("GODZ MISSIONS: Config carregada com sucesso.")
        end
    end
end)

-- Gerador de Missões (Thread)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60 * 60 * 1000) -- 60 minutos
        -- Citizen.Wait(30000) -- DEBUG: 30s

        if not activeMission and missionConfig then
            StartNexusMission()
        end
    end
end)

function StartNexusMission()
    local spawn = missionConfig.spawns[math.random(#missionConfig.spawns)]
    local model = missionConfig.vehicles[math.random(#missionConfig.vehicles)]
    local delivery = missionConfig.deliveries[math.random(#missionConfig.deliveries)]
    
    -- Spawn Vehicle (OneSync)
    local vehicle = CreateVehicle(GetHashKey(model), spawn.x, spawn.y, spawn.z, spawn.h, true, true)
    
    -- Aguarda criação
    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 100 do
        Citizen.Wait(100)
        timeout = timeout + 1
    end
    
    if DoesEntityExist(vehicle) then
        SetVehicleNumberPlateText(vehicle, "GODZ-IA")
        SetVehicleDoorsLocked(vehicle, 2) -- Trancado
        
        activeMission = {
            vehicle = vehicle,
            netId = NetworkGetNetworkIdFromEntity(vehicle),
            delivery = delivery,
            hacked = false,
            alerted = false
        }
        
        -- Alerta Global (Opcional ou apenas para hackers)
        TriggerClientEvent("godz_interface:Notify", -1, "ia_tip", "NEXUS", "Oportunidade identificada. Veículo de transporte de dados localizado.", 10000)
        
        -- Sincronizar missão com clientes
        TriggerClientEvent("godz_missions:syncMission", -1, activeMission.netId)
        
        print("GODZ MISSIONS: Missão iniciada. Veículo: "..model.." | NetID: "..activeMission.netId)
    end
end

RegisterServerEvent("godz_missions:alertPolice")
AddEventHandler("godz_missions:alertPolice", function(coords)
    local source = source
    if activeMission and not activeMission.alerted then
        activeMission.alerted = true
        
        local oficiais = vRP.getUsersByPermission("policia.permissao")
        for _,uid in ipairs(oficiais) do
            local ps = vRP.getUserSource(parseInt(uid))
            if ps then
                if vRP.hasGroup(uid,"policia") then
                    TriggerClientEvent("godz_interface:Notify", ps, "ia_tip", "NEXUS", "🚨 Alerta de roubo tecnológico. Veículo rastreado.", 10000)
                    TriggerClientEvent("Notify", ps, "importante", "Veículo GODZ-IA detectado!")
                    vRPclient.playSound(ps, "Oneshot_Final", "MP_MISSION_COUNTDOWN_SOUNDSET")
                    
                    -- Blip
                    TriggerClientEvent("godz_missions:policeBlip", ps, coords)
                end
            end
        end
    end
end)

RegisterServerEvent("godz_missions:finish")
AddEventHandler("godz_missions:finish", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if activeMission and user_id then
        local reward = math.random(50000, 100000)
        vRP.giveInventoryItem(user_id, "dinheirosujo", reward, true)
        
        TriggerClientEvent("godz_interface:Notify", source, "ia_tip", "NEXUS", "Conexão encerrada. Limpe os rastros e desapareça.", 10000)
        
        -- Deletar veículo após um tempo
        Citizen.SetTimeout(10000, function()
            if DoesEntityExist(activeMission.vehicle) then
                DeleteEntity(activeMission.vehicle)
            end
            activeMission = nil
        end)
    end
end)