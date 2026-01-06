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
DISCORD_GUILD_ID = 0 # ID do Servidor para contagem (Opcional)

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
        "username": "GODZ AI Sentinel",
        "avatar_url": "https://i.imgur.com/YourLogoHere.png" # Placeholder
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
                # Tentar pegar contagem de players localmente
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
            
            await asyncio.sleep(60) # Atualiza a cada 60s

def run_discord_bot():
    if "SEU_TOKEN" in DISCORD_TOKEN:
        print(f"{Fore.YELLOW}[GODZ BOT] {Fore.WHITE}Token não configurado. Bot de Status desativado.")
        return

    bot = GodzDiscordBot()
    try:
        bot.run(DISCORD_TOKEN)
    except Exception as e:
        print(f"{Fore.RED}[GODZ BOT] Erro ao iniciar Bot: {e}")

# Iniciar Bot em Thread Separada
threading.Thread(target=run_discord_bot, daemon=True).start()


# ==================================================================================
# ENDPOINTS
# ==================================================================================

@app.route('/status', methods=['GET'])
def status():
    return jsonify({"status": "online", "model": MODEL_NAME, "gpu": torch.cuda.is_available() if 'torch' in sys.modules else False})

# ----------------------------------------------------------------------------------
# 2. ENDPOINT DE SUPORTE (/ai_assist)
# ----------------------------------------------------------------------------------
@app.route('/ai_assist', methods=['POST'])
def ai_assist():
    data = request.json
    player_question = data.get('question', '')
    
    if not player_question:
        return jsonify({"error": "Pergunta vazia"}), 400

    prompt = f"""
    <|system|>
    Você é o GODZ AI, um assistente virtual de elite do servidor GODZ Roleplay.
    Sua personalidade é formal, técnica e prestativa.
    Responda à pergunta do usuário baseando-se estritamente nas regras abaixo:
    
    {RULES_CONTENT}
    
    Se a resposta não estiver nas regras, oriente a procurar o Discord.
    <|end|>
    <|user|>
    {player_question}
    <|assistant|>
    """

    response_text = ""
    
    if pipeline:
        try:
            outputs = pipeline(prompt, return_full_text=False)
            response_text = outputs[0]['generated_text'].strip()
        except Exception as e:
            logger.error(f"Erro na inferência: {e}")
            response_text = "Desculpe, meus circuitos neurais encontraram um erro. Por favor, contate um administrador."
    else:
        # Fallback simples se o modelo não carregou
        response_text = "O sistema de IA ainda está inicializando. Por favor, tente novamente em instantes ou consulte as regras manualmente."

    return jsonify({"response": response_text})

# ----------------------------------------------------------------------------------
# 3. ENDPOINT DE AUDITORIA (/ai_audit)
# ----------------------------------------------------------------------------------
@app.route('/ai_audit', methods=['POST'])
def ai_audit():
    """
    Analisa transações financeiras.
    Espera JSON: {"transactions": [{"sender": int, "receiver": int, "amount": float, "type": str}]}
    """
    data = request.json
    transactions = data.get('transactions', [])
    suspicious_alerts = []
    
    for tx in transactions:
        risk_score = 0
        reasons = []
        
        amount = float(tx.get('amount', 0))
        
        # Heurísticas de Risco
        if amount > 1000000: # Transferência acima de 1M
            risk_score += 50
            reasons.append("Valor extremamente alto")
        elif amount > 500000:
            risk_score += 20
            reasons.append("Valor alto")
            
        if tx.get('type') == 'transfer' and amount > 100000:
            risk_score += 10 # Transferência direta alta é suspeita
            
        # Normalização do Score (0-100)
        risk_score = min(risk_score, 100)
        
        if risk_score > 30: # Limite de alerta
            alert = {
                "transaction": tx,
                "risk_score": risk_score,
                "reasons": reasons
            }
            suspicious_alerts.append(alert)

            # Disparar Webhook
            embed = {
                "title": "🚨 Alerta de Auditoria Financeira",
                "description": f"Transação suspeita detectada com Score de Risco **{risk_score}/100**",
                "color": COLOR_NEON_RED,
                "fields": [
                    {"name": "Remetente", "value": str(tx.get('sender')), "inline": True},
                    {"name": "Destinatário", "value": str(tx.get('receiver')), "inline": True},
                    {"name": "Valor", "value": f"${amount:,.2f}", "inline": True},
                    {"name": "Motivos", "value": ", ".join(reasons), "inline": False}
                ],
                "footer": {"text": "GODZ AI Audit System"}
            }
            send_discord_webhook(DISCORD_WEBHOOK_AUDIT, embed)
            
    return jsonify({"alerts": suspicious_alerts, "total_scanned": len(transactions)})

