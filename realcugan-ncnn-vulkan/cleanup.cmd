@echo off

echo clean inputs folder content + tmp/outputs folders
del _inputs\*.* /s /q /f > NUL 2> NUL
rd /S /Q _outputs-nose
rd /S /Q _outputs-pro
rd /S /Q _outputs-se
rd /S /Q _tmp
