# 🌟 Familía God Base - VRPEX Premium

Bem-vindo ao repositório oficial da **Base Familía God**. Este projeto é uma **Super Base** consolidada, nascida da fusão estratégica entre as arquiteturas Unity, Zirix e Bahamas, corrigida e otimizada para alta performance e roleplay sério.

![Banner](logo.png)

## 🏛️ História e Arquitetura

### A Fusão (Unity + Zirix + Bahamas)
A Familía God não é apenas um "copia e cola". Analisamos o código-fonte das três maiores bases do cenário para criar um híbrido perfeito:
1.  **Unity (O Core):** Utilizamos o loop de threads e o sistema de inventário (vRP.items) da Unity como fundação, pois são imbatíveis em performance sob estresse.
2.  **Zirix (O Gameplay):** Adotamos a modularidade de empregos, facções e garagens da Zirix, que oferece a melhor experiência de configuração para donos de cidade.
3.  **Bahamas (A Interface):** O visual (HUD, NUI, Notify) foi totalmente reescrito seguindo o design system da base Bahamas, garantindo modernidade e fluidez.

### Estrutura de Pastas
A base segue uma separação rigorosa para facilitar a manutenção DevOps:
*   `artifacts/`: Binários do servidor (FiveM server builds). Mantemos separado para atualizações fáceis.
*   `server/`: Onde a mágica acontece. Contém `resources`, `config` e scripts Python.
    *   `resources/[vRP]`: O núcleo do framework.
    *   `resources/[godz_core]`: Scripts exclusivos da Familía God (Identity, Tuning, AI).

---

## 🔧 Core Fixes e Soluções Técnicas

Durante o desenvolvimento, enfrentamos e resolvemos bugs críticos que derrubam 90% dos servidores novos:

### 1. O "Apagão" de Dados (vRP.getUserIdByIdentifiers)
**Problema:** Ao migrar bases, o nome da tabela de usuários mudou de `vrp_users` para `godz_users`, mas o MySQL legado não foi atualizado. Isso fazia o servidor travar silenciosamente na entrada do player.
**Solução:** Implementamos um `pcall` (Protected Call) no `base.lua`. Agora, o servidor verifica a conexão com o banco antes de tentar ler o ID. Se a tabela não existir, ele emite um alerta `[FAMILÍA GOD] CRITICAL ERROR` no console, mas **não derruba a thread principal**, permitindo que o admin veja o erro e corrija.

### 2. Conflito de IDs (vRP.items = {})
**Problema:** A fusão de itens da Zirix com a Unity gerou duplicidade de IDs e pesos conflitantes.
**Solução:** Padronizamos o arquivo `items.lua` para usar a estrutura de metadados da Unity. Criamos um script de validação que remove chaves duplicadas na inicialização.

### 3. Loop de Wait Infinito
**Problema:** Scripts mal otimizados consumiam 100% da CPU em loops `while true do`.
**Solução:** Refatoramos todos os loops globais para utilizar `Citizen.Wait` dinâmico, que aumenta o tempo de espera quando o jogador está ocioso.

---

## 🤖 Familía God AI Bridge

A grande inovação desta base é a integração nativa com Inteligência Artificial Local.

### O Modelo (Phi-3 Mini)
Utilizamos o **Microsoft Phi-3 Mini 4k Instruct**, um modelo de linguagem pequeno (SLM) que roda localmente na VPS. Ele é capaz de:
*   Responder dúvidas de RP com base no arquivo `REGRAS.txt`.
*   Analisar logs de economia para detectar inflação.
*   Identificar comportamentos suspeitos (anti-cheat comportamental).

### Infraestrutura (Waitress WSGI)
Abandonamos o servidor de desenvolvimento do Flask (`app.run`). O script `godz_ai_bridge.py` agora utiliza **Waitress**, um servidor WSGI de produção robusto.
*   **Vantagem:** Suporta múltiplas requisições simultâneas (vários players perguntando ao mesmo tempo) sem bloquear a thread da IA.
*   **Segurança:** O Token do Discord agora passa por um `.strip()` automático para evitar erros de formatação (`Improper token`) comuns em copy-paste.

---

## 🚀 Como Iniciar

1.  **Banco de Dados:** Importe `GODZ_INSTALL_DB.sql` e configure o `server.cfg`.
2.  **Dependências:**
    ```bash
    cd server
    pip install -r requirements.txt
    ```
3.  **Start:** Execute o `Start.bat` (ou `run.sh` no Linux).
4.  **IA:** Em outro terminal, rode `python server/godz_ai_bridge.py`.

---
*Documentação oficial mantida pela equipe de Engenharia da Familía God.*
