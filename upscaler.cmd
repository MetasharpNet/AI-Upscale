@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

setlocal enabledelayedexpansion

REM ---------------------------------------------------------------------------
REM Variables
REM ---------------------------------------------------------------------------
set mode=book
set model_fullname=models-%model_name%
if /i %upscaler% == ESRGAN (
	set model_fullname=realesr-%model_name%
)
set model_out_folder=_outputs-%model_name%
set model_out_tmp_folder=_outputs-%model_name%-tmp

REM ---------------------------------------------------------------------------
REM Constants
REM colors: https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
REM ---------------------------------------------------------------------------
set color_reset=[0m
set cyan=[96m
set green=[92m
set red=[91m
set yellow=[93m

REM ---------------------------------------------------------------------------
REM Process
REM ---------------------------------------------------------------------------

call :msg %green% "##### [%upscaler%][!model_fullname!]"

call :msg %cyan% "##### Cleaning _inputs..."
del _inputs\*.txt /s /q /f > NUL 2> NUL
del _inputs\*.xml /s /q /f > NUL 2> NUL
del _inputs\*.pdf /s /q /f > NUL 2> NUL
del _inputs\*.nfo /s /q /f > NUL 2> NUL
del _inputs\*.sfv /s /q /f > NUL 2> NUL
del _inputs\.DS_Store /s /q /f > NUL 2> NUL
del _inputs\*.ffindex /s /q /f > NUL 2> NUL
rd /S /Q _tmp > NUL 2> NUL
mkdir %model_out_folder% > NUL 2> NUL

for %%a in ("_inputs\*.*") do (
	REM %%a   : relative filepath (ex: _inputs\filename.ext)
	REM %%~na : file name without extension (ex: filename)
	REM %%~xa : file extension (ex: .mkv)
	REM %%~fa : full file path (ex: D:\upscale ai\_inputs\filename.ext)

	if /i "%%~xa" == ".mkv" (
		set mode=video
	) else if /i "%%~xa" == ".mp4" (
		set mode=video
	) else if /i "%%~xa" == ".avi" (
		set mode=video
	) else if /i "%%~xa" == ".ts" (
		set mode=video
	)
	call :msg %yellow% "##### [!mode!] %%~a"

	call :msg %cyan% "##### Initializing temporary folders..."
	rd /S /Q _inputs-extracted > NUL 2> NUL
	rd /S /Q _inputs-resize > NUL 2> NUL
	rd /S /Q _inputs-frames > NUL 2> NUL
	rd /S /Q _outputs-frames > NUL 2> NUL

	REM ---------------------------------------------------------------------------
	REM Book
	REM ---------------------------------------------------------------------------
	if /i !mode! == book (
		mkdir _inputs-extracted  > NUL 2> NUL
		mkdir _inputs-resize  > NUL 2> NUL
		mkdir _tmp  > NUL 2> NUL
		rd /S /Q %model_out_tmp_folder% > NUL 2> NUL
		mkdir %model_out_tmp_folder% > NUL 2> NUL

		call :msg %cyan% "##### Extracting archive..."
		tools\7-zip\7z.exe x "%%~fa" -o"_inputs-extracted" -aoa -bd > NUL 2> NUL
		call PowerShell.exe -ExecutionPolicy Bypass -File "tools\torootfolder.ps1" -SourceFilePath "%%~fa" -DestinationFolder "_inputs-extracted"
		del _inputs-extracted\*.txt /s /q /f > NUL 2> NUL
		del _inputs-extracted\*.xml /s /q /f > NUL 2> NUL
		del _inputs-extracted\*.pdf /s /q /f > NUL 2> NUL
		del _inputs-extracted\*.nfo /s /q /f > NUL 2> NUL
		del _inputs-extracted\*.sfv /s /q /f > NUL 2> NUL
		del _inputs-extracted\zzz-rip-club*.* /s /q /f > NUL 2> NUL
		del _inputs-extracted\.DS_Store /s /q /f > NUL 2> NUL

		if /i %images_rename% == on (
			call :msg %cyan% "##### Renaming files..."
			call powershell -ExecutionPolicy Bypass -File "tools\substitutecharacters.ps1" "_inputs-extracted"
		)

		if /i %images_resize% == height (
			call :msg %cyan% "##### Downsizing initial pictures max heights to %images_resize_height%px and converting to jpg..."
			for %%b in ("_inputs-extracted\*.*") do (
					call tools\scale.bat -source "%%~fb" -target "_inputs-resize\%%~nb.jpg" -max-height %images_resize_height% -keep-ratio yes -force yes
			)
		) else (
			call :msg %cyan% "##### Downsizing initial pictures max widths to %images_resize_width%px and converting to jpg..."
			for %%b in ("_inputs-extracted\*.*") do (
					call tools\scale.bat -source "%%~fb" -target "_inputs-resize\%%~nb.jpg" -max-width %images_resize_width% -keep-ratio yes -force yes
			)
		)

		call :msg %cyan% "##### Upscaling with [%upscaler%][!model_fullname!] pictures..."
		if /i %upscaler% == CUGAN (
			tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -f png -i _inputs-resize -o _tmp -m !model_fullname! -n 0
		) else (
			tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -f png -i _inputs-resize -o _tmp -n !model_fullname!
		)
		
		if /i %images_resize% == height (
			call :msg %cyan% "##### Downsizing initial pictures max heights to %images_resize_height%px and converting to jpg..."
			for %%b in ("_tmp\*.png") do (
			   call tools\scale.bat -source "%%~fb" -target "%model_out_tmp_folder%\%%~nb.jpg" -max-height %images_resize_height% -keep-ratio yes -force yes
			)
		) else (
			call :msg %cyan% "##### Downsizing initial pictures max widths to %images_resize_width%px and converting to jpg..."
			for %%b in ("_tmp\*.png") do (
			   call tools\scale.bat -source "%%~fb" -target "%model_out_tmp_folder%\%%~nb.jpg" -max-width %images_resize_width% -keep-ratio yes -force yes
			)
		)

		if /i %images_rename% == on (
			call :msg %cyan% "##### Renumbering files with padding..."
			cd %model_out_tmp_folder% && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "tools\padfilenames.ps1" -FolderPath "%model_out_tmp_folder%"
		)

		call :msg %cyan% "##### Creating cbz..."
		cd %model_out_tmp_folder% && cd .. && cd %model_out_folder% && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "tools\zip.ps1" -SourceFolder "%model_out_tmp_folder%" -DestinationFilePath "%model_out_folder%\%%~na [ia-%images_resize_height%px].cbz"

		call :msg %cyan% "##### Cleaning..."
		rd /S /Q _inputs-extracted > NUL 2> NUL
		rd /S /Q _inputs-resize > NUL 2> NUL
		rd /S /Q _tmp > NUL 2> NUL
		rd /S /Q %model_out_tmp_folder% > NUL 2> NUL

		call :msg %green% "##### Book done: %model_out_folder%\%%~na [ia-%images_resize_height%px].cbz"
	)

	REM ---------------------------------------------------------------------------
	REM Video
	REM ---------------------------------------------------------------------------
	if /i !mode! == video (
		mkdir _inputs-frames  > NUL 2> NUL
		mkdir _outputs-frames  > NUL 2> NUL

		if %video_deinterlace% NEQ None (
			
			call :msg %cyan% "##### Creating Avisynth script for deinterlacing..."
			call powershell -ExecutionPolicy Bypass -File "tools\createdeinterlace-avs.ps1" -filepath  "%%a" -mode %video_deinterlace% -assumeMode %video_deinterlace_assume_mode% -resizeAlgo %video_deinterlace_resize_algo% -x %video_deinterlace_resize_x% -y %video_deinterlace_resize_y%

			call :msg %cyan% "##### Extracting images with AviSynth from %%a ..."
			tools\ffmpeg.exe -i deinterlace.avs -qscale:v 1 -qmin 1 -qmax 1 -pix_fmt yuv420p -r 25 -strict experimental _inputs-frames/frame%%08d.jpg
		) else (
		
			call :msg %cyan% "##### Extracting images from %%a ..."
			tools\ffmpeg.exe -i "%%a" -qscale:v 1 -qmin 1 -qmax 1 -pix_fmt yuv420p -r 25 -strict experimental _inputs-frames/frame%%08d.jpg
		)

		call :msg %cyan% "##### Deleting temporary files..."
		del /f /q deinterlace.avs
		del /f /q "%%a.ffindex"

		call :msg %cyan% "##### Upscaling with [%upscaler%][!model_fullname!] images..."
		if %upscaler% == CUGAN (
			tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -f png -i _inputs-frames -o _outputs-frames -m %model_fullname% -n 0
		) else (
			tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -i _inputs-frames -o _outputs-frames -n %model_fullname% -s 2 -f jpg
		)

		call :msg %cyan% "##### Joining upscaled images into a video..."
		if %upscaler% == CUGAN (
			tools\ffmpeg.exe -i _outputs-frames/frame%%08d.png -i "%%a" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 19 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p "!model_out_folder!\%%~na.mp4"
		) else (
			tools\ffmpeg.exe -i _outputs-frames/frame%%08d.jpg -i "%%a" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 19 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p "!model_out_folder!\%%~na.mp4"
		)

		call :msg %cyan% "##### Cleaning..."
		rd /S /Q _inputs-frames > NUL 2> NUL
		rd /S /Q _outputs-frames > NUL 2> NUL

		call :msg %green% "##### Video done: %model_out_folder%\%%~na.mp4"
	)
)

pause

REM ---------------------------------------------------------------------------
REM Functions
REM ---------------------------------------------------------------------------

:msg
echo %~1%~2%color_reset%
exit /b
