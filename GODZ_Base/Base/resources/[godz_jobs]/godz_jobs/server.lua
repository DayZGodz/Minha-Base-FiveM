local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local src = {}
Tunnel.bindInterface("godz_jobs", src)

local MySQL = module("vrp_mysql", "MySQL")

-- Prepare SQL
MySQL.createCommand("godz_jobs/create_table", [[
    CREATE TABLE IF NOT EXISTS godz_user_jobs (
        user_id int(11) NOT NULL,
        job varchar(50) NOT NULL,
        level int(11) DEFAULT 1,
        xp int(11) DEFAULT 0,
        PRIMARY KEY (user_id, job)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])

MySQL.createCommand("godz_jobs/get_job", "SELECT * FROM godz_user_jobs WHERE user_id = @user_id AND job = @job")
MySQL.createCommand("godz_jobs/set_job", "INSERT INTO godz_user_jobs (user_id, job, level, xp) VALUES (@user_id, @job, @level, @xp) ON DUPLICATE KEY UPDATE level = @level, xp = @xp")

-- Init
Citizen.CreateThread(function()
    MySQL.execute("godz_jobs/create_table", {})
end)

-- Methods
function src.getAllJobsData()
    local source = source
    local user_id = vRP.getUserId(source)
    local data = {}
    
    for k, v in pairs(Config.Jobs) do
        local rows = MySQL.query("godz_jobs/get_job", { user_id = user_id, job = k })
        if #rows > 0 then
            data[k] = rows[1]
        else
            data[k] = { level = 1, xp = 0 }
        end
        
        data[k].next_level_xp = Config.XPFormula(data[k].level)
        data[k].bonus = (data[k].level - 1) * v.bonus_per_level
    end
    
    return data
end

RegisterServerEvent("godz_jobs:finishRoute")
AddEventHandler("godz_jobs:finishRoute", function(jobKey)
    local source = source
    local user_id = vRP.getUserId(source)
    local jobCfg = Config.Jobs[jobKey]
    
    if not jobCfg then return end
    
    -- Security check: Cooldown or distance verification should be here
    -- For now, we trust the client (PROTOTYPE)
    
    local rows = MySQL.query("godz_jobs/get_job", { user_id = user_id, job = jobKey })
    local current = { level = 1, xp = 0 }
    if #rows > 0 then current = rows[1] end
    
    -- Calculate Reward
    local bonus = (current.level - 1) * jobCfg.bonus_per_level
    local payment = jobCfg.salary_base + bonus
    
    -- Update XP
    current.xp = current.xp + jobCfg.xp_per_route
    local needed = Config.XPFormula(current.level)
    local leveledUp = false
    
    if current.xp >= needed then
        current.level = current.level + 1
        current.xp = current.xp - needed
        leveledUp = true
        TriggerClientEvent("godz_notify:notify", source, "sucesso", "Level Up!", "Você alcançou o nível " .. current.level .. " em " .. jobCfg.label)
    end
    
    -- Save
    MySQL.execute("godz_jobs/set_job", {
        user_id = user_id,
        job = jobKey,
        level = current.level,
        xp = current.xp
    })
    
    -- Give Money
    vRP.giveBankMoney(user_id, payment)
    TriggerClientEvent("godz_notify:notify", source, "sucesso", "Pagamento", "Recebeu $"..payment)
    
    -- Update HUD
    TriggerClientEvent("godz_interface:showXP", source, jobCfg.label, jobCfg.xp_per_route, (current.xp / Config.XPFormula(current.level)) * 100)
end)
