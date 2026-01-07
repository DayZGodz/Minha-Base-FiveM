# 👑 Família God - Super Base Unified (2026)

Bem-vindo à documentação oficial da **Família God**, a evolução definitiva em servidores de Roleplay para FiveM.

---

## 📖 Identidade & Missão
Este projeto representa a culminação de anos de desenvolvimento, unificando o melhor de três bases lendárias:
*   **Unity Clean**: Performance e código limpo.
*   **Zirix v2**: Funcionalidades robustas e sistemas testados.
*   **Bahamas (Hensa)**: Inovações em gameplay e economia.

Nosso objetivo é fornecer uma experiência de RP de alta fidelidade, com zero "bloatware", segurança reforçada e uma arquitetura preparada para escalar.

---

## 🏗️ Arquitetura do Projeto

A estrutura de diretórios foi desenhada para separar claramente o motor do jogo dos dados do servidor, facilitando atualizações e CI/CD.

*   **`artifacts/`**: Contém os binários do FXServer (o motor). Mantenha esta pasta atualizada via `godz_updater.py`.
*   **`server/`**: O coração do seu projeto.
    *   `config/`: Arquivos `.cfg` essenciais.
    *   `resources/`: Scripts e assets organizados por categorias (`[godz_core]`, `[assets]`, etc.).
    *   `godz_ai_bridge.py`: Ponte de inteligência artificial.

---

## 📦 Ecossistema de Scripts (Godz Core)

Cada script foi refatorado para garantir estabilidade e performance. O prefixo técnico `godz_` garante integridade no banco de dados, enquanto a marca "Família God" brilha no jogo.

### 🏦 Godz Bank
Sistema bancário completo com interface NUI moderna, logs de transações e suporte a múltiplas contas.

### 🆔 Godz Identity
Gerenciamento de identidades (RG, CNH) vinculado ao ID do usuário no banco de dados unificado.

### 🔧 Godz Tuning
Módulo de modificação de veículos.
*   **Melhoria Técnica**: Substituímos chamadas inseguras de `io.open` pela nativa `LoadResourceFile`, eliminando erros de caminho absoluto e garantindo compatibilidade total com o sistema de arquivos do FiveM.

### 🎒 Godz Inventory (Legacy & New)
O sistema de inventário foi blindado contra falhas comuns.
*   **Fix de Inicialização**: Implementamos uma lógica de `Wait` inteligente que impede o jogador de acessar o inventário antes que seus dados sejam carregados do banco.
*   **Prevenção de Erros**: A tabela `vRP.items = {}` é inicializada explicitamente para evitar erros de "attempt to index a nil value" durante o boot.

---

## 🤖 IA & Monitoramento (Godz AI Bridge)

A **GODZ AI BRIDGE** é o cérebro invisível do servidor.
*   **Tecnologia**: Um script Python (`godz_ai_bridge.py`) que roda em paralelo ao servidor.
*   **Auditoria Econômica**: Utiliza bibliotecas de análise (como `torch` no backend) para monitorar o fluxo de dinheiro.
*   **Detecção**: Identifica anomalias, como facções gerando mais de **$20k/h**, e alerta automaticamente a administração via Discord.

---

## � Guia de Instalação

### 1. Banco de Dados
O projeto utiliza um banco de dados unificado para máxima performance.
1.  Instale o MariaDB/MySQL.
2.  Importe o arquivo `godz_database.sql` localizado na raiz.
3.  O driver **oxmysql** gerencia todas as conexões de forma assíncrona.

### 2. Configuração
1.  Edite o arquivo `server/config/config.cfg`.
2.  Insira sua chave de licença FiveM e a API Key da Steam.
3.  Configure a string de conexão do banco de dados.

### 3. Permissões
Configure o `GODZ_MASTER_CONFIG.json` com os IDs do Discord dos administradores para liberar acesso ao painel de controle e comandos sensíveis.

---

## 🛠️ Suporte & Comunidade
Participe do desenvolvimento e reporte bugs em nosso repositório oficial.

> *Família God: Performance, Segurança e Roleplay de Verdade.*
