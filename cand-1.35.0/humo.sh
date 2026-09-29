#!/usr/bin/env bash
# Humo acotado de la propuesta SEC-047: cada caso contra la puerta real de la base (713ac68) y de la
# propuesta, mismo JSON PreToolUse, proyecto temporal con el manifiesto base del banco. No es el banco.
S="$(cd "$(dirname "$0")" && pwd)"
MANI='{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}'
BOM=$'\xef\xbb\xbf'; ZW=$'\xe2\x80\x8b'; NB=$'\xc2\xa0'; C3=$'\xc3'; CY=$'\xd0\xb0'
nuevo_proj() {
  P="$(mktemp -d "$S/proj.XXXX")"; mkdir -p "$P/.arnes" "$P/requirements"
  printf '%s\n' "$MANI" > "$P/.arnes/config.json"; printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
}
# decide <arbol> <json> -> allow | deny
decide() {
  local out; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$P" bash "$S/$1/hooks/guard-completado.sh" 2>/dev/null)"
  if grep -q '"permissionDecision": *"deny"' <<< "$out"; then
    printf 'deny  <%s>' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<< "$out" | cut -c1-150)"
  else printf 'allow'; fi
}
edit_json()  { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
write_json() { jq -n --arg fp "$1" --arg c "$2" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,content:$c}}'; }
# caso <id> <esperado prop> <cabecera (sin Estado)> [old] [new] [estado inicial] [cuerpo]
caso() {
  local id="$1" esp="$2" cab="$3" old="${4:-en-revisión}" new="${5:-completado}" est="${6:-en-revisión}" cuerpo="${7:-}"
  nuevo_proj; local f="$P/requirements/REQ-900.md"
  printf '# REQ-900\nEstado: %s\nPrioridad: alta\n%s\n\n## Historia\nx\n%s' "$est" "$cab" "$cuerpo" > "$f"
  local j; j="$(export CLAUDE_PROJECT_DIR="$P"; edit_json "$f" "$old" "$new")"
  local b p pc; b="$(decide base "$j")"; p="$(export LC_ALL=C.UTF-8; decide prop "$j")"; pc="$(export LC_ALL=C; decide prop "$j")"
  local ok=PASS; [ "${p%% *}" = "$esp" ] || ok=FAIL; [ "${p%% *}" = "${pc%% *}" ] || ok="FAIL(locale)"
  printf '%-5s %-4s esperado=%-5s base=%-5s prop=%s\n' "$ok" "$id" "$esp" "${b%% *}" "$p"
  rm -rf "$P"
}
V='QA: aprobado\nSeguridad: aprobado'
G="Sensible a seguridad: no\nRigor: estandar\n$V\nHallazgos abiertos: (ninguno)"
echo "== RECHAZO (la variante no puede convertirse en ausencia)"
caso R1  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\nHallazgos  abiertos: SEC-1 (contrato)'
caso R2  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\nHallazgos abiertos: QA-2 (instrumento)\nHALLAZGOS ABIERTOS: SEC-1 (contrato)'
caso R3  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n'"${BOM}Hallazgos abiertos: SEC-1 (contrato)"
caso R4  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n'"Hallazgos abier${ZW}tos: SEC-1 (contrato)"
caso R5  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n'"Hallazgos${NB}abiertos: SEC-1 (contrato)"
caso R6  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n- Hallazgos abiertos: SEC-1 (contrato)'
caso R7  deny $'SENSIBLE A  SEGURIDAD: sí\nRigor: ligero\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: (ninguno)'
caso R8  deny "${BOM}Sensible a seguridad: sí"$'\nRigor: ligero\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: (ninguno)'
caso R9  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n'"${C3}Hallazgos abiertos: SEC-1 (contrato)"
caso R10 deny $'Sensible a seguridad: no\nRigor: estandar\nqa: pendiente\nSeguridad: n/a\nHallazgos abiertos: (ninguno)'
caso R11 deny $'Sensible a seguridad: no\nRIGOR: critico\nQA: aprobado\nSeguridad: pendiente\nHallazgos abiertos: (ninguno)'
caso R12 deny $'Sensible a seguridad: no\nRigor: estandar\nQA: pendiente\nSeguridad: n/a\nHallazgos abiertos: (ninguno)' 'Estado: en-revisión' 'ESTADO: completado'
caso R13 deny $'Sensible a seguridad: sí\nRigor: ligero\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: (ninguno)\nSensible a seguridad: no'
caso R14 deny $'Sensible a seguridad: no\nRigor: estandar\n1. QA: pendiente\nSeguridad: n/a\nHallazgos abiertos: (ninguno)'
caso R15 deny "$(printf "$G")"$'\nQA: aprobado'
echo "== ACEPTACION (ausencia legitima, prosa, tolerancias, reapertura)"
caso A1  allow "$(printf "$G")"
caso A2  allow "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n**Hallazgos abiertos:** (ninguno)'
caso A3  allow $'QA: aprobado'
caso A4  allow "$(printf "$G")"$'\nNota: la seguridad del estado se revisa aparte\nMódulo: hooks\nVersión destino: 1.35.0'
caso A5  allow "$(printf "$G")"$'\n<!-- HALLAZGOS ABIERTOS: SEC-1 (contrato) -->'
caso A6  allow "$(printf "$G")"$'\nHALLAZGOS ABIERTOS: SEC-1 (contrato)' 'Estado: completado' 'Estado: en-progreso' completado
caso A7  allow "$(printf "$G")"$'\nHALLAZGOS ABIERTOS: SEC-1 (contrato)' 'Prioridad: alta' 'Prioridad: media' en-progreso
caso A8  allow "$(printf "$G")" en-revisión completado en-revisión $'HALLAZGOS ABIERTOS: SEC-1 (contrato)\n'
caso A9  allow "$(printf "Sensible a seguridad: no\n$V\nHallazgos abiertos: (ninguno)")"$'\n**Rigor**: estandar'
echo "== FUERA DE LA FRONTERA (declarado: sigue como hoy, ausencia)"
caso F1  allow "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n'"Hallazgos ${CY}biertos: SEC-1 (contrato)"
caso F2  allow "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\nHallazgo abierto: SEC-1 (contrato)'
pad=''; for i in $(seq 90); do pad+="$ZW"; done
caso F3  allow "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\n'"${pad}Hallazgos abiertos: SEC-1 (contrato)"
echo "== SIN CAMBIO (puertas existentes)"
caso U1  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\nHallazgos abiertos: SEC-1 (contrato)\nHallazgos abiertos: (ninguno)'
caso U2  deny "$(printf "Sensible a seguridad: no\nRigor: estandar\n$V")"$'\nHallazgos abiertos: SEC-1 (contrato)'
# CRLF entero, todo en verde: decide igual que LF
nuevo_proj; f="$P/requirements/REQ-901.md"; printf '# REQ-901\r\nEstado: en-revisión\r\nSensible a seguridad: no\r\nRigor: estandar\r\nQA: aprobado\r\nSeguridad: aprobado\r\nHallazgos abiertos: (ninguno)\r\n\r\n## H\r\nx\r\n' > "$f"
j="$(export CLAUDE_PROJECT_DIR="$P"; edit_json "$f" 'en-revisión' 'completado')"
printf 'CRLF  U3   esperado=allow base=%-5s prop=%s\n' "$(decide base "$j" | cut -c1-5)" "$(decide prop "$j" | cut -c1-5)"; rm -rf "$P"
