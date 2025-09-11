@echo off
chcp 65001 > NUL
if exist "%~dp0ComfyUiVersionControl-Disabled.txt" ( del "%~dp0ComfyUiVersionControl-Disabled.txt" > NUL )
