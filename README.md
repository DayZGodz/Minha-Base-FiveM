# 🦅 Familía God Base - VRPEX Premium

> **"Tecnologia de Elite para Roleplay Sério"**

Bem-vindo ao repositório oficial da **Base Familía God**. Este projeto não é apenas mais uma base FiveM; é uma **Super Base VRPEX** consolidada, projetada para redefinir os padrões de performance, segurança e inteligência artificial no cenário brasileiro.

![Banner](logo.png)

---

## 🏛️ Arquitetura "The Three Pillars"

Nossa infraestrutura foi meticulosamente construída através da fusão estratégica dos três maiores frameworks do mercado, extraindo o melhor de cada um para criar um híbrido perfeito:

### 1. Unity (O Core)
*   **Foco:** Performance Bruta e Estabilidade.
*   **Implementação:** Utilizamos o loop de threads otimizado e o sistema de inventário (`vRP.items`) da Unity.
*   **Resultado:** Capacidade de processar milhares de requisições de inventário sem degradar o tickrate do servidor, mantendo 60 FPS estáveis mesmo em situações de estresse.

### 2. Zirix (A Modularidade)
*   **Foco:** Flexibilidade e Gestão.
*   **Implementação:** Adotamos a estrutura modular de grupos, empregos e garagens da Zirix.
*   **Resultado:** Um sistema onde a criação de novas facções ou empregos é feita via configuração simples, sem necessidade de reescrever código core.

### 3. Bahamas (A Experiência)
*   **Foco:** UI/UX e Modernidade.
*   **Implementação:** Toda a interface visual (HUD, NUI, Notify, Inventário) foi reescrita seguindo o design system da base Bahamas.
*   **Resultado:** Uma experiência visual fluida, limpa e responsiva, com animações em 60fps e feedback visual imediato.

---

## 🤖 Ecossistema de IA (AI Bridge)

A **Familía God** é pioneira na integração nativa com Inteligência Artificial Local, eliminando a dependência de APIs externas caras e lentas.

### Infraestrutura
*   **Modelo:** Microsoft Phi-3 Mini 4k Instruct (Rodando localmente).
*   **Backend:** Python com servidor **Waitress WSGI** (Produção) para handling de múltiplas requisições simultâneas.
*   **Segurança:** Autenticação via Token com validação estrita e sanitização de inputs.

### Recursos Ativos
1.  **Assistente Virtual (/ajuda):** Responde dúvidas de regras e comandos instantaneamente, consultando a `WIKI.md` e `REGRAS.txt`.
2.  **Lore Dinâmica:** NPCs e eventos reagem ao contexto da história do servidor.
3.  **Smart Dispatch (/911):** O sistema analisa chamados de emergência, gera um resumo tático profissional e define a prioridade (Baixa/Média/Alta) para a polícia e paramédicos.
4.  **Tuning IA:** Gera laudos técnicos detalhados para veículos modificados, justificando a performance com base nas peças instaladas.

---

## 🛡️ Segurança (GODZ Sentinel)

Nossa camada de segurança proprietária, **GODZ Sentinel**, opera em nível de kernel do servidor para mitigar ameaças antes que elas afetem a jogabilidade.

*   **Anti-Injection:** Bloqueio proativo de executores Lua comuns.
*   **Honeypots:** Variáveis e eventos "iscas" que, quando acessados por menus de trapaça, banem o infrator instantaneamente.
*   **Análise Preditiva:** O sistema monitora logs em tempo real para identificar padrões de comportamento anômalo (ex: spawn excessivo de dinheiro ou armas) antes que a economia seja afetada.
*   **Webhooks Seguros:** Sistema de logs criptografados que impede a interceptação de dados sensíveis.

---

## 💰 Economia Inteligente

O mercado do servidor é vivo e autorregulado.

*   **Precificação Dinâmica:** A IA monitora o saldo total dos jogadores e a circulação de dinheiro a cada hora.
*   **Controle de Inflação:** Se a economia inflacionar, os preços de itens de luxo e impostos são ajustados automaticamente para drenar o excesso de liquidez.
*   **Eventos de Mercado:** Promoções relâmpago ou escassez de produtos são geradas dinamicamente pelo **Diretor de Eventos**.

---

## 🎨 Visual Exclusive Signature

Nossa identidade visual é única e inconfundível, projetada para transmitir luxo e exclusividade.

*   **Paleta:** Dark Gold (`#D4AF37`) sobre fundos translúcidos escuros.
*   **Glassmorphism:** Interfaces com desfoque de fundo (backdrop-filter) para imersão total.
*   **ia_tip:** Um sistema de notificação exclusivo com efeito de pulsação dourada para avisos gerados pela Inteligência Artificial.

---

## 🔄 Protocolo de Atualização Contínua

**ATENÇÃO DESENVOLVEDORES:** A manutenção da documentação é tão crítica quanto o código.

Para toda alteração técnica realizada:
1.  **Identificar Impacto:** Analise como a mudança afeta os "Três Pilares" ou a segurança.
2.  **Atualizar Documentação:** Edite imediatamente a seção correspondente neste `README.md` ou adicione ao `CHANGELOG.md`.
3.  **Sincronia:** O Git Push só deve ser realizado se a documentação refletir 100% da versão do código.

> *"Código sem documentação é dívida técnica."*

---

## 🚀 Como Iniciar

1.  **Banco de Dados:** Importe `GODZ_INSTALL_DB.sql` e configure o `server.cfg`.
2.  **Dependências Python:**
    ```bash
    cd server
    pip install -r requirements.txt
    ```
3.  **Start:** Execute o `Start.bat`.
4.  **AI Bridge:** Em outro terminal, inicie a inteligência:
    ```bash
    python server/godz_ai_bridge.py
    ```

---
*Copyright © 2025 Familía God Engineering Team. All rights reserved.*
