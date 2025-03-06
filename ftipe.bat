@echo off
set rep="%1"

rem Varible
set /a octets=0

setlocal EnableDelayedExpansion
for /f "tokens=3 delims= " %%a in ('dir /a "%rep%" ^| findstr /e /l "octets"') do (@set octets=%%a) >nul
for /f %%a in ("%octets") do (@set octets) >nul
setlocal DisableDelayedExpansion
echo %octets%|convertion.exe & echo.