@ECHO ON
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
FOR /R iso %%I IN (*.bffnt.lz *.bfres.lz *.msbt.lz) DO (tools\lzxTool d "%%I" "%%~dpnI" || PAUSE)
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
