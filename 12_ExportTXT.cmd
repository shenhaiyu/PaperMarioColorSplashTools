@ECHO OFF
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
tools\MSBTBatch\MSBTBatch e y iso\messages
FOR /R iso\messages %%I IN (*.kup) DO (COPY /Y "%%I" "%%~ndpI.txt")
ECHO;
ECHO;
ECHO ##There should be 25302 Labels has been replaced.
tools\bwfr\bwfr iso\messages\*.txt -f -s -argfile:tools\bwfr\FormatLabel.txt -encin:utf-8 -encout:utf-8 -encarg:utf-8 -unisign -trc
ECHO;
ECHO;
ECHO ##There should be 6088 Controls has been replaced.
tools\bwfr\bwfr iso\messages\*.txt -f -s -argfile:tools\bwfr\FormatCtrls.txt -encin:utf-8 -encout:utf-8 -encarg:utf-8 -unisign -trc
ECHO;
ECHO;
ECHO ##There should be 90234 Others has been replaced.
tools\bwfr\bwfr iso\messages\*.txt -f -s -argfile:tools\bwfr\FormatOther.txt -encin:utf-8 -encout:utf-8 -encarg:utf-8 -unisign -trc
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
PAUSE
