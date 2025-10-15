@echo off
setlocal ENABLEDELAYEDEXPANSION
chcp 65001 >nul

REM === Paths ===
set ROOT=%~dp0
set AI_ENGINE=%ROOT%ai-engine
set FRONTEND=%ROOT%ai-engine-frontend
set FRONTEND_JAR=%FRONTEND%\target\ai-engine-frontend-0.0.1-SNAPSHOT-exec.jar
REM Try to find Maven automatically or use environment variable
set MAVEN_BIN=
if defined MAVEN_HOME (
  set MAVEN_BIN=%MAVEN_HOME%\bin\mvn.cmd
) else (
  REM Try to find mvn in PATH first
  where mvn.cmd >nul 2>&1
  if %ERRORLEVEL% equ 0 (
    set MAVEN_BIN=mvn.cmd
    goto :maven_found
  )
  REM Try common Maven installation paths relative to system drives
  for %%D in (C: D: E:) do (
    for %%P in ("%%D\maven\apache-maven-*\bin\mvn.cmd" "%%D\Program Files\Apache\Maven\bin\mvn.cmd" "%%D\tools\apache-maven\bin\mvn.cmd") do (
      if exist "%%~P" (
        set MAVEN_BIN=%%~P
        goto :maven_found
      )
    )
  )
)
:maven_found
set MVNW=%FRONTEND%\mvnw.cmd
set PYTHON=%AI_ENGINE%\.venv\Scripts\python.exe
set UVICORN_APP=app.main:app
set OLLAMA_EXE=
REM Try to find Ollama automatically
where ollama.exe >nul 2>&1
if %ERRORLEVEL% equ 0 (
  set OLLAMA_EXE=ollama.exe
) else (
  REM Try common Ollama installation path
  set OLLAMA_EXE=%USERPROFILE%\AppData\Local\Programs\Ollama\ollama.exe
)

REM === Check Ollama ===
if exist "%OLLAMA_EXE%" (
  echo [INFO] Ollama found: %OLLAMA_EXE%
) else (
  echo [WARN] Ollama not found at %OLLAMA_EXE%
  echo        請安裝或調整 OLLAMA_EXE 路徑。
)

REM === Start Backend (FastAPI) ===
if exist "%PYTHON%" (
  echo [INFO] Starting backend...
  start "AI-ENGINE (Backend)" cmd /k "cd /d %AI_ENGINE% && call .venv\Scripts\activate && python -m uvicorn %UVICORN_APP% --host 127.0.0.1 --port 8000"
) else (
  echo [ERROR] Python venv not found at %PYTHON%
  echo         請先在 ai-engine 建立虛擬環境並安裝依賴。
  goto :EOF
)

REM === Wait for Backend health ===
set /a RETRIES=20
:wait_backend
  powershell -NoProfile -Command "try { $r = Invoke-WebRequest -Uri http://127.0.0.1:8000/healthz -UseBasicParsing; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { Start-Sleep -Seconds 1; exit 1 }"
  if %ERRORLEVEL% equ 0 (
    echo [INFO] Backend is up.
  ) else (
    set /a RETRIES-=1
    if !RETRIES! gtr 0 (
      timeout /t 1 >nul
      goto :wait_backend
    ) else (
      echo [WARN] Backend health check timed out, continue to start frontend.
    )
  )

