@echo off

if "%1"=="/brk" (
	taskkill /im "explorer.exe" /f >nul
) else if "%1"=="/str" (
	@start explorer.exe
) else (
	echo "Option invalide. Utilisation : desk [/brk | /str]"
)