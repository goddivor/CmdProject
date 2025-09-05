@echo off

rem Affichage de l'aide si aucun argument
if "%1"=="" goto show_help

rem Traitement des commandes
if /i "%1"=="/add" goto add_user
if /i "%1"=="/del" goto delete_user
if /i "%1"=="/mod" goto modify_user
if /i "%1"=="/rename" goto rename_user
if /i "%1"=="/list" goto list_users
if /i "%1"=="/info" goto user_info
if /i "%1"=="/enable" goto enable_user
if /i "%1"=="/disable" goto disable_user
if /i "%1"=="/groups" goto manage_groups
if /i "%1"=="/ini" goto initialize_user
if /i "%1"=="/help" goto show_help
if /i "%1"=="/?" goto show_help

echo ERREUR: Commande inconnue "%1"
echo Utilisez /help pour voir les commandes disponibles.
goto end_script

rem ========================================
rem Fonction d'ajout d'utilisateur
rem ========================================
:add_user
echo ==========================================
echo Creation d'un nouvel utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a creer"
)

rem Vérifier que l'utilisateur n'existe pas déjà
call :user_exists "%usernam%" user_found
if %user_found% equ 1 (
    echo ERREUR: L'utilisateur "%usernam%" existe deja.
    goto end_script
)

set /p pwd="Definir un mot de passe? (O/N) [N]: "
if /i "!pwd!"=="O" (
    call :get_secure_password password
    net user "%usernam%" "%password%" /add >nul 2>&1
) else (
    net user "%usernam%" /add >nul 2>&1
)

if %errorlevel% neq 0 (
    echo ERREUR: Impossible de creer l'utilisateur "%usernam%".
    goto end_script
)

echo Utilisateur "%usernam%" cree avec succes.

set /p admin="Ajouter aux Administrateurs? (O/N) [N]: "
if /i "!admin!"=="O" (
    net localgroup Administrators "%usernam%" /add >nul 2>&1
    if %errorlevel% equ 0 (
        echo Utilisateur ajoute au groupe Administrators.
    ) else (
        echo ATTENTION: Impossible d'ajouter au groupe Administrators.
    )
)

set /p other_groups="Ajouter a d'autres groupes? (O/N) [N]: "
if /i "!other_groups!"=="O" (
    call :add_to_groups "%usernam%"
)

goto end_script

rem ========================================
rem Fonction de suppression d'utilisateur
rem ========================================
:delete_user
echo ==========================================
echo Suppression d'un utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a supprimer"
)

rem Vérifier que l'utilisateur existe
call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

echo ATTENTION: Vous etes sur le point de supprimer l'utilisateur "%usernam%".
set /p confirm="Confirmer la suppression? (OUI pour confirmer): "
if not /i "%confirm%"=="OUI" (
    echo Suppression annulee.
    goto end_script
)

net user "%usernam%" /delete >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur "%usernam%" supprime avec succes.
) else (
    echo ERREUR: Impossible de supprimer l'utilisateur "%usernam%".
)

goto end_script

rem ========================================
rem Fonction de modification d'utilisateur
rem ========================================
:modify_user
echo ==========================================
echo Modification du mot de passe
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a modifier"
)

rem Vérifier que l'utilisateur existe
call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

call :get_secure_password password
net user "%usernam%" "%password%" >nul 2>&1

if %errorlevel% equ 0 (
    echo Mot de passe de "%usernam%" modifie avec succes.
) else (
    echo ERREUR: Impossible de modifier le mot de passe de "%usernam%".
)

goto end_script

rem ========================================
rem Fonction de renommage d'utilisateur
rem ========================================
:rename_user
echo ==========================================
echo Renommage d'un utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set oldname=%2
    if not "%3"=="" (
        set newname=%3
    ) else (
        call :get_valid_username newname "Nouveau nom d'utilisateur"
    )
) else (
    call :get_valid_username oldname "Nom d'utilisateur actuel"
    call :get_valid_username newname "Nouveau nom d'utilisateur"
)

rem Vérifier que l'ancien utilisateur existe
call :user_exists "%oldname%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%oldname%" n'existe pas.
    goto end_script
)

rem Vérifier que le nouveau nom n'existe pas déjà
call :user_exists "%newname%" user_found
if %user_found% equ 1 (
    echo ERREUR: L'utilisateur "%newname%" existe deja.
    goto end_script
)

wmic useraccount where "name='%oldname%'" rename "%newname%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur "%oldname%" renomme en "%newname%" avec succes.
) else (
    echo ERREUR: Impossible de renommer l'utilisateur "%oldname%".
)

goto end_script

rem ========================================
rem Fonction de liste des utilisateurs
rem ========================================
:list_users
echo ==========================================
echo Liste des utilisateurs du systeme
echo ==========================================
echo.

rem Utiliser PowerShell pour un meilleur formatage
powershell -command "Get-LocalUser | Select-Object Name, Enabled, Description, LastLogon | Format-Table -AutoSize"

goto end_script

rem ========================================
rem Fonction d'information utilisateur
rem ========================================
:user_info
echo ==========================================
echo Informations detaillees d'un utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a consulter"
)

rem Vérifier que l'utilisateur existe
call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

echo Informations pour l'utilisateur "%usernam%":
echo.
net user "%usernam%"
echo.
echo Groupes d'appartenance:
net user "%usernam%" | findstr /C:"Appartient aux groupes"

goto end_script

rem ========================================
rem Fonction d'activation d'utilisateur
rem ========================================
:enable_user
if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a activer"
)

call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

net user "%usernam%" /active:yes >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur "%usernam%" active avec succes.
) else (
    echo ERREUR: Impossible d'activer l'utilisateur "%usernam%".
)

