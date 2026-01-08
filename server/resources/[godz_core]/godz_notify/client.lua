
-- Export Function
function SendNotification(type, message, length)
    SendNUIMessage({
        action = "notify",
        type = type,
        message = message,
        length = length
    })
end

exports("SendNotification", SendNotification)

-- Event Handler (Server Call)
RegisterNetEvent("godz:notify")
AddEventHandler("godz:notify", function(type, message, length)
    SendNotification(type, message, length)
end)

-- Override Standard vRP Notify
RegisterNetEvent("Notify")
AddEventHandler("Notify", function(type, message)
    -- Map vRP types (sucesso, negado, aviso, importante) to GODZ types
    local map = {
        ["sucesso"] = "success",
        ["negado"] = "error",
        ["aviso"] = "warning",
        ["importante"] = "info"
    }
    
    local newType = map[type] or "info"
    SendNotification(newType, message, 5000)
end)
