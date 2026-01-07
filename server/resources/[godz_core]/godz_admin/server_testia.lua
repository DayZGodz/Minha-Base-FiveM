
RegisterCommand('testia', function(source, args, rawCommand)
    print("[GODZ DEBUG] Testando conexão com IA...")
    local headers = { 
        ["Content-Type"] = "application/json", 
        ["Authorization"] = "Bearer godz_secret_key_123" 
    }
    PerformHttpRequest("http://localhost:5000/health", function(err, text, headers)
        if err == 200 then
            print("[GODZ DEBUG] Conexão bem sucedida! Resposta: " .. tostring(text))
        else
            print("[GODZ DEBUG] Falha na conexão. Código: " .. tostring(err))
        end
    end, 'GET', "", headers)
end)
