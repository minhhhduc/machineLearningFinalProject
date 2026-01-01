@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ========================================
echo   AUTO COMPILE LaTeX
echo ========================================
echo.
echo Monitoring all .tex and .bib files...
echo Press Ctrl+C to STOP
echo.

set "PREV_HASH=first_run"

:monitor_loop
REM Get current hash of all .tex and .bib files using PowerShell
for /f "delims=" %%H in ('powershell -NoProfile -Command "$files = Get-ChildItem -Recurse -Include *.tex,*.bib -ErrorAction SilentlyContinue; ($files | ForEach-Object { $_.LastWriteTime.Ticks }) -join ','"') do (
    set "CURR_HASH=%%H"
)

REM Compare hashes
if "!PREV_HASH!"=="first_run" (
    echo [%date% %time%] First run - setting baseline...
    set "PREV_HASH=!CURR_HASH!"
) else if not "!CURR_HASH!"=="!PREV_HASH!" (
    echo.
    echo [%date% %time%] Files changed - waiting 3 seconds...
    timeout /t 3 /nobreak > nul
    
    echo [%date% %time%] Compiling...
    
    pdflatex -interaction=nonstopmode main.tex > nul 2>&1
    biber main > nul 2>&1
    pdflatex -interaction=nonstopmode main.tex > nul 2>&1
    
    if exist main.pdf (
        echo [%date% %time%] Compile successful
    ) else (
        echo [%date% %time%] Compile failed
    )
    
    REM Update hash after compile
    for /f "delims=" %%H in ('powershell -NoProfile -Command "$files = Get-ChildItem -Recurse -Include *.tex,*.bib -ErrorAction SilentlyContinue; ($files | ForEach-Object { $_.LastWriteTime.Ticks }) -join ','"') do (
        set "PREV_HASH=%%H"
    )
) else (
    echo [%date% %time%] No changes
)

timeout /t 3 /nobreak > nul
goto monitor_loop




