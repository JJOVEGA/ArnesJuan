#!/usr/bin/env bash
# t5b — continuación de línea hacia un REQ (guard-completado) y >> ; ajeno al delta.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
proyecto_nuevo "$S/p5b"
NL=$'\n'
C10="printf '%s\n' '# REQ-900' 'Estado: completado' > \\${NL}requirements/REQ-900.md"
C11="echo x >> \\${NL}src/a.ts"
j_bash "$C10"; fila "C10 printf … 'Estado: completado' > \\<LF>requirements/REQ-900.md" "$J"
j_bash "$C11"; fila "C11 echo x >> \\<LF>src/a.ts" "$J"
T="$S/efe5b"; proyecto_nuevo "$T"; ( cd "$T" && bash -c "$C10"; bash -c "$C11" ) >/dev/null 2>&1
echo "efecto: REQ-900 l2=$(sed -n 2p "$T/requirements/REQ-900.md") ; src/a.ts=$(tr '\n' '|' < "$T/src/a.ts")"; rm -rf "$T"
