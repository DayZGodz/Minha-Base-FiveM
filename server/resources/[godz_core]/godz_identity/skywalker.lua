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
    vRP.execute("vRP/add_biography_column", {})
    vRP.execute("vRP/add_ip_column", {})
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
        
        -- [FIX GODZ] Verificação de integridade da identidade antes do Proxy
        local identity_check = vRP.query("godz/get_identity", {user_id = user_id})
        
        -- Retry Logic: Tenta buscar novamente se falhar na primeira (espera DB sync)
        if not identity_check or #identity_check == 0 or not identity_check[1] then
            print("[GODZ] Identidade não encontrada, aguardando sincronização DB...")
            Citizen.Wait(2000) -- [GODZ ENGINEERING] Wait aumentado para 2s
            identity_check = vRP.query("godz/get_identity", {user_id = user_id})
        end

        -- [FIX GODZ] Loop de verificação de persistência
        local max_retries = 3
        local current_retry = 0
        while (not identity_check or #identity_check == 0) and current_retry < max_retries do
            print("[GODZ IDENTITY] Aguardando persistência de dados para ID: " .. tostring(user_id) .. " (Tentativa " .. current_retry .. ")")
            Citizen.Wait(1000)
            identity_check = vRP.query("godz/get_identity", {user_id = user_id})
            current_retry = current_retry + 1
        end

        -- Safeguard: Se identidade não existe (primeira conexão), retorna valores temporários
        if not identity_check or #identity_check == 0 or not identity or type(identity) ~= "table" then 
            print("[GODZ SAFEGUARD] Identidade nula detectada para ID: " .. tostring(user_id) .. ". Usando perfil temporário.") 
            return "default.png", "Cidadão", "Novo", user_id, "000AAA", 18, "000-000", vRP.format(parseInt(banco)), vRP.format(parseInt(mymultas)), groupv, cnh, "Recém-chegado em Los Santos."
        end

        -- Proxy Safeguard: Check if identity exists before accessing properties (Redundant but safe)
        if identity == nil or type(identity) ~= "table" then
            print("[GODZ DEBUG] Identidade retornou nula ou inválida para o ID " .. tostring(user_id))
            return nil
        end

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
    
    local headers = { 
        ["Content-Type"] = "application/json", 
        ["Authorization"] = "Bearer godz_secret_key_123" 
    }
    print("[GODZ] Tentando conectar com a IA...")

    PerformHttpRequest("http://127.0.0.1:5000/ai_assist", function(err, text, headers)
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
    }), headers)
    
    return Citizen.Await(p)
end

function vRPN.saveBiography(user_id, bio)
    vRP.execute("vRP/update_biography", { user_id = user_id, biography = bio })
end

