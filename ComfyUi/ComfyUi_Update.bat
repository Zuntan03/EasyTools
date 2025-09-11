@echo off
chcp 65001 > NUL
set CURL_CMD=C:\Windows\System32\curl.exe -kL
set EASY_TOOLS=%~dp0..
set GITHUB_CLONE_OR_PULL_TAG=%EASY_TOOLS%\Git\GitHub_CloneOrPull_Tag.bat
set PYTHON_ACTIVATE=%EASY_TOOLS%\Python\Python_Activate.bat

if exist %~dp0vc_redist.x64.exe ( goto :EXIST_VC_REDIST_X64 )
echo.
echo %CURL_CMD% -o %~dp0vc_redist.x64.exe https://aka.ms/vs/17/release/vc_redist.x64.exe
%CURL_CMD% -o %~dp0vc_redist.x64.exe https://aka.ms/vs/17/release/vc_redist.x64.exe
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )
start %~dp0vc_redist.x64.exe /install /passive /norestart
:EXIST_VC_REDIST_X64

set COMFYUI_VERSION=
if exist "%~dp0ComfyUiVersionControl-Disabled.txt" ( goto :SKIP_COMFYUI_VERSION_CONTROL )
if exist "%~dp0ComfyUi_Version.txt" (
    set /p COMFYUI_VERSION=<"%~dp0ComfyUi_Version.txt"
)
:SKIP_COMFYUI_VERSION_CONTROL

@REM https://github.com/comfyanonymous/ComfyUI
call %GITHUB_CLONE_OR_PULL_TAG% comfyanonymous ComfyUI master %COMFYUI_VERSION%
if %ERRORLEVEL% neq 0 ( exit /b 1 )

pushd ComfyUI

@REM https://github.com/comfyanonymous/ComfyUI#manual-install-windows-linux
if not exist "%EASY_TOOLS%\Python\Python_DefaultVersion.txt" (
	echo 3.12.9> "%EASY_TOOLS%\Python\Python_DefaultVersion.txt"
)
call %PYTHON_ACTIVATE%
if %ERRORLEVEL% neq 0 ( popd & exit /b 1 )

@REM pip==25.2
echo python -m pip install -qq -U pip setuptools wheel
python -m pip install -qq -U pip setuptools wheel
if %ERRORLEVEL% neq 0 ( pause & popd & exit /b 1 )

if not exist "%~dp0UninstallModule.txt" ( goto :EASY_UNINSTALL_MODULE_NOT_FOUND )
set /p UNINSTALL_MODULE=<"%~dp0UninstallModule.txt"
echo pip uninstall -qq -y %UNINSTALL_MODULE%
pip uninstall -qq -y %UNINSTALL_MODULE%
if %ERRORLEVEL% neq 0 ( pause & popd & exit /b 1 )
:EASY_UNINSTALL_MODULE_NOT_FOUND

if exist "%~dp0PytorchVersionControl-Disabled.txt" ( goto :SKIP_PYTORCH_VERSION_CONTROL )

if not exist "%~dp0Torch_Version.txt" (
	echo torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128> "%~dp0Torch_Version.txt"
)
set /p TORCH_VERSION=<"%~dp0Torch_Version.txt"
echo pip install -qq %TORCH_VERSION%
pip install -qq %TORCH_VERSION%
if %ERRORLEVEL% neq 0 ( pause & popd & exit /b 1 )

@REM https://github.com/woct0rdho/triton-windows/releases
if not exist "%~dp0Triton_Version.txt" (
	echo triton-windows==3.4.0.post20> "%~dp0Triton_Version.txt"
)
set /p TRITON_VERSION=<"%~dp0Triton_Version.txt"
echo pip install -qq %TRITON_VERSION%
pip install -qq %TRITON_VERSION%
if %ERRORLEVEL% neq 0 ( pause & popd & exit /b 1 )

set "TRITON_CACHE=C:\Users\%USERNAME%\.triton\cache"
if not exist "%TRITON_CACHE%" ( goto :EASY_TRITON_CACHE_NOT_FOUND )
echo rmdir /S /Q "%TRITON_CACHE%"
rmdir /S /Q "%TRITON_CACHE%"
:EASY_TRITON_CACHE_NOT_FOUND

set "TORCH_INDUCTOR_TEMP=C:\Users\%USERNAME%\AppData\Local\Temp\torchinductor_%USERNAME%"
if not exist "%TORCH_INDUCTOR_TEMP%" ( goto :EASY_TORCH_INDUCTOR_TEMP_NOT_FOUND )
echo rmdir /S /Q "%TORCH_INDUCTOR_TEMP%"
rmdir /S /Q "%TORCH_INDUCTOR_TEMP%"
:EASY_TORCH_INDUCTOR_TEMP_NOT_FOUND

if exist %EASY_PORTABLE_PYTHON_DIR%\ (
	@REM tcc.exe & VS Build Tools cl.exe
	if not exist venv\Scripts\Include\Python.h (
		echo xcopy /SQY %EASY_PORTABLE_PYTHON_DIR%\include\*.* venv\Scripts\Include\
		xcopy /SQY %EASY_PORTABLE_PYTHON_DIR%\include\*.* venv\Scripts\Include\
		echo xcopy /SQY %EASY_PORTABLE_PYTHON_DIR%\libs\*.* venv\Scripts\libs\
		xcopy /SQY %EASY_PORTABLE_PYTHON_DIR%\libs\*.* venv\Scripts\libs\
	)
)

@REM https://github.com/woct0rdho/SageAttention/releases
if not exist "%~dp0SageAttention_Version.txt" (
	echo https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post2/sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl> "%~dp0SageAttention_Version.txt"
)
set /p SAGE_ATTENTION_VERSION=<"%~dp0SageAttention_Version.txt"
echo pip install -qq %SAGE_ATTENTION_VERSION%
pip install -qq %SAGE_ATTENTION_VERSION%
if %ERRORLEVEL% neq 0 ( pause & popd & exit /b 1 )

:SKIP_PYTORCH_VERSION_CONTROL

echo pip install -qq -r requirements.txt
pip install -qq -r requirements.txt
if %ERRORLEVEL% neq 0 ( pause & popd & exit /b 1 )

popd rem ComfyUI
pushd ComfyUI\custom_nodes

set COMFYUI_MANAGER_VERSION=
if exist "%~dp0ComfyUiVersionControl-Disabled.txt" ( goto :SKIP_COMFYUI_MANAGER_VERSION_CONTROL )
if exist "%~dp0ComfyUiManager_Version.txt" (
	set /p COMFYUI_MANAGER_VERSION=<"%~dp0ComfyUiManager_Version.txt"
)
:SKIP_COMFYUI_MANAGER_VERSION_CONTROL

@REM https://github.com/Comfy-Org/ComfyUI-Manager
call %GITHUB_CLONE_OR_PULL_TAG% Comfy-Org ComfyUI-Manager main %COMFYUI_MANAGER_VERSION%
if %ERRORLEVEL% neq 0 ( popd & exit /b 1 )

popd rem ComfyUI\custom_nodes
