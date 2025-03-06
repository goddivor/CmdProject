@echo off
if /i a%1 equ a (
	echo La Syntaxe de la Commande n'est pas correct
	) else (
	md %1
	@for /f "delims=" %%a in ('dir /s /b *.%1') do (
		echo nom : %%~pnxa taille : "%%~za"
		copy "%%a" "%1\%%~za-%%~nxa"
		)
	@rd %1
	)