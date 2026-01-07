local isPhoneOpen = false

-- Abrir/Fechar Celular
RegisterCommand("godphone", function()
    TogglePhone()
end)

RegisterKeyMapping("godphone", "Abrir God-Phone", "keyboard", "F1")

function TogglePhone()
    isPhoneOpen = not isPhoneOpen
    SetNuiFocus(isPhoneOpen, isPhoneOpen)
    SendNUIMessage({
        type = "toggle",
        status = isPhoneOpen
    })
    
    if isPhoneOpen then
        TriggerServerEvent("godz_phone:getContacts")
        -- TriggerServerEvent("godz_phone:getMessages")
    end
end

-- Callbacks NUI

RegisterNUICallback("close", function(data, cb)
    TogglePhone()
    cb("ok")
end)

RegisterNUICallback("askAI", function(data, cb)
    TriggerServerEvent("godz_phone:askAI", data.question)
    cb("sent")
end)

RegisterNUICallback("addContact", function(data, cb)
    TriggerServerEvent("godz_phone:addContact", data.name, data.number)
    cb("ok")
end)

-- Eventos do Servidor

RegisterNetEvent("godz_phone:receiveAIResponse")
AddEventHandler("godz_phone:receiveAIResponse", function(response)
    SendNUIMessage({
        type = "aiResponse",
        text = response
    })
end)

RegisterNetEvent("godz_phone:receiveContacts")
AddEventHandler("godz_phone:receiveContacts", function(contacts)
    SendNUIMessage({
        type = "updateContacts",
        data = contacts
    })
end)
