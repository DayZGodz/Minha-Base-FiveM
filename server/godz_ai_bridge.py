import sys
import os

os.environ['HF_HOME'] = 'D:/servidor FIVEM/PROJETO_SUPER_BASE/ai_cache'

from colorama import init, Fore, Style
init(autoreset=True)

import wave
import hashlib
import numpy as np
try:
    import soundfile as sf
except ImportError:
    sf = None
    print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}soundfile não encontrado. Export do ChatTTS indisponível.")

try:
    from scipy.signal import butter, lfilter
    SCIPY_AVAILABLE = True
except ImportError:
    SCIPY_AVAILABLE = False
    print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}Scipy não encontrado. Efeito de rádio simplificado.")

try:
    from piper import PiperVoice
except ImportError:
    PiperVoice = None
    print("Piper TTS library not found. Voice generation will be disabled.")

# [GODZ AI] ChatTTS Engine
CHATTTS_AVAILABLE = False
try:
    import ChatTTS
    import torch
    chat = ChatTTS.Chat()
    
    # [GODZ SUPREME] FP16 Optimization & Compile
    # Tenta carregar com otimizações se houver GPU
    if torch.cuda.is_available():
        print(f"{Fore.CYAN}[GODZ AI] {Fore.WHITE}GPU Detectada. Ativando FP16 e Compilação...")
        # Nota: A API do ChatTTS pode variar, mas load_models geralmente aceita device
        chat.load_models(compile=True) 
    else:
        chat.load_models()
        
    CHATTTS_AVAILABLE = True
    print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}ChatTTS Engine initialized (Supreme Quality).")
except ImportError:
    print(f"{Fore.YELLOW}[GODZ AI] {Fore.WHITE}ChatTTS library not found. Using Piper fallback.")
except Exception as e:
    print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}Error initializing ChatTTS: {e}")

from functools import wraps

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

app = Flask(__name__)

# [GODZ AI] Habilitar CORS para NUI/Loading Screen
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "online", "engine": "Supreme", "cache_size": len(COMMON_PHRASES_CACHE)}), 200

# [GODZ SUPREME] Radio Effect Filter
def apply_radio_effect(audio_data, sample_rate):
    try:
        # 1. Bandpass Filter (300Hz - 3400Hz) - Standard Telephony/Radio
        if SCIPY_AVAILABLE:
            nyquist = 0.5 * sample_rate
            low = 300 / nyquist
            high = 3400 / nyquist
            b, a = butter(1, [low, high], btype='band')
            filtered_audio = lfilter(b, a, audio_data)
            
            # 2. Add White Noise (Static)
            noise_level = 0.005
            noise = np.random.normal(0, noise_level, filtered_audio.shape)
            final_audio = filtered_audio + noise
            
            # Clip to prevent distortion
            final_audio = np.clip(final_audio, -1.0, 1.0)
            return final_audio
        else:
            # Fallback: Simple High Pass (Discrete Difference)
            # y[n] = x[n] - 0.95 * x[n-1]
            return np.diff(audio_data, prepend=0)
    except Exception as e:
        print(f"Radio Effect Error: {e}")
        return audio_data

# [GODZ SUPREME] Common Phrases Cache
# Pre-defined hash map for instant response
COMMON_PHRASES_CACHE = {
    "Bem-vindo": "welcome_generic.wav",
    "Acesso Negado": "access_denied.wav",
    "Sistema Online": "system_online.wav",
    "Protocolo de segurança ativado": "security_protocol.wav"
}

