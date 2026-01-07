local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

RegisterServerEvent('godz_missions:requestMission')
AddEventHandler('godz_missions:requestMission', function()
    local source = source
    local user_id = vRP.getUserId(source)
    
    -- Aqui poderíamos pegar o nível real do jogador no godz_jobs
    local player_level = 1 
    -- Exemplo: local player_level = vRP.getExp(user_id, "delivery") or 1
    
    PerformHttpRequest("http://127.0.0.1:5000/generate_mission", function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            if data and data.mission then
                TriggerClientEvent('godz_missions:receiveMission', source, data.mission)
            else
                TriggerClientEvent("Notify", source, "negado", "A IA não encontrou missões disponíveis.")
            end
        else
            TriggerClientEvent("Notify", source, "negado", "Erro de conexão com GODZ AI.")
        end
    end, "POST", json.encode({ level = player_level }), { ["Content-Type"] = "application/json" })
end)

RegisterServerEvent('godz_missions:completeMission')
AddEventHandler('godz_missions:completeMission', function(missionData)
    local source = source
    local user_id = vRP.getUserId(source)
    
    if missionData and missionData.reward then
        vRP.giveBankMoney(user_id, missionData.reward)
        TriggerClientEvent("Notify", source, "sucesso", "Missão concluída! Recebeu $"..missionData.reward)
        
        -- Chance de item raro
        if missionData.is_rare then
            -- vRP.giveInventoryItem(user_id, "blueprint_arma", 1, true)
            TriggerClientEvent("Notify", source, "importante", "Você encontrou um item raro!")
        end
    end
end)
