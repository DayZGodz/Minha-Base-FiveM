Config = {}

-- Configurações locais que não dependem da Master Config
Config.Debug = false

-- Zonas de Dominação (Exemplo)
Config.Zones = {
    ["biqueira_sul"] = {
        coords = vector3(100.0, -1900.0, 20.0),
        radius = 5.0,
        owner_group = "ballas", -- Será validado com Master Config
        farm_item = "folha_coca",
        farm_amount = 1
    }
}
