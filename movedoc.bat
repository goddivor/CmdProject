@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: movedoc.bat ^<repertoire_source^> ^<repertoire_destination^>
    echo Deplace tous les dossiers du repertoire source vers le repertoire destination
    exit /b 1
)

if "%~2"=="" (
    echo Usage: movedoc.bat ^<repertoire_source^> ^<repertoire_destination^>
    echo Deplace tous les dossiers du repertoire source vers le repertoire destination
    exit /b 1
)

set "source_dir=%~1"
set "dest_dir=%~2"

if not exist "%source_dir%" (
    echo Erreur: Le repertoire source '%source_dir%' n'existe pas.
    exit /b 1
)

if not exist "%dest_dir%" (
    echo Erreur: Le repertoire destination '%dest_dir%' n'existe pas.
    exit /b 1
)

echo Deplacement des dossiers de '%source_dir%' vers '%dest_dir%'...

set /a count=0
for /d %%D in ("%source_dir%\*") do (
    echo Deplacement: %%~nxD
    move "%%D" "%dest_dir%" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a count+=1
    ) else (
        echo Erreur lors du deplacement de: %%~nxD
    )
)

if !count! equ 0 (
    echo Aucun dossier trouve dans '%source_dir%'
) else (
    echo %count% dossier(s) deplace(s) avec succes.
)