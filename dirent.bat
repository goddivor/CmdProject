@echo off
set rep=%1

rem Varible 
set /a fich=0
set /a doss=0
set /a octets=0

for /f %%a in ('dir /s /b /a:-d %rep% ^| findstr -vi ".db"') do set /a fich+=1
for /f %%a in ('dir /s /b/a:d %rep%') do set /a doss+=1
echo.
echo Fichier ==^> %fich% Fichier(s)
echo dossier ==^> %doss% dossier(s)

setlocal EnableDelayedExpansion
for /f "tokens=3 delims= " %%a in ('dir /a /s %rep% ^| findstr /e /l "octets"') do (@set octets=%%a) >nul
for /f %%a in ("%octets") do (@set octets) >nul
setlocal DisableDelayedExpansion

echo      Taille du repertoire : %octets%
rem echo %octets%|dirconv.exe