@echo off
REM Script compile LaTeX voi debug mode - hien thi tat ca loi chi tiet
REM Chay: compile-debug.bat

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   LaTeX Compilation (DEBUG MODE)
echo ========================================
echo.
echo Log file: compile-debug.log
echo.

REM Step 1: pdflatex (lan 1)
echo [1/4] Running pdflatex (first pass)...
pdflatex -interaction=nonstopmode main.tex >> compile-debug.log 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       ✓ Success
) else (
    echo       ✗ Error detected - check compile-debug.log
)
echo.

REM Step 2: biber (process bibliography)
echo [2/4] Running biber (processing bibliography)...
biber main >> compile-debug.log 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       ✓ Success
) else (
    echo       ✗ Error detected - check compile-debug.log
)
echo.

REM Step 3: pdflatex (lan 2)
echo [3/4] Running pdflatex (second pass)...
pdflatex -interaction=nonstopmode main.tex >> compile-debug.log 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       ✓ Success
) else (
    echo       ✗ Error detected - check compile-debug.log
)
echo.

REM Step 4: pdflatex (lan 3)
echo [4/4] Running pdflatex (third pass - final update)...
pdflatex -interaction=nonstopmode main.tex >> compile-debug.log 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       ✓ Success
) else (
    echo       ✗ Error detected - check compile-debug.log
)
echo.

REM Check if PDF was created
echo ========================================
if exist main.pdf (
    echo ✓ PDF Created Successfully!
    echo   File: main.pdf
    for /F "tokens=*" %%A in ('dir /b main.pdf ^| find /c "main.pdf"') do (
        if %%A EQU 1 (
            dir main.pdf
        )
    )
) else (
    echo ✗ PDF Creation Failed!
    echo   Check compile-debug.log for errors
)
echo ========================================
echo.
echo Debug log saved to: compile-debug.log
echo.

pause
