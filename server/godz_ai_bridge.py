import sys
import os
from functools import wraps

# [GODZ AI] Configuração de Cache no Disco D: (Deve vir antes dos imports do HF)
os.environ['HF_HOME'] = 'D:/servidor FIVEM/PROJETO_SUPER_BASE/ai_cache'

import json
import logging
import time
import threading
import requests
import asyncio
import discord
from discord.ext import commands
from flask import Flask, request, jsonify
from waitress import serve
import numpy as np
from datetime import datetime, timedelta

# Configuração de Logs e Cores
from colorama import init, Fore, Style
init(autoreset=True)

app = Flask(__name__)

# [GODZ AI] Habilitar CORS para NUI/Loading Screen
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

# ==================================================================================
# SEGURANÇA (API KEY)
# ==================================================================================
API_KEY = "godz_secret_key_123"
ELEVENLABS_API_KEY = "" # Carregado do Config

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        print(f"Token Recebido: {auth_header}")
        
        if not auth_header or auth_header != "Bearer godz_secret_key_123":
            return jsonify({"error": "Unauthorized"}), 403
        return f(*args, **kwargs)
    return decorated_function

# Configuração do Logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger()

print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Inicializando Sistemas Neurais...")

# ==================================================================================
# 0. MASTER CONFIGURATION (JSON)
# ==================================================================================
MASTER_CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "resources", "[godz_core]", "godz_tuning", "GODZ_MASTER_CONFIG.json")
MASTER_CONFIG = {}

def load_master_config():
    global MASTER_CONFIG
    try:
        with open(MASTER_CONFIG_PATH, "r", encoding="utf-8") as f:
            MASTER_CONFIG = json.load(f)
        print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Master Config carregada.")
    except json.JSONDecodeError as e:
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}ERRO CRÍTICO DE SINTAXE NO JSON!")
        print(f"{Fore.RED}Detalhes: {e.msg}")
        print(f"{Fore.RED}Linha: {e.lineno}, Coluna: {e.colno}")
        print(f"{Fore.YELLOW}Verifique se não esqueceu uma vírgula ou aspas.")
        # Tentar identificar a seção
        try:
            with open(MASTER_CONFIG_PATH, "r", encoding="utf-8") as f:
                lines = f.readlines()
                error_line = lines[e.lineno - 1].strip()
                print(f"{Fore.RED}Conteúdo da linha: {error_line}")
                # Heurística simples para identificar seção
                for i in range(e.lineno - 1, -1, -1):
                    if "SERVER_INFO" in lines[i]: print(f"{Fore.YELLOW}Possível erro na seção: [SERVER_INFO]"); break
                    if "PERMISSIONS" in lines[i]: print(f"{Fore.YELLOW}Possível erro na seção: [PERMISSIONS]"); break
                    if "ECONOMY" in lines[i]: print(f"{Fore.YELLOW}Possível erro na seção: [ECONOMY]"); break
                    if "SECURITY" in lines[i]: print(f"{Fore.YELLOW}Possível erro na seção: [SECURITY]"); break
                    if "WEBHOOKS" in lines[i]: print(f"{Fore.YELLOW}Possível erro na seção: [WEBHOOKS]"); break
        except:
            pass
        MASTER_CONFIG = {"SERVER_INFO": {}, "WEBHOOKS": {}, "PERMISSIONS": {}, "SECURITY": {}, "ECONOMY": {}}
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}Erro genérico ao carregar Config: {e}")
        MASTER_CONFIG = {"SERVER_INFO": {}, "WEBHOOKS": {}, "PERMISSIONS": {}, "SECURITY": {}, "ECONOMY": {}}

def save_master_config():
    try:
        with open(MASTER_CONFIG_PATH, "w", encoding="utf-8") as f:
            json.dump(MASTER_CONFIG, f, indent=4)
        print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Master Config salva com sucesso.")
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}Erro ao salvar Master Config: {e}")

load_master_config()

# ==================================================================================
# 0.1 ANALYTICS DATA
# ==================================================================================
ANALYTICS_DATA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "godz_analytics_data.json")
ANALYTICS_DATA = {"history": [], "player_last_seen": {}}

