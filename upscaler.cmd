@echo off
REM https://github.com/nihui/realcugan-ncnn-vulkan
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

setlocal enabledelayedexpansion

REM ---------------------------------------------------------------------------
REM Constants
REM colors: https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
REM ---------------------------------------------------------------------------
set color_reset=[0m
set cyan=[96m
set green=[92m
set red=[91m
set yellow=[93m
set pre_upscaler_scale=2
set upscaler_scale=2
set pre_upscaler_on=0
set upscaler_on=0

REM ---------------------------------------------------------------------------
REM verify arguments
REM ---------------------------------------------------------------------------
if /i %pre_upscaler% NEQ None (
	if /i %pre_upscaler% NEQ CUGAN (
		if /i %pre_upscaler% NEQ ESRGAN (
			call :msg %red% "[ERROR] pre_upscaler=%pre_upscaler% - Possible values: None, CUGAN, ESRGAN (not case sensitive)"
			pause & exit
		)
	)
)
if /i %upscaler% NEQ None (
	if /i %upscaler% NEQ CUGAN (
		if /i %upscaler% NEQ ESRGAN (
			call :msg %red% "[ERROR] upscaler=%upscaler% - Possible values: CUGAN, ESRGAN (not case sensitive)"
			pause & exit
		)
	)
)
if /i %pre_upscaler% == CUGAN (
	set pre_upscaler_on=1
	if %pre_model_name% NEQ nose (
		if /i %pre_model_name% NEQ pro (
			if /i %pre_model_name% NEQ se (
				call :msg %red% "[ERROR] pre_model_name=%pre_model_name% - Possible values: nose, pro, se (case sensitive)"
				pause & exit
			)
		)
	)
)
if /i %pre_upscaler% == ESRGAN (
	set pre_upscaler_on=1
	if %pre_model_name% NEQ animevideov3 (
		if /i %pre_model_name% NEQ x4plus (
			if /i %pre_model_name% NEQ x4plus-anime (
				call :msg %red% "[ERROR] pre_model_name=%pre_model_name% - Possible values: animevideov3, x4plus, x4plus-anime (case sensitive)"
				pause & exit
			)
		)
	)
)
if /i %upscaler% == CUGAN (
	set upscaler_on=1
	if %model_name% NEQ nose (
		if /i %model_name% NEQ pro (
			if /i %model_name% NEQ se (
				call :msg %red% "[ERROR] model_name=%model_name% - Possible values: nose, pro, se (case sensitive)"
				pause & exit
			)
		)
	)
)
if /i %upscaler% == ESRGAN (
	set upscaler_on=1
	if %model_name% NEQ animevideov3 (
		if /i %model_name% NEQ x4plus (
			if /i %model_name% NEQ x4plus-anime (
				call :msg %red% "[ERROR] model_name=%model_name% - Possible values: animevideov3, x4plus, x4plus-anime (case sensitive)"
				pause & exit
			)
		)
	)
)
if /i %images_rename% NEQ on (
	if /i %images_rename% NEQ off (
		call :msg %red% "[ERROR] images_rename=%images_rename% - Possible values: on, off (not case sensitive)"
		pause & exit
	)
)
if /i %images_preresize% NEQ none (
	if /i %images_preresize% NEQ height (
		if /i %images_preresize% NEQ width (
			call :msg %red% "[ERROR] images_rename=%images_preresize% - Possible values: none, height, width (not case sensitive)"
			pause & exit
		)
	)
)
if /i %images_postresize% NEQ none (
	if /i %images_postresize% NEQ height (
		if /i %images_postresize% NEQ width (
			call :msg %red% "[ERROR] images_rename=%images_postresize% - Possible values: none, height, width (not case sensitive)"
			pause & exit
		)
	)
)
if /i %video_deinterlace% NEQ None (
	if /i %video_deinterlace% NEQ JustResize (
		if /i %video_deinterlace% NEQ QTGMC (
			if /i %video_deinterlace% NEQ Decomb (
				call :msg %red% "[ERROR] video_deinterlace=%video_deinterlace% - Possible values: None, JustResize, QTGMC, Decomb (not case sensitive)"
				pause & exit
			)
		)
	)
)
if /i %video_deinterlace_assume_mode% NEQ None (
	if /i %video_deinterlace_assume_mode% NEQ BFF (
		if /i %video_deinterlace_assume_mode% NEQ TFF (
			call :msg %red% "[ERROR] video_deinterlace_assume_mode=%video_deinterlace_assume_mode% - Possible values: None, BFF, TFF (not case sensitive)"
			pause & exit
		)
	)
)
if /i %video_deinterlace_resize_algo% NEQ None (
	if /i %video_deinterlace_resize_algo% NEQ Bilinear (
		if /i %video_deinterlace_resize_algo% NEQ Spline64 (
			call :msg %red% "[ERROR] video_deinterlace_resize_algo=%video_deinterlace_resize_algo% - Possible values: None, Bilinear, Spline64 (not case sensitive)"
			pause & exit
		)
	)
)
if /i %video_crop% NEQ None (
	if /i %video_crop% NEQ Manual (
		if /i %video_crop% NEQ Auto (
			call :msg %red% "[ERROR] video_crop=%video_crop% - Possible values: None, Auto, Manual (not case sensitive)"
			pause & exit
		)
	)
)

REM ---------------------------------------------------------------------------
REM Variables
REM ---------------------------------------------------------------------------
set mode=book
set pre_model_fullname=models-%pre_model_name%
if /i %pre_upscaler% == ESRGAN (
	if /i %pre_model_name% == animevideov3 (
		set pre_model_fullname=realesr-%pre_model_name%
	) else (
		set pre_model_fullname=realesrgan-%pre_model_name%
		set pre_upscaler_scale=4
	)
)
set model_fullname=models-%model_name%
if /i %upscaler% == ESRGAN (
	if /i %model_name% == animevideov3 (
		set model_fullname=realesr-%model_name%
	) else (
		set model_fullname=realesrgan-%model_name%
		set upscaler_scale=4
	)
)
set model_out_folder=_outputs_%model_name%
set model_out_tmp_folder=_outputs_%model_name%_tmp

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
mkdir %model_out_folder% > NUL 2> NUL

for %%a in ("_inputs\*.*") do (
	REM %%a   : relative filepath (ex: _inputs\filename.ext)
	REM %%~na : file name without extension (ex: filename)
	REM %%~xa : file extension (ex: .mkv)
	REM %%~fa : full file path (ex: D:\upscale ai\_inputs\filename.ext)

	REM Define Mode (book, image, video)
	if /i "%%~xa" == ".mkv" (
		set mode=video
	) else if /i "%%~xa" == ".mp4" (
		set mode=video
	) else if /i "%%~xa" == ".avi" (
		set mode=video
	) else if /i "%%~xa" == ".ts" (
		set mode=video
	) else if /i "%%~xa" == ".png" (
		set mode=image
	) else if /i "%%~xa" == ".jpg" (
		set mode=image
	) else if /i "%%~xa" == ".jpeg" (
		set mode=image
	) else if /i "%%~xa" == ".tif" (
		set mode=image
	) else if /i "%%~xa" == ".bmp" (
		set mode=image
	) else if /i "%%~xa" == ".webp" (
		set mode=image
	)
	call :msg %yellow% "##### [!mode!] %%~a"

	call :msg %cyan% "##### Initializing temporary folders..."
	rd /S /Q _tmp > NUL 2> NUL
	rd /S /Q _inputs_extracted > NUL 2> NUL
	rd /S /Q _inputs_resize > NUL 2> NUL
	rd /S /Q _inputs_pre_frames > NUL 2> NUL
	rd /S /Q _inputs_frames > NUL 2> NUL
	rd /S /Q _outputs_frames > NUL 2> NUL

	REM Get start time
	set "startTime=!time: =0!"

	REM ---------------------------------------------------------------------------
	REM Book
	REM ---------------------------------------------------------------------------
	if /i !mode! == book (
		mkdir _inputs_extracted  > NUL 2> NUL
		mkdir _inputs_resize  > NUL 2> NUL
		mkdir _tmp  > NUL 2> NUL
		rd /S /Q %model_out_tmp_folder% > NUL 2> NUL
		mkdir %model_out_tmp_folder% > NUL 2> NUL

		REM 1. EXTRACT
		call :msg %cyan% "##### Extracting archive..."
		tools\7-zip\7z.exe x "%%~fa" -o"_inputs_extracted" -aoa -bd > NUL 2> NUL
		call PowerShell.exe -ExecutionPolicy Bypass -File "tools\torootfolder.ps1" -SourceFilePath "%%~fa" -DestinationFolder "_inputs_extracted"
		del _inputs_extracted\*.txt /s /q /f > NUL 2> NUL
		del _inputs_extracted\*.xml /s /q /f > NUL 2> NUL
		del _inputs_extracted\*.pdf /s /q /f > NUL 2> NUL
		del _inputs_extracted\*.nfo /s /q /f > NUL 2> NUL
		del _inputs_extracted\*.sfv /s /q /f > NUL 2> NUL
		del _inputs_extracted\zzz-rip-club*.* /s /q /f > NUL 2> NUL
		del _inputs_extracted\.DS_Store /s /q /f > NUL 2> NUL

		REM 2. RENAME CRAPPY CHAR
		if /i %images_rename% == on (
			call :msg %cyan% "##### Renaming files..."
			call powershell -ExecutionPolicy Bypass -File "tools\substitutecharacters.ps1" "_inputs_extracted"
		)

		REM 3. PRE-RESIZE
		if /i %images_preresize% == height (
			call :msg %cyan% "##### Resizing initial pictures max heights to %images_preresize_height%px and converting to jpg..."
			for %%b in ("_inputs_extracted\*.*") do (
					tools\imagemagick\convert.exe -resize x%images_preresize_height% "%%~fb" "_inputs_resize\%%~nb.jpg"
			)
		) else if %images_preresize% == width (
			call :msg %cyan% "##### Resizing initial pictures max widths to %images_preresize_width%px and converting to jpg..."
			for %%b in ("_inputs_extracted\*.*") do (
					tools\imagemagick\convert.exe -resize %images_preresize_width% "%%~fb" "_inputs_resize\%%~nb.jpg"
			)
		) else (
			rd /S /Q _inputs_resize > NUL 2> NUL
			ren _inputs_extracted _inputs_resize
		)

		REM 4. PRE-UPSCALER
		if !pre_upscaler_on! == 1 (
			rd /S /Q _inputs_resize_pre > NUL 2> NUL
			ren _inputs_resize _inputs_resize_pre
			mkdir _inputs_resize
			call :msg %cyan% "##### Pre-upscaling with [%upscaler%][!pre_model_fullname!] pictures..."
			if /i %pre_upscaler% == CUGAN (
				tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -i _inputs_resize_pre -o _inputs_resize -m !pre_model_fullname! -n 0
			) else if /i %pre_upscaler% == ESRGAN (
				tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -i _inputs_resize_pre -o _inputs_resize -n !pre_model_fullname! -s !pre_upscaler_scale!
			)
			REM 4.1. Convert all non-JPG images to JPG with 100% quality
			for %%f in ("_inputs_resize\*.*") do (
				if /I not "%%~xf"==".jpg" (
					tools\imagemagick\convert "%%f" -quality 100 "_inputs_resize\%%~nf.jpg"
					del "%%f"
				)
			)
			REM 4.2. RESIZE DOWN
			if !pre_upscaler_scale! == 4 (
				call :msg %cyan% "##### Resize pictures from 4X to 2X..."
				tools\imagemagick\mogrify.exe -resize 25%% _inputs_resize\*.jpg
			) else (
				call :msg %cyan% "##### Resize pictures from 2X to 1X..."
				tools\imagemagick\mogrify.exe -resize 50%% _inputs_resize\*.jpg
			)
		)
		
		REM 5. UPSCALER
		if !upscaler_on! == 1 (
			call :msg %cyan% "##### Upscaling with [%upscaler%][!model_fullname!] pictures..."
			if /i %upscaler% == CUGAN (
				tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -i _inputs_resize -o _tmp -m !model_fullname! -n 0
			) else (
				tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -i _inputs_resize -o _tmp -n !model_fullname! -s !upscaler_scale!
			)
			REM 5.1. Convert all non-JPG images to JPG with 100% quality
			for %%f in ("_tmp\*.*") do (
				if /I not "%%~xf"==".jpg" (
					tools\imagemagick\convert "%%f" -quality 100 "_tmp\%%~nf.jpg"
					del "%%f"
				)
			)
		)

		REM 6. POST-RESIZE
		if /i %images_postresize% == height (
			call :msg %cyan% "##### Resizing initial pictures max heights to %images_postresize_height%px and converting to jpg..."
			for %%b in ("_tmp\*.jpg") do (
				tools\imagemagick\convert.exe -resize x%images_postresize_height% "%%~fb" "%model_out_tmp_folder%\%%~nb.jpg"
			)
		) else if /i %images_postresize% == width (
			call :msg %cyan% "##### Resizing initial pictures max widths to %images_postresize_width%px and converting to jpg..."
			for %%b in ("_tmp\*.jpg") do (
				tools\imagemagick\convert.exe -resize %images_postresize_width% "%%~fb" "%model_out_tmp_folder%\%%~nb.jpg"
			)
		) else (
			rd /S /Q "%model_out_tmp_folder%" > NUL 2> NUL
			ren _tmp "%model_out_tmp_folder%"
		)

		REM 7. RENAME
		if /i %images_rename% == on (
			call :msg %cyan% "##### Renumbering files with padding..."
			cd %model_out_tmp_folder% && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "tools\padfilenames.ps1" -FolderPath "%model_out_tmp_folder%"
		)

		REM 8. CBZ
		call :msg %cyan% "##### Creating cbz..."
		cd %model_out_tmp_folder% && cd .. && cd %model_out_folder% && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "tools\zip.ps1" -SourceFolder "%model_out_tmp_folder%" -DestinationFilePath "%model_out_folder%\%%~na [ia-%model_name%].cbz"

		REM 9. CLEAN
		call :msg %cyan% "##### Cleaning..."
		rd /S /Q _inputs_extracted > NUL 2> NUL
		rd /S /Q _inputs_resize > NUL 2> NUL
		rd /S /Q _tmp > NUL 2> NUL
		rd /S /Q %model_out_tmp_folder% > NUL 2> NUL

		call :msg %green% "##### Book done: %model_out_folder%\%%~na [ia-%model_name%].cbz"
	)

	REM ---------------------------------------------------------------------------
	REM Video
	REM ---------------------------------------------------------------------------
	if /i !mode! == video (
		mkdir _inputs_frames  > NUL 2> NUL
		mkdir _outputs_frames  > NUL 2> NUL

		if /i %video_deinterlace% NEQ None (
			REM 1. DEINTERLACE
			call :msg %cyan% "##### Creating Avisynth script for deinterlacing..."
			call powershell -ExecutionPolicy Bypass -File "tools\createdeinterlace-avs.ps1" -filepath  "%%a" -mode %video_deinterlace% -assumeMode %video_deinterlace_assume_mode% -resizeAlgo %video_deinterlace_resize_algo% -x %video_deinterlace_resize_x% -y %video_deinterlace_resize_y% -crop %video_crop% -cropTop %video_crop_top% -cropBottom %video_crop_bottom% -cropLeft %video_crop_left% -cropRight %video_crop_right% 
			REM 2. EXTRACT IMAGES
			call :msg %cyan% "##### Extracting images with AviSynth from %%a ..."
			tools\ffmpeg.exe -i deinterlace.avs -qscale:v 1 -qmin 1 -qmax 1 -pix_fmt yuv420p -r 25 -strict experimental _inputs_frames/frame%%08d.jpg
		) else (
			REM 2. EXTRACT IMAGES
			call :msg %cyan% "##### Extracting images from %%a ..."
			tools\ffmpeg.exe -i "%%a" -qscale:v 1 -qmin 1 -qmax 1 -pix_fmt yuv420p -r 25 -strict experimental _inputs_frames/frame%%08d.jpg
		)

		REM 3. CLEAN
		call :msg %cyan% "##### Deleting temporary files..."
		del /f /q deinterlace.avs
		del /f /q "%%a.ffindex"

		REM 4. PRE-UPSCALER
		if !pre_upscaler_on! == 1 (
			rd /S /Q _inputs_pre_frames > NUL 2> NUL
			ren _inputs_frames _inputs_pre_frames
			mkdir _inputs_frames
			call :msg %cyan% "##### Pre-upscaling with [%pre_upscaler%][!pre_model_fullname!] images..."
			if /i %pre_upscaler% == CUGAN (
				tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -i _inputs_pre_frames -o _inputs_frames -m %pre_model_fullname% -n 0 -j %load_proc_save%
			) else if /i %pre_upscaler% == ESRGAN (
				tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -i _inputs_pre_frames -o _inputs_frames -n %pre_model_fullname% -s !pre_upscaler_scale! -j %load_proc_save%
			)
			REM 4.1. Convert all non-JPG images to JPG with 100% quality
			for %%f in ("_inputs_frames\*.*") do (
				if /I not "%%~xf"==".jpg" (
					tools\imagemagick\convert "%%f" -quality 100 "_inputs_frames\%%~nf.jpg"
					del "%%f"
				)
			)
			REM 4.2. RESIZE DOWN
			if !post_upscaler_scale! == 4 (
				call :msg %cyan% "##### Resize pictures from 4X to 1X..."
				tools\imagemagick\mogrify.exe -resize 25%% _inputs_frames\*.jpg
			) else (
				call :msg %cyan% "##### Resize pictures from 2X to 1X..."
				tools\imagemagick\mogrify.exe -resize 50%% _inputs_frames\*.jpg
			)
		)

		REM 5. UPSCALER
		if !upscaler_on! == 1 (
			call :msg %cyan% "##### Upscaling with [%upscaler%][!model_fullname!] images..."
			if /i %upscaler% == CUGAN (
				tools\realcugan-ncnn-vulkan\realcugan-ncnn-vulkan.exe -x -i _inputs_frames -o _outputs_frames -m %model_fullname% -n 0 -j %load_proc_save%
			) else (
				tools\realesrgan-ncnn-vulkan\realesrgan-ncnn-vulkan.exe -x -i _inputs_frames -o _outputs_frames -n %model_fullname% -s !upscaler_scale! -j %load_proc_save%
			)
			REM 5.1. Convert all non-JPG images to JPG with 100% quality
			for %%f in ("_outputs_frames\*.*") do (
				if /I not "%%~xf"==".jpg" (
					tools\imagemagick\convert "%%f" -quality 100 "_outputs_frames\%%~nf.jpg"
					del "%%f"
				)
			)
		)

		REM 6. JOIN TO VIDEO
		call :msg %cyan% "##### Joining upscaled images into a video..."
		tools\ffmpeg.exe -i _outputs_frames/frame%%08d.jpg -i "%%a" -vf "scale=in_range=full:out_range=full" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq %video_encoder_quality% -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p -color_range pc -colorspace smpte170m -color_primaries smpte170m -color_trc iec61966_2_1 -g 25 -keyint_min 25 "!model_out_folder!\%%~na.mp4"
		REM alternative config to keep colors: -pix_fmt rgb24 -color_range pc -colorspace bt709 -color_primaries bt709 -color_trc iec61966_2_1

		REM tools\ffmpeg.exe -i _outputs_frames/frame%%08d.jpg -i "%%a" -vf "scale=in_range=full:out_range=full" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 15 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p -color_range pc -colorspace smpte170m -color_primaries smpte170m -color_trc iec61966_2_1 -g 25 -keyint_min 25 "!model_out_folder!\%%~na.15.mp4"
		REM tools\ffmpeg.exe -i _outputs_frames/frame%%08d.jpg -i "%%a" -vf "scale=in_range=full:out_range=full" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 19 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p -color_range pc -colorspace smpte170m -color_primaries smpte170m -color_trc iec61966_2_1 -g 25 -keyint_min 25 "!model_out_folder!\%%~na.19.mp4"
		REM tools\ffmpeg.exe -i _outputs_frames/frame%%08d.jpg -i "%%a" -vf "scale=in_range=full:out_range=full" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 25 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p -color_range pc -colorspace smpte170m -color_primaries smpte170m -color_trc iec61966_2_1 -g 25 -keyint_min 25 "!model_out_folder!\%%~na.25.mp4"
		REM tools\ffmpeg.exe -i _outputs_frames/frame%%08d.jpg -i "%%a" -vf "scale=in_range=full:out_range=full" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 30 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p -color_range pc -colorspace smpte170m -color_primaries smpte170m -color_trc iec61966_2_1 -g 25 -keyint_min 25 "!model_out_folder!\%%~na.30.mp4"
		REM tools\ffmpeg.exe -i _outputs_frames/frame%%08d.jpg -i "%%a" -vf "scale=in_range=full:out_range=full" -map 0:v:0 -map 1:a:0 -c:a copy -c:v hevc_nvenc -preset p7 -tune hq -rc vbr -cq 35 -qmin 1 -qmax 51 -b:v 0 -r 25 -pix_fmt yuv420p -color_range pc -colorspace smpte170m -color_primaries smpte170m -color_trc iec61966_2_1 -g 25 -keyint_min 25 "!model_out_folder!\%%~na.35.mp4"


		REM 7. CLEAN
		call :msg %cyan% "##### Cleaning..."
		rd /S /Q _inputs_pre_frames > NUL 2> NUL
		rd /S /Q _inputs_frames > NUL 2> NUL
		rd /S /Q _outputs_frames > NUL 2> NUL

		call :msg %green% "##### Video done: %model_out_folder%\%%~na.mp4"
	)
	
	REM Elapsed time
	set "endTime=!time: =0!"
	set "end=!endTime:%time:~8,1%=%%100)*100+1!"  
	set "start=!startTime:%time:~8,1%=%%100)*100+1!"
	set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"
	set /A "cc=elap%%100+100, elap/=100, ss=elap%%60+100, elap/=60, mm=elap%%60+100, hh=elap/60+100"
	set "formattedTime=!hh:~1!h!mm:~1!min!ss:~1!s!cc:~1!ms"
	call :msg %green% "##### Upscaled in: !formattedTime!"
)

pause

REM ---------------------------------------------------------------------------
REM Functions
REM ---------------------------------------------------------------------------

:msg
echo %~1%~2%color_reset%
exit /b
