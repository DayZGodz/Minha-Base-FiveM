import discord
from discord.ui import Modal, TextInput, View, Button
from discord.ext import commands
import mysql.connector
import requests
import json
import os
import asyncio

# Configurações (Carregar do JSON ou Hardcoded para simplificar se necessário)
# Idealmente carregar de ../[godz_core]/godz_tuning/GODZ_MASTER_CONFIG.json
# Para garantir robustez, vou ler o JSON.

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "resources", "[godz_core]", "godz_tuning", "GODZ_MASTER_CONFIG.json")

def load_config():
    try:
        with open(CONFIG_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"Erro ao carregar config: {e}")
        return {}

config = load_config()
SERVER_INFO = config.get("SERVER_INFO", {})
DATABASE = config.get("DATABASE", {})
# Extrair token e string de conexão
DISCORD_TOKEN = SERVER_INFO.get("discord_token", "")
DB_CONN_STR = DATABASE.get("connection_string", "mysql://root@localhost/godz_database")
# Parse simples da string de conexão (mysql://user:pass@host/db)
# Vou usar valores padrão caso falhe o parse, ajustável conforme ambiente.
DB_USER = "root"
DB_PASS = ""
DB_HOST = "localhost"
DB_NAME = "godz_database"

# Configuração da API Bridge
AI_BRIDGE_URL = "http://127.0.0.1:5000/evaluate_wl"
API_KEY = "godz_secret_key_123"

# ID do cargo de Cidadão (Deve ser configurado pelo usuário)
CITIZEN_ROLE_ID = 1394591451597246494 # Placeholder (ID da Guilda usado como ex, user deve mudar)

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

bot = commands.Bot(command_prefix="!", intents=intents)

class WhitelistModal(Modal, title="Candidatura Whitelist GODZ"):
    q1 = TextInput(
        label="O que é RDM e VDM?",
        placeholder="Explique com suas palavras...",
        style=discord.TextStyle.paragraph,
        min_length=20,
        max_length=500
    )
    
    q2 = TextInput(
        label="Defina Meta-gaming e Power-gaming",
        placeholder="Dê exemplos...",
        style=discord.TextStyle.paragraph,
        min_length=20,
        max_length=500
    )

    q3 = TextInput(
        label="História do Personagem (Lore)",
        placeholder="Conte a história do seu personagem...",
        style=discord.TextStyle.paragraph,
        min_length=50,
        max_length=1000
    )

    q4 = TextInput(
        label="O que faria numa abordagem policial?",
        placeholder="Descreva sua reação...",
        style=discord.TextStyle.paragraph,
        min_length=20,
        max_length=500
    )

    async def on_submit(self, interaction: discord.Interaction):
        await interaction.response.defer(ephemeral=True)
        
        # Preparar payload para a IA
        payload = {
            "discord_id": str(interaction.user.id),
            "answers": {
                "q1": self.q1.value,
                "q2": self.q2.value,
                "q3": self.q3.value,
                "q4": self.q4.value
            }
        }

        try:
            # Enviar para GODZ AI BRIDGE
            headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
            response = requests.post(AI_BRIDGE_URL, json=payload, headers=headers)
            
            if response.status_code == 200:
                result = response.json()
                approved = result.get("approved", False)
                reason = result.get("reason", "Sem motivo especificado.")
                
                if approved:
                    # 1. Atualizar Banco de Dados
                    if update_whitelist_db(interaction.user.id):
                        # 2. Dar Cargo no Discord
                        try:
                            # Tentar achar o cargo. Se CITIZEN_ROLE_ID for inválido, vai falhar (user deve ajustar)
                            # Vou tentar pegar um cargo chamado "Cidadão" se o ID falhar, ou usar o ID configurado.
                            guild = interaction.guild
                            role = guild.get_role(CITIZEN_ROLE_ID)
                            if not role:
                                role = discord.utils.get(guild.roles, name="Cidadão")
                            
                            if role:
                                await interaction.user.add_roles(role)
                                await interaction.followup.send(f"✅ **APROVADO!** Bem-vindo à GODZ City.\nMotivo: {reason}", ephemeral=True)
                            else:
                                await interaction.followup.send(f"✅ **APROVADO!** (Mas não encontrei o cargo 'Cidadão' para te dar. Avise um ADM).", ephemeral=True)
                        except Exception as e:
                            await interaction.followup.send(f"✅ **APROVADO!** (Erro ao dar cargo: {e})", ephemeral=True)
                    else:
                        await interaction.followup.send("⚠️ **APROVADO PELA IA**, mas não encontrei seu ID no banco de dados. Entre no servidor uma vez para registrar seu ID e tente novamente.", ephemeral=True)
                else:
                    await interaction.followup.send(f"❌ **REPROVADO**\nMotivo: {reason}\n\nVocê pode tentar novamente em 2 horas.", ephemeral=True)
            else:
                await interaction.followup.send("⚠️ Erro de comunicação com a IA Nexus. Tente novamente mais tarde.", ephemeral=True)

        except Exception as e:
            print(f"Erro na integração: {e}")
            await interaction.followup.send("⚠️ Erro interno no bot.", ephemeral=True)

