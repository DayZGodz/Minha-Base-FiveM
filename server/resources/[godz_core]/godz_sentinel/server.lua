local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local entity_creation_log = {}
local ENTITY_LIMIT = 5
local ENTITY_TIME = 1000 -- 1 segundo

-- Webhook (Configure aqui)
local WEBHOOK_SENTINEL = "YOUR_DISCORD_WEBHOOK_HERE"
local AI_ENDPOINT = "http://localhost:5000/sentinel_check"

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOGS EM EMBED PREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function sendSentinelLog(title, description, user_id, type)
    Citizen.CreateThread(function()
        local identity = vRP.getUserIdentity(user_id)
        local bio = "N/A"
        local name = "Unknown"
        
        if identity then
            name = identity.name .. " " .. identity.firstname
            -- Busca a biografia na tabela godz_user_identities (suporte ao Lore Generator)
            local rows = exports.oxmysql:executeSync("SELECT biography FROM godz_user_identities WHERE user_id = ?", {user_id})
            if rows and rows[1] and rows[1].biography then 
                bio = rows[1].biography 
            end
        end

        local color = 13998647 -- Dourado (#D4AF37)
        if type == "BAN" then color = 15158332 end -- Vermelho

        local embed = {
            {
                ["color"] = color,
                ["title"] = "**" .. title .. "**",
                ["description"] = description,
                ["fields"] = {
                    { ["name"] = "🆔 User ID", ["value"] = tostring(user_id), ["inline"] = true },
                    { ["name"] = "👤 Personagem", ["value"] = name, ["inline"] = true },
                    { ["name"] = "📜 Lore (IA)", ["value"] = bio }
                },
                ["footer"] = { ["text"] = "🛡️ GODZ Sentinel AI • " .. os.date("%d/%m/%Y %H:%M:%S") }
            }
        }
        
        PerformHttpRequest(WEBHOOK_SENTINEL, function(err, text, headers) end, 'POST', json.encode({username = "GODZ Sentinel", embeds = embed}), { ['Content-Type'] = 'application/json' })
    end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANTI-EXPLOSÃO & ENTITY CONTROL
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("entityCreating", function(entity)
    local source = NetworkGetEntityOwner(entity)
    if not source then return end
    
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    if not entity_creation_log[user_id] then entity_creation_log[user_id] = {} end

    local now = GetGameTimer()
    -- Limpa logs antigos (> 1s)
    for i=#entity_creation_log[user_id], 1, -1 do
        if now - entity_creation_log[user_id][i] > ENTITY_TIME then
            table.remove(entity_creation_log[user_id], i)
        end
    end

    table.insert(entity_creation_log[user_id], now)

    if #entity_creation_log[user_id] > ENTITY_LIMIT then
        CancelEvent()
        vRP.kick(source, "[GODZ SENTINEL] Tentativa de Crash Detectada (Entity Spam)")
        sendSentinelLog("🚫 CRITICAL: ENTITY SPAM", "Jogador tentou criar mais de " .. ENTITY_LIMIT .. " entidades em 1 segundo.", user_id, "BAN")
        print("[GODZ SENTINEL] Entity Spam detectado para ID: " .. user_id)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANÁLISE DE SUSPEITA (IA)
-----------------------------------------------------------------------------------------------------------------------------------------
function checkSuspiciousActivity(user_id, activity_type, value)
    local data = {
        user_id = user_id,
        activity = activity_type,
        value = value,
        timestamp = os.time()
    }

    PerformHttpRequest(AI_ENDPOINT, function(err, text, headers)
        if err == 200 then
            local result = json.decode(text)
            if result and result.action == "quarantine" then
                -- Coloca em Quarentena (Shadowban)
                vRP.setUData(user_id, "godz:quarantine", "true")
                sendSentinelLog("🤖 AI SENTINEL: QUARANTINE", "IA detectou comportamento anômalo e colocou o jogador em quarentena.\n**Motivo:** " .. (result.reason or "Padrão suspeito não confirmado"), user_id, "WARN")
                
                local source = vRP.getUserSource(user_id)
                if source then
                    TriggerClientEvent("Notify", source, "ia_tip", "Sua conta está sob análise da IA. Algumas funções podem estar limitadas.")
                end
            end
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("godz_sentinel:checkSuspicious")
AddEventHandler("godz_sentinel:checkSuspicious", function(user_id, type, value)
    checkSuspiciousActivity(user_id, type, value)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PROTEÇÃO DE TRIGGERS (Source Trust & HoneyPots)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Lista de eventos comuns usados por injetores (Honeypot)
local honey_events = {
    "esx:giveInventoryItem",
    "mvm:giveMoney",
    "AdminMenu:giveBank",
    "vrp:giveMoney", -- Proteção contra injetores que tentam adivinhar eventos
    "vrp:setGroup"
}

for _, evt in pairs(honey_events) do
    RegisterNetEvent(evt)
    AddEventHandler(evt, function()
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            vRP.setBanned(user_id, true)
            vRP.kick(source, "[GODZ SENTINEL] Trigger Malicioso Detectado: " .. evt)
            sendSentinelLog("⛔ BAN: TRIGGER ABUSE", "Tentativa de usar trigger bloqueado/inexistente: " .. evt, user_id, "BAN")
        end
    end)
end
