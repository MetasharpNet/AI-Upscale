@echo off

REM CUGAN, ESRGAN
set upscaler=CUGAN
REM CUGAN: nose, pro, se
REM ESRGAN: animevideov3, x4plus, x4plus-anime
set model_name=nose
REM on, off
set images_rename=off
REM height, width
set images_resize=height
set images_resize_height=2500
set images_resize_width=1738
REM QTGMC, Decomb, JustResize
set video_deinterlace=QTGMC
REM None, BFF for VHS, TFF for DVD
set video_deinterlace_assume_mode=TFF
REM None, Bilinear, Spline64 for a small sharpening
set video_deinterlace_resize_algo=Spline64
REM specific height
set video_deinterlace_resize_x=0
REM specific width
set video_deinterlace_resize_y=0

call "upscaler.cmd"