# ----------------------------------------------------------------------------------
# 4. ENDPOINT GUARDIAN (/ai_sentinel)
# ----------------------------------------------------------------------------------
@app.route('/ai_sentinel', methods=['POST'])
def ai_sentinel():
    """
    Analisa vetores de movimento.
    Espera JSON: {"user_id": int, "positions": [[x,y,z,time], [x,y,z,time], ...]}
    """
    data = request.json
    positions = data.get('positions', [])
    
    if len(positions) < 2:
        return jsonify({"status": "insufficient_data"})
    
    max_speed_kmh = 0
    max_dist_tick = 0
    flags = []
    
    # Análise Vetorial Simples
    # positions deve ser ordenado por tempo
    # Converter para numpy array para velocidade
    try:
        coords = np.array([p[:3] for p in positions]) # X, Y, Z
        times = np.array([p[3] for p in positions])   # Timestamps (ms)
        
        # Calcular diferenças
        deltas = np.diff(coords, axis=0)
        dists = np.sqrt((deltas ** 2).sum(axis=1)) # Distância Euclidiana
        time_deltas = np.diff(times) / 1000.0      # Segundos
        
        # Evitar divisão por zero
        time_deltas[time_deltas == 0] = 0.001
        
        speeds = dists / time_deltas # m/s
        speeds_kmh = speeds * 3.6
        
        max_speed_kmh = np.max(speeds_kmh)
        max_dist_tick = np.max(dists)
        
        # Regras de Detecção
        if max_speed_kmh > 400: # 400 km/h (considerando supercarros, acima disso é suspeito)
            flags.append("SPEEDHACK_DETECTED")
            
        if max_dist_tick > 500 and np.max(time_deltas) < 1.0: # Teleporte: >500m em <1s
            flags.append("TELEPORT_DETECTED")
            
        if flags:
            # Disparar Webhook
            embed = {
                "title": "🛡️ GODZ Sentinel Alert",
                "description": f"Atividade anormal detectada para o User ID **{data.get('user_id')}**",
                "color": COLOR_NEON_RED,
                "fields": [
                    {"name": "Velocidade Máx", "value": f"{max_speed_kmh:.2f} km/h", "inline": True},
                    {"name": "Distância Instantânea", "value": f"{max_dist_tick:.2f} m", "inline": True},
                    {"name": "Flags", "value": ", ".join(flags), "inline": False}
                ],
                "footer": {"text": "GODZ AI Sentinel System"}
            }
            send_discord_webhook(DISCORD_WEBHOOK_SENTINEL, embed)

    except Exception as e:
        return jsonify({"error": str(e)}), 500
        
    return jsonify({
        "user_id": data.get('user_id'),
        "max_speed_kmh": round(max_speed_kmh, 2),
        "flags": flags,
        "verdict": "BAN" if flags else "SAFE"
    })

# ----------------------------------------------------------------------------------
# 5. ENDPOINT ECONOMY SIMULATION (/ai_economy_simulation)
# ----------------------------------------------------------------------------------
@app.route('/ai_economy_simulation', methods=['POST'])
def ai_economy_simulation():
    """
    Simula inflação e poder de compra.
    Espera JSON: {"salaries": {}, "drugs": {}, "food": {}, "vehicles": {}}
    """
    data = request.json
    salaries = data.get('salaries', {})
    drugs = data.get('drugs', {})
    vehicles = data.get('vehicles', {})
    
    # Cálculos
    lixeiro_salary = salaries.get('lixeiro', 1)
    car_popular_price = vehicles.get('popular_avg', 1)
    
    hours_to_buy_car = car_popular_price / lixeiro_salary
    
    cocaine_price = drugs.get('cocaine_sell', 0)
    # Suposição: Facção vende 50 unidades por hora por membro
    faction_profit_per_member_hr = cocaine_price * 50 
    
    # Relatório
    report_lines = [
        f"**🚗 Poder de Compra (Lixeiro)**",
        f"- Salário Base: ${lixeiro_salary}",
        f"- Carro Popular: ${car_popular_price}",
        f"- Tempo para conquista: **{hours_to_buy_car:.1f} horas** de trabalho",
        "",
        f"**🏴 Lucro Estimado (Crime)**",
        f"- Preço Cocaína: ${cocaine_price}",
        f"- Lucro/Hora (Estimado): **${faction_profit_per_member_hr:,.2f}** (50 vendas)",
        "",
        f"**⚖️ Veredito IA**"
    ]
    
    if hours_to_buy_car > 50:
        report_lines.append("⚠️ **Economia Muito Difícil:** Iniciantes podem desistir.")
    elif hours_to_buy_car < 10:
        report_lines.append("⚠️ **Economia Muito Fácil:** Risco de inflação rápida.")
    else:
        report_lines.append("✅ **Economia Equilibrada:** Progressão saudável.")

    embed = {
        "title": "💰 GODZ Economy Report",
        "description": "\n".join(report_lines),
        "color": COLOR_NEON_GREEN,
        "footer": {"text": "GODZ AI Economy Simulation"}
    }
    
    send_discord_webhook(DISCORD_WEBHOOK_AUDIT, embed)
    
    return jsonify({"status": "success", "report": report_lines})

if __name__ == '__main__':
    print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Servidor Bridge rodando na porta 5000...")
    app.run(host='0.0.0.0', port=5000)
