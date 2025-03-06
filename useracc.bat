@echo off

set arg1=%1
set arg2=%2

if "%arg1%"=="/add" (
    set /p usernam="Enter the username to create: "
    set /p pwd="Do you want to set a password? (Yes/No): "

    if /i "%pwd%"=="Yes" (
        set /p password="Enter the password: "
        net user %usernam% %password% /add
    ) else (
        net user %usernam% /add
    )

    set /p admin="Add this user to the Administrators group? (Yes/No): "
    if /i "%admin%"=="Yes" (
        net localgroup Administrators %usernam% /add
    )
) else if "%arg1%"=="/del" (
    set /p usernam="Enter the username to delete: "
    net user %usernam% /delete
) else if "%arg1%"=="/mod" (
    set /p usernam="Enter the username to modify: "
    set /p password="Enter the new password: "
    net user %usernam% %password%
) else if "%arg1%"=="/rename" (
    set /p oldname="Enter the current username: "
    set /p newname="Enter the new username: "
    wmic useraccount where name='%oldname%' rename '%newname%'
) else if "%arg1%"=="/list" (
    net user
) else if "%arg1%"=="/ini" (
    set /p usernam="Enter the username to initialize: "
    echo.|net user %usernam% *>nul
) else if "%arg1%"=="/help" (
    echo Available commands:
    echo /add - Add a new user
    echo /del - Delete a user
    echo /mod - Modify a user's password
    echo /rename - Rename a user
    echo /list - List all users
    echo /ini - Initialize a user
    echo /help - Display this help message
) else (
    echo Unknown command.
)

pause