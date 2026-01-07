@echo off
cd /d "%~dp0"
echo Iniciando servidor GODZ...
artifacts\FXServer.exe +set serverProfile "default" +set serverDataPath "server" +exec config/config.cfg
pause