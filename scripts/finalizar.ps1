$ErrorActionPreference="SilentlyContinue"
$Project=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Dir=Join-Path $Project ".exam"; $Session=(Get-Content (Join-Path $Dir "session.id") -ErrorAction SilentlyContinue)
$Log=Join-Path $Dir "audit.log"
function L($level,$msg){Add-Content $Log ("{0:yyyy-MM-dd HH:mm:ss} [{1}] [{2}] {3}" -f (Get-Date),$level,$Session,$msg) -Encoding UTF8}
L "FINISH" "Recopilacion final iniciada"

# Comprobar que el monitor siga vivo.
$pidFile=Join-Path $Dir "monitor.pid"
$monitorAlive=$false
if(Test-Path $pidFile){
 $mpid=[int](Get-Content $pidFile)
 if(Get-Process -Id $mpid -ErrorAction SilentlyContinue){$monitorAlive=$true}
}
if(!$monitorAlive){L "ALERTA" "Monitor no estaba activo al finalizar"}

Push-Location $Project
$g=Join-Path $Dir "git_evidence.txt"
"=== SESSION ===`n$Session`n=== STATUS ==="|Set-Content $g
git status --short 2>&1|Add-Content $g
"`n=== BRANCH ==="|Add-Content $g; git branch --show-current 2>&1|Add-Content $g
"`n=== LOG ==="|Add-Content $g; git log --oneline --decorate -20 2>&1|Add-Content $g
"`n=== REMOTES ==="|Add-Content $g; git remote -v 2>&1|Add-Content $g
if(Test-Path package.json){
 npm outdated 2>&1|Set-Content (Join-Path $Dir "npm_outdated.txt")
 npm audit 2>&1|Set-Content (Join-Path $Dir "npm_audit.txt")
}
Pop-Location

if(Get-Command code -ErrorAction SilentlyContinue){
 (& code --list-extensions 2>&1)|Set-Content (Join-Path $Dir "extensiones_vscode_final.txt")
}
Get-Process|Sort-Object ProcessName|Select-Object ProcessName,Id,StartTime|
 Format-Table -AutoSize|Out-String|Set-Content (Join-Path $Dir "procesos_final.txt")

$heartbeats=(Select-String $Log -Pattern "\[HEARTBEAT\]" -ErrorAction SilentlyContinue).Count
$alerts=(Select-String $Log -Pattern "\[ALERTA\]" -ErrorAction SilentlyContinue).Count

@"
EXAMGUARD UMG v2
Sesion: $Session
Equipo: $env:COMPUTERNAME
Usuario: $env:USERNAME
Finalizado: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Monitor activo al finalizar: $monitorAlive
Heartbeats: $heartbeats
Alertas: $alerts

ESTADO ORIENTATIVO: $(if(!$monitorAlive -or $alerts -gt 0){"REVISAR"}else{"NORMAL"})

Una alerta no demuestra uso de IA. Requiere contraste con Git,
la practica, las reglas del examen y revision docente.
"@|Set-Content (Join-Path $Dir "RESUMEN_EXAMEN.txt")

L "FINISH" "Recopilacion completada"

# Detener únicamente el proceso monitor registrado.
if($monitorAlive){Stop-Process -Id $mpid -Force -ErrorAction SilentlyContinue}

# Hash final después de detener monitor.
$hf=Join-Path $Dir "hashes.sha256.txt"
Get-ChildItem $Dir -File|Where-Object {$_.Name -notin @("hashes.sha256.txt",".gitkeep")}|
 Sort-Object Name|ForEach-Object {$h=Get-FileHash $_.FullName -Algorithm SHA256;"$($h.Hash)  $($_.Name)"}|
 Set-Content $hf

Write-Host "=============================================="
Write-Host "EXAMEN FINALIZADO"
Write-Host "Sesion: $Session"
Write-Host "Estado: $(if(!$monitorAlive -or $alerts -gt 0){"REVISAR"}else{"NORMAL"})"
Write-Host "Evidencias: $Dir"
Write-Host "=============================================="
