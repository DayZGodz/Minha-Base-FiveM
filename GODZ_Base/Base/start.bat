@echo off

echo ===---------[GODZ BASE]---------===
echo     GODZ DEV BASE VRPEX (release)
echo     Performance/Seguranca/Otimização
echo     Developed by: GODZ Dev 
echo     Discord: github.com/DayZGodz
echo ===---------------------------------===

start ..\artifacts\FXServer.exe +exec config/config.cfg +set onesync_enableInfinity 0 +set onesync on +set sv_enforceGameBuild 2612
exit

