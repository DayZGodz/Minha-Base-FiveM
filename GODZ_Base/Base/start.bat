@echo off
title GODZ SERVER CONTROLLER

echo ===---------[GODZ BASE]---------===
echo     GODZ DEV BASE VRPEX (release)
echo     Performance/Seguranca/Otimizacao
echo     Developed by: GODZ Dev 
echo     Discord: github.com/DayZGodz
echo ===---------------------------------===

set /p update="Deseja verificar atualizacoes de Artefatos? (S/N): "
if /i "%update%"=="S" (
    echo Iniciando atualizador...
    powershell -ExecutionPolicy Bypass -File "..\..\update_artifacts.ps1"
)

echo.
echo [96m[GODZ AI] Verificando dependencias...[0m
python -c "import flask" 2>NUL
if %errorlevel% neq 0 (
    echo [93m[GODZ AI] Instalando bibliotecas necessarias...[0m
    pip install -r requirements.txt
) else (
    echo [92m[GODZ AI] Dependencias OK.[0m
)

echo.
echo [95m[GODZ AI] Iniciando Cerebro...[0m
start "GODZ_AI_BRIDGE" /min python godz_ai_bridge.py

echo.
echo [94m[GODZ SERVER] Carregando Artefatos...[0m
echo [94m[GODZ SERVER] Servidor iniciando...[0m

:: Inicia o servidor e aguarda o fechamento da janela
start /wait ..\artifacts\FXServer.exe +exec config/config.cfg +set onesync_enableInfinity 0 +set onesync on +set sv_enforceGameBuild 2612

echo.
echo [91m[GODZ SERVER] Servidor encerrado.[0m
echo [91m[GODZ AI] Encerrando IA...[0m
taskkill /FI "WINDOWTITLE eq GODZ_AI_BRIDGE" /F >NUL 2>&1

echo [SYSTEM] Processos finalizados.
timeout /t 3
exit

