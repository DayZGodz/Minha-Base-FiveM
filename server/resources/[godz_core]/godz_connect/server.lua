local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

RegisterServerEvent("godz_connect:checkPlayerStatus")
AddEventHandler("godz_connect:checkPlayerStatus", function()
    local source = source
    local user_id = vRP.getUserId(source)
    local playerName = GetPlayerName(source) or "Cidadão"
    
    local isWhitelisted = false
    local hasIdentity = false
    local wlToken = nil
    
    if user_id then
        -- [GODZ] Protocolo V7: Verificação completa de status
        isWhitelisted = vRP.isWhitelisted(user_id)
        
        local identity = vRP.getUserIdentity(user_id)
        if identity and identity.firstname then
            playerName = identity.firstname .. " " .. identity.name
            hasIdentity = true
        else
            -- Clean up name for AI
            playerName = string.gsub(playerName, "[^a-zA-Z0-9 ]", "")
        end

        if isWhitelisted then
            local role = (user_id == 1) and "CEO" or "Cidadão"
            local msg = "Protocolo de Autoridade: " .. role .. " " .. playerName .. " (ID " .. user_id .. ") estabeleceu conexão."
            exports.godz_modules:Log("Login", msg, 3066993)
        else
            local msg = "Acesso Negado: Jogador " .. playerName .. " [" .. user_id .. "] bloqueado por falta de assinatura (WL)."
            exports.godz_modules:Log("Whitelist", msg, 15158332)
            
            local tokrows = vRP.query("godz_wl_temp_get_by_user", { user_id = user_id })
            if tokrows and #tokrows > 0 then
                wlToken = tokrows[1].token
            end
        end
    end

    local status = {
        isCreator = (user_id == 1),
        playerName = playerName,
        isWhitelisted = isWhitelisted,
        hasIdentity = hasIdentity,
        token = wlToken
    }

    SetTimeout(3000, function()
        TriggerClientEvent("godz_connect:receiveStatus", source, status)
    end)
end)