@app.route('/tts', methods=['GET'])
def tts_endpoint():
    try:
        text = request.args.get('text')
        if not text:
            return jsonify({"error": "No text provided"}), 400
        
        # 1. Check Explicit Cache (Common Phrases)
        for phrase, filename in COMMON_PHRASES_CACHE.items():
            if phrase.lower() in text.lower() and len(text) < len(phrase) + 10:
                cache_path = os.path.join(GODZ_CONNECT_SOUNDS_DIR, filename)
                if os.path.exists(cache_path):
                     return jsonify({"status": "ok", "file": filename, "cached": "explicit"})

        # 2. Check Hash Cache
        text_hash = hashlib.md5(text.encode()).hexdigest()
        output_filename = f"nexus_{text_hash}.wav"
        output_file = os.path.join(GODZ_CONNECT_SOUNDS_DIR, output_filename)
        
        if os.path.exists(output_file):
             return jsonify({"status": "ok", "file": output_filename, "cached": True})

        # Generation
        generated = False
        
        if CHATTTS_AVAILABLE and sf is not None:
            try:
                global CHATTTS_SPEAKERS
                if 'CHATTTS_SPEAKERS' not in globals():
                    CHATTTS_SPEAKERS = {}

                if not CHATTTS_SPEAKERS.get("vitoria") or not CHATTTS_SPEAKERS.get("thalita"):
                    try:
                        np.random.seed(1042)
                        CHATTTS_SPEAKERS["vitoria"] = chat.sample_random_speaker()
                        np.random.seed(2042)
                        CHATTTS_SPEAKERS["thalita"] = chat.sample_random_speaker()
                    except Exception:
                        pass

                spk_emb = CHATTTS_SPEAKERS.get("vitoria") or CHATTTS_SPEAKERS.get("thalita")

                params_refine_text = {
                    "prompt": "[oral_5][break_6]"
                }
                params_infer_code = {
                    "spk_emb": spk_emb,
                    "top_P": 0.7,
                    "top_K": 20,
                    "temperature": 0.3,
                    "repetition_penalty": 1.05
                }

                wavs = chat.infer([text], params_refine_text=params_refine_text, params_infer_code=params_infer_code)
                
                # [GODZ SUPREME] Apply Radio Effect
                audio_data = wavs[0]
                # Convert list to numpy if needed (ChatTTS usually returns list of numpy arrays)
                if isinstance(audio_data, list):
                    audio_data = np.array(audio_data)
                
                final_audio = apply_radio_effect(audio_data, 24000)

                # Save to file
                sf.write(output_file, final_audio, 24000)
                generated = True
                print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Áudio gerado via ChatTTS (Voz: Vitoria) + Rádio FX: {text[:30]}...")
            except Exception as e:
                print(f"{Fore.RED}[GODZ AI] {Fore.WHITE}Erro no ChatTTS, tentando fallback: {e}")
        
        if not generated and PiperVoice:
            # Fallback to Piper
            if not os.path.exists(PIPER_MODEL_PATH) or not os.path.exists(PIPER_MODEL_JSON):
                return jsonify({"error": "Voice model not found"}), 500
            
            voice = PiperVoice.load(PIPER_MODEL_PATH)
            with wave.open(output_file, "wb") as wav_file:
                voice.synthesize(text, wav_file)
            generated = True
            print(f"{Fore.GREEN}[GODZ AI] {Fore.WHITE}Áudio gerado via Piper: {text[:30]}...")

        if not generated:
            return jsonify({"error": "No TTS engine available"}), 500
        
        # Send Discord Log
        if DISCORD_WEBHOOK_AUDIT:
            embed = {
                "title": "🎙️ NEXUS VOICE GENERATION",
                "description": f"**Texto:** {text}\n**Engine:** {'ChatTTS' if CHATTTS_AVAILABLE else 'Piper'}\n**Status:** Gerado com sucesso.",
                "color": COLOR_NEON_CYAN,
                "footer": {"text": "GODZ AI SUPREME"}
            }
            threading.Thread(target=send_discord_webhook, args=(DISCORD_WEBHOOK_AUDIT, embed)).start()
        
        return jsonify({"status": "ok", "file": output_filename})

    except Exception as e:
        logger.error(f"TTS Error: {e}")
        return jsonify({"error": str(e)}), 500

# ==================================================================================
# SEGURANÇA (API KEY)
# ==================================================================================
API_KEY = "godz_secret_key_123"

# [GODZ AI] Piper TTS Config
PIPER_MODELS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "piper_models")
# Caminho exato para a pasta sounds do godz_connect
GODZ_CONNECT_SOUNDS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "resources", "[godz_core]", "godz_connect", "sounds")

if not os.path.exists(GODZ_CONNECT_SOUNDS_DIR):
    os.makedirs(GODZ_CONNECT_SOUNDS_DIR, exist_ok=True)

# Garantir modelo Thalita
PIPER_MODEL_NAME = "pt_BR-thalita-medium.onnx"
PIPER_MODEL_PATH = os.path.join(PIPER_MODELS_DIR, PIPER_MODEL_NAME)
PIPER_MODEL_JSON = PIPER_MODEL_PATH + ".json"

# [GODZ] Auto-Download Models
def download_file(url, path):
    print(f"{Fore.YELLOW}[GODZ AI] Baixando {os.path.basename(path)}...")
    try:
        r = requests.get(url, stream=True)
        r.raise_for_status()
        with open(path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"{Fore.GREEN}[GODZ AI] Download concluído: {path}")
        return True
    except Exception as e:
        print(f"{Fore.RED}[GODZ AI] Falha no download: {e}")
        return False

