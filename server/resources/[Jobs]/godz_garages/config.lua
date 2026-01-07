Config = {}

Config.Debug = false

Config.WithdrawFee = 100 -- Taxa para retirar veículo
Config.InsurancePrice = 5000 -- Preço do seguro
Config.ImpoundFee = 2000 -- Taxa para retirar veículo apreendido (se liberado)

-- Modelos de NPC
Config.PedModel = "cs_bankman"

-- Garagens Públicas
Config.Garages = {
    ["Praca"] = {
        coords = vector3(215.12, -808.57, 30.73),
        heading = 250.0,
        spawnPoint = vector4(215.80, -801.0, 30.75, 250.0),
        type = "public"
    },
    ["Hospital"] = {
        coords = vector3(-449.67, -340.83, 34.50),
        heading = 80.0,
        spawnPoint = vector4(-455.5, -341.5, 34.5, 180.0),
        type = "public"
    },
    ["Policia"] = {
        coords = vector3(441.0, -981.0, 30.7),
        heading = 90.0,
        spawnPoint = vector4(435.0, -976.0, 30.7, 90.0),
        type = "service",
        perm = "policia.permissao"
    }
}
