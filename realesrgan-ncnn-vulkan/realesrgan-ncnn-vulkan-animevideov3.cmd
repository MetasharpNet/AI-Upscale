@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [realesr-animevideov3] (animation video)
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-animevideov3  > NUL 2> NUL
del _outputs-animevideov3\*.* /s /q /f > NUL 2> NUL
realesrgan-ncnn-vulkan.exe -x -f png -i _inputs -o _tmp -n realesr-animevideov3
echo resizing and converting to jpg...
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-animevideov3\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
pause
echo renumbering files with padding...
cd _outputs-animevideov3 && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-animevideov3"
echo deleting temporary folder...
rd /S /Q _tmp
