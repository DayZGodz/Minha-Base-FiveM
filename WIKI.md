# GODZ Base Wiki - Documentação Técnica Oficial

Bem-vindo à documentação oficial da **Base GODZ**, um ecossistema de alta performance para FiveM que integra inteligência artificial avançada, design premium e segurança de elite.

---

## 🏗️ Arquitetura da Base

A Base GODZ foi construída sobre uma fusão estratégica de três pilares fundamentais, visando o equilíbrio perfeito entre otimização e funcionalidade:

| Pilar | Foco | Descrição |
| :--- | :--- | :--- |
| **Unity** | Performance | Núcleo otimizado para garantir alto FPS e estabilidade sob carga pesada. |
| **Zirix** | Modularidade | Estrutura de resources organizada e flexível, facilitando a manutenção e escalabilidade. |
| **Bahamas** | Design System | Interface do usuário (UI) moderna e responsiva, adaptada para o padrão visual GODZ. |

Esta arquitetura híbrida permite que a base suporte sistemas complexos de IA sem comprometer a fluidez da gameplay.

---

## 🤖 Configuração da IA (AI Bridge)

O coração da inteligência da base é o **GODZ AI Bridge**, um middleware Python que conecta o servidor FiveM (Lua) a modelos de linguagem locais (LLMs).

### Especificações Técnicas
*   **Modelo:** Phi-3 Mini (Otimizado para respostas rápidas e baixo consumo de VRAM).
*   **Servidor Web:** Waitress (WSGI Production-ready).
*   **Framework:** Flask.
*   **Porta Padrão:** `5000`.

### Instalação e Execução

1.  **Instale o Python 3.10+**.
2.  Instale as dependências:
    ```bash
    pip install flask waitress requests torch transformers
    ```
3.  Execute o script da ponte:
    ```bash
    python godz_ai_bridge.py
    ```

### Segurança da API
Todas as requisições devem ser autenticadas utilizando a chave secreta configurada no `godz_ai_bridge.py`:

```python
API_KEY = "godz_secret_key_123"
```

Certifique-se de que esta chave corresponda à definida nos arquivos `server.lua` dos resources (`godz_tuning`, `godz_jobs`, `godz_identity`, etc.).

---

## 🗄️ Banco de Dados

A persistência de dados utiliza MySQL/MariaDB, otimizado para alta concorrência.

### Tabela `godz_users`
Estrutura central de identificação dos jogadores.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| `user_id` | INT (PK) | Identificador único do cidadão. |
| `steam_hex` | VARCHAR | Identificador Steam para whitelist. |
| `ip` | VARCHAR | **Crítico:** Usado pelo Sentinel para rastreio e proteção contra ban evasion. |
| `last_login` | DATETIME | Registro de atividade para limpeza automática de contas inativas. |
| `whitelisted` | BOOLEAN | Status de aprovação do jogador. |

---

## 🎮 Sistemas do Jogador

Funcionalidades interativas potencializadas pela IA para imersão total.

### Comandos Principais

| Comando | Função | Integração IA |
| :--- | :--- | :--- |
| `/ajuda [dúvida]` | Suporte Inteligente | A IA analisa a dúvida e responde com base na Lore do servidor e regras. |
| `/rg` | Identidade Premium | Exibe o RG visual. A biografia do personagem é gerada dinamicamente pela IA. |
| `/911 [msg]` | Despacho Inteligente | Envia alerta para polícia/SAMU. A IA resume a ocorrência e define a prioridade. |

### Tuning e Garagem
Ao modificar um veículo na **GODZ Tuning**, o jogador recebe um "Laudo Mecânico" gerado pela IA, detalhando as alterações de performance e estética de forma técnica e imersiva.

---

## 🛡️ Segurança (GODZ Sentinel)

O **GODZ Sentinel** é o sistema de proteção ativa da base.

### Funcionalidades
*   **Anti-Injection:** Detecção de executores de Lua não autorizados.
*   **Honeypots:** Triggers falsos espalhados pelo código para capturar cheaters tentando explorar vulnerabilidades.
*   **Análise de Suspeita:** Monitoramento de ganhos de dinheiro e criação de entidades. Jogadores com comportamento anômalo são marcados com "High Suspicion".

### Webhooks
Configure os logs no arquivo `config.lua` do `godz_sentinel` para receber alertas em tempo real no Discord:

```lua
Config.Webhooks = {
    Detection = "https://discord.com/api/webhooks/...",
    Suspicion = "https://discord.com/api/webhooks/...",
    Ban = "https://discord.com/api/webhooks/..."
}
```

---

## 🛠️ Ferramentas Administrativas

Painel de controle avançado para a Staff.

### Comando `/staff`
Abre o **GODZ Admin Panel** (NUI).

*   **Funcionalidades:**
    *   Lista de jogadores online com Ping e ID.
    *   **AI Log Analyzer:** Botão para analisar logs financeiros de um jogador suspeito. A IA emite um veredito ("Legítimo" ou "Suspeito").
    *   Gerenciador de Economia (Visualização do Multiplicador Global).

### Permissões Necessárias

| Grupo | Permissão | Acesso |
| :--- | :--- | :--- |
| Admin | `admin.permissao` | Acesso total ao painel e comandos de ban. |
| Polícia | `policia.permissao` | Recebimento de despachos `/911` e visualização de alertas. |
| Paramédico | `paramedico.permissao` | Recebimento de despachos médicos. |

---

## 🎨 Estilo Visual

A identidade visual da GODZ segue o padrão **Premium Dark Gold**.

*   **Paleta de Cores:**
    *   Primária: `#D4AF37` (Dark Gold)
    *   Fundo: `#0a0a0a` (Absolute Black) com transparência.
*   **Design:** Glassmorphism (Efeito de vidro fosco com bordas sutis).
*   **Notificações `ia_tip`:** Novo estilo de notificação com borda dourada pulsante, utilizado exclusivamente para mensagens geradas pela Inteligência Artificial.

---

*Documentação gerada automaticamente pela Equipe de Desenvolvimento GODZ.*
*Versão: 1.0.0 - 2026*