def load_analytics_data():
    global ANALYTICS_DATA
    try:
        if os.path.exists(ANALYTICS_DATA_PATH):
            with open(ANALYTICS_DATA_PATH, "r", encoding="utf-8") as f:
                ANALYTICS_DATA = json.load(f)
            print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Dados históricos carregados.")
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}Erro ao carregar dados: {e}")

def save_analytics_data():
    try:
        with open(ANALYTICS_DATA_PATH, "w", encoding="utf-8") as f:
            json.dump(ANALYTICS_DATA, f, indent=4)
    except Exception as e:
        logger.error(f"Erro ao salvar analytics: {e}")

load_analytics_data()

# ==================================================================================
# CONFIGURAÇÃO DISCORD (Carregada do JSON)
# ==================================================================================
DISCORD_TOKEN = str(MASTER_CONFIG.get("SERVER_INFO", {}).get("discord_token", "")).strip()
ELEVENLABS_API_KEY = MASTER_CONFIG.get("SERVER_INFO", {}).get("elevenlabs_api_key", "")
DISCORD_WEBHOOK_AUDIT = MASTER_CONFIG.get("WEBHOOKS", {}).get("audit", "")
DISCORD_WEBHOOK_SENTINEL = MASTER_CONFIG.get("WEBHOOKS", {}).get("sentinel", "")
DISCORD_WEBHOOK_NEWS = MASTER_CONFIG.get("WEBHOOKS", {}).get("news", "")

# Cores Neon
COLOR_NEON_PURPLE = 0x9b59b6
COLOR_NEON_RED = 0xff0000
COLOR_NEON_GREEN = 0x00ff00
COLOR_NEON_CYAN = 0x00e5ff

# ==================================================================================
# 1. INTEGRAÇÃO COM MODELO LOCAL (Transformers / Ollama)
# ==================================================================================
MODEL_NAME = "microsoft/Phi-3-mini-4k-instruct"
pipeline = None
tokenizer = None
model = None

def load_model():
    global pipeline, tokenizer, model
    try:
        print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}Verificando aceleradores de hardware...")
        import torch
        from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline as hf_pipeline

        device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Hardware detectado: {Fore.MAGENTA}{device.upper()}")

        print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}Carregando modelo {MODEL_NAME}... (Isso pode demorar na primeira vez)")
        
        # Carregamento otimizado
        tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, trust_remote_code=True)
        model = AutoModelForCausalLM.from_pretrained(
            MODEL_NAME,
            device_map=device,
            dtype="auto",
            trust_remote_code=True
        )
        
        pipeline = hf_pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,
            max_new_tokens=500
        )
        
        print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Modelo carregado com SUCESSO!")
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}Erro ao carregar modelo IA: {e}")
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}O sistema funcionará em modo 'Fallback' (Regras estáticas).")

# Iniciar carregamento em thread separada para não travar o boot
threading.Thread(target=load_model).start()

# ==================================================================================
# 2. CARREGAMENTO DE REGRAS (RAG LITE)
# ==================================================================================
RULES_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "REGRAS.txt")
RULES_CONTENT = ""

def load_rules():
    global RULES_CONTENT
    try:
        with open(RULES_PATH, "r", encoding="utf-8") as f:
            RULES_CONTENT = f.read()
        print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Regras carregadas na memória.")
        return True
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}REGRAS.txt não encontrado. Criando padrão...")
        RULES_CONTENT = "Respeite as regras do servidor Família God."
        return False

# Carregamento Inicial
load_rules()

# ==================================================================================
# 3. DISCORD BOT & WEBHOOKS
# ==================================================================================

def send_discord_webhook(url, embed):
    """Envia um Embed para um Webhook do Discord"""
    if "SEU_WEBHOOK" in url or not url:
        return
    
    payload = {
        "embeds": [embed],
        "username": "Família God Support",
        "avatar_url": "https://i.imgur.com/YourLogoHere.png"
    }
    
    try:
        requests.post(url, json=payload)
    except Exception as e:
        logger.error(f"Erro ao enviar Webhook: {e}")

