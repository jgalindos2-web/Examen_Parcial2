@echo off
cd /d "%~dp0"
title UMG - Inicio Examen DevOps
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\iniciar.ps1"
echo.
pause
