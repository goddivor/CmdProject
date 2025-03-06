@echo off
set doc=%1
set doc2=%2
if /i a%doc% equ a (
echo La syntaxe de la commande n'est pas correcte.
) else (
if /i a%doc2% equ a (
echo La syntaxe de la commande n'est pas correcte.
) else (
rem echo correct
rem echo %doc2%
if exist %doc2% (
for /f "delims=" %%a in ('dir /b /a:d %1') do move "%%a" %doc2%
) else (
echo repertoire introuvables
)
)
)
rem Liberation des vairable
set doc=
set doc2=