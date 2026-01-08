Config = {}

-- Webhooks (Substitua pelas URLs reais)
Config.Webhooks = {
    JoinLeave = "",
    Deaths = "",
    Chat = "",
    Admin = "https://discord.com/api/webhooks/1458221676184469504/PFK2PVXWYTeX_NCFD_UEA1QCacxTY1h2YTkeNKPIcdfQdB8dVyEwo3ARF50m5KWmfBS9", -- Usando Staff como Admin/Geral
    Anticheat = "https://discord.com/api/webhooks/1458221652046250044/ercvfHRBg58IHJiHV8eoboDUq8igFHW_x8M-hV1IYO-0CObhjZ9eNq0RoJuk3HxBXBD-",
    Inventory = "https://discord.com/api/webhooks/1458221642391228569/DuExYvz5iCHII9uT8ld5FV90gchEWcwjXZv1bfALWjGk0CFmJemcgt7Te_OQhiSxanxB", -- Usando Audit para Inventory
    Bank = "https://discord.com/api/webhooks/1458221658723582057/_RYQ4tvETWgSBZcI26P_DDEb5K0nCdcZvG5ZWgx1yS869HyChMY-tpio0BXtnRptVHTf",
    Audit = "https://discord.com/api/webhooks/1458221642391228569/DuExYvz5iCHII9uT8ld5FV90gchEWcwjXZv1bfALWjGk0CFmJemcgt7Te_OQhiSxanxB" -- Added explicit Audit
}

-- Cores dos Embeds (Decimal)
Config.Colors = {
    Green = 3066993,
    Red = 15158332,
    Blue = 3447003,
    Yellow = 16776960,
    Orange = 15105570,
    Grey = 9807270
}

-- Configurações Gerais
Config.LogIP = false -- Se true, mostra o IP nos logs (cuidado com privacidade/lives)
