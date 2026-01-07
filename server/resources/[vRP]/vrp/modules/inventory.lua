
vRP.items = {}

function vRP.defInventoryItem(idname,name,weight)
	if weight == nil then
		weight = 0
	end
	vRP.items[idname] = { name = name, weight = weight }
end
