local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
server = Tunnel.getInterface("godz_housing")

local currentHome = nil
local spawnedShell = nil
local furnitureObjects = {}
local inEditor = false
local previewObject = nil

-- Cache
local Homes = {}

Citizen.CreateThread(function()
    server.getAllHomes({}, function(homes)
        Homes = homes
        UpdateTargets()
    end)
end)

RegisterNetEvent("godz_housing:updateHome")
AddEventHandler("godz_housing:updateHome", function(id, data)
    Homes[id] = data
    -- Refresh target if nearby? 
    -- Ideally we just check Homes array in real-time or update specific entry
end)

function UpdateTargets()
    if not exports["godz_target"] then return end
    
    for id, home in pairs(Homes) do
        local pos = vector3(home.coords.x, home.coords.y, home.coords.z)
        
        exports["godz_target"]:AddTargetCircle("home_"..id, pos, 1.5, {
            options = {
                {
                    event = "godz_housing:enter",
                    icon = "fas fa-door-open",
                    label = "Entrar na Propriedade",
                    homeId = id
                },
                {
                    event = "godz_housing:buy",
                    icon = "fas fa-dollar-sign",
                    label = "Comprar ($"..home.price..")",
                    homeId = id,
                    canInteract = function() return home.owner_id == nil end
                },
                {
                    event = "godz_housing:menu",
                    icon = "fas fa-cog",
                    label = "Gerenciar Casa",
                    homeId = id,
                    canInteract = function() 
                        -- Check if owner client side or let server handle
                        return true 
                    end
                }
            }
        })
    end
end

RegisterNetEvent("godz_housing:enterResult")
AddEventHandler("godz_housing:enterResult", function(success, shellModel, spawnCoords, furniture)
    if success then
        DoScreenFadeOut(500)
        Citizen.Wait(500)
        
        local ped = PlayerPedId()
        SetEntityCoords(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z)
        
        -- Spawn Shell
        SpawnShell(shellModel, spawnCoords)
        
        -- Load Furniture
        SpawnFurniture(furniture)
        
        Citizen.Wait(500)
        DoScreenFadeIn(500)
    else
        TriggerEvent("godz_notify:notify", "negado", "Trancado", shellModel) -- shellModel is error msg here
    end
end)

RegisterNetEvent("godz_housing:enter")
AddEventHandler("godz_housing:enter", function(data)
    local id = data.homeId or data
    currentHome = id
    TriggerServerEvent("godz_housing:reqEnter", id)
end)

RegisterNetEvent("godz_housing:buy")
AddEventHandler("godz_housing:buy", function(data)
    local id = data.homeId
    TriggerServerEvent("godz_housing:reqBuy", id)
end)

function SpawnShell(model, coords)
    if spawnedShell then DeleteEntity(spawnedShell) end
    
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    
    spawnedShell = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(spawnedShell, true)
    
    -- Setup Exit Target inside shell
    -- Usually shells have a specific door offset. For v16 shells it varies.
    -- We'll put the exit at the spawn point for simplicity or try to find door.
    -- Assuming spawn point is near door.
    exports["godz_target"]:AddTargetCircle("home_exit", coords, 1.5, {
        options = {
            {
                action = function() ExitHome() end,
                icon = "fas fa-door-open",
                label = "Sair da Casa"
            },
            {
                action = function() OpenFurnitureMenu() end,
                icon = "fas fa-couch",
                label = "Decorar"
            }
        }
    })
end

function ExitHome()
    if not currentHome then return end
    local home = Homes[currentHome]
    
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    
    -- Cleanup
    if spawnedShell then DeleteEntity(spawnedShell) spawnedShell = nil end
    for _, obj in pairs(furnitureObjects) do DeleteEntity(obj) end
    furnitureObjects = {}
    
    server.exitHome({currentHome}, function()
        local ped = PlayerPedId()
        SetEntityCoords(ped, home.coords.x, home.coords.y, home.coords.z)
        currentHome = nil
        Citizen.Wait(500)
        DoScreenFadeIn(500)
    end)
