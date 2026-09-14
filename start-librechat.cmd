@echo off
setlocal

echo ===================================================
echo        BharatTech - Starting LibreChat AI Service
echo ===================================================
echo.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: 1. Check if Docker CLI is installed
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not found in PATH.
    echo Please install Docker Desktop to run LibreChat.
    pause
    exit /b 1
)

:: 2. Check if Docker daemon is running
docker info >nul 2>nul
if %errorlevel% equ 0 goto start_containers

echo [INFO] Docker daemon is not running.
if not exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    echo [ERROR] Docker Desktop was not found at "C:\Program Files\Docker\Docker\Docker Desktop.exe".
    echo Please launch Docker Desktop manually and run this script again.
    pause
    exit /b 1
)

echo [INFO] Launching Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
echo [INFO] Waiting for Docker daemon to become ready...

set "WAIT_COUNT=0"

:wait_loop
timeout /t 3 /nobreak >nul
docker info >nul 2>nul
if %errorlevel% equ 0 goto start_containers

set /a WAIT_COUNT+=1
echo   Waiting for Docker engine to initialize... attempt %WAIT_COUNT% of 20
if %WAIT_COUNT% geq 20 goto docker_timeout
goto wait_loop

:docker_timeout
echo.
echo [ERROR] Docker daemon took too long to start.
echo Please ensure Docker Desktop is running and try again.
pause
exit /b 1

:start_containers
echo.
echo [INFO] Docker is active. Starting LibreChat containers...
docker compose up -d

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to start LibreChat containers.
    echo Check logs using: docker compose logs
    pause
    exit /b %errorlevel%
)

echo.
echo ===================================================
echo   LibreChat AI is running successfully!
echo   Local Web URL:  http://localhost:3080
echo   OpenID SSO:     http://localhost:3080/oauth/openid
echo ===================================================
echo.
echo To view container logs:  docker compose logs -f api
echo To stop the service:     run stop-librechat.cmd
echo.

pause
