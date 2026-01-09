-- [GODZ CONNECT] Client Script para Gerenciamento de Foco e Transição
-- PROTOCOLO ANDROIDE 3D: NEXUS LIVE AVATAR

local nexusPed = nil
local nexusCam = nil
local lobbyCoords = vector3(3525.5, 3704.3, 21.0) -- Humane Labs Interior
local isCreator = false -- Variável de controle do Criador
local isWhitelistedClient = false -- [GODZ] Status WL para gating
local currentToken = nil -- [GODZ] Token de validação dinâmica
local introCompleted = false

-- [GODZ] Force Shutdown Loading Screen ASAP
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    DisplayRadar(false)
    Wait(0)
    DoScreenFadeIn(500)
end)

function StartGameSequence()
    -- 1. Garante que NUI e Loading Screen sumam
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    SetNuiFocus(false, false)

    -- 2. Animação da Nexus (Simples/Rápida)
    if nexusPed and DoesEntityExist(nexusPed) then
        if isCreator then
            -- Reverência rápida
            TaskPlayAnim(nexusPed, "anim@mp_player_intcelebrationfemale@bow", "bow", 8.0, -8.0, 1500, 0, 0, false, false, false)
            Wait(1500)
        else
            -- Reverência Padrão
            TaskPlayAnim(nexusPed, "anim@mp_player_intcelebrationfemale@bow", "bow", 8.0, -8.0, 2000, 0, 0, false, false, false)
            Wait(2000)
        end
    end

    -- 3. Transição de Tela
    DoScreenFadeOut(500)
    Wait(500)

    -- 4. Limpeza de Entidades
    if nexusPed and DoesEntityExist(nexusPed) then 
        DeleteEntity(nexusPed) 
    end
    
    if nexusCam then 
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(nexusCam, false) 
    end
    
    ClearTimecycleModifier()
    
    -- 5. Teleporte do Player para Legion Square
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, -205.5, -1011.5, 30.0)
    SetEntityHeading(playerPed, 320.0)
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true, false)
    
    -- 6. Inicia Identidade (Bypass NUI se godz_identity tiver suporte, senão mostra seleção)
    TriggerEvent("godz_identity:showSelection")
    
    Wait(500)
    DoScreenFadeIn(1000)
    DisplayRadar(true)
end

Citizen.CreateThread(function()
    -- 1. SETUP DO LOBBY 3D
    DisplayRadar(false)
    
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z - 10.0)
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)

    -- Carrega Modelos
    local model = GetHashKey("mp_f_freemode_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    RequestAnimDict("mp_facial")
    while not HasAnimDictLoaded("mp_facial") do Wait(10) end

    RequestAnimDict("move_f@finesse")
    while not HasAnimDictLoaded("move_f@finesse") do Wait(10) end

    RequestAnimDict("anim@mp_player_intcelebrationfemale@bow")
    while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@bow") do Wait(10) end

    -- Cria Nexus
    nexusPed = CreatePed(4, model, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z, 180.0, false, true)
    SetEntityAlpha(nexusPed, 255, false)
    FreezeEntityPosition(nexusPed, true)
    SetEntityInvincible(nexusPed, true)
    SetBlockingOfNonTemporaryEvents(nexusPed, true)
    SetEntityAsMissionEntity(nexusPed, true, true)
    
    -- Estilização (Simplificada para garantir execução)
    SetPedHeadBlendData(nexusPed, 21, 21, 0, 21, 21, 0, 0.5, 0.5, 0.0, false)
    SetPedComponentVariation(nexusPed, 2, 20, 0, 2) -- Cabelo
    SetPedComponentVariation(nexusPed, 11, 306, 0, 2) -- Top
    SetPedComponentVariation(nexusPed, 4, 121, 0, 2) -- Calça
    SetPedComponentVariation(nexusPed, 6, 90, 0, 2) -- Sapatos

    -- Iluminação e Olhar
    Citizen.CreateThread(function()
        while DoesEntityExist(nexusPed) do
            DrawLightWithRange(lobbyCoords.x, lobbyCoords.y + 1.0, lobbyCoords.z + 1.8, 0, 200, 255, 4.0, 10.0)
            TaskLookAtCoord(nexusPed, lobbyCoords.x, lobbyCoords.y + 1.5, lobbyCoords.z + 1.6, 2000, 2048, 3)
            Wait(0)
        end
    end)

    -- Animação Idle
    TaskPlayAnim(nexusPed, "move_f@finesse", "idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Câmera
    nexusCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(nexusCam, lobbyCoords.x, lobbyCoords.y + 1.5, lobbyCoords.z + 1.6) 
    PointCamAtPedBone(nexusCam, nexusPed, 31086, 0.0, 0.0, 0.0)
    SetCamFov(nexusCam, 50.0)
    SetCamActive(nexusCam, true)
    RenderScriptCams(true, false, 0, true, true)
    
    SetTimecycleModifier("prologue_ending_fog")
    
    Wait(500)
    DoScreenFadeIn(1000)
    
    -- Check Status no Server
    TriggerServerEvent("godz_connect:checkPlayerStatus")
end)

RegisterNetEvent("godz_connect:receiveStatus")
AddEventHandler("godz_connect:receiveStatus", function(status)
    isCreator = status.isCreator
    isWhitelistedClient = status.isWhitelisted
    currentToken = status.token
    
    if isWhitelistedClient or isCreator then
        -- Se estiver na WL, inicia sequência de jogo
        PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
        
        -- [GODZ] Nexus Awakening Protocol
        -- Instead of starting immediately, we trigger the intro sequence
        SendNUIMessage({ 
            action = "startIntro", 
            playerName = status.playerName,
            isCreator = isCreator
        })
    else
        -- Acesso Negado (Nativo)
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~r~ACESSO NEGADO: VOCÊ NÃO ESTÁ NA WHITELIST.")
        DrawNotification(false, true)
    end
end)

-- Fallback de Segurança (Force Spawn se travar em 3% ou NUI falhar)
Citizen.CreateThread(function()
    Wait(90000)
    
    -- Verifica se o jogador ainda não spawnou (ainda está no lobby ou loading)
    if not introCompleted and (nexusPed or GetIsLoadingScreenActive()) then
        print("[GODZ CONNECT] Force Spawn Activated due to timeout.")
        
        -- Garante que o loading morra
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        
        -- Força a sequência de jogo
        StartGameSequence()
    end
end)

-- [GODZ] Voice Interaction Trigger (Key E)
RegisterKeyMapping('godz_ai_talk', 'Falar com Nexus AI', 'keyboard', 'E')

RegisterCommand('godz_ai_talk', function()
    -- Only allow if 3D sequence is active or explicitly allowed
    if not GetIsLoadingScreenActive() then
        SendNUIMessage({ action = "toggleVoice" })
        -- Visual feedback
        local playerPed = PlayerPedId()
        RequestAnimDict("mp_facial")
        while not HasAnimDictLoaded("mp_facial") do Wait(0) end
        PlayFacialAnim(playerPed, "mic_chatter", "mp_facial")
    end
end)

-- [GODZ] Callback when Nexus finishes introduction
RegisterNUICallback('introFinished', function(data, cb)
    introCompleted = true
    StartGameSequence()
    if cb then cb('OK') end
end)
