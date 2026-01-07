local activeEvent = nil
local eventEntities = {}

--[ UTILS ]-------------------------------------------------------------------------------------------------------

local function cleanupEntities()
    for _, entity in ipairs(eventEntities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
    eventEntities = {}
end

local function cleanupEvent()
    if activeEvent and activeEvent.blip then
        RemoveBlip(activeEvent.blip)
    end
    cleanupEntities()
    activeEvent = nil
end

local function spawnEventEntities(type, coords)
    if type == "PlaneCrash" then
        -- Crashed Plane
        local model = GetHashKey("stt_prop_stunt_plane_l_crush")
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(10) end
        
        local plane = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        PlaceObjectOnGroundProperly(plane)
        FreezeEntityPosition(plane, true)
        table.insert(eventEntities, plane)
        
        -- Loot Box
        local modelBox = GetHashKey("prop_box_wood02a_pu")
        RequestModel(modelBox)
        while not HasModelLoaded(modelBox) do Citizen.Wait(10) end
        
        local box = CreateObject(modelBox, coords.x + 2.0, coords.y + 2.0, coords.z, false, false, false)
        PlaceObjectOnGroundProperly(box)
        table.insert(eventEntities, box)
        
        -- Fire
        StartScriptFire(coords.x, coords.y, coords.z, 25, false)
        
    elseif type == "NPCInvasion" then
        -- Hostile Peds
        local model = GetHashKey("g_m_y_ballas_01")
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(10) end
        
        for i = 1, 5 do
            local ped = CreatePed(4, model, coords.x + math.random(-10,10), coords.y + math.random(-10,10), coords.z, 0.0, false, true)
            TaskCombatPed(ped, PlayerPedId(), 0, 16)
            SetPedArmour(ped, 100)
            SetPedAccuracy(ped, 60)
            GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 250, false, true)
            table.insert(eventEntities, ped)
        end
    end
end

--[ EVENTS ]------------------------------------------------------------------------------------------------------

RegisterNetEvent("godz_events:startPlaneCrash")
AddEventHandler("godz_events:startPlaneCrash", function(coords)
    startEvent("PlaneCrash", coords, 463, 1, "Queda de Avião")
end)

RegisterNetEvent("godz_events:startInvasion")
AddEventHandler("godz_events:startInvasion", function(coords)
    startEvent("NPCInvasion", coords, 84, 1, "Invasão Hostil")
end)

RegisterNetEvent("godz_events:playSound")
AddEventHandler("godz_events:playSound", function(soundName)
    if soundName == "event_start" then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
end)

--[ LOGIC ]-------------------------------------------------------------------------------------------------------

function startEvent(type, coords, blipSprite, blipColor, blipName)
    cleanupEvent()
    
    activeEvent = { type = type, coords = coords }
    
    -- Blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipSprite)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, blipColor)
    SetBlipFlashes(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipName)
    EndTextCommandSetBlipName(blip)
    
    activeEvent.blip = blip
    
    -- Monitor Thread
    Citizen.CreateThread(function()
        local spawned = false
        while activeEvent and activeEvent.type == type do
            local ply = PlayerPedId()
            local dist = #(GetEntityCoords(ply) - vector3(coords.x, coords.y, coords.z))
            
            if dist < 150.0 and not spawned then
                spawnEventEntities(type, coords)
                spawned = true
            elseif dist > 180.0 and spawned then
                cleanupEntities()
                spawned = false
            end
            Citizen.Wait(2000)
        end
        cleanupEntities()
    end)
    
    -- Auto cleanup after 30 mins
    Citizen.SetTimeout(30 * 60 * 1000, function()
        if activeEvent and activeEvent.type == type then
            cleanupEvent()
        end
    end)
end
