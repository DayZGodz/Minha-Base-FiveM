local Config = {}

Config.Command = "faccao" -- Command to open the menu

-- Definition of Factions
-- [FactionID] = { name = "Display Name", leaderGroup = "groupName", memberGroup = "groupName" }
Config.Factions = {
    ["police"] = {
        name = "Polícia Militar",
        leaderGroup = "comandante", -- Example leader group
        memberGroup = "policia"     -- Example member group
    },
    ["medico"] = {
        name = "Hospital",
        leaderGroup = "diretor",
        memberGroup = "medico"
    },
    ["burguer"] = {
        name = "BurguerShot",
        leaderGroup = "burguer1",
        memberGroup = "burguer"
    }
}

return Config
