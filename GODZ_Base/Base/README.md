# GODZ Project

## ⚙️ Configuração Master (Guia do Usuário)

O `GODZ_MASTER_CONFIG.json` é o coração do servidor. Sua estrutura hierárquica facilita a manutenção e evita conflitos.

### Estrutura e Categorias

1.  **[SERVER_INFO]**
    *   Dados básicos do servidor e tokens de conexão.
    *   Ex: `discord_token`, `guild_id`.

2.  **[PERMISSIONS]**
    *   Controle de acesso administrativo.
    *   Define quem são `ceos`, `admins` e `moderators` (IDs numéricos).

3.  **[ECONOMY]**
    *   Configurações financeiras e preços globais.
    *   Ex: `tuning_prices` para o script `godz_tuning`.

4.  **[SECURITY]**
    *   Whitelists para sistemas de proteção.
    *   Ex: `ignored_by_sentinel` (Anti-Cheat) e `ignored_by_auditor` (IA de Economia).

5.  **[WEBHOOKS]**
    *   URLs de integração com canais do Discord.
    *   Logs de auditoria, suporte, staff, etc.

### Validação Inteligente
Caso você cometa um erro de sintaxe (esqueça uma vírgula ou aspas), o console do servidor avisará exatamente a linha e a provável seção onde o erro ocorreu:
`⚠️ ERRO NO CONFIG: Sintaxe inválida na seção ECONOMY`

---

## 🏎️ GODZ Tuning (Customização de Alta Performance)

Recurso avançado de customização veicular integrado ao ecossistema GODZ.

### Funcionalidades
- **Interface Glassmorphism**: UI moderna e imersiva.
- **Sistema de Níveis**: Peças de alta performance (Turbo, Motor Pro) exigem nível alto de mecânico.
- **Persistência**: Modificações salvas automaticamente no banco de dados.
- **Integração Econômica**: Preços sincronizados via `GODZ_MASTER_CONFIG.json` (Bloco `ECONOMY`).
- **Otimização**: Baixo uso de Resmon (0.01ms ocioso).

### Configuração
Os preços das peças podem ser ajustados no arquivo `GODZ_MASTER_CONFIG.json` dentro de `ECONOMY`.

### Comandos
- Aproxime-se da bancada de tuning ou do marker na oficina e pressione `E`.

---

## 🗄️ Importação do Banco de Dados (DBA Guide)

Para garantir a integridade referencial e evitar erros de `Foreign Key Constraint`, siga rigorosamente esta ordem de importação no HeidiSQL ou phpMyAdmin:

1.  **Setup Inicial (CRÍTICO)**
    *   Execute `00_GODZ_SETUP_INITIAL.sql` primeiro.
    *   Este script cria o banco `vrp` e a tabela mestra `vrp_users` com as configurações corretas de Charset (`utf8mb4`) e Engine (`InnoDB`).

2.  **Estrutura Principal**
    *   Execute `Banco de Dados.sql`.
    *   Isso criará as tabelas core do vRP e importará dados essenciais.

3.  **Módulos Adicionais**
    *   Importe os SQLs dos recursos na ordem que preferir, pois todos agora possuem proteções de Foreign Key:
        *   `godz_bank.sql`
        *   `godz_housing.sql`
        *   `godz_jobs.sql`
        *   `godz_ems.sql`
        *   `godz_mdt.sql`

> **Nota Técnica**: Todos os arquivos SQL foram refatorados para incluir `SET FOREIGN_KEY_CHECKS = 0;` no início e `1` no final, garantindo uma importação livre de erros de dependência circular.
