local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("godz_admin", src)

local Cfg = module("godz_admin", "config")
local alerts = {}

function src.checkPermission()
    local source = source
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, Cfg.Permission)
end

function src.getPlayers()
    local source = source
    local user_id = vRP.getUserId(source)
    if not vRP.hasPermission(user_id, Cfg.Permission) then return {} end

    local players = {}
    local users = vRP.getUsers()
    for id, src in pairs(users) do
        local identity = vRP.getUserIdentity(id)
        if identity then
            table.insert(players, {
                id = id,
                name = identity.name .. " " .. identity.firstname,
                source = src
            })
        end
    end
    return players
end

function src.adminAction(action, target_id)
    local source = source
    local user_id = vRP.getUserId(source)
    if not vRP.hasPermission(user_id, Cfg.Permission) then return end
    
    local target_src = vRP.getUserSource(target_id)
    if not target_src and action ~= "ban" then 
        TriggerClientEvent("godz_notify:notify", source, "erro", "Erro", "Jogador offline.")
        return 
    end

    if action == "goto" then
        local tCoords = GetEntityCoords(GetPlayerPed(target_src))
        vRPclient.teleport(source, tCoords.x, tCoords.y, tCoords.z)
    elseif action == "bring" then
        local sCoords = GetEntityCoords(GetPlayerPed(source))
        vRPclient.teleport(target_src, sCoords.x, sCoords.y, sCoords.z)
    elseif action == "god" then
        vRPclient.killGod(target_src)
        vRPclient.setHealth(target_src, 400)
        TriggerClientEvent("godz_notify:notify", source, "sucesso", "Admin", "Jogador revivido.")
    elseif action == "kick" then
        vRP.kick(target_src, "Você foi kickado por um administrador.")
    elseif action == "ban" then
        vRP.setBanned(target_id, true)
        if target_src then vRP.kick(target_src, "Você foi banido.") end
        TriggerClientEvent("godz_notify:notify", source, "sucesso", "Admin", "Jogador banido.")
    end
end

function src.giveItem(target_id, item, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if not vRP.hasPermission(user_id, Cfg.Permission) then return end
    
    vRP.giveInventoryItem(target_id, item, amount, true)
    TriggerClientEvent("godz_notify:notify", source, "sucesso", "Admin", "Item enviado.")
end

function src.giveVehicle(target_id, vehicle)
    local source = source
    local user_id = vRP.getUserId(source)
    if not vRP.hasPermission(user_id, Cfg.Permission) then return end
    
    local target_src = vRP.getUserSource(target_id)
    if target_src then
        -- Assuming standard vRP command or function to spawn/give vehicle
        -- For simplicity, we might just spawn it or add to database
        -- Using a command approach or direct execute if available
        -- vRP.execute("vRP/add_vehicle", { user_id = target_id, vehicle = vehicle }) -- If SQL
        -- TriggerClientEvent("godz_admin:spawnVehicle", target_src, vehicle) -- Simple spawn
        
        -- Let's add it to DB and notify
        vRP.execute("vRP/add_vehicle", { user_id = target_id, vehicle = vehicle }) 
        TriggerClientEvent("godz_notify:notify", source, "sucesso", "Admin", "Veículo adicionado à garagem.")
    end
end

function src.getSecurityAlerts()
    return alerts
end

function src.logNoclip(isActive)
    local source = source
    local user_id = vRP.getUserId(source)
    local status = isActive and "Ativado" or "Desativado"
    
    -- Send to Discord (Simple implementation)
    PerformHttpRequest(Cfg.WebhookNoclip, function(err, text, headers) end, 'POST', json.encode({
        content = "Admin ID: " .. user_id .. " | Noclip: " .. status
    }), { ['Content-Type'] = 'application/json' })
end

-- Event to receive alerts from godz_shield
RegisterNetEvent("godz_admin:addAlert")
AddEventHandler("godz_admin:addAlert", function(alertData)
    table.insert(alerts, 1, alertData)
    if #alerts > 5 then table.remove(alerts) end
end)
