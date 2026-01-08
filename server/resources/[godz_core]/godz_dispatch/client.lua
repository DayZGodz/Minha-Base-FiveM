
RegisterNetEvent("godz_dispatch:show")
AddEventHandler("godz_dispatch:show", function(data)
    -- Play sound
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", 1)
    
    -- Notification (HUD)
    local notifyType = "info"
    if data.priority == "Alta" then notifyType = "error" end
    if data.priority == "Média" then notifyType = "warning" end
    
    exports["godz_notify"]:SendNotification("ia_tip", "[DESPACHO IA] Prioridade: " .. data.priority .. "<br>" .. data.summary, 10000)

    -- Chat Message
    TriggerEvent("chat:addMessage", {
        template = '<div style="padding: 10px; margin: 5px 0; background-color: rgba(0, 0, 0, 0.6); border-left: 4px solid #D4AF37; border-radius: 5px;">' ..
                   '<b>[DESPACHO IA]</b> <span style="color: #D4AF37;">{0}</span><br>' ..
                   '<b>Prioridade:</b> {1}<br>' ..
                   '<b>Resumo:</b> {2}<br>' ..
                   '<b>Solicitante:</b> {3}</div>',
        args = { data.type, data.priority, data.summary, data.caller }
    })

    -- Add Blip (Optional, for 30s)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 1) -- Red
    if data.priority == "Alta" then SetBlipFlashes(blip, true) end
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Ocorrência: " .. data.summary)
    EndTextCommandSetBlipName(blip)

    Citizen.SetTimeout(30000, function()
        RemoveBlip(blip)
    end)
end)
