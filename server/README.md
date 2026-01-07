# 🐉 GODZ BASE - MANUAL TÉCNICO VRPEX

**GODZ BASE** é o resultado da fusão definitiva das bases **Unity**, **Zirix** e **Bahamas**, refinada para performance extrema e integração com Inteligência Artificial. Este manual documenta a infraestrutura para desenvolvedores.

---

## 🏗️ Fusão e Arquitetura

A base unifica o melhor de três mundos:
*   **Unity**: Sistema de inventário e economia robusta.
*   **Zirix**: Interface limpa e otimizações de netcode.
*   **Bahamas**: Scripts de RP avançados e sistema de organizações.

### Game Build 3407 (Bottom Dollar Bounties)
A base força o uso do Build 3407 (`sv_enforceGameBuild 3407`), garantindo:
*   **144hz UI**: Suporte nativo a interfaces Vue.js/React com alta taxa de atualização.
*   **Veículos/Roupas**: Acesso direto aos assets da DLC Bottom Dollar Bounties.
*   **Estabilidade**: Correções de crash do motor do GTA V.

---

## 🗄️ Gerenciamento de Dados

O arquivo **`GODZ_INSTALL_DB.sql`** é a **única fonte de verdade** para a estrutura do banco de dados.

*   **Regra de Ouro**: Nunca crie arquivos SQL separados para novos recursos. Todas as tabelas devem ser consolidadas no Master SQL.
*   **Padronização**: Todas as tabelas utilizam o prefixo `godz_` para evitar conflitos com recursos legados.
*   **Engine**: InnoDB (utf8mb4).

### Tabelas Principais
*   `godz_users`: Tabela mestre.
*   `godz_phone_contacts/messages`: Dados do ecossistema mobile.
*   `godz_user_moneys`: Economia bancária.

---

## 🔧 Fixes Críticos Aplicados

### 1. Inicialização de Inventário (`vrp/base.lua` e `inventory.lua`)
Foi corrigido o erro de indexação nula em itens:
```lua
-- Fix aplicado em inventory.lua
vRP.items = {} -- Garante que a tabela exista antes de qualquer definição
```

### 2. Conexão de Banco de Dados
Padronização para connection string URL para suporte a drivers modernos:
```cfg
set mysql_connection_string "mysql://root@localhost/godz_database?charset=utf8mb4"
```

### 3. Identidade e Tabelas `godz_`
Migração completa de `vrp_` para `godz_`.

---

## 🧠 Infraestrutura de IA (Phi-3 Mini)

A base opera um servidor de inferência local (`godz_ai_bridge.py`) rodando o modelo **Phi-3 Mini 4k Instruct**.

### Especificações
*   **Modelo**: Microsoft Phi-3 Mini (3.8B parâmetros).
*   **Servidor HTTP**: Waitress (Production WSGI).
*   **Endpoint**: `POST http://127.0.0.1:5000/ai_chat`.

### Otimização de Armazenamento (Disco D:)
Para preservar o SSD principal, o cache do Hugging Face é redirecionado:
```python
# Configuração no topo do bridge
os.environ['HF_HOME'] = 'D:/servidor FIVEM/PROJETO_SUPER_BASE/ai_cache'
```

---

## 🚀 Inicialização

1.  **Start.bat**: Inicia o servidor FiveM + Ponte de IA.
2.  **Monitoramento**: Acompanhe os logs com prefixo `[GODZ]` e `[GODZ AI]`.

---

**GODZ Dev Team**
*Copyright © 2026*