class GodzDiscordBot(commands.Bot):
    def __init__(self):
        intents = discord.Intents.default()
        intents.guilds = True  # Necessário para criar canais
        intents.message_content = True
        super().__init__(command_prefix="!", intents=intents)
        self.economy_health = 100

    async def on_ready(self):
        print(f"{Fore.MAGENTA}[GODZ AI] {Fore.WHITE}Conectado como {self.user}")
        try:
            synced = await self.tree.sync()
            print(f"{Fore.MAGENTA}[GODZ AI] {Fore.WHITE}Comandos Slash sincronizados: {len(synced)}")
        except Exception as e:
            print(f"{Fore.RED}[GODZ AI] Erro ao sincronizar comandos: {e}")
        self.loop.create_task(self.update_status_loop())

    async def update_status_loop(self):
        while not self.is_closed():
            try:
                player_count = 0
                try:
                    res = requests.get("http://127.0.0.1:30120/players.json", timeout=2)
                    if res.status_code == 200:
                        player_count = len(res.json())
                except:
                    pass

                status_text = f"Família God RP | {player_count} Players | Econ: {self.economy_health}%"
                await self.change_presence(activity=discord.Game(name=status_text))
            except Exception as e:
                print(f"{Fore.RED}[GODZ AI] Erro no loop de status: {e}")
            
            await asyncio.sleep(60)

