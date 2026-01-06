# GODZ Project

## 🔧 Configuração Mestre (GODZ_MASTER_CONFIG.json)

O arquivo `GODZ_MASTER_CONFIG.json` foi refatorado para uma estrutura hierárquica e auto-explicativa para facilitar a manutenção e evitar erros.
**IMPORTANTE:** Mantenha a estrutura de blocos e observe as chaves `_desc` e `_hint` para entender o propósito de cada configuração.

### Estrutura dos Blocos
- **SERVER_SETTINGS**: Configurações gerais, tokens e economia base.
- **STAFF_PERMISSIONS**: Gerenciamento de acesso administrativo (CEOs, Admins, Moderadores).
- **SECURITY_CONFIG**: Listas de exceção (Whitelists) para os sistemas de segurança (Sentinel/Auditor).
- **WEBHOOKS**: URLs de integração com o Discord para logs e auditoria.

### Exemplo de Edição
Para alterar o token do bot ou preços de tuning, edite o bloco `SERVER_SETTINGS`:
```json
"SERVER_SETTINGS": {
    "discord_token": "SEU_NOVO_TOKEN_AQUI",
    "tuning_prices": {
        "turbo_base": 20000
    }
}
```

---

## 🏎️ GODZ Tuning (Customização de Alta Performance)

Recurso avançado de customização veicular integrado ao ecossistema GODZ.

### Funcionalidades
- **Interface Glassmorphism**: UI moderna e imersiva.
- **Sistema de Níveis**: Peças de alta performance (Turbo, Motor Pro) exigem nível alto de mecânico.
- **Persistência**: Modificações salvas automaticamente no banco de dados.
- **Integração Econômica**: Preços sincronizados via `GODZ_MASTER_CONFIG.json` (Bloco `SERVER_SETTINGS`).
- **Otimização**: Baixo uso de Resmon (0.01ms ocioso).

### Configuração
Os preços das peças podem ser ajustados no arquivo `GODZ_MASTER_CONFIG.json` dentro de `SERVER_SETTINGS`.

### Comandos
- Aproxime-se da bancada de tuning ou do marker na oficina e pressione `E`.
