@echo off

set arg1=%1
set arg2=%2

if "%arg1%"=="/add" (
    set /p usernam="Nom de l'utilisateur à créer : "
    set /p pwd="Voulez-vous définir un mot de passe ? (Oui/Non) : "

    if /i "%pwd%"=="Oui" (
        set /p password="Entrez le mot de passe : "
        net user %usernam% %password% /add
    ) else (
        net user %usernam% /add
    )
) else if "%arg1%"=="/del" (
    set /p usernam="Nom de l'utilisateur à supprimer : "
    net user %usernam% /delete
) else if "%arg1%"=="/mod" (
    set /p usernam="Nom de l'utilisateur à modifier : "
    set /p password="Entrez le nouveau mot de passe : "
    net user %usernam% %password%
) else if "%arg1%"=="/list" (
    net user
) else if "%arg1%"=="/ini" (
    set /p usernam="Nom de l'utilisateur à initialiser : "
    rem net user %usernam% * /delete
    rem net user %usernam% /add
    echo.|net user %usernam% *>nul
) else (
    echo Commande inconnue.
)

pause
