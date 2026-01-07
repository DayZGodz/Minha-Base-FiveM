# 🌟 GODZ ENGINE - O FUTURO DO ROLEPLAY

> **"Ecossistema Proprietário. Inteligência Soberana. Tecnologia de Elite."**

Bem-vindo à documentação oficial da **GODZ BASE**. Este projeto representa o ápice do desenvolvimento FiveM, operando sob uma arquitetura de software independente e otimizada para performance extrema. Não utilizamos "partes" de outras bases; todo o ecossistema **GODZ** foi projetado para funcionar como uma unidade coesa, estável e inovadora.

![Banner](logo.png)

---

## 🤖 2. GODZ AI NEXUS & DISCORD INTEGRATION

O cérebro da nossa cidade não é humano, é digital. A **GODZ ENGINE** integra nativamente modelos de Inteligência Artificial e automação via Discord.

### 🧠 GODZ AI Bridge (Phi-3 Mini)
Utilizamos o modelo **Microsoft Phi-3 Mini 4k Instruct** rodando localmente para processamento de linguagem natural em tempo real.
*   **AI Support (/ajuda):** Um assistente neural que entende o contexto do servidor e tira dúvidas de regras instantaneamente.
*   **Lore Generator (/rg):** Criação dinâmica de biografias para personagens baseada em suas características e histórico.
*   **Automotive Consultant:** Gera laudos técnicos de engenharia mecânica após o tuning de veículos.
*   **Smart Dispatch:** Analisa chamados de emergência e coordena as unidades policiais com relatórios táticos.

### 🎮 Discord Bot Integration (Python)
Um bot customizado em Python que atua como a ponte entre o jogo e a comunidade.
*   **Sincronização de Cargos:** Atualiza automaticamente as permissões no jogo baseadas nos cargos do Discord.
*   **Logs Administrativos:** Espelhamento de ações da staff em canais privados para auditoria.
*   **Comandos Remotos:** Permite que administradores executem ações no servidor diretamente pelo chat do Discord.

---

## � 3. ARQUITETURA DE ARQUIVOS (GODZ CORE)

Nossa estrutura de pastas é modular, organizada e intuitiva. Cada recurso é um micro-serviço independente.

### 🔹 Núcleo GODZ ([godz_core])
O coração do sistema. Aqui residem os scripts vitais para o funcionamento da cidade:

*   **godz_admin:** Painel de gestão administrativa avançada com ferramentas de espectador e banimento.
*   **godz_bank:** Sistema financeiro exclusivo com interface bancária, transferências e histórico.
*   **godz_economy:** Gerenciador dinâmico de inflação que ajusta preços baseado na circulação de dinheiro.
*   **godz_sentinel:** Sistema de proteção ativa (Anti-Cheat) que blinda triggers e monitora injeções.
*   **godz_identity:** Sistema de criação de personagens (Multicharacter) com geração de Lore via IA.
*   **godz_interface & godz_notify:** Framework de UI/UX responsável pelo design Dark Gold e Glassmorphism.
*   **godz_chest:** Sistema de baús e armazéns com persistência de dados.
*   **godz_connect:** Gerenciador de fila e tela de carregamento otimizada.
*   **godz_dispatch:** Central de chamados de emergência integrada à IA.
*   **godz_events:** Diretor de eventos automáticos que cria dinâmicas globais no mapa.
*   **godz_garage:** Gestão de frotas pessoais e apreensão de veículos.
*   **godz_housing:** Sistema imobiliário com compra, venda e decoração de propriedades.
*   **godz_inventory:** Inventário inteligente com sistema de peso e durabilidade de itens.
*   **godz_jobs:** Central de empregos com missões procedurais.
*   **godz_logs:** Auditoria completa de ações dos jogadores (tiros, compras, trocas).
*   **godz_missions:** Framework de missões diárias e desafios.
*   **godz_phone:** Smartphone funcional com aplicativos sociais e utilitários.
*   **godz_target:** Sistema de interação visual (Olho) para NPCs e objetos.
*   **godz_tuning:** Oficina mecânica com persistência de modificações e laudos técnicos.

### � Especializações ([godz_modules])
Módulos focados em gameplay específico:

*   **godz_factions:** Gestão de organizações criminosas e corporações legais.
*   **godz_illegal:** Rotas de drogas, desmanches e lavagem de dinheiro.
*   **godz_shield:** Camada extra de firewall contra ataques DDoS e flood.
*   **godz_support:** Sistema de tickets e atendimento ao jogador in-game.
*   **godz_garages:** Expansão para garagens de facções e empresas.

### ⚙️ Módulos de Sistema ([system])
Infraestrutura técnica de suporte:

*   **[builders]:** Compiladores de mapas e scripts C#.
*   **[chat]:** Sistema de chat customizado com canais e comandos.
*   **[voip]:** Integração de voz de alta qualidade (PMA-Voice otimizado).
*   **screenshot-basic:** Utilitário para captura de tela (usado pelo Phone e Logs).
*   **mapmanager:** Gerenciador de carregamento de mapas e interiores (MLOs).

---

## � 4. ESTRUTURA DE DADOS (DATABASE)

Nossa base de dados `godz_users` é otimizada para segurança e rastreabilidade total.

### Tabela Mestra: `godz_users`
| Coluna | Descrição Técnica | Segurança |
| :--- | :--- | :--- |
| `id` | Identificador único do cidadão. | Primary Key |
| `whitelisted` | Status de aprovação na cidade. | Boolean |
| `banned` | Status de banimento global. | Boolean |
| `ip` | Último endereço IP de conexão. | Rastreio de Segurança |
| `last_login` | Timestamp da última sessão. | Auditoria de Atividade |
| `moedas` | Saldo de moeda VIP/Premium. | Protegido Server-Side |
| `pet` | Dados do animal de estimação vinculado. | JSON |
| `garagem` | Array de veículos possuídos. | JSON |

---

## 💎 5. IDENTIDADE VISUAL & UX

A **GODZ BASE** possui uma assinatura visual inconfundível.

*   **Dark Gold Standard:** Paleta de cores exclusiva utilizando Preto Carbono e Dourado Metálico (`#D4AF37`).
*   **Glassmorphism:** Todas as interfaces utilizam desfoque de fundo (backdrop-filter) para imersão e modernidade.
*   **Pulse Notifications:** O sistema `ia_tip` utiliza animações de pulsação para destacar informações críticas da IA.

---

## 🔄 Protocolo de Atualização

**Regra de Ouro:** Este documento é vivo. Qualquer alteração no código, adição de mod ou correção de bug **DEVE** ser refletida imediatamente nesta documentação técnica.

> *"Na GODZ ENGINE, a documentação é tão importante quanto o código."*

---
*Copyright © 2025 GODZ Technologies. All rights reserved.*
