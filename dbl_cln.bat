@echo off

if "%1"=="/spd" (
    call :spd
    goto :eof
)

echo Usage: dbl_cln /spd
goto :eof

:spd
md tach
move * tach
for %%b in (tach\*) do (
    md tach\%%~zb
    if errorlevel 1 echo %%~zb>>tach.txt
    move "%%b" tach\%%~zb >nul
)
md double
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
cd double & move_file
cd ..
cd tach & move_file
cd ..
move_file
goto :eof
