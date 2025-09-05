@echo off
setlocal enabledelayedexpansion

rem Afficher l'aide si demandée
if /i "%~1"=="/?" goto show_help
if /i "%~1"=="--help" goto show_help
if /i "%~1"=="-h" goto show_help

rem Options
set show_space=0
if /i "%~1"=="-s" set show_space=1
if /i "%~1"=="--space" set show_space=1

echo ==========================================
echo Analyse des lecteurs du systeme
echo ==========================================
echo.

rem Utiliser une approche simple avec les lecteurs courants
echo Scan des lecteurs en cours...
echo.

rem Tester les lecteurs de A: à Z:
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        call :analyze_drive "%%d:"
    )
)

echo ==========================================
echo Analyse terminee
echo ==========================================

exit /b 0

rem ========================================
rem Fonction d'analyse d'un lecteur
rem ========================================
:analyze_drive
set drive=%~1

rem Supprimer les espaces
set drive=%drive: =%

rem Vérifier que ce n'est pas vide
if "%drive%"=="" exit /b 0

echo Lecteur: %drive%

rem Obtenir le type de lecteur
set drive_type=Inconnu
for /f "tokens=*" %%t in ('fsutil fsinfo drivetype %drive% 2^>nul') do (
    set drive_info=%%t
    for /f "tokens=4*" %%x in ("!drive_info!") do set drive_type=%%x %%y
)

rem Nettoyer le type de lecteur
set drive_type=!drive_type: =!
if "!drive_type!"=="" set drive_type=Inaccessible

echo   Type: !drive_type!

rem Afficher l'espace si demandé
if %show_space%==1 (
    call :get_drive_space "%drive%"
)

echo.
exit /b 0

rem ========================================
rem Fonction pour obtenir l'espace du lecteur
rem ========================================
:get_drive_space
set target_drive=%~1

rem Vérifier si le lecteur est accessible
if not exist "%target_drive%" (
    echo   Espace: Lecteur inaccessible
    exit /b 0
)

rem Obtenir l'espace libre
set free_space=
for /f "tokens=3 delims= " %%s in ('dir "%target_drive%" 2^>nul ^| findstr /e /l "libres"') do (
    set free_space=%%s
)

rem Obtenir l'espace total (approximatif via dir)
set total_space=
for /f "tokens=3 delims= " %%s in ('dir "%target_drive%" 2^>nul ^| findstr /e /l "octets"') do (
    set total_space=%%s
)

if defined free_space (
    call :clean_and_format_space "!free_space!" free_formatted
    echo   Espace libre: !free_formatted!
) else (
    echo   Espace: Information non disponible
)

exit /b 0

rem ========================================
rem Fonction de formatage des tailles
rem ========================================
:clean_and_format_space
setlocal
set input=%~1
set output=

rem Nettoyer les espaces et caractères non numériques
for /l %%i in (0,1,50) do (
    set char=!input:~%%i,1!
    if "!char!"=="" goto format_space
    if "!char!" geq "0" if "!char!" leq "9" set output=!output!!char!
)

:format_space
if "!output!"=="" set output=0

rem Utiliser PowerShell pour formater
for /f "delims=" %%i in ('powershell -command "$size = !output!; if($size -lt 1024) { \"$size octets\" } elseif($size -lt 1MB) { \"{0:N2} Ko\" -f ($size/1KB) } elseif($size -lt 1GB) { \"{0:N2} Mo\" -f ($size/1MB) } elseif($size -lt 1TB) { \"{0:N2} Go\" -f ($size/1GB) } else { \"{0:N2} To\" -f ($size/1TB) }"') do set result=%%i

endlocal & set %2=%result%
exit /b 0

:show_help
echo Usage: %~n0 [options]
echo.
echo Description:
echo   Affiche la liste de tous les lecteurs du systeme avec leur type
echo.
echo Options:
echo   -s, --space       Affiche aussi l'espace libre de chaque lecteur
echo   -h, /?, --help    Affiche cette aide
echo.
echo Exemples:
echo   %~n0              Liste tous les lecteurs avec leur type
echo   %~n0 -s           Liste tous les lecteurs avec type et espace libre
echo.
exit /b 0