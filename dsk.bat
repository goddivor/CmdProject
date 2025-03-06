@echo off
for /f "tokens=2,3,4,5,6,7,8,9,10,11,12,13 delims= " %%a in ('fsutil fsinfo drives') do (
	echo Liste : %%a %%b %%c %%d %%e %%f %%g %%h %%i %%j %%k %%l
	echo.
	rem fsutil fsinfo drivetype %%a
	rem fsutil fsinfo drivetype %%b
	rem fsutil fsinfo drivetype %%c
	rem fsutil fsinfo drivetype %%d
	
	if /i not "%%a" equ "" (
		fsutil fsinfo drivetype %%a
		)
	if /i not "%%b" equ "" (
		fsutil fsinfo drivetype %%b
		)
	if /i not "%%c" equ "" (
		fsutil fsinfo drivetype %%c
		)
	if /i not "%%d" equ "" (
		fsutil fsinfo drivetype %%d
		)
	if /i not "%%e" equ "" (
		fsutil fsinfo drivetype %%e
		)
	if /i not "%%f" equ "" (
		fsutil fsinfo drivetype %%f
		)
	if /i not "%%g" equ "" (
		fsutil fsinfo drivetype %%g
		)
	if /i not "%%h" equ "" (
		fsutil fsinfo drivetype %%h
		)
	if /i not "%%i" equ "" (
		fsutil fsinfo drivetype %%i
		)
	if /i not "%%j" equ "" (
		fsutil fsinfo drivetype %%j
		)
	if /i not "%%k" equ "" (
		fsutil fsinfo drivetype %%k
		)
	if /i not "%%l" equ "" (
		fsutil fsinfo drivetype %%l
		)
	)