@ECHO OFF
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
FOR /R iso\Graphics %%I IN (*.bfres) DO (COPY /Y "%%I" "%%~ndpI.bfbak")
FOR /R iso\Graphics %%I IN (*.bfres) DO (tools\BFRESTool\bfres_extract.py "%%I" "%%~dpI")
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
PAUSE
