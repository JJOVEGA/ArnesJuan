#!/usr/bin/env bash
# SEC-115 / SEC-118 / SEC-129, paso 6 de 1.36.0, fase 1: sonda a nivel de hook (fuera del banco).
# Uso: 01-sonda.sh <scratch> <vector> <dir-hooks> [timeout_s] [modo]
#   vector: un nombre de `vector` (abajo). modo: normal (por defecto) | jqlog (mide lo que el hook
#   INTENTA emitir: una función `jq` exportada envuelve al binario, mide en bytes el `--arg` del motivo
#   o del aviso y el JSON que habría salido, y llama al binario igual que antes).
# Imprime UNA línea: vector, árbol, decisión, rc, ms, bytes de salida, efecto (c), motivo (200 car.).
set -u
S="${1:?scratch}"; V="${2:?vector}"; H="${3:?hooks}"; TO="${4:-60}"; MODO="${5:-normal}"
W="$(mktemp -d "$S/s-XXXX")"; trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
jq -nc '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*","app/*"]},quality_gates:["true"],estados:{completado:"completado"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
R="$P/requirements/REQ-950.md"
cab() { printf '# REQ-950\nEstado: %s\nQA: %s\nSeguridad: %s\nSensible a seguridad: sí\nRigor: critico\n' "$1" "$2" "$3"; }
rep() { local i; for ((i = 0; i < $1; i++)); do printf '%s' "$2"; done; }
# Una línea `Hallazgos abiertos: <v>` repetida N veces, en una cabecera que, salvo eso, cerraría.
hall() { { cab completado aprobado aprobado; for ((i = 0; i < $1; i++)); do printf 'Hallazgos abiertos: %s\n' "$2"; done; printf '\n## Texto\nx\n'; } > "$W/doc"
         cab en-revisión aprobado aprobado > "$R"; printf '\n## Texto\nx\n' >> "$R"
         jq -Rs --arg fp "$R" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$W/doc" > "$W/in"; }
# Edit de la coordinadora: old -> new sobre el REQ en disco (los textos por archivo: pueden pasar de 128 KB).
editj() { jq -n --rawfile o "$W/old" --rawfile n "$W/new" --arg fp "$R" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:$n}}' > "$W/in"; }
writej() { jq -Rs --arg fp "$R" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$W/doc" > "$W/in"; }
L60="QA-1 (instrumento, $(rep 40 r))"            # línea de 20+46 = 66 caracteres ASCII
CORTA='(ninguno)'                                  # línea de 29 caracteres ASCII
N2="QA-1 (instrumento, $(rep 40 ñ))"             # 66 caracteres, los 40 últimos de 2 bytes
N4="QA-1 (instrumento, $(rep 40 𝄞))"             # 66 caracteres, los 40 últimos de 4 bytes
CN="$(rep 12 ñ)"                                   # línea de 32 caracteres, 44 bytes
grande() { case "$1" in a) rep 143360 x ;; 2) rep 71680 ñ ;; 4) rep 35840 𝄞 ;; esac; }   # ~140 KB
case "$V" in
  h-ascii60-1601) hall 1601 "$L60" ;;   h-ascii60-1801) hall 1801 "$L60" ;;
  h-corta-2501)   hall 2501 "$CORTA" ;; h-corta-3000)   hall 3000 "$CORTA" ;;
  h-n2-1601)      hall 1601 "$N2" ;;    h-n4-1001)      hall 1001 "$N4" ;;   h-cn-2501) hall 2501 "$CN" ;;
  qa140|seg140|qa140-aviso*|seg140-aviso*)
    cab en-revisión pendiente pendiente > "$R"; printf '\n## Texto\nx\n' >> "$R"
    k=QA; [[ $V == seg* ]] || :; [[ $V != seg* ]] || k=Seguridad
    c=a; case "$V" in *-aviso-2) c=2 ;; *-aviso-4) c=4 ;; esac
    if [[ $V == *aviso* ]]; then printf '%s: pendiente' "$k" > "$W/old"; { printf '%s: pendiente ' "$k"; grande "$c"; } > "$W/new"
    else printf 'Estado: en-revisión\nQA: pendiente\nSeguridad: pendiente' > "$W/old"
      if [ "$k" = QA ]; then { printf 'Estado: completado\nQA: pendiente '; grande a; printf '\nSeguridad: pendiente'; } > "$W/new"
      else { printf 'Estado: completado\nQA: aprobado\nSeguridad: pendiente '; grande a; } > "$W/new"; fi
    fi; editj ;;
  sens140)
    cab en-revisión aprobado pendiente > "$R"; printf '\n## Texto\nx\n' >> "$R"
    printf 'Estado: en-revisión\nQA: aprobado\nSeguridad: pendiente\nSensible a seguridad: sí' > "$W/old"
    { printf 'Estado: completado\nQA: aprobado\nSeguridad: pendiente\nSensible a seguridad: quizá '; grande a; } > "$W/new"; editj ;;
  cr140)
    cab en-revisión aprobado aprobado > "$R"; printf '\n## Texto\nx\n' >> "$R"
    printf 'Estado: en-revisión' > "$W/old"
    { printf 'Estado: completado\nNota sin dos puntos '; rep 71680 x; printf '\r'; rep 71680 x; } > "$W/new"; editj ;;
  t1)   # R-044-C §2 vía (a): QA: pendiente (…) con ~255 KB de evidencia con blancos, Edit a completado
    { printf '# REQ-950\nEstado: en-revisión\nQA: pendiente ('; rep 25500 'evidencia '; printf ')\nSeguridad: pendiente\nRigor: critico\n\n## Texto\nx\n'; } > "$R"
    printf 'Estado: en-revisión' > "$W/old"; printf 'Estado: completado' > "$W/new"; editj ;;
  t1b)  # exploratoria, NO es T1: la misma evidencia SIN paréntesis (se normaliza el valor entero)
    { printf '# REQ-950\nEstado: en-revisión\nQA: pendiente '; rep 25500 'evidencia '; printf '\nSeguridad: pendiente\nRigor: critico\n\n## Texto\nx\n'; } > "$R"
    printf 'Estado: en-revisión' > "$W/old"; printf 'Estado: completado' > "$W/new"; editj ;;
  t2-2m|t2-1m)  # R-044-C §2 vía (b): Write con la cabecera pendiente, de 2 025 113 / 1 012 650 bytes
    obj=2025113; [ "$V" = t2-1m ] && obj=1012650
    cab en-revisión pendiente pendiente > "$R"
    { cab completado pendiente pendiente; printf '\n## Texto\n'; } > "$W/doc"
    lin="$(rep 7 'relleno de cuerpo ')"; lin="${lin:0:79}"; n=$(( (obj - $(wc -c < "$W/doc")) / 80 ))
    for ((i = 0; i < n; i++)); do printf '%s\n' "$lin"; done >> "$W/doc"
    f=$(( obj - $(wc -c < "$W/doc") )); [ "$f" -le 0 ] || { rep $((f - 1)) z; printf '\n'; } >> "$W/doc"
    writej ;;
  t3-*) # R-045-A §5: búsqueda literal del old_string (procedimiento 00-procedimiento-t3.txt)
    L="${V#t3-}"; h=$(( L / 2 ))
    { printf '# REQ-950 '; rep "$L" a; printf '\n'; cab en-revisión pendiente pendiente | tail -n +2; printf '\n## Texto\nx\n'; } > "$R"
    { rep "$h" a; printf '\nEstado: en-revisión'; } > "$W/old"; { rep "$h" a; printf '\nEstado: completado'; } > "$W/new"; editj ;;
  *) echo "vector desconocido: $V" >&2; exit 2 ;;
