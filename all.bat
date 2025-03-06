@echo off

@for /d %%a in (*) do @(
	echo doc : %%a
	call elem "%%a"
)