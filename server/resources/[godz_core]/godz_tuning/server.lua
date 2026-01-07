local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
-- local MySQL = module("vrp_mysql", "MySQL")
-- MySQL.createCommand removed for oxmysql

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local MasterConfig = {}

-- Create Table for Mods
Citizen.CreateThread(function()
    Wait(1000)
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS godz_vehicle_mods (
            user_id int(11) NOT NULL,
            vehicle varchar(100) NOT NULL,
            plate varchar(20) NOT NULL,
            mods longtext,
            PRIMARY KEY (plate)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
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
    local config = LoadResourceFile(GetCurrentResourceName(), "GODZ_MASTER_CONFIG.json")
    
    if config then
        MasterConfig = json.decode(config)
        if MasterConfig then
            print("^2[GODZ Tuning] Master Config carregado com sucesso.^0")
        else
            print("^1[GODZ Tuning] Erro de sintaxe no JSON. Usando valores padrão.^0")
            -- Default values
            MasterConfig = {
                ECONOMY = {
                    tuning_prices = {
                        engine_base = 5000,
                        turbo_base = 15000,
                        brakes_base = 2000,
                        transmission_base = 3000,
                        suspension_base = 2500,
                        armor_base = 10000
                    }
                }
            }
        end
    else
        print("^1[GODZ Tuning] Erro: GODZ_MASTER_CONFIG.json não encontrado via LoadResourceFile.^0")
        MasterConfig = {
            ECONOMY = {
                tuning_prices = {
                    engine_base = 5000,
                    turbo_base = 15000,
                    brakes_base = 2000,
                    transmission_base = 3000,
                    suspension_base = 2500,
                    armor_base = 10000
                }
            }
        }
    end
end)

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