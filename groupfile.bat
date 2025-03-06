@echo off
if /i a%1 equ a (
	echo La Syntaxe de la Commande n'est pas correct
	) else (
	md %1
	@for /f "delims=" %%a in ('dir /s /b *.%1') do move "%%a" .\%1
	@rd %1
	)