end

-- Raycast for placement (Tick)
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if inEditor and previewObject then
            wait = 0
            -- Raycast from camera
            local hit, coords = RaycastFromCamera()
            if hit then
                SetEntityCoords(previewObject, coords.x, coords.y, coords.z)
                
                -- Rotation Controls
                if IsControlPressed(0, 174) then -- Left
                    local rot = GetEntityRotation(previewObject, 2)
                    SetEntityRotation(previewObject, rot.x, rot.y, rot.z + 1.0, 2, true)
                end
                if IsControlPressed(0, 175) then -- Right
                    local rot = GetEntityRotation(previewObject, 2)
                    SetEntityRotation(previewObject, rot.x, rot.y, rot.z - 1.0, 2, true)
                end
                
                -- Place
                if IsControlJustPressed(0, 24) then -- Left Click
                    PlaceCurrentPreview()
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function RaycastFromCamera()
    local pad = PlayerPedId()
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local fwd = RotationToDirection(camRot)
    local dest = camPos + (fwd * 10.0)
    
    local handle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, pad, 0)
    local _, hit, endCoords, _, _ = GetShapeTestResult(handle)
    return hit, endCoords
end

function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

function PlaceCurrentPreview()
    if not previewObject then return end
    
    local modelHash = GetEntityModel(previewObject)
    local coords = GetEntityCoords(previewObject)
    local rot = GetEntityRotation(previewObject, 2)
    
    -- Find model name from hash (reverse Config)
    local modelName = "unknown"
    for _, item in pairs(Config.Furniture) do
        if GetHashKey(item.model) == modelHash then
            modelName = item.model
            break
        end
    end
    
    DeleteEntity(previewObject)
    previewObject = nil
    
    -- Create Real Object
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, true)
    FreezeEntityPosition(obj, true)
    table.insert(furnitureObjects, { entity = obj, model = modelName }) -- Store wrapper
    
    -- Re-open NUI or stay in edit mode?
    SetNuiFocus(true, true) -- Give back cursor
end

-- Decoration Mode
function OpenFurnitureMenu()
    inEditor = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "open",
        items = Config.Furniture
    })
end

RegisterNUICallback("close", function(data, cb)
    inEditor = false
    SetNuiFocus(false, false)
    if previewObject then DeleteEntity(previewObject) previewObject = nil end
    cb("ok")
end)

RegisterNUICallback("spawnPreview", function(data, cb)
    if previewObject then DeleteEntity(previewObject) end
    
    local hash = GetHashKey(data.model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 2.0
    
    previewObject = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
    SetEntityAlpha(previewObject, 150, false)
    SetEntityCollision(previewObject, false, false)
    cb("ok")
end)

RegisterNUICallback("saveFurniture", function(data, cb)
    -- Collect all placed furniture logic would go here if we were doing full editor
    -- But for simplicity, let's assume we place ONE item at a time or we are saving the *current state*.
    -- Actually, the best way for a housing script is:
    -- 1. List existing furniture.
    -- 2. Add new ones.
    -- 3. Save ALL current furnitureObjects positions to DB.
    
    -- Here we implement a "Save Layout" button that iterates furnitureObjects
    local layout = {}
    for _, obj in pairs(furnitureObjects) do
        local model = GetEntityModel(obj)
        -- We need the model name, but GetEntityModel returns hash. 
        -- We might need to store metadata on the object or reverse lookup (slow).
        -- Better: store the model name in a lua table linked to the entity handle.
        -- For this MVP, let's skip complex reverse lookup and assume we tracked it.
    end
    -- Revised: The NUI should manage the "placed" list or we send it to NUI.
    
    -- Let's keep it simple: "Add Item" -> Places it -> Saves it immediately?
    -- No, "Edit Mode" usually allows moving things.
    
    -- MVP Implementation:
    -- User selects item -> Preview follows cursor -> Click to place.
    -- On click, it becomes a real object and is added to `furnitureObjects`.
    -- Then "Save" sends all `furnitureObjects` data to server.
    
    cb("ok")
end)

-- Raycast for placement (Tick)
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if inEditor and previewObject then
            wait = 0
            -- Raycast from camera
            local hit, coords = RaycastFromCamera()
            if hit then
                SetEntityCoords(previewObject, coords.x, coords.y, coords.z)
                
                -- Rotation Controls
                if IsControlPressed(0, 174) then -- Left
                    local rot = GetEntityRotation(previewObject, 2)
                    SetEntityRotation(previewObject, rot.x, rot.y, rot.z + 1.0, 2, true)
                end
                if IsControlPressed(0, 175) then -- Right
                    local rot = GetEntityRotation(previewObject, 2)
                    SetEntityRotation(previewObject, rot.x, rot.y, rot.z - 1.0, 2, true)
                end
                
                -- Place
                if IsControlJustPressed(0, 24) then -- Left Click
                    PlaceCurrentPreview()
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function RaycastFromCamera()
    local pad = PlayerPedId()
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local fwd = RotationToDirection(camRot)
    local dest = camPos + (fwd * 10.0)
    
    local handle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, pad, 0)
    local _, hit, endCoords, _, _ = GetShapeTestResult(handle)
    return hit, endCoords
