local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local MasterConfig = {}

local function sanitize_json(content)
    if not content then return nil end
    content = content:gsub("^\239\187\191", "")
    content = content:gsub("\r", "")
    content = content:gsub("%z", "")
    return content
end

-- Create Table for Mods and Report
Citizen.CreateThread(function()
    Wait(1000)
    
    -- Fix: Ensure godz_user_vehicles exists (Protocolo de Estabilização Crítica)
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS godz_user_vehicles (
            user_id INT(11) NOT NULL,
            vehicle VARCHAR(50) NOT NULL,
            plate VARCHAR(20) NOT NULL,
            mechanic_report TEXT DEFAULT NULL,
            PRIMARY KEY (user_id, vehicle)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS godz_vehicle_mods (
            user_id int(11) NOT NULL,
            vehicle varchar(100) NOT NULL,
            plate varchar(20) NOT NULL,
            mods longtext,
            PRIMARY KEY (plate)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
    
    -- Ensure godz_user_vehicles has mechanic_report column
    -- We try to add it; if it fails (exists), we catch it or ignore.
    -- Since we can't easily catch SQL errors in all versions, we'll assume it might be missing.
    -- Better strategy: Just run ALTER TABLE IGNORE or check information_schema if possible.
    -- Simple approach: Attempt to add it.
    MySQL.query("ALTER TABLE godz_user_vehicles ADD COLUMN IF NOT EXISTS mechanic_report TEXT", {}, function(result) end)
end)

local src = {}

-- Methods
function src.getVehicleMods(plate)
    if not plate then return nil end
    local rows = MySQL.query.await("SELECT mods FROM godz_vehicle_mods WHERE plate = @plate", {plate = plate})
    if rows and #rows > 0 then
        return json.decode(rows[1].mods)
    end
    return nil
end

function src.saveVehicleMods(user_id, vehicle, plate, mods)
    if not user_id or not plate then return end
    
    MySQL.insert("INSERT INTO godz_vehicle_mods (user_id, vehicle, plate, mods) VALUES (@user_id, @vehicle, @plate, @mods) ON DUPLICATE KEY UPDATE mods = @mods", {
        user_id = user_id,
        vehicle = vehicle,
        plate = plate,
        mods = json.encode(mods)
    })
end

function src.saveMechanicReport(user_id, plate, report)
    MySQL.update("UPDATE godz_user_vehicles SET mechanic_report = @report WHERE user_id = @user_id AND vehicle_plate = @plate", {
        report = report,
        user_id = user_id,
        plate = plate
    })
end

-- Helper: Get Mechanic Level
function GetMechanicLevel(user_id)
    -- Assuming a vRP function or query
    -- Mock implementation
    return 20 -- Always max for testing or check groups
end

-- Load Master Config
Citizen.CreateThread(function()
    local config = LoadResourceFile(GetCurrentResourceName(), "GODZ_MASTER_CONFIG.json")
    config = sanitize_json(config)
    
    if config then
        local status, result = pcall(json.decode, config)
        if status then
            MasterConfig = result
            print("^2[GODZ Tuning] Master Config carregado com sucesso.^0")
        else
            print("^1[GODZ Tuning] Erro fatal ao decodificar JSON: " .. result .. "^0")
            MasterConfig = nil 
        end
    end
end)

function GetMasterConfig()
    return MasterConfig
end
exports('GetMasterConfig', GetMasterConfig)        print("^1[GODZ Tuning] Arquivo GODZ_MASTER_CONFIG.json não encontrado.^0")
    end

    if not MasterConfig then
        MasterConfig = { 
            SERVER_INFO = { server_name = "GODZ", discord_token = "YOUR_DISCORD_TOKEN_HERE" },
            ECONOMY = { tuning_prices = { engine_base = 5000, turbo_base = 15000, brakes_base = 2000, transmission_base = 3000, suspension_base = 2500, armor_base = 10000 } } 
        }
    end
end)

exports("GetMasterConfig", function()
    if not MasterConfig then return nil end
    local ok, cloned = pcall(function()
        return json.decode(json.encode(MasterConfig))
    end)
    if ok then return cloned end
    return MasterConfig
end)

exports("ReloadMasterConfig", function()
    local config = LoadResourceFile(GetCurrentResourceName(), "GODZ_MASTER_CONFIG.json")
    config = sanitize_json(config)
    if not config then return false end
    local status, result = pcall(json.decode, config)
    if not status then return false end
    MasterConfig = result
    return true
end)

-- [GODZ] Safe Config Save (Merge Strategy)
function src.saveConfig()
    local current_content = LoadResourceFile(GetCurrentResourceName(), "GODZ_MASTER_CONFIG.json")
    local current_data = {}
    if current_content then
        current_data = json.decode(current_content) or {}
    end

    -- Merge Memory Config into File Config
    for k,v in pairs(MasterConfig) do
        current_data[k] = v
    end
    
    -- Ensure Token Persistence
    if not current_data.SERVER_INFO then current_data.SERVER_INFO = {} end
    if not current_data.SERVER_INFO.discord_token or current_data.SERVER_INFO.discord_token == "" then
        -- Restore from hardcoded backup if missing
        current_data.SERVER_INFO.discord_token = "YOUR_DISCORD_TOKEN_HERE"
    end
    
    SaveResourceFile(GetCurrentResourceName(), "GODZ_MASTER_CONFIG.json", json.encode(current_data, {indent = true}), -1)
end

RegisterNetEvent("godz_tuning:requestConfig")
AddEventHandler("godz_tuning:requestConfig", function()
    local source = source
    local prices = {}
    
    if MasterConfig and MasterConfig.ECONOMY and MasterConfig.ECONOMY.tuning_prices then
        prices = MasterConfig.ECONOMY.tuning_prices
    else
         prices = {
            engine_base = 5000,
            turbo_base = 15000,
            brakes_base = 2000,
            transmission_base = 3000,
            suspension_base = 2500,
            armor_base = 10000
        }
    end
    
    TriggerClientEvent("godz_tuning:receiveConfig", source, prices)
end)

RegisterNetEvent("godz_tuning:applyMod")
AddEventHandler("godz_tuning:applyMod", function(category, index, level, props)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end
    
    -- Aqui entraria verificação de dinheiro e nível
    -- Vamos assumir sucesso para o teste
    
    -- Salvar no banco
    if props and props.plate then
        src.saveVehicleMods(user_id, props.model, props.plate, props)
    end
    
    -- Notificar sucesso ao client para atualizar visual
    TriggerClientEvent("godz_tuning:modApplied", source, category, index)
    
    -- Opcional: Notificar pagamento
    -- vRP.tryPayment(user_id, price)
end)

RegisterNetEvent("godz_tuning:finish")
AddEventHandler("godz_tuning:finish", function(mods, model, plate)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end
    
    -- Integrar com AI (Real)
    local prompt = "Gere um laudo mecânico curto e técnico (max 20 palavras) para um veículo modelo " .. tostring(model) .. " com as seguintes modificações: "
    if mods.engine == 3 then prompt = prompt .. "Motor Nível 4, " end
    if mods.turbo then prompt = prompt .. "Turbo, " end
    if mods.suspension == 3 then prompt = prompt .. "Suspensão Competição, " end
    if mods.brakes == 2 then prompt = prompt .. "Freios de Corrida, " end
    if mods.transmission == 2 then prompt = prompt .. "Transmissão Esportiva, " end
    prompt = prompt .. ". Fale sobre desempenho em retas e curvas."

    PerformHttpRequest("http://localhost:5000/ai_assist", function(err, text, headers)
        local report = "Laudo indisponível no momento."
        
        if err == 200 and text then
            local data = json.decode(text)
            if data and data.report then
                report = data.report
            end
        else
            -- Fallback em caso de erro da API
            if mods.engine == 3 and mods.turbo then
                report = "Com esse setup, seu veículo é um monstro nas retas, mas cuidado com o torque excessivo nas curvas."
            else
                report = "Configuração equilibrada para uso urbano. Boa resposta, mas sem exageros."
            end
        end

        -- Salvar laudo
        if plate then
            MySQL.update("UPDATE godz_user_vehicles SET mechanic_report = @report WHERE user_id = @user_id AND vehicle_plate = @plate", {
                report = report,
                user_id = user_id,
                plate = plate
            })
        end

        -- Notificar Client
        TriggerClientEvent("Notify", source, "ia_tip", "Laudo Mecânico: " .. report)
    end, 'POST', json.encode({prompt = prompt}), { ["Content-Type"] = 'application/json' })
end)