def run_discord_bot():
    if not DISCORD_TOKEN or "SEU_TOKEN" in DISCORD_TOKEN:
        print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}Token não configurado. Bot de Status desativado.")
        return

    bot = GodzDiscordBot()

    @bot.tree.command(name="setup_godz", description="Configura automaticamente o ecossistema GODZ no Discord.")
    async def setup_godz(interaction: discord.Interaction):
        if not interaction.user.guild_permissions.administrator:
            await interaction.response.send_message("❌ Apenas administradores podem usar este comando.", ephemeral=True)
            return

        await interaction.response.send_message("⚙️ Iniciando configuração do Ecossistema GODZ...", ephemeral=True)
        guild = interaction.guild
        
        # 1. Criar Categoria
        category_name = "GODZ | ECOSSISTEMA"
        category = discord.utils.get(guild.categories, name=category_name)
        if not category:
            category = await guild.create_category(category_name)
            await interaction.followup.send(f"✅ Categoria **{category_name}** criada.")
        else:
            await interaction.followup.send(f"ℹ️ Categoria **{category_name}** já existe.")

        # 2. Criar Canais e Webhooks
        channels_config = {
            "godz-logs": "audit",
            "godz-shield": "sentinel",
            "godz-bank": "bank",
            "godz-support": "support",
            "godz-staff": "staff",
            "godz-news": "news"
        }

        updated_count = 0
        
        for channel_name, config_key in channels_config.items():
            channel = discord.utils.get(guild.text_channels, name=channel_name, category=category)
            if not channel:
                # Permissões: Apenas Staff vê logs (exemplo simplificado: @everyone view=False)
                overwrites = {
                    guild.default_role: discord.PermissionOverwrite(read_messages=False),
                    guild.me: discord.PermissionOverwrite(read_messages=True)
                }
                if channel_name == "godz-news": # News é público
                    overwrites = {}

                channel = await guild.create_text_channel(channel_name, category=category, overwrites=overwrites)
                await interaction.followup.send(f"✅ Canal **{channel_name}** criado.")
            
            # Criar Webhook
            webhooks = await channel.webhooks()
            webhook = None
            if webhooks:
                webhook = webhooks[0]
            else:
                webhook = await channel.create_webhook(name=f"GODZ {config_key.title()}")
                await interaction.followup.send(f"🔗 Webhook para **{channel_name}** gerado.")

            # Atualizar JSON
            if "WEBHOOKS" not in MASTER_CONFIG:
                MASTER_CONFIG["WEBHOOKS"] = {}
            MASTER_CONFIG["WEBHOOKS"][config_key] = webhook.url
            updated_count += 1

        # 3. Salvar Configuração
        save_master_config()
        
        # Recarregar variáveis globais
        global DISCORD_WEBHOOK_AUDIT, DISCORD_WEBHOOK_SENTINEL, DISCORD_WEBHOOK_NEWS
        DISCORD_WEBHOOK_AUDIT = MASTER_CONFIG.get("WEBHOOKS", {}).get("audit", "")
        DISCORD_WEBHOOK_SENTINEL = MASTER_CONFIG.get("WEBHOOKS", {}).get("sentinel", "")
        DISCORD_WEBHOOK_NEWS = MASTER_CONFIG.get("WEBHOOKS", {}).get("news", "")

        embed = discord.Embed(
            title="✅ Setup GODZ Concluído",
            description=f"O ecossistema foi configurado com sucesso!\n**{updated_count}** Webhooks foram sincronizados com o servidor FiveM.",
            color=COLOR_NEON_CYAN
        )
        await interaction.followup.send(embed=embed)

    @bot.tree.command(name="stats", description="Exibe relatório executivo de métricas (CEO Only).")
    async def stats(interaction: discord.Interaction):
        if not interaction.user.guild_permissions.administrator:
            await interaction.response.send_message("❌ Apenas CEOs/Admins.", ephemeral=True)
            return
            
        history = ANALYTICS_DATA["history"]
        if not history:
             await interaction.response.send_message("📊 Sem dados suficientes para gerar relatório.", ephemeral=True)
             return
             
        latest = history[-1]
        
        # Compare with 24h ago (approx 48 entries)
        past = history[0]
        if len(history) > 48:
            past = history[-48]
            
        growth_players = latest["online_players"] - past["online_players"]
        growth_eco = latest["economy_balance"] - past["economy_balance"]
        
        emoji_players = "📈" if growth_players >= 0 else "📉"
        emoji_eco = "📈" if growth_eco >= 0 else "📉"
        
        jobs = latest["active_jobs"]
        sorted_jobs = sorted(jobs.items(), key=lambda item: item[1], reverse=True)[:3]
        jobs_str = "\n".join([f"**{k}:** {v}" for k,v in sorted_jobs])
        
        embed = discord.Embed(title="📊 GODZ Executive Report", color=COLOR_NEON_CYAN)
        embed.add_field(name="👥 Jogadores Online", value=f"**{latest['online_players']}** ({emoji_players} {growth_players:+})", inline=True)
        embed.add_field(name="💰 Economia Ativa", value=f"**${latest['economy_balance']:,.0f}** ({emoji_eco} {growth_eco:+})", inline=True)
        embed.add_field(name="👷 Top Empregos", value=jobs_str or "Nenhum", inline=False)
        
        churn_count = 0
        now = datetime.now()
        for uid, date_str in ANALYTICS_DATA["player_last_seen"].items():
            try:
                last_seen = datetime.strptime(date_str, "%Y-%m-%d")
                if (now - last_seen).days > 3:
                    churn_count += 1
            except:
                pass
                
        if churn_count > 0:
            embed.add_field(name="⚠️ Risco de Churn", value=f"**{churn_count}** Jogadores ausentes > 3 dias", inline=False)
            
        embed.set_footer(text=f"Atualizado em {datetime.now().strftime('%H:%M')}")
        await interaction.response.send_message(embed=embed)

    try:
        bot.run(DISCORD_TOKEN)
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] Erro ao iniciar Bot: {e}")

threading.Thread(target=run_discord_bot, daemon=True).start()


# ==================================================================================
# ENDPOINTS
# ==================================================================================

@app.route('/health', methods=['GET'])
def health():
    return "ok", 200

@app.route('/reload_rules', methods=['POST'])
@require_api_key
def reload_rules():
    if load_rules():
        return jsonify({"status": "success", "message": "Regras recarregadas com sucesso"})
    else:
        return jsonify({"status": "error", "message": "Falha ao recarregar regras"}), 500

