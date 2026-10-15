#!/usr/bin/env bash
# QA fase 2 de REQ-032: confirmación de QA-032-01 sobre un proyecto LIMPIO (sin archivos-señuelo salvo
# los que cada caso declara), y la línea base de cada forma cuando el operando que toma el detector NO
# es un archivo regular existente (¿ya estaba abierta en v1.36.0?).
# Uso: bash 32-confirmacion.sh <hooks candidata> <hooks v1.36.0>
set -u
HC="$1"; HV="$2"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
nuevo() {   # proyecto limpio en $T/p<n>: manifiesto base del banco; src/a.ts, docs/notas.md, docs/sub/, S
  P="$T/p$1"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs/sub"
  printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '# REQ-X\nEstado: en-revisión\nQA: pendiente\n' > "$P/requirements/REQ-X.md"
  printf 'n\n' > "$P/docs/notas.md"; printf 'a\n' > "$P/src/a.ts"; printf 'S\n' > "$P/S"; printf 'u\n' > "$P/docs/sub/u.md"
}
dec() { local out; out="$(cd "$T" && jq -cn --arg c "$P" --arg k "$2" --arg a "$3" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}} + (if $a != "-" then {agent_id:"q",agent_type:$a} else {} end)' | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"
  case "$out" in *'"deny"'*) echo deny ;; *) echo allow ;; esac; }
n=0
caso() {   # <id> <preparación (eval en $P)|-> <comando> [agente]
  n=$((n + 1)); nuevo "$n"; [ "$2" = - ] || ( cd "$P" && eval "$2" )
  local dv dc a b
  dv="$(dec "$HV" "$3" "${4:--}")"; dc="$(dec "$HC" "$3" "${4:--}")"
  a="$(cat "$P/src/a.ts"; ls "$P/src" | tr '\n' ' ')"
  ( cd "$P" && timeout 5 bash -c "$3" ) </dev/null >/dev/null 2>&1
  b="$(cat "$P/src/a.ts" 2>/dev/null; ls "$P/src" | tr '\n' ' ')"
  local ef='src/ intacto'; [ "$a" = "$b" ] || ef="src/ CAMBIA ($(ls "$P/src" | tr '\n' ' '); a.ts=$(cat "$P/src/a.ts" 2>/dev/null | head -c 20 | tr '\n' ' '))"
  printf '%-5s v1.36.0=%-5s candidata=%-5s %-34s | prep: %-28s | %s  [%s]\n' "$1" "$dv" "$dc" "$ef" "$2" "$3" "${4:-coordinadora}"
}
echo "fecha: $(date -Iseconds)  candidata: $HC  v1.36.0: $HV  (cwd de la entrada = raíz del proyecto)"
echo "--- (a) redirección de stdin: el detector toma el archivo de entrada por destino"
caso A1 - 'cp S src/a.ts < docs/notas.md'
caso A2 - 'cp S src/a.ts < /dev/null'
caso A3 - 'cp S src/a.ts < S'
caso A4 - 'cp S src/a.ts < docs/notas.md' qa-tester
caso A5 - 'mv S src/a.ts < docs/notas.md'
caso A6 - 'install S src/a.ts < docs/notas.md'
caso A7 - 'cp S src/nuevo.ts < docs/notas.md'
echo "--- (b) redirección con descriptor numérico: el detector toma el número por destino"
caso B1 - 'cp S src/a.ts 2>/dev/null'
caso B2 'printf x > 2' 'cp S src/a.ts 2>/dev/null'
caso B3 'printf x > 2' 'cp S src/a.ts 2>&1'
caso B4 - 'cp S src/a.ts 2>&1'
echo "--- (c) comentario final: el detector toma la última palabra del comentario por destino"
caso C1 - 'cp S src/a.ts # nada'
caso C2 - 'cp S src/a.ts  # copia de docs/notas.md'
caso C3 - 'cp S src/a.ts # ver S'
caso C4 - 'cp S src/a.ts # ver docs/sub'
echo "--- (d) -t disfrazado: el detector toma el último origen por destino y no ve el -t"
caso D1 - 'cp -t src docs/notas.md'
caso D2 - 'cp "-t" src docs/notas.md'
caso D3 - 'cp -r -t src docs/sub'
caso D4 - 'cp -r "-t" src docs/sub'
caso D5 - 'cp -rt src docs/sub'
caso D6 - 'cp \-t src S'
caso D7 - "cp '--target-directory=src' S"
caso D8 - 'T=-t; cp $T src S'
caso D9 - 'cp -t src docs/nuevo.md'
echo "--- (e) enlace DURO a un archivo protegido, fuera del ámbito: oráculo cat > frente a cp"
caso E1 'ln src/a.ts docs/hl' 'cat S > docs/hl'
caso E2 'ln src/a.ts docs/hl' 'cp S docs/hl'
echo "--- (f) F-137-13"
caso F1 - 'mv src/a.ts docs/notas.md'
caso F2 - 'mv src/a.ts docs/nuevo.md'
caso F3 'printf x > a.ts' 'cd src && cp S a.ts'
caso F4 - 'cd src && cp ../S a.ts'
caso F5 'printf x > a.ts' 'cd src && cp ../S a.ts'
caso F6 'printf x > "\$X"' 'X=src/a.ts; cp S $X'
caso F7 - 'X=src/a.ts; cp S $X'
caso F8 'printf x > "\$X"' 'cp S $X'
echo "casos: $n"
echo "--- (g) hermanas preexistentes de (a): la entrada estándar desde un directorio (bash la abre y cp corre)"
caso G1 - 'cp S src/a.ts < docs/sub'
caso G2 - 'cp S src/a.ts < docs'
echo "casos: $n"
