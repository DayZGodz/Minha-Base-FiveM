local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local Config = module("godz_factions", "config")
local menuOpen = false

RegisterCommand(Config.Command, function()
    TriggerServerEvent("godz_factions:requestData")
end)

RegisterNetEvent("godz_factions:openMenu")
AddEventHandler("godz_factions:openMenu", function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = data
    })
    menuOpen = true
end)

RegisterNetEvent("godz_factions:updateMembers")
AddEventHandler("godz_factions:updateMembers", function(members)
    SendNUIMessage({
        action = "updateMembers",
        members = members
    })
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    menuOpen = false
    cb("ok")
end)

RegisterNUICallback("hire", function(data, cb)
    TriggerServerEvent("godz_factions:hireMember", data.target_id)
    cb("ok")
end)

RegisterNUICallback("fire", function(data, cb)
    TriggerServerEvent("godz_factions:fireMember", data.target_id)
    cb("ok")
end)
