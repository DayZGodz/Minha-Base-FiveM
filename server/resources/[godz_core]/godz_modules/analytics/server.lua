local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local cfg = module("vrp", "cfg/groups")
local groups = cfg.groups

local AI_BASE_URL = "http://127.0.0.1:5000/"

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

-- Função de Retry Suave para IA (Evita travar o servidor)
local function PerformHttpRequestWithRetry(url, cb, method, data, headers, max_retries, timeout_ms)
    local retries = 0
    local success = false
    local tmo = timeout_ms or 20000
    
    Citizen.CreateThread(function()
        while retries < (max_retries or 3) and not success do
            local finished = false
            local function finish(err, text, resp_headers)
                if finished then return end
                finished = true
                if err == 0 or err == nil then
                    -- Falha de rede/timeout
                    if retries >= 1 then
                        print("^3[GODZ MODULES] Tentativa de conexão com IA (" .. (retries + 1) .. "/" .. max_retries .. ") falhou. Retentando em breve...^0")
                    end
                else
                    success = true
                    if cb then cb(err, text, resp_headers) end
                end
            end

            PerformHttpRequest(url, function(err, text, resp_headers)
                finish(err, text, resp_headers)
            end, method, data, headers)

            -- Timeout de segurança interno da função wrapper
            SetTimeout(tmo, function()
                finish(0, nil, nil)
            end)

            -- Espera resposta ou timeout
            local wait_count = 0
            while not finished and wait_count < math.floor((tmo + 1000) / 100) do
                Wait(100)
                wait_count = wait_count + 1
            end

            if not success then
                retries = retries + 1
                Wait(2000) -- Espera 2s antes de tentar de novo (Suave)
            end
        end

        if not success then
             print("^1[GODZ MODULES] IA Inacessível após várias tentativas. Operação cancelada sem travar o servidor.^0")
        end
    end)
end

local function SendAnalytics()
    local data = {
        online_players = GetOnlinePlayers(),
        economy_balance = GetActiveEconomy(),
        active_jobs = GetActiveJobs(),
        active_user_ids = GetActiveUserIDs()
    }
    
    -- Usando o sistema de Retry Suave
    PerformHttpRequestWithRetry(AI_BASE_URL .. "analytics_ingest", function(err, text, headers)
        if err == 200 then
            print("^2[GODZ ANALYTICS] ^7Dados enviados com sucesso.")
        else
            print("^1[GODZ ANALYTICS] ^7Erro na resposta da API: " .. tostring(err))
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' }, 8, 20000)
end

Citizen.CreateThread(function()
    Wait(60000)
    SendAnalytics()
    while true do
        Wait(30 * 60 * 1000) -- 30 minutos
        SendAnalytics()
    end
end)
