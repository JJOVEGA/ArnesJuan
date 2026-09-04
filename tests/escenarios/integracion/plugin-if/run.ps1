# Prueba de INTEGRACION: ¿respeta Claude Code el campo `if` de un hook declarado en un PLUGIN?
#
# No va en el banco normal porque cuesta una llamada al modelo (~30 s, Haiku). Se corre
# A MANO cada vez que se toque hooks/hooks.json, porque es la unica prueba que demuestra
# que los hooks del plugin CARGAN en una instalacion real -- el banco invoca los scripts
# directamente y nunca pasa por el motor de hooks de Claude Code.
#
# Diseño: dos handlers sobre Bash. `TODOS` sin `if` es el CONTROL POSITIVO: si no
# registra nada, el plugin no cargo y la prueba no vale (seria un verde falso). `CON_IF`
# lleva `if: "Bash(touch *)"`. Se ejecutan `ls` y `touch`. Veredicto:
#   TODOS registra ls y touch, CON_IF solo touch  -> `if` funciona (PASS)
#   CON_IF registra tambien ls                    -> `if` se ignora en plugins (FAIL)
#   TODOS no registra nada                        -> el plugin no cargo (ABORT)
$ErrorActionPreference = 'Stop'
$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$work = Join-Path ([IO.Path]::GetTempPath()) ("arnes-if-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $work | Out-Null
$env:IF_TEST_LOG = Join-Path $work 'registro.log'
Push-Location $work
try {
  & claude -p --model haiku --plugin-dir $aqui --allowedTools "Bash(ls*)" "Bash(touch *)" --output-format text `
    "Ejecuta exactamente estos dos comandos Bash, uno por llamada, sin nada mas y sin explicar: primero ls, despues touch marcador.txt. Al terminar responde solo OK." | Out-Null
} finally { Pop-Location }
if (-not (Test-Path $env:IF_TEST_LOG)) { Write-Host "ABORT: ningun hook del plugin corrio (¿--plugin-dir? ¿version de Claude Code?)"; exit 2 }
$log = Get-Content $env:IF_TEST_LOG
Write-Host "--- registro ---"; $log | ForEach-Object { "  $_" }
$todosLs   = ($log | Where-Object { $_ -like 'TODOS: ls*' }).Count
$todosTch  = ($log | Where-Object { $_ -like 'TODOS: touch*' }).Count
$conIfLs   = ($log | Where-Object { $_ -like 'CON_IF: ls*' }).Count
$conIfTch  = ($log | Where-Object { $_ -like 'CON_IF: touch*' }).Count
if ($todosLs -lt 1 -or $todosTch -lt 1) { Write-Host "ABORT: el control no registro los dos comandos; la prueba no vale"; exit 2 }
if ($conIfLs -gt 0) { Write-Host "FAIL: el handler con if ARRANCO para ls: Claude Code ignora `if` en plugins"; exit 1 }
if ($conIfTch -lt 1) { Write-Host "FAIL: el handler con if NO arranco para touch"; exit 1 }
Write-Host "PASS: `if` en plugin funciona: TODOS={ls,touch}  CON_IF={touch}"
Remove-Item -Recurse -Force $work
exit 0
