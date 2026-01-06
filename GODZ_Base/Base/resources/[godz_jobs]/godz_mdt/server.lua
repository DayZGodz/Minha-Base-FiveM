local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local src = {}
Tunnel.bindInterface("godz_mdt", src)

-- Prepare Queries
MySQL.ready(function()
    -- Vehicles (Assuming standard vRP table, if different, adjust here)
    MySQL.createCommand("godz_mdt/get_vehicles", "SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
    -- Warrants
    MySQL.createCommand("godz_mdt/get_warrants", "SELECT * FROM godz_mdt_warrants WHERE status = 'active'")
    MySQL.createCommand("godz_mdt/add_warrant", "INSERT INTO godz_mdt_warrants (user_id, reason, author_id) VALUES (@user_id, @reason, @author_id)")
    MySQL.createCommand("godz_mdt/delete_warrant", "UPDATE godz_mdt_warrants SET status = 'served' WHERE id = @id")
    MySQL.createCommand("godz_mdt/get_user_warrants", "SELECT * FROM godz_mdt_warrants WHERE user_id = @user_id AND status = 'active'")
end)

function src.checkPermission()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        return vRP.hasPermission(user_id, "policia.permissao")
    end
    return false
end

function src.searchUser(query)
    local source = source
    local user_id = vRP.getUserId(source)
    if not vRP.hasPermission(user_id, "policia.permissao") then return false end

    local target_id = parseInt(query)
    if target_id > 0 then
        -- Search by ID
        local identity = vRP.getUserIdentity(target_id)
        if identity then
            return src.getUserDetails(target_id)
        else
            return nil
        end
    else
        -- Search by Name (Not implemented in standard vRP easily without custom query, defaulting to ID search only for now or simple query)
        -- We will assume ID search is primary. 
        return nil
    end
end

function src.getUserDetails(target_id)
    local identity = vRP.getUserIdentity(target_id)
    if not identity then return nil end

    -- Bank Data
    local bank = vRP.getBankMoney(target_id)
    local bank_logs = MySQL.Sync.fetchAll("SELECT * FROM godz_bank_logs WHERE sender_id = @user_id OR receiver_id = @user_id ORDER BY date DESC LIMIT 5", { ['@user_id'] = target_id })

    -- Vehicles
    local vehicles = MySQL.Sync.fetchAll("godz_mdt/get_vehicles", { ['@user_id'] = target_id })

    -- Warrants
    local warrants = MySQL.Sync.fetchAll("godz_mdt/get_user_warrants", { ['@user_id'] = target_id })

    return {
        id = target_id,
        name = identity.name,
        firstname = identity.firstname,
        age = identity.age,
        phone = identity.phone,
        registration = identity.registration,
        foto = identity.foto or "https://i.imgur.com/r7x6y7v.png", -- Default photo if nil
        bank = bank,
        bank_logs = bank_logs,
        vehicles = vehicles,
        warrants = warrants
    }
end

function src.getAllWarrants()
    return MySQL.Sync.fetchAll("godz_mdt/get_warrants", {})
end

function src.createWarrant(target_id, reason)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "policia.permissao") then
        MySQL.Async.execute("godz_mdt/add_warrant", {
            ['@user_id'] = target_id,
            ['@reason'] = reason,
            ['@author_id'] = user_id
        })
        -- Notify all police?
        return true
    end
    return false
end

function src.deleteWarrant(id)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "policia.permissao") then
        MySQL.Async.execute("godz_mdt/delete_warrant", { ['@id'] = id })
        return true
    end
    return false
end

function src.applyFine(target_id, amount, reason)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "policia.permissao") then
        local target_source = vRP.getUserSource(target_id)
        
        -- Deduct from bank
        vRP.setBankMoney(target_id, vRP.getBankMoney(target_id) - parseInt(amount))
        
        -- Log to bank
        MySQL.Async.execute("INSERT INTO godz_bank_logs (sender_id, receiver_id, type, value) VALUES (@sender_id, @receiver_id, @type, @value)", {
            ['@sender_id'] = target_id,
            ['@receiver_id'] = 0, -- State/System
            ['@type'] = "Multa: "..reason,
            ['@value'] = amount
        })

        TriggerClientEvent("godz:notify", source, "success", "Multa aplicada com sucesso.", 5000)
        if target_source then
            TriggerClientEvent("godz:notify", target_source, "error", "Você foi multado em $"..vRP.format(parseInt(amount)).." por "..reason, 10000)
        end
        return true
    end
    return false
end
