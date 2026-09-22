@echo off
cd /d "%~dp0"
title UMG - Finalizar Examen DevOps
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\finalizar.ps1"
echo.
echo Muestre RESUMEN_EXAMEN.txt al docente.
pause