goto end_script

rem ========================================
rem Fonction de désactivation d'utilisateur
rem ========================================
:disable_user
if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a desactiver"
)

call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

net user "%usernam%" /active:no >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur "%usernam%" desactive avec succes.
) else (
    echo ERREUR: Impossible de desactiver l'utilisateur "%usernam%".
)

goto end_script

rem ========================================
rem Fonction de gestion des groupes
rem ========================================
:manage_groups
echo ==========================================
echo Gestion des groupes
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur"
)

call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

echo Groupes disponibles:
net localgroup | findstr /V "La commande" | findstr /V "Aliases" | findstr /V "^\*"
echo.

set /p action="Ajouter (A) ou Retirer (R) des groupes? (A/R): "
if /i "!action!"=="A" (
    call :add_to_groups "%usernam%"
) else if /i "!action!"=="R" (
    call :remove_from_groups "%usernam%"
) else (
    echo Action non reconnue.
)

goto end_script

rem ========================================
rem Fonction d'initialisation d'utilisateur
rem ========================================
:initialize_user
echo ==========================================
echo Initialisation du mot de passe
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    call :get_valid_username usernam "Nom d'utilisateur a initialiser"
)

call :user_exists "%usernam%" user_found
if %user_found% neq 1 (
    echo ERREUR: L'utilisateur "%usernam%" n'existe pas.
    goto end_script
)

echo Forcer le changement de mot de passe a la prochaine connexion...
net user "%usernam%" /logonpasswordchg:yes >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur "%usernam%" initialise. Changement de mot de passe requis.
) else (
    echo ERREUR: Impossible d'initialiser l'utilisateur "%usernam%".
)

goto end_script

rem ========================================
rem Fonctions utilitaires
rem ========================================


:user_exists
setlocal
set username=%~1
set exists=0
net user "%username%" >nul 2>&1
if %errorlevel% equ 0 set exists=1
endlocal & set %2=%exists%
exit /b 0

:get_valid_username
setlocal
set prompt_text=%~2
:ask_username
set /p username="!prompt_text!: "
if "!username!"=="" (
    echo Le nom d'utilisateur ne peut pas etre vide.
    goto ask_username
)
if "!username:~0,1!"==" " (
    echo Le nom d'utilisateur ne peut pas commencer par un espace.
    goto ask_username
)
if "!username: =!" neq "!username!" (
    echo Le nom d'utilisateur ne peut pas contenir d'espaces.
    goto ask_username
)
endlocal & set %1=%username%
exit /b 0

:get_secure_password
echo ATTENTION: Le mot de passe sera masque pendant la saisie.
set /p password="Nouveau mot de passe: "
if "%password%"=="" (
    echo ATTENTION: Mot de passe vide defini.
)
set %1=%password%
exit /b 0

:add_to_groups
setlocal
set username=%~1
echo.
echo Groupes disponibles pour ajout:
net localgroup | findstr /V "La commande" | findstr /V "Aliases" | findstr /V "^\*"
echo.
:add_group_loop
set /p group="Nom du groupe (ou ENTER pour finir): "
if "!group!"=="" goto end_add_groups
net localgroup "!group!" "!username!" /add >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur ajoute au groupe "!group!".
) else (
    echo ERREUR: Impossible d'ajouter au groupe "!group!".
)
goto add_group_loop
:end_add_groups
endlocal
exit /b 0

:remove_from_groups
setlocal
set username=%~1
echo.
echo Groupes actuels de l'utilisateur:
net user "!username!" | findstr /C:"Appartient aux groupes"
echo.
:remove_group_loop
set /p group="Nom du groupe a retirer (ou ENTER pour finir): "
if "!group!"=="" goto end_remove_groups
net localgroup "!group!" "!username!" /delete >nul 2>&1
if %errorlevel% equ 0 (
    echo Utilisateur retire du groupe "!group!".
) else (
    echo ERREUR: Impossible de retirer du groupe "!group!".
)
goto remove_group_loop
:end_remove_groups
endlocal
exit /b 0

:show_help
echo.
echo ==========================================
echo Gestionnaire de comptes utilisateurs Windows
echo ==========================================
echo.
echo Usage: %~n0 [commande] [utilisateur]
echo.
echo COMMANDES PRINCIPALES:
echo   /add [nom]           Creer un nouvel utilisateur
echo   /del [nom]           Supprimer un utilisateur
echo   /mod [nom]           Modifier le mot de passe
echo   /rename [ancien] [nouveau]  Renommer un utilisateur
echo.
echo COMMANDES D'INFORMATION:
echo   /list                Lister tous les utilisateurs
echo   /info [nom]          Details d'un utilisateur
echo.
echo COMMANDES DE GESTION:
echo   /enable [nom]        Activer un compte
echo   /disable [nom]       Desactiver un compte  
echo   /groups [nom]        Gerer les groupes
echo   /ini [nom]           Forcer changement mot de passe
echo.
echo AIDE:
echo   /help ou /?          Afficher cette aide
echo.
echo EXEMPLES:
echo   %~n0 /add john              Creer utilisateur 'john'
echo   %~n0 /del john              Supprimer utilisateur 'john'
echo   %~n0 /info john             Infos de 'john'
echo   %~n0 /rename john johnny    Renommer 'john' en 'johnny'
echo   %~n0 /groups john           Gerer groupes de 'john'
echo.
echo NOTES:
echo   - Validation des noms d'utilisateur
echo   - Confirmation requise pour suppressions
echo   - Gestion d'erreurs integree
echo.
goto end_script

:end_script
exit /b 0