esac
ant="$(sha256sum < "$R")"; tam="$(wc -c < "$W/in")"
JQLOG="$W/jqlog"; : > "$JQLOG"
(
  cd "$P"; unset LC_ALL POSIXLY_CORRECT BASH_ENV; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"
  if [ "$MODO" = jqlog ]; then
    export SONDA_JQLOG="$JQLOG"
    jq() {
      local i r='' k='' a
      for ((i = 1; i < $#; i++)); do a="${!i}"; if [ "$a" = --arg ]; then local j=$((i + 1)) l=$((i + 2)); k="${!j}"; r="${!l}"; fi; done
      if [ -n "$r" ] && [[ "$*" == *permissionDecisionReason* || "$*" == *systemMessage* ]]; then
        local LC_ALL=C nb sal; nb=${#r}
        sal="$(printf '%s' "$r" | command jq -Rsc 'if ($k=="m") then {systemMessage:.} else {hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:.}} end' --arg k "$k" | wc -c)"
        printf 'arg=%s motivo_bytes=%s salida_bytes=%s\n' "$k" "$nb" "$sal" >> "$SONDA_JQLOG"
      fi
      command jq "$@"
    }
    export -f jq
  fi
  t0=${EPOCHREALTIME/./}; timeout "$TO" bash "$H/guard.sh" < "$W/in" > "$W/out" 2> "$W/err"; rc=$?; t1=${EPOCHREALTIME/./}
  printf '%s %s\n' "$rc" "$(( (t1 - t0) / 1000 ))" > "$W/rc"
)
read -r rc ms < "$W/rc"; ob="$(wc -c < "$W/out")"
d=nada; grep -q '"permissionDecision":"deny"' "$W/out" && d=deny
av=no; grep -q '"systemMessage"' "$W/out" && av=si
jv=no; [ -s "$W/out" ] && jq -e . "$W/out" >/dev/null 2>&1 && jv=si
mot="$(jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // empty' "$W/out" 2>/dev/null | head -c 200 | tr '\n\r' '  ')"
desp="$(sha256sum < "$R")"; ef=igual; [ "$ant" = "$desp" ] || ef=CAMBIADO
printf '%-16s %-34s dec=%-4s aviso=%s rc=%-3s ms=%-6s salida=%sB json=%s entrada=%sB disco=%s' "$V" "${H%/hooks}" "$d" "$av" "$rc" "$ms" "$ob" "$jv" "$tam" "$ef"
[ ! -s "$JQLOG" ] || printf ' intento[%s]' "$(tr '\n' ';' < "$JQLOG")"
[ ! -s "$W/err" ] || printf ' stderr[%s]' "$(head -c 160 "$W/err" | tr '\n' '|')"
printf ' motivo<%s>\n' "$mot"
