import sys
import os
import json
import logging
import time
import threading
import requests
import asyncio
import discord
from discord.ext import commands
from flask import Flask, request, jsonify
import numpy as np
from datetime import datetime, timedelta

# Configuração de Logs e Cores
from colorama import init, Fore, Style
init(autoreset=True)

app = Flask(__name__)

# Configuração do Logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger()

print(f"{Fore.CYAN}[FAMILÍA GOD AI] {Fore.WHITE}Inicializando Sistemas Neurais...")

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
        print(f"{Fore.GREEN}[FAMILÍA GOD CONFIG] {Fore.WHITE}Master Config carregada.")
    except json.JSONDecodeError as e:
        print(f"{Fore.RED}[FAMILÍA GOD CONFIG] {Fore.WHITE}ERRO CRÍTICO DE SINTAXE NO JSON!")
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
        print(f"{Fore.RED}[FAMILÍA GOD CONFIG] {Fore.WHITE}Erro genérico ao carregar Config: {e}")
        MASTER_CONFIG = {"SERVER_INFO": {}, "WEBHOOKS": {}, "PERMISSIONS": {}, "SECURITY": {}, "ECONOMY": {}}

def save_master_config():
    try:
        with open(MASTER_CONFIG_PATH, "w", encoding="utf-8") as f:
            json.dump(MASTER_CONFIG, f, indent=4)
        print(f"{Fore.GREEN}[FAMILÍA GOD CONFIG] {Fore.WHITE}Master Config salva com sucesso.")
    except Exception as e:
        print(f"{Fore.RED}[FAMILÍA GOD CONFIG] {Fore.WHITE}Erro ao salvar Master Config: {e}")

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
            print(f"{Fore.GREEN}[FAMILÍA GOD ANALYTICS] {Fore.WHITE}Dados históricos carregados.")
    except Exception as e:
        print(f"{Fore.RED}[FAMILÍA GOD ANALYTICS] {Fore.WHITE}Erro ao carregar dados: {e}")

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
        print(f"{Fore.YELLOW}[FAMILÍA GOD AI] {Fore.WHITE}Verificando aceleradores de hardware...")
        import torch
        from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline as hf_pipeline

        device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"{Fore.GREEN}[FAMILÍA GOD AI] {Fore.WHITE}Hardware detectado: {Fore.MAGENTA}{device.upper()}")

        print(f"{Fore.YELLOW}[FAMILÍA GOD AI] {Fore.WHITE}Carregando modelo {MODEL_NAME}... (Isso pode demorar na primeira vez)")
        
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
        
        print(f"{Fore.GREEN}[FAMILÍA GOD AI] {Fore.WHITE}Modelo carregado com SUCESSO!")
    except Exception as e:
        print(f"{Fore.RED}[FAMILÍA GOD AI] {Fore.WHITE}Erro ao carregar modelo IA: {e}")
        print(f"{Fore.RED}[FAMILÍA GOD AI] {Fore.WHITE}O sistema funcionará em modo 'Fallback' (Regras estáticas).")

# Iniciar carregamento em thread separada para não travar o boot
threading.Thread(target=load_model).start()

# ==================================================================================
# 2. CARREGAMENTO DE REGRAS (RAG LITE)
# ==================================================================================
RULES_CONTENT = ""
try:
    with open("REGRAS.txt", "r", encoding="utf-8") as f:
        RULES_CONTENT = f.read()
    print(f"{Fore.GREEN}[FAMILÍA GOD AI] {Fore.WHITE}Regras carregadas na memória.")
except Exception as e:
    print(f"{Fore.RED}[FAMILÍA GOD AI] {Fore.WHITE}REGRAS.txt não encontrado. Criando padrão...")
    RULES_CONTENT = "Respeite as regras do servidor Família God."

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
        print(f"{Fore.MAGENTA}[FAMILÍA GOD BOT] {Fore.WHITE}Conectado como {self.user}")
        try:
            synced = await self.tree.sync()
            print(f"{Fore.MAGENTA}[FAMILÍA GOD BOT] {Fore.WHITE}Comandos Slash sincronizados: {len(synced)}")
        except Exception as e:
            print(f"{Fore.RED}[FAMILÍA GOD BOT] Erro ao sincronizar comandos: {e}")
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
                print(f"{Fore.RED}[FAMILÍA GOD BOT] Erro no loop de status: {e}")
            
            await asyncio.sleep(60)

