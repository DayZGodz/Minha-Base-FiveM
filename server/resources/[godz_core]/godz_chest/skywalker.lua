local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

--[ CONEXÃO ]-----------------------------------------------------------------------------------------------------------------------------------------------------------

src = {}
Tunnel.bindInterface("godz_chest",src)
vCLIENT = Tunnel.getInterface("godz_chest")

--[ VARIAVEIS ]---------------------------------------------------------------------------------------------------------------------------------------------------------

local logBauDmla = ""
local logDplaArsenal = ""
local logDplaEvidencias = ""

--[ CHEST ]-------------------------------------------------------------------------------------------------------------------------------------------------------------

local chest = {
	["ems"] = { 5000,"ems.permissao" },
	["policia-arsenal"] = { 5000,"policia.permissao" },
	["policia-evidencias"] = { 5000,"policia.permissao" },
}

--[ VARIÁVEIS ]---------------------------------------------------------------------------------------------------------------------------------------------------------

local actived = {}

--[ ACTIVEDOWNTIME ]----------------------------------------------------------------------------------------------------------------------------------------------------

local actived = {}
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(actived) do
			if actived[k] > 0 then
				actived[k] = v - 1
				if actived[k] <= 0 then
					actived[k] = nil
				end
			end
		end
		Citizen.Wait(100)
	end
end)

--[ CHECKINTPERMISSIONS ]-----------------------------------------------------------------------------------------------------------------------------------------------

function src.checkIntPermissions(chestName)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if not vRP.searchReturn(source,user_id) then
			if vRP.hasPermission(user_id,"policia.permissao") then
				return true
			end

			if vRP.hasPermission(user_id,chest[chestName][2]) then
				return true
			end
		end
	end
	return false
end

--[ OPENCHEST ]---------------------------------------------------------------------------------------------------------------------------------------------------------

function src.openChest(chestName)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local hsinventory = {}
		local myinventory = {}
		local data = vRP.getSData("chest:"..tostring(chestName))
		local result = json.decode(data) or {}
		if result then
			for k,v in pairs(result) do
				if vRP.itemBodyList(k) then
					table.insert(hsinventory,{ amount = parseInt(v.amount), name = vRP.itemNameList(k), index = vRP.itemIndexList(k), key = k, peso = vRP.getItemWeight(k) })
				end
			end

			local inv = vRP.getInventory(parseInt(user_id))
			for k,v in pairs(inv) do
				if vRP.itemBodyList(k) then
					table.insert(myinventory,{ amount = parseInt(v.amount), name = vRP.itemNameList(k), index = vRP.itemIndexList(k), key = k, peso = vRP.getItemWeight(k) })
				end
			end
		end
		return hsinventory,myinventory,vRP.getInventoryWeight(user_id),vRP.getInventoryMaxWeight(user_id),vRP.computeItemsWeight(result),parseInt(chest[tostring(chestName)][1])
	end
	return false
end

vRP.prepare("factions_inv/get","SELECT item, amount FROM godz_factions_inventory WHERE chest_key = @key")
vRP.prepare("factions_inv/get_item","SELECT amount FROM godz_factions_inventory WHERE chest_key = @key AND item = @item")
vRP.prepare("factions_inv/upsert","INSERT INTO godz_factions_inventory(chest_key,item,amount) VALUES(@key,@item,@amount) ON DUPLICATE KEY UPDATE amount = amount + @amount")
vRP.prepare("factions_inv/set_amount","UPDATE godz_factions_inventory SET amount = @amount WHERE chest_key = @key AND item = @item")
vRP.prepare("factions_inv/cleanup","DELETE FROM godz_factions_inventory WHERE chest_key = @key AND amount <= 0")

