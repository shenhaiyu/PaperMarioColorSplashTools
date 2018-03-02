@ECHO OFF
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
::RD /S /Q translate

MD translate
XCOPY iso\fonts\*.bffnt translate\fonts\ /S /Y

MD translate\Graphics
XCOPY iso\Graphics\*.bfres translate\Graphics\ /S /Y
XCOPY iso\Graphics\*.bfbak translate\Graphics\ /S /Y
XCOPY iso\Graphics\*.dds translate\Graphics\ /S /Y

MD translate\messages
XCOPY iso\messages\*.msbt translate\messages\ /S /Y
XCOPY iso\messages\*.msbt.bak translate\messages\ /S /Y
XCOPY iso\messages\*.msbt.txt translate\messages\ /S /Y

COPY iso\fs.table translate\fs.table.US
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
ECHO Remember add fs.table.JP and fs.table.EU to translate folder!!!!!!
PAUSE