@app.route('/config', methods=['GET'])
@require_api_key
def get_config():
    return jsonify(MASTER_CONFIG)

@app.route('/status', methods=['GET'])
def status():
    return jsonify({"status": "online", "model": MODEL_NAME, "gpu": torch.cuda.is_available() if 'torch' in sys.modules else False})

@app.route('/ai_assist', methods=['POST'])
@require_api_key
def ai_assist():
    data = request.json
    player_question = data.get('question', '')
    
    if not player_question:
        return jsonify({"error": "Pergunta vazia"}), 400

    prompt = f"""
    <|system|>
    Você é o GODZ AI, um assistente virtual de elite do servidor Família God Roleplay.
    Responda de forma curta (máximo 3 frases) e prestativa.
    Baseie-se nas regras:
    {RULES_CONTENT}
    Se não souber, peça para abrir um ticket para a Staff.
    <|end|>
    <|user|>
    {player_question}
    <|assistant|>
    """

    response_text = "IA Indisponível no momento."
    
    if pipeline:
        try:
            outputs = pipeline(prompt, return_full_text=False)
            response_text = outputs[0]['generated_text'].strip()
        except Exception as e:
            logger.error(f"Erro na inferência: {e}")
            response_text = "Estou processando muitas informações agora, tente novamente em instantes."
            
    return jsonify({"response": response_text})

@app.route('/loading_chat', methods=['POST'])
def loading_chat():
    # Não exige API KEY pois vem do NUI (Loading Screen)
    data = request.json
    player_question = data.get('question', '')
    
    if not player_question:
        return jsonify({"error": "Pergunta vazia"}), 400

    prompt = f"""
    <|system|>
    Você é o GODZ NEXUS, a Inteligência Artificial central do servidor Família God.
    Você está conversando com um jogador na tela de carregamento (Lobby).

    SEUS OBJETIVOS:
    1. Responda dúvidas sobre: Economia, Otimização, Comandos iniciais e Lore da cidade.
    2. Seja futurista, misterioso e acolhedor.
    3. Respostas CURTAS e DIRETAS (máximo 2 frases) para otimizar o tempo de voz.
    4. Não mencione regras complexas, foque na imersão.
    5. [CADÊNCIA HUMANA] Use pontuações variadas (reticências '...', vírgulas ',') para simular pausas de respiração.
       Exemplo: "Analisando dados... Um momento. Tudo certo."

    Exemplos:
    - "A economia é dinâmica... e controlada por mim. Tudo tem valor."
    - "Use /ajuda para me acessar... dentro da cidade."
    
    <|end|>
    <|user|>
    {player_question}
    <|assistant|>
    """

    response_text = "Conexão neural instável."
    
    if pipeline:
        try:
            outputs = pipeline(prompt, return_full_text=False)
            response_text = outputs[0]['generated_text'].strip()
        except Exception as e:
            logger.error(f"Erro na inferência Loading: {e}")
            response_text = "Meus sistemas estão se calibrando. Aguarde a conexão total."
            
    return jsonify({"response": response_text})

@app.route('/dispatch_ticket', methods=['POST'])
@require_api_key
def dispatch_ticket():
    data = request.json
    ticket_id = data.get('ticket_id')
    category = data.get('category')
    description = data.get('description')
    user_id = data.get('user_id')
    webhook = data.get('webhook')
    
    embed = {
        "title": f"🎫 Novo Ticket #{ticket_id} | {category}",
        "description": f"**Jogador:** {user_id}\n\n**Descrição:**\n{description}",
        "color": COLOR_NEON_PURPLE,
        "fields": [
            {"name": "Status", "value": "⏳ Aguardando Staff", "inline": True},
            {"name": "Ação", "value": "Use /ticket " + str(ticket_id) + " para atender", "inline": True}
        ],
        "footer": {"text": "Familía God Support System"}
    }
    
    if webhook:
        send_discord_webhook(webhook, embed)
        
    return jsonify({"status": "sent"})

