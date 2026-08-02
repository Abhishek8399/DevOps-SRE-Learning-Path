@echo off
setlocal
cd /d "%~dp0"

where npm.cmd >nul 2>nul
if errorlevel 1 (
  echo Node.js and npm were not found on PATH.
  echo Install Node.js 22.13 or newer, then run this file again.
  pause
  exit /b 1
)

if not exist "node_modules\next\package.json" (
  echo Installing the exact dependencies from package-lock.json...
  call npm.cmd ci
  if errorlevel 1 (
    echo Dependency installation failed. Review the output above.
    pause
    exit /b 1
  )
)

start "" powershell.exe -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Start-Process 'http://127.0.0.1:3000'"
echo Learning cockpit: http://127.0.0.1:3000
echo Keep this window open. Press Ctrl+C to stop the local server.
call npm.cmd run dev -- --hostname 127.0.0.1
