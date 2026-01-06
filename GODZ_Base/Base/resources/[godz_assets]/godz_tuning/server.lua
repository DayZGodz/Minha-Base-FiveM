local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local MySQL = module("vrp_mysql", "MySQL")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local MasterConfig = {}

-- Create Table for Mods
MySQL.createCommand("godz_tuning/create_table", [[
    CREATE TABLE IF NOT EXISTS godz_vehicle_mods (
        user_id int(11) NOT NULL,
        vehicle varchar(100) NOT NULL,
        plate varchar(20) NOT NULL,
        mods longtext,
        PRIMARY KEY (plate)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])

MySQL.createCommand("godz_tuning/get_mods", "SELECT mods FROM godz_vehicle_mods WHERE plate = @plate")
MySQL.createCommand("godz_tuning/set_mods", "INSERT INTO godz_vehicle_mods (user_id, vehicle, plate, mods) VALUES (@user_id, @vehicle, @plate, @mods) ON DUPLICATE KEY UPDATE mods = @mods")

-- Helper: Get Mechanic Level
function GetMechanicLevel(user_id)
    local rows = MySQL.query("godz_jobs/get_job", { user_id = user_id, job = "mecanico" })
    if #rows > 0 then
        return rows[1].level
    end
    return 0 -- Não é mecânico ou nível 0
end

-- Load Master Config
Citizen.CreateThread(function()
    MySQL.execute("godz_tuning/create_table", {})
    
    -- Tentar ler GODZ_MASTER_CONFIG.json
    local file = io.open("GODZ_MASTER_CONFIG.json", "r")
    if file then
        local content = file:read("*a")
        MasterConfig = json.decode(content)
        file:close()
        print("^2[GODZ Tuning] Master Config carregado com sucesso.^0")
    else
        print("^1[GODZ Tuning] Erro ao carregar GODZ_MASTER_CONFIG.json. Usando valores padrao.^0")
        MasterConfig = {
            tuning_prices = {
                engine_base = 5000,
                turbo_base = 15000,
                brakes_base = 2000,
                transmission_base = 3000,
                suspension_base = 2500,
                armor_base = 10000
            }
        }
    end
end)

RegisterNetEvent("godz_tuning:requestConfig")
AddEventHandler("godz_tuning:requestConfig", function()
    local source = source
    TriggerClientEvent("godz_tuning:receiveConfig", source, MasterConfig.tuning_prices or {})
end)

RegisterNetEvent("godz_tuning:applyMod")
AddEventHandler("godz_tuning:applyMod", function(modType, modIndex, modLevel, vehicleProps)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    -- Verificar Nível
    local mechLevel = GetMechanicLevel(user_id)
    local reqLevel = 0
    
    if Config.LevelRequirements[modType] then
        if type(Config.LevelRequirements[modType]) == "table" then
            -- Check specific level for index
            -- Mas o config usa indices 0-4 ou true/false.
            -- modIndex vem do JS.
            if modType == "turbo" then
                if modIndex == true or modIndex == "on" or modIndex == 1 then
                    reqLevel = Config.LevelRequirements.turbo[true]
                end
            else
                reqLevel = Config.LevelRequirements[modType][tonumber(modIndex)] or 0
            end
        end
    end

    if mechLevel < reqLevel then
        TriggerClientEvent("godz_notify:notify", source, "negado", "Nível Insuficiente", "Você precisa ser mecânico nível "..reqLevel.." para instalar esta peça.")
        return
    end

    -- Calcular Preço
    local price = 0
    local prices = {}
    if MasterConfig.ECONOMY and MasterConfig.ECONOMY.tuning_prices then
        prices = MasterConfig.ECONOMY.tuning_prices
    end
    
    if modType == "engine" then
        price = (prices.engine_base or 5000) * (modIndex + 1) -- Exemplo simples
        if modIndex == -1 then price = 0 end -- Stock
    elseif modType == "turbo" then
        price = prices.turbo_base or 15000
    elseif modType == "brakes" then
        price = (prices.brakes_base or 2000) * (modIndex + 1)
    elseif modType == "transmission" then
        price = (prices.transmission_base or 3000) * (modIndex + 1)
    elseif modType == "suspension" then
        price = (prices.suspension_base or 2500) * (modIndex + 1)
    end
    
    -- Cobrar
    if vRP.tryFullPayment(user_id, price) then
        -- Salvar no DB
        local plate = vehicleProps.plate
        local model = vehicleProps.model -- Hash ou Nome
        
        -- Async Save para não travar main thread
        Citizen.CreateThread(function()
            MySQL.execute("godz_tuning/set_mods", {
                user_id = user_id,
                vehicle = model,
                plate = plate,
                mods = json.encode(vehicleProps)
            })
        end)

        TriggerClientEvent("godz_tuning:modApplied", source, modType, modIndex)
        TriggerClientEvent("godz_notify:notify", source, "sucesso", "Tuning", "Peça instalada com sucesso! Pagou $"..price)
    else
        TriggerClientEvent("godz_notify:notify", source, "negado", "Saldo Insuficiente", "Você precisa de $"..price)
    end
end)

-- Evento para carregar mods ao spawnar (pode ser chamado pelo godz_garages)
RegisterNetEvent("godz_tuning:loadMods")
AddEventHandler("godz_tuning:loadMods", function(plate, vehicleNetId)
    local source = source
    MySQL.query("godz_tuning/get_mods", { plate = plate }, function(rows)
        if #rows > 0 and rows[1].mods then
            local mods = json.decode(rows[1].mods)
            TriggerClientEvent("godz_tuning:applyModsParams", source, vehicleNetId, mods)
        end
    end)
end)
