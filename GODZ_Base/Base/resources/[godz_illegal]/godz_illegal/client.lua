local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
server = Tunnel.getInterface("godz_illegal")

local isProcessing = false

-- Drug System
Citizen.CreateThread(function()
    if exports["godz_target"] then
        -- Add targets for Drug Processing
        for drugName, data in pairs(Config.Drugs) do
            exports["godz_target"]:AddCircleZone("drug_"..drugName, data.processPos, 1.0, {
                name = "drug_"..drugName,
                debugPoly = false,
            }, {
                options = {
                    {
                        event = "godz_illegal:startProcess",
                        icon = "fas fa-flask",
                        label = "Processar " .. drugName,
                        drugType = drugName
                    }
                },
                distance = 2.0
            })
        end
    end
end)

RegisterNetEvent("godz_illegal:startProcess")
AddEventHandler("godz_illegal:startProcess", function(data)
    if isProcessing then return end
    local drugType = data.drugType
    local drugData = Config.Drugs[drugType]
    
    isProcessing = true
    
    -- Animation
    local ped = PlayerPedId()
    RequestAnimDict(drugData.animDict)
    while not HasAnimDictLoaded(drugData.animDict) do Citizen.Wait(10) end
    TaskPlayAnim(ped, drugData.animDict, drugData.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Progress Bar (Simulating Minigame)
    TriggerEvent("progress", drugData.time, "Processando " .. drugType)
    Citizen.Wait(drugData.time)
    
    ClearPedTasks(ped)
    isProcessing = false
    
    -- Server Call
    server.processDrug({drugType})
end)

-- Chop Shop System
local nearbyVehicle = nil
local dismantledParts = {}

Citizen.CreateThread(function()
    while true do
        local idle = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.ChopShop.zone)
        
        if dist < Config.ChopShop.radius then
            idle = 5
            -- Check for vehicle
            local veh = GetVehiclePedIsIn(ped, false)
            if veh == 0 then
                veh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71)
            end
            
            if veh ~= 0 and not dismantledParts[veh] then
                -- Draw Text or 3D
                DrawText3D(pos.x, pos.y, pos.z + 1.0, "[E] Desmanchar Veículo")
                
                if IsControlJustPressed(0, 38) then
                    StartChopShop(veh)
                end
            end
        end
        Citizen.Wait(idle)
    end
end)

function StartChopShop(vehicle)
    local ped = PlayerPedId()
    local plate = GetVehicleNumberPlateText(vehicle)
    dismantledParts[vehicle] = { doors = false, hood = false, wheels = false }
    
    -- Interaction Loop
    -- Simplified: Automatic sequence or Menu. Let's do a sequence of prompts.
    
    -- 1. Remove Doors
    PlayChopAnim("Porta", 5000)
    SetVehicleDoorBroken(vehicle, 0, true)
    SetVehicleDoorBroken(vehicle, 1, true)
    server.dismantlePart({"Porta", plate})
    
    -- 2. Remove Hood
    PlayChopAnim("Capô", 5000)
    SetVehicleDoorBroken(vehicle, 4, true)
    server.dismantlePart({"Capô", plate})
    
    -- 3. Remove Wheels
    PlayChopAnim("Roda", 5000)
    SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
    SetVehicleTyreBurst(vehicle, 1, true, 1000.0)
    server.dismantlePart({"Roda", plate})
    
    -- Finish
    server.finishChopShop({plate, GetEntityModel(vehicle)})
    DeleteEntity(vehicle)
end

function PlayChopAnim(part, duration)
    local ped = PlayerPedId()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do Citizen.Wait(10) end
    TaskPlayAnim(ped, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    TriggerEvent("progress", duration, "Removendo " .. part)
    Citizen.Wait(duration)
    ClearPedTasks(ped)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

-- Faction Panel
RegisterCommand("fmenu", function()
    server.getFactionData({}, function(data)
        if data then
            SetNuiFocus(true, true)
            SendNUIMessage({ action = "open", data = data })
        else
            TriggerEvent("Notify", "negado", "Você não pertence a uma facção.")
        end
    end)
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)