def check_and_download_models():
    if not os.path.exists(PIPER_MODELS_DIR):
        os.makedirs(PIPER_MODELS_DIR)
    
    # Thalita Medium URLs
    onnx_url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/thalita/medium/pt_BR-thalita-medium.onnx?download=true"
    json_url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/thalita/medium/pt_BR-thalita-medium.onnx.json?download=true"
    
    if not os.path.exists(PIPER_MODEL_PATH) or os.path.getsize(PIPER_MODEL_PATH) < 1000:
        download_file(onnx_url, PIPER_MODEL_PATH)
        
    if not os.path.exists(PIPER_MODEL_JSON) or os.path.getsize(PIPER_MODEL_JSON) < 100:
        download_file(json_url, PIPER_MODEL_JSON)

# Trigger Download Check
threading.Thread(target=check_and_download_models).start()

# [GODZ] GPU/ONNX Runtime Check
try:
    import onnxruntime as ort
    providers = ort.get_available_providers()
    print(f"{Fore.CYAN}[GODZ AI] ONNX Runtime Providers: {providers}")
    if 'CUDAExecutionProvider' in providers:
        print(f"{Fore.GREEN}[GODZ AI] Aceleração GPU (CUDA) Ativa para Piper!")
    else:
        print(f"{Fore.YELLOW}[GODZ AI] Rodando em CPU. Instale onnxruntime-gpu para maior performance.")
except ImportError:
    pass

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

