@echo off

if "%1" equ "1" (
for /d  %%a in (*) do (
	move "%%a"\*
	)
	emptdoc
)
if "%1" equ "2" (
md tach
move * tach
for %%b in (tach\*) do (
	md tach\%%~zb
	if errorlevel 1 echo %%~zb>>tach.txt
	move "%%b" tach\%%~zb >nul
	rem echo %%b
)
	md double
	rem call ..\tach.bat
	for /f %%a in (tach.txt) do (
	move tach\%%a .\double\
	)
	cd double
	for /d %%a in (*) do (
		cd %%a
		echo doc : %%a
		sup_double
		cd ..
		)
	cd ..
	del tach.txt
	cd double & test 1 & emptdoc
	cd ..
	cd tach & test 1 & emptdoc
	cd ..
	test 1 & emptdoc
)
rem title Invite de  commande
rem for /d %%a in (*) do (
rem 	cd "%%a" & @test2.bat
rem 	rem if %errorlevel% equ 1 move * ..
rem 	echo %errorlevel%
rem 	cd ..
rem 	)
	rem call emptdoc
	rem echo %errorlevel%

	rem for /d %%a in (*) do (
	rem 	for /f "delims=" %%b in ('dir /b "%%a"\*') do (
	rem 		echo %%b
	rem 		)
	rem 	)

rem set /a fichier=0	
	rem for /d %%a in (*) do (
	rem 	for %%b in ("%%a"\*) do (
	rem 		echo %%~nxb
	rem 		)
	rem 	rem echo %fichier%
	rem 	)
rem set fichier=