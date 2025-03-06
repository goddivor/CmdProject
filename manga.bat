@echo off

rem Créer un tableau pour stocker les noms de dossier créés
setlocal enabledelayedexpansion
set "dirs= "

rem Parcourir les fichiers dans le répertoire courant
for %%i in (*.mp4 *.mp3 *.mkv) do (
    rem Extraire les deux premiers mots du nom de fichier
    for /f "tokens=1,2 delims= " %%j in ("%%~ni") do (
        set "dir_name=%%j*%%k"
        set "dir_name=!dir_name: =*!"
        rem Vérifier si le dossier pour ces deux premiers mots existe déjà
        if "!dirs!"=="!dirs:%%j*%%k=!" (
            rem Si le dossier n'existe pas, le créer et l'ajouter au tableau des noms de dossier créés
            md "%%j %%k"
            set dirs=!dirs! %%j*%%k
        )
        rem Déplacer le fichier dans le dossier correspondant en utilisant le nom de dossier complet
        if exist "!dir_name!*.*" (
            move "!dir_name!*.*" "%%j %%k"
        )
    )
)
