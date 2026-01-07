# 🐉 GODZ BASE - FiveM Server (Build 3407)

**GODZ BASE** é uma infraestrutura de alta performance para servidores FiveM, projetada para estabilidade, escalabilidade e integração nativa com Inteligência Artificial.

---

## 🏗️ Arquitetura do Sistema

Esta base utiliza o **Game Build 3407**, permitindo:
*   **UI/UX 144hz**: Interfaces fluidas baseadas em Vue.js.
*   **Carregamento Dinâmico**: Atualização de assets e recursos sem reinicialização total.
*   **Novos Veículos e Roupas**: Acesso nativo ao conteúdo mais recente do GTA Online.

---

## 💾 Estrutura de Banco de Dados (`godz_database`)

Todo o core vRP foi migrado para tabelas prefixadas com `godz_`, garantindo isolamento e organização.

### 👤 Identidade e Usuários
*   `godz_users`: Tabela mestre (ID, Whitelist, Banimento, IP).
*   `godz_user_ids`: Mapeamento de identificadores (Steam, Discord, License).
*   `godz_user_identities`: Dados de RP (Nome, Sobrenome, Idade, Registro, Telefone).

### 💰 Economia (Bank & Wallet)
*   `godz_user_moneys`: 
    *   `wallet`: Dinheiro em mão.
    *   `bank`: Saldo bancário.
    *   `coin`: Moeda premium.
*   `godz_benefits`: Benefícios VIP e status global.

### 📱 Ecossistema Mobile (Phone)
*   `godz_phone_contacts`: Agenda de contatos sincronizada.
*   `godz_phone_messages`: Histórico de SMS persistente.
*   **Storage**: Fotos salvas localmente no Disco D (economizando espaço no SSD principal).

### 🏠 Housing & Dados Diversos
*   `godz_srv_data`: Armazenamento Key-Value para propriedades (homes), baús e configurações globais.
*   `godz_user_data`: Dados específicos do jogador (roupas, customização, inventário datatable).

---

## 🧠 Integração com IA (`godz_ai_bridge`)

A base conta com uma ponte Python-Lua que conecta o servidor ao modelo **Phi-3**.
*   **Cache Otimizado**: O cache da IA é redirecionado para `D:/servidor FIVEM/PROJETO_SUPER_BASE/ai_cache`, prevenindo lotação do Disco C.
*   **Logs**: Monitoramento em tempo real via tag `[GODZ AI]`.

---

## 🚀 Como Iniciar

1.  **Database**: Importe `server/GODZ_INSTALL_DB.sql` e `server/GODZ_PHONE.sql`.
2.  **Config**: Verifique `server/config/config.cfg` e a string de conexão `mysql://root@localhost/familia_god_db`.
3.  **Start**: Execute `Start.bat` na raiz.

---

**Desenvolvido por GODZ Dev Team**
*Copyright © 2026*
