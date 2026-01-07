local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local bank = Tunnel.getInterface("godz_bank")

-- Toggle UI
function ToggleBank(show)
    if show then
        bank.getDashboardData({}, function(data)
            if data then
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "open",
                    data = data
                })
                -- Animation
                local ped = PlayerPedId()
                RequestAnimDict("amb@prop_human_atm@male@idle_a")
                while not HasAnimDictLoaded("amb@prop_human_atm@male@idle_a") do Citizen.Wait(10) end
                TaskPlayAnim(ped, "amb@prop_human_atm@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end)
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
        ClearPedTasks(PlayerPedId())
    end
end

RegisterNetEvent("godz_bank:open")
AddEventHandler("godz_bank:open", function()
    ToggleBank(true)
end)

-- NUI Callbacks
RegisterNUICallback("close", function(data, cb)
    ToggleBank(false)
    cb("ok")
end)

RegisterNUICallback("transfer", function(data, cb)
    bank.transferMoney({data.target_id, data.amount}, function(success)
        if success then
            bank.getDashboardData({}, function(newData) cb(newData) end)
        else
            cb(false)
        end
    end)
end)

RegisterNUICallback("deposit", function(data, cb)
    bank.depositMoney({data.amount}, function(success)
        if success then
            bank.getDashboardData({}, function(newData) cb(newData) end)
        else
            cb(false)
        end
    end)
end)

RegisterNUICallback("withdraw", function(data, cb)
    bank.withdrawMoney({data.amount}, function(success)
        if success then
            bank.getDashboardData({}, function(newData) cb(newData) end)
        else
            cb(false)
        end
    end)
end)

RegisterNUICallback("takeLoan", function(data, cb)
    bank.takeLoan({data.amount}, function(success)
        if success then
            bank.getDashboardData({}, function(newData) cb(newData) end)
        else
            cb(false)
        end
    end)
end)

RegisterNUICallback("payLoan", function(data, cb)
    bank.payLoan({data.amount}, function(success)
        if success then
            bank.getDashboardData({}, function(newData) cb(newData) end)
        else
            cb(false)
        end
    end)
end)

-- Target Integration
Citizen.CreateThread(function()
    if exports["godz_target"] then
        exports["godz_target"]:AddTargetModel({
            "prop_atm_01",
            "prop_atm_02",
            "prop_atm_03",
            "prop_fleeca_atm"
        }, {
            options = {
                {
                    event = "godz_bank:open",
                    icon = "fas fa-university",
                    label = "Acessar Banco",
                }
            },
            distance = 1.5
        })
    end
end)
