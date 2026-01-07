# FAMILÍA GOD BASE - VRPEX (Fusion Edition)

> **Versão Oficial de Produção - 2026**
> Fusão das bases Unity, Zirix e Bahamas com Infraestrutura de IA proprietária.

---

## 🏛️ História e Arquitetura: A Grande Fusão

A **Familía God Base** não é apenas mais um servidor; é o resultado de uma engenharia complexa de fusão de três das maiores bases de código do cenário FiveM, criando um ecossistema robusto e único.

### 1. Unity (O Core e Backend)
Utilizamos o **Loop de Threads** e o sistema de gerenciamento de **Items (vRP.items)** da Unity como nossa fundação.
*   **Por que?** A Unity possui o gerenciamento de inventário mais leve do mercado, permitindo milhares de itens sem lag no banco de dados.
*   **Legado:** Mantivemos a estrutura de tabelas `vrp_users`, `vrp_user_ids` e `vrp_user_data` para garantir compatibilidade máxima com scripts legados e ferramentas de administração.

### 2. Zirix (O Gameplay e Empregos)
Adotamos a modularidade de **Empregos (Jobs)**, **Facções** e **Garagens** da Zirix.
*   **Por que?** O sistema de grupos e permissões da Zirix é imbatível em flexibilidade, permitindo hierarquias complexas para polícias e facções criminosas.

### 3. Bahamas (A Interface e UX)
O visual (**HUD**, **NUI**, **Notify**, **Inventory UI**) foi totalmente reescrito seguindo o *Design System* da base Bahamas.
*   **Por que?** A estética "Clean & Neon" da Bahamas oferece a melhor experiência de usuário (UX), com menus intuitivos e responsivos.

---

## 🛠️ Core Fixes & Soluções Técnicas

Durante o desenvolvimento, enfrentamos e resolvemos desafios críticos que derrubam 90% dos servidores:

### 🔧 1. O "Apagão" de Dados (Database Fix)
*   **Problema:** O servidor não conseguia identificar jogadores, gerando o erro `Failed to access database 'godz_users'`.
*   **Causa:** Tentativa de rebranding forçado nas tabelas do MySQL sem migração de dados.
*   **Solução:** Revertemos o core `base.lua` para utilizar as tabelas padrão `vrp_users`. Implementamos um **Security Check** com `pcall` na função `getUserIdByIdentifiers` (Linha 134+), garantindo que falhas de banco de dados sejam tratadas graciosamente sem crashar a thread principal.

### 🔧 2. Conflito de Inventário (vRP.items = {})
*   **Problema:** Itens desaparecendo ou pesando 0kg.
*   **Solução:** Unificação dos dicionários de itens. Removemos as definições duplicadas em `cfg/items.lua` e centralizamos tudo no módulo `inventory.lua`, garantindo que cada item tenha peso e função definidos uma única vez.

### 🔧 3. Loop de Wait Infinito
*   **Problema:** Threads travando em loops `while true do Wait(0)` mal otimizados.
*   **Solução:** Substituição por `Wait(idle_time)` dinâmico. Se o jogador não está perto de um marcador, o script "dorme" (`Wait(1000)`), economizando até 40% de CPU.

---

## 🤖 Familía God AI Bridge (Infraestrutura de IA)

A nossa maior inovação é a ponte de Inteligência Artificial que roda em paralelo ao servidor FiveM.

### O Modelo (Phi-3 Mini)
Utilizamos o **Microsoft Phi-3 Mini 4k Instruct**, um modelo de linguagem pequeno (SLM) otimizado para rodar localmente na VPS sem GPU dedicada.
*   **Função:** Atua como "Dungeon Master", analisando logs e respondendo dúvidas.
*   **Arquivo:** `godz_ai_bridge.py`.

### Servidor de Produção (Waitress)
Abandonamos o servidor de desenvolvimento do Flask.
*   **Tecnologia:** Implementamos `waitress`, um servidor WSGI de produção.
*   **Benefício:** Suporte a múltiplas requisições simultâneas, estabilidade total e zero avisos de console.

### Monitoramento Econômico & Anti-Cheat
A IA monitora ativamente:
*   **Inflação:** Analisa salários vs. preços de carros (`/ai_economy_simulation`).
*   **Limpa-Baú:** Detecta retiradas massivas de itens de facções (`/analyze_chest_activity`).
*   **Comportamento:** Identifica padrões de player tóxico através de análise de chat.

---

## 🚀 Guia de Instalação e Inicialização

### Pré-requisitos
*   Python 3.10+
*   MariaDB 10.6+ ou MySQL 8.0+
*   Artifacts FiveM (Build 3095+)

### Passo a Passo

1.  **Banco de Dados:**
    *   Importe o `GODZ_INSTALL_DB.sql` (agora compatível com estrutura `vrp_`).
    *   Verifique a conexão em `server.cfg`: `set mysql_connection_string`.

2.  **Instalação da IA:**
    ```bash
    cd server
    pip install -r requirements.txt
    ```

3.  **Configuração:**
    *   Edite `resources/[godz_core]/godz_tuning/GODZ_MASTER_CONFIG.json` com seus Webhooks e Token do Discord.
    *   O sistema aplicará `.strip()` automaticamente no token para evitar erros.

4.  **Iniciar:**
    *   Execute `start.bat`.
    *   Aguarde a mensagem: `[FAMILÍA GOD AI] Servidor de Produção rodando na porta 5000...`

---

## 📞 Suporte

*   **Discord:** discord.gg/DayZGodz
*   **GitHub:** github.com/DayZGodz/Minha-Base-FiveM
*   **Developer:** Familía God Dev Team
