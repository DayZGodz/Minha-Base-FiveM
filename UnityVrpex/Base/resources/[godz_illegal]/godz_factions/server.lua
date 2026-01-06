local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local Config = module("godz_factions", "config")

--[ DATABASE INITIALIZATION ]------------------------------------------------------------------------------------------------------------------------

vRP.prepare("godz_factions/create_table", [[
    CREATE TABLE IF NOT EXISTS godz_faction_stats (
        user_id INT NOT NULL,
        faction VARCHAR(50) NOT NULL,
        items_delivered INT DEFAULT 0,
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, faction)
    )
]])

vRP.prepare("godz_factions/update_farm", "INSERT INTO godz_faction_stats (user_id, faction, items_delivered) VALUES (@user_id, @faction, @amount) ON DUPLICATE KEY UPDATE items_delivered = items_delivered + @amount")
vRP.prepare("godz_factions/get_stats", "SELECT items_delivered FROM godz_faction_stats WHERE user_id = @user_id AND faction = @faction")
vRP.prepare("godz_factions/reset_stats", "UPDATE godz_faction_stats SET items_delivered = 0 WHERE user_id = @user_id AND faction = @faction")

Citizen.CreateThread(function()
    vRP.execute("godz_factions/create_table")
end)

--[ FUNCTIONS ]--------------------------------------------------------------------------------------------------------------------------------------

function getPlayerFaction(user_id)
    for factionId, data in pairs(Config.Factions) do
        if vRP.hasPermission(user_id, data.leaderGroup) then
            return factionId, true -- Is Leader
        elseif vRP.hasPermission(user_id, data.memberGroup) then
            return factionId, false -- Is Member
        end
    end
    return nil, false
end

function getFactionMembers(factionId)
    local members = {}
    local data = Config.Factions[factionId]
    if not data then return members end

    -- Getting online users
    local online_users = vRP.getUsers()
    for _, src in pairs(online_users) do
        local uid = vRP.getUserId(src)
        if uid then
            if vRP.hasPermission(uid, data.memberGroup) or vRP.hasPermission(uid, data.leaderGroup) then
                local rows = vRP.query("godz_factions/get_stats", { user_id = uid, faction = factionId })
                local farm = 0
                if #rows > 0 then farm = rows[1].items_delivered end
                
                local identity = vRP.getUserIdentity(uid)
                local name = "Desconhecido"
                if identity then name = identity.name .. " " .. identity.firstname end
                
                table.insert(members, {
                    user_id = uid,
                    name = name,
                    farm = farm,
                    online = true,
                    is_leader = vRP.hasPermission(uid, data.leaderGroup)
                })
            end
        end
    end
    
    return members
end

--[ EVENT HANDLERS ]---------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent("godz_factions:updateFarm")
AddEventHandler("godz_factions:updateFarm", function(user_id, amount)
    if user_id and amount then
        local factionId, _ = getPlayerFaction(user_id)
        if factionId then
            vRP.execute("godz_factions/update_farm", { user_id = user_id, faction = factionId, amount = amount })
        end
    end
end)

--[ NUI CALLBACKS ]----------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent("godz_factions:requestData")
AddEventHandler("godz_factions:requestData", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    local factionId, isLeader = getPlayerFaction(user_id)
    if factionId and isLeader then
        local members = getFactionMembers(factionId)
        TriggerClientEvent("godz_factions:openMenu", source, {
            factionName = Config.Factions[factionId].name,
            members = members,
            factionId = factionId
        })
    else
        TriggerClientEvent("Notify", source, "negado", "Você não é líder de uma facção.", 5000)
    end
end)

RegisterServerEvent("godz_factions:hireMember")
AddEventHandler("godz_factions:hireMember", function(target_id)
    local source = source
    local user_id = vRP.getUserId(source)
    local factionId, isLeader = getPlayerFaction(user_id)

    if isLeader and target_id then
        local target_id = parseInt(target_id)
        local target_src = vRP.getUserSource(target_id)
        
        if target_src then
            vRP.addUserGroup(target_id, Config.Factions[factionId].memberGroup)
            TriggerClientEvent("Notify", source, "sucesso", "Membro contratado com sucesso!", 5000)
            TriggerClientEvent("Notify", target_src, "importante", "Você foi contratado para " .. Config.Factions[factionId].name, 5000)
            
            -- Refresh menu
            local members = getFactionMembers(factionId)
            TriggerClientEvent("godz_factions:updateMembers", source, members)
        else
            TriggerClientEvent("Notify", source, "negado", "Cidadão não encontrado ou offline.", 5000)
        end
    end
end)

RegisterServerEvent("godz_factions:fireMember")
AddEventHandler("godz_factions:fireMember", function(target_id)
    local source = source
    local user_id = vRP.getUserId(source)
    local factionId, isLeader = getPlayerFaction(user_id)

    if isLeader and target_id then
        local target_id = parseInt(target_id)
        
        -- Prevent firing self or other leaders (optional safety)
        if target_id == user_id then
            TriggerClientEvent("Notify", source, "negado", "Você não pode se demitir.", 5000)
            return
        end

        vRP.removeUserGroup(target_id, Config.Factions[factionId].memberGroup)
        vRP.removeUserGroup(target_id, Config.Factions[factionId].leaderGroup) -- Remove leader too just in case
        
        TriggerClientEvent("Notify", source, "sucesso", "Membro demitido com sucesso!", 5000)
        
        local target_src = vRP.getUserSource(target_id)
        if target_src then
            TriggerClientEvent("Notify", target_src, "aviso", "Você foi demitido de " .. Config.Factions[factionId].name, 5000)
        end

        -- Refresh menu
        local members = getFactionMembers(factionId)
        TriggerClientEvent("godz_factions:updateMembers", source, members)
    end
end)
