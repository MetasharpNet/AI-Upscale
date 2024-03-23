@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

set target_height=2500
set target_width=1738

mkdir _tmp  > NUL 2> NUL

echo [rescale]
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-rescale  > NUL 2> NUL
del _outputs-rescale\*.* /s /q /f > NUL 2> NUL
echo "downsize initial pictures max heights to %target_height%px..."
for %%a in ("_inputs\*.*") do (
   call tools\scale.bat -source "%%~fa" -target "_outputs-rescale\%%~na.jpg" -max-height %target_height% -keep-ratio yes -force yes
)
pause
echo renumbering files with padding...
cd _outputs-rescale && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "tools\padfilenames.ps1" -FolderPath "_outputs-rescale"
echo deleting temporary folder...
rd /S /Q _tmp
