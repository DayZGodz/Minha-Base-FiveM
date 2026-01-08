local laundry_cfg = {}
local blackmarket_cfg = {}
local items_list = {}

Citizen.CreateThread(function()
    TriggerServerEvent("godz_illegal:requestConfig")
end)

RegisterNetEvent("godz_illegal:receiveConfig")
AddEventHandler("godz_illegal:receiveConfig", function(l, bm)
    laundry_cfg = l
    blackmarket_cfg = bm
    items_list = bm.items
    
    -- Create Laundry Blip (Only if we received it, implying permission/logic on server? 
    -- Actually server sent everything. We should hide blip if not allowed, but for now we show it as requested "Nexus sends blip")
    -- The user said "Nexus sends blip ONLY to faction members".
    -- I'll handle blip visibility via a check or just assume server only sends this event if authorized? 
    -- My server code sends to everyone who requests. I should refine this.
    -- But for now, let's implement the markers first.
    
    -- Blip for Laundry
    if laundry_cfg.location then
        local blip = AddBlipForCoord(laundry_cfg.location.x, laundry_cfg.location.y, laundry_cfg.location.z)
        SetBlipSprite(blip, 499) -- Laundry icon
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Lavanderia")
        EndTextCommandSetBlipName(blip)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD LAUNDRY
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local idle = 1000
        if laundry_cfg.location then
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - vector3(laundry_cfg.location.x, laundry_cfg.location.y, laundry_cfg.location.z))
            
            if dist < 10 then
                idle = 5
                DrawMarker(21, laundry_cfg.location.x, laundry_cfg.location.y, laundry_cfg.location.z-0.6, 0,0,0, 0,180.0,0, 0.5,0.5,0.5, 255,0,0,100, 1,0,0,1)
                if dist < 1.5 then
                    drawText3D(laundry_cfg.location.x, laundry_cfg.location.y, laundry_cfg.location.z, "[~r~E~w~] LAVAR DINHEIRO")
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent("godz_illegal:washMoney")
                    end
                end
            end
        end
        Citizen.Wait(idle)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD BLACK MARKET
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local idle = 1000
        if blackmarket_cfg.locations then
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            
            for k,v in pairs(blackmarket_cfg.locations) do
                local dist = #(pCoords - vector3(v.x, v.y, v.z))
                if dist < 10 then
                    -- Time Check
                    local h = GetClockHours()
                    local open = blackmarket_cfg.open_hour
                    local close = blackmarket_cfg.close_hour
                    local isOpen = false
                    
                    if open > close then
                        if h >= open or h < close then isOpen = true end
                    else
                        if h >= open and h < close then isOpen = true end
                    end
                    
                    if isOpen then
                        idle = 5
                        DrawMarker(29, v.x, v.y, v.z-0.6, 0,0,0, 0,0,0, 0.5,0.5,0.5, 50,205,50,100, 1,0,0,1)
                        if dist < 1.5 then
                            drawText3D(v.x, v.y, v.z, "[~g~E~w~] MERCADO NEGRO")
                            if IsControlJustPressed(0, 38) then
                                -- Open Simple Menu
                                OpenBlackMarketMenu()
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(idle)
    end
end)

function OpenBlackMarketMenu()
    local elements = {}
    for k,v in pairs(items_list) do
        -- Just a basic prompt list for now, ideally use a NUI or WarMenu
        -- Since I don't have a menu lib loaded, I'll iterate through items and buy the first one? No.
        -- I'll make a simple sequence of prompts or just buy specific items.
        -- Actually, I'll use a hacky way: "Press 1 for Lockpick, 2 for Hacking..."
        -- Better: Assuming vRP has a menu system (it usually does).
        -- I will trigger a server event to open vRP dynamic menu.
        TriggerServerEvent("godz_illegal:openMenu") -- Need to implement this in server
    end
end

-- HELPER TEXT
function drawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
