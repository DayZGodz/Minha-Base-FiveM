local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- MASTER CONFIG SYNC
-----------------------------------------------------------------------------------------------------------------------------------------
local MasterConfig = { whitelists = { ignored_by_sentinel = {} } }
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
                        print("^3[GODZ SHIELD] Falha na conexão com IA (Erro " .. tostring(err) .. "). Tentativa " .. (retries + 1) .. "...^0")
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
        
        if not success then
            print("^1[GODZ SHIELD] Erro Crítico: Não foi possível conectar à IA após tentativas.^0")
        end
    end)
end

Citizen.CreateThread(function()
    local attempts = 0
    while GetResourceState("godz_tuning") ~= "started" and attempts < 100 do
        attempts = attempts + 1
        Wait(200)
    end

    print("[GODZ] Tentando conectar com a IA...")

    local data = nil
    if GetResourceState("godz_tuning") == "started" then
        local ok, res = pcall(function()
            return exports["godz_tuning"]:GetMasterConfig()
        end)
        if ok then data = res end
    end

    if data then
        MasterConfig = data
        print("^2[GODZ SHIELD] ^7Config carregada via godz_tuning.")
    else
        print("^1[GODZ SHIELD] ^7Falha ao carregar config via godz_tuning")
    end
end)

local function IsWhitelisted(user_id)
    local ignored = (MasterConfig.PERMISSIONS and MasterConfig.PERMISSIONS.ignored_by_sentinel) or (MasterConfig.whitelists and MasterConfig.whitelists.ignored_by_sentinel) or {}
    for _, id in pairs(ignored) do
        if tonumber(id) == tonumber(user_id) then return true end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- BAN FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------------
local function BanPlayer(source, reason)
    local user_id = vRP.getUserId(source)
    if user_id then
        if IsWhitelisted(user_id) then
            print("^3[GODZ SHIELD] ^7Banimento evitado para Staff ID: " .. user_id .. " (Whitelist Ativa)")
            return
        end

        print("^1[GODZ SHIELD] BANINDO JOGADOR ID: " .. user_id .. " | MOTIVO: " .. reason .. "^0")
        
        -- Tenta usar a função nativa de banimento do vRP se existir, caso contrário bane via SQL ou kick
        if vRP.setBanned then
            vRP.setBanned(user_id, true)
            vRP.kick(source, Config.Messages.Banned)
        else
            -- Fallback para Kick se setBanned não estiver disponível diretamente
            -- Idealmente aqui entraria uma query SQL update godz_users set banned = 1 where id = @id
            -- Mas como não temos certeza da estrutura exata do admin, vamos usar DropPlayer
            DropPlayer(source, Config.Messages.Banned)
            
            -- Tentativa de banimento SQL direto (assumindo godz_users padrão)
            -- exports.oxmysql:execute("UPDATE godz_users SET banned = 1 WHERE id = ?", {user_id})
        end
    else
        DropPlayer(source, Config.Messages.Banned)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANTI-TRIGGER (HONEYPOTS)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Registra eventos falsos que cheaters costumam tentar chamar
for _, eventName in pairs(Config.SensitiveEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function()
        local source = source
        local user_id = vRP.getUserId(source)
        
        if user_id then
            -- Verifica se o jogador tem permissão de admin
            if not vRP.hasPermission(user_id, Config.AdminPermission) then
                BanPlayer(source, "Tentativa de Trigger Malicioso: " .. eventName)
            else
                print("^3[GODZ SHIELD] Admin ID " .. user_id .. " disparou evento monitorado: " .. eventName .. " (Permitido)^0")
            end
        end
    end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANTI-EXPLOIT DE NOME
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()
    Wait(1000) -- [GODZ FIX] Delay aumentado para 1s para garantir integridade DB
    
    local playerName = name
    if not playerName then 
        deferrals.done("Nome inválido.")
        return 
    end

    -- Regex para permitir apenas letras, números, espaços, underlines e hífens
    -- Bloqueia aspas, ponto e vírgula, e outros caracteres usados em SQL Injection ou bugs visuais
    if string.match(playerName, "[^a-zA-Z0-9%s%-_]") then
        print("^1[GODZ SHIELD] Conexão recusada para: " .. playerName .. " (Caracteres inválidos)^0")
        deferrals.done(Config.Messages.InvalidName)
    else
        deferrals.done()
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOG DE DETECÇÃO DE ARMAS (Recebido do Client)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("godz_shield:logDetection")
AddEventHandler("godz_shield:logDetection", function(weaponName)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        print("^3[GODZ SHIELD] Arma proibida removida do ID: " .. user_id .. " | Arma: " .. weaponName .. "^0")
        -- Opcional: Notificar admins online
    end
end)
