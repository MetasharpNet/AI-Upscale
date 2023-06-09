@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [realesr-general-wdn-x4v3]
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-general-wdn-x4v3  > NUL 2> NUL
del _outputs-general-wdn-x4v3\*.* /s /q /f > NUL 2> NUL
realesrgan-ncnn-vulkan.exe -x -f png -i _inputs -o _tmp -n realesr-general-wdn-x4v3
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-general-wdn-x4v3\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
call renumber.cmd _outputs-gan-x4plus-anime\
rd /S /Q _tmp
