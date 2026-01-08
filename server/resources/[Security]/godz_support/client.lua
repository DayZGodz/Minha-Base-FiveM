
local isUiOpen = false

RegisterCommand(Config.Command, function()
    if not isUiOpen then
        OpenSupportUI()
    else
        CloseSupportUI()
    end
end)

if Config.Keybind then
    RegisterKeyMapping(Config.Command, 'Abrir Suporte GODZ', 'keyboard', Config.Keybind)
end

function OpenSupportUI()
    isUiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        categories = Config.Categories
    })
end

function CloseSupportUI()
    isUiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
end

RegisterNUICallback('close', function(data, cb)
    CloseSupportUI()
    cb('ok')
end)

RegisterNUICallback('submit', function(data, cb)
    TriggerServerEvent('godz_support:openTicket', data)
    cb('ok')
end)

RegisterNUICallback('resolveAI', function(data, cb)
    TriggerServerEvent('godz_support:aiResolved')
    cb('ok')
end)

RegisterNUICallback('escalateAI', function(data, cb)
    TriggerServerEvent('godz_support:escalateTicket')
    cb('ok')
end)

RegisterNetEvent('godz_support:showAIResponse')
AddEventHandler('godz_support:showAIResponse', function(text)
    SendNUIMessage({
        action = "aiResponse",
        text = text
    })
end)

RegisterNetEvent('godz_support:notify')
AddEventHandler('godz_support:notify', function(msg)
    -- Use GODZ Notify if available, else standard chat message
    TriggerEvent("Notify", "sucesso", msg) 
end)
