@echo off
rem definition des variables

:restart
set /a dossier=0
set /a element=0
set /a fichier=0
set rep="%1"

rem echo rep : %rep:&=^&%
rem rem affichage des variables avant modifications
rem echo %dossier%
rem echo %fichier%
rem echo %element%
rem echo %rep%

rem rem Test des variables avant modifications
rem set dossier
rem set fichier
rem set element
rem set rep

rem Grande Modification

rem Test d'integrite
if -%1- equ -- (
	rem echo il na rien mis
rem modifications
for %%a in (*) do set /a fichier+=1
for /d %%b in (*) do set /a dossier+=1
set /a element=fichier+dossier
	) else (
	rem echo il a mis quelque chose
rem modifications
for %%a in ("%rep%"\*) do set /a fichier+=1
for /d %%b in ("%rep%"\*) do set /a dossier+=1
set /a element=fichier+dossier
	)


rem affichage des variables apres modifications
rem echo    %dossier% dossier
rem echo    %fichier% fichier
rem echo    %element% element
rem OU
echo   [%dossier%] dossier(s)   [%fichier%] fichier(s)  [%element%] element(s)
rem echo %rep%

rem rem Test des variables apres modification
rem set dossier
rem set fichier
rem set element
rem set rep

:test
shift
if /i -%1- equ -- (
	goto fin
	) else (
	goto restart
	)
:fintest

:fin
rem Supression des variables
set dossier=
set fichier=
set element=
set rep=

rem rem Test des variables apres suppression
rem set dossier
rem set fichier
rem set element
rem set rep