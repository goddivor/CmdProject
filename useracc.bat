@echo off

rem Afficher l'aide si aucun argument
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

:add_user
echo ==========================================
echo Creation d'un nouvel utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Nom d'utilisateur a creer: "
)

set /p pwd="Definir un mot de passe? (O/N): "
if /i "%pwd%"=="O" (
    set /p password="Mot de passe: "
    net user "%usernam%" "%password%" /add
) else (
    net user "%usernam%" /add
)

if %errorlevel% neq 0 (
    echo ERREUR: Impossible de creer l'utilisateur.
    goto end_script
)

echo Utilisateur "%usernam%" cree avec succes.

set /p admin="Ajouter aux Administrateurs? (O/N): "
if /i "%admin%"=="O" (
    net localgroup Administrators "%usernam%" /add
)

goto end_script

:delete_user
echo ==========================================
echo Suppression d'un utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Nom d'utilisateur a supprimer: "
)

echo ATTENTION: Suppression de l'utilisateur "%usernam%".
set /p confirm="Confirmer avec OUI: "
if not "%confirm%"=="OUI" (
    echo Suppression annulee.
    goto end_script
)

net user "%usernam%" /delete
if %errorlevel% equ 0 (
    echo Utilisateur supprime avec succes.
) else (
    echo ERREUR: Impossible de supprimer l'utilisateur.
)

goto end_script

:modify_user
echo ==========================================
echo Modification du mot de passe
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Nom d'utilisateur a modifier: "
)

set /p password="Nouveau mot de passe: "
net user "%usernam%" "%password%"

if %errorlevel% equ 0 (
    echo Mot de passe modifie avec succes.
) else (
    echo ERREUR: Impossible de modifier le mot de passe.
)

goto end_script

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
        set /p newname="Nouveau nom: "
    )
) else (
    set /p oldname="Nom actuel: "
    set /p newname="Nouveau nom: "
)

wmic useraccount where "name='%oldname%'" rename "%newname%"
if %errorlevel% equ 0 (
    echo Utilisateur renomme avec succes.
) else (
    echo ERREUR: Impossible de renommer.
)

goto end_script

:list_users
echo ==========================================
echo Liste des utilisateurs
echo ==========================================
echo.

net user

goto end_script

:user_info
echo ==========================================
echo Informations utilisateur
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Nom d'utilisateur: "
)

net user "%usernam%"

goto end_script

:enable_user
if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Utilisateur a activer: "
)

net user "%usernam%" /active:yes
if %errorlevel% equ 0 (
    echo Utilisateur active.
) else (
    echo ERREUR: Impossible d'activer.
)

goto end_script

:disable_user
if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Utilisateur a desactiver: "
)

net user "%usernam%" /active:no
if %errorlevel% equ 0 (
    echo Utilisateur desactive.
) else (
    echo ERREUR: Impossible de desactiver.
)

goto end_script

:manage_groups
echo ==========================================
echo Gestion des groupes
echo ==========================================
echo.

if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Nom d'utilisateur: "
)

echo Groupes disponibles:
net localgroup
echo.

set /p action="Ajouter (A) ou Retirer (R)? "
set /p group="Nom du groupe: "

if /i "%action%"=="A" (
    net localgroup "%group%" "%usernam%" /add
) else if /i "%action%"=="R" (
    net localgroup "%group%" "%usernam%" /delete
)

goto end_script

:initialize_user
if not "%2"=="" (
    set usernam=%2
) else (
    set /p usernam="Utilisateur a initialiser: "
)

echo.|net user %username% *>nul
if %errorlevel% equ 0 (
    echo Utilisateur initialise.
) else (
    echo ERREUR: Impossible d'initialiser.
)

goto end_script

:show_help
echo.
echo ==========================================
echo Gestionnaire de comptes utilisateurs
echo ==========================================
echo.
echo Usage: useracc [commande] [utilisateur]
echo.
echo COMMANDES:
echo   /add [nom]           Creer utilisateur
echo   /del [nom]           Supprimer utilisateur
echo   /mod [nom]           Modifier mot de passe
echo   /rename [old] [new]  Renommer utilisateur
echo   /list                Lister utilisateurs
echo   /info [nom]          Infos utilisateur
echo   /enable [nom]        Activer compte
echo   /disable [nom]       Desactiver compte
echo   /groups [nom]        Gerer groupes
echo   /ini [nom]           Initialiser mot de passe
echo   /help ou /?          Cette aide
echo.
echo EXEMPLES:
echo   useracc /add john
echo   useracc /del john
echo   useracc /info john
echo.

:end_script
exit /b 0