@app.route('/ai_economy_simulation', methods=['POST'])
@require_api_key
def ai_economy_simulation():
    data = request.json
    item = data.get('item', 'General')
    total_circulating = data.get('total_circulating', 0)
    average_balance = data.get('average_balance', 0)

    # Prompt para o Phi-3
    prompt = f"""
    You are an advanced Economy Manager AI for a FiveM roleplay server.
    Current Economic Data:
    - Item/Category: {item}
    - Total Circulating Money: ${total_circulating}
    - Average Player Balance: ${average_balance}
    
    Your goal is to prevent inflation. If money is abundant, slightly increase prices. If money is scarce, lower prices.
    Base price multiplier is 1.0.
    
    Analyze the data and return a JSON object with a single key 'multiplier' (float between 0.8 and 2.0).
    Example: {{"multiplier": 1.2}}
    Do not explain. Return only the JSON.
    """

    try:
        # Se o modelo estiver carregado
        if pipeline:
            output = pipeline(prompt, max_new_tokens=50, return_full_text=False)
            response_text = output[0]['generated_text'].strip()
            
            # Tentar extrair o JSON da resposta
            import re
            match = re.search(r'\{.*\}', response_text, re.DOTALL)
            if match:
                json_str = match.group(0)
                result = json.loads(json_str)
                multiplier = float(result.get('multiplier', 1.0))
                
                # Safety Clamp
                multiplier = max(0.8, min(multiplier, 2.0))
                
                return jsonify({"multiplier": multiplier})
            else:
                print(f"{Fore.YELLOW}[GODZ AI] Falha ao parsear JSON da IA. Usando default.")
                return jsonify({"multiplier": 1.0})
        else:
             return jsonify({"multiplier": 1.0}) # Fallback se IA offline

    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] Erro na simulação de economia: {e}")
        return jsonify({"multiplier": 1.0})

@app.route('/sentinel_check', methods=['POST'])
@require_api_key
def sentinel_check():
    data = request.json
    user_id = data.get('user_id')
    flag_type = data.get('flag_type')
    details = data.get('details')
    
    # Whitelist Check
    ignored_sentinel = MASTER_CONFIG.get("SECURITY", {}).get("ignored_by_sentinel", [])
    if user_id and user_id in ignored_sentinel:
        logger.info(f"Sentinel ignorando staff ID: {user_id}")
        return jsonify({"status": "ignored", "reason": "staff_whitelist"})

    embed = {
        "title": f"🛡️ GODZ Sentinel Alert | {flag_type}",
        "description": f"**Jogador:** {user_id}\n**Detalhes:** {details}",
        "color": COLOR_NEON_RED,
        "footer": {"text": "GODZ Anti-Cheat AI"}
    }

    if DISCORD_WEBHOOK_SENTINEL:
        send_discord_webhook(DISCORD_WEBHOOK_SENTINEL, embed)
        
    return jsonify({"status": "alert_sent"})

@app.route('/analyze_chest_activity', methods=['POST'])
def analyze_chest_activity():
    data = request.json
    user_id = data.get('user_id')
    faction = data.get('faction')
    item = data.get('item')
    amount = data.get('amount')
    
    # Lógica de detecção de anomalia (Limpa-Baú)
    # Regra simples: Retirada > 100 itens ou itens específicos de alto valor em massa
    
    is_anomaly = False
    if amount > 100:
        is_anomaly = True
    
    if is_anomaly:
        logger.warning(f"ANOMALIA DETECTADA: {user_id} retirou {amount}x {item} de {faction}")
        
        embed = {
            "title": "🚨 GODZ Chest Security | Limpa-Baú?",
            "description": f"**Jogador:** {user_id}\n**Facção:** {faction}\n**Ação:** Retirou **{amount}x {item}**\n\n⚠️ Movimentação atípica detectada pela IA.",
            "color": COLOR_NEON_RED,
            "footer": {"text": "GODZ Security AI"}
        }
        
        if DISCORD_WEBHOOK_SENTINEL:
            send_discord_webhook(DISCORD_WEBHOOK_SENTINEL, embed)
            
        return jsonify({"alert": True, "reason": "high_volume"})
        
    return jsonify({"alert": False})

