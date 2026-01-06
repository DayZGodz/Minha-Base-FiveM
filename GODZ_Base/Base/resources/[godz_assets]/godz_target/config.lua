Config = {}

Config.MaxDistance = 3.0
Config.Debug = false

-- Key to enable target (Default: LALT)
Config.TargetKey = 19 

-- Global Targets (Integrations)
Config.GlobalTargets = {
    -- ATMs
    ["atm"] = {
        models = {
            "prop_atm_01", "prop_atm_02", "prop_atm_03", "prop_fleeca_atm", 
            "prop_atm_01_cr", "prop_atm_02_cr", "prop_atm_03_cr"
        },
        options = {
            {
                event = "godz_bank:open",
                icon = "fas fa-credit-card",
                label = "Acessar Banco"
            }
        }
    },
    -- Police Vehicles
    ["police_vehicle"] = {
        models = {
            "police", "police2", "police3", "police4", "fbi", "fbi2", "sheriff", "sheriff2", "pbus", "polmav"
        },
        options = {
            {
                event = "godz_mdt:openFromVehicle",
                icon = "fas fa-tablet-alt",
                label = "Abrir MDT"
            }
        }
    },
    -- Ambulances
    ["ambulance"] = {
        models = {
            "ambulance"
        },
        options = {
            {
                event = "godz_ems:toggleStretcher",
                icon = "fas fa-bed",
                label = "Pegar/Guardar Maca"
            }
        }
    },
    -- Players
    ["player"] = {
        options = {
            {
                event = "godz_police:search", -- Assuming this event exists or will be created
                icon = "fas fa-search",
                label = "Revistar",
                job = "policia" -- Job check to be implemented in client if needed, or check in event
            }
        }
    }
}
