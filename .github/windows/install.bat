@echo off
setlocal enabledelayedexpansion
title Apollo - Installer
color 0B

echo.
echo ================================================================
echo               Apollo - Auto Installer
echo ================================================================
echo.

where py >nul 2>nul
if errorlevel 1 (
    echo [error] python launcher not found.
    echo please install python 3.11 from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [step 1] checking python 3.11...
py -3.11 --version >nul 2>nul
if errorlevel 1 (
    echo [error] python 3.11 is not installed.
    echo please install python 3.11 from https://www.python.org/downloads/release/python-3119/
    pause
    exit /b 1
)
echo [ok] python 3.11 detected.
echo.

if exist venv311 (
    echo [step 2] virtual environment already exists. skipping creation.
) else (
    echo [step 2] creating virtual environment venv311...
    py -3.11 -m venv venv311
    if errorlevel 1 (
        echo [error] failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [ok] virtual environment created.
)
echo.

echo [step 3] activating virtual environment...
call venv311\Scripts\activate.bat
if errorlevel 1 (
    echo [error] failed to activate virtual environment.
    pause
    exit /b 1
)
echo [ok] virtual environment activated.
echo.

echo [step 4] upgrading pip...
python -m pip install --upgrade pip
echo.

echo [step 5] installing required packages from requirements.txt...
pip install -r requirements.txt
if errorlevel 1 (
    echo [error] failed to install packages.
    pause
    exit 