def update_whitelist_db(discord_id):
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME
        )
        cursor = conn.cursor()
        
        # Buscar User ID baseado no Discord ID
        identifier = f"discord:{discord_id}"
        query_find = "SELECT user_id FROM godz_user_ids WHERE identifier = %s"
        cursor.execute(query_find, (identifier,))
        result = cursor.fetchone()
        
        if result:
            user_id = result[0]
            # Atualizar Whitelist
            query_update = "UPDATE godz_users SET whitelisted = 1 WHERE id = %s"
            cursor.execute(query_update, (user_id,))
            conn.commit()
            cursor.close()
            conn.close()
            return True
        else:
            cursor.close()
            conn.close()
            return False
            
    except Exception as e:
        print(f"Erro MySQL: {e}")
        return False

class WhitelistView(View):
    def __init__(self):
        super().__init__(timeout=None) # Botão persistente

    @discord.ui.button(label="🔗 Iniciar Protocolo de Whitelist", style=discord.ButtonStyle.green, custom_id="start_whitelist_btn")
    async def start_whitelist(self, interaction: discord.Interaction, button: Button):
        await interaction.response.send_modal(WhitelistModal())

@bot.event
async def on_ready():
    print(f"🤖 GODZ DISCORD BOT conectado como {bot.user}")
    bot.add_view(WhitelistView())
    
    # --- AUTO-SETUP: IDENTITY SECTOR ---
    try:
        guild_id = SERVER_INFO.get("guild_id")
        guild = bot.get_guild(guild_id) if guild_id else bot.guilds[0]
        
        if not guild:
            print("❌ ERRO: Guilda não encontrada.")
            return

        category_name = "🛡️ GODZ | IDENTIDADE"
        channel_name = "📝-realizar-whitelist"
        
        # 1. Verificar/Criar Categoria
        category = discord.utils.get(guild.categories, name=category_name)
        if not category:
            category = await guild.create_category(category_name)
            print(f"✅ Categoria '{category_name}' criada.")

        # 2. Verificar/Criar Canal
        channel = discord.utils.get(guild.text_channels, name=channel_name, category=category)
        if not channel:
            # Permissões: @everyone vê mas não fala. Bot fala.
            overwrites = {
                guild.default_role: discord.PermissionOverwrite(read_messages=True, send_messages=False),
                guild.me: discord.PermissionOverwrite(read_messages=True, send_messages=True)
            }
            channel = await guild.create_text_channel(channel_name, category=category, overwrites=overwrites)
            print(f"✅ Canal '{channel_name}' criado.")
            
            # Enviar Embed Inicial Automaticamente
            embed = discord.Embed(
                title="SISTEMA DE IDENTIFICAÇÃO NEXUS",
                description="""Saudações, candidato. Eu sou a Nexus. Detectei sua assinatura em nosso radar.

Para ingressar no ecossistema GODZ, você deve passar pelo protocolo de avaliação de Roleplay. Minha inteligência analisará suas respostas em tempo real.

**Requisitos:**
• Microfone funcional.
• Conhecimento das diretrizes de convivência.
• Respostas claras e objetivas.""",
                color=0xB8860B # Dark Gold
            )
            embed.set_footer(text="GODZ ENGINE • Secure Identification Protocol")
            embed.set_thumbnail(url="https://i.imgur.com/YourLogoHere.png") # Placeholder, idealmente configurar no JSON
            
            await channel.send(embed=embed, view=WhitelistView())
            print("✅ Mensagem de Whitelist enviada.")
            
    except Exception as e:
        print(f"❌ Erro no Auto-Setup de Identidade: {e}")

@bot.command()
@commands.has_permissions(administrator=True)
async def setup_whitelist(ctx):
    """(Manual) Envia a mensagem com o botão de Whitelist"""
    embed = discord.Embed(
        title="SISTEMA DE IDENTIFICAÇÃO NEXUS",
        description="""Saudações, candidato. Eu sou a Nexus. Detectei sua assinatura em nosso radar.

Para ingressar no ecossistema GODZ, você deve passar pelo protocolo de avaliação de Roleplay. Minha inteligência analisará suas respostas em tempo real.

**Requisitos:**
• Microfone funcional.
• Conhecimento das diretrizes de convivência.
• Respostas claras e objetivas.""",
        color=0xB8860B # Dark Gold
    )
    embed.set_footer(text="GODZ ENGINE • Secure Identification Protocol")
    await ctx.send(embed=embed, view=WhitelistView())

if __name__ == "__main__":
    if DISCORD_TOKEN and DISCORD_TOKEN != "TOKEN_REMOVIDO_POR_SEGURANCA":
        bot.run(DISCORD_TOKEN)
    else:
        print("❌ ERRO: Discord Token não configurado em GODZ_MASTER_CONFIG.json")
