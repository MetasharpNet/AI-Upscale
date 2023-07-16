@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [models-se] (default)
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-se  > NUL 2> NUL
del _outputs-se\*.* /s /q /f > NUL 2> NUL
realcugan-ncnn-vulkan.exe -x -f png -i _inputs -o _tmp -m models-se -n 0
echo resizing and converting to jpg...
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-se\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
pause
echo renumbering files with padding...
call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-se"
echo deleting temporary folder...
rd /S /Q _tmp
