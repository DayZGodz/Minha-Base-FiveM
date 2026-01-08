local cfg = module("cfg/player_state")

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	local source = source
	local user_id = vRP.getUserId(source)
	local data = vRP.getUserDataTable(user_id)
	vRPclient._setFriendlyFire(source,true)

	if first_spawn then
		if data.colete then
			vRPclient.setArmour(source,data.colete)
		end

		if data.customization == nil then
			data.customization = cfg.default_customization
		end

		if data.position then
			vRPclient.teleport(source,data.position.x,data.position.y,data.position.z)
		end

		if data.customization then
			vRPclient.setCustomization(source,data.customization) 
			if data.weapons then
				vRPclient.giveWeapons(source,data.weapons,true)

				if data.health then
					vRPclient.setHealth(source,data.health)
					SetTimeout(5000,function()
						if vRPclient.isInComa(source) then
							vRPclient.killComa(source)
						end
					end)
				end
			end
		else
			if data.weapons then
				vRPclient.giveWeapons(source,data.weapons,true)
			end

			if data.health then
				vRPclient.setHealth(source,data.health)
			end
		end
	else
		vRPclient._setHandcuffed(source,false)

		if not vRP.hasPermission(user_id,"mochila.permissao") then
			data.gaptitudes = {}
		end

		if data.customization then
			vRPclient._setCustomization(source,data.customization)
		end
	end
		vRPclient._playerStateReady(source,true)
end)

function tvRP.updatePos(x,y,z)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		local tmp = vRP.getUserTmpTable(user_id)
		if data and (not tmp or not tmp.home_stype) then
			data.position = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
		end
	end
end

function tvRP.updateArmor(armor)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.colete = armor
		end
	end
end

function tvRP.updateWeapons(weapons)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.weapons = weapons
		end
	end
end

function tvRP.updateCustomization(customization)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.customization = customization
		end
	end
end

function tvRP.updateHealth(health)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.health = health
		end
	end
end


function vRP.modelPlayer(source)
	local ped = GetPlayerPed(source)
	if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
		return "mp_m_freemode_01"
	elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
		return "mp_f_freemode_01"
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MALA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trymala")
AddEventHandler("trymala",function(nveh)
	TriggerClientEvent("syncmala",-1,nveh)
end)

-- GODZ AI CONTEXTUAL TIPS
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Verifica a cada 60 segundos
        for k,v in pairs(vRP.users) do
            local user_id = v
            local source = vRP.getUserSource(user_id)
            if source then
                local hunger = vRP.getHunger(user_id)
                local thirst = vRP.getThirst(user_id)
                
                -- Se fome ou sede estiverem críticas (> 90 no vRP significa < 10% de saciedade)
                if (hunger > 90 or thirst > 90) then
                    if not vRP.ai_cooldowns then vRP.ai_cooldowns = {} end
                    
                    -- Cooldown de 5 minutos (300 segundos) para não spammar a IA
                    if not vRP.ai_cooldowns[user_id] or (os.time() - vRP.ai_cooldowns[user_id]) > 300 then
                        vRP.ai_cooldowns[user_id] = os.time()
                        
                        local condition = ""
                        if hunger > 90 then condition = "morrendo de fome" end
                        if thirst > 90 then condition = "morrendo de sede" end
                        if hunger > 90 and thirst > 90 then condition = "morrendo de fome e sede" end
                        
                        local prompt = "O jogador está " .. condition .. ". Dê uma dica curta e imersiva de sobrevivência (máx 15 palavras) para o jogo GTA RP."
                        
                        -- Chama a IA (assumindo que a função vRP.askGodzAI existe ou adaptando para o padrão do servidor)
                        -- Como não tenho a definição de vRP.askGodzAI, vou usar um print de debug e tentar chamar se existir, 
                        -- ou apenas simular se for necessário. Mas o usuário pediu explicitamente para chamar o endpoint /ai_assist.
                        -- Vou assumir que existe uma implementação de PerformHttpRequest para a IA ou usar a função nativa do vRP se houver.
                        -- Vou implementar usando PerformHttpRequest direto para garantir.
                        
                        PerformHttpRequest("http://127.0.0.1:5000/ai_assist", function(err, text, headers)
                            if err == 200 then
                                local data = json.decode(text)
                                if data and data.response then
                                    TriggerClientEvent("Notify", source, "ia_tip", data.response)
                                end
                            end
                        end, "POST", json.encode({
                            question = prompt,
                            user_id = user_id
                        }), { ["Content-Type"] = "application/json" })
                    end
                end
            end
        end
    end
end)
