# 👑 Família God - Super Base Unified (2026)

## 📖 História do Projeto
O projeto **Família God** nasceu da necessidade de elevar o padrão do Roleplay no Brasil. Unificamos três bases lendárias para criar algo único:
*   **Unity Clean**: A base mais otimizada e leve do mercado.
*   **Zirix v2**: Conhecida por seus sistemas robustos e testados em batalha.
*   **Bahamas (Hensa)**: Referência em inovações de gameplay e economia balanceada.

Esta fusão resultou em uma super base focada em **Performance**, **Segurança** e **Escalabilidade**.

## 🔭 Visão Geral
Unificamos três bases consagradas (Unity Clean, Zirix v2, Bahamas/Hensa) para entregar a Super Base **Família God**. Mantemos o prefixo técnico `godz_` para compatibilidade e identidade operacional, enquanto toda a experiência e os logs exibem a marca **Família God**.

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
A **GODZ AI BRIDGE** é o cérebro invisível que protege a economia e a integridade do servidor Família God. Diferente de sistemas de log passivos, nossa IA atua ativamente para identificar anomalias.

### 🧠 Tecnologia Neural (Transformers)
Utilizamos a biblioteca `transformers` (Hugging Face) para carregar modelos de linguagem locais (como `Phi-3` ou `TinyLlama`), permitindo que o servidor "entenda" o contexto dos logs.
*   **Análise Semântica**: A IA não busca apenas palavras-chave; ela analisa o contexto. Ex: Um jogador recebendo $1.000.000 de um Admin é normal (evento), mas receber de um desconhecido é flagrado como suspeito.
*   **Hardware Agnostic**: O script detecta automaticamente se há GPU (CUDA) disponível; caso contrário, roda em modo otimizado para CPU.

### 📊 Auditoria Econômica em Tempo Real
O módulo de economia utiliza algoritmos preditivos para monitorar o fluxo de caixa:
*   **Threshold de Alerta**: Facções que geram mais de **$20.000/hora** ativam um alerta nível DEFCON 3.
*   **Detecção de Dupes**: Padrões repetitivos de transações (ex: sacar/depositar valores idênticos em milissegundos) são bloqueados e reportados.

### 🤖 Configuração do Bot Discord
O **Família God Bot** conecta o servidor in-game ao seu Discord.
1.  **Token**: Insira seu token no arquivo `server/resources/[godz_core]/godz_tuning/GODZ_MASTER_CONFIG.json`.
    ```json
    "discord_token": "SEU_TOKEN_AQUI"
    ```
2.  **Permissões**: O bot requer intents de `guilds` e `message_content` ativados no Portal do Desenvolvedor.
 3.  **Logs Automáticos**: Ao iniciar, o bot cria automaticamente categorias e canais de log (Audit, Sentinel, Bank) se não existirem.

---

## 🧩 Requisitos do Sistema
- Python 3.12+
- Torch (CPU/GPU conforme disponibilidade)
- Accelerate (gerência de dispositivos e paralelismo)
- Transformers (modelos de linguagem locais)
- Hugging Face Hub (com extra `hf_xet` para aceleração de downloads)

Instalação rápida:

```bash
pip install -r server/requirements.txt
pip install accelerate "huggingface-hub[hf_xet]"
# Em ambientes Linux com CUDA: pip install flash-attn
```

Observação: em Windows, o pacote flash-attn pode não possuir wheel pré‑compilado; use WSL2 + CUDA para instalação.

## 🛠️ Manual do Desenvolvedor (vRP)
- Carregamento de Itens: o vRP inicializa dicionários de itens no boot. Defina `vRP.items = {}` antes de módulos dependentes para evitar erros de nil.
- Wait Logic: aguarde conexão do banco e dicionários populados antes de liberar inventário. Evita inventário vazio no login.
- Permissões: use `vRP.hasPermission(user_id, "perm.nome")` para gates de ações críticas (banco, chest, tuning).
- Integração com IA: endpoints expostos via Flask (`/status`, `/config`, `/ai_assist`) e webhooks do Discord para auditoria.

## 🧯 Solução de Problemas
- players.json indisponível: habilite `sv_endpointPrivacy` corretamente e confirme porta 30120 aberta; a IA usa `http://127.0.0.1:30120/players.json` para contabilizar online.
- Symlinks no Windows: ative o Developer Mode para permitir links simbólicos (necessário em alguns fluxos de IA/recursos).
  - Windows 11: Configurações → Privacidade e Segurança → Para Desenvolvedores → Ativar Modo de Desenvolvedor.
  - Windows 10: Configurações → Atualização e Segurança → Para Desenvolvedores → Modo de Desenvolvedor.
- Flash‑Attention no Windows: prefira WSL2 com CUDA e drivers NVIDIA; caso indisponível, use `Accelerate`/CPU como fallback.

## 🚀 Instalação e Suporte

1.  Clone o repositório.
2.  Importe o `godz_database.sql`.
3.  Configure o `server.cfg` com suas chaves.
4.  Inicie o servidor e aproveite a estabilidade da **Família God**.

> *Desenvolvido para quem leva o RP a sério.*
