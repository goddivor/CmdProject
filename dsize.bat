@echo off

set /a compt=0
:restart
set rep="%1"

rem Varible
set /a octets=0

setlocal EnableDelayedExpansion
for /f "tokens=3 delims= " %%a in ('dir /a /s "%rep%" ^| findstr /e /l "octets"') do (@set octets=%%a) >nul
for /f %%a in ("%octets%") do (@set octets) >nul
setlocal DisableDelayedExpansion

shift

:code
	set /a compt=compt+1
	for /f "tokens=1-10 delims= " %%a in (' echo %octets%') do (
		set gard=%%a%%b%%c%%d%%e%%f%%g%%h%%i%%j
		)
	if not defined octets2 (
		set octets2=%gard%
		) else (
		set octets2=%octets2%+%gard%
		)
:fincode

:verification
if /i -%1- equ -- (
	goto fin
	) else (
	goto restart
	)
:finverification


:fin
if /i %compt% gtr 1 (
	rem echo a envoyer a la nouvel
	echo %octets2%|convertion2.exe & echo.
	rem echo %octets2% & echo.
	) else (
	rem echo a envoyer a l'ancienne
	echo %octets%|convertion.exe & echo.
	rem echo %octets2% & echo.
	)

rem Liberationion des variable
set rep=
set octets=
set octets2=
set compt=