@echo off
setlocal enabledelayedexpansion

set "MAGICK=C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"
set "IMAGES_DIR=c:\Users\cukormegtej\Documents\momecodingclass\mrmettyou.github.io\IMAGES"
set count=0
set total_orig=0
set total_opt=0

echo Optimizing images with ImageMagick...

for /r "%IMAGES_DIR%" %%F in (*.jpg *.jpeg *.png *.gif) do (
    set "file=%%F"
    set "temp_file=%%F.tmp"
    
    REM Get original file size
    for %%A in ("!file!") do set "orig_size=%%~zA"
    
    REM Convert with quality reduction
    "%MAGICK%" "!file!" -quality 85 "!temp_file!" >nul 2>&1
    
    if exist "!temp_file!" (
        REM Get new file size
        for %%A in ("!temp_file!") do set "new_size=%%~zA"
        
        REM Replace original with optimized
        del /q "!file!" >nul 2>&1
        move /y "!temp_file!" "!file!" >nul 2>&1
        
        set /a count+=1
        set /a total_orig+=!orig_size!
        set /a total_opt+=!new_size!
        
        REM Progress indicator
        set /a mod=!count! %% 50
        if !mod! equ 0 (
            echo Processed !count! images...
        )
    )
)

echo.
echo === Optimization Complete ===
echo Total images optimized: !count!
echo Original total size: !total_orig! bytes
echo Optimized total size: !total_opt! bytes
set /a saved=!total_orig! - !total_opt!
echo Space saved: !saved! bytes

