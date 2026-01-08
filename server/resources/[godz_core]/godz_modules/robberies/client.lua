local shops = {
	[1] = { x = 25.76, y = -1345.5, z = 29.49, heading = 270.0 }, -- 24/7 Innocence
	[2] = { x = -709.17, y = -914.26, z = 19.21, heading = 90.0 }, -- LTD Little Seoul
	[3] = { x = -48.519, y = -1757.514, z = 29.421, heading = 50.0 }, -- Davis
	[4] = { x = 1163.373, y = -323.801, z = 69.205, heading = 100.0 }, -- Mirror Park
	[5] = { x = 373.875, y = 325.896, z = 103.566, heading = 255.0 }, -- Clinton
}

local robbing = false

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		if not robbing then
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			
			for k,v in pairs(shops) do
				local dist = #(coords - vector3(v.x,v.y,v.z))
				if dist < 1.5 then
					sleep = 5
					if IsPedArmed(ped, 4) then -- 4 = Guns
						DrawText3D(v.x,v.y,v.z+0.5, "~r~[E]~w~ ASSALTAR")
						if IsControlJustPressed(0,38) then
							startRobbery(k,v)
						end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

function startRobbery(id, shop)
	robbing = true
	TriggerServerEvent("godz_robberies:start", id)
	TriggerEvent("godz_interface:Notify","ia_tip","NEXUS","Violação de segurança detectada. Unidades táticas acionadas.",8000)
	
	local ped = PlayerPedId()
	-- Animation or Task
	-- Simple wait for now
	
	-- Progress
	local time = 20
	while time > 0 do
		Citizen.Wait(1000)
		time = time - 1
		DrawText3D(shop.x, shop.y, shop.z+0.5, "Roubando... "..time.."s")
		
		-- Check if still aiming/armed or dead
		if not IsPedArmed(ped, 4) or IsEntityDead(ped) then
			robbing = false
			TriggerEvent("Notify","negado","Assalto cancelado.")
			return
		end
		
		-- Check distance
		local coords = GetEntityCoords(ped)
		local dist = #(coords - vector3(shop.x,shop.y,shop.z))
		if dist > 5.0 then
			robbing = false
			TriggerEvent("Notify","negado","Você se afastou demais.")
			return
		end
	end
	
	TriggerServerEvent("godz_robberies:payment", id)
	robbing = false
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end