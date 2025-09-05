@echo off
REM — Passe la console en UTF-8
chcp 65001 >nul

rem Afficher l'aide si demandée
if /i "%~1"=="/?" goto show_help
if /i "%~1"=="--help" goto show_help

rem Traitement si aucun argument (répertoire courant)
if "%~1"=="" (
    call :process_directory "."
    goto end
)

@REM echo Analyse des répertoires...
@REM echo.

rem Boucle pour traiter chaque répertoire
:process_all
if "%~1"=="" goto end

call :process_directory "%~1"
shift
goto process_all

:process_directory
set target_dir=%~1

rem Vérifier si le répertoire existe
if not exist "%target_dir%" (
    echo Erreur: Le répertoire "%target_dir%" n'existe pas
    exit /b 1
)

rem Initialiser les compteurs
set dirs=0
set files=0

rem Compter les dossiers
for /d %%d in ("%target_dir%\*") do set /a dirs+=1

rem Compter les fichiers
for %%f in ("%target_dir%\*") do (
    if not exist "%%f\*" set /a files+=1
)

set /a elements=dirs+files

rem Afficher les résultats pour ce répertoire
@REM if "%target_dir%"=="." (
@REM     echo Répertoire courant:
@REM ) else (
@REM     echo Répertoire "%target_dir%":
@REM )
echo   [%dirs%] dossier(s)   [%files%] fichier(s)   [%elements%] element(s)
echo.

exit /b 0

:end
exit /b 0

:show_help
echo Usage: %~n0 [répertoire1] [répertoire2] [...]
echo.
echo Description:
echo   Compte les fichiers et dossiers dans un ou plusieurs répertoires
echo.
echo Options:
echo(/?, --help     Affiche cette aide
echo.
echo Exemples:
echo   %~n0                  Analyse le répertoire courant
echo   %~n0 C:\Windows       Analyse le répertoire C:\Windows
echo   %~n0 . Documents      Analyse le répertoire courant et Documents
echo.
exit /b 0