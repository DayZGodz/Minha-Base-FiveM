# 👑 Ecossistema GODZ Roleplay (Super Base Unified)

## 📋 Descrição
Projeto de fusão das bases Unity, Zirix e Bahamas com rebranding total e monitoramento por IA. Esta base representa o estado da arte em desenvolvimento FiveM, focada em performance, segurança e escalabilidade.

## 📂 Estrutura de Pastas
A organização do servidor segue padrões profissionais para facilitar manutenção e CI/CD:

- **artifacts/** (Engine): Contém os binários do servidor FXServer (Alpine/Windows). Separado dos dados para facilitar atualizações.
- **server/** (Data/Resources): Contém todos os scripts, configurações e dados do servidor.
  - **resources/**: Os recursos são categorizados utilizando colchetes `[]` (ex: `[godz_core]`, `[assets]`) para garantir ordem de carregamento e organização visual, além de evitar warnings de "missing manifest" em pastas puramente organizacionais.

## ⚙️ Core Framework (vRP)
O framework vRP foi estabilizado e otimizado:
- **Correção de Inicialização**: Implementada lógica de `Wait` inteligente para garantir que itens e inventários sejam carregados apenas após a conexão completa com o banco de dados.
- **Inventário**: Sistema reescrito para evitar duplicação e garantir transações atômicas.

## 🔧 Configuração Central
O coração da configuração reside no arquivo `GODZ_MASTER_CONFIG.json`.
- **LoadResourceFile**: Para evitar erros de "caminho não encontrado" ou problemas com caminhos absolutos (`D:/...`), utilizamos a função nativa `LoadResourceFile(GetCurrentResourceName(), 'GODZ_MASTER_CONFIG.json')` nos scripts Lua. Isso garante portabilidade total do servidor.

## 💾 Banco de Dados
- **Schema Unificado**: Migração completa para o banco `godz_database`, eliminando bancos fragmentados.
- **Driver**: Utilização exclusiva do **oxmysql** para alta performance e queries assíncronas.

## 🤖 IA & Auditoria
- **GODZ AI BRIDGE**: Um sistema de ponte escrito em Python que conecta o servidor a serviços de IA para monitoramento em tempo real.
- **Monitoramento Econômico**: A IA analisa logs de transações para detectar anomalias, dupes ou injeção de dinheiro ilegal na economia do servidor.
