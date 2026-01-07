local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
server = Tunnel.getInterface("godz_garages")

local currentGarage = nil

Citizen.CreateThread(function()
    -- Register Public Garages
    for name, garage in pairs(Config.Garages) do
        exports["godz_target"]:AddTargetModel(Config.PedModel, {
            options = {
                {
                    event = "godz_garages:open",
                    icon = "fas fa-car",
                    label = "Abrir Garagem",
                    garageName = name,
                    garageType = garage.type,
                    spawnPoint = garage.spawnPoint
                }
            },
            distance = 2.5
        })
        
        -- Create NPCs
        RequestModel(GetHashKey(Config.PedModel))
        while not HasModelLoaded(GetHashKey(Config.PedModel)) do Citizen.Wait(10) end
        
        local ped = CreatePed(4, GetHashKey(Config.PedModel), garage.coords.x, garage.coords.y, garage.coords.z - 1.0, garage.heading, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end
    
    -- Register Home Garages
    Citizen.Wait(1000) -- Wait for Housing to init
    if Housing then
        Housing.getAllHomes({}, function(homes)
            for id, home in pairs(homes) do
                if home.garage then
                    local g = json.decode(home.garage)
                    if g and g.x then
                         exports["godz_target"]:AddTargetCircle("home_garage_"..id, vector3(g.x, g.y, g.z), 1.5, {
                            options = {
                                {
                                    event = "godz_garages:openHome",
                                    icon = "fas fa-warehouse",
                                    label = "Garagem Privada",
                                    homeId = id
                                }
                            }
                        })
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent("godz_garages:openHome")
AddEventHandler("godz_garages:openHome", function(data)
    local homeId = data.homeId
    
    server.checkHomeAccess({homeId}, function(access, garageInfo)
        if access and garageInfo then
            currentGarage = {
                garageName = "Casa " .. homeId,
                garageType = "home",
                spawnPoint = vector4(garageInfo.x, garageInfo.y, garageInfo.z, garageInfo.h)
            }
            
            server.getVehicles({}, function(vehicles)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "open",
                    garageName = currentGarage.garageName,
                    vehicles = vehicles
                })
            end)
        else
            TriggerEvent("godz_notify:notify", "negado", "Garagem", "Você não tem acesso a esta garagem.")
        end
    end)
end)

RegisterNetEvent("godz_garages:open")
AddEventHandler("godz_garages:open", function(data)
    local garageName = data.garageName or "Unknown"
    local garageType = data.garageType or "public"
    
    currentGarage = data -- Store context (spawnPoint, etc)

    -- Fetch Vehicles
    server.getVehicles({}, function(vehicles)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            garageName = garageName,
            vehicles = vehicles
        })
    end)
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("spawn", function(data, cb)
    local vehicle = data.vehicle
    
    server.checkSpawn({vehicle, currentGarage.garageType}, function(allowed, message)
        if allowed then
            SetNuiFocus(false, false)
            SpawnVehicle(vehicle, currentGarage.spawnPoint)
            TriggerEvent("godz_notify:notify", "sucesso", "Garagem", "Veículo retirado.")
        else
            TriggerEvent("godz_notify:notify", "negado", "Garagem", message)
        end
    end)
    cb("ok")
end)

RegisterNUICallback("payInsurance", function(data, cb)
    server.payInsurance({data.vehicle}, function(success, msg)
        if success then
            TriggerEvent("godz_notify:notify", "sucesso", "Seguro", msg)
            -- Refresh list
            server.getVehicles({}, function(vehicles)
                SendNUIMessage({
                    action = "updateList",
                    vehicles = vehicles
                })
            end)
        else
            TriggerEvent("godz_notify:notify", "negado", "Seguro", msg)
        end
    end)
    cb("ok")
end)

function SpawnVehicle(model, coords)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    
    -- Check if spawn point is clear
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
        TriggerEvent("godz_notify:notify", "aviso", "Garagem", "Vaga ocupada.")
        return
    end

    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityAsMissionEntity(veh, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    
    -- Set Properties (Engine, Body, Fuel) should be fetched and applied
    -- For MVP, we assume 100% or stored state if we passed it.
    -- TODO: Add state application from DB data.
end

-- Store Vehicle Logic (Target on Vehicle or Zone?)
-- Usually "Guardar" is an option on the vehicle itself via Target when near a garage
-- Or a separate "Delete Zone".
-- Let's add a "Guardar" option to vehicles if near a garage.
Citizen.CreateThread(function()
    local garageZones = {}
    for name, g in pairs(Config.Garages) do
        table.insert(garageZones, g.coords)
    end
    
    -- We can use godz_target GlobalVehicle options
    exports["godz_target"]:AddGlobalVehicle({
        options = {
            {
                event = "godz_garages:store",
                icon = "fas fa-parking",
                label = "Guardar Veículo",
                canInteract = function(entity)
                    local pCoords = GetEntityCoords(PlayerPedId())
                    for _, coord in pairs(garageZones) do
                        if #(pCoords - coord) < 10.0 then return true end
                    end
                    return false
                end
            }
        }
    })
end)

RegisterNetEvent("godz_garages:store")
AddEventHandler("godz_garages:store", function(data)
    local entity = data.entity
    if not entity then return end
    
    -- Get Model Name
    -- vRP needs model name (string). GetEntityModel returns hash.
    -- We need to check against a list or use a native if available?
    -- Native `GetDisplayNameFromVehicleModel` gives display name, not spawn name.
    -- We usually assume the player owns it, so we can check their owned vehicles hashes?
    -- For now, let's rely on server matching or `GetEntityModel`.
    -- Wait, `server.storeVehicle` expects `vehicle` name.
    -- Correct approach: Check if `GetVehicleNumberPlateText(entity)` matches user's owned vehicle.
    -- But we don't have that list here.
    -- We'll delete the entity and tell server to store based on PLATE.
    
    -- Actually, simpler: Server checks if user owns a vehicle with this plate.
    -- But vRP `godz_user_vehicles` stores by `vehicle` (model name).
    -- If we don't have the model name, we can't update the specific row easily if user has duplicates?
    -- vRP doesn't support duplicates of same model usually (primary key user_id, vehicle).
    
    -- Workaround: Loop through all known vehicle models or fetch user's vehicles and compare hash.
    server.getVehicles({}, function(vehicles)
        local modelHash = GetEntityModel(entity)
        local foundModel = nil
        for _, v in pairs(vehicles) do
            if GetHashKey(v.vehicle) == modelHash then
                foundModel = v.vehicle
                break
            end
        end
        
        if foundModel then
            local engine = GetVehicleEngineHealth(entity)
            local body = GetVehicleBodyHealth(entity)
            local fuel = GetVehicleFuelLevel(entity)
            
            DeleteEntity(entity)
            server.storeVehicle({foundModel, {engine=engine, body=body, fuel=fuel}})
        else
            TriggerEvent("godz_notify:notify", "negado", "Erro", "Veículo não pertence a você.")
        end
    end)
end)
