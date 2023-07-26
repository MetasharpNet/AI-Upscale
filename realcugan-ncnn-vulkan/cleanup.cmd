@echo off

echo clean inputs folder content + tmp/outputs folders
del _inputs\*.* /s /q /f > NUL 2> NUL
rd /S /Q _inputs-extracted
rd /S /Q _inputs-resize
rd /S /Q _tmp
rd /S /Q _outputs-nose
rd /S /Q _outputs-nose-cbz
rd /S /Q _outputs-pro
rd /S /Q _outputs-pro-cbz
rd /S /Q _outputs-se
rd /S /Q _outputs-se-cbz
rd /S /Q _outputs-rescale
