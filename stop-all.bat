@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

echo [INFO] Stopping AI Engine (Frontend/Backend)

REM === First, try to close windows by exact title (gentle approach) ===
echo [INFO] Attempting to close windows gracefully...
for %%T in ("AI-ENGINE (Frontend)" "AI-ENGINE (Backend)") do (
  echo [INFO] Closing window: %%~T
  taskkill /FI "WINDOWTITLE eq %%~T" /T /F >nul 2>&1
)

REM === Give processes time to shut down gracefully ===
timeout /t 3 >nul

REM === Kill processes by specific ports (more reliable) ===
echo [INFO] Killing processes by port...
for %%P in (8080 8000) do (
  echo [INFO] Checking port %%P...
  for /f "tokens=5" %%I in ('netstat -ano ^| findstr /r ":%%P.*LISTENING" 2^>nul') do (
    if not "%%I"=="" (
      echo [INFO] Killing process on port %%P (PID=%%I)
      taskkill /PID %%I /T /F >nul 2>&1
      if !ERRORLEVEL! equ 0 (
        echo [INFO] Successfully terminated PID %%I
      ) else (
        echo [WARN] Failed to terminate PID %%I
      )
    )
  )
)

REM === Kill any remaining AI Engine related processes ===
echo [INFO] Cleaning up remaining processes...

REM Directly kill processes listening on our ports
echo [INFO] Force killing processes on ports 8000 and 8080...
for %%P in (8000 8080) do (
  for /f "tokens=5" %%I in ('netstat -ano ^| findstr ":%%P" ^| findstr "LISTENING"') do (
    if not "%%I"=="" (
      echo [INFO] Force killing PID %%I listening on port %%P
      taskkill /PID %%I /F >nul 2>&1
    )
  )
)

REM === Final verification ===
timeout /t 2 >nul
echo [INFO] Verifying services are stopped...

set SERVICES_STOPPED=1
for %%P in (8080 8000) do (
  for /f "tokens=5" %%I in ('netstat -ano ^| findstr /r ":%%P\>.*LISTENING" 2^>nul') do (
    if not "%%I"=="" (
      echo [WARN] Port %%P is still in use by PID %%I
      set SERVICES_STOPPED=0
    )
  )
)

if %SERVICES_STOPPED% equ 1 (
  echo [INFO] All services stopped successfully.
) else (
  echo [WARN] Some services may still be running. Check manually if needed.
)

echo [INFO] Done. You can re-run start-all.bat to start services again.
endlocal
exit /b 0
