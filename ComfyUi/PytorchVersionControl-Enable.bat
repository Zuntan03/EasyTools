@echo off
chcp 65001 > NUL
if exist "%~dp0PytorchVersionControl-Disabled.txt" ( del "%~dp0PytorchVersionControl-Disabled.txt" > NUL )
