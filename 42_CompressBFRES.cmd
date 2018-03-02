@ECHO ON
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
FOR /R translate %%I IN (*.bfres) DO (tools\lzxTool c "%%I" "%%I.lz" || PAUSE)
::FOR /R translate\Graphics\DisposObject\MOBJ\ %%I IN (*.bfres) DO (tools\lzxTool c "%%I" "%%I.lz" || PAUSE)
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