REM === Start Frontend (Spring Boot) ===
if not exist "%FRONTEND_JAR%" (
  echo [INFO] Frontend JAR not found, building package...
  REM Set Java 21 environment for building
  set BUILD_JAVA_HOME=
  if exist "C:\Program Files\Java\openjdk-21\bin\java.exe" (
    set BUILD_JAVA_HOME=C:\Program Files\Java\openjdk-21
    echo [INFO] Using Java 21 for building
  )
  
  if exist "%MVNW%" (
    pushd "%FRONTEND%"
    if defined BUILD_JAVA_HOME (
      set JAVA_HOME=%BUILD_JAVA_HOME%
    )
    call mvnw.cmd -q -DskipTests package
    popd
  ) else if exist "%MAVEN_BIN%" (
    pushd "%FRONTEND%"
    if defined BUILD_JAVA_HOME (
      set JAVA_HOME=%BUILD_JAVA_HOME%
    )
    call "%MAVEN_BIN%" -q -DskipTests package
    popd
  ) else (
    echo [ERROR] 無法建置前端：Maven Wrapper 與 Maven 都不可用。
    echo         請確保 MAVEN_HOME 環境變數已設定，或將 Maven 安裝在：
    echo         - [磁碟機]:\maven\apache-maven-*\bin\mvn.cmd
    echo         - [磁碟機]:\Program Files\Apache\Maven\bin\mvn.cmd
    echo         - [磁碟機]:\tools\apache-maven\bin\mvn.cmd
    echo         或將 Maven 加入 PATH 環境變數中
  )
)

if exist "%FRONTEND_JAR%" (
  echo [INFO] Starting frontend with JAR...
  REM Try to use Java 21 if available, otherwise use system Java
  if exist "C:\Program Files\Java\openjdk-21\bin\java.exe" (
    echo [INFO] Using Java 21 for frontend
    start "AI-ENGINE (Frontend)" cmd /k "cd /d %FRONTEND% && set JAVA_HOME=C:\Program Files\Java\openjdk-21 && set PATH=C:\Program Files\Java\openjdk-21\bin;%%PATH%% && java -jar target\ai-engine-frontend-0.0.1-SNAPSHOT-exec.jar"
  ) else if defined JAVA_HOME (
    echo [INFO] Using JAVA_HOME Java for frontend
    start "AI-ENGINE (Frontend)" cmd /k "cd /d %FRONTEND% && java -jar target\ai-engine-frontend-0.0.1-SNAPSHOT-exec.jar"
  ) else (
    echo [INFO] Using system Java for frontend
    start "AI-ENGINE (Frontend)" cmd /k "cd /d %FRONTEND% && java -jar target\ai-engine-frontend-0.0.1-SNAPSHOT-exec.jar"
  )
) else if exist "%MVNW%" (
  echo [INFO] Starting frontend with Maven Wrapper...
  start "AI-ENGINE (Frontend)" cmd /k "cd /d %FRONTEND% && call mvnw.cmd -DskipTests org.springframework.boot:spring-boot-maven-plugin:3.3.4:run"
) else if exist "%MAVEN_BIN%" (
  echo [INFO] Starting frontend with Maven...
  start "AI-ENGINE (Frontend)" cmd /k "cd /d %FRONTEND% && call %MAVEN_BIN% -DskipTests org.springframework.boot:spring-boot-maven-plugin:3.3.4:run"
) else (
  echo [ERROR] 前端未找到可執行 JAR，且 Maven Wrapper / Maven 也不可用。
  echo         請確保 MAVEN_HOME 環境變數已設定，或使用 Maven Wrapper。
)

echo [INFO] All done. Backend: http://127.0.0.1:8000  Frontend: http://127.0.0.1:8080

REM === Wait for Frontend to be ready and open browser ===
echo [INFO] Waiting for frontend to be ready...
set /a FRONTEND_RETRIES=30
:wait_frontend
  powershell -NoProfile -Command "try { $r = Invoke-WebRequest -Uri http://127.0.0.1:8080 -UseBasicParsing -TimeoutSec 3; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { Start-Sleep -Seconds 1; exit 1 }" >nul 2>&1
  if %ERRORLEVEL% equ 0 (
    echo [INFO] Frontend is ready! Opening browser...
    start http://127.0.0.1:8080
    goto :frontend_ready
  ) else (
    set /a FRONTEND_RETRIES-=1
    if !FRONTEND_RETRIES! gtr 0 (
      timeout /t 1 >nul
      goto :wait_frontend
    ) else (
      echo [WARN] Frontend startup timeout. Please check manually at http://127.0.0.1:8080
    )
  )
:frontend_ready

endlocal
exit /b 0
