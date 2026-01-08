local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local robbery_cooldown = {}

RegisterServerEvent("godz_robberies:start")
AddEventHandler("godz_robberies:start",function(shopId)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if robbery_cooldown[shopId] and os.time() < robbery_cooldown[shopId] then
			TriggerClientEvent("Notify",source,"negado","Caixa vazio. Aguarde para roubar novamente.")
			return
		end
		
		-- Notify Police
		local identity = vRP.getUserIdentity(user_id)
		
		local oficiais = vRP.getUsersByPermission("policia.permissao")
		for _,uid in ipairs(oficiais) do
			local ps = vRP.getUserSource(parseInt(uid))
			if ps then
				if vRP.hasGroup(uid,"policia") then -- Only on duty
					TriggerClientEvent("godz_interface:Notify",ps,"ia_tip","NEXUS","🚨 [NEXUS]: Assalto em andamento na Loja "..shopId..".",10000)
					TriggerClientEvent("Notify",ps,"importante","Roubo em andamento na loja "..shopId)
					vRPclient.playSound(ps,"Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
				end
			end
		end
		
		-- Webhook
		local msg = "**Ladrão:** "..identity.name.." "..identity.firstname.." ["..user_id.."]\n**Loja:** "..shopId
		TriggerEvent("godz_logs:send","Audit","Assalto Iniciado",msg,15158332,source)
	end
end)

RegisterServerEvent("godz_robberies:payment")
AddEventHandler("godz_robberies:payment",function(shopId)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local reward = math.random(5000,15000)
		vRP.giveInventoryItem(user_id,"dinheirosujo",reward,true)
		robbery_cooldown[shopId] = os.time() + 1800 -- 30 min cooldown
		
		local identity = vRP.getUserIdentity(user_id)
		local msg = "**Ladrão:** "..identity.name.." "..identity.firstname.." ["..user_id.."]\n**Loja:** "..shopId.."\n**Roubo:** $"..vRP.format(reward).." (Sujo)"
		TriggerEvent("godz_logs:send","Audit","Assalto Finalizado",msg,3066993,source)
		
		TriggerClientEvent("Notify",source,"sucesso","Você roubou $"..vRP.format(reward)..".")
	end
end)