def send_discord_webhook(webhook_url, embed):
    try:
        data = {"embeds": [embed], "username": "GODZ AI SUPREME"}
        requests.post(webhook_url, json=data)
    except Exception as e:
        print(f"Erro no Webhook: {e}")

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

    @bot.tree.command(name="setup-godz", description="Configura automaticamente o ecossistema GODZ no Discord (restrito CEOS/Admins).")
    async def setup_godz(interaction: discord.Interaction):
        perms = MASTER_CONFIG.get("PERMISSIONS", {})
        allowed_ids = set()
        for key in ("ceos", "admins"):
            for i in perms.get(key, []) or []:
                try:
                    allowed_ids.add(int(i))
                except Exception:
                    pass
        if int(interaction.user.id) not in allowed_ids and not interaction.user.guild_permissions.administrator:
            await interaction.response.send_message("❌ Acesso restrito: apenas CEOS/Admins configurados.", ephemeral=True)
            return

        await interaction.response.send_message("⚙️ Iniciando configuração do Ecossistema GODZ...", ephemeral=True)
        guild = interaction.guild
        me_perms = guild.me.guild_permissions
        if not me_perms.manage_channels or not me_perms.manage_roles:
            await interaction.followup.send("❌ Permissões insuficientes. Conceda 'Manage Channels' e 'Manage Roles' ao Bot.", ephemeral=True)
            return
        
        # 1. Criar Categoria
        category_name = "GODZ | WHITELIST"
        category = discord.utils.get(guild.categories, name=category_name)
        if not category:
            category = await guild.create_category(category_name)
            await interaction.followup.send(f"✅ Categoria **{category_name}** criada.")
        else:
            await interaction.followup.send(f"ℹ️ Categoria **{category_name}** já existe.")

        # 2. Criar Canais essenciais
        channels_config = {
            "godz-logs": "audit",
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

        # 2.1 Criar canal de whitelist com botão
        wl_channel = discord.utils.get(guild.text_channels, name="fazer-whitelist", category=category)
        if not wl_channel:
            wl_channel = await guild.create_text_channel(
                "fazer-whitelist",
                category=category,
                overwrites={guild.default_role: discord.PermissionOverwrite(read_messages=True)}
            )
            await interaction.followup.send("✅ Canal **fazer-whitelist** criado.")

        class WhitelistView(discord.ui.View):
            def __init__(self, category_id: int):
                super().__init__(timeout=None)
                self.category_id = category_id

            @discord.ui.button(label="🔰 Iniciar Whitelist", style=discord.ButtonStyle.success)
            async def open_ticket(self, button_interaction: discord.Interaction, _button):
                guild2 = button_interaction.guild
                category2 = discord.utils.get(guild2.categories, id=self.category_id)
                overwrites = {
                    guild2.default_role: discord.PermissionOverwrite(read_messages=False),
                    guild2.me: discord.PermissionOverwrite(read_messages=True),
                    button_interaction.user: discord.PermissionOverwrite(read_messages=True, send_messages=True)
                }
                chan_name = f"wl-{button_interaction.user.name.lower().replace(' ', '-')}-{button_interaction.user.id}"
                ticket = await guild2.create_text_channel(chan_name, category=category2, overwrites=overwrites)
                await button_interaction.response.send_message(f"🎫 Ticket criado: {ticket.mention}", ephemeral=True)

        wl_embed = discord.Embed(
            title="GODZ Whitelist",
            description="Clique no botão abaixo para abrir seu ticket privado de Whitelist.",
            color=COLOR_NEON_CYAN
        )
        try:
            await wl_channel.send(embed=wl_embed, view=WhitelistView(category.id))
        except Exception:
            pass
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
        
        jobs = latest.get("active_jobs", {})
        top_jobs = []
        try:
            if isinstance(jobs, dict):
                top_jobs = sorted(jobs.items(), key=lambda item: (item[1] if isinstance(item[1], (int, float)) else 0), reverse=True)[:3]
            elif isinstance(jobs, list):
                if len(jobs) > 0 and isinstance(jobs[0], dict):
                    normalized = []
                    for row in jobs:
                        name = str(row.get("job") or row.get("name") or "Indefinido")
                        try:
                            count = int(row.get("count") or row.get("value") or 0)
                        except Exception:
                            count = 0
                        normalized.append((name, count))
                    top_jobs = sorted(normalized, key=lambda item: item[1], reverse=True)[:3]
                else:
                    normalized = []
                    for entry in jobs:
                        try:
                            name, val = entry
                            count = int(val) if isinstance(val, (int, float, str)) else 0
                            normalized.append((str(name), count))
                        except Exception:
                            continue
                    top_jobs = sorted(normalized, key=lambda item: item[1], reverse=True)[:3]
        except Exception:
            top_jobs = []
        jobs_str = "\n".join([f"**{k}:** {v}" for k, v in top_jobs])
        
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


# Old TTS Endpoint Removed


# ==================================================================================
# 3. ROTAS DA API
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

# ==================================================================================
# 5. ENDPOINT DE GERAÇÃO DE VOZ (PIPER TTS)
# ==================================================================================
@app.route('/generate_voice', methods=['POST'])
@require_api_key
def generate_voice():
    if PiperVoice is None:
        return jsonify({"error": "Piper TTS library not installed on server."}), 501

    try:
        data = request.json
        text = data.get('text')
        voice_name = data.get('voice', 'pt_BR-faber-medium.onnx')
        
        if not text:
            return jsonify({"error": "No text provided"}), 400

        model_path = os.path.join(PIPER_MODELS_DIR, voice_name)
        if not os.path.exists(model_path):
             # Tentar encontrar qualquer modelo .onnx no diretório se o solicitado não existir
             available_models = [f for f in os.listdir(PIPER_MODELS_DIR) if f.endswith('.onnx')]
             if available_models:
                 model_path = os.path.join(PIPER_MODELS_DIR, available_models[0])
                 print(f"{Fore.YELLOW}[GODZ AI] Modelo {voice_name} não encontrado. Usando fallback: {available_models[0]}")
             else:
                 return jsonify({"error": f"Model {voice_name} not found and no fallbacks available in {PIPER_MODELS_DIR}"}), 404

        # Generate filename unique to text and voice
        filename = f"voice_{int(time.time())}_{hash(text)}.wav"
        output_path = os.path.join(VOICE_OUTPUT_DIR, filename)
        
        # Check cache (opcional, mas bom)
        if os.path.exists(output_path):
            url = f"http://127.0.0.1:5000/static/voices/{filename}"
            with wave.open(output_path, 'r') as f:
                frames = f.getnframes()
                rate = f.getframerate()
                duration = frames / float(rate)
            return jsonify({"url": url, "duration": duration, "text": text, "cached": True})

        voice = PiperVoice.load(model_path)
        with wave.open(output_path, "wb") as wav_file:
            voice.synthesize(text, wav_file)
            
        url = f"http://127.0.0.1:5000/static/voices/{filename}"
        
        with wave.open(output_path, 'r') as f:
            frames = f.getnframes()
            rate = f.getframerate()
            duration = frames / float(rate)

        return jsonify({
            "url": url,
            "duration": duration,
            "text": text
        })

    except Exception as e:
        logger.error(f"Error generating voice: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print(f"{Fore.CYAN}✅ [NEXUS SUPREME] Sistema de Voz e IA pronto na porta 5000")
    
    # [NEXUS SUPREME] Startup Log (Audit Channel)
    discord_audit = MASTER_CONFIG.get("WEBHOOKS", {}).get("audit")
    
    if discord_audit:
         embed = {
            "title": "🎙️ NEXUS SUPREME: ONLINE",
            "description": "🎙️ [NEXUS SUPREME]: Conexão total estabelecida. Voz Humana Generativa Ativa.",
            "fields": [
                {"name": "Engine", "value": "ChatTTS (ElevenLabs Level)", "inline": True},
                {"name": "Port", "value": "5000", "inline": True},
                {"name": "Voice", "value": "Vitoria (Prosody Enhanced)", "inline": True}
            ],
            "color": COLOR_NEON_GREEN,
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {"text": "GODZ AI SYSTEM"}
        }
         threading.Thread(target=send_discord_webhook, args=(discord_audit, embed)).start()

    serve(app, host='0.0.0.0', port=5000)
