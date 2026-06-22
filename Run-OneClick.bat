@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Test-RemoteWorkReadiness.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo Remote Work Readiness Test finished with exit code %RC%.
pause
exit /b %RC%
