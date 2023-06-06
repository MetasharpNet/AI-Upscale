@echo off

echo clean inputs folder content + tmp/outputs folders
del _inputs\*.* /s /q /f > NUL 2> NUL
rd /S /Q _outputs-animevideov3
rd /S /Q _outputs-gan-x4plus
rd /S /Q _outputs-gan-x4plus-anime
rd /S /Q _tmp
