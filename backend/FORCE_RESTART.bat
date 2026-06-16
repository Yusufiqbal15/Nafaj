@echo off
echo Killing all Node.js processes...
taskkill /F /IM node.exe 2>nul

echo Waiting 3 seconds...
timeout /t 3 /nobreak >nul

echo Starting backend server...
cd /d "%~dp0"
start cmd /k "npm start"

echo.
echo Backend server is starting in new window...
echo Wait for "Server running on port 5000" message
echo Then press any key here to test API...
pause

echo.
echo Testing API...
node test-order-model.js

echo.
echo If you see "Found 7 orders" above, it's working!
pause
