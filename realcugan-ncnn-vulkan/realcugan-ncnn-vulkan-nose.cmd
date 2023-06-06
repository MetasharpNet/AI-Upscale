@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

mkdir _tmp  > NUL 2> NUL

echo [models-nose] (BD best)
del _tmp\*.* /s /q /f > NUL 2> NUL
mkdir _outputs-nose > NUL 2> NUL
del _outputs-nose\*.* /s /q /f > NUL 2> NUL
realcugan-ncnn-vulkan.exe -f png -i _inputs -o _tmp -m models-nose -n 0
for %%a in ("_tmp\*.png") do (
   call scale.bat -source "%%~fa" -target "_outputs-nose\%%~nxa" -max-height 2500 -keep-ratio yes -force yes
)

rd /S /Q _tmp
