@echo off
set name=%1
if a%1 equ a (
echo.|net user %username% *>nul
) else (
echo.|net user %name% *>nul
)
set name=