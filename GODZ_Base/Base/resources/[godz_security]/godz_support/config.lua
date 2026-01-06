Config = {}

Config.Webhooks = {
    Tickets = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE", -- Configure no Discord
    Productivity = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
}

Config.Command = "calladmin"

Config.Categories = {
    { id = "bug", label = "🐛 Reportar Bug", description = "Encontrei um erro no sistema", ai_assist = false },
    { id = "denuncia", label = "🚨 Denúncia", description = "Anti-RP ou quebra de regras", ai_assist = false },
    { id = "duvida", label = "❓ Dúvida", description = "Ajuda sobre comandos ou regras", ai_assist = true },
    { id = "suporte", label = "🔧 Suporte Técnico", description = "Problemas de conexão ou FPS", ai_assist = true }
}

Config.Messages = {
    TicketOpened = "Seu ticket foi aberto! Aguarde atendimento.",
    AISuggestion = "O GODZ AI encontrou uma possível solução. Isso ajudou?",
    TicketClosed = "Ticket fechado com sucesso."
}
