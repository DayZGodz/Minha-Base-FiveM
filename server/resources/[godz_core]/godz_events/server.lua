local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local AI_ENDPOINT = "http://127.0.0.1:5000/ai_assist"
local DEBUG_MODE = true

--[ UTILS ]-------------------------------------------------------------------------------------------------------

local function getEconomyIndex()
    if GetResourceState("godz_economy") == "started" then
        return exports["godz_economy"]:GetPriceMultiplier("Global") or 1.0
    end
    return 1.0
end

local function announceEvent(title, description)
    TriggerClientEvent("godz:notify", -1, "ia_tip", "<b>" .. title .. "</b><br>" .. description, 15000)
    -- Also sound
    TriggerClientEvent("godz_events:playSound", -1, "event_start")
end

--[ EVENT HANDLERS ]----------------------------------------------------------------------------------------------

local activeEvents = {}

local function startPlaneCrash()
    print("[GODZ Events] Starting Plane Crash")
    -- Logic to choose a location and sync with client
    -- For now, we'll pick a random airport or open area
    local coords = {x = 1700.0, y = 3200.0, z = 40.0} -- Sandy Shores Airfield Area
    TriggerClientEvent("godz_events:startPlaneCrash", -1, coords)
    return "Queda de Avião", "Um avião de carga suspeito caiu em Sandy Shores. Recupere a carga!"
end

local function startNPCInvasion()
    print("[GODZ Events] Starting NPC Invasion")
    local coords = {x = 100.0, y = -1900.0, z = 20.0} -- Grove Street Area
    TriggerClientEvent("godz_events:startInvasion", -1, coords)
    return "Invasão de Gangue", "Uma gangue rival está dominando a Grove Street. Expulse-os!"
end

local function startFlashSale()
    print("[GODZ Events] Starting Flash Sale")
    -- Integration with shops (simulated)
    return "Promoção Relâmpago", "Todas as lojas de conveniência estão com 50% de desconto por 15 minutos!"
end

--[ AI DIRECTOR ]-------------------------------------------------------------------------------------------------

local function DirectorAI()
    local players = GetNumPlayerIndices()
    local economy = getEconomyIndex()
    
    local prompt = "Você é o Diretor de Eventos do servidor (GTA RP). " ..
                   "Status: " .. players .. " jogadores online, Economia " .. economy .. "x. " ..
                   "Escolha um evento para iniciar agora: 'PlaneCrash' (ação, loot), 'NPCInvasion' (tiroteio, pve), 'FlashSale' (economia) ou 'None' (nada). " ..
                   "Considere o balanceamento. Responda apenas o ID do evento em JSON: { \"event\": \"...\" }"

    if DEBUG_MODE then print("[GODZ Events] AI Director Thinking...") end

    PerformHttpRequest(AI_ENDPOINT, function(err, text, headers)
        if err == 200 and text then
            local data = json.decode(text)
            if data and data.event then
                local title, desc
                
                if data.event == "PlaneCrash" then
                    title, desc = startPlaneCrash()
                elseif data.event == "NPCInvasion" then
                    title, desc = startNPCInvasion()
                elseif data.event == "FlashSale" then
                    title, desc = startFlashSale()
                end

                if title and desc then
                    announceEvent(title, desc)
                end
            end
        else
            print("[GODZ Events] AI Error")
        end
    end, 'POST', json.encode({ prompt = prompt }), { ["Content-Type"] = 'application/json' })
end

--[ THREAD ]------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Initial wait
    while true do
        -- 1 Hour Interval
        Citizen.Wait(60 * 60 * 1000)
        DirectorAI()
    end
end)

--[ COMMAND FOR TESTING ]-----------------------------------------------------------------------------------------

RegisterCommand('testevent', function(source)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "admin.permissao") then
        DirectorAI()
        TriggerClientEvent("Notify", source, "sucesso", "Diretor IA acionado manualmente.")
    end
end)
