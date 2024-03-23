@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

REM variables
set model_name=nose
set model_fullname=models-%model_name%
set model_info="[%model_fullname%] (bd best)"
set target_height=2500
set target_width=1738
set model_out_folder=_outputs-%model_name%
set model_cbz_folder=_outputs-%model_name%-cbz

REM constants
REM colors: https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
set color_reset=[0m
set cyan=[96m
set green=[92m
set red=[91m
set yellow=[93m

REM ---------------------------------------------------------------------------

call :msg %green% %model_info%

call :msg %cyan% "_inputs cleanup..."
del _inputs\*.txt /s /q /f > NUL 2> NUL
del _inputs\*.xml /s /q /f > NUL 2> NUL
del _inputs\*.pdf /s /q /f > NUL 2> NUL
del _inputs\*.nfo /s /q /f > NUL 2> NUL
del _inputs\*.sfv /s /q /f > NUL 2> NUL
del _inputs\.DS_Store /s /q /f > NUL 2> NUL
rd /S /Q _tmp > NUL 2> NUL

for %%a in ("_inputs\*.*") do (
	REM %%a   : relative filepath (ex: _inputs\filename.ext)
	REM %%~na : file name without extension (ex: filename)
	REM %%~fa : full file path (ex: D:\upscale ai\_inputs\filename.ext)

	call :msg %cyan% "temp folders initializing..."
	rd /S /Q _inputs-extracted > NUL 2> NUL
	rd /S /Q _inputs-resize > NUL 2> NUL
	rd /S /Q _inputs-frames > NUL 2> NUL
	mkdir _inputs-frames  > NUL 2> NUL
	rd /S /Q _outputs-frames > NUL 2> NUL
	mkdir _outputs-frames  > NUL 2> NUL
	mkdir %model_out_folder% > NUL 2> NUL

	call :msg %cyan% "creating Avisynth script for deinterlacing..."
	call powershell -ExecutionPolicy Bypass -File "tools\createdeinterlace-avs.ps1" "%%a"

	call :msg %cyan% "extract images from video..."
	tools\ffmpeg.exe -i deinterlace.avs -qscale:v 1 -qmin 1 -qmax 1 -pix_fmt yuv420p -r 25 -strict experimental _inputs-frames/frame%%08d.jpg

	call :msg %cyan% "deleting temporary deinterlace.avs..."
	del /f /q deinterlace.avs
	del /f /q "%%a.ffindex"

	call :msg %cyan% "apply AI model [%model_fullname%] to images..."
	tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -f png -i _inputs-frames -o _outputs-frames -m %model_fullname% -n 0
	
	call :msg %cyan% "join upscaled images into a video..."
	tools\ffmpeg.exe -i _outputs-frames/frame%%08d.png -i "%%a" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 19 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p "%model_out_folder%\%%~na.mp4"
)

call :msg %cyan% "cleanup..."
rd /S /Q _inputs-frames > NUL 2> NUL
rd /S /Q _outputs-frames > NUL 2> NUL

pause

REM ---------------------------------------------------------------------------

REM Functions

:msg
echo %~1%~2%color_reset%
exit /b