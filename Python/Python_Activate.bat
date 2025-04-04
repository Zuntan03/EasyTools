@echo off
chcp 65001 > NUL
set PS_CMD=PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass
set CURL_CMD=C:\Windows\System32\curl.exe -kL
set PYTHON_CMD=python

@REM set EASY_PYTHON_VERSION=3.10.6
@REM 3.10.6, 3.12.9
if not exist "%~dp0Python_DefaultVersion.txt" (
	echo 3.10.6> "%~dp0Python_DefaultVersion.txt"
)

if "%EASY_PYTHON_VERSION%" == "" (
	set /p EASY_PYTHON_VERSION=< "%~dp0Python_DefaultVersion.txt"
)

set EASY_PYTHON_MINOR_VERSION=%EASY_PYTHON_VERSION:~0,5%
set EASY_PYTHON_VERSION_3=%EASY_PYTHON_MINOR_VERSION:.=%

set PYTHON_DIR="%~dp0env\python%EASY_PYTHON_VERSION_3%"
set LOCAL_PYTHON_CMD=%PYTHON_DIR%\python.exe

for /f "tokens=*" %%i in ('%PYTHON_CMD% --version 2^>^&1') do set PYTHON_VERSION_VAR=%%i
if not "%PYTHON_VERSION_VAR:~7,5%"=="%EASY_PYTHON_MINOR_VERSION%" (
	set PYTHON_CMD=%LOCAL_PYTHON_CMD%
	setlocal enabledelayedexpansion
	if not exist %PYTHON_DIR%\ (
		echo https://www.python.org/
		echo https://github.com/pypa/get-pip
		mkdir %PYTHON_DIR%

		echo %CURL_CMD% -o %~dp0env\python.zip https://www.python.org/ftp/python/%EASY_PYTHON_VERSION%/python-%EASY_PYTHON_VERSION%-embed-amd64.zip
		%CURL_CMD% -o %~dp0env\python.zip https://www.python.org/ftp/python/%EASY_PYTHON_VERSION%/python-%EASY_PYTHON_VERSION%-embed-amd64.zip
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )

		echo %PS_CMD% Expand-Archive -Path %~dp0env\python.zip -DestinationPath %PYTHON_DIR%
		%PS_CMD% Expand-Archive -Path %~dp0env\python.zip -DestinationPath %PYTHON_DIR%
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )

		echo del %~dp0env\python.zip
		del %~dp0env\python.zip
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )

		echo %PS_CMD% "try { &{(Get-Content '%PYTHON_DIR%/python%EASY_PYTHON_VERSION_3%._pth') -creplace '#import site', 'import site' | Set-Content '%PYTHON_DIR%/python%EASY_PYTHON_VERSION_3%._pth' } } catch { exit 1 }"
		%PS_CMD% "try { &{(Get-Content '%PYTHON_DIR%/python%EASY_PYTHON_VERSION_3%._pth') -creplace '#import site', 'import site' | Set-Content '%PYTHON_DIR%/python%EASY_PYTHON_VERSION_3%._pth' } } catch { exit 1 }"
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )

		echo %CURL_CMD% -o %PYTHON_DIR%\get-pip.py https://bootstrap.pypa.io/get-pip.py
		%CURL_CMD% -o %PYTHON_DIR%\get-pip.py https://bootstrap.pypa.io/get-pip.py
		@REM プロキシ環境用コマンド。ただし動作未確認、かつ Python をインストールしたほうが楽。
		@REM %CURL_CMD% -o %PYTHON_DIR%\get-pip.py https://bootstrap.pypa.io/get-pip.py --proxy="PROXY_SERVER:PROXY_PORT"
		if %ERRORLEVEL% neq 0 (
			echo "[Error] プロキシ環境によりインストールに失敗した可能性があります。Python %EASY_PYTHON_MINOR_VERSION% 系をパスを通してインストールしてください。"
			pause & exit /b 1
		)

		echo %LOCAL_PYTHON_CMD% %PYTHON_DIR%\get-pip.py --no-warn-script-location
		%LOCAL_PYTHON_CMD% %PYTHON_DIR%\get-pip.py --no-warn-script-location
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )

		echo %LOCAL_PYTHON_CMD% -m pip install virtualenv --no-warn-script-location
		%LOCAL_PYTHON_CMD% -m pip install virtualenv --no-warn-script-location
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )
	)

	if not exist %PYTHON_DIR%\include\Python.h (
		echo %PS_CMD% Expand-Archive -Force -Path %~dp0python_include_libs-%EASY_PYTHON_VERSION%.zip -DestinationPath %PYTHON_DIR%
		%PS_CMD% Expand-Archive -Force -Path %~dp0python_include_libs-%EASY_PYTHON_VERSION%.zip -DestinationPath %PYTHON_DIR%
		if !ERRORLEVEL! neq 0 ( pause & endlocal & exit /b 1 )
	)
	endlocal
)

for /f "tokens=*" %%i in ('%PYTHON_CMD% --version 2^>^&1') do set PYTHON_VERSION_VAR2=%%i
if not "%PYTHON_VERSION_VAR2:~7,5%"=="%EASY_PYTHON_MINOR_VERSION%" (
	echo %PYTHON_VERSION_VAR2%
	echo "[Error] 何らかの理由で Python をインストールできませんでした。Python %EASY_PYTHON_MINOR_VERSION% 系をパスを通してインストールしてください。"
	pause & exit /b 1
)

if not "%~1"=="" (
	set VIRTUAL_ENV_DIR=%~1
) else (
	set VIRTUAL_ENV_DIR=venv
)

if not exist %VIRTUAL_ENV_DIR%\ (
	echo %PYTHON_CMD% -m venv %VIRTUAL_ENV_DIR%
	%PYTHON_CMD% -m venv %VIRTUAL_ENV_DIR%

	if not exist %VIRTUAL_ENV_DIR%\ (
		echo %PYTHON_CMD% -m pip install virtualenv --no-warn-script-location
		%PYTHON_CMD% -m pip install virtualenv --no-warn-script-location

		echo %PYTHON_CMD% -m virtualenv --copies %VIRTUAL_ENV_DIR%
		%PYTHON_CMD% -m virtualenv --copies %VIRTUAL_ENV_DIR%
	)

	if not exist %VIRTUAL_ENV_DIR%\ (
		echo "[ERROR] Python 仮想環境を作成できません。Python %EASY_PYTHON_MINOR_VERSION% 系を手動でパスを通してインストールしてください。"
		pause & exit /b 1
	)
)

call %VIRTUAL_ENV_DIR%\Scripts\activate.bat
if %ERRORLEVEL% neq 0 ( pause &  exit /b 1 )
