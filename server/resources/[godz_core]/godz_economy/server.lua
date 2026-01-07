local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

-- Função para enviar dados para a IA
function SendEconomyToAI()
    local data = {
        salaries = Config.Economy.Salaries,
        drugs = Config.Economy.Drugs,
        food = Config.Economy.FoodAndDrink,
        vehicles = Config.Economy.Vehicles
    }
    
    PerformHttpRequest("http://127.0.0.1:5000/ai_economy_simulation", function(err, text, headers) 
        if err == 0 or err == 200 then
            print("^2[GODZ ECONOMY] ^7Dados enviados para a IA com sucesso.")
        else
            print("^1[GODZ ECONOMY] ^7Erro ao conectar com a IA: " .. tostring(err))
        end
    end, "POST", json.encode(data), { ["Content-Type"] = "application/json" })
end

-- Enviar ao iniciar o recurso
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Aguarda 5 segundos para garantir que a IA subiu
    SendEconomyToAI()
end)

-- Comando para forçar envio
RegisterCommand("updateeconomy", function(source, args, rawCommand)
    if source == 0 then
        SendEconomyToAI()
    else
        local user_id = vRP.getUserId(source)
        if vRP.hasPermission(user_id, "admin.permissao") then
            SendEconomyToAI()
            TriggerClientEvent("Notify", source, "sucesso", "Dados de economia enviados para a IA.")
        end
    end
end)
