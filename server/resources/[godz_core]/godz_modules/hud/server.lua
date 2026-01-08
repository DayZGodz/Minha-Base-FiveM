local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local lastAlerts = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        local users = vRP.getUsers()
        for user_id,source in pairs(users) do
            local hunger = vRP.getHunger(user_id)
            local thirst = vRP.getThirst(user_id)
            TriggerClientEvent("godz:updateStatus",source,hunger,thirst)

            local now = GetGameTimer()
            local la = lastAlerts[user_id] or {h=0,t=0}

            if hunger >= 85 and (now - la.h) > 60000 then
                lastAlerts[user_id] = {h=now, t=la.t}
                TriggerClientEvent("godz_interface:Notify",source,"aviso","NEXUS","Atenção: Seus níveis de nutrição estão críticos. Procure suprimentos.",8000)
            end

            if thirst >= 85 and (now - la.t) > 60000 then
                lastAlerts[user_id] = {h=la.h, t=now}
                TriggerClientEvent("godz_interface:Notify",source,"aviso","NEXUS","Atenção: Seus níveis de hidratação estão abaixo do recomendado. Procure um posto de suprimentos.",8000)
            end
        end
    end
end)
