@echo off

set /a nbr=0
rem ci %2 existe
if /i -%2- neq -- set /a nbr+=1

:restart
if /i -%1- equ -- (
	rem echo la syntaxe de commande est incorrect
	rem echo %cd:~0,2%
	fsutil volume diskfree %cd:~0,2%
	) else (
	if %nbr% gtr 0 (
		echo Lecteur %1
		)
	fsutil volume diskfree %1
	)

:test
shift
if /i -%1- equ -- (
	goto fin
	) else (
	echo.
	goto restart
	)
:fintest

:fin
set nbr=