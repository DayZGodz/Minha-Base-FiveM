local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        local users = vRP.getUsers()
        for user_id,source in pairs(users) do
            local hunger = vRP.getHunger(user_id)
            local thirst = vRP.getThirst(user_id)
            TriggerClientEvent("godz:updateStatus",source,hunger,thirst)
        end
    end
end)
