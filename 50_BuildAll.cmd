@ECHO OFF&setlocal enabledelayedexpansion
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
RD /S /Q build

::US
MD build\US\content\fonts
XCOPY translate\fonts\*.bffnt.lz build\US\content\fonts\ /S /Y
MD build\US\content\Graphics
XCOPY translate\Graphics\*.bfres.lz build\US\content\Graphics\ /S /Y
MD build\US\content\messages
XCOPY translate\messages\*.msbt.lz build\US\content\messages\ /S /Y
COPY translate\fs.table.US build\US\content\fs.table

::JP
MD build\JP\content\fonts
XCOPY translate\fonts\*.bffnt.lz build\JP\content\fonts\ /S /Y
COPY build\JP\content\fonts\pop.bffnt.lz build\JP\content\fonts\jp.bffnt.lz /Y
COPY build\JP\content\fonts\popL.bffnt.lz build\JP\content\fonts\jpL.bffnt.lz /Y
MD build\JP\content\Graphics
XCOPY translate\Graphics\*.bfres.lz build\JP\content\Graphics\ /S /Y
FOR /R build\JP\content\Graphics %%I IN (*.bfres.lz) DO (
  SET FN=%%~nxI
  SET FN=!FN:USA_en=JPN_ja!
  REN "%%I" "!FN!"
)
MD build\JP\content\messages
XCOPY translate\messages\US_Final_English\*.msbt.lz build\JP\content\messages\Japanese\ /S /Y
COPY translate\fs.table.JP build\JP\content\fs.table

::EU
MD build\EU\content\fonts
XCOPY translate\fonts\*.bffnt.lz build\EU\content\fonts\ /S /Y
MD build\EU\content\Graphics
XCOPY translate\Graphics\*.bfres.lz build\EU\content\Graphics\ /S /Y
FOR /R build\EU\content\Graphics %%I IN (*.bfres.lz) DO (
  SET FN=%%~nxI
  SET FN=!FN:USA_en=EUR_en!
  REN "%%I" "!FN!"
)
MD build\EU\content\messages
XCOPY translate\messages\US_Final_English\*.msbt.lz build\EU\content\messages\EU_English\ /S /Y
COPY translate\fs.table.EU build\EU\content\fs.table

CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
