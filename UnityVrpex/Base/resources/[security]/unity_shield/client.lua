CreateThread(function()
    while true do
        Wait(2000) -- Verifica a cada 2 segundos para não pesar o cliente
        
        local ped = PlayerPedId()
        
        if DoesEntityExist(ped) then
            for weaponName, _ in pairs(Config.WeaponBlacklist) do
                local weaponHash = GetHashKey(weaponName)
                
                if HasPedGotWeapon(ped, weaponHash, false) then
                    -- Remove a arma
                    RemoveWeaponFromPed(ped, weaponHash)
                    
                    -- Notifica o jogador
                    TriggerEvent("Notify", "negado", Config.Messages.WeaponRemoved)
                    
                    -- Loga no servidor
                    TriggerServerEvent("unity_shield:logDetection", weaponName)
                end
            end
        end
    end
end)
