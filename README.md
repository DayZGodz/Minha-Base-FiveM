# GODZ DEV BASE VRPEX

> Base oficial GODZ, unificada e profissional, construída sobre VRPex com foco em Performance, Segurança e Escalabilidade.

---

## 📋 Sobre o Projeto

Este projeto representa o estado da arte em desenvolvimento FiveM, focado em **Performance**, **Segurança** e **Escalabilidade**. Removemos todo o "bloatware" desnecessário para entregar uma experiência fluida, mantendo os sistemas complexos que os jogadores amam (Inventário GODZ, Tuning Avançado, etc.) funcionando em harmonia com um Core otimizado.

---

## 🛠️ Stack Tecnológico & Recursos

### 🛡️ Segurança & Core
> Núcleo GODZ. Leve, rápido e protegido.
- Banco de Dados Unificado (OxMySQL) com transações otimizadas.
- Shield e Anticheat proprietários, integrados ao ecossistema GODZ.

### 👤 Identidade & Inventário
> Experiência de RPG moderna e estável.
- Criação de Personagem completa (CNH, RG) com persistência visual.
- Inventário GODZ e integração com inventário legado (quando habilitado).

### 📱 Comunicação & Tecnologia
> Ferramentas essenciais para o roleplay moderno.
- GODZ Phone: celular completo (Twitter, WhatsApp, Câmera).
- Logs Centralizados com webhooks para auditoria e monitoramento.

### 💎 Experiência Visual e HUD
> Identidade visual GODZ, consistente e moderna.
- GODZ Notify (NUI) em Glassmorphism.
- Padronização visual entre Inventário, Celular e Notificações.

### 🏴 Gestão de Facções Profissional
> Controle total para líderes, integrado e automatizado.
- Painel NUI para contratação e demissão em tempo real.
- Controle de farm e monitoramento por baú/membro.

### 👮 Policiamento Avançado
> Evolução das interações policiais com foco em imersão.
- Menu Tático GODZ (`/pmenu`) centraliza ações essenciais.
- Verificar Ficha, Apreender Itens, Escoltar, Algemar e Gestão de Veículos.

### 🎯 Interação Avançada (Third Eye)
> Sistema de alvo moderno estilo ox_target/qtarget, integrado ao GODZ.
- Recurso: `godz_target` com NUI leve (Glassmorphism).
- Ativação: segure ALT, mire e clique direito para abrir opções.
- Alvos de Jogador: Menu Policial, Verificar Ficha, Apreender, Algemar, Escoltar, CV/RV.
- Garagens via Third Eye: selecione “Acessar Garagem” nas zonas.
- Performance: substitui markers e reduz consumo de FPS.
- Arquivos-Chave:
  - [client.lua](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_assets%5D/godz_target/client.lua)
  - [client.lua](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_core%5D/godz_modules/policia/client.lua)
  - [server.lua](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_core%5D/godz_modules/policia/server.lua)
  - [client.lua](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_jobs%5D/godz_garages/client.lua)

### 🛠️ Gestão Administrativa 2.0
> Controle total do servidor na ponta dos dedos.
- **GODZ Admin Tablet:** Interface NUI moderna (Glassmorphism) acessível via `/admin`.
- **Ações Rápidas:** Banir, Desbanir, Reviver, Spawnar Veículos e Dar Itens com poucos cliques.
- **Monitoramento Shield:** Integração nativa com o `godz_shield` para visualizar alertas de proteção em tempo real.
- **UX Otimizada:** Design limpo e intuitivo para facilitar a moderação.

### 🏘️ Imersão & Mundo
> Ambiente vivo e otimizado.
- Shells otimizados para interiores.
- Pacotes de favelas leves.
- Elevadores funcionais (angelicxs-elevators).

### 🚗 Veículos & Mecânica
> Para quem ama carros e customização.
- **Tuning Avançado (Renzu Base):** Modificação profunda de veículos (Motor, Turbos, Extras, Pintura RGB/Matte).
- **Handling Personalizado:** Configuração física realista exposta para ajustes finos.

---

## 📦 Estrutura GODZ (Pastas e Recursos)

Organização profissional e intuitiva:

