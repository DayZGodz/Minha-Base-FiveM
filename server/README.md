# GODZ BASE - Manual do Desenvolvedor (v2.1)

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
O sistema utiliza um único arquivo SQL mestre (`server/GODZ_INSTALL_DB.sql`) para garantir a integridade de todos os recursos.

### Instalação Limpa
1.  Abra seu gerenciador de banco de dados (HeidiSQL/DBeaver).
2.  Crie um banco chamado `godz_database` (ou use o nome definido na sua `mysql_connection_string`).
3.  Importe o arquivo `server/GODZ_INSTALL_DB.sql`.
4.  Reinicie o servidor.

### Estrutura das Tabelas (`godz_`)
Todas as tabelas do ecossistema GODZ possuem o prefixo `godz_` para organização e evitar conflitos.

#### 1. Core & Identidade
*   `godz_users`: Tabela raiz. Contém ID, Whitelist, Banimento, IP e Last Login.
*   `godz_user_ids`: Identificadores (Steam, Discord, License).
*   `godz_user_identities`: Dados de RP (Nome, Idade, Registro).

#### 2. Economia & Banco
*   `godz_user_moneys`: Wallet, Bank, Coin, Paypal.
*   `godz_business`: Gestão de lavagem de dinheiro.
*   `godz_bank_loans`: Sistema de empréstimos bancários.
*   `godz_bank_logs`: Logs de transações e transferências (Pix).

#### 3. Ecossistema Mobile (God-Phone)
*   `godz_phone_contacts`: Agenda sincronizada.
*   `godz_phone_messages`: SMS persistente.
*   *Nota: Fotos são salvas no File System (Disco D:) para economizar DB.*

#### 4. Habitação (Housing)
*   `godz_housing_homes`: Propriedades, coordenadas e preços.
*   `godz_housing_keys`: Sistema de chaves compartilhadas.

#### 5. Veículos e Customs
*   `renzu_customs`: Salvamento de tunagem e inventário de oficinas (exceção ao prefixo `godz_` por ser lib externa).

---

## 💎 Superioridade Estrutural (GODZ vs Legacy)

### Por que `godz_`?
Bases legadas (vrpex, creative) sofrem com "Colisão de Tabelas" ao instalar scripts de terceiros. A estrutura GODZ resolve isso:
1.  **Isolamento**: Prefixos `godz_` garantem que nossos scripts nunca conflitem com mods baixados da internet.
2.  **Integridade Referencial (FKs)**: Ao deletar um usuário em `godz_users`, o banco limpa automaticamente:
    *   Contatos do celular.
    *   Contas bancárias.
    *   Chaves de casas.
    *   Dados de inventário.
    *   *Isso elimina o "lixo" acumulado no banco de dados, comum em servidores antigos.*

### Interação com Build 3407
O Build 3407 traz nativos modernos de persistência.
*   O servidor utiliza `LoadResourceFile` para carregar configurações JSON dinâmicas, reduzindo chamadas SQL desnecessárias.
*   A estrutura de banco foi desenhada para suportar os novos tipos de dados de veículos e roupas estendidas da DLC Bottom Dollar Bounties.

---

## 🔧 Configurações do Servidor

### Build 3407
O servidor força o build 3407 via `server.cfg` (e `start.bat`):
```cfg
set sv_enforceGameBuild 3407
```
Isso carrega automaticamente os assets da DLC "Bottom Dollar Bounties".

### Servidor Waitress (Python AI)
A ponte de IA (`godz_ai_bridge.py`) utiliza o servidor WSGI `Waitress` para produção no Windows, garantindo estabilidade no processamento de requisições do chat.
*   **Cache**: Redirecionado para `D:/servidor FIVEM/PROJETO_SUPER_BASE/ai_cache`.
*   **Logs**: Prefixados com `[GODZ AI]`.

---

## 🛠️ Manutenção e Soluções
*   **Debug SQL**: `vrp/base.lua` agora exibe o erro RAW do MySQL no console se a conexão falhar.
*   **Fix de Login (V3 - Resilient)**: O sistema de autenticação foi blindado e automatizado:
    *   **Auto-Criação**: Se o jogador não existir, o sistema cria automaticamente um novo ID na tabela `godz_users` e vincula os identificadores em `godz_user_ids`.
    *   **Proteção contra Nil**: Tratamento específico para evitar que falhas de query retornem `nil` crítico para o scheduler.
    *   **Logs Claros**: Exibe `[GODZ] Novo jogador detectado...` em vez de erros assustadores.
    *   Usa `exports.oxmysql:scalar` com `LAST_INSERT_ID()` para garantir sincronia na criação de usuários.
    *   Totalmente otimizado para o driver `oxmysql` moderno e Build 3407.
*   **Dynamic Loading**: Recursos utilizam `LoadResourceFile` e `SaveResourceFile` para persistência local quando apropriado.
