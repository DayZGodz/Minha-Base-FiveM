

local isMenuOpen = false

RegisterNetEvent("godz_admin:open")
AddEventHandler("godz_admin:open", function(data)
    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "OPEN",
        players = data.players,
        multiplier = data.multiplier,
        alerts = data.alerts
    })
end)

RegisterNetEvent("godz_admin:receiveReport")
AddEventHandler("godz_admin:receiveReport", function(report)
    if isMenuOpen then
        SendNUIMessage({
            type = "AI_REPORT",
            report = report
        })
    end
end)

RegisterNetEvent("godz_admin:newAlert")
AddEventHandler("godz_admin:newAlert", function(alert)
    if isMenuOpen then
        SendNUIMessage({
            type = "NEW_ALERT",
            alert = alert
        })
    else
        -- Optional: Notification if menu is closed
        TriggerEvent("Notify", "aviso", "GODZ SHIELD: Alerta de " .. alert.type)
    end
end)

RegisterNUICallback("close", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("analyzePlayer", function(data, cb)
    if data.user_id then
        TriggerServerEvent("godz_admin:analyzePlayer", data.user_id)
    end
    cb("ok")
end)

RegisterNUICallback("action", function(data, cb)
    TriggerServerEvent("godz_admin:action", data)
    cb("ok")
end)