### [godz_core]
> Scripts vitais e fundamentais.
- `godz_identity`: Identidade e criação de personagem.
- `godz_inventory`: Inventário moderno e otimizado.
- `godz_logs`: Sistema centralizado de logs via webhook.
- `godz_admin`: Painel administrativo.
- `godz_modules`: Módulos centrais (ferimentos, wall, etc).

### [godz_illegal]
> Crime e economia subterrânea.
- `godz_factions`: Gestão avançada de facções (painel NUI).
- `godz_drugs`: Sistema de drogas (se houver).
- `godz_robbery`: Sistema de roubos.

### [godz_jobs]
> Empregos legais e serviços públicos.
- `godz_dispatch`: Central de despacho policial.
- `godz_garages`: Sistema de garagens e veículos.
- `godz_police`: Scripts auxiliares de polícia.

### [godz_assets]
> Recursos visuais e interativos.
- `godz_target`: Sistema de interação Third Eye.
- `godz_phone`: Smartphone funcional.
- `godz_vehicles`: Veículos customizados.
- `godz_maps`: Mapeamentos exclusivos.
 - `godz_interface`: HUD moderna em Glassmorphism (Saúde, Colete, Fome, Sede, Oxigênio).

### [godz_security]
> Proteção e integridade.
- `godz_shield`: Anticheat e proteção contra exploits.

---

## 🚀 Instalação e Inicialização

1. Configure o banco de dados (MySQL/MariaDB) e importe o arquivo SQL.
2. Verifique a conexão no `server.cfg` (string de conexão oxmysql).
3. A ordem de carregamento no `resources.cfg` é crítica:
   ```cfg
   ensure [godz_core]
   ensure [godz_illegal]
   ensure [godz_jobs]
   ensure [godz_assets]
   ensure [godz_security]
   ```
4. Inicie o servidor e verifique o console para garantir que todos os recursos `godz_` foram carregados corretamente.
5. Diretório raiz de execução: `GODZ_Base`.

---

## 🐞 Relatos de Bugs

- Use `/bugs` para reportar problemas diretamente do jogo.
- Logs de bug são enviados aos administradores para correções rápidas.
- As correções de estabilidade são publicadas via GitHub.

## 💎 GODZ Interface Custom

- Interface NUI otimizada com Glassmorphism.
- Exibe Saúde, Colete, Fome, Sede e Oxigênio.
- Atualização em tempo real com baixa utilização de ms.
- Atalho: use o comando `/hud` para ocultar/exibir.
- Arquivos:
  - [fxmanifest.lua](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_assets%5D/godz_interface/fxmanifest.lua)
  - [client.lua](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_assets%5D/godz_interface/client.lua)
  - [index.html](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_assets%5D/godz_interface/nui/index.html)
  - [style.css](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_assets%5D/godz_interface/nui/style.css)
  - [script.js](file:///d:/servidor%20FIVEM/PROJETO_SUPER_BASE/01_BASE_PRINCIPAL/GODZ_Base/Base/resources/%5Bgodz_assets%5D/godz_interface/nui/script.js)

---

## ⚙️ GODZ Auto-Updater

- Ferramenta de automação para manutenção de artefatos do servidor.
- Script: `update_artifacts.ps1` (localizado na raiz `01_BASE_PRINCIPAL`).
- Funcionalidades:
  - Baixa automaticamente a build recomendada/latest do FiveM Windows.
  - Extrai e atualiza a pasta `GODZ_Base/artifacts`.
  - Limpa arquivos temporários para economizar espaço.
- Integração:
  - O `start.bat` agora pergunta se deseja verificar atualizações antes de iniciar o servidor.
  - Responda `S` (Sim) para atualizar ou `N` (Não) para iniciar imediatamente.

---

## 🔄 Changelog Recente (Refatoração GODZ)

- **Rebranding Total:** Padronização de nomes para `godz_*` (ex: `vrp_inventory` -> `godz_inventory`).
- **Otimização:** Substituição de markers pesados por zonas Third Eye em garagens e interações.
- **Code Cleanup:** Remoção de referências a bases antigas (Zirix/Unity) e código morto.
- **Fixes:** Correção de conflitos de IDs e eventos legados (`unity_inventory` -> `godz_inventory`).
