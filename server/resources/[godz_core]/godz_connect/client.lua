-- [GODZ CONNECT] Client Script para Gerenciamento de Foco e Transição
-- PROTOCOLO ANDROIDE 3D: NEXUS LIVE AVATAR

local nexusPed = nil
local nexusCam = nil
local lobbyCoords = vector3(3525.5, 3704.3, 21.0) -- Humane Labs Interior
local isCreator = false -- Variável de controle do Criador
local speechDone = false -- [GODZ] Controle de sincronia da fala
local isWhitelistedClient = false -- [GODZ] Status WL para gating

local currentToken = nil -- [GODZ] Token de validação dinâmica

-- [GODZ] Force Shutdown Loading Screen ASAP for Transparent Overlay
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    -- [GODZ] REMOVED DoScreenFadeOut(0) to prevent black screen
    DisplayRadar(false) -- [GODZ] Disable Radar Immediately
    Wait(0) -- [GODZ] Instant Transition
    DoScreenFadeIn(500) -- [GODZ] Quick Fade In
end)

Citizen.CreateThread(function()
    -- 1. SETUP DO LOBBY 3D (PRIORIDADE MÁXIMA)
    DisplayRadar(false)
    -- [GODZ] REMOVED DoScreenFadeOut(0)
    
    -- Teleporte do Player (Segurança Imediata)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z - 10.0)
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)

    -- Carrega Modelos
    local model = GetHashKey("mp_f_freemode_01") -- Modelo Feminino Base
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    RequestAnimDict("mp_facial")
    while not HasAnimDictLoaded("mp_facial") do Wait(10) end

    RequestAnimDict("move_f@finesse")
    while not HasAnimDictLoaded("move_f@finesse") do Wait(10) end

    -- [GODZ] Carrega Dicionários de Animação Extras
    RequestAnimDict("amb@world_human_hanging_out@female_a@idle_a")
    while not HasAnimDictLoaded("amb@world_human_hanging_out@female_a@idle_a") do Wait(10) end

    RequestAnimDict("anim@heists@prison_heiststation@cop_reactions")
    while not HasAnimDictLoaded("anim@heists@prison_heiststation@cop_reactions") do Wait(10) end

    RequestAnimDict("anim@mp_player_intcelebrationfemale@salute")
    while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@salute") do Wait(10) end

    -- Teleporte do Player (Segurança)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z - 10.0)
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)

    -- 3. CRIAÇÃO DA NEXUS (ENTIDADE 0 - LOCAL)
    nexusPed = CreatePed(4, model, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z, 180.0, false, true)
    SetEntityAlpha(nexusPed, 255, false)
    FreezeEntityPosition(nexusPed, true)
    SetEntityInvincible(nexusPed, true)
    SetBlockingOfNonTemporaryEvents(nexusPed, true)
    
    -- Configuração de Entidade 0 (Conceitual)
    SetEntityAsMissionEntity(nexusPed, true, true) 
    
    -- 4. ESTILIZAÇÃO PREMIUM (NEXUS ANDROID - SPACE RANGER)
    
    -- Rosto e Pele (Sintética)
    SetPedHeadBlendData(nexusPed, 21, 21, 0, 21, 21, 0, 0.5, 0.5, 0.0, false)
    
    -- Maquiagem Cyber
    SetPedHeadOverlay(nexusPed, 4, 1, 1.0) -- Maquiagem
    SetPedHeadOverlayColor(nexusPed, 4, 1, 0, 0)
    SetPedEyeColor(nexusPed, 7) -- Olhos Brancos/Cinza (Artificial)

    -- Roupas (Space Ranger / Android Platinum)
    SetPedComponentVariation(nexusPed, 2, 20, 0, 2) -- Cabelo: Coque/Sleek
    SetPedHairColor(nexusPed, 28, 33) -- Platinado Metálico

    SetPedComponentVariation(nexusPed, 3, 15, 0, 2) -- Mãos (Luvas invisíveis ou pele)
    
    -- Uniforme Tático-Futurista (Arena War / Deadline Style)
    SetPedComponentVariation(nexusPed, 11, 306, 0, 2) -- Top: Bodysuit Futurista
    SetPedComponentVariation(nexusPed, 8, 15, 0, 2)   -- Undershirt (Vazio)
    SetPedComponentVariation(nexusPed, 4, 121, 0, 2)  -- Calça: Bodysuit Legs
    SetPedComponentVariation(nexusPed, 6, 90, 0, 2)   -- Sapatos: Botas Sci-Fi

    -- VFX: Iluminação Cinematográfica (Humane Labs)
    Citizen.CreateThread(function()
        while DoesEntityExist(nexusPed) do
            -- Luz Ambiente (Azul Neon / Cyberpunk)
            DrawLightWithRange(lobbyCoords.x, lobbyCoords.y + 1.0, lobbyCoords.z + 1.8, 0, 200, 255, 4.0, 10.0)
            
            -- Luz de Recorte (Dourada para Contraste)
            DrawLightWithRange(lobbyCoords.x, lobbyCoords.y - 1.5, lobbyCoords.z + 1.0, 255, 215, 0, 2.0, 5.0)
            
            -- Nexus sempre olha para a câmera
            TaskLookAtCoord(nexusPed, lobbyCoords.x, lobbyCoords.y + 1.5, lobbyCoords.z + 1.6, 2000, 2048, 3)
            Wait(0)
        end
    end)

    -- Animação de Postura Robótica/Elegante
    TaskPlayAnim(nexusPed, "move_f@finesse", "idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Pré-carrega animação de despedida
    RequestAnimDict("anim@mp_player_intcelebrationfemale@bow")
    while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@bow") do Wait(10) end

    RequestAnimDict("anim@mp_player_intcelebrationfemale@salute")
    while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@salute") do Wait(10) end
    
    -- Configuração da Câmera (Cinematográfica)
    if DoesCamExist(nexusCam) then
        SetCamCoord(nexusCam, lobbyCoords.x, lobbyCoords.y + 1.5, lobbyCoords.z + 1.6) 
        if nexusPed and DoesEntityExist(nexusPed) then
            PointCamAtPedBone(nexusCam, nexusPed, 31086, 0.0, 0.0, 0.0)
        end
        SetCamFov(nexusCam, 50.0)
        SetCamActive(nexusCam, true)
        RenderScriptCams(true, false, 0, true, true)
    end
    
    -- Atmosfera
    SetTimecycleModifier("prologue_ending_fog")
    
    Wait(1000)
    DoScreenFadeIn(2000)
    
    SetNuiFocus(true, true)
    TriggerServerEvent("godz_connect:checkPlayerStatus")
end)

