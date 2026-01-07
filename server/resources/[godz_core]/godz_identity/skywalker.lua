local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRPN = {}
Tunnel.bindInterface("godz_identity",vRPN)
Proxy.addInterface("godz_identity",vRPN)

local cfg = module("vrp","cfg/groups")
local groups = cfg.groups

-- Verificação da coluna 'biography' na tabela 'godz_user_identities'
Citizen.CreateThread(function()
    vRP.execute("vRP/add_biography_column", "ALTER TABLE godz_user_identities ADD COLUMN IF NOT EXISTS biography TEXT")
end)

--[ FUNÇÕES ]----------------------------------------------------------------------------------------------------------------------------

function vRPN.Identidade()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local banco = vRP.getBankMoney(user_id)
		local identity = vRP.getUserIdentity(user_id)
		local multas = vRP.getUData(user_id,"vRP:multas")
		local mymultas = json.decode(multas) or 0

		local groupv = vRPN.getUserGroupByType(user_id,"job")
		local cargo = vRPN.getUserGroupByType(user_id,"hie")

		if groupv == "" and cargo == "" then
			groupv = "Desempregado"
		end

		if cargo ~= "" then
			groupv = cargo
		end

		local cnh = "Inválido"
		if identity.driverlicense == 0 then
			cnh = "Não habilitado"
		elseif identity.driverlicense == 1 then
			cnh = "Habilitado"
		elseif identity.driverlicense == 3 then
			cnh = "Cassada"
		end
        
        -- Fallback para biografia
        local bio = identity.biography or "Cidadão de Los Santos."

		if identity then
			return identity.foto,identity.name,identity.firstname,identity.user_id,identity.registration,identity.age,identity.phone,vRP.format(parseInt(banco)),vRP.format(parseInt(mymultas)),groupv,cnh,bio
		end
	end
end

-- LORE GENERATOR (AI)
function vRPN.generateLore(name, firstname, age, job)
    local p = promise.new()
    local prompt = "Crie uma breve biografia (máximo 3 linhas) para um personagem de GTA RP chamado " .. name .. " " .. firstname .. ", " .. age .. " anos, que trabalha como " .. job .. ". O tom deve ser imersivo."
    
    PerformHttpRequest("http://localhost:5000/ai_assist", function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            if data and data.response then
                p:resolve(data.response)
            else
                p:resolve("Cidadão misterioso de Los Santos.")
            end
        else
            p:resolve("Cidadão de Los Santos.")
        end
    end, "POST", json.encode({
        question = prompt,
        user_id = 0 -- ID temporário
    }), { ["Content-Type"] = "application/json" })
    
    return Citizen.Await(p)
end

function vRPN.saveBiography(user_id, bio)
    vRP.execute("vRP/update_biography", { user_id = user_id, biography = bio })
end

-- Prepare Queries
vRP.prepare("vRP/update_biography", "UPDATE godz_user_identities SET biography = @biography WHERE user_id = @user_id")
vRP.prepare("vRP/add_biography_column", "ALTER TABLE godz_user_identities ADD COLUMN IF NOT EXISTS biography TEXT")

function vRPN.nuIdentidade()

	local source = source
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source,2)
	local nuser_id = vRP.getUserId(nplayer)
	if nplayer then
		local identitynu = vRP.getUserIdentity(nuser_id)
		
		if user_id then
			local identity = vRP.getUserIdentity(user_id)
			local message = "**Quem Verificou:** " .. identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]\n**Verificado:** " .. identitynu.name .. " " .. identitynu.firstname .. " [" .. nuser_id .. "]"
			TriggerEvent("godz_logs:send", "Inventory", "Identidade Verificada", message, 3066993, source)
		end

		local cnh = "Inválido"
		if identitynu.driverlicense == 0 then
			cnh = "Não habilitado"
		elseif identitynu.driverlicense == 1 then
			cnh = "Habilitado"
		elseif identitynu.driverlicense == 3 then
			cnh = "Cassada"
		end

		if identitynu then
			return identitynu.foto,identitynu.name,identitynu.firstname,identitynu.registration,identitynu.age,cnh
		end
	end
end

function vRPN.modifyIdentidade()
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	
	if user_id then
		if vRP.getInventoryItemAmount(user_id,"passaporte") >= 1 then
			local nome = vRP.prompt(source,"Qual é o nome? ( Preencha com atençao! )", "")
			if nome ~= "" then
				local sobrenome = vRP.prompt(source,"Qual é o sobrenome? ( Preencha com atençao! )", "")
				if sobrenome ~= "" then
					local idade = vRP.prompt(source,"Qual é a sua idade? ( Preencha com atençao! )", "")
					if idade ~= "" then
						local checkIdade = idade
						if idade >= "18" and idade <= "90" then

							vRP.execute("vRP/update_user_identity",{
								user_id = user_id,
								firstname = sobrenome,
								name = nome,
								age = idade,
								registration = identity.registration,
								phone = identity.phone
							})

							vRP.tryGetInventoryItem(user_id,"passaporte",1)
                            local message = "**Jogador:** " .. identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]\n**Novo Nome:** " .. nome .. " " .. sobrenome .. "\n**Nova Idade:** " .. idade
                            TriggerEvent("godz_logs:send", "Inventory", "Identidade Atualizada", message, 3066993, source)
							TriggerClientEvent("Notify",source,"sucesso","Você foi cadastrado no sistema do governo com sucesso!.",8000)
							return true
						else
							TriggerClientEvent("Notify",source,"negado","Sua idade não pode ser menor que 18 ou maior que 90.",8000)
							return false
						end
					else
						TriggerClientEvent("Notify",source,"negado","Você precisa dizer a sua idade!",8000)
						return false
					end
				else
					TriggerClientEvent("Notify",source,"negado","Você precisa dizer o seu sobrenome!",8000)
					return false
				end
			else
				TriggerClientEvent("Notify",source,"negado","Você precisa dizer o seu nome!",8000)
				return false
			end
		else
			TriggerClientEvent("Notify",source,"negado","Você precisa de um passaporte para iniciar o cadastro na cidade.",8000)
			return false
		end
	end
end

function vRPN.getUserGroupByType(user_id,gtype)
	local user_groups = vRP.getUserGroups(user_id)
	for k,v in pairs(user_groups) do
		local kgroup = groups[k]
		if kgroup then
			if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
				return kgroup._config.title
			end
		end
	end
	return ""
end