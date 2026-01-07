# GODZ DEV BASE VRPEX

> Base oficial GODZ, unificada e profissional, construída sobre VRPex com foco em Performance, Segurança e Escalabilidade.

---

## 📋 Sobre o Projeto

Este projeto representa o estado da arte em desenvolvimento FiveM, focado em **Performance**, **Segurança** e **Escalabilidade**. Removemos todo o "bloatware" desnecessário para entregar uma experiência fluida, mantendo os sistemas complexos que os jogadores amam (Inventário GODZ, Tuning Avançado, etc.) funcionando em harmonia com um Core otimizado.

---

## 📂 Nova Estrutura de Pastas (Padrão Enterprise)

A organização do servidor foi reestruturada para seguir padrões de mercado, facilitando a manutenção e escalabilidade.

### 📁 Raiz (`server/`)
- **`config/`**: Arquivos de configuração (`config.cfg`, `resources.cfg`).
- **`infra/`**: Ferramentas de automação e infraestrutura (`godz_updater.py`).
- **`resources/`**: Recursos do servidor organizados por categoria.
- **`godz_ai_bridge.py`**: Ponte de IA para economia e segurança.
- **`start.bat`**: Inicializador automatizado.

### 📦 Resources (`server/resources/`)
1.  **`[godz_core]`**: Núcleo do ecossistema (Admin, Banco, Inventário, Housing, Tuning, etc.).
2.  **`[Jobs]`**: Sistemas de trabalho e garagens unificadas.
3.  **`[Illegal]`**: Facções, Drogas e Desmanches.
4.  **`[Security]`**: Anticheat (Shield) e Suporte.
5.  **`[vRP]`**: Framework Base (vRP modificado).
6.  **`[assets]`**: Conteúdo visual (Roupas, Veículos, Mapas).
7.  **`[standalone]`**: Scripts de terceiros (OxMySQL, PMA-Voice).

---

## 🛠️ Stack Tecnológico & Recursos

### 🛡️ Segurança & Core
> Núcleo GODZ. Leve, rápido e protegido.
- Banco de Dados Unificado (OxMySQL) com transações otimizadas.
- Shield e Anticheat proprietários, integrados ao ecossistema GODZ.
- **Auto-Update Nativo:** Script `godz_updater.py` integrado ao boot, mantendo os artefatos do servidor sempre na última versão recomendada automaticamente.

### 💾 Banco de Dados (Rebranding Total)
> Estrutura de dados unificada e exclusiva.
- **Schema Único:** `godz_database` (substitui bancos fragmentados).
- **Tabelas Padronizadas:** Prefixo `godz_` em todas as tabelas (ex: `godz_users`, `godz_vehicles`).
- **Migração Completa:** Scripts Lua/Python atualizados para eliminar dependências legadas (`vrp_`).
- **Dependência Estrita:** A base é agora **100% dependente** do banco de dados `godz_database`. Certifique-se de que a string de conexão no `server.cfg` aponte corretamente para este banco. Qualquer referência a `vrp` ou bancos antigos causará falha na inicialização.

### ⚙️ Configuração Master (Guia do Usuário)
O `GODZ_MASTER_CONFIG.json` é o coração do servidor. Sua estrutura hierárquica facilita a manutenção e evita conflitos.

**Categorias:**
1.  **[SERVER_INFO]**: Dados básicos e tokens (Discord).
2.  **[PERMISSIONS]**: Controle de acesso administrativo (IDs).
3.  **[ECONOMY]**: Preços globais e tuning.
4.  **[SECURITY]**: Whitelists para Anti-Cheat e IA.
5.  **[DATABASE]**: String de conexão unificada.

---

## 🗄️ Instalação do Banco de Dados

Para garantir a integridade do sistema, utilize o arquivo unificado:

1.  **Importação Única:**
    *   Execute o arquivo `GODZ_INSTALL_DB.sql` localizado na raiz do servidor.
    *   Ele criará o banco `godz_database` e toda a estrutura necessária.

> **Nota**: Arquivos SQL antigos e fragmentados foram removidos. Utilize apenas o `GODZ_INSTALL_DB.sql`.

---

## 🎨 GODZ Media Kit (Identidade Visual)

Consolidação da marca GODZ com padronização visual em todos os sistemas.

- **Paleta Oficial:** Roxo Neon (#9b59b6) e Ciano Neon (#00e5ff).
- **Recursos Padronizados:** HUD, Notify, Tablet, Banco, Loading.
