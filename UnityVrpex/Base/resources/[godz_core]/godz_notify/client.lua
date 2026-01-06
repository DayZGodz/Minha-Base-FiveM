local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

RegisterNetEvent("Notify")
AddEventHandler("Notify",function(Css,Message,Timer,Title)
    SendNUIMessage({ action = "notify", type = Css, message = Message, time = Timer or 5000, title = Title or "NOTIFICAÇÃO" })
end)

RegisterNetEvent("pNotify")
AddEventHandler("pNotify",function(Message)
    SendNUIMessage({ action = "notify", type = "aviso", message = Message, time = 5000, title = "AVISO" })
end)

RegisterNetEvent("vRP:Notify")
AddEventHandler("vRP:Notify",function(Message)
    SendNUIMessage({ action = "notify", type = "aviso", message = Message, time = 5000, title = "AVISO" })
end)