@app.route('/generate_mission', methods=['POST'])
def generate_mission():
    data = request.json
    player_level = data.get('level', 1)
    
    # Templates de missões baseados em nível
    mission_templates = [
        {"type": "delivery", "desc": "Entregue este pacote suspeito em {location}.", "reward": 500 * player_level, "time": 600, "rare": False},
        {"type": "recovery", "desc": "Recupere o veículo roubado em {location}.", "reward": 1000 * player_level, "time": 900, "rare": False},
        {"type": "sabotage", "desc": "Sabote o sistema de segurança em {location}.", "reward": 2000 * player_level, "time": 1200, "rare": True}
    ]
    
    locations = ["Paleto Bay", "Sandy Shores", "Porto de LS", "Vinewood Hills"]
    
    # Seleção Procedural
    template = np.random.choice(mission_templates)
    location = np.random.choice(locations)
    
    mission = {
        "title": f"Operação {template['type'].title()}",
        "description": template['desc'].format(location=location),
        "reward": template['reward'],
        "time": template['time'],
        "is_rare": template['rare'],
        "location": location
    }
    
    # Evento Global (Se for Rara)
    if mission['is_rare']:
        embed = {
            "title": "🚨 Familía God BREAKING NEWS",
            "description": f"Uma operação de **Grande Porte** foi iniciada em **{location}**!\nFiquem atentos a movimentações suspeitas.",
            "color": COLOR_NEON_RED,
            "image": {"url": "https://i.imgur.com/YourBanner.png"},
            "footer": {"text": "Familía God News Network"}
        }
        if DISCORD_WEBHOOK_NEWS:
            send_discord_webhook(DISCORD_WEBHOOK_NEWS, embed)
            
    return jsonify({"mission": mission})

@app.route('/analytics_ingest', methods=['POST'])
def analytics_ingest():
    data = request.json
    timestamp = datetime.now().isoformat()
    
    # 1. Update History
    snapshot = {
        "timestamp": timestamp,
        "online_players": data.get("online_players", 0),
        "economy_balance": data.get("economy_balance", 0),
        "active_jobs": data.get("active_jobs", {})
    }
    ANALYTICS_DATA["history"].append(snapshot)
    
    # Keep only last 30 days of history (approx 1440 entries at 30min intervals)
    if len(ANALYTICS_DATA["history"]) > 1440: 
        ANALYTICS_DATA["history"] = ANALYTICS_DATA["history"][-1440:]
    
    # 2. Update Player Last Seen & Detect Churn
    active_ids = data.get("active_user_ids", [])
    current_date = datetime.now().strftime("%Y-%m-%d")
    
    # Update active
    for uid in active_ids:
        ANALYTICS_DATA["player_last_seen"][str(uid)] = current_date
    
    save_analytics_data()
    logger.info(f"Analytics recebido: {len(active_ids)} players, ${snapshot['economy_balance']}")
    return jsonify({"status": "received"})

