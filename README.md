# 👑 GODZ ENGINE - THE PINNACLE OF PERFORMANCE

> *O ecossistema definitivo para FiveM, unindo Inteligência Artificial, Segurança de Elite e UX Premium.*

---

## 🧠 O CÉREBRO: GODZ AI NEXUS & BOT

### 🤖 GODZ AI NEXUS (Phi-3 Mini)
**A Mente da Cidade**
O núcleo de inteligência artificial do servidor não é apenas um chatbot. É um modelo de linguagem local (Phi-3 Mini) treinado especificamente para roleplay, operando em uma ponte Python-Lua de baixa latência.
*   **Context Awareness:** A IA sabe quem é o jogador, seu emprego, status financeiro e localização.
*   **Latency Optimized:** Respostas em milissegundos graças ao cache inteligente em disco.
*   **Roleplay Enforcer:** Garante que as interações mantenham a imersão do cenário.

---

### 🆘 SISTEMA DE AJUDA INTELIGENTE (`/ajuda`)
**Suporte Automatizado 24/7**
Esqueça os tickets de suporte repetitivos. O comando `/ajuda` conecta o jogador diretamente à IA.
*   **Resolução de Dúvidas:** "Como compro um carro?", "Onde fica a prefeitura?". A IA responde com base na Wiki do servidor.
*   **Filtragem de Tickets:** Reduz em 90% a carga da staff, permitindo foco em problemas reais.
*   **Aprendizado Contínuo:** O sistema aprende com as perguntas mais frequentes.

---

### 🚓 DESPACHO TÁTICO IMERSIVO (`/911`)
**Coordenação Policial Avançada**
O sistema de emergência não envia apenas um blip. Ele cria uma narrativa.
*   **Relatórios Detalhados:** A IA analisa a chamada e gera um relatório de situação para a polícia (Cores, Veículos, Suspeitos).
*   **Priorização Automática:** Classifica chamados baseados na gravidade descrita pelo jogador.
*   **Audio Dispatch:** (Roadmap) Integração futura com TTS para despacho por voz.

---

## 📦 NÚCLEO GODZ ([godz_core])

### 🛡️ GODZ ADMIN
**Gestão Administrativa & Auditoria**
Painel administrativo completo com ferramentas de monitoramento em tempo real e logs de auditoria detalhados para garantir a integridade do servidor.

---

### 💰 GODZ BANK
**Finanças, PIX e Histórico Digital**
Sistema bancário moderno com interface Glassmorphism, suporte a transferências instantâneas (PIX), extratos detalhados e gestão de cartões de crédito.

---

### 📉 GODZ ECONOMY
**Inteligência Econômica**
Algoritmo avançado que regula a inflação e os preços de mercado dinamicamente, mantendo o equilíbrio financeiro do servidor.

---

### ⚔️ GODZ SENTINEL
**Proteção Ativa**
Sistema de segurança robusto que atua como um escudo contra injetores e tentativas de exploração, garantindo um ambiente justo para todos.

---

### 👥 GODZ IDENTITY
**Multicharacter com Lore IA**
Criação de personagens imersiva onde a IA gera biografias únicas baseadas nas escolhas do jogador. Interface visual premium para seleção de personagens.

---

### 🏠 GODZ HOUSING
**Sistema Imobiliário & Decoração**
Compra, venda e aluguel de propriedades com sistema de decoração livre, permitindo que os jogadores personalizem seus espaços.

---

### 🎒 GODZ INVENTORY
**Gestão de Itens com Metadados**
Inventário inteligente que suporta metadados (durabilidade, número de série, etc.) e drag-and-drop fluido.

---

### 📋 OUTROS MÓDULOS CORE
*   **godz_chest:** Sistema de baús seguros e compartilhados.
*   **godz_connect:** Gerenciamento de filas e conexões otimizado.
*   **godz_dispatch:** Central de despachos unificada.
*   **godz_events:** Sistema de eventos dinâmicos pelo mapa.
*   **godz_garage:** Garagem pessoal com persistência de veículos.
*   **godz_jobs:** Empregos interativos e diversificados.
*   **godz_missions:** Missões diárias e semanais geradas proceduralmente.
*   **godz_phone:** Smartphone funcional com apps reais (Twitter, Instagram, Banco).
*   **godz_target:** Sistema de interação "olho" otimizado (ox_target).
*   **godz_tuning:** Oficina mecânica com diagnóstico via IA.

---

## 🛡️ ESPECIALIZAÇÕES ([godz_modules])

### ⚔️ GODZ FACTIONS
**Gestão de Organizações**
Painel completo para líderes de facções gerenciarem membros, cargos, salários e o cofre da organização, seja ela criminosa ou legal.

---

### 💊 GODZ ILLEGAL
**Rotas de Drogas & Lavagem**
Ecossistema criminal profundo com rotas de produção de drogas, riscos calculados e sistemas de lavagem de dinheiro através de empresas de fachada.

---

### 🔥 GODZ SHIELD
**Firewall Anti-DDoS**
Camada extra de proteção de rede para mitigar ataques de negação de serviço e manter o servidor online e estável.

---

### 🎫 GODZ SUPPORT
**Sistema de Tickets In-Game**
Ferramenta integrada para jogadores reportarem bugs ou denúncias diretamente para a staff sem sair do jogo.

---

### 🚗 GODZ GARAGES
**Expansão Empresarial**
Módulo estendido de garagens focado em empresas, permitindo frotas corporativas e compartilhamento de veículos entre funcionários.

---

## 🗄️ ARQUITETURA DE DADOS (DB)

### 📊 GODZ USERS (TABELA MESTRA)
**A Espinha Dorsal do Servidor**
Estrutura otimizada para segurança e performance.
*   **`id`**: Identificador único do cidadão.
*   **`whitelisted`**: Status de aprovação.
*   **`banned`**: Status de banimento global.
*   **`ip`**: Rastreio de IP para segurança e auditoria.
*   **`last_login`**: Data/Hora da última conexão (`%d/%m/%Y %H:%M:%S`).
*   **Controle Integrado:** Moedas Premium, Pets e Slots de Garagem vinculados diretamente ao ID.

---

## 🛠️ TECHNICAL UPDATES
**Patch Notes - Identidade e Persistência de Dados**

O sistema de identificação recebeu atualizações críticas para garantir a estabilidade e a integridade dos dados desde a primeira conexão:

*   **🛡️ Prioridade de Registro de IP (Async Fix):** O sistema de conexão (`vrp/base.lua`) agora executa a gravação do IP e Last Login no banco de dados **antes** de liberar o jogador para a verificação da IA. Isso é garantido por uma execução forçada via OxMySQL e um delay estratégico de sincronização.
*   **🔄 Sincronização de IA (Wait Check):** O módulo `godz_shield` implementa um `Wait(500)` na conexão para assegurar que a IA apenas consulte a base de dados após o registro completo do jogador, eliminando falsos negativos na whitelist.
*   **💾 Redundância de Identidade:** O `godz_identity` agora possui um sistema de **Retry Automático** se os dados retornarem nulos na primeira tentativa, além de um fallback seguro para perfis temporários, impedindo quedas de conexão por timeouts de banco de dados.

---

> *GODZ ENGINE - Desenvolvido para quem exige a perfeição.*
