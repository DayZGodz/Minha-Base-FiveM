
local isMenuOpen = false

-- Garage Locations
local GarageLocations = {
    {x = -336.0, y = -135.0, z = 39.0}, -- Exemplo LSC
    {x = -1140.0, y = -1992.0, z = 13.0} -- Exemplo Aeroporto
}

-- Helper: Get Vehicle Properties
function GetVehicleProperties(vehicle)
    local props = {}
    props.plate = GetVehicleNumberPlateText(vehicle)
    props.model = GetEntityModel(vehicle)
    props.fuel = GetVehicleFuelLevel(vehicle)
    props.engine = GetVehicleEngineHealth(vehicle)
    props.body = GetVehicleBodyHealth(vehicle)
    
    -- Mods
    props.modEngine = GetVehicleMod(vehicle, 11)
    props.modBrakes = GetVehicleMod(vehicle, 12)
    props.modTransmission = GetVehicleMod(vehicle, 13)
    props.modSuspension = GetVehicleMod(vehicle, 15)
    props.modArmor = GetVehicleMod(vehicle, 16)
    props.modTurbo = IsToggleModOn(vehicle, 18)
    
    -- Colors, wheels, etc. omitted for brevity but should be here
    return props
end

-- Open Menu
function OpenGarageMenu()
    if isMenuOpen then return end
    TriggerServerEvent("godz_garage:requestVehicles")
end

RegisterNetEvent("godz_garage:receiveVehicles")
AddEventHandler("godz_garage:receiveVehicles", function(vehicles)
    isMenuOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "open",
        vehicles = vehicles
    })
end)

RegisterNUICallback("close", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("spawn", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    TriggerServerEvent("godz_garage:spawnVehicle", data.plate)
    cb("ok")
end)

RegisterNetEvent("godz_garage:spawnClient")
AddEventHandler("godz_garage:spawnClient", function(model, plate, mods, status)
    local ped = PlayerPedId()
    local hash = (type(model) == "number") and model or GetHashKey(model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Check for spawn point clearance or use specific spawn points
    -- For now, spawn at player pos
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    
    SetVehicleNumberPlateText(vehicle, plate)
    SetPedIntoVehicle(ped, vehicle, -1)
    
    -- Apply Status
    if status.fuel then SetVehicleFuelLevel(vehicle, status.fuel + 0.0) end
    if status.engine then SetVehicleEngineHealth(vehicle, status.engine + 0.0) end
    if status.body then SetVehicleBodyHealth(vehicle, status.body + 0.0) end
    
    -- Apply Mods
    SetVehicleModKit(vehicle, 0)
    if mods then
        if mods.modEngine then SetVehicleMod(vehicle, 11, mods.modEngine, false) end
        if mods.modBrakes then SetVehicleMod(vehicle, 12, mods.modBrakes, false) end
        if mods.modTransmission then SetVehicleMod(vehicle, 13, mods.modTransmission, false) end
        if mods.modSuspension then SetVehicleMod(vehicle, 15, mods.modSuspension, false) end
        if mods.modArmor then SetVehicleMod(vehicle, 16, mods.modArmor, false) end
        if mods.modTurbo ~= nil then ToggleVehicleMod(vehicle, 18, mods.modTurbo) end
    end
    
    SetModelAsNoLongerNeeded(hash)
end)

-- Marker Loop
Citizen.CreateThread(function()
    while true do
        local idle = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        for _, loc in pairs(GarageLocations) do
            local dist = #(coords - vector3(loc.x, loc.y, loc.z))
            if dist < 10.0 then
                idle = 0
                DrawMarker(36, loc.x, loc.y, loc.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 212, 175, 55, 150, 0, 1, 0, 1)
                if dist < 3.0 then
                    if IsPedInAnyVehicle(ped, false) then
                        -- Store Logic
                        -- Draw Text: Press E to Store
                        if IsControlJustPressed(0, 38) then -- E
                            local vehicle = GetVehiclePedIsUsing(ped)
                            local props = GetVehicleProperties(vehicle)
                            TriggerServerEvent("godz_garage:storeVehicle", props)
                            
                            -- Delete Client Side (Immediate Feedback) or wait for server?
                            -- Safest: Server deletes. We just trigger.
                            -- But for responsiveness:
                            TaskLeaveVehicle(ped, vehicle, 0)
                        end
                    else
                        -- Open Logic
                        if IsControlJustPressed(0, 38) then -- E
                            OpenGarageMenu()
                        end
                    end
                end
            end
        end
        Citizen.Wait(idle)
    end
end)
