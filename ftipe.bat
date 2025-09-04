@echo off
setlocal enabledelayedexpansion

set error_flag=0
set "total_list="

rem Vérifier s'il y a des arguments
if "%~1"=="" (
    echo Usage: %~n0 ^<fichier1^> [fichier2] [...]
    echo Exemple: %~n0 document.txt video.mp4
    exit /b 1
)

echo Calcul de la taille des fichiers...
echo.

rem Boucle pour traiter chaque fichier
:process_file
if "%~1"=="" goto calculate_result

rem Vérifier si le fichier existe
if not exist "%~1" (
    echo Erreur: Le fichier "%~1" n'existe pas
    set error_flag=1
    shift
    goto process_file
)

echo Traitement de: "%~1"

rem Obtenir la taille du fichier actuel
set current_bytes=
for /f "tokens=3 delims= " %%a in ('dir /a "%~1" 2^>nul ^| findstr /e /l "octets"') do (
    set current_bytes=%%a
)

rem Nettoyer les espaces
call :clean_number "!current_bytes!" current_bytes

rem Afficher la taille de ce fichier
if defined current_bytes (
    if "!current_bytes!"=="0" (
        echo   Taille: 0 octets
    ) else (
        call :format_size "!current_bytes!" current_formatted
        echo   Taille: !current_formatted!
        
        rem Ajouter à la liste pour le total
        if "!total_list!"=="" (
            set total_list=!current_bytes!
        ) else (
            set total_list=!total_list!+!current_bytes!
        )
    )
)

shift
goto process_file

:calculate_result
echo.
if !error_flag! equ 1 (
    echo Certains fichiers n'ont pas pu être traités.
    echo.
)

if "!total_list!"=="" (
    echo Aucune donnée à afficher.
    exit /b !error_flag!
)

rem Afficher le total seulement s'il y a plusieurs fichiers
set file_count=0
set temp_list=!total_list!
:count_files
if "!temp_list!"=="" goto done_count
set /a file_count+=1
for /f "tokens=1* delims=+" %%a in ("!temp_list!") do set temp_list=%%b
goto count_files
:done_count

if !file_count! gtr 1 (
    echo ==========================================
    call :sum_and_format "!total_list!" formatted_total
    echo Taille totale: !formatted_total!
    echo ==========================================
)

exit /b !error_flag!

rem ========================================
rem Fonction qui fait la somme ET le formatage avec PowerShell
rem ========================================
:sum_and_format
setlocal
set expression=%~1

rem Utiliser PowerShell pour calculer et formater en une fois
for /f "delims=" %%i in ('powershell -command "$total = %expression%; if($total -lt 1024) { \"$total octets\" } elseif($total -lt 1MB) { \"{0:N2} Ko\" -f ($total/1KB) } elseif($total -lt 1GB) { \"{0:N2} Mo\" -f ($total/1MB) } elseif($total -lt 1TB) { \"{0:N2} Go\" -f ($total/1GB) } else { \"{0:N2} To\" -f ($total/1TB) }"') do set result=%%i

endlocal & set %2=%result%
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