----------------------------------------------------------
-- [GERAL]
----------------------------------------------------------
vRP.prepare("database/imgProfile", "SELECT * FROM godz_user_identities WHERE user_id = @user_id")
----------------------------------------------------------
-- [GARAGEM]
----------------------------------------------------------
vRP.prepare("garagem/get_inroad","SELECT * FROM godz_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("garagem/get_vehicle_inroad","SELECT * FROM godz_user_vehicles WHERE user_id = @user_id AND in_road = @in_road")
vRP.prepare("garagem/up_inroad","UPDATE godz_user_vehicles SET in_road = @in_road WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("garagem/reset_inroad","UPDATE godz_user_vehicles SET in_road = @in_road")
vRP.prepare("garagem/reset_player_inroad","UPDATE godz_user_vehicles SET in_road = @in_road WHERE user_id = @user_id")

vRP.prepare("creative/get_vehicle","SELECT * FROM godz_user_vehicles WHERE user_id = @user_id")
vRP.prepare("creative/rem_vehicle","DELETE FROM godz_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("creative/get_vehicles","SELECT * FROM godz_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND alugado = 0")
-- vRP.prepare("creative/set_update_vehicles","UPDATE godz_user_vehicles SET engine = @engine, body = @body, fuel = @fuel WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("creative/set_update_vehicles","UPDATE godz_user_vehicles SET engine = @engine, body = @body, fuel = @fuel, damage_state = @damage_state WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("creative/set_detido","UPDATE godz_user_vehicles SET detido = @detido, time = @time WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("creative/set_ipva","UPDATE godz_user_vehicles SET ipva = @ipva WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("creative/move_vehicle","UPDATE godz_user_vehicles SET user_id = @nuser_id WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("creative/add_vehicle","INSERT IGNORE INTO godz_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
vRP.prepare("creative/con_maxvehs","SELECT COUNT(vehicle) as qtd FROM godz_user_vehicles WHERE user_id = @user_id")
vRP.prepare("creative/rem_srv_data","DELETE FROM godz_srv_data WHERE dkey = @dkey")
vRP.prepare("creative/get_estoque","SELECT * FROM godz_estoque WHERE vehicle = @vehicle")
vRP.prepare("creative/set_estoque","UPDATE godz_estoque SET estoque = @estoque WHERE vehicle = @vehicle")
vRP.prepare("creative/get_users","SELECT * FROM godz_users WHERE id = @user_id")
vRP.prepare("creative/up_garage","UPDATE godz_users SET garagem = @garagem WHERE id = @id")
------------------------------------------------------------
-- [LOJA VIP]
------------------------------------------------------------
-- vRP.prepare("vRP/select_steam","SELECT * FROM godz_user_ids")
vRP.prepare("vRP/userid","SELECT user_id FROM godz_user_ids WHERE identifier = @identifier")
vRP.prepare("vRP/get_user_vip_active","SELECT user_id FROM godz_vips WHERE user_id = @user_id AND data_contrat <= @data_contrat")
vRP.prepare("vRP/insert_new_vip","INSERT IGNORE INTO godz_vips(user_id,vipName,data_contrat) VALUES (@user_id,@vipName,@data_contrat)")
vRP.prepare("vRP/delete_user_vip","DELETE FROM godz_vips WHERE user_id = @user_id")
vRP.prepare("creative/get_estoque_vip","SELECT * FROM godz_lojavip WHERE vehicle = @vehicle")
vRP.prepare("creative/set_estoque_vip","UPDATE godz_lojavip SET estoque = @estoque WHERE vehicle = @vehicle")
