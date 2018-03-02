@ECHO OFF
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"
FOR /R translate\messages %%I IN (*.txt) DO (COPY /Y "%%I" "%%~ndpI.kup")
ECHO;
ECHO;
ECHO ##There should be 112403 Labels has been replaced.
tools\bwfr\bwfr translate\messages\*.kup -f -s -argfile:tools\bwfr\ReformatLabel.txt -encin:utf-8 -encout:utf-8 -encarg:utf-8 -unisign -trc
ECHO;
ECHO;
ECHO ##There should be 6096 Controls has been replaced.
tools\bwfr\bwfr translate\messages\*.kup -f -s -argfile:tools\bwfr\ReformatCtrls.txt -encin:utf-8 -encout:utf-8 -encarg:utf-8 -unisign -trc
ECHO;
ECHO;
ECHO ##There should be 1801 Others has been replaced.
tools\bwfr\bwfr translate\messages\*.kup -f -s -argfile:tools\bwfr\ReformatOther.txt -encin:utf-8 -encout:utf-8 -encarg:utf-8 -unisign -trc
ECHO;
ECHO;
tools\MSBTBatch\MSBTBatch i y translate\messages
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!
PAUSE
