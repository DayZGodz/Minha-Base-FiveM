Config = {}

Config.Debug = false

-- Shell Offsets (Spawn location relative to entry, or absolute if we use buckets)
-- Since we use buckets, we can spawn everyone at the same coordinate deep under map.
Config.SpawnCoords = vector3(0.0, 0.0, -100.0)

Config.Shells = {
    ["shell_v16_low"] = { model = "shell_v16_low", price = 50000 },
    ["shell_v16_mid"] = { model = "shell_v16_mid", price = 150000 },
    ["shell_v16_high"] = { model = "shell_v16_high", price = 500000 },
    ["shell_lester"] = { model = "shell_lester", price = 300000 },
    ["shell_ranch"] = { model = "shell_ranch", price = 250000 },
    ["shell_trevor"] = { model = "shell_trevor", price = 200000 }
}

Config.Furniture = {
    { label = "Sofá Moderno", model = "prop_lev_des_couch_01", price = 1500, category = "sala" },
    { label = "Mesa de Centro", model = "prop_t_coffe_table_02", price = 500, category = "sala" },
    { label = "TV Plasma", model = "prop_tv_flat_01", price = 2500, category = "eletronicos" },
    { label = "Cama King", model = "prop_bed_double_05", price = 3000, category = "quarto" },
    { label = "Abajur", model = "prop_lamp_01", price = 200, category = "decoracao" },
    { label = "Geladeira", model = "prop_fridge_01", price = 1200, category = "cozinha" },
    { label = "Fogão", model = "prop_cooker_03", price = 1000, category = "cozinha" },
    { label = "Mesa Jantar", model = "prop_table_03", price = 800, category = "cozinha" },
    { label = "Cadeira", model = "prop_chair_02", price = 150, category = "sala" }
}

-- Initial Homes (Examples)
Config.Homes = {
    { name = "Eclipse Towers Apt 1", price = 250000, coords = vector3(-774.0, 312.0, 85.7), shell = "shell_v16_mid" },
    { name = "Alta St Apt 5", price = 150000, coords = vector3(-268.0, -960.0, 31.2), shell = "shell_v16_low" },
    { name = "Vinewood Hills Mansion", price = 5000000, coords = vector3(-685.0, 560.0, 135.0), shell = "shell_v16_high" }
}
