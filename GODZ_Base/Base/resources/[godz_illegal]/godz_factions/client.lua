local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local isDashboardOpen = false

-- Command to open dashboard
RegisterCommand("fmenu", function()
    TriggerServerEvent("godz_factions:getDashboardData")
end)

RegisterNetEvent("godz_factions:openDashboard")
AddEventHandler("godz_factions:openDashboard", function(data)
    isDashboardOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        faction = data.faction,
        members = data.members
    })
end)

RegisterNUICallback("close", function(data, cb)
    isDashboardOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("manageMember", function(data, cb)
    TriggerServerEvent("godz_factions:manageMember", data)
    cb("ok")
end)

-- Zones & Target
Citizen.CreateThread(function()
    -- Inicializar Targets das Zonas
    if exports["godz_target"] then
        for zoneName, zoneData in pairs(Config.Zones) do
            exports["godz_target"]:AddCircleZone("FactionZone_"..zoneName, zoneData.coords, 2.0, {
                name = "FactionZone_"..zoneName,
                debugPoly = false,
            }, {
                options = {
                    {
                        event = "godz_factions:checkZone", -- Evento intermediário para passar dados
                        icon = "fas fa-flag",
                        label = "Interagir com Zona",
                        zoneName = zoneName
                    }
                },
                distance = 2.5
            })
        end
    end

    -- Loop de Marcadores (Visual apenas ou Fallback)
    while true do
        local idle = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        for zoneName, zoneData in pairs(Config.Zones) do
            local dist = #(coords - zoneData.coords)
            if dist < zoneData.radius then
                idle = 5
                DrawMarker(27, zoneData.coords.x, zoneData.coords.y, zoneData.coords.z - 0.95, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 155, 89, 182, 100, 0, 0, 0, 1)
                
                -- Fallback se não tiver target
                if not exports["godz_target"] and dist < 1.5 then
                    if IsControlJustPressed(0, 38) then -- E
                         TriggerServerEvent("godz_factions:interactZone", zoneName)
                    end
                end
            end
        end
        Wait(idle)
    end
end)

RegisterNetEvent("godz_factions:checkZone")
AddEventHandler("godz_factions:checkZone", function(data)
    if data and data.zoneName then
        TriggerServerEvent("godz_factions:interactZone", data.zoneName)
    end
end)
