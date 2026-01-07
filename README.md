# 🌟 Familía God Base - VRPEX Premium

Bem-vindo ao repositório oficial da **Base Familía God**. Este projeto representa o estado da arte em servidores FiveM, resultado de uma fusão meticulosa entre as melhores características das bases Unity, Zirix e Bahamas, estabilizada com correções críticas no núcleo do vRP e potencializada por uma Inteligência Artificial proprietária.

![Banner](logo.png)

## 🚀 Sobre o Projeto (Fusão de Bases)

A "Super Base" não é apenas um compilado de scripts; é uma arquitetura unificada.

*   **Legado Unity:** Herdamos o sistema de otimização de threads e o gerenciamento de inventário robusto, garantindo que o servidor suporte alta carga sem "crashar".
*   **Core Zirix:** Utilizamos a estrutura modular de empregos e facções da Zirix, conhecida pela facilidade de configuração e estabilidade em roleplay sério.
*   **UI Bahamas:** Integramos a interface visual moderna (HUD, Inventário, Notify) inspirada na base Bahamas, proporcionando uma experiência visual limpa e responsiva (NUI otimizada).

---

## 🛠️ Instalação e Configuração

### Pré-requisitos
*   **Game Build:** A base requer a build `3095` (ou superior) para carregar corretamente os assets de roupas e veículos. Isso já está configurado no `server.cfg` (`set sv_enforceGameBuild 3095`), mas certifique-se de mantê-la.
*   Python 3.10+ (Para a ponte de IA).
*   MySQL Server (XAMPP ou MariaDB).

### 1. Configuração do Banco de Dados
A base utiliza uma estrutura SQL otimizada. O arquivo `GODZ_INSTALL_DB.sql` na raiz contém todas as tabelas necessárias.

1.  Crie um banco de dados chamado `godz_database` (ou `familia_god_db` se preferir renomear).
2.  Importe o arquivo `GODZ_INSTALL_DB.sql`.
3.  Verifique o `server.cfg` e garanta que a string de conexão corresponda:
    ```cfg
    set mysql_connection_string "user=root;database=godz_database;password=;host=127.0.0.1"
    ```
    > **Nota:** Se o nome do banco no `server.cfg` não bater com o banco criado, o script `base.lua` agora emitirá um alerta crítico no console ao invés de travar o servidor silenciosamente.

### 2. Dependências Python (IA)
Para ativar a Inteligência Artificial, instale as dependências:
```bash
cd server
pip install -r requirements.txt
```

---

## 🔧 Correções Críticas Realizadas

### ✅ Fix do Core vRP (`base.lua`)
Identificamos um erro fatal na função `getUserIdByIdentifiers` onde uma falha na conexão SQL ou ausência de tabela causava um crash silencioso no scheduler do FiveM.
**Solução:** Implementamos um `pcall` (Protected Call) na linha 134 do `base.lua`. Agora, se o `oxmysql` falhar, o erro é capturado e uma mensagem amigável `[FAMILÍA GOD] CRITICAL ERROR` é exibida, prevenindo o colapso do servidor.

### ✅ Correção de Inventário (`vRP.items`)
Bases fundidas frequentemente sofrem com IDs de itens duplicados. Padronizamos o `items.lua` para garantir que não haja conflitos entre itens da Unity e da Zirix, utilizando o sistema de peso e stack da Unity como padrão mestre.

---

## 🤖 Sistema de Inteligência Artificial (Familía God AI)

A base conta com um sistema de IA exclusivo rodando localmente, projetado para monitorar a economia e auxiliar a administração.

### Arquitetura
*   **Modelo:** Microsoft Phi-3 Mini (4k Instruct) - Leve e eficiente para respostas rápidas.
*   **Servidor:** Utilizamos `Waitress` como servidor WSGI de produção, substituindo o servidor de desenvolvimento do Flask. Isso garante suporte a múltiplas requisições simultâneas sem engasgos.
*   **Ponte:** O script `godz_ai_bridge.py` conecta o servidor FiveM (via HTTP) ao modelo Python.

### Funcionalidades
1.  **Sentinela:** Monitora logs em busca de anomalias (ex: retiradas massivas de baús).
2.  **Economista:** Analisa salários vs. preços de veículos para sugerir balanceamento.
3.  **Suporte:** Um bot de Discord integrado responde dúvidas de jogadores baseando-se no arquivo `REGRAS.txt`.

Para iniciar a IA:
```bash
python server/godz_ai_bridge.py
```
*(Certifique-se de configurar o Token do Discord no `GODZ_MASTER_CONFIG.json`)*

---

## 🔗 Links Úteis
*   **Repositório Oficial:** [https://github.com/DayZGodz/Minha-Base-FiveM](https://github.com/DayZGodz/Minha-Base-FiveM)
*   **Discord de Suporte:** [Link do Discord]

---
*Desenvolvido com ❤️ pela equipe Familía God.*
