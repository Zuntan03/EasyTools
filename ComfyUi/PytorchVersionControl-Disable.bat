@echo off
chcp 65001 > NUL
if not exist "%~dp0PytorchVersionControl-Disabled.txt" ( copy NUL "%~dp0PytorchVersionControl-Disabled.txt" > NUL )
