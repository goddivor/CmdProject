@echo off & echo.
rem definition des variables
set /a dossier=0

rem petite verification
if a%1 neq a (
	set doc=%1
	goto class1
	)

:suite

rem Commencement
if a%1 equ a (
for /d %%a in ("%cd%"\*) do (
	set /a dossier+=1 & @echo [%%~nxa]
	)
) else (
	for /d %%a in ("%cd%"\%doc%) do (
		set /a dossier+=1 & @echo [%%~nxa]
		)
	)
rem afficache du nombre d'element
echo. & echo                     [%dossier%] dossiers
goto fin

rem Supression des variables
set dossier=
set doc=

:class1
if "%doc:~-1%" neq "*" (
	set doc=%doc%\*
	)
goto suite

:fin