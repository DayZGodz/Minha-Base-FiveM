
-- basic_items.lua restored and patched
local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

Citizen.CreateThread(function()
    print("^3[vRP] Aguardando inicialização do core para registrar itens básicos...^0")
    Wait(5000) -- Aguarda 5 segundos para garantir que o vRP/DB carregou
    
    local cfg = module("vrp", "cfg/items")
    if cfg and cfg.items then
        for k,v in pairs(cfg.items) do
            if vRP then
                vRP.defInventoryItem(k,v[1],v[2])
            else
                print("^1[vRP] Erro Crítico: vRP Proxy é nil em basic_items.lua^0")
            end
        end
        print("^2[vRP] Itens básicos registrados com sucesso.^0")
    end
end)
