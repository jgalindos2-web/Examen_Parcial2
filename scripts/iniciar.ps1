$ErrorActionPreference="SilentlyContinue"
$Project=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Dir=Join-Path $Project ".exam"; New-Item -ItemType Directory -Force $Dir|Out-Null

# Identificador único por sesión/equipo.
$rand=[guid]::NewGuid().ToString("N").Substring(0,6).ToUpper()
$SessionId=("UMG-DEVOPS-{0}-{1}" -f $env:COMPUTERNAME,$rand)
$SessionId|Set-Content (Join-Path $Dir "session.id") -Encoding ASCII

@{
 session=$SessionId
 computer=$env:COMPUTERNAME
 user=$env:USERNAME
 started=(Get-Date).ToString("o")
 project=(Resolve-Path $Project).Path
} | ConvertTo-Json | Set-Content (Join-Path $Dir "session.json") -Encoding UTF8

# Estado inicial.
Get-Process|Sort-Object ProcessName|Select-Object ProcessName,Id,StartTime|
 Format-Table -AutoSize|Out-String|Set-Content (Join-Path $Dir "procesos_inicio.txt") -Encoding UTF8

if(Get-Command code -ErrorAction SilentlyContinue){
 $ext=& code --list-extensions 2>&1
 $ext|Set-Content (Join-Path $Dir "extensiones_vscode_inicio.txt") -Encoding UTF8
}

# Monitor en segundo plano, minimizado.
$mon=Join-Path $Project "scripts\monitor.ps1"
$p=Start-Process powershell.exe -WindowStyle Minimized -PassThru -ArgumentList @(
 "-NoProfile","-ExecutionPolicy","Bypass","-File",('"{0}"' -f $mon),
 "-Project",('"{0}"' -f $Project),"-SessionId",('"{0}"' -f $SessionId)
)
$p.Id|Set-Content (Join-Path $Dir "monitor.pid") -Encoding ASCII

Write-Host "=============================================="
Write-Host " UMG - EXAMEN PRACTICO DEVOPS"
Write-Host " Sesion: $SessionId"
Write-Host " Equipo: $env:COMPUTERNAME"
Write-Host "=============================================="
Write-Host "ExamGuard iniciado en segundo plano."

Push-Location $Project
Write-Host "`n[1/3] Instalando dependencias..."
npm install
Write-Host "`n[2/3] Ejecutando pruebas iniciales..."
npm test
Write-Host "`n[3/3] Preparando Git..."
if(!(Test-Path ".git")){
 git init | Out-Null
 git add .
 git commit -m "chore: proyecto base examen DevOps" 2>&1 | Out-Null
}
Pop-Location

# Abrir IDE autorizado si VS Code está disponible.
if(Get-Command code -ErrorAction SilentlyContinue){
 Write-Host "Abriendo VS Code..."
 Start-Process code -ArgumentList ('"{0}"' -f $Project)
}else{
 Write-Host "VS Code no se abrió automáticamente; abra el IDE autorizado."
}
Write-Host "`nNO modifique la carpeta .exam."
Write-Host "Al finalizar ejecute FINALIZAR_EXAMEN.bat."