def run_discord_bot():
    if not DISCORD_TOKEN or "SEU_TOKEN" in DISCORD_TOKEN:
        print(f"{Fore.YELLOW}[FAMILÍA GOD BOT] {Fore.WHITE}Token não configurado. Bot de Status desativado.")
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
        print(f"{Fore.RED}[FAMILÍA GOD BOT] Erro ao iniciar Bot: {e}")

threading.Thread(target=run_discord_bot, daemon=True).start()


# ==================================================================================
# ENDPOINTS
# ==================================================================================

@app.route('/config', methods=['GET'])
def get_config():
    return jsonify(MASTER_CONFIG)

@app.route('/status', methods=['GET'])
def status():
    return jsonify({"status": "online", "model": MODEL_NAME, "gpu": torch.cuda.is_available() if 'torch' in sys.modules else False})

@app.route('/ai_assist', methods=['POST'])
def ai_assist():
    data = request.json
    player_question = data.get('question', '')
    
    if not player_question:
        return jsonify({"error": "Pergunta vazia"}), 400

    prompt = f"""
    <|system|>
    Você é o FAMILÍA GOD AI, um assistente virtual de elite do servidor Família God Roleplay.
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
            response_text = "Erro ao processar sua dúvida."
            
    return jsonify({"response": response_text})

@app.route('/dispatch_ticket', methods=['POST'])
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
        "footer": {"text": "GODZ Support System"}
    }
    
    if webhook:
        send_discord_webhook(webhook, embed)
        
    return jsonify({"status": "sent"})

@app.route('/ai_economy_simulation', methods=['POST'])
def ai_economy_simulation():
    data = request.json
    
    # Whitelist check for Auditor
    user_id = data.get('user_id')
    ignored_auditor = MASTER_CONFIG.get("SECURITY", {}).get("ignored_by_auditor", [])
    if user_id and user_id in ignored_auditor:
        logger.info(f"Auditor ignorando staff ID: {user_id}")
        return jsonify({"status": "ignored", "reason": "staff_whitelist"})

    salaries = data.get('salaries', {})
    drugs = data.get('drugs', {})
    vehicles = data.get('vehicles', {})
    
    lixeiro_salary = salaries.get('lixeiro', 1) or 1
    car_popular_price = vehicles.get('popular_avg', 1) or 1
    
    hours_to_buy_car = car_popular_price / lixeiro_salary
    
    cocaine_price = drugs.get('cocaine_sell', 0) or 0
    faction_profit = cocaine_price * 50
    
    report_lines = [
        f"**🚗 Poder de Compra**",
        f"- Tempo para Carro Popular: **{hours_to_buy_car:.1f} horas**",
        "",
        f"**🏴 Crime**",
        f"- Lucro/Hora Facção: **${faction_profit:,.2f}**",
        "",
        f"**⚖️ Veredito IA**"
    ]
    
    if hours_to_buy_car > 50:
        report_lines.append("⚠️ **Muito Difícil**")
    elif hours_to_buy_car < 10:
        report_lines.append("⚠️ **Muito Fácil**")
    else:
        report_lines.append("✅ **Equilibrado**")

    embed = {
        "title": "💰 GODZ Economy Report",
        "description": "\n".join(report_lines),
        "color": COLOR_NEON_GREEN,
        "footer": {"text": "GODZ AI Economy Simulation"}
    }
    
    if DISCORD_WEBHOOK_AUDIT:
        send_discord_webhook(DISCORD_WEBHOOK_AUDIT, embed)
    
    return jsonify({"status": "success", "report": report_lines})

@app.route('/sentinel_check', methods=['POST'])
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
            "title": "🚨 GODZ BREAKING NEWS",
            "description": f"Uma operação de **Grande Porte** foi iniciada em **{location}**!\nFiquem atentos a movimentações suspeitas.",
            "color": COLOR_NEON_RED,
            "image": {"url": "https://i.imgur.com/YourBanner.png"},
            "footer": {"text": "GODZ News Network"}
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

if __name__ == '__main__':
    print(f"{Fore.CYAN}[FAMILÍA GOD AI] {Fore.WHITE}Servidor rodando na porta 5000...")
    app.run(host='0.0.0.0', port=5000)
