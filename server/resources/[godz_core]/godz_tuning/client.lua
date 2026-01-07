local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

local isMenuOpen = false

-- Configuração de Máximos para Normalização (Progress Bars)
local MAX_SPEED = 300.0 -- km/h
local MAX_ACCEL = 1.0 -- g-force approx
local MAX_BRAKE = 2.0 -- g-force approx
local MAX_TRACTION = 3.5 -- g-force approx

function GetVehicleStats(vehicle)
    local stats = {}
    
    -- Valores Brutos
    local speedVal = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel") * 3.6 -- Convert to km/h approx
    local accelVal = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce")
    local brakesVal = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce")
    local tractionVal = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax")

    -- Valores Normalizados (0-100)
    stats.speedVal = speedVal
    stats.speedPercent = math.min((speedVal / MAX_SPEED) * 100, 100)
    
    stats.accelVal = accelVal
    stats.accelPercent = math.min((accelVal / MAX_ACCEL) * 100, 100)
    
    stats.brakesVal = brakesVal
    stats.brakesPercent = math.min((brakesVal / MAX_BRAKE) * 100, 100)
    
    stats.tractionVal = tractionVal
    stats.tractionPercent = math.min((tractionVal / MAX_TRACTION) * 100, 100)
    
    return stats
end

function OpenTuningMenu()
    if isMenuOpen then return end
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if not vehicle then return end

    -- Solicitar Config Atualizada do Server (Preços)
    TriggerServerEvent("godz_tuning:requestConfig")
end

RegisterNetEvent("godz_tuning:receiveConfig")
AddEventHandler("godz_tuning:receiveConfig", function(prices)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if not vehicle then return end
    
    isMenuOpen = true
    SetNuiFocus(true, true)
    
    -- Coletar dados atuais
    local mods = {
        engine = GetVehicleMod(vehicle, 11),
        brakes = GetVehicleMod(vehicle, 12),
        transmission = GetVehicleMod(vehicle, 13),
        suspension = GetVehicleMod(vehicle, 15),
        armor = GetVehicleMod(vehicle, 16),
        turbo = IsToggleModOn(vehicle, 18)
    }

    local stats = GetVehicleStats(vehicle)

    SendNUIMessage({
        action = "open",
        currentMods = mods,
        categories = Config.Categories,
        prices = prices,
        stats = stats
    })
end)

RegisterNUICallback("close", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("finish", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if vehicle then
        -- Coletar mods finais para envio ao servidor (caso precise de log extra ou apenas o trigger)
        -- Na verdade, os mods já foram aplicados um a um. 
        -- O evento de finish é para gerar o laudo IA.
        local mods = {
            engine = GetVehicleMod(vehicle, 11),
            brakes = GetVehicleMod(vehicle, 12),
            transmission = GetVehicleMod(vehicle, 13),
            suspension = GetVehicleMod(vehicle, 15),
            armor = GetVehicleMod(vehicle, 16),
            turbo = IsToggleModOn(vehicle, 18)
        }
        TriggerServerEvent("godz_tuning:finish", mods, GetEntityModel(vehicle), GetVehicleNumberPlateText(vehicle))
    end
    cb("ok")
end)

RegisterNUICallback("playSound", function(data, cb)
    if data.sound == "hover" then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif data.sound == "select" then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
    cb("ok")
end)

RegisterNUICallback("applyMod", function(data, cb)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if not vehicle then return end
    
    local props = GetVehicleProperties(vehicle)
    
    if data.category == "engine" then props.modEngine = tonumber(data.index) end
    if data.category == "transmission" then props.modTransmission = tonumber(data.index) end
    if data.category == "brakes" then props.modBrakes = tonumber(data.index) end
    if data.category == "suspension" then props.modSuspension = tonumber(data.index) end
    if data.category == "armor" then props.modArmor = tonumber(data.index) end
    if data.category == "turbo" then props.modTurbo = data.index end 
    
    TriggerServerEvent("godz_tuning:applyMod", data.category, data.index, data.level, props)
    cb("ok")
end)

RegisterNetEvent("godz_tuning:modApplied")
AddEventHandler("godz_tuning:modApplied", function(modType, modIndex)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if not vehicle then return end
    
    if modType == "engine" then SetVehicleMod(vehicle, 11, tonumber(modIndex), false) end
    if modType == "brakes" then SetVehicleMod(vehicle, 12, tonumber(modIndex), false) end
    if modType == "transmission" then SetVehicleMod(vehicle, 13, tonumber(modIndex), false) end
    if modType == "suspension" then SetVehicleMod(vehicle, 15, tonumber(modIndex), false) end
    if modType == "armor" then SetVehicleMod(vehicle, 16, tonumber(modIndex), false) end
    if modType == "turbo" then ToggleVehicleMod(vehicle, 18, modIndex) end
    
    -- Atualizar stats na NUI
    local stats = GetVehicleStats(vehicle)
    SendNUIMessage({
        action = "updateStats",
        stats = stats
    })
end)

-- Helper para pegar props (simplificado)
function GetVehicleProperties(vehicle)
    local props = {}
    props.plate = GetVehicleNumberPlateText(vehicle)
    props.model = GetEntityModel(vehicle)
    props.modEngine = GetVehicleMod(vehicle, 11)
    props.modBrakes = GetVehicleMod(vehicle, 12)
    props.modTransmission = GetVehicleMod(vehicle, 13)
    props.modSuspension = GetVehicleMod(vehicle, 15)
    props.modArmor = GetVehicleMod(vehicle, 16)
    props.modTurbo = IsToggleModOn(vehicle, 18)
    return props
end

RegisterNetEvent("godz_tuning:applyModsParams")
AddEventHandler("godz_tuning:applyModsParams", function(vehNetId, mods)
    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
    if DoesEntityExist(vehicle) then
        SetVehicleModKit(vehicle, 0)
        if mods.modEngine then SetVehicleMod(vehicle, 11, mods.modEngine, false) end
        if mods.modBrakes then SetVehicleMod(vehicle, 12, mods.modBrakes, false) end
        if mods.modTransmission then SetVehicleMod(vehicle, 13, mods.modTransmission, false) end
        if mods.modSuspension then SetVehicleMod(vehicle, 15, mods.modSuspension, false) end
        if mods.modArmor then SetVehicleMod(vehicle, 16, mods.modArmor, false) end
        if mods.modTurbo ~= nil then ToggleVehicleMod(vehicle, 18, mods.modTurbo) end
    end
end)

-- Marker Loop
Citizen.CreateThread(function()
    while true do
        local idle = 1000
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local coords = GetEntityCoords(ped)
            for _, loc in pairs(Config.TuningLocations) do
                local dist = #(coords - vector3(loc.x, loc.y, loc.z))
                if dist < 10.0 then
                    idle = 0
                    DrawMarker(27, loc.x, loc.y, loc.z - 0.95, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 1.0, 0, 153, 255, 100, 0, 0, 0, 1)
                    if dist < 3.0 then
                        if IsControlJustPressed(0, 38) then -- E
                            OpenTuningMenu()
                        end
                    end
                end
            end
        end
        Citizen.Wait(idle)
    end
end)
