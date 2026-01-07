Config = {}

Config.Drugs = {
    Cocaine = {
        processPos = vector3(1090.54, -3196.60, -38.99), -- Example coords
        input = "pasta_base",
        output = "cocaina",
        amountInput = 5,
        amountOutput = 1,
        time = 10000, -- ms
        animDict = "anim@amb@business@coc@coc_unpack_cut@",
        animName = "fullcut_cycle_v6_cokecutter",
        prop = "prop_coke_block_01"
    },
    Meth = {
        processPos = vector3(997.02, -3200.74, -36.39),
        input = "metilamina",
        output = "metafetamina",
        amountInput = 5,
        amountOutput = 1,
        time = 10000,
        animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
        animName = "chemical_pour_long_cooker",
        prop = "bkr_prop_meth_smashed"
    }
}

Config.ChopShop = {
    zone = vector3(-429.54, -1728.46, 19.78),
    radius = 10.0,
    parts = {
        { name = "Porta", item = "porta_veiculo", animDict = "mini@repair", animName = "fixing_a_ped", duration = 5000 },
        { name = "Capô", item = "capo_veiculo", animDict = "mini@repair", animName = "fixing_a_ped", duration = 5000 },
        { name = "Roda", item = "roda_veiculo", animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", animName = "machinic_loop_mechandplayer", duration = 5000 },
        { name = "Motor", item = "motor_veiculo", animDict = "mini@repair", animName = "fixing_a_ped", duration = 7000 }
    },
    allowedClasses = { 0, 1, 2, 3, 4, 5, 6, 7, 9 } -- Car classes
}

Config.Factions = {
    ["Ballas"] = { type = "gang", coords = vector3(100.0, -1900.0, 20.0) },
    ["Vagos"] = { type = "gang", coords = vector3(300.0, -2000.0, 20.0) },
    ["Mafia"] = { type = "mafia", coords = vector3(-50.0, -2500.0, 20.0) }
}
