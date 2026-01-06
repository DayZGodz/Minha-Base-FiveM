local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
src = Tunnel.getInterface("godz_ems")

local isTabletOpen = false
local stretcherObject = nil
local isPushing = false

-- Animation Dicts
local animDicts = {
    push = "anim@heists@box_carry@",
    dead = "dead"
}

Citizen.CreateThread(function()
    for _, dict in pairs(animDicts) do
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Citizen.Wait(10) end
    end
end)

-- Tablet Functions
function ToggleTablet()
    if isTabletOpen then
        CloseTablet()
    else
        OpenTablet()
    end
end

function OpenTablet()
    src.checkPermission({}, function(hasPermission)
        if hasPermission then
            isTabletOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({ type = "open" })
            StartTabletAnimation()
        else
            TriggerEvent("godz_notify:notify", "erro", "Acesso Negado", "Apenas paramédicos podem acessar.")
        end
    end)
end

function CloseTablet()
    isTabletOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "close" })
    StopTabletAnimation()
end

function StartTabletAnimation()
    local ped = PlayerPedId()
    RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")
    while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do Citizen.Wait(10) end
    tabletObj = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(tabletObj, ped, GetPedBoneIndex(ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(ped, "amb@world_human_seat_wall_tablet@female@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
end

function StopTabletAnimation()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if tabletObj then
        DeleteEntity(tabletObj)
        tabletObj = nil
    end
end

RegisterNUICallback("close", function(data, cb)
    CloseTablet()
    cb("ok")
end)

RegisterNUICallback("searchPatient", function(data, cb)
    src.searchPatient({data.id}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("finishTreatment", function(data, cb)
    src.finishTreatment({data.id}, function(success)
        cb(success)
    end)
end)

RegisterCommand("ems", function()
    ToggleTablet()
end)

-- Stretcher System
RegisterNetEvent("godz_ems:toggleStretcher")
AddEventHandler("godz_ems:toggleStretcher", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnCoords = coords + forward * 2.0
    
    if stretcherObject then
        DeleteEntity(stretcherObject)
        stretcherObject = nil
        TriggerEvent("godz_notify:notify", "aviso", "Maca", "Maca recolhida.")
    else
        local model = GetHashKey("prop_gascyl_01a") -- Fallback
        local stretcherModel = GetHashKey("prop_stretcher_01")
        if IsModelInCdimage(stretcherModel) then model = stretcherModel end
        
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(10) end
        
        stretcherObject = CreateObject(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
        PlaceObjectOnGroundProperly(stretcherObject)
        TriggerEvent("godz_notify:notify", "sucesso", "Maca", "Maca retirada da ambulância.")
    end
end)

-- Target Integration
Citizen.CreateThread(function()
    if exports["godz_target"] then
        -- Reception Zone
        exports["godz_target"]:AddTargetCircle("hospital_reception", vector3(307.0, -595.0, 43.0), 1.5, {
            options = {
                {
                    event = "godz_ems:reception", -- Event to be implemented or linked to notify
                    icon = "fas fa-clipboard-list",
                    label = "Atendimento"
                }
            }
        })

        -- Stretcher Model
        exports["godz_target"]:AddTargetModel({"prop_stretcher_01", "prop_gascyl_01a"}, {
            {
                event = "godz_ems:useStretcher",
                icon = "fas fa-procédure",
                label = "Deitar/Levantar"
            },
            {
                event = "godz_ems:pushStretcher",
                icon = "fas fa-hands",
                label = "Empurrar/Soltar"
            }
        })
    end
end)

RegisterNetEvent("godz_ems:useStretcher")
AddEventHandler("godz_ems:useStretcher", function(entity)
    -- Logic to attach player to stretcher
    local ped = PlayerPedId()
    if IsEntityAttachedToEntity(ped, entity) then
        DetachEntity(ped, true, true)
        ClearPedTasks(ped)
    else
        AttachEntityToEntity(ped, entity, 0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        RequestAnimDict("anim@gangops@morgue@table@")
        while not HasAnimDictLoaded("anim@gangops@morgue@table@") do Citizen.Wait(10) end
        TaskPlayAnim(ped, "anim@gangops@morgue@table@", "body_search", 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end)

RegisterNetEvent("godz_ems:pushStretcher")
AddEventHandler("godz_ems:pushStretcher", function(entity)
    -- Logic to attach stretcher to player (pushing)
    local ped = PlayerPedId()
    if isPushing then
        DetachEntity(entity, true, true)
        isPushing = false
    else
        AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, 17916), 0.0, 1.5, -1.0, 0.0, 0.0, 90.0, false, false, false, false, 2, true)
        isPushing = true
    end
end)

RegisterCommand("pushmaca", function()
    local ped = PlayerPedId()
    if isPushing then
        DetachEntity(stretcherObject, true, true)
        ClearPedTasks(ped)
        isPushing = false
    else
        if stretcherObject and DoesEntityExist(stretcherObject) then
            local pCoords = GetEntityCoords(ped)
            local sCoords = GetEntityCoords(stretcherObject)
            if #(pCoords - sCoords) < 2.5 then
                AttachEntityToEntity(stretcherObject, ped, GetPedBoneIndex(ped, 28422), 0.0, 1.0, -1.0, 0.0, 0.0, 90.0, false, false, true, false, 2, true)
                isPushing = true
                -- Animation if needed, but attach usually enough for pushing look with correct anim
            end
        end
    end
end)

RegisterCommand("putmaca", function()
    -- Put closest player on stretcher
    if stretcherObject and DoesEntityExist(stretcherObject) then
        local ped = PlayerPedId()
        local closestPlayer, distance = vRP.getNearestPlayer(2.0)
        if closestPlayer then
             -- Trigger server event to attach player to stretcher?
             -- For simplicity, assuming client-side control if local, but better to sync via server if possible. 
             -- Since we don't have a robust networked entity system ready, we'll try to find the closest ped and attach.
             -- Note: In vRP, getNearestPlayer returns server ID. We need the ped.
             -- Better approach: GetClosestPed
             local playerPed = GetPlayerPed(GetPlayerFromServerId(closestPlayer))
             if playerPed then
                AttachEntityToEntity(playerPed, stretcherObject, 0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
                -- Play anim on patient
                -- TriggerServerEvent("godz_ems:syncAnim", ...) -- simplified
             end
        end
    end
end)
