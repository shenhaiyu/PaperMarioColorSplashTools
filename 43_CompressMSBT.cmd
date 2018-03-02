@ECHO ON
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
FOR /R translate %%I IN (*.msbt) DO (tools\lzxTool c "%%I" "%%I.lz" || PAUSE)
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
