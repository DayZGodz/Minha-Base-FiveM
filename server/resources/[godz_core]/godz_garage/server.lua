local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

RegisterNetEvent("godz_garage:requestVehicles")
AddEventHandler("godz_garage:requestVehicles", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end
    
    MySQL.query("SELECT * FROM godz_user_vehicles WHERE user_id = @user_id", {user_id = user_id}, function(rows)
        local vehicles = {}
        if rows then
            for _, row in ipairs(rows) do
                table.insert(vehicles, {
                    name = row.vehicle, 
                    plate = row.vehicle_plate,
                    fuel = row.fuel or 100,
                    engine = row.engine or 1000,
                    body = row.body or 1000,
                    report = row.mechanic_report
                })
            end
        end
        TriggerClientEvent("godz_garage:receiveVehicles", source, vehicles)
    end)
end)

RegisterNetEvent("godz_garage:spawnVehicle")
AddEventHandler("godz_garage:spawnVehicle", function(plate)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end
    
    local rows = MySQL.query.await("SELECT * FROM godz_user_vehicles WHERE user_id = @user_id AND vehicle_plate = @plate", {
        user_id = user_id,
        plate = plate
    })
    
    if #rows > 0 then
        local row = rows[1]
        local model = row.vehicle
        
        -- Get Mods
        local mods = nil
        local modRows = MySQL.query.await("SELECT mods FROM godz_vehicle_mods WHERE plate = @plate", {plate = plate})
        if modRows and #modRows > 0 then
            mods = json.decode(modRows[1].mods)
        end
        
        -- Trigger Client Spawn
        TriggerClientEvent("godz_garage:spawnClient", source, model, plate, mods, row)
        TriggerClientEvent("Notify", source, "sucesso", "Veículo retirado da garagem.")
    else
        TriggerClientEvent("Notify", source, "negado", "Veículo não encontrado.")
    end
end)

RegisterNetEvent("godz_garage:storeVehicle")
AddEventHandler("godz_garage:storeVehicle", function(props)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end
    
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    
    -- Verify ownership (via plate)
    local rows = MySQL.query.await("SELECT user_id FROM godz_user_vehicles WHERE vehicle_plate = @plate AND user_id = @user_id", {
        plate = props.plate,
        user_id = user_id
    })
    
    if #rows > 0 then
        -- Async Update
        -- "Otimização de Persistência: ... exports.oxmysql:update de forma assíncrona"
        exports.oxmysql:update("UPDATE godz_user_vehicles SET fuel = @fuel, engine = @engine, body = @body WHERE vehicle_plate = @plate AND user_id = @user_id", {
            fuel = props.fuel,
            engine = props.engine,
            body = props.body,
            plate = props.plate,
            user_id = user_id
        })
        
        -- Delete Entity
        local entity = NetworkGetEntityFromNetworkId(props.netId) 
        -- Client didn't send netId in props, but we can get it via `GetVehiclePedIsIn`.
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
        
        TriggerClientEvent("Notify", source, "sucesso", "Veículo guardado com sucesso.")
    else
        TriggerClientEvent("Notify", source, "negado", "Este veículo não pertence a você.")
    end
end)
