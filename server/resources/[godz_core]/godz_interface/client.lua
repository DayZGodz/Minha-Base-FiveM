local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local hunger = 0
local thirst = 0
local lastHealth = -1
local lastArmour = -1
local lastHunger = -1
local lastThirst = -1

-- Recebe atualização de fome/sede do vRP
RegisterNetEvent("statusFome")
AddEventHandler("statusFome", function(h, t)
    hunger = h
    thirst = t
end)

RegisterNetEvent("statusSede")
AddEventHandler("statusSede", function(h, t)
    hunger = h
    thirst = t
end)

-- Loop principal de HUD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200) -- 5fps update rate is enough for bars

        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local armour = GetPedArmour(ped)

        -- Normalização (Assumindo MaxHealth = 200, 100 = morto para MP Peds, ou 0 = morto)
        -- Ajuste comum: (Health - 100) para MP peds onde 100 é o mínimo
        -- Mas vamos garantir que não fique negativo
        local healthPercent = health - 100
        if healthPercent < 0 then healthPercent = 0 end
        if healthPercent > 100 then healthPercent = 100 end
        
        -- vRP hunger/thirst: 0 = full, 100 = empty.
        -- HUD usually shows FILL level. So we invert.
        local hungerPercent = 100 - hunger
        local thirstPercent = 100 - thirst
        if hungerPercent < 0 then hungerPercent = 0 end
        if thirstPercent < 0 then thirstPercent = 0 end
        
        -- Send only if changed
        if healthPercent ~= lastHealth or armour ~= lastArmour or hungerPercent ~= lastHunger or thirstPercent ~= lastThirst then
            SendNUIMessage({
                action = "updateHUD",
                health = healthPercent,
                armour = armour,
                hunger = hungerPercent,
                thirst = thirstPercent
            })
            lastHealth = healthPercent
            lastArmour = armour
            lastHunger = hungerPercent
            lastThirst = thirstPercent
        end
    end
end)

-- Notify
RegisterNetEvent("godz_interface:Notify")
AddEventHandler("godz_interface:Notify", function(type, title, message, duration)
    SendNUIMessage({
        action = "notify",
        type = type,
        title = title,
        message = message,
        duration = duration or 5000
    })
end)

-- Override vRP Notify
RegisterNetEvent("Notify")
AddEventHandler("Notify", function(type, message)
    -- Map vRP types to our types
    -- vRP: sucesso, negado, importante, aviso
    local title = "NOTIFICAÇÃO"
    local cssType = "aviso"

    if type == "sucesso" then
        title = "SUCESSO"
        cssType = "sucesso"
    elseif type == "negado" or type == "erro" then
        title = "ERRO"
        cssType = "erro"
    elseif type == "importante" or type == "aviso" then
        title = "IMPORTANTE"
        cssType = "aviso"
    elseif type == "ia_tip" then
        title = "DICA INTELIGENTE"
        cssType = "ia_tip"
    end

    SendNUIMessage({
        action = "notify",
        type = cssType,
        title = title,
        message = message,
        duration = 5000
    })
end)

-- Ocultar HUD quando pausado
Citizen.CreateThread(function()
    local isPaused = false
    while true do
        Citizen.Wait(500)
        if IsPauseMenuActive() and not isPaused then
            isPaused = true
            SendNUIMessage({ action = "toggleHUD", show = false })
        elseif not IsPauseMenuActive() and isPaused then
            isPaused = false
            SendNUIMessage({ action = "toggleHUD", show = true })
        end
    end
end)
