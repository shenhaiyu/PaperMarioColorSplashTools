@ECHO ON
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
FOR /R build\US\content %%I IN (*.bffnt.lz *.msbt.lz *.bfres.lz) DO (tools\fstableTool "%%I" "build\US\content\fs.table" build\US\content || PAUSE)
FOR /R build\JP\content %%I IN (*.bffnt.lz *.msbt.lz *.bfres.lz) DO (tools\fstableTool "%%I" "build\JP\content\fs.table" build\JP\content || PAUSE)
FOR /R build\EU\content %%I IN (*.bffnt.lz *.msbt.lz *.bfres.lz) DO (tools\fstableTool "%%I" "build\EU\content\fs.table" build\EU\content || PAUSE)
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
