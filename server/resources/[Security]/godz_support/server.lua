local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

local MasterConfig = { webhooks = {} }

Citizen.CreateThread(function()
    Wait(2000)
    PerformHttpRequest("http://127.0.0.1:5000/config", function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            if data then
                MasterConfig = data
                -- Atualiza webhook se disponível
                if MasterConfig.webhooks and MasterConfig.webhooks.support and MasterConfig.webhooks.support ~= "" then
                    Config.Webhooks.Tickets = MasterConfig.webhooks.support
                    print("^2[GODZ SUPPORT] ^7Webhook sincronizado com IA: " .. MasterConfig.webhooks.support)
                end
            end
        end
    end)
end)

local temp_tickets = {}

-- Inicialização do Banco de Dados
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS godz_support_tickets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            category VARCHAR(50),
            description TEXT,
            status VARCHAR(20) DEFAULT 'open',
            staff_id INT DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            closed_at TIMESTAMP NULL
        )
    ]])
    print("^2[GODZ SUPPORT] ^7Sistema de Tickets e SQL inicializados.")
end)

RegisterServerEvent('godz_support:openTicket')
AddEventHandler('godz_support:openTicket', function(data)
    local source = source
    local user_id = vRP.getUserId(source)
    
    local categoryInfo = nil
    for _, cat in ipairs(Config.Categories) do
        if cat.id == data.category then categoryInfo = cat break end
    end
    
    if not categoryInfo then return end

    -- Salva temporariamente para contexto (Escalonamento)
    temp_tickets[source] = {
        user_id = user_id,
        category = data.category,
        description = data.description,
        label = categoryInfo.label
    }

    if categoryInfo.ai_assist then
        -- Tenta resolver com IA primeiro
        PerformHttpRequest("http://127.0.0.1:5000/ai_assist", function(err, text, headers)
            local answered = false
            if err == 200 then
                local res = json.decode(text)
                if res and res.response and res.response ~= "" then
                    TriggerClientEvent('godz_support:showAIResponse', source, res.response)
                    answered = true
                end
            end
            
            if not answered then
                DispatchToDiscord(source, temp_tickets[source])
            end
        end, "POST", json.encode({
            question = data.description,
            user_id = user_id
        }), { ["Content-Type"] = "application/json" })
    else
        DispatchToDiscord(source, temp_tickets[source])
    end
end)

RegisterServerEvent('godz_support:escalateTicket')
AddEventHandler('godz_support:escalateTicket', function()
    local source = source
    if temp_tickets[source] then
        DispatchToDiscord(source, temp_tickets[source])
        -- Não limpamos temp_tickets imediatamente para evitar spam? Melhor limpar.
        temp_tickets[source] = nil
    end
end)

RegisterServerEvent('godz_support:aiResolved')
AddEventHandler('godz_support:aiResolved', function()
    local source = source
    if temp_tickets[source] then
        local t = temp_tickets[source]
        -- Loga como resolvido pela IA (Economizou tempo da staff!)
        MySQL.Async.execute("INSERT INTO godz_support_tickets (user_id, category, description, status, staff_id) VALUES (@uid, @cat, @desc, 'resolved_ai', 0)", {
            ['@uid'] = t.user_id,
            ['@cat'] = t.category,
            ['@desc'] = t.description
        })
        TriggerClientEvent('godz_support:notify', source, "Ficamos felizes em ajudar!")
        temp_tickets[source] = nil
    end
end)

function DispatchToDiscord(source, ticket)
    MySQL.Async.insert("INSERT INTO godz_support_tickets (user_id, category, description) VALUES (@uid, @cat, @desc)", {
        ['@uid'] = ticket.user_id,
        ['@cat'] = ticket.category,
        ['@desc'] = ticket.description
    }, function(insertId)
        
        -- Envia para a API Python (que vai usar o Bot do Discord para criar Embed interativo)
        local payload = {
            ticket_id = insertId,
            user_id = ticket.user_id,
            category = ticket.label,
            description = ticket.description,
            webhook = Config.Webhooks.Tickets -- Fallback se o Bot não estiver configurado
        }
        
        PerformHttpRequest("http://127.0.0.1:5000/dispatch_ticket", function(err, text, headers)
            TriggerClientEvent('godz_support:notify', source, "Ticket #" .. insertId .. " enviado para a Staff.")
        end, "POST", json.encode(payload), { ["Content-Type"] = "application/json" })
        
    end)
end
