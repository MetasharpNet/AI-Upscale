@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _inputs-resize  > NUL 2> NUL
mkdir _tmp  > NUL 2> NUL

echo [realesr-general-wdn-x4v3]
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _inputs-resize  > NUL 2> NUL
mkdir _outputs-general-wdn-x4v3  > NUL 2> NUL
del _outputs-general-wdn-x4v3\*.* /s /q /f > NUL 2> NUL
for %%a in ("_inputs\*.*") do (
   call scale.bat -source "%%~fa" -target "_inputs-resize\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)

realesrgan-ncnn-vulkan.exe -x -f png -i _inputs-resize -o _tmp -n realesr-general-wdn-x4v3
echo resizing and converting to jpg...
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-general-wdn-x4v3\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
pause
echo renumbering files with padding...
cd _outputs-general-wdn-x4v3 && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-general-wdn-x4v3"
echo deleting temporary folder...
rd /S /Q _inputs-resize
rd /S /Q _tmp