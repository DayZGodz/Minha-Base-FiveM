local last = { health = -1, armor = -1, hunger = -1, thirst = -1, oxygen = -1 }
local showing = true
local currentHunger = 0
local currentThirst = 0

RegisterNetEvent("godz:updateStatus")
AddEventHandler("godz:updateStatus",function(h,t)
    currentHunger = h
    currentThirst = t
end)

Citizen.CreateThread(function()
    while true do
        local wait = 500
        local ped = PlayerPedId()
        local hp = GetEntityHealth(ped)
        local armor = GetPedArmour(ped)
        local healthPct = math.max(0, math.min(100, math.floor(((hp - 100) / 100) * 100)))
        local underwater = IsPedSwimmingUnderWater(ped)
        local oxy = 100
        if underwater then
            local t = GetPlayerUnderwaterTimeRemaining(PlayerId())
            oxy = math.max(0, math.min(100, math.floor((t / 10) * 100)))
        end
        local hunger = currentHunger
        local thirst = currentThirst

        if healthPct ~= last.health or armor ~= last.armor or hunger ~= last.hunger or thirst ~= last.thirst or oxy ~= last.oxygen then
            SendNUIMessage({ action = "update", health = healthPct, armor = armor, hunger = hunger, thirst = thirst, oxygen = oxy, show = showing })
            last.health = healthPct
            last.armor = armor
            last.hunger = hunger
            last.thirst = thirst
            last.oxygen = oxy
        end

        Citizen.Wait(wait)
    end
end)

RegisterCommand("hud", function()
    showing = not showing
    SendNUIMessage({ action = "toggle", show = showing })
end)

RegisterNetEvent("godz_interface:showXP")
AddEventHandler("godz_interface:showXP", function(jobLabel, xpAmount, progressPct)
    SendNUIMessage({
        action = "showXP",
        label = jobLabel,
        xp = xpAmount,
        progress = progressPct
    })
end)
