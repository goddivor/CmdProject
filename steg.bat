@echo off

:start
set /p iname=Nom de l'image (.ext): 
goto ver1
:suite

:start2
set /p aname=Nom de l'archive (.ext): 
goto ver2
:suite2
copy /b %iname%+%aname%
goto fin


:ver1
if not defined iname (
	set iname=0
	echo Vous devez entrer le nom de l'image
	set iname=
	goto start
	)

if /i "a%iname%a" equ "a a" (
	echo cet nom " " est incorrect.
	set iname=
	goto start
	)

if not exist %iname% (
	echo desoler on ne trouve pas cet image sur votre ordi
	set iname=
	goto start
	) else (
	goto suite
	) 

:finver1

:ver2
if not defined aname (
	set aname=0
	echo Vous devez entrer le nom de l'archive
	set aname=
	goto start2
	)

if /i "a%aname%a" equ "a a" (
	echo cet nom " " est incorrect.
	set aname=
	goto start2
	)


if not exist %aname% (
	echo desoler on ne trouve pas cet archive sur votre ordi
	set aname=
	goto start2
	) else (
	goto suite2
	)
:finver2

:fin
set iname=
set aname=