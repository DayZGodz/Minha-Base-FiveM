local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","godz_population")

local activeNPCs = {}

RegisterNetEvent("godz:requestNPC")
AddEventHandler("godz:requestNPC", function(index)
    local src = source
    local locData = Config.Locations[index]
    
    if not locData then return end

    if activeNPCs[index] then
        TriggerClientEvent("godz:receiveNPCData", src, index, activeNPCs[index])
        return
    end

    print("^3[GODZ POPULATION] Generating NPC for " .. locData.name .. "...^7")

    PerformHttpRequest("http://127.0.0.1:5000/generate_npc", function(errorCode, resultData, resultHeaders)
        if errorCode == 200 then
            local data = json.decode(resultData)
            activeNPCs[index] = data
            TriggerClientEvent("godz:receiveNPCData", src, index, data)
            print("^2[GODZ POPULATION] NPC Generated: " .. data.name .. "^7")
        else
            print("^1[GODZ POPULATION] Error generating NPC: " .. tostring(errorCode) .. "^7")
        end
    end, "POST", json.encode({
        location = locData.name,
        job = locData.job
    }), { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer godz_secret_key_123" })
end)
