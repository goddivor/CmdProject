@echo off

rem Declaration de Variables
set /a fichier=0
set /a fich=0
set rep=%1

rem Verifier s'il a mis des argument
if a%1 equ a (
	goto ver1
	) else (
	goto ver2
	)



:ver1
	rem echo Sans argument
	rem Verifier si le dossier est vide de fichier
	for %%a in (*) do set /a fichier+=1
	if %fichier% == 0 (
	echo Le repertoire ne contient pas de fichier
	) else (
	rem echo contient des fichiers %fichier%
	goto tache1
	)
	goto suite
:finVer1

:ver2
rem echo Avec argument
rem Verifier si cet argument est exist
	if exist %rep% (
		rem echo Ca exist
		goto ver3
		) else (
		echo Le repertoire indiquer est introuvable
		)
	goto suite
:finVer2

:ver3
rem Verifier si le dossier est vide de fichier
for %%b in (%1\*) do set /a fich+=1
if %fich% == 0 (
echo le repertoire ne contient pas de fichier
) else (
rem echo contient des fichiers %fich%
goto tache2
)	
goto suite
:finVer3

:tache1
for /f "tokens=1,2 delims==" %%a in ('assoc') do (
	if exist *%%a (
		if not exist %%b md %%b
		move *%%a %%b
		)
	)
goto suite
:fintache1

:tache2
for /f "tokens=1,2 delims==" %%a in ('assoc') do (
	if exist %1\*%%a (
		if not exist %1\%%b md %1\%%b
		move %1\*%%a %1\%%b
		)
	)
goto suite
:fintache2

:suite

rem Liberation des Variables
set fichier=
set rep=
set fich=