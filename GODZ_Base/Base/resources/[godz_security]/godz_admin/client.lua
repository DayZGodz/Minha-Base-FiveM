local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
src = Tunnel.getInterface("godz_admin")

local isMenuOpen = false
local noclipActive = false
local noclipEntity = nil

-- Noclip Configuration
local noclipSpeed = 1.0
local minSpeed = 0.1
local maxSpeed = 10.0

-- Noclip Logic
function ToggleNoclip()
    noclipActive = not noclipActive
    local ped = PlayerPedId()
    
    if noclipActive then
        SetEntityInvincible(ped, true)
        SetEntityVisible(ped, false, false)
        src.logNoclip(true)
        TriggerEvent("godz_notify:notify", "sucesso", "Admin", "Noclip Ativado")
    else
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
        FreezeEntityPosition(ped, false)
        src.logNoclip(false)
        TriggerEvent("godz_notify:notify", "aviso", "Admin", "Noclip Desativado")
    end
end

Citizen.CreateThread(function()
    while true do
        local wait = 100
        if noclipActive then
            wait = 0
            local ped = PlayerPedId()
            local x,y,z = table.unpack(GetEntityCoords(ped))
            local dx,dy,dz = GetCamDirection()
            local speed = noclipSpeed
            
            SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
            
            if IsControlPressed(0, 21) then -- SHIFT
                speed = speed * 5
            end
            
            if IsControlPressed(0, 32) then -- W
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end
            
            if IsControlPressed(0, 269) then -- S
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end
            
            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
            FreezeEntityPosition(ped, true) -- Freeze to prevent gravity
        end
        Citizen.Wait(wait)
    end
end)

function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x*x + y*y + z*z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x,y,z
end

-- Menu Logic
function ToggleMenu()
    if isMenuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end

function OpenMenu()
    src.checkPermission({}, function(hasPermission)
        if hasPermission then
            isMenuOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({ type = "open" })
            StartTabletAnimation()
        else
            TriggerEvent("godz_notify:notify", "erro", "Acesso Negado", "Você não é admin.")
        end
    end)
end

function CloseMenu()
    isMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "close" })
    StopTabletAnimation()
end

function StartTabletAnimation()
    local ped = PlayerPedId()
    RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")
    while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do Citizen.Wait(10) end
    tabletObj = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(tabletObj, ped, GetPedBoneIndex(ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(ped, "amb@world_human_seat_wall_tablet@female@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
end

function StopTabletAnimation()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if tabletObj then
        DeleteEntity(tabletObj)
        tabletObj = nil
    end
end

RegisterCommand("admin", function()
    ToggleMenu()
end)

RegisterCommand("noclip", function()
    src.checkPermission({}, function(hasPermission)
        if hasPermission then
            ToggleNoclip()
        end
    end)
end)

RegisterKeyMapping("noclip", "Toggle Noclip", "keyboard", "F4")

-- NUI Callbacks
RegisterNUICallback("close", function(data, cb)
    CloseMenu()
    cb("ok")
end)

RegisterNUICallback("getPlayers", function(data, cb)
    src.getPlayers({}, function(players)
        cb(players)
    end)
end)

RegisterNUICallback("adminAction", function(data, cb)
    src.adminAction({data.action, data.id})
    cb("ok")
end)

RegisterNUICallback("giveItem", function(data, cb)
    src.giveItem({data.id, data.item, data.amount})
    cb("ok")
end)

RegisterNUICallback("giveVehicle", function(data, cb)
    src.giveVehicle({data.id, data.vehicle})
    cb("ok")
end)

RegisterNUICallback("getAlerts", function(data, cb)
    src.getSecurityAlerts({}, function(alerts)
        cb(alerts)
    end)
end)
