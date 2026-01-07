Config = {}

Config.TuningLocations = {
    { x = -337.0, y = -136.8, z = 39.0 }, -- LSCustoms Centro
    { x = 732.0, y = -1088.0, z = 22.1 }, -- LSCustoms Sul
    { x = -1155.0, y = -2006.0, z = 13.1 } -- LSCustoms Aeroporto
}

Config.Categories = {
    { label = "Motor", name = "engine", icon = "fas fa-cogs" },
    { label = "Transmissão", name = "transmission", icon = "fas fa-random" },
    { label = "Freios", name = "brakes", icon = "fas fa-stop-circle" },
    { label = "Suspensão", name = "suspension", icon = "fas fa-compress-arrows-alt" },
    { label = "Blindagem", name = "armor", icon = "fas fa-shield-alt" },
    { label = "Turbo", name = "turbo", icon = "fas fa-tachometer-alt" },
    -- Estética
    { label = "Pintura", name = "color", icon = "fas fa-palette" },
    { label = "Rodas", name = "wheels", icon = "fas fa-compact-disc" },
    { label = "Janelas", name = "window", icon = "fas fa-window-maximize" }
}

-- Mapeamento de níveis (0 = livre)
Config.LevelRequirements = {
    engine = {
        [0] = 0, -- Stock
        [1] = 2, -- Level 1
        [2] = 5, -- Level 2
        [3] = 10, -- Level 3
        [4] = 20  -- Level 4 (GODZ)
    },
    turbo = {
        [false] = 0,
        [true] = 15 -- Só mecânicos lvl 15+ instalam turbo
    },
    transmission = {
        [0] = 0,
        [1] = 2,
        [2] = 5,
        [3] = 10
    },
    brakes = {
        [0] = 0,
        [1] = 2,
        [2] = 5,
        [3] = 10
    }
}
