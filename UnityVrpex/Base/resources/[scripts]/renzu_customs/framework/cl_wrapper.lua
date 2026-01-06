local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

ClientCallbacks = {}
CurrentRequestId = 0

function Framework()
	if Config.framework == 'ESX' then
		ESX = exports['es_extended']:getSharedObject()
		PlayerData = ESX.GetPlayerData()
	elseif Config.framework == 'QBCORE' then
		QBCore = exports['qb-core']:GetCoreObject()
		QBCore.Functions.GetPlayerData(function(p)
			PlayerData = p
			if PlayerData.job ~= nil then
				PlayerData.job.grade = PlayerData.job.grade.level
			end
        end)
    elseif Config.framework == 'vRP' then
        PlayerData = {}
        PlayerData.job = { name = 'unemployed', grade = 0 }
	end
end

function Playerloaded()
	if Config.framework == 'ESX' then
		RegisterNetEvent('esx:playerLoaded')
		AddEventHandler('esx:playerLoaded', function(xPlayer)
			PlayerData = xPlayer
			playerloaded = true
			TriggerServerEvent('renzu_customs:loaded')
		end)
	elseif Config.framework == 'QBCORE' then
		RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
		AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
			playerloaded = true
			TriggerServerEvent('renzu_customs:loaded')
			QBCore.Functions.GetPlayerData(function(p)
				PlayerData = p
				if PlayerData.job ~= nil then
					PlayerData.job.grade = PlayerData.job.grade.level
				end
			end)
		end)
    elseif Config.framework == 'vRP' then
        -- Trigger immediately on restart
        CreateThread(function()
            Wait(1000)
            playerloaded = true
            TriggerServerEvent('renzu_customs:loaded')
            TriggerServerEvent('renzu_customs:requestJob')
        end)
        
        RegisterNetEvent('vRP:playerSpawned')
        AddEventHandler('vRP:playerSpawned', function()
            playerloaded = true
            TriggerServerEvent('renzu_customs:loaded')
            TriggerServerEvent('renzu_customs:requestJob')
        end)
	end
end

function SetJob()
	if Config.framework == 'ESX' then
		RegisterNetEvent('esx:setJob')
		AddEventHandler('esx:setJob', function(job)
			PlayerData.job = job
			playerjob = PlayerData.job.name
			inmark = false
			cancel = true
			markers = {}
		end)
	elseif Config.framework == 'QBCORE' then
		RegisterNetEvent('QBCore:Client:OnJobUpdate')
		AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
			PlayerData.job = job
			PlayerData.job.grade = PlayerData.job.grade.level
			playerjob = PlayerData.job.name
			inmark = false
			cancel = true
			markers = {}
		end)
    elseif Config.framework == 'vRP' then
        RegisterNetEvent('renzu_customs:setJob')
        AddEventHandler('renzu_customs:setJob', function(jobName, jobGrade)
            if not PlayerData then PlayerData = {} end
            PlayerData.job = { name = jobName, grade = jobGrade or 0 }
            playerjob = jobName
            inmark = false
            cancel = true
            markers = {}
        end)
	end
end

CreateThread(function()
    Wait(500)
	if Config.framework == 'ESX' then
		while ESX == nil do Wait(1) end
		TriggerServerCallback_ = function(...)
			ESX.TriggerServerCallback(...)
		end
	elseif Config.framework == 'QBCORE' then
		while QBCore == nil do Wait(1) end
		TriggerServerCallback_ =  function(...)
			QBCore.Functions.TriggerCallback(...)
		end
    elseif Config.framework == 'vRP' then
        TriggerServerCallback_ = function(name, cb, ...)
            CurrentRequestId = CurrentRequestId + 1
            ClientCallbacks[CurrentRequestId] = cb
            TriggerServerEvent('renzu_customs:triggerCallback', name, CurrentRequestId, ...)
        end
        
        RegisterNetEvent('renzu_customs:callbackReturn')
        AddEventHandler('renzu_customs:callbackReturn', function(requestId, ...)
            if ClientCallbacks[requestId] then
                ClientCallbacks[requestId](...)
                ClientCallbacks[requestId] = nil
            end
        end)
	end
end)

MathRound = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end
