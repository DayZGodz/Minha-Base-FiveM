import sys
import os
import json
import logging
import time
import threading
import requests
import asyncio
import discord
from flask import Flask, request, jsonify
import numpy as np

# Configuração de Logs e Cores
from colorama import init, Fore, Style
init(autoreset=True)

app = Flask(__name__)

# Configuração do Logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger()

print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Inicializando Sistemas Neurais...")

# ==================================================================================
# CONFIGURAÇÃO DISCORD (Preencha aqui)
# ==================================================================================
DISCORD_TOKEN = "SEU_TOKEN_AQUI"
DISCORD_WEBHOOK_AUDIT = "SEU_WEBHOOK_AUDIT_AQUI"
DISCORD_WEBHOOK_SENTINEL = "SEU_WEBHOOK_SENTINEL_AQUI"
DISCORD_GUILD_ID = 0 

# Cores Neon
COLOR_NEON_PURPLE = 0x9b59b6
COLOR_NEON_RED = 0xff0000
COLOR_NEON_GREEN = 0x00ff00

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
            torch_dtype="auto", 
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
RULES_CONTENT = ""
try:
    with open("REGRAS.txt", "r", encoding="utf-8") as f:
        RULES_CONTENT = f.read()
    print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Regras carregadas na memória.")
except Exception as e:
    print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}REGRAS.txt não encontrado. Criando padrão...")
    RULES_CONTENT = "Respeite as regras do servidor GODZ."

# ==================================================================================
# 3. DISCORD BOT & WEBHOOKS
# ==================================================================================

def send_discord_webhook(url, embed):
    """Envia um Embed para um Webhook do Discord"""
    if "SEU_WEBHOOK" in url or not url:
        return
    
    payload = {
        "embeds": [embed],
        "username": "GODZ Support",
        "avatar_url": "https://i.imgur.com/YourLogoHere.png"
    }
    
    try:
        requests.post(url, json=payload)
    except Exception as e:
        logger.error(f"Erro ao enviar Webhook: {e}")

class GodzDiscordBot(discord.Client):
    def __init__(self):
        intents = discord.Intents.default()
        super().__init__(intents=intents)
        self.economy_health = 100

    async def on_ready(self):
        print(f"{Fore.MAGENTA}[GODZ BOT] {Fore.WHITE}Conectado como {self.user}")
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

                status_text = f"GODZ RP | {player_count} Players | Econ: {self.economy_health}%"
                await self.change_presence(activity=discord.Game(name=status_text))
            except Exception as e:
                print(f"{Fore.RED}[GODZ BOT] Erro no loop de status: {e}")
            
            await asyncio.sleep(60)

def run_discord_bot():
    if "SEU_TOKEN" in DISCORD_TOKEN:
        print(f"{Fore.YELLOW}[GODZ BOT] {Fore.WHITE}Token não configurado. Bot de Status desativado.")
        return

    bot = GodzDiscordBot()
    try:
        bot.run(DISCORD_TOKEN)
    except Exception as e:
        print(f"{Fore.RED}[GODZ BOT] Erro ao iniciar Bot: {e}")

threading.Thread(target=run_discord_bot, daemon=True).start()


# ==================================================================================
# ENDPOINTS
# ==================================================================================

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
    Você é o GODZ AI, um assistente virtual de elite do servidor GODZ Roleplay.
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
    # (Mantendo a lógica existente da economia, simplificada aqui para não apagar se existisse, 
    # mas como estou reescrevendo o arquivo, preciso garantir que o código anterior esteja aqui se for importante.
    # O código anterior foi lido e estava funcional. Vou reincluir a lógica.)
    
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

if __name__ == '__main__':
    print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Servidor rodando na porta 5000...")
    app.run(host='0.0.0.0', port=5000)
