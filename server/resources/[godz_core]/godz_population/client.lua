local spawnedNPCs = {}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, loc in ipairs(Config.Locations) do
            local dist = #(playerCoords - loc.coords)
            
            if dist < 50.0 then
                sleep = 500
                if not spawnedNPCs[i] then
                    TriggerServerEvent("godz:requestNPC", i)
                    spawnedNPCs[i] = { spawned = false, requesting = true }
                end
                
                if spawnedNPCs[i] and spawnedNPCs[i].spawned then
                    local ped = spawnedNPCs[i].entity
                    if DoesEntityExist(ped) then
                        if dist < 10.0 then
                            sleep = 0
                            local zOffset = 2.0
                            DrawText3D(loc.coords.x, loc.coords.y, loc.coords.z + zOffset, "~y~" .. (spawnedNPCs[i].name or "Unknown"))
                            DrawText3D(loc.coords.x, loc.coords.y, loc.coords.z + zOffset - 0.15, "~w~" .. (spawnedNPCs[i].job or loc.job))
                            
                            if dist < 2.0 then
                                DrawText3D(loc.coords.x, loc.coords.y, loc.coords.z + zOffset - 0.3, "~g~[E] ~w~Conversar")
                                
                                if IsControlJustPressed(0, 38) then -- E
                                    TriggerEvent("chat:addMessage", {
                                        color = {184, 134, 11}, -- Dark Gold
                                        multiline = true,
                                        args = { "NPC " .. spawnedNPCs[i].name, spawnedNPCs[i].dialog }
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent("godz:receiveNPCData")
AddEventHandler("godz:receiveNPCData", function(index, data)
    if spawnedNPCs[index] and spawnedNPCs[index].spawned then return end

    local loc = Config.Locations[index]
    RequestModel(GetHashKey(loc.model))
    while not HasModelLoaded(GetHashKey(loc.model)) do Wait(10) end
    
    local ped = CreatePed(4, GetHashKey(loc.model), loc.coords.x, loc.coords.y, loc.coords.z - 1.0, loc.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    spawnedNPCs[index] = {
        spawned = true,
        entity = ped,
        name = data.name,
        backstory = data.backstory,
        dialog = data.dialog,
        job = loc.job
    }
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end
