@echo off
REM Vérifie si un paramètre est passé
IF "%~1"=="" (
    echo Utilisation : genicon nom_fichier_avec_extension
    echo Exemple : genicon monimage.png
    exit /b
)

REM Stocke le nom complet du fichier source
set INPUT_FILE=%~1

REM Vérifie si le fichier existe
IF NOT EXIST "%INPUT_FILE%" (
    echo Le fichier "%INPUT_FILE%" n'existe pas.
    exit /b
)

echo Génération des icônes depuis %INPUT_FILE%...

magick %INPUT_FILE% -resize 16x16 icon16.png
magick %INPUT_FILE% -resize 32x32 icon32.png
magick %INPUT_FILE% -resize 48x48 icon48.png
magick %INPUT_FILE% -resize 128x128 icon128.png

echo Terminé ! Icônes générées : icon16.png, icon32.png, icon48.png, icon128.png