Citizen.CreateThread(function()
    Wait(1500)
    if exports and exports.oxmysql and exports.oxmysql.execute then
        exports.oxmysql:execute([[CREATE TABLE IF NOT EXISTS `godz_factions_inventory` (
            `chest_key` varchar(100) NOT NULL,
            `item` varchar(100) NOT NULL,
            `amount` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`chest_key`,`item`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
    end
end)

local function factionChestWeight(key)
    local rows = vRP.query("factions_inv/get",{ key = key })
    local w = 0
    for _,r in pairs(rows) do
        if vRP.itemBodyList(r.item) then
            w = w + vRP.getItemWeight(r.item) * parseInt(r.amount)
        end
    end
    return w
end

function src.openFactionChest(chestName)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local hsinventory = {}
        local myinventory = {}
        local rows = vRP.query("factions_inv/get",{ key = tostring(chestName) })
        for _,v in pairs(rows) do
            if vRP.itemBodyList(v.item) then
                table.insert(hsinventory,{ amount = parseInt(v.amount), name = vRP.itemNameList(v.item), index = vRP.itemIndexList(v.item), key = v.item, peso = vRP.getItemWeight(v.item) })
            end
        end
        local inv = vRP.getInventory(parseInt(user_id))
        for k,v in pairs(inv) do
            if vRP.itemBodyList(k) then
                table.insert(myinventory,{ amount = parseInt(v.amount), name = vRP.itemNameList(k), index = vRP.itemIndexList(k), key = k, peso = vRP.getItemWeight(k) })
            end
        end
        local peso2 = factionChestWeight(tostring(chestName))
        return hsinventory,myinventory,vRP.getInventoryWeight(user_id),vRP.getInventoryMaxWeight(user_id),peso2,5000
    end
    return false
end

function src.storeFactionItem(chestName,itemName,amount)
    if itemName then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            local cap = 5000
            local peso2 = factionChestWeight(tostring(chestName))
            local addw = vRP.getItemWeight(itemName) * parseInt(amount)
            if peso2 + addw <= cap then
                if vRP.tryGetInventoryItem(user_id,itemName,amount) then
                    vRP.execute("factions_inv/upsert",{ key = tostring(chestName), item = itemName, amount = parseInt(amount) })
                    TriggerClientEvent("Chest:UpdateChest",source,"updateChest")
                else
                    TriggerClientEvent("Notify",source,"negado","Você precisa especificar a quantidade.",10000)
                end
            else
                TriggerClientEvent("Notify",source,"negado","Baú cheio.",10000)
            end
        end
    end
end

function src.takeFactionItem(chestName,itemName,amount)
    if itemName then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            local rows = vRP.query("factions_inv/get_item",{ key = tostring(chestName), item = itemName })
            local have = 0
            if rows[1] then have = parseInt(rows[1].amount) end
            local amt = parseInt(amount)
            if amt <= 0 or have < amt then
                TriggerClientEvent("Notify",source,"negado","Quantidade inválida.",10000)
                return
            end
            if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(itemName) * amt <= vRP.getInventoryMaxWeight(user_id) then
                vRP.execute("factions_inv/set_amount",{ key = tostring(chestName), item = itemName, amount = have - amt })
                vRP.execute("factions_inv/cleanup",{ key = tostring(chestName) })
                vRP.giveInventoryItem(user_id,itemName,amt)
                TriggerClientEvent("Chest:UpdateChest",source,"updateChest")
            else
                TriggerClientEvent("Notify",source,"negado","Mochila cheia.",10000)
            end
        end
    end
end
--[ STOREITEM ]---------------------------------------------------------------------------------------------------------------------------------------------------------

function src.storeItem(chestName,itemName,amount)
    if itemName then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
			if vRP.storeChestItem(user_id,"chest:"..tostring(chestName),itemName,amount,chest[tostring(chestName)][1]) then
				local identity = vRP.getUserIdentity(user_id)
				if identity then
                    local message = "**Jogador:** " .. identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]\n**Baú:** " .. chestName .. "\n**Item:** " .. vRP.itemNameList(itemName) .. "\n**Quantidade:** " .. parseInt(amount)
                    TriggerEvent("godz_logs:send", "Inventory", "Item Guardado no Baú", message, 3066993, source)
                    TriggerEvent("godz_factions:updateFarm", user_id, parseInt(amount))
				end
				TriggerClientEvent("Chest:UpdateChest",source,"updateChest")
			else
				TriggerClientEvent("Notify",source,"negado","Você precisa especificar a quantidade.",10000)
            end
        end
    end
end

--[ TAKEITEM ]----------------------------------------------------------------------------------------------------------------------------------------------------------

function src.takeItem(chestName,itemName,amount)
    if itemName then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
			if vRP.tryChestItem(user_id,"chest:"..tostring(chestName),itemName,amount) then
				local identity = vRP.getUserIdentity(user_id)
				if identity then
                    local message = "**Jogador:** " .. identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]\n**Baú:** " .. chestName .. "\n**Item:** " .. vRP.itemNameList(itemName) .. "\n**Quantidade:** " .. parseInt(amount)
                    TriggerEvent("godz_logs:send", "Inventory", "Item Retirado do Baú", message, 15105570, source)
				end
				TriggerClientEvent("Chest:UpdateChest",source,"updateChest")
			else
				TriggerClientEvent("Notify",source,"negado","Você precisa especificar a quantidade.",10000)
            end
        end
    end
end
