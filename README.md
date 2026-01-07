# Familía God - Base FiveM Premium

![Familía God Banner](https://via.placeholder.com/800x200.png?text=Familia+God+Base+Premium)

## � Identidade e História
A **Familía God** representa a culminação de anos de desenvolvimento e otimização no cenário FiveM. Esta base é o resultado de uma fusão estratégica e técnica entre três das mais respeitadas bases do mercado:

*   **Unity Clean**: A fundação leve e otimizada, garantindo performance superior e zero lag.
*   **Zirix v2**: A robustez e as funcionalidades clássicas que definiram uma era de RP.
*   **Bahamas**: Sistemas exclusivos e inovações de jogabilidade que trazem modernidade.

O resultado é uma infraestrutura **híbrida e poderosa**, projetada para estabilidade, escalabilidade e uma experiência de jogador imersiva.

---

## 🏗️ Arquitetura Técnica
A estrutura do projeto foi reorganizada para separar claramente o ambiente de execução dos dados do servidor, facilitando atualizações e manutenção.

### Estrutura de Diretórios
*   **`artifacts/`**: Contém os binários do servidor FiveM (fxserver.exe e dependências). Mantemos esta pasta separada para facilitar a atualização da build do servidor sem afetar os scripts.
*   **`server/`**: O coração da base.
    *   `resources/`: Todos os scripts e recursos.
    *   `server.cfg`: Configurações principais.
    *   `start.bat`: Script de inicialização automatizado e estilizado.

Esta separação garante que a lógica de negócio (`server/`) esteja desacoplada da runtime (`artifacts/`), seguindo as melhores práticas de DevOps para FiveM.

---

## 🔧 Core vRP Fixes
Para garantir a estabilidade absoluta, realizamos correções profundas no núcleo do vRP.

### 1. Inicialização de Itens (`vRP.items = {}`)
Um erro comum em bases vRP é a tentativa de indexar `vRP.items` antes de sua definição.
**Correção:** Em `vrp/modules/inventory.lua`, garantimos a inicialização explícita no topo do arquivo:
```lua
vRP.items = {} -- Inicialização preventiva
-- ... restante do código
```
Isso previne erros de "attempt to index a nil value" durante o carregamento de módulos dependentes.

### 2. Lógica de Wait (Prevenção de Nil Value)
Implementamos loops de verificação (`Wait`) em scripts críticos (como inventário e identidade) para aguardar o carregamento completo das tabelas do banco de dados e do objeto vRP antes de prosseguir.
**Exemplo de Lógica:**
```lua
Citizen.CreateThread(function()
    while not vRP or not vRP.getUserId do
        Wait(100)
    end
    -- Execução segura após carregamento
end)
```
Essa abordagem elimina condições de corrida (race conditions) na inicialização do servidor.

---

## � Módulos God (Godz Scripts)
A base conta com uma suite exclusiva de scripts desenvolvidos ou refatorados pela equipe Familía God, prefixados com `godz_` para fácil identificação e padronização.

### Lista de Módulos Principais
*   **`godz_core`**: Núcleo de funções compartilhadas.
*   **`godz_admin`**: Ferramentas administrativas avançadas.
*   **`godz_bank`**: Sistema bancário com UI moderna.
*   **`godz_chest`**: Baús de facções e casas otimizados.
*   **`godz_clothing`**: Loja de roupas com persistência robusta.
*   **`godz_factions`**: Gerenciamento completo de facções ilegais.
*   **`godz_garages`**: Sistema de garagens com salvamento de estado.
*   **`godz_housing`**: Sistema imobiliário dinâmico.
*   **`godz_identity`**: Criação e gestão de identidade (RG).
*   **`godz_inventory`**: Inventário com peso, slots e hotbar, altamente responsivo.
*   **`godz_missions`**: Missões interativas para empregos.
*   **`godz_phone`**: Smartphone funcional integrado (banco, twitter, fotos).
*   **`godz_tuning`**: Oficina de tunagem completa.

### Destaque Técnico: Tuning Otimizado
No módulo `godz_tuning`, substituímos chamadas pesadas de banco de dados por arquivos de configuração JSON carregados via `LoadResourceFile`.
**Benefício:** Carregamento instantâneo de preços e configurações de peças, sem latência de SQL.
```lua
-- Exemplo em godz_tuning/server.lua
local config = LoadResourceFile(GetCurrentResourceName(), "GODZ_MASTER_CONFIG.json")
MasterConfig = json.decode(config)
```

---

## 🤖 Familía God AI: Infraestrutura de Próxima Geração
A inovação central desta base é a integração com Inteligência Artificial para monitoramento, gestão e suporte, agora operando em nível de produção.

### Infraestrutura de Produção (WSGI)
Abandonamos o servidor de desenvolvimento do Flask em favor do **Waitress**, um servidor WSGI robusto e escalável.
*   **Concorrência:** Suporte real a múltiplos jogadores e requisições simultâneas sem bloqueios.
*   **Estabilidade:** Eliminação de avisos de "Development Server" e maior resiliência a falhas.
*   **Performance:** Otimização no handling de threads para inferência de IA.

### Modelo de IA & Otimização
Utilizamos o modelo **`microsoft/Phi-3-mini-4k-instruct`**, um LLM (Large Language Model) leve e poderoso, capaz de rodar localmente com alta eficiência.
*   **Aceleração:** Uso de `flash-attn` e `hf_xet` para inferência ultra-rápida em GPUs NVIDIA.
*   **Segurança:** O bridge Python (`godz_ai_bridge.py`) implementa sanitização rigorosa de tokens (`.strip()`) para prevenir erros de autenticação ("Improper token") e vazamento de credenciais.
*   **Log Padronizado:** Todo o sistema de logs foi unificado sob a tag `[FAMILÍA GOD AI]` para fácil rastreabilidade.

### Monitoramento de Facções
A IA analisa logs em tempo real para calcular o lucro das facções:
1.  Coleta dados de transações (vendas de drogas, lavagem de dinheiro).
2.  Processa os valores via Python.
3.  Gera relatórios de eficiência e alerta sobre anomalias econômicas.

---

## 🚀 Como Iniciar

### Pré-requisitos
*   **Game Build:** A base requer a build `3095` (ou superior) para carregar corretamente os assets de roupas e veículos. Isso já está configurado no `server.cfg`, mas certifique-se de não remover a linha `set sv_enforceGameBuild 3095`. Sem isso, texturas e DLCs podem bugar.
*   Python 3.10+
*   Dependências Python:
    ```bash
    pip install -r server/requirements.txt
    ```
    *(Nota: `flash-attn` é recomendado para GPUs NVIDIA, mas opcional em Windows se houver problemas de compilação)*

### Start
Execute o arquivo `server/start.bat`. O script irá:
1.  Limpar o cache automaticamente.
2.  Iniciar a bridge de IA.
3.  Subir o servidor FiveM.

---
*Desenvolvido por Familía God Dev Team - 2025*
