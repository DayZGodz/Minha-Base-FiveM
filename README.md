# 👑 GODZ ENGINE

**O Ápice da Engenharia de Simulação**

A **GODZ ENGINE** representa a próxima fronteira em infraestrutura para FiveM. Desenvolvida sob uma arquitetura proprietária de alta performance, nossa engine elimina gargalos de processamento tradicionais através de threads assíncronas e otimização de baixo nível. Este não é apenas um servidor; é um ecossistema vivo, governado por Inteligência Artificial e protegido por sistemas de segurança de nível militar.

---

## 🤖 CORE INTELLIGENCE (AI & BOT)

A inteligência é o alicerce da nossa infraestrutura. A GODZ opera com um sistema híbrido de processamento neural e automação externa.

| Tecnologia | Funcionalidade e Integração |
| :--- | :--- |
| **GODZ AI Nexus** (Phi-3 Mini) | O cérebro local da cidade. Processa linguagem natural para oferecer **Suporte Inteligente** (`/ajuda`), gera **Laudos Técnicos de Tuning**, coordena o **Despacho Policial** (`/911`) e cria **Lore de Personagens** (`/rg`) em tempo real. |
| **GODZ Discord Bot** (Python) | A ponte de comando externa. Bot desenvolvido em Python que realiza **sincronização de cargos** em tempo real, espelha **logs administrativos** sensíveis e permite **gestão remota** do servidor. |

---

## 📂 ARQUITETURA DE MÓDULOS PROPRIETÁRIOS

Nossa codebase é estruturada em módulos independentes, garantindo estabilidade e facilidade de manutenção. Cada módulo é uma peça de engenharia exclusiva GODZ.

| Módulo | Descrição Técnica e Funcionalidade |
| :--- | :--- |
| `godz_admin` | Gestão administrativa avançada com ferramentas de auditoria e monitoramento em tempo real. |
| `godz_bank` | Ecossistema financeiro digital completo com interface premium, PIX e histórico de transações. |
| `godz_sentinel` | Sistema de proteção ativa server-side (Kernel Level Logic) contra injetores, triggers maliciosos e abusos. |
| `godz_economy` | Regulador econômico inteligente que ajusta preços e salários dinamicamente para controlar a inflação. |
| `godz_identity` | Sistema multicharacter robusto com geração de Lore imersiva assistida por IA no momento da criação. |
| `godz_interface` | Framework UI/UX exclusivo utilizando o Design System "Dark Gold" e Glassmorphism. |
| `godz_inventory` | Inventário inteligente com metadados, sistema de peso dinâmico e hotbar responsiva. |
| `godz_factions` | Sistema de gestão de organizações criminosas e corporações com hierarquias customizáveis. |
| `godz_illegal` | Rotas de atividades ilícitas, desmanches e economia paralela integradas ao risco global. |
| `godz_shield` | Camada de segurança lógica e firewall de eventos para mitigação de ataques e flood. |
| `godz_tuning` | Oficina mecânica avançada com diagnóstico técnico gerado por IA e persistência total de mods. |
| `godz_garage` | Gestão de frotas pessoais e de facção com salvamento persistente de estado e danos. |

---

## 🗄️ GODZ DATA ARCHITECTURE

Nossa estrutura de dados é desenhada para segurança máxima e rastreabilidade total. A tabela mestra `godz_users` é o coração da persistência do cidadão.

### Tabela Mestra: `godz_users`

*   **🛡️ Segurança de Acesso:**
    *   `ip`: Rastreamento de endereço IP de última conexão para auditoria de segurança e prevenção de evasão.
    *   `last_login`: Timestamp preciso para controle de inatividade e purga automática de contas ociosas.
    *   `whitelisted` / `banned`: Flags booleanas de controle de acesso rígido e banimento global.

*   **💾 Integração de Ativos:**
    *   `moedas`: Saldo de moeda Premium protegido por validação server-side rigorosa.
    *   `pet`: Armazenamento JSON dos dados do animal de estimação vinculado ao cidadão.
    *   `garagem`: Estrutura JSON complexa contendo a frota de veículos, suas modificações e estados.

---

## 💎 SIGNATURE EXPERIENCE

A identidade visual da GODZ é inconfundível, projetada para transmitir luxo, exclusividade e tecnologia de ponta.

*   **Padrão Dark Gold (#D4AF37):** A cor primária que define nossa marca. Utilizada estrategicamente em acentos, bordas e destaques vitais, criando um contraste elegante com fundos escuros profundos (Carbon Black).
    
*   **Glassmorphism UI:** Todas as interfaces utilizam desfoque de fundo (`backdrop-filter`) e transparências calculadas, criando uma estética de vidro fosco moderna que mantém a imersão no ambiente 3D.
    
*   **Notificações `ia_tip`:** Um sistema exclusivo de alertas com animação de **pulso dourado**, utilizado especificamente para indicar interações diretas com a Inteligência Artificial do servidor, diferenciando-as de notificações comuns do sistema.
