# 🏙️ FAMILÍA GOD BASE (FiveM Server)

> **Versão:** 1.0.0 (Production Ready)  
> **Framework:** vRPex (Optimized)  
> **Game Build:** 3407 (The Chop Shop)  
> **Database:** MySQL (OxMySQL Driver)

---

## 📖 Sobre o Projeto
A **Familía God Base** é o resultado de uma engenharia de software avançada, unificando o melhor de três mundos: a estabilidade da **Unity**, a jogabilidade da **Zirix** e a estética da **Bahamas**. Este projeto não é apenas um servidor, é uma plataforma robusta pronta para alta demanda.

---

## 🏛️ História e Arquitetura: A Grande Fusão

### 1. Unity (O Core e Backend)
Utilizamos o **Loop de Threads** e o sistema de gerenciamento de **Items (vRP.items)** da Unity como nossa fundação.
*   **Por que?** A Unity possui o scheduler mais estável entre as bases vRP, evitando "crashes" por deadlocks em queries de banco de dados.

### 2. Zirix (O Gameplay e Empregos)
Adotamos a modularidade de **Empregos (Jobs)**, **Facções** e **Garagens** da Zirix.
*   **Por que?** O sistema de classes da Zirix permite fácil criação de novos empregos sem necessidade de alterar o core do vRP.

### 3. Bahamas (A Interface e UX)
O visual (**HUD**, **NUI**, **Notify**, **Inventory UI**) foi totalmente reescrito seguindo o *Design System* da base Bahamas.
*   **Por que?** Interfaces limpas, responsivas e modernas (Glassmorphism) aumentam a retenção de jogadores.

---

## 🛠️ Requisitos de Instalação

*   **FiveM Artifacts:** Recomendado versão 7000+ (Windows).
*   **Game Build:** `set sv_enforceGameBuild 3407` (Obrigatório para roupas e veículos novos).
*   **Banco de Dados:** MariaDB ou MySQL 8.0+.
*   **Driver:** `oxmysql` (Substituindo o obsoleto ghmattimysql).

---

## 🔧 Core Fixes & Soluções Técnicas

### 1. Fix de Identificação (`base.lua`)
**Problema:** O vRP falhava ao identificar jogadores novos devido à mudança de nome das tabelas.
**Solução:** 
*   Implementamos um `pcall` (Protected Call) na função `getUserIdByIdentifiers`.
*   Padronizamos todas as queries para usar o prefixo `godz_` (`godz_users`, `godz_user_ids`, etc.), sincronizando com o `GODZ_INSTALL_DB.sql`.

### 2. Fix de Inventário (`vRP.items`)
**Problema:** Tabelas nulas causando erro de indexação.
**Solução:** Inicialização segura de `vRP.items = {}` antes do carregamento dos módulos de inventário.

### 3. Otimização de Loop (Anti-Crash)
**Problema:** Loops infinitos (`while true do`) sem `Wait`.
**Solução:** Adição de `Wait(100)` ou `Citizen.Wait(0)` em todas as threads críticas de jobs e verificação de vida.

---

## 🤖 Familía God AI Bridge (Infraestrutura de IA)

### O Modelo (Phi-3 Mini)
Utilizamos o **Microsoft Phi-3 Mini 4k Instruct**, um modelo de linguagem pequeno (SLM) otimizado para rodar localmente na VPS sem GPU dedicada.
*   **Função:** Atua como "Dungeon Master", analisando logs e respondendo dúvidas.
*   **Arquivo:** `godz_ai_bridge.py`.

### Servidor de Produção (Waitress)
Abandonamos o servidor de desenvolvimento do Flask.
*   **Tecnologia:** Waitress (WSGI Server).
*   **Configuração:** `serve(app, host='0.0.0.0', port=5000)`.
*   **Capacidade:** Suporte a múltiplas requisições simultâneas sem bloqueio da thread principal.

---

## 🚀 Como Iniciar

1.  **Banco de Dados:**
    *   Importe o arquivo `server/GODZ_INSTALL_DB.sql` no seu HeidiSQL/DBeaver.
    *   Verifique se o banco criado se chama `godz_database`.

2.  **Configuração:**
    *   Abra `server/config/config.cfg`.
    *   Confira a conexão: `set mysql_connection_string "user=root;database=godz_database;password=;host=127.0.0.1"`.

3.  **Start:**
    *   Execute `Start.bat` na raiz do servidor.
    *   Aguarde o log `[FAMILÍA GOD AI] Servidor de Produção rodando...`.

---

**Desenvolvido por Familía God Dev Team**
*Copyright © 2026*
