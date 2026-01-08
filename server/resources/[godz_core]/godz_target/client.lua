local Models = {}
local Entities = {}
local Zones = {}

local isTargeting = false
local hasFocus = false
local targetActive = false
local success = false

-- Core Raycast Function
local function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )
    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )
    return direction
end

local function RaycastCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = vector3(
        cameraCoord.x + direction.x * distance,
        cameraCoord.y + direction.y * distance,
        cameraCoord.z + direction.z * distance
    )

    local shapeTest = StartShapeTestRay(
        cameraCoord.x, cameraCoord.y, cameraCoord.z,
        destination.x, destination.y, destination.z,
        -1, PlayerPedId(), 0
    )
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
    return hit, entityHit, endCoords
end

-- Check Targets
local function CheckEntity(entity, coords)
    local options = {}

    -- Check Zones
    for id, zone in pairs(Zones) do
        local dist = #(coords - zone.center)
        if dist <= zone.radius then
            for _, opt in ipairs(zone.options) do
                table.insert(options, opt)
            end
        end
    end

    if entity and entity > 0 then
        local model = GetEntityModel(entity)
        
        -- Check Models
        for _, data in pairs(Models) do
            if data.models[model] then
                for _, opt in ipairs(data.options) do
                    table.insert(options, opt)
                end
            end
        end

        -- Check Config Global Targets
        for key, data in pairs(Config.GlobalTargets) do
            if data.models then
                for _, m in ipairs(data.models) do
                    if GetHashKey(m) == model then
                        for _, opt in ipairs(data.options) do
                            table.insert(options, opt)
                        end
                    end
                end
            elseif key == "all_vehicles" and IsEntityAVehicle(entity) then
                for _, opt in ipairs(data.options) do
                    table.insert(options, opt)
                end
            end
        end
            
            -- Check Players
            if IsPedAPlayer(entity) and Config.GlobalTargets["player"] then
                 for _, opt in ipairs(Config.GlobalTargets["player"].options) do
                    table.insert(options, opt)
                end
            end
            
            -- Check Entities (Direct Reference)
        if Entities[entity] then
            for _, opt in ipairs(Entities[entity].options) do
                table.insert(options, opt)
            end
        end
    end

    return options
end

-- Main Loop (Optimized)
Citizen.CreateThread(function()
    while true do
        local wait = 500
        if IsControlPressed(0, Config.TargetKey) then
            wait = 0
            isTargeting = true
            
            local hit, entity, coords = RaycastCamera(Config.MaxDistance)
            
            -- Always check if we hit something OR if we are in a zone (using coords)
            local options = CheckEntity(entity, coords)
            
            if options and #options > 0 then
                if not targetActive then
                    targetActive = true
                    SendNUIMessage({
                        type = "foundTarget",
                        options = options,
                        entity = entity
                    })
                end
            else
                if targetActive then
                    targetActive = false
                    SendNUIMessage({ type = "lostTarget" })
                end
            end
            
            -- Enable Cursor if clicked
            if IsControlJustPressed(0, 24) and targetActive then -- Left Click
                SetNuiFocus(true, true)
                hasFocus = true
            end
            
            -- Draw Eye Icon via NUI (Handled by JS based on isTargeting state)
            SendNUIMessage({ type = "targeting", state = true })
        else
            if isTargeting then
                isTargeting = false
                targetActive = false
                SendNUIMessage({ type = "targeting", state = false })
                SendNUIMessage({ type = "lostTarget" })
            end
        end
        Citizen.Wait(wait)
    end
end)

-- NUI Callbacks
RegisterNUICallback("select", function(data, cb)
    SetNuiFocus(false, false)
    hasFocus = false
    
    if data.event then
        TriggerEvent(data.event, data.entity)
    elseif data.serverEvent then
        TriggerServerEvent(data.serverEvent, data.entity)
    end
    cb("ok")
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    hasFocus = false
    cb("ok")
end)

-- Exports
function AddTargetModel(models, options)
    if type(models) ~= "table" then models = {models} end
    local hashModels = {}
    for _, m in ipairs(models) do
        if type(m) == "string" then
            hashModels[GetHashKey(m)] = true
        else
            hashModels[m] = true
        end
    end
    table.insert(Models, { models = hashModels, options = options })
end

function AddTargetEntity(entity, options)
    Entities[entity] = { options = options }
end

function AddTargetCircle(name, center, radius, options)
    Zones[name] = { center = center, radius = radius, options = options.options }
end

function RemoveTargetModel(models)
    -- Implementation skipped for brevity
end

function RemoveTargetEntity(entity)
    Entities[entity] = nil
end

function RemoveTargetCircle(name)
    Zones[name] = nil
end

function AddCircleZone(name, center, radius, params, targetoptions)
    -- Wrapper for god_factions compatibility
    -- params: { name, debugPoly, useZ, ... } - mostly ignored by simple target
    -- targetoptions: { options = {}, distance = ... }
    if targetoptions and targetoptions.options then
        AddTargetCircle(name, center, radius, { options = targetoptions.options })
    end
end

function AddGlobalVehicle(options)
    -- Adds options to all vehicles generally or specific classes if we enhanced the system
    -- For now, we will add to a generic 'vehicle' entry if it existed, 
    -- but Config.GlobalTargets keys are models. 
    -- To support "Global Vehicle", we might need to iterate all vehicle keys or add a special check in CheckEntity.
    -- Let's look at CheckEntity: it checks Models, Config.GlobalTargets (by model), and Entities.
    -- It does NOT have a "All Vehicles" check.
    -- We should add one in CheckEntity or add to a new list.
    -- For simplest implementation matching current code:
    -- We'll assume this adds to a list we check in CheckEntity.
    if not Config.GlobalTargets["all_vehicles"] then
        Config.GlobalTargets["all_vehicles"] = { options = {} }
    end
    for _, opt in ipairs(options) do
        table.insert(Config.GlobalTargets["all_vehicles"].options, opt)
    end
end

function AddTargetPlayer(options)
    if not Config.GlobalTargets["player"] then
        Config.GlobalTargets["player"] = { options = {} }
    end
    for _, opt in ipairs(options) do
        table.insert(Config.GlobalTargets["player"].options, opt)
    end
end

-- Exports for External Use
exports("AddTargetModel", AddTargetModel)
exports("AddTargetEntity", AddTargetEntity)
exports("AddTargetCircle", AddTargetCircle)
exports("AddCircleZone", AddCircleZone)
exports("AddGlobalVehicle", AddGlobalVehicle)
exports("AddTargetPlayer", AddTargetPlayer)

