@echo off
set doc=%1

if a%1 equ a (
	echo La syntaxe de commande est incorrect.
	goto fin
	) else (
	goto ver1
	)



:ver1
if exist %doc% (
@echo %doc%|isdi.exe
	) else (
	echo Nom de dossier introuvable.
	)

:fin