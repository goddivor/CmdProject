@echo off
rem %1 : le nom du dossier
rem %2 : l'extension des fichier a ranger
if exist %1 (
	if exist %1\*.%2 (
		if a%2 equ a (
			echo vous devez indiquer l'extension des fichiers a ranger
			) else (
			@echo %1 %2|codec.exe
			)
		) else (
			echo il n'existe aucun fichier de ce extension "%2" dans le dossier "%1"
			goto fin
		)
	) else (
	echo Le repertoire indiquer "%1" n'existe pas
	)

	:fin
