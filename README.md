# 🌟 GODZ BASE - THE AI REVOLUTION

> **"Tecnologia de Elite. Performance Extrema. Inteligência Real."**

Bem-vindo ao repositório oficial da **GODZ BASE**. Este projeto representa o ápice do desenvolvimento FiveM, uma **Super Base VRPEX** forjada para redefinir o que é possível em termos de performance, segurança e imersão. Não é apenas um servidor; é um ecossistema vivo governado por Inteligência Artificial.

![Banner](logo.png)

---

## 🏛️ Arquitetura Híbrida "The Three Pillars"

Nossa infraestrutura foi meticulosamente construída através da fusão estratégica dos três frameworks mais robustos do mercado, extraindo o melhor de cada um para criar um híbrido perfeito:

### 1. Unity (O Core - Performance)
*   **Foco:** Estabilidade sob estresse e otimização de threads.
*   **Implementação:** Utilizamos o loop de threads nativo e o sistema de inventário (`vRP.items`) da Unity.
*   **Resultado:** Capacidade de processar milhares de requisições de inventário e banco de dados sem degradar o tickrate do servidor, mantendo 60 FPS estáveis para todos os jogadores.

### 2. Zirix (A Modularidade - Gestão)
*   **Foco:** Flexibilidade administrativa e escalabilidade.
*   **Implementação:** Adotamos a estrutura modular de grupos, empregos e garagens da Zirix.
*   **Resultado:** Um sistema onde a criação de novas facções, corporações ou empregos é feita via configuração simples (`cfg`), sem necessidade de reescrever o núcleo do código.

### 3. Bahamas (A Experiência - Visual)
*   **Foco:** UI/UX moderna e responsiva.
*   **Implementação:** Toda a interface visual (HUD, NUI, Notify, Inventário) foi reescrita seguindo o design system da base Bahamas.
*   **Resultado:** Uma experiência visual fluida, limpa e responsiva, com animações em 60fps e feedback visual imediato.

---

## 🤖 Ecossistema de IA (GODZ AI Bridge)

A **GODZ BASE** é pioneira mundial na integração nativa com Inteligência Artificial Local, eliminando a dependência de APIs externas lentas.

### Infraestrutura
*   **Modelo:** Microsoft Phi-3 Mini 4k Instruct (Rodando localmente na VPS).
*   **Backend:** Python com servidor **Waitress WSGI** (Produção) para handling de múltiplas requisições simultâneas.
*   **Segurança:** Autenticação via Token com a chave mestra `godz_secret_key_123` e sanitização rigorosa de inputs.

### Funcionalidades Inteligentes
*   **Lore de Personagem (/rg):** A IA analisa o histórico do jogador e gera uma biografia única no RG, considerando suas ações passadas.
*   **Suporte Inteligente (/ajuda):** Um assistente virtual que responde dúvidas de regras e comandos instantaneamente, consultando a base de conhecimento interna.
*   **Despacho Imersivo (/911):** O sistema analisa chamados de emergência, gera um resumo tático profissional e define a prioridade (Baixa/Média/Alta) para a polícia e paramédicos.
*   **Laudo Técnico de Tuning:** Ao modificar um veículo, a IA gera um relatório técnico justificando o aumento de performance com base nas peças instaladas (ex: "Instalação de Turbo Garrett GT35 aumentou a admissão de ar...").

---

## 🛡️ Segurança de Elite (GODZ Sentinel)

Nossa camada de segurança proprietária, **GODZ Sentinel**, opera em nível de kernel do servidor para mitigar ameaças antes que elas afetem a jogabilidade.

*   **Anti-Injection:** Bloqueio proativo de executores Lua comuns e payloads maliciosos.
*   **Honeypots Ativos:** Variáveis e eventos "iscas" espalhados pelo código que, quando acessados por menus de trapaça, banem o infrator instantaneamente.
*   **Anti-Crash de Entidades:** Monitoramento constante de objetos e peds; o sistema deleta automaticamente entidades inválidas ou spawnadas em massa.
*   **Logs em Embed Dourado:** Todos os alertas de segurança são enviados para o Discord em embeds detalhados na cor Dark Gold, facilitando a auditoria.

---

## 💰 Economia Dinâmica "Banco Central AI"

O mercado do servidor é vivo e autorregulado por uma Inteligência Artificial que atua como Banco Central.

*   **Regulação de Inflação:** A IA monitora o saldo total dos jogadores e a circulação de dinheiro a cada hora.
*   **Ajuste Automático:** Se a economia inflacionar, os preços de itens de luxo e impostos são ajustados automaticamente para drenar o excesso de liquidez.
*   **Salários Dinâmicos:** Os pagamentos dos empregos podem flutuar baseados na demanda e na saúde econômica do servidor.

---

## 🎨 Interface Signature GODZ

Nossa identidade visual é única e inconfundível, projetada para transmitir luxo e exclusividade tecnológica.

*   **Paleta:** Dark Gold (`#D4AF37`) sobre fundos translúcidos escuros (`rgba(0, 0, 0, 0.85)`).
*   **Glassmorphism:** Interfaces com desfoque de fundo (backdrop-filter) para imersão total em todos os NUIs (Identidade, Tuning, Admin, Empregos).
*   **ia_tip:** Um sistema de notificação exclusivo com efeito de pulsação dourada para avisos gerados pela Inteligência Artificial.

---

## � Comandos e Permissões

| Comando | Descrição | Permissão Necessária |
| :--- | :--- | :--- |
| `/ajuda [pergunta]` | Consulta a IA sobre regras ou comandos do servidor. | Todos |
| `/rg` | Exibe a identidade com Lore gerada por IA. | Todos |
| `/911 [msg]` | Envia um chamado de emergência inteligente para a polícia. | Todos |
| `/tuning_laudo` | Gera um laudo técnico do veículo atual via IA. | Mecânicos |
| `/staff` | Abre o painel administrativo GODZ. | `admin.permissao` |
| `/debug_ai` | Testa a conexão com o servidor Python local. | `admin.permissao` |
| `/godz_event` | Força o início de um evento mundial via IA. | `admin.permissao` |

---

## 🔄 Technical Updates & Protocolo

**ATENÇÃO DESENVOLVEDORES:**

1.  **Identificar Impacto:** Analise como a mudança afeta os "Três Pilares" ou a segurança.
2.  **Atualizar Documentação:** Edite imediatamente a seção correspondente neste `README.md`.
3.  **Sincronia:** O Git Push só deve ser realizado se a documentação refletir 100% da versão do código.

> *"Código sem documentação é dívida técnica. Na GODZ BASE, não aceitamos dívidas."*

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
*Copyright © 2025 GODZ Engineering Team. All rights reserved.*
