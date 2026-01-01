@echo off
REM Auto-compile LaTeX file - Check every 10 seconds for changes
REM Chạy: auto_compile.bat từ thư mục chứa main.tex

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ========================================
echo   AUTO COMPILE LaTeX - Smart Monitor
echo ========================================
echo.
echo Compile folder: %cd%
echo Checking for changes every 10 seconds...
echo Press Ctrl+C to stop
echo.

REM Initialize previous modification times
set "PREV_MAIN_TIME=0"
set "PREV_BIB_TIME=0"

:monitor_loop
REM Wait 10 seconds
timeout /t 10 /nobreak > nul

REM Get current file modification times
for /f %%A in ('powershell -NoProfile -Command "[int64](Get-Item main.tex).LastWriteTime.Ticks"') do (
    set "CURR_MAIN_TIME=%%A"
)

for /f %%A in ('powershell -NoProfile -Command "[int64](Get-Item thesis.bib).LastWriteTime.Ticks"') do (
    set "CURR_BIB_TIME=%%A"
)

REM Check if any file has changed
set "FILES_CHANGED=0"

if !PREV_MAIN_TIME! equ 0 (
    set "FILES_CHANGED=1"
) else (
    if not !PREV_MAIN_TIME! equ !CURR_MAIN_TIME! (
        set "FILES_CHANGED=1"
    )
    if not !PREV_BIB_TIME! equ !CURR_BIB_TIME! (
        set "FILES_CHANGED=1"
    )
)

REM If files changed, compile
if !FILES_CHANGED! equ 1 (
    echo.
    echo [%date% %time%] Files changed - Compiling...
    echo.

    REM Run pdflatex compilation
    pdflatex -interaction=nonstopmode main.tex > nul 2>&1

    REM Check if .bib file has been modified
    set BIB_MODIFIED=0

    if not exist main.bbl (
        set BIB_MODIFIED=1
    ) else (
        for /f %%A in ('powershell -NoProfile -Command "if((Get-Item thesis.bib).LastWriteTime -gt (Get-Item main.bbl).LastWriteTime) {echo 1} else {echo 0}"') do (
            set BIB_MODIFIED=%%A
        )
    )

    REM Run biber only if .bib file has changed
    if !BIB_MODIFIED! equ 1 (
        echo [%date% %time%] Bibliography updated - running biber...
        biber main > nul 2>&1
        
        REM Run pdflatex again to update references
        pdflatex -interaction=nonstopmode main.tex > nul 2>&1
    ) else (
        echo [%date% %time%] Bibliography unchanged - skipped biber
    )

    REM Check if PDF was created successfully
    if exist main.pdf (
        echo [%date% %time%] ✓ Compile successful - main.pdf updated
    ) else (
        echo [%date% %time%] ✗ Compile failed
    )
) else (
    echo [%date% %time%] No changes detected
)

REM Update previous times
set "PREV_MAIN_TIME=!CURR_MAIN_TIME!"
set "PREV_BIB_TIME=!CURR_BIB_TIME!"

goto monitor_loop
