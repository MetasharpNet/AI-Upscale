@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

REM variables
set model_name=x4plus
set model_fullname=realesrgan-%model_name%
set model_info="[%model_fullname%]"
set target_height=2500
set model_out_folder=_outputs-gan-%model_name%
set model_cbz_folder=_outputs-gan-%model_name%-cbz

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
mkdir %model_cbz_folder% > NUL 2> NUL

for %%a in ("_inputs\*.*") do (
	REM %%a   : relative filepath (ex: _inputs\filename.ext)
	REM %%~na : file name without extension (ex: filename)
	REM %%~fa : full file path (ex: D:\upscale ai\_inputs\filename.ext)

	call :msg %cyan% "temp folders initializing..."
	rd /S /Q _inputs-extracted > NUL 2> NUL
	mkdir _inputs-extracted  > NUL 2> NUL
	rd /S /Q _inputs-resize > NUL 2> NUL
	mkdir _inputs-resize  > NUL 2> NUL
	rd /S /Q _tmp > NUL 2> NUL
	mkdir _tmp  > NUL 2> NUL
	rd /S /Q %model_out_folder% > NUL 2> NUL
	mkdir %model_out_folder% > NUL 2> NUL

	call :msg %cyan% "extract archive"
	7-zip\7z.exe x "%%~fa" -o"_inputs-extracted" -aoa -bd > NUL 2> NUL
	call PowerShell.exe -ExecutionPolicy Bypass -File "torootfolder.ps1" -SourceFilePath "%%~fa" -DestinationFolder "_inputs-extracted"
	del _inputs-extracted\*.txt /s /q /f > NUL 2> NUL
	del _inputs-extracted\*.xml /s /q /f > NUL 2> NUL
	del _inputs-extracted\*.pdf /s /q /f > NUL 2> NUL
	del _inputs-extracted\*.nfo /s /q /f > NUL 2> NUL
	del _inputs-extracted\zzz-rip-club*.* /s /q /f > NUL 2> NUL
	
	call :msg %cyan% "downsize initial pictures heights to %target_height%px..."
	for %%b in ("_inputs-extracted\*.*") do (
	   call scale.bat -source "%%~fb" -target "_inputs-resize\%%~nb.jpg" -max-height %target_height% -keep-ratio yes -force yes
	)

	call :msg %cyan% "apply AI model [] to pictures..."
	realesrgan-ncnn-vulkan.exe -x -f png -i _inputs-resize -o _tmp -n %model_fullname%

	call :msg %cyan% "resizing and converting to jpg..."
	for %%b in ("_tmp\*.png") do (
	   call scale.bat -source "%%~fb" -target "%model_out_folder%\%%~nb.jpg" -max-height %target_height% -keep-ratio yes -force yes
	)

	call :msg %cyan% "renumbering files with padding..."
	cd %model_out_folder% && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "%model_out_folder%"

	call :msg %cyan% "creating cbz..."
	cd %model_out_folder% && cd .. && cd %model_cbz_folder% && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "zip.ps1" -SourceFolder "%model_out_folder%" -DestinationFilePath "%model_cbz_folder%\%%~na.cbz"

)

call :msg %cyan% "deleting temp folders..."
rd /S /Q _inputs-extracted > NUL 2> NUL
rd /S /Q _inputs-resize > NUL 2> NUL
rd /S /Q _tmp > NUL 2> NUL
rd /S /Q %model_out_folder% > NUL 2> NUL

pause

REM ---------------------------------------------------------------------------

REM Functions

:msg
echo %~1%~2%color_reset%
exit /b