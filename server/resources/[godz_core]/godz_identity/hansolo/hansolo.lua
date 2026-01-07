local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPNserver = Tunnel.getInterface("godz_identity")

--[ NUI CALLBACKS ]----------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback("generateLore", function(data, cb)
    local lore = vRPNserver.generateLore(data.name, data.firstname, data.age, data.job)
    cb({ lore = lore })
end)

RegisterNUICallback("createCharacter", function(data, cb)
    local success, message = vRPNserver.createCharacter(data.name, data.firstname, data.age, data.job, data.bio, data.slot)
    if success then
        -- Refresh characters
        local characters = vRPNserver.getCharacters()
        cb({ success = true, characters = characters })
    else
        cb({ success = false, message = message })
    end
end)

RegisterNUICallback("playCharacter", function(data, cb)
    -- Logic to select character (Simulated for now)
    TriggerEvent("Notify", "sucesso", "Personagem selecionado: " .. data.user_id)
    SendNUIMessage({ action = "hide" })
    SetNuiFocus(false, false)
    cb('ok')
end)

--[ COMANDOS ]---------------------------------------------------------------------------------------------------------------------------

local showRG = false
RegisterCommand("rg", function(source, args)
    if showRG then
        showRG = false
        SendNUIMessage({ action = "hide" })
        SetNuiFocus(false, false)
    else
        -- Fetch data
        local foto, name, firstname, user_id, registration, age, phone, banco, multas, groupname, cnh, bio = vRPNserver.Identidade()
        
        if user_id then
            showRG = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openRG",
                foto = foto,
                nome = name,
                sobrenome = firstname,
                user_id = user_id,
                registro = registration,
                idade = age,
                emprego = groupname,
                biografia = bio
            })
        end
    end
end)

RegisterCommand("char", function(source, args)
    local characters = vRPNserver.getCharacters()
    SetNuiFocus(true, true)
    SendNUIMessage({ 
        action = "openMulticharacter",
        characters = characters
    })
end)

-- Tecla F11 para abrir RG (Legacy support)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0,344) then
            ExecuteCommand("rg")
		end
	end
end)

--[ LOCALIZAÇÕES ]-----------------------------------------------------------------------------------------------------------------------

local ponto = {
	{ ['x'] = -552.85, ['y'] = -190.74, ['z'] = 38.22 }
}

Citizen.CreateThread(function()
	while true do
		local idle = 1000
		for k,v in pairs(ponto) do
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
			local distance = GetDistanceBetweenCoords(v.x,v.y,cdz,x,y,z,true)
			local ponto = ponto[k]

			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), ponto.x, ponto.y, ponto.z, true ) < 5.1 then
				DrawText3D(ponto.x, ponto.y, ponto.z, "Pressione [~p~E~w~] para abrir o ~p~MULTICHARACTER (Demo)~w~.")
			end
			
			if distance < 10.1 then
				DrawMarker(23,ponto.x,ponto.y,ponto.z-0.99,0,0,0,0,0,0,0.7,0.7,0.5,136, 96, 240, 180,0,0,0,0)
				idle = 5
				if distance < 1.2 then
					if IsControlJustPressed(0,38) then
						ExecuteCommand("char")
					end
				end
			end
		end
		Citizen.Wait(idle)
	end
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end