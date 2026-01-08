-- [GODZ CONNECT] Client Script para Gerenciamento de Foco e Transição
-- PROTOCOLO ANDROIDE 3D: NEXUS LIVE AVATAR

local nexusPed = nil
local nexusCam = nil
local lobbyCoords = vector3(3525.5, 3704.3, 21.0) -- Humane Labs Interior
local isCreator = false -- Variável de controle do Criador

Citizen.CreateThread(function()
    -- 1. SETUP DO LOBBY 3D
    DoScreenFadeOut(0)
    Wait(500)
    
    -- Carrega Modelos
    local model = GetHashKey("mp_f_freemode_01") -- Modelo Feminino Base
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    RequestAnimDict("mp_facial")
    while not HasAnimDictLoaded("mp_facial") do Wait(10) end

    RequestAnimDict("move_f@finesse")
    while not HasAnimDictLoaded("move_f@finesse") do Wait(10) end

    -- Teleporte do Player (Segurança)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z - 10.0)
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false, false)

    -- Criação do PED Nexus
    nexusPed = CreatePed(4, model, lobbyCoords.x, lobbyCoords.y, lobbyCoords.z, 180.0, false, true)
    SetEntityAlpha(nexusPed, 255, false)
    FreezeEntityPosition(nexusPed, true)
    SetEntityInvincible(nexusPed, true)
    SetBlockingOfNonTemporaryEvents(nexusPed, true)
    
    -- 4. ESTILIZAÇÃO PREMIUM (NEXUS ANDROID)
    
    -- Rosto e Pele (Impecável)
    SetPedHeadBlendData(nexusPed, 21, 21, 0, 21, 21, 0, 0.5, 0.5, 0.0, false) -- Face Simétrica
    
    -- Maquiagem e Detalhes
    SetPedHeadOverlay(nexusPed, 4, 1, 1.0) -- Maquiagem (Delineado)
    SetPedHeadOverlayColor(nexusPed, 4, 1, 0, 0) -- Cor Preta
    SetPedHeadOverlay(nexusPed, 0, 255, 0.0) -- Remove imperfeições (Blemishes)
    SetPedEyeColor(nexusPed, 1) -- Azul Brilhante

    -- Roupas (Branco e Dourado - Luxo)
    SetPedComponentVariation(nexusPed, 2, 20, 0, 2) -- Cabelo: Coque Elegante
    SetPedHairColor(nexusPed, 28, 33) -- Platinado

    SetPedComponentVariation(nexusPed, 3, 15, 0, 2) -- Torso/Braços: Pele Perfeita
    
    -- Uniforme Futurista (Tentativa de ID Luxo - Ajuste conforme base)
    SetPedComponentVariation(nexusPed, 11, 285, 1, 2) -- Top: Blazer Formal (Variação Branca)
    SetPedComponentVariation(nexusPed, 8, 15, 0, 2)   -- Undershirt
    SetPedComponentVariation(nexusPed, 4, 108, 1, 2)  -- Calça Social (Branca)
    SetPedComponentVariation(nexusPed, 6, 29, 0, 2)   -- Sapatos: Salto Alto

    -- VFX: Iluminação de Estúdio & Olhar
    Citizen.CreateThread(function()
        while DoesEntityExist(nexusPed) do
            -- Luz Frontal (Branca/Dourada - Highlight)
            DrawLightWithRange(lobbyCoords.x, lobbyCoords.y + 1.0, lobbyCoords.z + 1.8, 255, 245, 220, 3.0, 10.0)
            
            -- Luz de Contorno (Dourado Real para Criador, Azul Cyber padrão)
            if isCreator then
                DrawLightWithRange(lobbyCoords.x, lobbyCoords.y - 1.5, lobbyCoords.z + 1.0, 255, 215, 0, 4.0, 5.0) -- Gold
            else
                DrawLightWithRange(lobbyCoords.x, lobbyCoords.y - 1.5, lobbyCoords.z + 1.0, 0, 229, 255, 2.0, 3.0) -- Cyber Blue
            end
            
            -- Nexus sempre olha para a câmera
            TaskLookAtCoord(nexusPed, lobbyCoords.x, lobbyCoords.y + 1.5, lobbyCoords.z + 1.6, 2000, 2048, 3)
            Wait(0)
        end
    end)

    -- Animação de Postura Elegante
    TaskPlayAnim(nexusPed, "move_f@finesse", "idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Pré-carrega animação de despedida
    RequestAnimDict("anim@mp_player_intcelebrationfemale@bow")
    while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@bow") do Wait(10) end

    RequestAnimDict("anim@mp_player_intcelebrationfemale@salute")
    while not HasAnimDictLoaded("anim@mp_player_intcelebrationfemale@salute") do Wait(10) end
    
    -- Configuração da Câmera (Retrato 35mm)   nexusCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    -- Posiciona a câmera focada no rosto/busto
    SetCamCoord(nexusCam, lobbyCoords.x, lobbyCoords.y + 1.2, lobbyCoords.z + 1.6) 
    PointCamAtPedBone(nexusCam, nexusPed, 31086, 0.0, 0.0, 0.0) -- Foca na Cabeça (Bone 31086)
    SetCamActive(nexusCam, true)
    RenderScriptCams(true, false, 0, true, true)
    
    -- Atmosfera
    SetTimecycleModifier("prologue_ending_fog")
    
    Wait(1000)
    DoScreenFadeIn(2000)
    
    -- Ativa o foco do mouse para UI
    SetNuiFocus(true, true)
end)

-- 2. SINCRONIA LABIAL (NUI CALLBACKS)
RegisterNUICallback('startLipSync', function(data, cb)
    if nexusPed and DoesEntityExist(nexusPed) then
        -- Animação facial de fala genérica
        PlayFacialAnim(nexusPed, "mic_chatter", "mp_facial")
    end
    cb('ok')
end)

RegisterNUICallback('stopLipSync', function(data, cb)
    if nexusPed and DoesEntityExist(nexusPed) then
        -- Para animação ou volta ao neutro
        PlayFacialAnim(nexusPed, "mood_normal_1", "facials@gen_male@variations@normal")
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
    -- Gesto de Finalização (Despedida da Nexus)
    if nexusPed and DoesEntityExist(nexusPed) then
        if isCreator then
            -- PROTOCOLO CRIADOR: Continência/Respeito Máximo
            TaskPlayAnim(nexusPed, "anim@mp_player_intcelebrationfemale@salute", "salute", 8.0, -8.0, 3000, 0, 0, false, false, false)
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
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(nexusCam, false) 
    end
    
    ClearTimecycleModifier()
    
    -- Restaura Player
    local playerPed = PlayerPedId()
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

RegisterNetEvent("godz_connect:setCreatorMode")
AddEventHandler("godz_connect:setCreatorMode", function(status, name)
    isCreator = status
    SendNUIMessage({
        eventName = 'setCreatorMode',
        action = 'setupIdentity', -- Compatibility
        isCreator = isCreator,
        playerName = name,
        name = name -- Compatibility
    })
end)
