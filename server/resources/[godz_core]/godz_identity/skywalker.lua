local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRPN = {}
Tunnel.bindInterface("godz_identity",vRPN)
Proxy.addInterface("godz_identity",vRPN)

local cfg = module("vrp","cfg/groups")
local groups = {}
if cfg then
    groups = cfg.groups
else
    print("[GODZ IDENTITY] AVISO: Configuração de grupos (cfg/groups) não encontrada ou vazia.")
end

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
vRP.prepare("vRP/get_user_by_identifier", "SELECT user_id FROM godz_user_ids WHERE identifier = @identifier")
vRP.prepare("vRP/create_user", "INSERT INTO godz_users(whitelisted,banned) VALUES(0,0)")
vRP.prepare("vRP/add_identifier", "INSERT INTO godz_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
vRP.prepare("vRP/init_user_identity", "INSERT INTO godz_user_identities(user_id,registration,phone,firstname,name,age,biography) VALUES(@user_id,@registration,@phone,@firstname,@name,@age,@biography)")

function vRPN.getSteam(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            return id
        end
    end
    return nil
end

function vRPN.getCharacters()
    local source = source
    local steam = vRPN.getSteam(source)
    if not steam then return {} end

    local characters = {}
    local identifiers = { steam, steam..":2", steam..":3" }

    for i, id in ipairs(identifiers) do
        local rows = vRP.query("vRP/get_user_by_identifier", { identifier = id })
        if #rows > 0 then
            local user_id = rows[1].user_id
            local identity = vRP.getUserIdentity(user_id)
            if identity then
                local job = vRPN.getUserGroupByType(user_id, "job") or "Desempregado"
                table.insert(characters, {
                    slot = i,
                    user_id = user_id,
                    name = identity.name,
                    firstname = identity.firstname,
                    age = identity.age,
                    job = job,
                    foto = identity.foto,
                    biography = identity.biography
                })
            end
        end
    end
    return characters
end

function vRPN.createCharacter(name, firstname, age, job, bio, slot)
    local source = source
    local steam = vRPN.getSteam(source)
    if not steam then return false, "Steam não encontrada." end
    
    local identifier = steam
    if slot > 1 then identifier = steam .. ":" .. slot end

    -- Check exist
    local rows = vRP.query("vRP/get_user_by_identifier", { identifier = identifier })
    if #rows > 0 then return false, "Personagem já existe neste slot!" end

    -- Create User
    vRP.execute("vRP/create_user", {})
    -- Get inserted ID (Hack: select max id, assuming low concurrency)
    local res = vRP.query("vRP/get_users", {}) -- vRP usually doesn't expose get_last_insert_id directly via tunnel
    -- Better: We can't easily get the last ID without a specific query. 
    -- I'll define a query for LAST_INSERT_ID()
    
    -- Let's try to assume vRP.getUserId returns the one for the source if I could map it... but I can't.
    -- I'll add a query to get the max ID.
    local max_rows = vRP.query("vRP/get_max_user_id", {})
    local user_id = 1
    if #max_rows > 0 and max_rows[1].id then
        user_id = max_rows[1].id
    end
    
    -- Insert Identifier
    vRP.execute("vRP/add_identifier", { identifier = identifier, user_id = user_id })
    
    -- Init Identity
    local registration = vRP.generateRegistrationNumber()
    local phone = vRP.generatePhoneNumber()
    
    vRP.execute("vRP/init_user_identity", {
        user_id = user_id,
        registration = registration,
        phone = phone,
        firstname = firstname,
        name = name,
        age = age,
        biography = bio
    })
    
    return true, "Personagem criado com sucesso!"
end

vRP.prepare("vRP/get_max_user_id", "SELECT MAX(id) as id FROM godz_users")

function vRPN.checkIdentity()
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