@echo off

if -%1- equ -- (
	@echo 7|couleur.exe
) else (
	@echo %1|couleur.exe
)