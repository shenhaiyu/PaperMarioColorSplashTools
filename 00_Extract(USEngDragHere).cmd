@ECHO OFF
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
::RD /S /Q iso
MD iso
XCOPY "%~1\content\fonts\*.bffnt.lz" iso\fonts\ /S /Y
XCOPY "%~1\content\Graphics\*.USA_en.bfres.lz" iso\Graphics\ /S /Y
::XCOPY "%~1\content\Graphics\*.USA_es.bfres.lz" iso\Graphics\ /S /Y
::XCOPY "%~1\content\Graphics\*.USA_fr.bfres.lz" iso\Graphics\ /S /Y
::XCOPY "%~1\content\Graphics\*.USA_pt.bfres.lz" iso\Graphics\ /S /Y
::XCOPY "%~1\content\Graphics\*.JPN_ja.bfres.lz" iso\Graphics\ /S /Y
::XCOPY "%~1\content\messages\*.msbt.lz" iso\messages\ /S /Y
XCOPY "%~1\content\messages\US_Final_English\*.msbt.lz" iso\messages\US_Final_English\ /S /Y
COPY "%~1\content\messages\gojika.msbp.lz" iso\messages\
COPY "%~1\content\fs.table" iso\
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
