# GODZ BASE - Manual do Desenvolvedor

## 🌟 Sobre o Projeto
A **GODZ BASE** é uma infraestrutura de alta performance para FiveM, unificando o melhor das bases Unity, Zirix e Bahamas em um núcleo otimizado, seguro e escalável.

## 🚀 Tecnologias Core
*   **Game Build**: 3407 (Bottom Dollar Bounties) - Suporte nativo a novos veículos e roupas.
*   **Database**: MySQL 8.0 / MariaDB 10.4+ (Driver: `oxmysql`).
*   **Framework**: vRP 1.0 (Custom Fork) + Módulos de IA.
*   **UI/UX**: Vue.js + HTML5 (144hz fluid).
*   **AI Bridge**: Python Flask + Phi-3 (Integração Neural).

---

## 🗄️ Gerenciamento de Dados (Master SQL)

### Arquitetura Unificada
Abandonamos a prática de múltiplos arquivos SQL espalhados. A estrutura do banco de dados é **monolítica e referencial**, definida exclusivamente no arquivo:
`server/GODZ_INSTALL_DB.sql`

### Estrutura das Tabelas (`godz_`)
Todas as tabelas possuem o prefixo `godz_` e integridade referencial (FKs) com `ON DELETE CASCADE`.

#### 1. Core & Identidade
*   `godz_users`: Tabela raiz. Contém ID, Whitelist, Banimento, IP e Last Login.
*   `godz_user_ids`: Identificadores (Steam, Discord, License).
*   `godz_user_identities`: Dados de RP (Nome, Idade, Registro).

#### 2. Economia
*   `godz_user_moneys`: Wallet, Bank, Coin, Paypal.
*   `godz_business`: Gestão de lavagem de dinheiro e empresas.

#### 3. Ecossistema Mobile (God-Phone)
*   `godz_phone_contacts`: Agenda sincronizada.
*   `godz_phone_messages`: SMS persistente.
*   *Nota: Fotos são salvas no File System (Disco D:) para economizar DB.*

### Conexão (URL String)
O servidor utiliza **Connection Strings** modernas para maior estabilidade.
Configuração no `server.cfg`:
```cfg
set mysql_connection_string "mysql://root@localhost/godz_database?charset=utf8mb4"
```

---

## 🧠 Ponte de IA (God Assistant)
O servidor roda um microserviço em Python para processar NLP e Logs.

### Configuração de Cache (Economia de SSD)
Para evitar lotar o Disco C:, o script `godz_ai_bridge.py` define:
```python
os.environ['HF_HOME'] = 'D:/servidor FIVEM/PROJETO_SUPER_BASE/ai_cache'
```
*Isso redireciona 10GB+ de modelos da Hugging Face para o HD secundário.*

### Logs
Logs da IA são prefixados com `[GODZ AI]` para fácil filtragem no console.

---

## 🔧 Soluções Técnicas Recentes
*   **Fix de Login**: A tabela `godz_users` agora aceita `NULL` em campos de log (ip, last_login) para evitar falhas na criação inicial de usuários.
*   **Rebranding**: Interface e logs padronizados para "GODZ BASE".
*   **Dynamic Loading**: Recursos carregados dinamicamente via `LoadResourceFile` no Build 3407.
