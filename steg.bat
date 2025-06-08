@echo off

:start
echo Welcome to the Steganography Tool!
echo This tool combines an image and an archive file into a single file.
echo.
echo Usage:
echo   - Enter the name of the image file (with extension) when prompted.
echo   - Enter the name of the archive file (with extension) when prompted.
echo   - The combined file will be created in the current directory.
echo.

set /p iname=Image name (.ext): 
goto ver1
:suite

:start2
set /p aname=Archive name (.ext): 
goto ver2
:suite2
copy /b %iname%+%aname% combined_%iname%
echo.
echo Done! The combined file is: combined_%iname%
goto end


:ver1
if not defined iname (
	set iname=0
	echo You must enter the image name
	set iname=
	goto start
	)

if /i "a%iname%a" equ "a a" (
	echo This name " " is incorrect.
	set iname=
	goto start
	)

if not exist %iname% (
	echo Sorry, this image was not found on your computer
	set iname=
	goto start
	) else (
	goto suite
	) 

:endver1

:ver2
if not defined aname (
	set aname=0
	echo You must enter the archive name
	set aname=
	goto start2
	)

if /i "a%aname%a" equ "a a" (
	echo This name " " is incorrect.
	set aname=
	goto start2
	)


if not exist %aname% (
	echo Sorry, this archive was not found on your computer
	set aname=
	goto start2
	) else (
	goto suite2
	)
:endver2

:end
set iname=
set aname=