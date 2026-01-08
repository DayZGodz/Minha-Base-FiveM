local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local cfg = module("vrp", "cfg/groups")
local groups = cfg.groups

local function getUserJob(user_id)
    local user_groups = vRP.getUserGroups(user_id)
    for k,v in pairs(user_groups) do
        local kgroup = groups[k]
        if kgroup and kgroup._config and kgroup._config.gtype and kgroup._config.gtype == "job" then
            return kgroup._config.title
        end
    end
    return "Desempregado"
end

local function GetOnlinePlayers()
    return GetNumPlayerIndices()
end

local function GetActiveJobs()
    local jobs = {}
    local users = vRP.getUsers()
    for _, user_id in pairs(users) do
        local job = getUserJob(user_id)
        jobs[job] = (jobs[job] or 0) + 1
    end
    return jobs
end

local function GetActiveUserIDs()
    local ids = {}
    local users = vRP.getUsers()
    for _, user_id in pairs(users) do
        table.insert(ids, parseInt(user_id))
    end
    return ids
end

-- Soma apenas economia ativa (jogadores online) para evitar locks no DB
local function GetActiveEconomy()
    local total = 0
    local users = vRP.getUsers()
    for _, user_id in pairs(users) do
        local wallet = vRP.getMoney(user_id) or 0
        local bank = vRP.getBankMoney(user_id) or 0
        total = total + wallet + bank
    end
    return total
end

local function SendAnalytics()
    local data = {
        online_players = GetOnlinePlayers(),
        economy_balance = GetActiveEconomy(),
        active_jobs = GetActiveJobs(),
        active_user_ids = GetActiveUserIDs()
    }
    
    -- Timeout reduzido para 2 segundos conforme solicitado (evita travar spawn se chamado no inicio)
    PerformHttpRequestWithTimeout("http://127.0.0.1:5000/analytics_ingest", function(err, text, headers)
        if err == 200 then
            print("^2[GODZ ANALYTICS] ^7Dados enviados com sucesso.")
        else
            print("^1[GODZ ANALYTICS] ^7Erro ou Timeout ao enviar dados: " .. tostring(err))
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' }, 2000)
end

Citizen.CreateThread(function()
    Wait(10000) -- Aguarda 10s para inicialização total
    SendAnalytics()
    while true do
        Wait(30 * 60 * 1000) -- 30 minutos
        SendAnalytics()
    end
end)
