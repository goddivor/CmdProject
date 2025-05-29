@echo off
REM — Passe la console en UTF-8
chcp 65001 >nul

REM — Récupère le nom du script pour l’usage
set SCRIPT_NAME=%~n0

REM — Si pas d’argument ou demande d’aide, affiche l’aide
if "%~1"=="" goto :usage
if "%~1"=="-h" goto :usage
if "%~1"=="--help" goto :usage
if "%~1"=="/?" goto :usage

REM — Appelle l’exécutable en lui passant tous les paramètres
"%~dp0tree_ex_with_icons.exe" %*
goto :eof

:usage
echo Usage: %SCRIPT_NAME% [chemin] [-e pattern] [-E pattern] [-f] [-h^|--help]
echo.
echo Description :
echo   Wrapper pour tree_ex_with_icons.exe qui force l'affichage UTF-8.
echo.
echo Options :
echo   chemin         Chemin du répertoire à explorer (défaut : .)
echo   -e pattern     Exclut les dossiers matching pattern (wildcards OK)
echo   -E pattern     Exclut les fichiers matching pattern (wildcards OK)
echo   -f             Affiche aussi les fichiers (sinon seuls les dossiers)
echo   -h, --help     Affiche cette aide
echo.
echo Exemples :
echo   %SCRIPT_NAME% C:\MonProjet -e .git -E *.exe -f
echo   %SCRIPT_NAME% . -e node_modules --help
echo   %SCRIPT_NAME% .. -e .git -e node_modules -E *.o -f
goto :eof
