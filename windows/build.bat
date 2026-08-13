@echo off
setlocal enabledelayedexpansion
title Apollo - Build EXE
color 0B

echo.
echo ================================================================
echo               Apollo - Building EXE
echo ================================================================
echo.

if not exist venv311\Scripts\activate.bat (
    echo [error] virtual environment not found.
    echo run install.bat first.
    pause
    exit /b 1
)

call venv311\Scripts\activate.bat

echo [step 1] cleaning previous build...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
echo [ok] cleaned.
echo.

echo [step 2] building exe with pyinstaller...
python -m PyInstaller build_exe.spec --noconfirm
if errorlevel 1 (
    echo [error] pyinstaller build failed.
    pause
    exit /b 1
)
echo [ok] exe built successfully.
echo.

echo [step 3] copying required files to dist...
if exist apollo.ico copy /y apollo.ico dist\Apollo\
if exist ffmpeg.exe copy /y ffmpeg.exe dist\Apollo\
echo [ok] files copied.
echo.

echo ================================================================
echo   build complete!
echo   output folder: dist\Apollo\
echo   main exe: dist\Apollo\Apollo.exe
echo ================================================================
echo.
pause