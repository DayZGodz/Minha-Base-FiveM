local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local MySQL = module("vrp_mysql", "MySQL")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("godz_garages", src)
Proxy.addInterface("godz_garages", src)

-- Prepare SQL
MySQL.createCommand("godz_garages/get_vehicles", "SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
MySQL.createCommand("godz_garages/update_state", "UPDATE vrp_user_vehicles SET in_road = @in_road, engine = @engine, body = @body, fuel = @fuel WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("godz_garages/set_impounded", "UPDATE vrp_user_vehicles SET detido = @detido, time = @time WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("godz_garages/get_specific", "SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")

-- Methods
function src.getVehicles()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return {} end

    local vehicles = {}
    -- Async query
    local finished = false
    MySQL.query("godz_garages/get_vehicles", {user_id = user_id}, function(rows)
        if rows and #rows > 0 then
            vehicles = rows
        end
        finished = true
    end)

    -- Wait for query (Blocking) - Not ideal but Tunnel expects return
    -- Better: Client passes callback. 
    -- Since Tunnel supports async return if we don't return immediately? 
    -- vRP Tunnel: if function returns nil, it waits? No.
    -- We must use TriggerClientEvent for async data or use callback on client side if using vRP Tunnel correctly.
    -- vRP Tunnel allows returning a value. If we need async, we spin wait.
    while not finished do Citizen.Wait(10) end
    return vehicles
end

function src.checkHomeAccess(homeId)
    local source = source
    local user_id = vRP.getUserId(source)
    local access = false
    local garageInfo = nil
    
    local finished = false
    
    MySQL.query("godz_garages/get_home", {id = homeId}, function(rows)
        if rows and #rows > 0 then
            local home = rows[1]
            if home.garage then
                garageInfo = json.decode(home.garage)
            end
            
            if home.owner_id == user_id then
                access = true
            else
                -- Check keys
                MySQL.query("godz_garages/get_home_keys", {id = homeId}, function(keys)
                    if keys then
                        for _, k in pairs(keys) do
                            if k.user_id == user_id then access = true break end
                        end
                    end
                    finished = true
                end)
                return -- Wait for inner query
            end
        end
        finished = true
    end)
    
    while not finished do Citizen.Wait(10) end
    return access, garageInfo
end

function src.checkSpawn(vehicle, type)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return false, "Erro de ID" end

    -- Check Specific Vehicle Status
    local allowed = false
    local message = ""
    local finished = false

    MySQL.query("godz_garages/get_specific", {user_id = user_id, vehicle = vehicle}, function(rows)
        if rows and #rows > 0 then
            local vehData = rows[1]
            if vehData.detido > 0 then
                allowed = false
                message = "Veículo apreendido/bloqueado."
            elseif vehData.in_road == 1 then
                -- Optional: allow respawn with fee or block
                allowed = true -- Allow retrieving from street (or logic to "bring" it)
                message = "Veículo estava na rua."
            else
                allowed = true
            end

            -- Payment for public garage
            if allowed and type == "public" and Config.WithdrawFee > 0 then
                if not vRP.tryFullPayment(user_id, Config.WithdrawFee) then
                    allowed = false
                    message = "Saldo insuficiente ($"..Config.WithdrawFee..")"
                end
            end
        else
            allowed = false
            message = "Veículo não encontrado."
        end
        finished = true
    end)

    while not finished do Citizen.Wait(10) end
    
    if allowed then
        -- Update state to in_road = 1
        MySQL.execute("godz_garages/update_state", {
            user_id = user_id,
            vehicle = vehicle,
            in_road = 1,
            engine = 1000, -- Load actual value if needed, but here we just mark it out
            body = 1000,
            fuel = 100
        })
    end

    return allowed, message
end

function src.storeVehicle(vehicle, damage)
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    -- damage: {engine, body, fuel}
    MySQL.execute("godz_garages/update_state", {
        user_id = user_id,
        vehicle = vehicle,
        in_road = 0,
        engine = damage.engine or 1000,
        body = damage.body or 1000,
        fuel = damage.fuel or 100
    })
    TriggerClientEvent("godz_notify:notify", source, "sucesso", "Garagem", "Veículo guardado.")
end

function src.payInsurance(vehicle)
    local source = source
    local user_id = vRP.getUserId(source)
    
    local finished = false
    local success = false
    local msg = ""

    if vRP.tryFullPayment(user_id, Config.InsurancePrice) then
        MySQL.execute("godz_garages/update_state", {
            user_id = user_id,
            vehicle = vehicle,
            in_road = 0, -- Back to garage
            engine = 1000,
            body = 1000,
            fuel = 100
        })
        success = true
        msg = "Seguro pago. Veículo recuperado."
    else
        success = false
        msg = "Dinheiro insuficiente."
    end
    
    return success, msg
end
