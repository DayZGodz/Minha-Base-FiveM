@echo off
title GODZ SERVER CONTROLLER

echo ==================================================
echo       FAMÍLIA GOD - SUPER BASE UNIFIED (2026)
echo ==================================================

echo [GODZ INFRA] Verificando atualizações do FXServer....
python infra/godz_updater.py

echo.
echo  [96m[FAMILÍA GOD AI] Verificando dependencias...[0m
python -c "import flask" 2>NUL
if %errorlevel% neq 0 (
    echo  [93m[FAMILÍA GOD AI] Instalando bibliotecas necessarias...[0m
    pip install -r requirements.txt
) else (
    echo  [92m[FAMILÍA GOD AI] Dependencias OK.[0m
)

echo.
echo  [95m[FAMILÍA GOD AI] Iniciando Cerebro...[0m
start "GODZ_AI_BRIDGE" /min python godz_ai_bridge.py

echo.
echo [94m[GODZ SERVER] Carregando Artefatos...[0m
echo [94m[GODZ SERVER] Servidor iniciando...[0m

:: Limpeza de Cache
echo [GODZ INFRA] Limpando cache...
if exist cache rd /s /q cache

:: Inicia o servidor e aguarda o fechamento da janela
start /wait ..\artifacts\FXServer.exe +exec config/config.cfg +set onesync_enableInfinity 0 +set onesync on +set sv_enforceGameBuild 2612

echo.
echo [91m[GODZ SERVER] Servidor encerrado.[0m
echo  [91m[FAMILÍA GOD AI] Encerrando IA...[0m
taskkill /FI "WINDOWTITLE eq GODZ_AI_BRIDGE" /F >NUL 2>&1

echo [SYSTEM] Processos finalizados.
timeout /t 3
exit

