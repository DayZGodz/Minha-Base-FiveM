local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local MASTER_CONFIG = {}

-- Carregar Configuração Mestra
Citizen.CreateThread(function()
    local attempts = 0
    while GetResourceState("godz_tuning") ~= "started" and attempts < 100 do
        attempts = attempts + 1
        Wait(200)
    end

    local data = nil
    if GetResourceState("godz_tuning") == "started" then
        local ok, res = pcall(function()
            return exports["godz_tuning"]:GetMasterConfig()
        end)
        if ok then data = res end
    end

    MASTER_CONFIG = data or {}
    print("[GODZ] God-Phone: Configuração Mestra Carregada com Sucesso.")
end)

-- Integração com Ponte de IA
RegisterServerEvent("godz_phone:askAI")
AddEventHandler("godz_phone:askAI", function(question)
    local source = source
    local user_id = vRP.getUserId(source)
    
    if not user_id then return end

    print("[GODZ AI] Processando pergunta de User " .. user_id .. ": " .. question)

    PerformHttpRequest("http://127.0.0.1:5000/ai_chat", function(errorCode, resultData, resultHeaders)
        local answer = "A IA está dormindo no momento..."
        local audio = nil
        
        if errorCode == 200 then
            local data = json.decode(resultData)
            if data then
                if data.response then
                    answer = data.response
                end
                if data.audio then
                    audio = data.audio
                end
            end
        else
            print("[GODZ AI] Erro na conexão com a ponte: " .. tostring(errorCode))
        end

        TriggerClientEvent("godz_phone:receiveAIResponse", source, answer, audio)
    end, "POST", json.encode({
        user_id = user_id,
        message = question,
        context = "game_server"
    }), { ["Content-Type"] = "application/json" })
end)

-- Database Operations (OxMySQL)

-- Contatos
RegisterServerEvent("godz_phone:getContacts")
AddEventHandler("godz_phone:getContacts", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    exports.oxmysql:execute("SELECT * FROM godz_phone_contacts WHERE user_id = ?", {user_id}, function(result)
        TriggerClientEvent("godz_phone:receiveContacts", source, result)
    end)
end)

RegisterServerEvent("godz_phone:addContact")
AddEventHandler("godz_phone:addContact", function(name, number)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    exports.oxmysql:insert("INSERT INTO godz_phone_contacts (user_id, name, number) VALUES (?, ?, ?)", {user_id, name, number}, function(id)
        TriggerClientEvent("godz_phone:contactAdded", source, id)
    end)
end)

-- Mensagens
RegisterServerEvent("godz_phone:getMessages")
AddEventHandler("godz_phone:getMessages", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    exports.oxmysql:execute("SELECT * FROM godz_phone_messages WHERE sender_id = ? OR receiver_id = ? ORDER BY created_at DESC LIMIT 50", {user_id, user_id}, function(result)
        TriggerClientEvent("godz_phone:receiveMessages", source, result)
    end)
end)

-- Sistema de Fotos (Armazenamento no Disco D:)
RegisterServerEvent("godz_phone:savePhoto")
AddEventHandler("godz_phone:savePhoto", function(image64)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    -- Remove header data:image/jpg;base64, se existir
    if string.find(image64, "base64") then
        local _, _, content = string.find(image64, "base64,(.+)")
        if content then image64 = content end
    end

    local filename = "photo_" .. user_id .. "_" .. os.time() .. ".jpg"
    -- Salva no diretório do recurso (Localizado no Disco D:)
    SaveResourceFile(GetCurrentResourceName(), "html/photos/" .. filename, image64, -1)
    
    print("[GODZ PHONE] Foto salva no Disco D: " .. filename)
    TriggerClientEvent("godz_phone:photoSaved", source, filename)
end)
