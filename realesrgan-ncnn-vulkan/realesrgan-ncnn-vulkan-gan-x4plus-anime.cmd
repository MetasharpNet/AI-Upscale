@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [realesrgan-x4plus-anime] (optimized for anime images, small model size) (Sasukeriabu BD)
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-gan-x4plus-anime  > NUL 2> NUL
del _outputs-gan-x4plus-anime\*.* /s /q /f > NUL 2> NUL
realesrgan-ncnn-vulkan.exe -x -f png -i _inputs -o _tmp -n realesrgan-x4plus-anime
echo resizing and converting to jpg...
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-gan-x4plus-anime\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
echo renumbering files with padding...
call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-gan-x4plus-anime"
echo deleting temporary folder...
rd /S /Q _tmp
