@echo off
setlocal enabledelayedexpansion

rem Vérifier s'il y a un argument
if "%~1"=="" (
    echo Usage: %~n0 ^<lecteur^>
    echo Exemple: %~n0 C:\
    exit /b 1
)

rem Obtenir l'espace libre du disque
set free_bytes=
for /f "tokens=3 delims= " %%a in ('dir "%~1" 2^>nul ^| findstr /e /l "libres"') do (
    set free_bytes=%%a
)

rem Vérifier si on a obtenu une valeur
if not defined free_bytes (
    echo Erreur: Impossible d'obtenir l'espace libre pour "%~1"
    exit /b 1
)

rem Nettoyer les espaces et caractères non numériques
call :clean_number "!free_bytes!" free_bytes

rem Afficher l'espace libre formaté
if "!free_bytes!"=="0" (
    echo 0 octets libres
) else (
    call :format_size "!free_bytes!" formatted_size
    echo Espace libre: !formatted_size!
)

exit /b 0

rem ========================================
rem Fonction de formatage avec PowerShell
rem ========================================
:format_size
setlocal
set bytes=%~1

rem Utiliser PowerShell pour formater
for /f "delims=" %%i in ('powershell -command "$size = %bytes%; if($size -lt 1024) { \"$size octets\" } elseif($size -lt 1MB) { \"{0:N2} Ko\" -f ($size/1KB) } elseif($size -lt 1GB) { \"{0:N2} Mo\" -f ($size/1MB) } elseif($size -lt 1TB) { \"{0:N2} Go\" -f ($size/1GB) } else { \"{0:N2} To\" -f ($size/1TB) }"') do set result=%%i

endlocal & set %2=%result%
exit /b 0

rem ========================================
rem Fonction de nettoyage des nombres
rem ========================================
:clean_number
setlocal
set input=%~1
set output=

rem Parcourir pour ne garder que les chiffres
for /l %%i in (0,1,50) do (
    set char=!input:~%%i,1!
    if "!char!"=="" goto end_clean
    if "!char!" geq "0" if "!char!" leq "9" set output=!output!!char!
)

:end_clean
if "!output!"=="" set output=0
endlocal & set %2=%output%
exit /b 0