end

function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

function PlaceCurrentPreview()
    if not previewObject then return end
    
    local modelHash = GetEntityModel(previewObject)
    local coords = GetEntityCoords(previewObject)
    local rot = GetEntityRotation(previewObject, 2)
    
    -- Find model name from hash (reverse Config)
    local modelName = "unknown"
    for _, item in pairs(Config.Furniture) do
        if GetHashKey(item.model) == modelHash then
            modelName = item.model
            break
        end
    end
    
    DeleteEntity(previewObject)
    previewObject = nil
    
    -- Create Real Object
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, true)
    FreezeEntityPosition(obj, true)
    table.insert(furnitureObjects, { entity = obj, model = modelName }) -- Store wrapper
    
    -- Re-open NUI or stay in edit mode?
    SetNuiFocus(true, true) -- Give back cursor
end

-- Override Save for MVP
RegisterNUICallback("save", function(data, cb)
    local saveData = {}
    for _, wrapper in pairs(furnitureObjects) do
        if type(wrapper) == "table" and wrapper.entity then
            local obj = wrapper.entity
            local coords = GetEntityCoords(obj)
            local rot = GetEntityRotation(obj, 2)
            table.insert(saveData, {
                model = wrapper.model,
                coords = {x = coords.x, y = coords.y, z = coords.z},
                rotation = {x = rot.x, y = rot.y, z = rot.z}
            })
        elseif type(wrapper) == "number" then -- Loaded from server (raw entity handle)
            -- We need to know the model name. 
            -- Issue: We didn't store model name when loading from server in `SpawnFurniture`.
            -- Fix: Update `SpawnFurniture` to store wrapper.
        end
    end
    
    -- Since we need to fix SpawnFurniture to support saving mixed items (old + new),
    -- Let's update `SpawnFurniture` logic in next pass or assuming wrapper structure.
    
    server.saveFurniture({currentHome, saveData}, function(success)
        if success then 
            TriggerEvent("godz_notify:notify", "sucesso", "Salvo", "Decoração salva com sucesso!")
        end
        cb("ok")
    end)
end)

-- Fix SpawnFurniture to match wrapper
function SpawnFurniture(list)
    -- Clear old
    for _, wrapper in pairs(furnitureObjects) do
        if type(wrapper) == "table" then DeleteEntity(wrapper.entity)
        else DeleteEntity(wrapper) end
    end
    furnitureObjects = {}
    
    for _, item in pairs(list) do
        local hash = GetHashKey(item.model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Citizen.Wait(10) end
        
        local obj = CreateObject(hash, item.coords.x, item.coords.y, item.coords.z, false, false, false)
        SetEntityRotation(obj, item.rotation.x, item.rotation.y, item.rotation.z, 2, true)
        FreezeEntityPosition(obj, true)
        table.insert(furnitureObjects, { entity = obj, model = item.model })
    end
end
