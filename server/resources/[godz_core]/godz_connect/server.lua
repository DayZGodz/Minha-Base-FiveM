local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

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
        SetTimeout(1500, function()
            TriggerClientEvent("godz_connect:setCreatorMode", source, true, "Senhor")
        end)
    else
        SetTimeout(1500, function()
            TriggerClientEvent("godz_connect:setCreatorMode", source, false, playerName)
        end)
    end
end)
