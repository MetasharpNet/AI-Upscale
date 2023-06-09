@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [models-nose] (BD best)
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-nose > NUL 2> NUL
del _outputs-nose\*.* /s /q /f > NUL 2> NUL
realcugan-ncnn-vulkan.exe -x -f png -i _inputs -o _tmp -m models-nose -n 0
echo resizing and converting to jpg...
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-nose\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
echo renumbering files with padding...
call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-nose"
echo deleting temporary folder...
rd /S /Q _tmp
