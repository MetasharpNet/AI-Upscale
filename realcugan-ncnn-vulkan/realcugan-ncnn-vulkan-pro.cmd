@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [models-pro]
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-pro  > NUL 2> NUL
del _outputs-pro\*.* /s /q /f > NUL 2> NUL
realcugan-ncnn-vulkan.exe -x -f png -i _inputs -o _tmp -m models-pro -n 0
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-pro\%%~na.jpg" -max-height 2500 -keep-ratio yes -force yes
)
call renumber.cmd _outputs-gan-x4plus-anime\
rd /S /Q _tmp
