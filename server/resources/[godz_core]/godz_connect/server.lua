local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

RegisterServerEvent("godz_connect:checkCreator")
AddEventHandler("godz_connect:checkCreator", function()
    local source = source
    local user_id = vRP.getUserId(source)
    local playerName = GetPlayerName(source)
    
    -- Tenta buscar a identidade real (Nome RP)
    local identity = vRP.getUserIdentity(user_id)
    if identity and identity.firstname then
        playerName = identity.firstname
    end

    if user_id == 1 then
        TriggerClientEvent("godz_connect:setCreatorMode", source, true, "Senhor")
    else
        TriggerClientEvent("godz_connect:setCreatorMode", source, false, playerName)
    end
end)