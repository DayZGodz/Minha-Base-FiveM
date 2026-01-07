local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

Config = {}
Config.DynamicPrices = {}

-- Loop de Monitoramento (30 minutos)
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Aguarda inicialização
    CheckEconomy() -- Checagem inicial
    
    while true do
        Citizen.Wait(30 * 60 * 1000) -- 30 minutos
        CheckEconomy()
    end
end)

function CheckEconomy()
    exports.oxmysql:execute("SELECT SUM(wallet + bank) as total_money, COUNT(*) as total_users FROM godz_user_moneys", {}, function(result)
        if result and result[1] then
            local total_circulating = result[1].total_money or 0
            local total_users = result[1].total_users or 1
            local average_balance = 0
            
            if total_users > 0 then
                average_balance = total_circulating / total_users
            end
            
            print("[GODZ ECONOMY] Analisando economia... Total: " .. total_circulating .. " | Média: " .. average_balance)

            -- Consultar IA para 'Weapons' (Armas) como proxy de inflação
            ConsultAI("Weapons", total_circulating, average_balance)
        end
    end)
end

function ConsultAI(item, total, average)
    -- Chama o módulo de IA via Proxy vRP
    vRP.askGodzAI("/ai_economy_simulation", {
        item = item,
        total_circulating = total,
        average_balance = average
    }, function(code, res, headers)
        if code == 200 then
            local body = json.decode(res)
            if body and body.multiplier then
                local multiplier = body.multiplier
                UpdatePrices(item, multiplier)
            end
        else
            print("[GODZ ECONOMY] Erro ao contatar IA: " .. tostring(code))
        end
    end)
end

function UpdatePrices(category, multiplier)
    Config.DynamicPrices[category] = multiplier
    
    print("[GODZ ECONOMY] Multiplicador para " .. category .. ": " .. multiplier)

    if multiplier >= 1.2 then
         TriggerClientEvent("chatMessage", -1, "^1[ECONOMIA]^7 O Banco Central informa: Alta inflação detectada! O preço das ^1armas^7 subiu devido à alta circulação de moedas.")
    elseif multiplier <= 0.8 then
         TriggerClientEvent("chatMessage", -1, "^2[ECONOMIA]^7 O Banco Central informa: Deflação detectada! O preço das ^2armas^7 caiu para estimular o mercado.")
    end
end

-- Export para pegar o multiplicador em outros scripts (ex: lojas)
exports('GetPriceMultiplier', function(category)
    return Config.DynamicPrices[category] or 1.0
end)
