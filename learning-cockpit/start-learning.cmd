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

powershell.exe -NoProfile -Command "if (Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction SilentlyContinue) { exit 1 }"
if errorlevel 1 (
  echo Port 3000 is already in use, so the learning cockpit was not started.
  echo Stop the process listening on port 3000, then run this file again.
  pause
  exit /b 1
)

start "" powershell.exe -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Start-Process 'http://127.0.0.1:3000'"
echo Learning cockpit: http://127.0.0.1:3000
echo Keep this window open. Press Ctrl+C to stop the local server.
call npm.cmd run dev -- --hostname 127.0.0.1 --port 3000
