# Prueba de INTEGRACION: que hace y que NO hace el campo `if` de un hook de PLUGIN.
#
# Cuesta una llamada al modelo (~30 s, Haiku), por eso no va en el banco. Se corre A
# MANO al tocar hooks/hooks.json. Es la unica prueba que pasa por el motor de hooks de
# Claude Code: el banco invoca los scripts directamente y nunca lo toca.
#
# HISTORIA, porque es lo que justifica cada sonda:
#   1.25.0 puso handlers `if` por disparador para que un `ls` no arrancara el guardian.
#   La primera version de ESTA prueba solo sondeaba `touch`, y paso. Pero el patron del
#   que dependia todo era `Bash(* >*)`, y nadie lo sondeo. Medido en un proyecto real:
#   `echo 'Estado: completado' > requirements/x` paso y creo el archivo. Una redireccion
#   NUNCA casa con `if`: Claude Code la separa del comando antes de evaluar el patron.
#   Un control positivo para QUE `if` EXISTE no era un control para EL PATRON QUE IMPORTABA.
#
# Sondas: `ls` (nada debe casar salvo el control), `touch` (prefijo: DEBE casar),
# `echo x > f` (redireccion: NO debe casar, y eso es lo que documenta la prueba).
#   TODOS registra los tres · IF_TOUCH solo touch · IF_REDIR* NADA     -> PASS
#   IF_REDIR* registra la redireccion                                  -> Claude Code cambio:
#                                                                         revisar si `if` ya
#                                                                         puede ver `>`
#   TODOS no registra nada                                             -> ABORT, no cargo
$ErrorActionPreference = 'Stop'
$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$work = Join-Path ([IO.Path]::GetTempPath()) ("arnes-if-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $work | Out-Null
$env:IF_TEST_LOG = Join-Path $work 'registro.log'
Push-Location $work
try {
  & claude -p --model haiku --plugin-dir $aqui --allowedTools "Bash(ls*)" "Bash(touch *)" "Bash(echo *)" --output-format text `
    "Ejecuta exactamente estos tres comandos Bash, uno por llamada, en este orden, sin nada mas y sin explicar: ls ; touch a.txt ; echo hola > b.txt . Al terminar responde solo OK." | Out-Null
} finally { Pop-Location }
$v = (& claude --version 2>&1 | Select-Object -First 1)
if (-not (Test-Path $env:IF_TEST_LOG)) { Write-Host "ABORT: ningun hook del plugin corrio ($v)"; exit 2 }
$log = Get-Content $env:IF_TEST_LOG
Write-Host "--- registro ($v) ---"; $log | ForEach-Object { "  $_" }
$c = @{}
foreach ($k in 'TODOS: ls','TODOS: touch','TODOS: echo','IF_TOUCH: touch','IF_TOUCH: ls','IF_REDIR: ','IF_REDIR2: ') { $c[$k] = ($log | Where-Object { $_ -like "$k*" }).Count }
if ($c['TODOS: ls'] -lt 1 -or $c['TODOS: touch'] -lt 1 -or $c['TODOS: echo'] -lt 1) { Write-Host "ABORT: el control no registro los tres comandos; la prueba no vale"; exit 2 }
if ($c['IF_TOUCH: ls'] -gt 0)   { Write-Host "FAIL: el if de touch arranco para ls: `if` se ignora"; exit 1 }
if ($c['IF_TOUCH: touch'] -lt 1) { Write-Host "FAIL: el if de touch NO arranco para touch"; exit 1 }
if (($c['IF_REDIR: '] + $c['IF_REDIR2: ']) -gt 0) {
  Write-Host "CAMBIO: un if de redireccion ARRANCO. Claude Code ya ve `>` en el patron; revisar si el catch-all de Bash puede volver a ser selectivo."
  exit 3
}
Write-Host "PASS: `if` funciona para prefijos (touch) y NO ve redirecciones (echo >). Por eso Bash lleva catch-all."
Remove-Item -Recurse -Force $work
exit 0
