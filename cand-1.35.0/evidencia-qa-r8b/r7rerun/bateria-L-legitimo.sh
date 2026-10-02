#!/usr/bin/env bash
# Operaciones legítimas con un `cwd` que contiene CR (CA-47 p11: lo que no depende del cwd se juzga como
# siempre): la DECISIÓN del hook del candidato (guard.sh) y, si permite, la operación EJECUTADA de verdad
# desde ese cwd y el ARCHIVO RESULTANTE. Si deniega, no se ejecuta y se comprueba que el disco no cambió.
# A nivel de hook: esto no es el host (no lo ejecuta Claude Code); simula la herramienta tras el veredicto.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8b/r7rerun/qa-lib-r8b.sh
PRJ=$Q/proj-l; F=$Q/fuera-l; rm -rf "$PRJ" "$F"; mkproj "$PRJ"; mkdir -p "$F/d"; ln -s "$PRJ" "$F/d$CR"
req "$PRJ/requirements/REQ-901.md" en-revisión aprobado
C="$F/d$CR"
h() { sha256sum "$1" 2>/dev/null | cut -c1-16 || echo ausente; }
caso() {   # <id> <json> <acción si allow (bash -c, desde el cwd con CR)> <archivo a mirar>
  local id="$1" json="$2" acc="$3" f="$4" antes despues
  antes="$(h "$f")"; call "$CAND" guard.sh "$json"
  if [ "$D" = allow ]; then ( cd "$C" && bash -c "$acc" ) >/dev/null 2>&1; fi
  despues="$(h "$f")"
  printf '%-62s decisión=%-5s  %s: antes=%s después=%s  contenido=%q\n' "$id" "$D" "${f#$PRJ/}" "$antes" "$despues" "$(head -c 60 "$f" 2>/dev/null | tr '\n' '|')"
  [ -z "$M" ] || printf '      motivo: %s\n' "${M:0:200}"
}
echo "== Operaciones legítimas desde cwd = <fuera>/d<CR> (enlace a la raíz), candidato fa070b7, $(date -Iseconds) =="
echo "   pwd -P desde ese cwd: $(cd "$C" && pwd -P)"
caso "L1 coordinadora Bash: printf ok > <raíz>/docs/legit.md (ABS)" "$(j Bash "$C" - "command=printf ok > $PRJ/docs/legit.md")" "printf ok > $PRJ/docs/legit.md" "$PRJ/docs/legit.md"
caso "L2 coordinadora Bash: ls -la (no escribe)"                    "$(j Bash "$C" - 'command=ls -la')"  "ls -la" "$PRJ/docs/legit.md"
caso "L3 coordinadora Write ABS <raíz>/docs/legit2.md"               "$(j Write "$C" - "file_path=$PRJ/docs/legit2.md" content=hola)" "printf hola > $PRJ/docs/legit2.md" "$PRJ/docs/legit2.md"
caso "L4 desarrollador Bash relativo: printf dev > src/b.ts"         "$(j Bash "$C" desarrollador 'command=printf dev > src/b.ts')" "printf dev > src/b.ts" "$PRJ/src/b.ts"
caso "L5 Edit ABS que cierra REQ-901 (en verde)"                     "$(cierre "$C" "$PRJ/requirements/REQ-901.md")" "sed -i 's/Estado: en-revisión/Estado: completado/' $PRJ/requirements/REQ-901.md" "$PRJ/requirements/REQ-901.md"
echo "-- y lo que se deniega no llega al disco:"
caso "D1 coordinadora Bash relativo: printf x > src/a.ts"            "$(j Bash "$C" - 'command=printf INTRUSO > src/a.ts')" "printf INTRUSO > src/a.ts" "$PRJ/src/a.ts"
caso "D2 coordinadora Bash relativo fuera del ámbito: printf x > n.md (declarado de allow a deny)" "$(j Bash "$C" - 'command=printf x > n.md')" "printf x > n.md" "$PRJ/n.md"
