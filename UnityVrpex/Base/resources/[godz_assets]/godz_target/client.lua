local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local Targets = {}
local GlobalPlayerTargets = {}
local Zones = {}

local isTargeting = false
local hasFocus = false
local currentOptions = {}
local lastEntity = nil

-- CONFIG
local maxDistance = 3.0

-- EXPORTS
exports('AddTargetModel', function(models, options)
    if type(models) ~= "table" then models = {models} end
    for _, model in pairs(models) do
        if type(model) == "string" then model = GetHashKey(model) end
        Targets[model] = options
    end
end)

exports('AddTargetPlayer', function(options)
    for _, opt in pairs(options) do
        table.insert(GlobalPlayerTargets, opt)
    end
end)

exports('AddCircleZone', function(name, coords, radius, options)
    Zones[name] = {
        coords = coords,
        radius = radius,
        options = options
    }
end)

-- THREAD
Citizen.CreateThread(function()
    while true do
        local idle = 250
        
        -- Default Key: Left Alt (19)
        if IsControlPressed(0, 19) then
            idle = 0
            isTargeting = true
            
            local hit, entity, coords = RaycastGamePlayCamera(maxDistance)
            local options = {}
            local active = false

            if not hasFocus then
                -- Check Zones
                local pCoords = GetEntityCoords(PlayerPedId())
                for name, zone in pairs(Zones) do
                    if #(pCoords - zone.coords) <= zone.radius then
                        options = zone.options
                        active = true
                        break
                    end
                end

                -- Check Entities
                if not active and hit and DoesEntityExist(entity) then
                    local model = GetEntityModel(entity)
                    
                    -- Player Check
                    if IsPedAPlayer(entity) then
                        options = GlobalPlayerTargets
                        if #options > 0 then active = true end
                    
                    -- Model Check
                    elseif Targets[model] then
                        options = Targets[model]
                        active = true
                    end
                    
                    lastEntity = entity
                end

                -- Update UI
                SendNUIMessage({
                    type = "eye",
                    display = true,
                    active = active
                })

                -- Open Menu on Click (Right Mouse = 25? No, usually interact is same key release or Click)
                -- Let's use Right Click (Mouse Button 2 -> 25)
                if active and IsControlJustReleased(0, 25) then
                    openMenu(options, entity)
                end
            end
        elseif isTargeting then
            isTargeting = false
            SendNUIMessage({ type = "eye", display = false })
        end

        Citizen.Wait(idle)
    end
end)

function RaycastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, e, c
end

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function openMenu(options, entity)
    hasFocus = true
    currentOptions = options
    SetNuiFocus(true, true)
    
    -- Filter options based on condition if exists
    local validOptions = {}
    for i, opt in ipairs(options) do
        local allowed = true
        if opt.condition then
            allowed = opt.condition(entity)
        end
        
        if allowed then
            -- We need to pass index to identify back
            opt._index = i
            table.insert(validOptions, opt)
        end
    end
    
    SendNUIMessage({
        type = "open",
        options = validOptions
    })
end

RegisterNUICallback('close', function(data, cb)
    hasFocus = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('select', function(data, cb)
    local index = data.index -- Index in the validOptions list? No, from JS it sends the array index.
    -- Wait, JS sends index of the displayed array.
    -- I need to map it back. 
    -- Simplification: Just trust the index from the filtered list in JS? 
    -- Re-filtering here is safer but complex.
    -- Let's assume the validOptions list matches what JS has.
    
    -- Re-construct validOptions to find the selected one
    local validOptions = {}
    for i, opt in ipairs(currentOptions) do
        local allowed = true
        if opt.condition then allowed = opt.condition(lastEntity) end
        if allowed then table.insert(validOptions, opt) end
    end
    
    local selected = validOptions[data.index + 1] -- JS is 0-based
    
    if selected then
        if selected.event then
            TriggerEvent(selected.event, selected, lastEntity)
        elseif selected.serverEvent then
            TriggerServerEvent(selected.serverEvent, selected, lastEntity)
        elseif selected.action then
            selected.action(lastEntity)
        end
    end
    
    hasFocus = false
    SetNuiFocus(false, false)
    cb('ok')
end)
