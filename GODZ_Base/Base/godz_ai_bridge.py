import sys
import os
import json
import logging
import time
import threading
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
            suspicious_alerts.append({
                "transaction": tx,
                "risk_score": risk_score,
                "reasons": reasons
            })
            
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
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500
        
    return jsonify({
        "user_id": data.get('user_id'),
        "max_speed_kmh": round(max_speed_kmh, 2),
        "flags": flags,
        "verdict": "BAN" if flags else "SAFE"
    })

if __name__ == '__main__':
    print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}Servidor Bridge rodando na porta 5000...")
    app.run(host='0.0.0.0', port=5000)
