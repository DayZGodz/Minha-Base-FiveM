local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","renzu_customs")

ServerCallbacks = {}

function Initialized()
	if Config.framework == 'ESX' then
		ESX = exports['es_extended']:getSharedObject()
		RegisterServerCallBack_ = function(...)
			ESX.RegisterServerCallback(...)
		end
		vehicletable = 'owned_vehicles'
		vehiclemod = 'vehicle'
	elseif Config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetCoreObject()
		RegisterServerCallBack_ =  function(...)
			QBCore.Functions.CreateCallback(...)
		end
		vehicletable = 'player_vehicles '
		vehiclemod = 'mods'
    elseif Config.framework == 'vRP' then
        RegisterServerCallBack_ = function(name, cb)
            ServerCallbacks[name] = cb
        end
        
        RegisterNetEvent('renzu_customs:triggerCallback')
        AddEventHandler('renzu_customs:triggerCallback', function(name, requestId, ...)
            local src = source
            if ServerCallbacks[name] then
                ServerCallbacks[name](src, function(...)
                    TriggerClientEvent('renzu_customs:callbackReturn', src, requestId, ...)
                end, ...)
            end
        end)
        
        vehicletable = 'godz_user_vehicles'
        vehiclemod = 'vehicle' 
        
        vRP.prepare("renzu/get_vehicle", "SELECT user_id, vehicle FROM godz_user_vehicles WHERE plate = @plate")
        vRP.prepare("renzu/get_vehicle2", "SELECT user_id, vehicle FROM godz_user_vehicles WHERE vehicle_plate = @plate")
	end
end

function GetPlayerFromId(src)
	self = {}
	self.src = src
	if Config.framework == 'ESX' then
		return ESX.GetPlayerFromId(self.src)
	elseif Config.framework == 'QBCORE' then
		selfcore = {}
		selfcore.data = QBCore.Functions.GetPlayer(self.src)
		if selfcore.data.identifier == nil then
			selfcore.data.identifier = selfcore.data.PlayerData.citizenid
		end
		if selfcore.data.job == nil then
			selfcore.data.job = selfcore.data.PlayerData.job
		end
		selfcore.data.getGroup = function(src)
			return QBCore.Functions.HasPermission(src, 'god')
		end
		selfcore.data.getMoney = function(value)
			return selfcore.data.PlayerData.money['cash']
		end
		selfcore.data.removeMoney = function(value)
				QBCore.Functions.GetPlayer(tonumber(self.src)).Functions.RemoveMoney('cash',tonumber(value))
			return true
		end
		return selfcore.data
    elseif Config.framework == 'vRP' then
        local user_id = vRP.getUserId(self.src)
        if not user_id then return nil end
        
        self.data = {}
        self.data.identifier = user_id
        
        self.data.job = { name = 'unemployed', grade = 0 }
        local found_customs_job = false
        if Config.Customs then
            for k,v in pairs(Config.Customs) do
                if v.job and vRP.hasPermission(user_id, v.job) then
                    self.data.job.name = v.job
                    found_customs_job = true
                    break
                end
            end
        end
        
        if not found_customs_job and Config.JobDiscounts then
             for k,v in pairs(Config.JobDiscounts) do
                if vRP.hasPermission(user_id, k) then
                    self.data.job.name = k
                    break
                end
             end
        end

        self.data.getGroup = function(src)
            return vRP.hasPermission(user_id, "admin.permission")
        end
        
        self.data.getMoney = function(value)
            return vRP.getMoney(user_id)
        end
        
        self.data.removeMoney = function(value)
            return vRP.tryFullPayment(user_id, tonumber(value))
        end
        
        return self.data
	end
end

function VehicleNames()
	if Config.framework == 'ESX' then
		vehiclesname = CustomsSQL(Config.Mysql,'fetchAll','SELECT * FROM vehicles', {})
		if Config.renzu_vehicleshopTable then
			vehiclesname = exports.renzu_vehicleshop:VehiclesTable()
		end
	elseif Config.framework == 'QBCORE' then
		vehiclesname = QBCore.Shared.Vehicles
    elseif Config.framework == 'vRP' then
        vehiclesname = {}
	end
end

function CustomsSQL(plugin,type,query,var)
    if type == 'fetchAll' and plugin == 'mysql-async' then
        local result = MySQL.Sync.fetchAll(query, var)
        return result
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Sync.execute(query,var) 
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        local data = nil
        exports.ghmattimysql:execute(query, var, function(result)
            data = result
        end)
        while data == nil do Wait(0) end
        return data
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:execute(query, var)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
        local result = exports.oxmysql:fetchSync(query, var)
        return result
    end
end

RegisterNetEvent('renzu_customs:requestJob')
AddEventHandler('renzu_customs:requestJob', function()
    local src = source
    local player = GetPlayerFromId(src)
    if player and player.job then
        TriggerClientEvent('renzu_customs:setJob', src, player.job.name, player.job.grade)
    end
end)

function SaveVehicleMods(plate, props)
    if Config.framework == 'vRP' then
        local rows = vRP.query("renzu/get_vehicle", { plate = plate })
        if #rows == 0 then
             rows = vRP.query("renzu/get_vehicle2", { plate = plate })
        end
        
        if #rows > 0 then
            local user_id = rows[1].user_id
            local vehicle = rows[1].vehicle
            vRP.setSData("custom:"..user_id..":"..vehicle, json.encode(props))
            return true
        end
        return false
    else
        CustomsSQL(Config.Mysql,'execute','UPDATE '..vehicletable..' SET `'..vehiclemod..'` = @'..vehiclemod..' WHERE UPPER(plate) = @plate', {
            ['@'..vehiclemod..''] = json.encode(props),
            ['@plate'] = plate
        })
        return true
    end
end
