@echo off
chcp 65001 > NUL
if not exist "%~dp0ComfyUiVersionControl-Disabled.txt" ( copy NUL "%~dp0ComfyUiVersionControl-Disabled.txt" > NUL )
