local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local mdt = Tunnel.getInterface("godz_mdt")

local isVisible = false
local tabletObj = nil

function ToggleMDT()
    mdt.checkPermission({}, function(allowed)
        if allowed then
            isVisible = not isVisible
            if isVisible then
                SetNuiFocus(true, true)
                SendNUIMessage({ action = "open" })
                StartTabletAnimation()
                
                -- Load initial data (Warrants list)
                mdt.getAllWarrants({}, function(warrants)
                    SendNUIMessage({ action = "updateWarrants", warrants = warrants })
                end)
            else
                CloseMDT()
            end
        else
            TriggerEvent("Notify", "negado", "Você não tem permissão.")
        end
    end)
end

function CloseMDT()
    isVisible = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
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
    StopAnimTask(ped, "amb@world_human_seat_wall_tablet@female@base", "base", 8.0)
    if DoesEntityExist(tabletObj) then
        DeleteEntity(tabletObj)
    end
end

RegisterCommand("mdt", function()
    ToggleMDT()
end)

RegisterNUICallback("close", function(data, cb)
    CloseMDT()
    cb("ok")
end)

RegisterNUICallback("search", function(data, cb)
    mdt.searchUser({data.query}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("addWarrant", function(data, cb)
    mdt.createWarrant({data.user_id, data.reason}, function(success)
        if success then
            mdt.getAllWarrants({}, function(warrants)
                SendNUIMessage({ action = "updateWarrants", warrants = warrants })
            end)
        end
        cb(success)
    end)
end)

RegisterNUICallback("deleteWarrant", function(data, cb)
    mdt.deleteWarrant({data.id}, function(success)
        if success then
            mdt.getAllWarrants({}, function(warrants)
                SendNUIMessage({ action = "updateWarrants", warrants = warrants })
            end)
        end
        cb(success)
    end)
end)

RegisterNUICallback("fine", function(data, cb)
    mdt.applyFine({data.user_id, data.amount, data.reason}, function(success)
        cb(success)
    end)
end)
