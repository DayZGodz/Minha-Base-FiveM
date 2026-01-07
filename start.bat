@echo off
cd /d "%~dp0"
echo ==================================================
echo       FAMÍLIA GOD - SUPER BASE UNIFIED (2026)
echo ==================================================
artifacts\FXServer.exe +set serverProfile "default" +set serverDataPath "server" +exec config/config.cfg
pause