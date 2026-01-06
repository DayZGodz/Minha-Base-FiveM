Config = {}

Config.MaxLevel = 100
Config.XPFormula = function(level)
    return math.floor(100 * (level ^ 1.5)) -- Curva de XP
end

Config.Jobs = {
    ["lixeiro"] = {
        label = "Lixeiro",
        description = "Coleta de resíduos pela cidade.",
        icon = "fas fa-trash-alt",
        npc = {
            model = "s_m_y_garbage",
            coords = vector4(-322.09, -1546.11, 31.02, 271.85), -- Exemplo
        },
        salary_base = 500,
        xp_per_route = 50,
        bonus_per_level = 10 -- +$10 por nível
    },
    ["entregador"] = {
        label = "Entregador",
        description = "Entregas rápidas de encomendas.",
        icon = "fas fa-box",
        npc = {
            model = "a_m_m_courier_01",
            coords = vector4(78.86, 112.04, 81.16, 160.0), -- Exemplo
        },
        salary_base = 400,
        xp_per_route = 40,
        bonus_per_level = 8
    },
    ["caminhoneiro"] = {
        label = "Caminhoneiro",
        description = "Transporte de cargas pesadas.",
        icon = "fas fa-truck",
        npc = {
            model = "s_m_m_trucker_01",
            coords = vector4(1197.35, -3253.64, 7.1, 88.6), -- Exemplo
        },
        salary_base = 1200,
        xp_per_route = 100,
        bonus_per_level = 25
    }
}

Config.Routes = {
    -- Pontos genéricos de entrega para teste
    vector3(-429.62, -1728.32, 19.78),
    vector3(154.67, -1662.91, 29.29),
    vector3(366.52, -1071.69, 29.41),
    vector3(-592.74, -929.83, 23.87)
}
