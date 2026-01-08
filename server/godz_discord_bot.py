import discord
from discord.ui import View, Button
from discord.ext import commands
import mysql.connector
import json
import os
import random
import asyncio

# --- CONFIGURAÇÃO ---
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
WHITELIST_CFG = config.get("WHITELIST", {})
CHANNELS_CFG = config.get("CHANNELS", {})

DISCORD_TOKEN = SERVER_INFO.get("discord_token", "")
DB_CONN_STR = DATABASE.get("connection_string", "mysql://root@localhost/godz_database")

# DB PARAMS (Extraídos da string ou hardcoded)
DB_USER = "root"
DB_PASS = ""
DB_HOST = "localhost"
DB_NAME = "godz_database"

ACCESS_CODE = WHITELIST_CFG.get("access_code", "GODZ2026")
CITIZEN_ROLE_ID = WHITELIST_CFG.get("citizen_role_id", 1394591451597246494)

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

bot = commands.Bot(command_prefix="!", intents=intents)

# --- FUNÇÕES DE BANCO DE DADOS ---
def approve_user_db(discord_id, firstname, lastname, age):
    try:
        conn = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_NAME)
        cursor = conn.cursor()
        
        # 1. Buscar User ID pelo Discord
        identifier = f"discord:{discord_id}"
        cursor.execute("SELECT user_id FROM godz_user_ids WHERE identifier = %s", (identifier,))
        result = cursor.fetchone()
        
        if result:
            user_id = result[0]
            
            # 2. Atualizar Whitelist na tabela godz_users
            cursor.execute("UPDATE godz_users SET whitelisted = 1 WHERE id = %s", (user_id,))
            
            # 3. Inserir Identidade na tabela godz_user_identities
            registration = f"{random.randint(10000000, 99999999)}"
            phone = f"{random.randint(100, 999)}-{random.randint(100, 999)}"
            
            query_identity = """
                INSERT IGNORE INTO godz_user_identities(user_id, registration, phone, firstname, name, age) 
                VALUES(%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query_identity, (user_id, registration, phone, firstname, lastname, age))
            
            conn.commit()
            cursor.close()
            conn.close()
            return True, user_id
        else:
            cursor.close()
            conn.close()
            return False, None
            
    except Exception as e:
        print(f"Erro MySQL: {e}")
        return False, None

# --- VALIDAÇÃO DE TOKEN + IP ---
def validate_token_and_approve(input_code, discord_id, firstname, lastname, age):
    try:
        conn = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_NAME)
        cursor = conn.cursor(dictionary=True)

        # 1) Buscar token na tabela temporária
        cursor.execute("SELECT user_id, ip, created_at FROM godz_whitelist_temp WHERE token = %s", (input_code,))
        row = cursor.fetchone()
        if not row:
            cursor.close(); conn.close()
            return False, None, "Código não encontrado"

        user_id = row['user_id']
        token_ip = row['ip']

        # 2) Expiração de 30 minutos
        cursor.execute("SELECT TIMESTAMPDIFF(MINUTE, created_at, NOW()) AS age_min FROM godz_whitelist_temp WHERE token = %s", (input_code,))
        age_row = cursor.fetchone()
        if age_row and age_row['age_min'] > 30:
            cursor.close(); conn.close()
            return False, None, "Código expirado"

        # 3) Verificar IP da última conexão do usuário
        cursor.execute("SELECT ip FROM godz_users WHERE id = %s", (user_id,))
        urow = cursor.fetchone()
        last_ip = urow['ip'] if urow and 'ip' in urow else None
        if not last_ip or last_ip != token_ip:
            cursor.close(); conn.close()
            return False, None, "IP divergente"

        # 4) Vincular discord_id ao user_id e aprovar whitelist
        identifier = f"discord:{discord_id}"
        cursor.execute("INSERT IGNORE INTO godz_user_ids(identifier,user_id) VALUES(%s,%s)", (identifier, user_id))
        cursor.execute("UPDATE godz_users SET whitelisted = 1 WHERE id = %s", (user_id,))

        # 5) Criar identidade se não existir
        cursor.execute("SELECT user_id FROM godz_user_identities WHERE user_id = %s", (user_id,))
        has_identity = cursor.fetchone()
        if not has_identity:
            registration = f"{random.randint(10000000, 99999999)}"
            phone = f"{random.randint(100, 999)}-{random.randint(100, 999)}"
            cursor.execute(
                "INSERT IGNORE INTO godz_user_identities(user_id, registration, phone, firstname, name, age) VALUES(%s,%s,%s,%s,%s,%s)",
                (user_id, registration, phone, firstname, lastname, age)
            )

        # 6) Remover token usado
        cursor.execute("DELETE FROM godz_whitelist_temp WHERE token = %s", (input_code,))

        conn.commit()
        cursor.close(); conn.close()
        return True, user_id, None

    except Exception as e:
        print(f"Erro MySQL: {e}")
        return False, None, "Erro interno"

# --- VIEWS E LÓGICA DE TICKET ---

class StartWhitelistView(View):
    def __init__(self):
        super().__init__(timeout=None)

    @discord.ui.button(label="📝 Iniciar Identificação", style=discord.ButtonStyle.green, custom_id="btn_start_wl")
    async def start_whitelist(self, interaction: discord.Interaction, button: Button):
        # 1. Criar Canal Privado
        guild = interaction.guild
        user = interaction.user
        category_id = CHANNELS_CFG.get("whitelist_category")
        category = guild.get_channel(category_id) if category_id else None
        
        # Fallback se a categoria não existir na config ou não for encontrada
        if not category:
            category = discord.utils.get(guild.categories, name="GODZ | TICKETS")
            if not category:
                category = await guild.create_category("GODZ | TICKETS")

        # Verifica se já tem ticket aberto
        existing_channel = discord.utils.get(guild.text_channels, name=f"identificacao-{user.id}")
        if existing_channel:
            await interaction.response.send_message(f"Você já possui um processo aberto em {existing_channel.mention}!", ephemeral=True)
            return

        # Permissões: User + Bot + Admins
        overwrites = {
            guild.default_role: discord.PermissionOverwrite(read_messages=False),
            user: discord.PermissionOverwrite(read_messages=True, send_messages=True),
            guild.me: discord.PermissionOverwrite(read_messages=True, send_messages=True)
        }
        
        channel = await guild.create_text_channel(f"identificacao-{user.id}", category=category, overwrites=overwrites)
        await interaction.response.send_message(f"Processo iniciado em {channel.mention}", ephemeral=True)
        
        # Iniciar fluxo da IA Nexus
        asyncio.create_task(run_nexus_protocol(channel, user))

async def run_nexus_protocol(channel, user):
    def check(m):
        return m.author == user and m.channel == channel

    embed_color = 0xB8860B # Dark Gold

    try:
        # Passo 1: Nome RP
        await channel.send(f"{user.mention}", embed=discord.Embed(
            description="Olá, detectamos sua assinatura. Eu sou a Nexus.\nPor favor, informe seu **Nome e Sobrenome** para o registro (Ex: Bob Godz).",
            color=embed_color
        ))
        
        msg_name = await bot.wait_for('message', check=check, timeout=300)
        full_name = msg_name.content.strip()
        
        # Tratamento simples do nome
        parts = full_name.split()
        if len(parts) < 2:
            firstname = full_name
            lastname = "Indigente"
        else:
            firstname = parts[0]
            lastname = " ".join(parts[1:])

        # Passo 2: Idade
        await channel.send(embed=discord.Embed(
            description=f"Entendido, **{firstname}**. Qual a sua idade?",
            color=embed_color
        ))
        
        while True:
            msg_age = await bot.wait_for('message', check=check, timeout=300)
            if msg_age.content.isdigit():
                age = int(msg_age.content)
                if 18 <= age <= 90:
                    break
                else:
                    await channel.send("A idade deve ser entre 18 e 90 anos. Tente novamente.")
            else:
                await channel.send("Por favor, digite apenas números.")

        # Passo 3: Código de Acesso (Token único exibido no jogo)
        await channel.send(embed=discord.Embed(
            description="Para validação biométrica final, informe o **Código de Acesso** exibido na sua tela do jogo.",
            color=embed_color
        ))
        
        msg_code = await bot.wait_for('message', check=check, timeout=300)
        input_code = msg_code.content.strip()

        # Validação cruzada (Token + IP)
        await channel.send(embed=discord.Embed(description="🔄 Verificando código e assinatura de rede...", color=embed_color))
        ok, user_id, err = validate_token_and_approve(input_code, user.id, firstname, lastname, age)

        if ok:
            # Dar Cargo
            try:
                guild = channel.guild
                role = guild.get_role(CITIZEN_ROLE_ID) or discord.utils.get(guild.roles, name="Cidadão")
                if role:
                    await user.add_roles(role)
            except Exception as e:
                print(f"Erro cargo: {e}")

            await channel.send(embed=discord.Embed(
                title="✅ IDENTIDADE VALIDADA",
                description=f"Bem-vindo à GODZ City, **{firstname} {lastname}**.\nVocê já pode acessar o setor.\n\n*Este canal será fechado em 10 segundos.*",
                color=embed_color
            ))
            
            await asyncio.sleep(10)
            await channel.delete()
        else:
            # Anti-venda / divergência
            msg = err or "Código inválido"
            await channel.send(embed=discord.Embed(
                title="❌ VALIDAÇÃO NEGADA",
                description=f"{msg}. Caso persistir, contate a Staff.",
                color=embed_color
            ))
            await asyncio.sleep(10)
            await channel.delete()

    except asyncio.TimeoutError:
        await channel.send("Tempo esgotado. Protocolo encerrado.")
        await asyncio.sleep(5)
        await channel.delete()
    except Exception as e:
        print(f"Erro no protocolo: {e}")

# --- COMANDOS ---

@bot.event
async def on_ready():
    print(f"🤖 GODZ NEXUS BOT conectado como {bot.user}")
    bot.add_view(StartWhitelistView())

@bot.command(name="setup-wl")
@commands.has_permissions(administrator=True)
async def setup_whitelist(ctx):
    await ctx.message.delete()
    
    embed = discord.Embed(
        title="SISTEMA DE IDENTIFICAÇÃO NEXUS",
        description="""Saudações, cidadão.
        
Para acessar a **GODZ City**, é necessário validar sua identidade biométrica e apresentar o código de acesso.

Clique no botão abaixo para iniciar o protocolo seguro.""",
        color=0xB8860B
    )
    embed.set_footer(text="GODZ ENGINE • Secure Identification Protocol")
    embed.set_image(url="https://i.imgur.com/YourBanner.png") # Placeholder
    
    await ctx.send(embed=embed, view=StartWhitelistView())

if __name__ == "__main__":
    if DISCORD_TOKEN and DISCORD_TOKEN != "COLOQUE_SEU_TOKEN_AQUI":
        bot.run(DISCORD_TOKEN)
    else:
        print("❌ ERRO: Configure o DISCORD_TOKEN no GODZ_MASTER_CONFIG.json")
