local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

RegisterServerEvent("godz_connect:checkCreator")
AddEventHandler("godz_connect:checkCreator", function()
    local source = source
    local user_id = vRP.getUserId(source)
    
    if user_id == 1 then
        TriggerClientEvent("godz_connect:setCreatorMode", source, true)
    else
        TriggerClientEvent("godz_connect:setCreatorMode", source, false)
    end
end)