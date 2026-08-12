@echo off
setlocal EnableExtensions

set "REPO_DIR=%~dp0"
set "APP_DIR=%REPO_DIR%learning-cockpit"
if not defined RELIABILITY_ATLAS_PORT set "RELIABILITY_ATLAS_PORT=3000"

echo %RELIABILITY_ATLAS_PORT%| findstr /r "^[0-9][0-9]*$" >nul || (
  echo [ERROR] RELIABILITY_ATLAS_PORT must be a numeric TCP port from 1 to 65535.
  exit /b 1
)
set /a "PORT_NUMBER=%RELIABILITY_ATLAS_PORT%" >nul 2>&1
if %PORT_NUMBER% LSS 1 (
  echo [ERROR] RELIABILITY_ATLAS_PORT must be from 1 to 65535.
  exit /b 1
)
if %PORT_NUMBER% GTR 65535 (
  echo [ERROR] RELIABILITY_ATLAS_PORT must be from 1 to 65535.
  exit /b 1
)

where node >nul 2>&1 || (
  echo [ERROR] Node.js is required. Install the version declared in learning-cockpit\package.json.
  exit /b 1
)
where npm >nul 2>&1 || (
  echo [ERROR] npm is required and was not found on PATH.
  exit /b 1
)
if not exist "%APP_DIR%\node_modules" (
  echo [ERROR] Dependencies are not installed in learning-cockpit\node_modules.
  echo         From the repo root, run: cd learning-cockpit ^&^& npm ci
  exit /b 1
)

echo Starting Reliability Atlas on http://127.0.0.1:%PORT_NUMBER%
echo Stop it with Ctrl+C in this window.
pushd "%APP_DIR%"
npm run dev -- --hostname 127.0.0.1 --port %PORT_NUMBER%
set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%
