# 👑 Família God - Super Base Unified (2026)

## 📖 História do Projeto
O projeto **Família God** nasceu da necessidade de elevar o padrão do Roleplay no Brasil. Unificamos três bases lendárias para criar algo único:
*   **Unity Clean**: A base mais otimizada e leve do mercado.
*   **Zirix v2**: Conhecida por seus sistemas robustos e testados em batalha.
*   **Bahamas (Hensa)**: Referência em inovações de gameplay e economia balanceada.

Esta fusão resultou em uma super base focada em **Performance**, **Segurança** e **Escalabilidade**.

---

## 🏗️ Arquitetura de Dados
Para garantir a integridade e velocidade das informações, realizamos mudanças estruturais profundas:

### Banco de Dados Unificado (`godz_database`)
Abandonamos o uso de múltiplos bancos fragmentados. Todo o ecossistema agora reside no schema `godz_database`, simplificando backups e manutenção.

### Driver `oxmysql`
Migramos 100% das queries para o **oxmysql**, aproveitando sua capacidade de execução assíncrona e suporte a transações complexas, eliminando travamentos na thread principal do servidor.

---

## ⚙️ Estabilização do Core (vRP)
O framework vRP recebeu correções críticas para eliminar erros históricos:

### Inicialização de Tabelas
Adicionamos a inicialização explícita de `vRP.items = {}` no boot do servidor. Isso previne o erro comum de *attempt to index a nil value* quando scripts tentam acessar itens antes do carregamento completo.

### Wait Logic (basic_items.lua)
Implementamos uma lógica de espera (`Wait`) inteligente. O servidor agora aguarda a confirmação de conexão com o banco de dados e o carregamento dos dicionários de itens antes de liberar o acesso aos inventários, erradicando falhas de "inventário vazio" no login.

---

## 📦 Módulos de Script (Godz Core)
Cada módulo foi revisado e modernizado, mantendo o prefixo técnico `godz_` para integridade, mas exibindo a identidade **Família God**.

### 🏦 Godz Bank
*   **Função**: Sistema bancário completo com NUI, empréstimos e múltiplas contas.
*   **Melhoria**: Logs de transações detalhados para auditoria.

### 🆔 Godz Identity
*   **Função**: Emissão e validação de RG, CNH e Passaporte.
*   **Melhoria**: Vinculação direta e imutável ao ID do usuário no banco.

### 🎒 Godz Inventory
*   **Função**: Gerenciamento de itens, peso e hotbar.
*   **Melhoria**: Proteção contra *dupes* via transações atômicas e validação server-side rigorosa.

### 🔧 Godz Tuning
*   **Função**: Customização veicular completa.
*   **Melhoria Crítica**: Substituição de chamadas obsoletas de `io.open` pela função nativa `LoadResourceFile`. Isso resolve problemas de caminhos absolutos e permissões de arquivo em diferentes sistemas operacionais.

---

## 🤖 IA & Monitoramento (Godz AI Bridge)
A **GODZ AI BRIDGE** é o diferencial tecnológico do projeto.

*   **Tecnologia**: Script Python (`godz_ai_bridge.py`) rodando em paralelo.
*   **Módulo Torch**: Utiliza aprendizado de máquina para analisar padrões de log.
*   **Auditoria Econômica**: Monitora em tempo real o fluxo de dinheiro das facções. Se uma organização gera mais de **$20k/h** sem justificativa (ex: farm excessivo ou exploit), um alerta de prioridade máxima é enviado para a administração.

---

## 🚀 Instalação e Suporte

1.  Clone o repositório.
2.  Importe o `godz_database.sql`.
3.  Configure o `server.cfg` com suas chaves.
4.  Inicie o servidor e aproveite a estabilidade da **Família God**.

> *Desenvolvido para quem leva o RP a sério.*