-- 2. SINCRONIA LABIAL (NUI CALLBACKS)
RegisterNUICallback('startLipSync', function(data, cb)
    if nexusPed and DoesEntityExist(nexusPed) then
        -- Animação facial de fala genérica
        PlayFacialAnim(nexusPed, "mic_chatter", "mp_facial")
        -- [GODZ] Animação de corpo (Fala autoritária)
        TaskPlayAnim(nexusPed, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    cb('ok')
end)

RegisterNUICallback('stopLipSync', function(data, cb)
    if nexusPed and DoesEntityExist(nexusPed) then
        -- Para animação ou volta ao neutro
        PlayFacialAnim(nexusPed, "mood_normal_1", "facials@gen_male@variations@normal")
        -- Volta para idle
        TaskPlayAnim(nexusPed, "move_f@finesse", "idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    cb('ok')
end)

RegisterNUICallback('startBioScan', function(data, cb)
    if nexusPed and DoesEntityExist(nexusPed) then
        Citizen.CreateThread(function()
            local startTime = GetGameTimer()
            local duration = 3000 -- Duração do Scan (Sincronizado com a fala)
            local startZ = lobbyCoords.z + 1.8 -- Cabeça
            local endZ = lobbyCoords.z - 0.9 -- Pés
            
            while (GetGameTimer() - startTime) < duration do
                local progress = (GetGameTimer() - startTime) / duration
                local currentZ = startZ - (progress * (startZ - endZ))
                
                -- Luz de Scan (Azul Ciano Tecnológico - Spotlight Simulado)
                -- Posicionada levemente à frente do PED para iluminar o rosto/corpo de cima a baixo
                DrawLightWithRange(lobbyCoords.x, lobbyCoords.y + 0.8, currentZ, 0, 255, 255, 2.5, 5.0)
                
                Wait(0)
            end
        end)
    end
    cb('ok')
end)

-- 3. TRANSIÇÃO E LIMPEZA
AddEventHandler('playerSpawned', function()
    -- [GODZ] NUI Cleanup (Overlay Fix)
    SendNUIMessage({ action = "hide" })

    -- [GODZ] Removido wait de sincronia de fala para evitar travamento em 3%
    -- A fala pode continuar em background ou ser cortada, prioridade é o spawn.
    
    -- Se não possuir WL, mantém a Nexus e bloqueia o jogador
    if not isWhitelistedClient then
        SetNuiFocus(true, true)
        -- Solicita exibição de bloqueio com token via NUI
        SendNUIMessage({ action = 'openBlockCode', token = currentToken or 'GZ-0000' })
        return
    end

    -- Gesto de Finalização (Despedida da Nexus)
    if nexusPed and DoesEntityExist(nexusPed) then
        if isCreator then
            -- PROTOCOLO CRIADOR: Continência/Respeito Máximo
            playNexusAnimation("ACCESS_GRANTED")
            Wait(2000) -- Transição mais rápida para o chefe
        else
            -- Reverência Elegante (Padrão)
            TaskPlayAnim(nexusPed, "anim@mp_player_intcelebrationfemale@bow", "bow", 8.0, -8.0, 3000, 0, 0, false, false, false)
            Wait(3000)
        end
    end

    -- Fade Out Dramático (Transição)
    if isCreator then
        DoScreenFadeOut(500) -- Fade rápido para ID 1
        Wait(500)
    else
        DoScreenFadeOut(1500)
        Wait(1500)
    end

    -- Fecha Loading Screen Manualmente
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    
    -- Remove Foco Temporariamente
    SetNuiFocus(false, false)
    
    -- Limpeza do Cenário 3D
    if nexusPed and DoesEntityExist(nexusPed) then 
        DeleteEntity(nexusPed) 
    end
    
    if nexusCam then 
        -- [GODZ] Transição Suave de Câmera (Interpolation)
        RenderScriptCams(false, true, 3000, true, true)
        DestroyCam(nexusCam, false) 
    end
    
    ClearTimecycleModifier()
    
    -- Restaura Player e Define Spawn Inicial (Legion Square)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, -205.5, -1011.5, 30.0) -- Legion Square
    SetEntityHeading(playerPed, 320.0)
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true, false)
    
    -- Força a transição para a Identidade
    TriggerEvent("godz_identity:showSelection")
end)

-- Evento opcional para remover foco explicitamente se necessário
RegisterNetEvent("godz_connect:releaseFocus")
AddEventHandler("godz_connect:releaseFocus", function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent("godz_connect:receiveStatus")
AddEventHandler("godz_connect:receiveStatus", function(status)
    isCreator = status.isCreator
    isWhitelistedClient = status.isWhitelisted
    currentToken = status.token
    SendNUIMessage({
        eventName = 'receiveStatus',
        action = 'setupIdentity', -- Keeps compatibility if needed
        isCreator = status.isCreator,
        playerName = status.playerName,
        isWhitelisted = status.isWhitelisted,
        hasIdentity = status.hasIdentity,
        token = status.token
    })
end)

-- Fallback: Força entrada do ID 1 após 10s se ainda na Loading Screen
Citizen.CreateThread(function()
    Wait(10000)
    if isCreator then
        SendNUIMessage({ action = "close" })
        SetNuiFocus(false, false)
        TriggerEvent("godz_identity:showSelection")
    end
end)
