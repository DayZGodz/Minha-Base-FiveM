Config = {}

-- Permissão de Administrador que bypassa as proteções
Config.AdminPermission = "admin.permissao"

-- Armas Proibidas (Blacklist)
-- Formato: [WEAPON_NAME] = true
Config.WeaponBlacklist = {
    ["WEAPON_RPG"] = true,
    ["WEAPON_MINIGUN"] = true,
    ["WEAPON_GRENADE"] = true,
    ["WEAPON_STICKYBOMB"] = true,
    ["WEAPON_RAILGUN"] = true,
    ["WEAPON_COMPACTLAUNCHER"] = true,
    ["WEAPON_HOMINGLAUNCHER"] = true,
    ["WEAPON_PROXIMITYMINE"] = true,
    ["WEAPON_PIPEBOMB"] = true
}

-- Eventos Sensíveis para Monitorar (Honeypots/Proteção)
Config.SensitiveEvents = {
    "vRP:giveMoney",
    "vRP:giveInventoryItem",
    "vRP:setGroup",
    "vRP:adminConsole",
    "vRP:teleportToPlayer"
}

-- Mensagens
Config.Messages = {
    WeaponRemoved = "SEGURANÇA: Arma proibida detectada e removida.",
    Banned = "Você foi banido automaticamente pelo Unity Shield. Motivo: Tentativa de Trigger Malicioso.",
    InvalidName = "Seu nome contém caracteres inválidos. Por favor, remova símbolos especiais."
}
