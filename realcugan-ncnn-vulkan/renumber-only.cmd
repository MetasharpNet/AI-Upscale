@echo off
REM https://github.com/xinntao/Real-ESRGAN
REM https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/imageProcessing/scale.bat

echo renumbering files with padding...
cd _outputs-nose && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-nose"
cd _outputs-pro && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-pro"
cd __outputs-se && cd .. && call PowerShell.exe -ExecutionPolicy Bypass -File "padfilenames.ps1" -FolderPath "_outputs-se"
echo deleting temporary folder...
rd /S /Q _inputs-resize
rd /S /Q _tmp
