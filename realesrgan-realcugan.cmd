@echo off

REM None, CUGAN, ESRGAN
set pre_upscaler=ESRGAN
set upscaler=CUGAN
REM CUGAN: nose, pro, se
REM ESRGAN: animevideov3, x4plus, x4plus-anime
set pre_model_name=animevideov3
set model_name=nose
REM on, off
set images_rename=on
REM height, width
set images_resize=height
set images_resize_height=2500
set images_resize_width=1738
REM None, QTGMC, Decomb, JustResize
set video_deinterlace=QTGMC
REM None, BFF for VHS, TFF for DVD
set video_deinterlace_assume_mode=TFF
REM None, Bilinear, Spline64 for a small sharpening
set video_deinterlace_resize_algo=Spline64
REM specific height
set video_deinterlace_resize_x=0
REM specific width
set video_deinterlace_resize_y=0
REM thread count for load:proc:save (default="1:2:2")
set load_proc_save="1:2:2"
REM 19 is pretty high
set video_encoder_quality=19
REM None,Auto,Manual
set video_crop=Auto
set video_crop_top=0
set video_crop_left=0
set video_crop_bottom=0
set video_crop_right=0

call "upscaler.cmd"
