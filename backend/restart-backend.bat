@echo off
echo.
echo ================================================
echo   BACKEND RESTART SCRIPT
echo ================================================
echo.

echo Step 1: Stopping Node processes...
taskkill /F /IM node.exe >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo    Done: Node processes stopped
) else (
    echo    Info: No Node processes were running
)

echo.
echo Step 2: Waiting...
timeout /t 2 /nobreak >nul
echo    Done: Ready to start

echo.
echo Step 3: Starting backend server...
echo.
echo ================================================
echo   BACKEND SERVER STARTING
echo ================================================
echo.

node src\server.js
