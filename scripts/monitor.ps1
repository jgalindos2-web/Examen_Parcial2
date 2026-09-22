param([string]$Project,[string]$SessionId)
$ErrorActionPreference="SilentlyContinue"
$Cfg=Import-PowerShellDataFile (Join-Path $Project "scripts\config.psd1")
$Dir=Join-Path $Project ".exam"; $Log=Join-Path $Dir "audit.log"
function L($level,$msg){Add-Content $Log ("{0:yyyy-MM-dd HH:mm:ss} [{1}] [{2}] {3}" -f (Get-Date),$level,$SessionId,$msg) -Encoding UTF8}
L "START" "Monitor iniciado | Equipo=$env:COMPUTERNAME | Usuario=$env:USERNAME"
$known=@{}
while($true){
 L "HEARTBEAT" "Activo"
 $procs=Get-Process
 foreach($n in $Cfg.SuspiciousProcessNames){
  foreach($p in ($procs|Where-Object {$_.ProcessName -like "*$n*"})){
   $k="$($p.ProcessName):$($p.Id)"
   if(!$known.ContainsKey($k)){L "ALERTA" "Proceso a revisar=$($p.ProcessName) PID=$($p.Id)";$known[$k]=$true}
  }
 }
 Start-Sleep ([int]$Cfg.PollSeconds)
}