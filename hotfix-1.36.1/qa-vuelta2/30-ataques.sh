#!/usr/bin/env bash
# QA fase 2 de REQ-032 (hotfix 1.36.1): casos de ruptura propios, fuera del banco.
# Uso: bash 30-ataques.sh <hooks candidata> <hooks v1.36.0>
# Para cada caso: decisión de guard.sh con cada árbol (mismo json, mismo proyecto), el inicio del motivo,
# y el EFECTO REAL: el comando se ejecuta en una copia desechable del proyecto y se dice si cambió algo
# protegido (src/, app/, requirements/) — así un `allow` se juzga por lo que de verdad escribe.
set -u
HC="$1"; HV="$2"
T="$(mktemp -d)"; trap 'chmod -R u+rwx "$T" 2>/dev/null; rm -rf "$T"' EXIT
P="$T/proj"
mk() {   # construye el proyecto de fixture (manifiesto base del banco) en $1
  local p="$1"
  mkdir -p "$p/.arnes" "$p/requirements" "$p/src" "$p/tests" "$p/docs/sub" "$p/docs/tmp"
  cat > "$p/.arnes/config.json" <<'J'
{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
J
  printf '## Pendientes\n\n## Resueltas\n' > "$p/PENDING_APPROVAL.md"
  printf '# REQ-X\nEstado: en-revisión\nQA: pendiente\n' > "$p/requirements/REQ-X.md"
  printf 'n\n' > "$p/docs/notas.md"; printf 'a\n' > "$p/src/a.ts"; printf 'S\n' > "$p/S"
  printf 'dos\n' > "$p/2"                              # un archivo regular llamado «2» en la raíz
  printf 'x\n' > "$p/a.ts"                             # <raíz>/a.ts existe (para `cd src && cp S a.ts`)
  printf 'X\n' > "$p/\$X"                              # un archivo llamado literalmente «$X»
  printf 'h\n' > "$p/docs/hl"; rm -f "$p/docs/hl"; ln "$p/src/a.ts" "$p/docs/hl"   # enlace DURO a src/a.ts
  ln -s ../src/a.ts "$p/docs/enlace-src"; ln -s notas.md "$p/docs/enlace-notas"
  ln -s ../src "$p/docs/dsrc"; ln -s enlace-src "$p/docs/enlace2"            # cadena de enlaces -> src/a.ts
  ln -s ../requirements/REQ-X.md "$p/docs/enlace-req"
  ln -s "$p/src" "$p/docs/dsrc-abs"
  mkfifo "$p/docs/fifo"
  printf 'u\n' > "$p/docs/sub/u.md"
  mkdir -p "$p/src/sub"; printf 'b\n' > "$p/src/sub/b.ts"
}
mk "$P"
huella() { ( cd "$1" && find src app requirements -xtype f -o -type f 2>/dev/null | sort | while read -r f; do printf '%s %s\n' "$f" "$(cat "$f" 2>/dev/null | md5sum | cut -c1-8)"; done; ls -la src requirements 2>/dev/null | awk '{print $1,$NF}' ) | md5sum | cut -c1-8; }
jin() {   # <cwd|-> <agente|-> <comando>
  jq -cn --arg c "$1" --arg a "$2" --arg k "$3" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$k}}
    + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"q32",agent_type:$a} else {} end)'
}
dec() {   # <hooks> <json> [dir del proceso] -> "deny|allow  motivo"
  local out; out="$(cd "${3:-$T}" && printf '%s' "$2" | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) printf 'deny  %s' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<< "$out" | cut -c1-150)";; *) printf 'allow';; esac
}
efecto() {   # <cwd relativo a la raíz> <comando>: ejecútalo en una copia y di si cambió algo protegido
  local c="$T/efecto"; rm -rf "$c"; cp -a "$P" "$c" 2>/dev/null
  # los enlaces absolutos de la copia apuntan al original: se rehacen
  rm -f "$c/docs/dsrc-abs"; ln -s "$c/src" "$c/docs/dsrc-abs"
  # el origen S, también en el cwd del caso (si no, `cp S …` desde docs/ o src/ falla y el efecto saldría «nada» en falso)
  [ -e "$c/$1/S" ] || cp "$c/S" "$c/$1/S"
  local a b; a="$(huella "$c")"
  # timeout: una FIFO sin lector bloquea la escritura real
  T="$c" timeout 5 bash -c 'cd "$1" && eval "$2"' _ "$c/$1" "$2" </dev/null >/dev/null 2>&1
  b="$(huella "$c")"; [ "$a" = "$b" ] && echo "efecto: nada protegido cambió" || echo "efecto: CAMBIÓ algo protegido (src/app/requirements)"
}
n=0
caso() {   # <id> <cwd rel|-> <agente|-> <comando> [dir del proceso]
  local id="$1" cr="$2" ag="$3" cmd="$4" dp="${5:-$T}" cwd j dc dv mov
  if [ "$cr" = - ]; then cwd=-; else cwd="$P${cr:+/$cr}"; fi
  j="$(jin "$cwd" "$ag" "${cmd//@P/$P}")"
  dc="$(dec "$HC" "$j" "$dp")"; dv="$(dec "$HV" "$j" "$dp")"
  mov="="; [ "${dc%% *}" = "${dv%% *}" ] || mov="${dv%% *}->${dc%% *}"
  n=$((n + 1))
  printf '%s | agente=%s | cwd=%s | %s\n   v1.36.0:   %s\n   candidata: %s\n   movimiento: %s\n' "$id" "${ag/#-/coordinadora}" "${cr:-<raíz>}" "$cmd" "$dv" "$dc" "$mov"
  if [ "$cr" != - ]; then printf '   %s\n' "$(efecto "$cr" "${cmd//@P/\$T}")"; fi
}
echo "fecha: $(date -Iseconds)  candidata: $HC  v1.36.0: $HV"
echo "(@P = la raíz del proyecto de fixture; globs src/* y app/*; requirements_dir requirements)"
echo
echo "=== 1. Enlaces (último componente, intermedio, cadenas, absolutos) y rutas equivalentes"
caso E1 "" - 'cp S docs/enlace-src'
caso E2 "" - 'cp S docs/enlace2'
caso E3 "" - 'cp S docs/dsrc/a.ts'
caso E4 "" - 'cp S docs/dsrc-abs/a.ts'
caso E5 "" - 'cp S docs/dsrc/../docs/notas.md'
caso E6 "" - 'cp S @P/docs/../src/a.ts'
caso E7 "" - 'cp S ./src/./a.ts'
caso E8 "" - 'cp S @P//src///a.ts'
caso E9 "docs" - 'cp S ../src/a.ts'
caso E10 "docs/sub" - 'cp S ../../src/a.ts'
caso E11 "" qa-tester 'mv S docs/enlace-src'
caso E12 "" - 'install S docs/enlace-src'
caso E13 "" - 'cp S docs/enlace-req && echo completado'
caso E14 "" desarrollador 'cp S docs/enlace-req && echo completado'
caso E15 "" - 'cp S docs/hl'
caso E16 "" - 'cp S src/sub/b.ts'
caso E17 "src" - 'cp S a.ts'
caso E18 "" - 'cp S src/a.ts/'
echo
echo "=== 2. cwd de la entrada frente al del proceso"
mkdir -p "$T/proc"; printf 'x\n' > "$T/proc/notas.md"; mkdir -p "$T/proc/src"
caso W1 "" - 'cp S src' "$T/proc"
mkdir -p "$T/proc2"; printf 'f\n' > "$T/proc2/src"
caso W2 "" - 'cp S src' "$T/proc2"
caso W3 "docs" - 'cp S notas.md' "$P/src"
caso W4 "src" - 'cp S a.ts' "$P/docs"
caso W5 - - 'cp S @P/src/a.ts'
caso W6 - - 'cp S @P/docs/notas.md'
echo
echo "=== 3. Tipos especiales"
caso X1 "" - 'cp S docs/fifo'
caso X2 "" - 'cp S /dev/null'
caso X3 "" - 'cp S /dev/stdout'
caso X4 "" - 'cp S /dev/fd/1'
caso X5 "" - 'cp S /proc/self/fd/1'
echo
echo "=== 4. La marca (tabulador) fabricada por quien escribe el comando"
caso M1 "" - "$(printf 'cp S\t\tsrc/a.ts')"
caso M2 "" - "$(printf 'cp S \tdocs/notas.md')"
caso M3 "" - "$(printf 'echo x >\tsrc/a.ts')"
caso M4 "" - 'cp S $'"'"'\t'"'"'src/a.ts'
caso M5 "" - "$(printf 'cp S \t')"
caso M6 "" - "$(printf 'cp S src/a.ts\t# docs/notas.md')"
echo
echo "=== 5. -t, --target-directory, grupos cortos y sus disfraces"
caso T1 "" - 'cp -t src docs/notas.md'
caso T2 "" - 'cp -tsrc docs/notas.md'
caso T3 "" - 'cp -avt src docs/notas.md'
caso T4 "" - 'cp --target-directory src docs/notas.md'
caso T5 "" - 'cp --target-dir=src docs/notas.md'
caso T6 "" - 'cp --ta=src docs/notas.md'
caso T7 "" - 'cp "-t" src docs/notas.md'
caso T8 "" - "cp '-t' src docs/notas.md"
caso T9 "" - 'cp \-t src docs/notas.md'
caso T10 "" - 'cp -""t src docs/notas.md'
caso T11 "" - 'cp "--target-directory=src" docs/notas.md'
caso T12 "" - 'T=-t; cp $T src docs/notas.md'
caso T13 "" - 'mv "-t" src docs/notas.md'
caso T14 "" - 'install "-t" src docs/notas.md'
caso T15 "" qa-tester 'cp "-t" src docs/notas.md'
caso T16 "" - 'cp -T S docs/notas.md'
caso T17 "" - 'cp --no-target-directory S docs/notas.md'
caso T18 "" - 'cp -t src -- docs/notas.md'
echo
echo "=== 6. El operando que el detector toma por destino NO es el destino (formas vecinas)"
caso V1 "" - 'cp S src/a.ts 2>/dev/null'
caso V2 "" - 'cp S src/a.ts 2>&1'
caso V3 "" - 'cp S src/a.ts # docs/notas.md'
caso V4 "" - 'cp S src/a.ts #docs/notas.md'
caso V5 "" - 'cp S src/a.ts </dev/null docs/notas.md'
caso V6 "" - 'cp S src/a.ts < docs/notas.md'
caso V7 "" - 'cp S src/a.ts 2>docs/notas.md'
caso V8 "" - 'cp S src/a.ts & cp S docs/notas.md'
caso V9 "" - 'cp S "src/a.ts" docs/notas.md'
caso V10 "" - 'cp S src/a.ts 2>/dev/null; true'
echo
echo "=== 7. F-137-13: las tres formas"
caso F1 "" - 'mv src/a.ts docs/notas.md'
caso F1b "" - 'mv src/a.ts docs/nuevo.md'
caso F1c "" qa-tester 'mv src/a.ts docs/notas.md'
caso F2 "" - 'cd src && cp S a.ts'
caso F2b "" - 'cd src && cp S nuevo.ts'
caso F3 "" - 'cp S $X'
caso F3b "" - 'X=src/a.ts; cp S $X'
echo
echo "=== 8. El cierre de un REQ por cp (CA-05) y sus variantes"
caso C1 "" - 'cp S requirements/REQ-X.md && echo completado'
caso C2 "" desarrollador 'cp S requirements/REQ-X.md && echo completado'
caso C3 "requirements" - 'cp S REQ-X.md # completado'
caso C4 "" - 'cp S ./requirements/../requirements/REQ-X.md; echo COMPLETADO'
caso C5 "" - 'mv S requirements/REQ-X.md && echo completado'
caso C6 "" - 'install S requirements/REQ-X.md && echo completado'
caso C7 "" - 'cp S requirements && echo completado'
caso C8 "" - 'cp "-t" requirements docs/notas.md && echo completado'
echo
echo "=== 9. Manifiesto roto"
P0="$P"; P="$T/roto"; mkdir -p "$P/.arnes" "$P/docs" "$P/src"; printf '{ "codigo_app": ' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf 'n\n' > "$P/docs/notas.md"; printf 'S\n' > "$P/S"
caso R1 "" - 'cp S docs/notas.md'
caso R2 "" - 'cp S .arnes/config.json'
caso R3 "" desarrollador 'cp S docs/notas.md'
caso R4 "" - 'ls -la'
P="$P0"
echo
echo "casos: $n"
