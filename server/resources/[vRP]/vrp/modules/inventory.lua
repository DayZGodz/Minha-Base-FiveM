
vRP.items = {}

function vRP.defInventoryItem(idname,name,weight)
	if weight == nil then
		weight = 0
	end
	if vRP.items[idname] then
		print("[vRP] AVISO: Item duplicado detectado ("..idname.."). Sobrescrevendo definição anterior para evitar conflitos.")
	end
	vRP.items[idname] = { name = name, weight = weight }
end
