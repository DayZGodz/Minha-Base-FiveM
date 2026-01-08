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

-- Input de Voz / Atalho Rápido para IA
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isPhoneOpen then
            -- Tecla E (38) para abrir IA rapidamente ou ativar voz
            if IsControlJustPressed(0, 38) then
                SendNUIMessage({
                    type = "openAI"
                })
            end
        end
    end
end)

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
AddEventHandler("godz_phone:receiveAIResponse", function(response, audio)
    SendNUIMessage({
        type = "aiResponse",
        text = response,
        audio = audio
    })
end)

RegisterNetEvent("godz_phone:receiveContacts")
AddEventHandler("godz_phone:receiveContacts", function(contacts)
    SendNUIMessage({
        type = "updateContacts",
        data = contacts
    })
end)
