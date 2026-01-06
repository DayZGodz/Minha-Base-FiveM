local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("godz_ems", src)
vRPems = Tunnel.getInterface("godz_ems")

local Cfg = module("godz_ems", "config")

-- Helper for Blood Type
local bloodTypes = {"A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"}
function getBloodType(user_id)
    local idx = (user_id % #bloodTypes) + 1
    return bloodTypes[idx]
end

function src.checkPermission()
    local source = source
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, Cfg.Permission)
end

function src.searchPatient(target_id)
    local source = source
    local user_id = vRP.getUserId(source)
    
    if not vRP.hasPermission(user_id, Cfg.Permission) then return false end
    
    local nuser_id = parseInt(target_id)
    if nuser_id > 0 then
        local identity = vRP.getUserIdentity(nuser_id)
        if identity then
            -- Get History
            local history = vRP.query("godz_ems/get_history", {user_id = nuser_id})
            
            return {
                name = identity.name .. " " .. identity.firstname,
                age = identity.age,
                blood_type = getBloodType(nuser_id),
                history = history or {}
            }
        end
    end
    return nil
end

function src.finishTreatment(target_id)
    local source = source
    local user_id = vRP.getUserId(source)
    local nuser_id = parseInt(target_id)
    
    if vRP.hasPermission(user_id, Cfg.Permission) then
        if vRP.tryFullPayment(nuser_id, Cfg.TreatmentPrice) then
            -- Log History
            vRP.execute("godz_ems/add_history", {
                user_id = nuser_id,
                medic_id = user_id,
                action = "Tratamento Hospitalar",
                notes = "Tratamento completo realizado."
            })
            
            -- Log Discord
            local identity = vRP.getUserIdentity(nuser_id)
            local medic_identity = vRP.getUserIdentity(user_id)
            exports["godz_logs"]:createLog(user_id, "ems_treatment", "Médico: " .. medic_identity.name .. " tratou Paciente: " .. identity.name .. " | Valor: $" .. Cfg.TreatmentPrice)
            
            TriggerClientEvent("godz_notify:notify", source, "sucesso", "Tratamento", "Paciente tratado com sucesso. Recebido: $"..Cfg.TreatmentPrice)
            TriggerClientEvent("godz_notify:notify", vRP.getUserSource(nuser_id), "info", "Hospital", "Você recebeu alta e pagou $"..Cfg.TreatmentPrice)
            return true
        else
            TriggerClientEvent("godz_notify:notify", source, "erro", "Erro", "Paciente não possui dinheiro suficiente.")
            return false
        end
    end
    return false
end

-- Prepare Queries
Citizen.CreateThread(function()
    vRP.prepare("godz_ems/get_history", "SELECT * FROM godz_ems_history WHERE user_id = @user_id ORDER BY date DESC LIMIT 10")
    vRP.prepare("godz_ems/add_history", "INSERT INTO godz_ems_history(user_id, medic_id, action, notes) VALUES(@user_id, @medic_id, @action, @notes)")
end)