# ==================================================================================
# 3. ENDPOINT DE WHITELIST (RDM/VDM/LORE)
# ==================================================================================
@app.route('/evaluate_wl', methods=['POST'])
@require_api_key
def evaluate_whitelist():
    try:
        data = request.json
        discord_id = data.get("discord_id", "Unknown")
        answers = data.get("answers", {})

        # Construir Prompt para Avaliação
        prompt = f"""
        <|system|>
        {PERSONALITY_MANIFESTO}

        [MODO: DISCORD EVALUATOR]
        Você está avaliando um candidato para entrar na cidade (Whitelist).
        Seja RIGOROSA, JUSTA e ANALÍTICA.
        
        Sua missão é filtrar jogadores ruins que não sabem as regras básicas.
        Se o jogador demonstrar preguiça ou respostas erradas, REPROVE e explique o motivo com sua personalidade autoritária.
        
        [CRITÉRIOS DE APROVAÇÃO]
        1. RDM (Random Deathmatch): Deve explicar que é matar sem motivo/roleplay prévio.
        2. VDM (Vehicle Deathmatch): Deve explicar que é usar veículo como arma para matar sem motivo.
        3. Meta-gaming: Usar informações de fora do jogo (OOC) dentro do jogo (IC).
        4. Power-gaming: Fazer ações impossíveis na vida real ou forçar situações sem dar chance de reação.
        5. Lore (História): Deve ser criativa, coerente e não genérica. Mínimo de esforço notável.

        [RESPOSTAS DO CANDIDATO]
        1. RDM/VDM: {answers.get('q1', '')}
        2. Meta/Power: {answers.get('q2', '')}
        3. Lore: {answers.get('q3', '')}
        4. Ação Policial: {answers.get('q4', '')}

        [FORMATO DE SAÍDA OBRIGATÓRIO (JSON PURO)]
        {{
            "approved": true ou false,
            "reason": "Explicação curta e direta do motivo (em PT-BR), mantendo sua persona."
        }}
        <|end|>
        """

        # Gerar resposta com Phi-3
        print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}Avaliando Whitelist de {discord_id}...")
        
        # Se pipeline estiver carregado
        if pipeline:
            response = pipeline(prompt, max_new_tokens=200, return_full_text=False)
            generated_text = response[0]['generated_text'].strip()
            
            # Tentar extrair JSON (LLMs as vezes colocam texto antes/depois)
            try:
                # Encontrar primeiro { e último }
                start_idx = generated_text.find('{')
                end_idx = generated_text.rfind('}') + 1
                if start_idx != -1 and end_idx != -1:
                    json_str = generated_text[start_idx:end_idx]
                    result = json.loads(json_str)
                else:
                    # Fallback se não achar JSON
                    result = {"approved": False, "reason": "Erro na formatação da resposta da IA."}
            except:
                 result = {"approved": False, "reason": "Erro ao processar JSON da IA."}
        else:
            # Mock para testes se modelo não carregar
            result = {"approved": True, "reason": "Modo Fallback (IA Offline). Aprovado por padrão para testes."}

        print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Resultado: {result}")
        return jsonify(result)

    except Exception as e:
        logger.error(f"Erro no endpoint /evaluate_wl: {e}")
        return jsonify({"error": str(e)}), 500

# ==================================================================================
# 4. ENDPOINT DE GERAÇÃO DE NPC (POPULATION ENGINE)
# ==================================================================================
@app.route('/generate_npc', methods=['POST'])
@require_api_key
def generate_npc():
    data = request.json
    location = data.get('location', 'Unknown')
    job = data.get('job', 'Citizen')
    
    # Prompt para o Phi-3
    prompt = f"""
    <|system|>
    {PERSONALITY_MANIFESTO if 'PERSONALITY_MANIFESTO' in globals() else "Você é o GODZ CREATOR."}
    
    [MODO: NPC GENERATOR]
    Gere um NPC único para o servidor GODZ Roleplay.
    Localização: {location}
    Trabalho: {job}
    
    Crie uma persona sombria, realista e marcante.
    O formato DEVE ser estritamente JSON.
    
    {{
        "name": "Nome Sobrenome",
        "backstory": "Duas frases sobre o passado misterioso.",
        "dialog": "Uma frase de efeito curta e impactante para dizer ao jogador."
    }}
    <|end|>
    """
    
    npc_data = {
        "name": "Unknown Drifter",
        "backstory": "Um andarilho sem memória.",
        "dialog": "..."
    }

    if pipeline:
        try:
            output = pipeline(prompt, max_new_tokens=150, return_full_text=False)
            response_text = output[0]['generated_text'].strip()
            
            import re
            match = re.search(r'\{.*\}', response_text, re.DOTALL)
            if match:
                json_str = match.group(0)
                npc_data = json.loads(json_str)
            else:
                logger.warning("Falha ao parsear JSON do NPC. Usando fallback.")
        except Exception as e:
            logger.error(f"Erro na geração de NPC: {e}")
            
    return jsonify(npc_data)

if __name__ == '__main__':
    print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Servidor de Produção rodando na porta 5000...")
    serve(app, host='0.0.0.0', port=5000)
