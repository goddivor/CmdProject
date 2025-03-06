@echo off & echo.

rem definition des variables
:restart
set /a fichier=0

rem petite verification
if a%1 neq a (
	set doc=%1
	goto class1
	)


:suite

rem Commencement
if a%1 equ a (
for %%a in (*) do (
	set /a fichier+=1 & @echo %%~nxa
	)
) else (
	for %%a in (%doc%) do (
	set /a fichier+=1 & @echo %%~nxa	
		)
	)
rem afficache du nombre d'element
echo. & echo                     [%fichier%] fichiers
goto fin


:class1
echo %doc%|@findstr /l "*">nul
rem echo %errorlevel%
if "%errorlevel%" equ "0" goto suite

rem if "%doc:~0,1%" equ "*" (
rem 	goto suite
rem 	)

if "%doc:~-1%" neq "*" (
	set doc=%doc%\*
	)
goto suite

:fin

:testo
shift
if /i a%1 equ a (
	goto fini
	) else (
	echo.
	goto restart
	)
:fintest

:fini
rem Supression des variables
set doc=
set fichier=