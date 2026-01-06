@echo off

echo ===---------[GODZ BASE]---------===
echo     GODZ DEV BASE VRPEX (release)
echo     Performance/Seguranca/Otimização
echo     Developed by: GODZ Dev 
echo     Discord: github.com/DayZGodz
echo ===---------------------------------===

set /p update="Deseja verificar atualizações de Artefatos? (S/N): "
if /i "%update%"=="S" (
    echo Iniciando atualizador...
    powershell -ExecutionPolicy Bypass -File "..\..\update_artifacts.ps1"
)

echo Iniciando servidor...
start ..\artifacts\FXServer.exe +exec config/config.cfg +set onesync_enableInfinity 0 +set onesync on +set sv_enforceGameBuild 2612
exit

