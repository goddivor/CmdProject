@echo off

for /d %%a in (*) do (
    move "%%a"\*
)
emptdoc
