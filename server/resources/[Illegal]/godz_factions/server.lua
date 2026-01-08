local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local MasterConfig = { groups = {} }
local API_KEY = "godz_secret_key_123"

local function PerformHttpRequestWithRetry(url, cb, method, data, headers, max_retries)
    local retries = 0
    local success = false
    
    Citizen.CreateThread(function()
        while retries < (max_retries or 10) and not success do
            local finished = false
            local function finish(err, text, resp_headers)
                if finished then return end
                finished = true
                if err == 0 or err == nil then
                    if retries > 3 then
                        print("^3[GODZ FACTIONS] Falha na conexão com IA (Erro " .. tostring(err) .. "). Tentativa " .. (retries + 1) .. "...^0")
                    end
                else
                    success = true
                    if cb then cb(err, text, resp_headers) end
                end
            end

            PerformHttpRequest(url, function(err, text, resp_headers)
                finish(err, text, resp_headers)
            end, method, data, headers)

            SetTimeout(10000, function()
                finish(0, nil, nil)
            end)

            while not finished do
                Wait(25)
            end

            if not success then
                retries = retries + 1
                Wait(3000)
            end
        end
    end)
end

-- 1. Sincronização Master Config
Citizen.CreateThread(function()
    local attempts = 0
    while GetResourceState("godz_tuning") ~= "started" and attempts < 100 do
        attempts = attempts + 1
        Wait(200)
    end

    local data = nil
    if GetResourceState("godz_tuning") == "started" then
        local ok, res = pcall(function()
            return exports["godz_tuning"]:GetMasterConfig()
        end)
        if ok then data = res end
    end

    if data then
        MasterConfig = data
        print("^2[GODZ FACTIONS] ^7Config carregada via godz_tuning.")
    else
        print("^1[GODZ FACTIONS] ^7Erro ao carregar config via godz_tuning")
    end
end)

-- Helper: Get Player Faction
function GetPlayerFaction(user_id)
    if not MasterConfig.permissions then return nil end
    
    -- Exemplo simples: Verifica se o user tem permissão de algum grupo ilegal
    -- Na prática, isso dependeria de como o MasterConfig estrutura grupos.
    -- Assumindo estrutura: permissions = { "ballas": { "perm": "ballas.permissao", "leader": "ballas.lider" } }
    
    for group, data in pairs(MasterConfig.permissions) do
        if vRP.hasPermission(user_id, data.perm) then
            return group, false -- group, is_leader
        elseif vRP.hasPermission(user_id, data.leader) then
            return group, true
        end
    end
    return nil, false
end

-- 2. NUI Callbacks
RegisterNetEvent("godz_factions:getDashboardData")
AddEventHandler("godz_factions:getDashboardData", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local faction, is_leader = GetPlayerFaction(user_id)
    
    if not faction or not is_leader then
        TriggerClientEvent("godz:notify", source, "error", "Apenas líderes podem acessar este painel.", 5000)
        return
    end

    -- Coletar membros (Simulação baseada em usuários online + DB se possível)
    -- Para vRP padrão, é difícil pegar todos membros offline sem query.
    -- Vamos pegar online primeiro ou usar vRP.getUsersByPermission se disponível (geralmente só online).
    -- Vou fazer uma query SQL simulada assumindo godz_user_data ou similar, ou apenas online para MVP.
    
    local members = {}
    local online_users = vRP.getUsers()
    
    -- Pega usuários online da facção
    for _, uid in pairs(online_users) do
        if vRP.hasPermission(uid, MasterConfig.permissions[faction].perm) or vRP.hasPermission(uid, MasterConfig.permissions[faction].leader) then
            local identity = vRP.getUserIdentity(uid)
            table.insert(members, {
                user_id = uid,
                name = identity.name .. " " .. identity.firstname,
                role = vRP.hasPermission(uid, MasterConfig.permissions[faction].leader) and "Líder" or "Membro",
                status = "online"
            })
        end
    end

    TriggerClientEvent("godz_factions:openDashboard", source, {
        faction = faction,
        members = members
    })
end)

