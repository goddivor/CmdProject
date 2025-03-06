@echo off

rem Varible
set /a octets=0

setlocal EnableDelayedExpansion
for /f "tokens=3 delims= " %%a in ('dir %1 ^| findstr /e /l "libres"') do (@set octets=%%a) >nul
for /f %%a in ("%octets") do (@set octets) >nul
setlocal DisableDelayedExpansion
if /i "%octets%" neq "0" (
	echo %octets%|convertion.exe & echo.
	)
set octets=