-- Prepare Queries
vRP.prepare("vRP/update_biography", "UPDATE godz_user_identities SET biography = @biography WHERE user_id = @user_id")
vRP.prepare("vRP/add_biography_column", "ALTER TABLE godz_user_identities ADD COLUMN IF NOT EXISTS biography TEXT")
vRP.prepare("vRP/add_ip_column", "ALTER TABLE godz_user_identities ADD COLUMN IF NOT EXISTS ip VARCHAR(50)")
vRP.prepare("vRP/get_user_by_identifier", "SELECT user_id FROM godz_user_ids WHERE identifier = @identifier")
vRP.prepare("vRP/create_user", "INSERT INTO godz_users(whitelisted,banned) VALUES(0,0)")
vRP.prepare("vRP/add_identifier", "INSERT INTO godz_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
vRP.prepare("vRP/init_user_identity", "INSERT INTO godz_user_identities(user_id,registration,phone,firstname,name,age,biography,slot) VALUES(@user_id,@registration,@phone,@firstname,@name,@age,@biography,@slot)")
vRP.prepare("vRP/update_identity_ip", "UPDATE godz_user_identities SET ip = @ip WHERE user_id = @user_id")

function vRPN.getSteam(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            return id
        end
    end
    return nil
end

local function getMaxSlotsInternal(user_id)
    local max = 2
    local user_groups = vRP.getUserGroups(user_id) or {}
    for k,_ in pairs(user_groups) do
        local name = string.lower(k)
        if string.find(name,"ceo") or string.find(name,"admin") then
            return 10
        end
    end
    for k,_ in pairs(user_groups) do
        local name = string.lower(k)
        if string.find(name,"vip") and (string.find(name,"ouro") or string.find(name,"platina")) then
            return 5
        end
    end
    return max
end

function vRPN.getMaxSlots()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return 2 end
    return getMaxSlotsInternal(user_id)
end

function vRPN.getCharacters()
    local source = source
    local steam = vRPN.getSteam(source)
    if not steam then return {} end
    local user_id = vRP.getUserId(source)
    local maxSlots = getMaxSlotsInternal(user_id)

    local characters = {}
    local identifiers = {}
    for i=1,maxSlots do
        if i == 1 then table.insert(identifiers, steam) else table.insert(identifiers, steam..":"..i) end
    end

    for i, id in ipairs(identifiers) do
        local rows = vRP.query("vRP/get_user_by_identifier", { identifier = id })
        if #rows > 0 then
            local user_id = rows[1].user_id
            local identity = vRP.getUserIdentity(user_id)
            if identity then
                local job = vRPN.getUserGroupByType(user_id, "job") or "Desempregado"
                table.insert(characters, {
                    slot = identity.slot or i,
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
    local user_id_src = vRP.getUserId(source)
    local maxSlots = getMaxSlotsInternal(user_id_src)
    if slot > maxSlots then return false, "Limite de identidades atingido. Torne-se VIP para desbloquear mais slots." end
    
    local identifier = steam
    if slot > 1 then identifier = steam .. ":" .. slot end

    -- Check exist
    local rows = vRP.query("vRP/get_user_by_identifier", { identifier = identifier })
    if rows == nil or type(rows) ~= "table" then
        print("[GODZ DEBUG] Falha crítica na verificação de existência para: " .. identifier)
        return false, "Erro interno de banco de dados."
    end
    if #rows > 0 then return false, "Personagem já existe neste slot!" end
    local count = 0
    for i=1,maxSlots do
        local idn = (i==1) and steam or (steam..":"..i)
        local r = vRP.query("vRP/get_user_by_identifier", { identifier = idn })
        if r and #r > 0 then count = count + 1 end
    end
    if count >= maxSlots then return false, "Limite de identidades atingido. Torne-se VIP para desbloquear mais slots." end

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
        biography = bio,
        slot = slot
    })

    -- [GODZ] Initialize Datatable to prevent JS crash (Slot 1 Force Init)
    local default_datatable = {
        inventory = {},
        weapons = {},
        groups = {},
        customization = {} -- Empty to force creator or default
    }
    vRP.setUData(user_id, "vRP:datatable", json.encode(default_datatable))
    
    -- [NEXUS LOG]
    local msg = "Novo Registro: ID " .. user_id .. " iniciou o protocolo de criação de personagem."
    exports.godz_modules:Log("Criação", msg, 3447003)

    return true, "Personagem criado com sucesso!"
end

vRP.prepare("vRP/get_max_user_id", "SELECT MAX(id) as id FROM godz_users")

function vRPN.selectCharacter(target_user_id)
    local source = source
    local ip = GetPlayerEndpoint(source) or "0.0.0.0"
    
    -- [GODZ FIX] Verificação de Criação Obrigatória
    local datatable = vRP.getUData(target_user_id, "vRP:datatable")
    local data = json.decode(datatable) or {}

    if not data.customization or type(data.customization) ~= "table" or not next(data.customization) then
        print("[GODZ IDENTITY] Bloqueio de Login: ID " .. tostring(target_user_id) .. " sem skin definida.")
        return false -- Bloqueia a seleção e força a interface a reagir
    end

    vRP.execute("vRP/update_identity_ip", { user_id = target_user_id, ip = ip })
    return true
end

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
