@echo off
setlocal enabledelayedexpansion

set "folder_path=%~1"

if "%folder_path%"=="" (
    echo No folder path provided.
    echo Usage: batch_rename.bat "C:\Path\to\Your\Folder"
    exit /b
)

if not exist "%folder_path%" (
    echo Folder path does not exist.
    exit /b
)

pushd "%folder_path%"

set "extension="
set "counter=0"

for %%F in (*) do (
    if "%%~xF" neq "" (
        set /a "counter+=1"
        set "extension=%%~xF"
    )
)

setlocal enabledelayedexpansion
set "padding_length=1"

:padding
if %counter% gtr 9 (
    set /a "counter/=10"
    set /a "padding_length+=1"
    goto padding
)

set "counter=1"

for %%F in (*) do (
    if "%%~xF" neq "" (
        set "filename=%%~nF"
        set "padded_number=0000000000!counter!"
        set "padded_number=!padded_number:~-%padding_length%!"
        ren "%%F" "!padded_number!!extension!"
        set /a "counter+=1"
    )
)

endlocal
popd