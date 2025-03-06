@echo off
rem for /f "delims=" %%a in ('forfiles /m * /c "cmd /c if /i @isdir == "true" echo @path"') do @rd %%a
for /d %%a in (*) do ( @rd "%%a")