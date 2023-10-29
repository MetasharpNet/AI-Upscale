@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

REM variables
set model_name=animevideov3
set model_fullname=realesr-%model_name%
set model_info="[%model_fullname%] (black n white mangas + animes)"
set target_height=2500
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
mkdir %model_cbz_folder% > NUL 2> NUL
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

	call :msg %cyan% "extract images from video..."
	tools\ffmpeg.exe -i "%%a" -fps_mode passthrough -qscale:v 1 -qmin 1 -qmax 1 _inputs-frames/frame%%08d.jpg
	
	call :msg %cyan% "apply AI model [] to images..."
	tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -i _inputs-frames -o _outputs-frames -n %model_fullname% -s 2 -f jpg
	
	call :msg %cyan% "join upscaled images into a video..."
	tools\ffmpeg.exe -i _outputs-frames/frame%%08d.jpg -i "%%a" -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 25 -pix_fmt yuv420p "%model_out_folder%\%%~na.mp4"
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