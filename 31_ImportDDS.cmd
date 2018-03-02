@ECHO OFF
SET curdir=%CD%
SET rootdir=%~dp0
CD /D "%rootdir%"

::Convert DDS
FOR /R translate\Graphics %%I IN (*.DXT1.png) DO (
  CD /D %curdir%\tools\TexTools\
  AMDCompressCLI.exe -nomipmap -performance "%%I" "%%~ndpI.dds"
  TexConv2.exe -i "%%~ndpI.dds" -f GX2_SURFACE_FORMAT_T_BC1_UNORM -o "%%~ndpI.gtx" -swizzle 1
  TexConv2.exe -i "%%~ndpI.gtx" -f GX2_SURFACE_FORMAT_T_BC1_UNORM -o "%%~ndpI.dds"
  DEL "%%~ndpI.gtx"
  CD /D "%curdir%"
)
FOR /R translate\Graphics %%I IN (*.DXT5.png) DO (
  CD /D %curdir%\tools\TexTools\
  AMDCompressCLI.exe -nomipmap -performance "%%I" "%%~ndpI.dds"
  TexConv2.exe -i "%%~ndpI.dds" -f GX2_SURFACE_FORMAT_T_BC3_UNORM -o "%%~ndpI.gtx" -swizzle 1
  TexConv2.exe -i "%%~ndpI.gtx" -f GX2_SURFACE_FORMAT_T_BC3_UNORM -o "%%~ndpI.dds"
  DEL "%%~ndpI.gtx"
  CD /D "%curdir%"
)
FOR /R translate\Graphics %%I IN (*.ATI2.png) DO (
  CD /D %curdir%\tools\TexTools\
  AMDCompressCLI.exe -nomipmap -performance "%%I" "%%~ndpI.dds"
  TexConv2.exe -i "%%~ndpI.dds" -f GX2_SURFACE_FORMAT_T_BC5_UNORM -o "%%~ndpI.gtx" -swizzle 1
  TexConv2.exe -i "%%~ndpI.gtx" -f GX2_SURFACE_FORMAT_T_BC5_UNORM -o "%%~ndpI.dds"
  DEL "%%~ndpI.gtx"
  CD /D "%curdir%"
)
FOR /R translate\Graphics %%I IN (*.RGB8.png) DO (
  CD /D %curdir%\tools\TexTools\
  AMDCompressCLI.exe -nomipmap -performance "%%I" "%%~ndpI.dds"
  TexConv2.exe -i "%%~ndpI.dds" -f GX2_SURFACE_FORMAT_TCS_R8_G8_B8_A8_UNORM -o "%%~ndpI.gtx"
  TexConv2.exe -i "%%~ndpI.gtx" -o "%%~ndpI.dds"
  DEL "%%~ndpI.gtx"
  CD /D "%curdir%"
  tools\QuickBMS\quickbms -o -q tools\QuickBMS\TexConv2DDSFix.bms "%%~ndpI.dds" "%%~dpI\"
)

::Import DDS
FOR /R translate\Graphics %%I IN (*.bfbak) DO (COPY /Y "%%I" "%%~ndpI.bfres")
FOR /R translate\Graphics %%I IN (*.bfres) DO (tools\BFRESTool\bfres_import.py "%%I" "%%~dpI")
CD /D "%curdir%"
ECHO;
ECHO;
ECHO All Done!!!!

::Test Function - Fix shadow ATI2 DDS chanels in BFRES
::UI\Cmn\DrcBg.USA_en.bfres               0x001230 0x0012F0 0x0013B0
::UI\Cmn\TxtSam.USA_en.bfres              0x0006F0
::UI\Eyecatch\Eyecatch.USA_en.bfres       0x009310 0x0093D0 0x009490 0x009550 0x009610 0x0096D0 0x009790 0x009850
::UI\Eyecatch\EyecatchLuigi.USA_en.bfres  0x0067A0 0x006C20
::UI\Eyecatch\EyecatchPeach.USA_en.bfres  0x006B50
::UI\Eyecatch\EyecatchMario.USA_en.bfres  0x0064D0
::UI\Eyecatch\EyecatchPenkey.USA_en.bfres 0x0063C8
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x001231 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x001232 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x001233 0x01
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x0012F1 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x0012F2 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x0012F3 0x01
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x0013B1 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x0013B2 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\DrcBg.USA_en.bfres 0x0013B3 0x01
::tools\FileCorrector translate\Graphics\UI\Cmn\TxtSam.USA_en.bfres 0x0006F1 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\TxtSam.USA_en.bfres 0x0006F2 0x00
::tools\FileCorrector translate\Graphics\UI\Cmn\TxtSam.USA_en.bfres 0x0006F3 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009311 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009312 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009313 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x0093D1 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x0093D2 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x0093D3 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009491 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009492 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009493 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009551 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009552 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009553 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009611 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009612 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009613 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x0096D1 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x0096D2 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x0096D3 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009791 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009792 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009793 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009851 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009852 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\Eyecatch.USA_en.bfres 0x009853 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchLuigi.USA_en.bfres 0x0067A1 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchLuigi.USA_en.bfres 0x0067A2 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchLuigi.USA_en.bfres 0x0067A3 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchLuigi.USA_en.bfres 0x006C21 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchLuigi.USA_en.bfres 0x006C22 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchLuigi.USA_en.bfres 0x006C23 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchPeach.USA_en.bfres 0x006B51 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchPeach.USA_en.bfres 0x006B52 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchPeach.USA_en.bfres 0x006B53 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchMario.USA_en.bfres 0x0064D1 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchMario.USA_en.bfres 0x0064D2 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchMario.USA_en.bfres 0x0064D3 0x01
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchPenkey.USA_en.bfres 0x0063C9 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchPenkey.USA_en.bfres 0x0063CA 0x00
::tools\FileCorrector translate\Graphics\UI\Eyecatch\EyecatchPenkey.USA_en.bfres 0x0063CB 0x01
