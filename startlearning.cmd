@echo off
setlocal EnableExtensions

set "REPO_DIR=%~dp0"
set "APP_DIR=%REPO_DIR%learning-cockpit"

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

echo Starting Reliability Atlas on http://127.0.0.1:3000
echo Stop it with Ctrl+C in this window.
pushd "%APP_DIR%"
npm run dev -- --hostname 127.0.0.1 --port 3000
set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%