RegisterNetEvent("godz_factions:manageMember")
AddEventHandler("godz_factions:manageMember", function(data)
    local source = source
    local user_id = vRP.getUserId(source)
    local faction, is_leader = GetPlayerFaction(user_id)

    if not is_leader then return end

    local target_id = tonumber(data.target_id)
    local action = data.action -- promote, demote, kick

    if action == "kick" then
        vRP.removeUserGroup(target_id, faction) -- Ajustar conforme nome do grupo real
        TriggerClientEvent("godz:notify", source, "success", "Membro removido.", 5000)
        -- Log IA
        LogFactionAction(user_id, "Kicked ID " .. target_id)
    elseif action == "promote" then
        -- Lógica de promoção
    end
    
    -- Refresh dashboard
    TriggerEvent("godz_factions:getDashboardData")
end)

-- 3. Chest Logic & AI Logs
RegisterNetEvent("godz_factions:openChest")
AddEventHandler("godz_factions:openChest", function()
    local source = source
    local user_id = vRP.getUserId(source)
    local faction, _ = GetPlayerFaction(user_id)
    
    if faction then
        TriggerClientEvent("godz_chest:openFactionChest", source, "faction:"..faction)
    end
end)

-- Hook para logar retirada de itens (Deve ser chamado pelo godz_inventory ou monitorado aqui se o chest for custom)
-- Como não alteramos o inventory, vamos criar um evento que o inventory PODERIA chamar, 
-- ou simular que este script gerencia o baú.
-- Para este exercício, vou criar a função que envia para a IA.

function LogChestActivity(user_id, faction, item, amount, type)
    -- type: "withdraw" ou "deposit"
    if type == "withdraw" then
        PerformHttpRequestWithRetry("http://127.0.0.1:5000/analyze_chest_activity", function(err, text, headers)
            if err == 200 then
                local res = json.decode(text)
                if res and res.alert then
                    -- Alerta retornado pela IA (Limpa-baú detectado)
                    print("^1[GODZ AI] ALERTA DE LIMPA-BAÚ: ID " .. user_id)
                    -- Notificar Staff/Discord via Webhook (já feito no Python, mas podemos reforçar in-game)
                    local staff = vRP.getUsersByPermission("admin.permissao")
                    for _, sid in pairs(staff) do
                        TriggerClientEvent("godz:notify", sid, "importante", "🚨 ALERTA IA: Possível Limpa-Baú na facção " .. faction, 10000)
                    end
                end
            end
        end, "POST", json.encode({
            user_id = user_id,
            faction = faction,
            item = item,
            amount = amount
        }), { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. API_KEY }, 10)
    end
end

function LogFactionAction(user_id, action)
    -- Log genérico de ações de liderança
end

-- 4. Zone Interaction
RegisterNetEvent("godz_factions:interactZone")
AddEventHandler("godz_factions:interactZone", function(zoneName)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local zone = Config.Zones[zoneName]
    if not zone then return end

    -- Check permission
    local faction, is_leader = GetPlayerFaction(user_id)
    
    if zone.owner_group then
        -- Validate if player belongs to owner group
        if faction ~= zone.owner_group then
             TriggerClientEvent("godz:notify", source, "negado", "Você não tem permissão para usar esta zona.", 5000)
             return
        end
    end

    -- Farm logic
    if zone.farm_item then
        if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(zone.farm_item) * zone.farm_amount <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id, zone.farm_item, zone.farm_amount, true)
            -- TriggerClientEvent("godz:notify", source, "sucesso", "Coletou " .. zone.farm_item, 3000)
        else
            TriggerClientEvent("godz:notify", source, "negado", "Mochila cheia.", 5000)
        end
    end
end)
