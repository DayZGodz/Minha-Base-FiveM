local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("godz_housing", src)
Proxy.addInterface("godz_housing", src)

-- local MySQL = module("vrp_mysql", "MySQL")
-- MySQL.createCommand removed for oxmysql compatibility

-- Cache
local Homes = {}

Citizen.CreateThread(function()
    -- Initialize Homes from Config if DB is empty, or just load from DB
    -- For simplicity, we assume DB is populated or we insert Config homes if missing.
    -- Ideally, a proper setup script handles this. Here we just load.
    Wait(1000)
    local rows = MySQL.query.await("SELECT * FROM godz_housing_homes", {})
    if rows and #rows > 0 then
        for _, row in pairs(rows) do
            Homes[row.id] = row
            Homes[row.id].coords = json.decode(row.coords)
        end
    else
        print("^3[GODZ Housing] ^7No homes in DB. Inserting Config defaults...")
        for _, home in pairs(Config.Homes) do
            MySQL.insert.await("INSERT INTO godz_housing_homes (name, price, coords, shell) VALUES (@name, @price, @coords, @shell)", {
                ['@name'] = home.name,
                ['@price'] = home.price,
                ['@coords'] = json.encode({x=home.coords.x, y=home.coords.y, z=home.coords.z}),
                ['@shell'] = home.shell
            })
        end
        -- Reload
        Wait(1000)
        local newRows = MySQL.query.await("SELECT * FROM godz_housing_homes", {})
        if newRows then
            for _, row in pairs(newRows) do
                Homes[row.id] = row
                Homes[row.id].coords = json.decode(row.coords)
            end
        end
    end
    print("^2[GODZ Housing] ^7Loaded " .. (rows and #rows or 0) .. " homes.")
end)

-- Methods
function src.getAllHomes()
    return Homes
end

-- Events
RegisterServerEvent("godz_housing:reqBuy")
AddEventHandler("godz_housing:reqBuy", function(id)
    local source = source
    local user_id = vRP.getUserId(source)
    local home = Homes[id]
    
    if not home then return end
    if home.owner_id then 
        TriggerClientEvent("godz_notify:notify", source, "negado", "Erro", "Já possui dono")
        return 
    end
    
    if vRP.tryFullPayment(user_id, home.price) then
        MySQL.execute("godz_housing/buy", { user_id = user_id, id = id })
        home.owner_id = user_id
        TriggerClientEvent("godz_housing:updateHome", -1, id, home)
        TriggerClientEvent("godz_notify:notify", source, "sucesso", "Parabéns", "Compra realizada com sucesso!")
    else
        TriggerClientEvent("godz_notify:notify", source, "negado", "Erro", "Dinheiro insuficiente.")
    end
end)

RegisterServerEvent("godz_housing:reqEnter")
AddEventHandler("godz_housing:reqEnter", function(id)
    local source = source
    local user_id = vRP.getUserId(source)
    local home = Homes[id]
    
    if not home then return end
    
    -- Check Access (Owner, Key, or Police)
    local allowed = false
    if home.owner_id == user_id then 
        allowed = true 
    elseif vRP.hasPermission(user_id, "policia.permissao") then
        allowed = true
        TriggerClientEvent("godz_notify:notify", source, "aviso", "Polícia", "Entrando com mandado/autoridade policial.")
    else
        -- Async Check keys
        local keys = MySQL.query("godz_housing/get_keys", { home_id = id })
        -- Note: If MySQL.query is async in this version of vrp_mysql, we might need a callback wrapper.
        -- Assuming vrp_mysql standard behavior: query(name, params, cb)
        -- However, modern adapters return result if no cb. Let's try synchronous approach logic or nested cb.
        -- To be safe with unknown MySQL wrapper, we'll assume it returns rows if awaited or we use callback.
        -- Since we can't easily await in Lua 5.1/FiveM without library, we use the callback pattern.
    end
    
    -- Refactored for Async Safety:
    local function finishEnter(isAllowed)
        if isAllowed then
            SetPlayerRoutingBucket(source, id) -- Bucket ID = Home ID
            
            -- Get Furniture
            MySQL.query("godz_housing/get_furniture", { home_id = id }, function(rows)
                local furniture = {}
                if rows then
                    for _, row in pairs(rows) do
                        table.insert(furniture, {
                            model = row.model,
                            coords = json.decode(row.coords),
                            rotation = json.decode(row.rotation)
                        })
                    end
                end
                TriggerClientEvent("godz_housing:enterResult", source, true, home.shell, Config.SpawnCoords, furniture)
            end)
        else
            TriggerClientEvent("godz_housing:enterResult", source, false, "Trancado. Você não tem a chave.")
        end
    end
    
    if home.owner_id == user_id or vRP.hasPermission(user_id, "policia.permissao") then
        finishEnter(true)
    else
        MySQL.query("godz_housing/get_keys", { home_id = id }, function(keys)
            local hasKey = false
            if keys then
                for _, k in pairs(keys) do
                    if k.user_id == user_id then hasKey = true break end
                end
            end
            finishEnter(hasKey)
        end)
    end
end)

RegisterServerEvent("godz_housing:saveFurniture")
AddEventHandler("godz_housing:saveFurniture", function(id, furnitureList)
    local source = source
    local user_id = vRP.getUserId(source)
    local home = Homes[id]
    
    if not home then return end
    if home.owner_id ~= user_id then return end
    
    -- Transaction: Clear and Re-insert
    MySQL.update("DELETE FROM godz_housing_furniture WHERE home_id = @home_id", { home_id = id })
    
    for _, item in pairs(furnitureList) do
        MySQL.insert("INSERT INTO godz_housing_furniture (home_id, model, coords, rotation) VALUES (@home_id, @model, @coords, @rotation)", {
            home_id = id,
            model = item.model,
            coords = json.encode(item.coords),
            rotation = json.encode(item.rotation)
        })
    end
    
    TriggerClientEvent("godz_notify:notify", source, "sucesso", "Salvo", "Decoração salva!")
    
    -- Sync with players inside
    local players = GetPlayers()
    for _, p in ipairs(players) do
        if GetPlayerRoutingBucket(p) == id then
            TriggerClientEvent("godz_housing:refreshFurniture", p, furnitureList)
        end
    end
end)

function src.exitHome(id)
    local source = source
    SetPlayerRoutingBucket(source, 0) -- Default World
    return true
end
