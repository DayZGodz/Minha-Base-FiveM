-- [GODZ CONNECT] Client Script para Gerenciamento de Foco e Transição
Citizen.CreateThread(function()
    -- Ativa o foco do mouse assim que o script inicia (durante/após loading)
    -- Isso permite clicar no microfone da Loading Screen
    SetNuiFocus(true, true)
end)

-- Listener para remover foco e transicionar quando o player spawnar
AddEventHandler('playerSpawned', function()
    -- Fecha Loading Screen Manualmente (caso fxmanifest tenha manual_shutdown)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    
    -- Remove Foco Temporariamente
    SetNuiFocus(false, false)
    
    -- Força a transição para a Identidade
    TriggerEvent("godz_identity:showSelection")
end)

-- Evento opcional para remover foco explicitamente se necessário
RegisterNetEvent("godz_connect:releaseFocus")
AddEventHandler("godz_connect:releaseFocus", function()
    SetNuiFocus(false, false)
end)