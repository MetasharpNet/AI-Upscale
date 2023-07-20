@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [rescale]
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-rescale  > NUL 2> NUL
del _outputs-rescale\*.* /s /q /f > NUL 2> NUL
echo resizing and converting to jpg...
for %%a in ("_inputs\*.*") do (
   call scale.bat -source "%%~fa" -target "_outputs-rescale\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
pause
echo renumbering files with padding...
cd _outputs-rescale && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-rescale"
echo deleting temporary folder...
rd /S /Q _tmp
