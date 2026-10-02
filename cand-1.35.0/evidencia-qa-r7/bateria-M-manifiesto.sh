#!/usr/bin/env bash
# CA-60 (manifiesto roto): la reparación legítima sigue pasando; sus bordes con LF (r6) y con CR (r7), y
# variantes propias (CR del cwd con ruta absoluta; CR en medio del file_path).
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r7/qa-lib-r7.sh
PRJ=$Q/proj-manif; F=$Q/fuera-manif; rm -rf "$PRJ" "$F"; mkproj "$PRJ"; mkdir -p "$F/d"; ln -s "$PRJ" "$F/d$CR"
printf 'esto no es json {' > "$PRJ/.arnes/config.json"   # manifiesto roto
MF="$PRJ/.arnes/config.json"   # (no se llama M: call() publica el motivo en M)
REP="pri""ntf '{}' > .arnes/config.json"
echo "== CA-60: manifiesto roto, la reparación y sus bordes con LF y CR, $(date -Iseconds) =="
echo "-- controles (la reparación legítima)"
quad "M-ctl Write al manifiesto (coordinadora)"                   guard.sh "$(j Write "$PRJ" - "file_path=$MF" content={})"
quad "M-dev Write al manifiesto (desarrollador)"                  guard.sh "$(j Write "$PRJ" desarrollador "file_path=$MF" content={})"
quad "M-bash reparación por Bash desde la raíz"                   guard.sh "$(j Bash "$PRJ" - "command=$REP")"
quad "M-ctlCR Write ABS al manifiesto con cwd F/d<CR> (no depende del cwd)" guard.sh "$(j Write "$F/d$CR" - "file_path=$MF" content={})"
quad "M-bashABS reparación por Bash ABS desde cwd F/d<CR>"        guard.sh "$(j Bash "$F/d$CR" - "command=pri""ntf '{}' > $MF")"
echo "-- bordes con LF (sexta autorización, r6)"
quad "M1 Write manifiesto<LF>"                                    guard.sh "$(j Write "$PRJ" - "file_path=$MF$NL" content={})"
quad "M2 Write manif<LF>manif"                                    guard.sh "$(j Write "$PRJ" - "file_path=$MF$NL$MF" content={})"
quad "M4 M1 por guard-completado a solas"                         guard-completado.sh "$(j Write "$PRJ" - "file_path=$MF$NL" content={})"
quad "M5 Write<LF> al manifiesto"                                 guard.sh "$(j "Write$NL" "$PRJ" - "file_path=$MF" content={})"
quad "M-bash2 reparación + otra escritura"                        guard.sh "$(j Bash "$PRJ" - "command=$REP ; ec""ho x > src/a.ts")"
echo "-- bordes con CR (séptima autorización)"
quad "MC2 Write manifiesto<CR> (coordinadora)"                    guard.sh "$(j Write "$PRJ" - "file_path=$MF$CR" content={})"
quad "MC3 Write<CR> al manifiesto"                                guard.sh "$(j "Write$CR" "$PRJ" - "file_path=$MF" content={})"
quad "MC4 Write manifiesto<CR> (desarrollador)"                   guard.sh "$(j Write "$PRJ" desarrollador "file_path=$MF$CR" content={})"
quad "MC4b MC2 por guard-completado a solas"                      guard-completado.sh "$(j Write "$PRJ" - "file_path=$MF$CR" content={})"
quad "MC5 reparación relativa por Bash desde cwd F/d<CR>"         guard.sh "$(j Bash "$F/d$CR" - "command=$REP")"
quad "MC7 Write <raíz>/.arnes<CR>/config.json (CR en medio)"      guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/.arnes$CR/config.json" content={})"
quad "MC8 Edit relativo .arnes/config.json desde cwd F/d<CR>"     guard.sh "$(j Edit "$F/d$CR" - "file_path=.arnes/config.json" old_string=esto new_string={})"
