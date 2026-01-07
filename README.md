# 👑 Família God - Super Base Unified (2026)

## 📖 Introdução
Bem-vindo à **Família God**, um projeto ambicioso que unifica o melhor de três mundos: Unity Clean, Zirix v2 e Bahamas (Hensa). Nossa missão é entregar uma base focada em performance extrema, segurança robusta e uma experiência de Roleplay de alta qualidade, livre de "bloatware" e otimizada para escalabilidade.

## 🚀 Guia de Instalação

### Pré-requisitos
- FXServer (Artifacts) atualizado
- Banco de Dados MySQL/MariaDB

### Configuração do Banco de Dados
1.  **Driver**: Utilizamos exclusivamente o **oxmysql** para performance assíncrona.
2.  **Schema**: Importe o arquivo `godz_database.sql` (ou equivalente na raiz) para criar a estrutura unificada.
3.  **Conexão**: Configure sua string de conexão no `server.cfg` apontando para o banco `godz_database`.

## 📦 Módulos do Sistema

### 🎒 Inventory (Inventário)
Sistema de inventário reescrito para garantir transações atômicas.
- **Fix**: Correção de *race conditions* que causavam duplicação de itens.
- **Lógica**: Implementação de `Wait` inteligente na inicialização para garantir que os dados do jogador estejam carregados antes de liberar o acesso.

### 🏦 Bank (Banco)
Sistema bancário integrado com logs detalhados e interface moderna (NUI). Suporta múltiplas contas e transações seguras.

### 🆔 Identity (Identidade)
Gerenciamento robusto de identidade de personagens (RG, CNH, Passaporte), vinculado diretamente ao ID do usuário no banco de dados unificado.

### 🔧 Tuning (Mecânica)
Módulo avançado de modificação de veículos, salvando propriedades visuais e de performance no banco de dados.

## 🤖 IA Audit System
Uma ponte inovadora entre o servidor FiveM e um backend Python.
- **Funcionamento**: O script `godz_ai_bridge.py` monitora logs em tempo real.
- **Auditoria**: Utiliza lógica (e potencialmente bibliotecas como `torch` no backend) para identificar anomalias econômicas, *dupes* e comportamentos suspeitos, enviando alertas para o Discord.

## 🛠️ Changelog de Correções

### Core & Estabilidade
- **Wait Logic**: Implementado `Wait` estratégico no carregamento de itens para evitar tentativas de acesso a tabelas nulas durante o login.
- **LoadResourceFile**: Migração de todas as chamadas de I/O de arquivo para `LoadResourceFile`, eliminando erros de caminho absoluto e garantindo compatibilidade entre Windows e Linux.

### Rebranding
- **Identidade**: Padronização de todos os logs e mensagens visuais para "Família God".
- **Técnico**: Manutenção do prefixo `godz_` em nomes de recursos e tabelas para integridade referencial.
