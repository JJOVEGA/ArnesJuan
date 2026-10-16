# Sección 49 del banco — 49-manifiesto-y-origen-de-mv
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# Hotfix 1.36.2, REQ-033: nadie borra, mueve ni vacía `.arnes/config.json` (CA-01), y el ORIGEN de `mv` se
# juzga como una escritura de ese archivo (CA-02). Alcance del propietario: sólo el manifiesto y el origen de
# `mv`; `rm`/`unlink`/`git rm` de otros archivos y las formas de SEC-135 no entran (CA-08).
#   A1–A5  CA-03: la tabla del REQ, con sus variantes de la misma propiedad (A1b, A3b, A3w, A4q, A5q, U1) ·
#   C      CA-04: los controles, que deciden igual en los dos árboles · PROC  CA-06: procesos y reloj.
# DOS ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`) y v1.36.1 (e21baef), por SHA con `mat49` (copia de
# `mat48`); sin ella, SKIP y motivo, nunca PASS. Se juzga por guard.sh, lo que recibe el cliente. El proyecto
# protege `hooks/*` y `src/*` y NO incluye el manifiesto en sus globs: es la forma de un proyecto consumidor.
CASOS_ESPERADOS_SECCION=90
PISO_AUTONOMO_SECCION=72  # 14 preámbulo (líneas 1-14, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO49, mat49_reg y mat49, copia de mat48, líneas 15-38) + 34 bloque indivisible mayor (proyecto, j49, w49, g49, juicio49 y fila49, líneas 43-76)
seccion_nueva "--- 49 · el manifiesto no se retira ni se vacía; el origen de mv es una escritura (REQ-033, hotfix 1.36.2) ---"
REPO49="${SEC_DIR%/}/../../../.."; MAT49_RUTAS='hooks'; MAT49_REG=''; MAT49_T0=0; MAT49_REF='-'
mat49_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT49_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT49_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT49_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT49_T0 )) procesos=$4 etiqueta=$MAT49_REF ref=$MAT49_REF archivos=$3"
}
# mat49 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat49() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT49_T0=${EPOCHREALTIME/./}; MAT49_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO49" ls-tree -r "$ref" -- $MAT49_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat49_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO49" archive "$ref" $MAT49_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat49_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO49" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat49_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat49_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat49_reg ok - "$n" 6
}
RV49="$RAIZ/rv1361-49-$BASHPID"; RV49_OK=no; RV49_MOT=''
if mat49 e21baef "$RV49"; then RV49_OK=si
else RV49_MOT="v1.36.1 (e21baef) no se materializó (${MAT49_REG#*motivo=})"; RV49_MOT="${RV49_MOT%% corrida=*})"; fi
v49() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
# El proyecto: globs `hooks/*` y `src/*`, un archivo protegido (`hooks/lib.sh`) y dos fuera de todo ámbito.
P49="$PROJ"; PD49="$P49"; M49="$P49/.arnes/config.json"
jq '.codigo_app.globs = ["hooks/*", "src/*"]' <<< "$MANIFIESTO_BASE" > "$M49"
mkdir -p "$P49/hooks"; printf 'l\n' > "$P49/hooks/lib.sh"; printf 'p\n' > "$P49/docs/PLAN.md"; printf 'n\n' > "$P49/docs/notas.md"
MC49="$(cat "$M49")"   # el contenido del manifiesto, para el Write de control
j49() {   # <agente|-> <comando> -> la entrada de Bash con cwd en la raíz y el agente como subagente real
  jq -cn --arg c "$P49" --arg a "$1" --arg k "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}
    + (if $a != "-" then {agent_id:"a49",agent_type:$a} else {} end)'
}
w49() {   # <agente|-> <file_path> <contenido> -> la entrada de un Write
  jq -cn --arg c "$P49" --arg a "$1" --arg f "$2" --arg t "$3" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$f,content:$t}}
    + (if $a != "-" then {agent_id:"a49",agent_type:$a} else {} end)'
}
D49=''; M49D=''
g49() {   # <dir de hooks> <json> -> D49 (deny|allow) y M49D (el motivo)
  local out; D49=''; M49D=''; [ -n "$2" ] || return 1
  out="$(cd "$P49" && printf '%s' "$2" | CLAUDE_PROJECT_DIR="$PD49" bash "$1/guard.sh" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D49=deny ;; *) D49=allow ;; esac
  [ "$D49" = allow ] || M49D="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
juicio49() {   # <nombre> <allow|deny> <cita|-> — sobre D49/M49D; la cita se exige al motivo de un deny
  if [ "$D49" != "$2" ]; then v49 FAIL "$1  esperado=$2 got=$D49  <${M49D:0:220}>"
  elif [ "$2" = deny ] && [ "$3" != - ] && [[ "$M49D" != *"$3"* ]]; then v49 FAIL "$1  el motivo no cita «$3»  <${M49D:0:240}>"
  else v49 PASS "$1  ($D49)"; fi
}
# fila49 <id> <candidata> <v1.36.1> <cita candidata|-> <json>: un caso por árbol, en la misma corrida.
fila49() {
  local nom="REQ-033 $1" ec="$2" ev="$3" cc="$4" json="$5" etq='control, decide igual'
  [ "$ec:$ev" != deny:allow ] || etq='fail-before'
  if ! json_no_vacio "$nom" "$json"; then v49 FAIL "$nom v1.36.1  la entrada salió vacía: no se midió"; return 0; fi
  g49 "$HOOKS_DIR" "$json"; juicio49 "$nom candidata" "$ec" "$cc"
  if [ "$RV49_OK" != si ]; then v49 SKIP "$nom v1.36.1 ($etq)  $RV49_MOT"; return 0; fi
  g49 "$RV49/hooks" "$json"; juicio49 "$nom v1.36.1 ($etq)" "$ev" -
}
MF49='manifiesto'; SRC49='código de la app'; ND49='no se pudo determinar a que archivo escribe'

# --- A1–A3: CA-01 — retirar o vaciar el manifiesto, a todo agente (también al de código) ---------------------------
for a in - desarrollador; do
  q="${a/#-/coordinadora}"
  fila49 "A1 $q: rm .arnes/config.json" deny allow "$MF49" "$(j49 "$a" 'rm .arnes/config.json')"
  fila49 "A2 $q: mv .arnes/config.json docs/config.json" deny allow "$MF49" "$(j49 "$a" 'mv .arnes/config.json docs/config.json')"
done
fila49 "A1b desarrollador: unlink .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador 'unlink .arnes/config.json')"
fila49 "A1b desarrollador: git rm -q .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador 'git rm -q .arnes/config.json')"
fila49 "A1b desarrollador: rm -f $P49/.arnes/config.json (ruta absoluta)" deny allow "$MF49" "$(j49 desarrollador "rm -f $P49/.arnes/config.json")"
fila49 "A1b desarrollador: rm -rf .arnes (el directorio que lo contiene)" deny allow "$MF49" "$(j49 desarrollador 'rm -rf .arnes')"
fila49 "A1b desarrollador: mv .arnes .arnes-off (el directorio que lo contiene)" deny allow "$MF49" "$(j49 desarrollador 'mv .arnes .arnes-off')"
fila49 "A1b qa-tester: rm docs/../.arnes/config.json (ruta equivalente)" deny allow "$MF49" "$(j49 qa-tester 'rm docs/../.arnes/config.json')"
fila49 "A3 desarrollador: : > .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador ': > .arnes/config.json')"
fila49 "A3b desarrollador: > .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador '> .arnes/config.json')"
fila49 "A3b desarrollador: truncate -s 0 .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador 'truncate -s 0 .arnes/config.json')"
fila49 "A3b desarrollador: cp /dev/null .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador 'cp /dev/null .arnes/config.json')"
fila49 "A3b desarrollador: echo {} | tee .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador 'echo {} | tee .arnes/config.json')"
fila49 "A3b desarrollador: sed -i s/a/b/ .arnes/config.json" deny allow "$MF49" "$(j49 desarrollador 'sed -i s/a/b/ .arnes/config.json')"
fila49 "A3b coordinadora: : > .arnes/config.json" deny allow "$MF49" "$(j49 - ': > .arnes/config.json')"
fila49 "A3w desarrollador: Write de .arnes/config.json con contenido vacío" deny allow "$MF49" "$(w49 desarrollador "$M49" '')"
fila49 "A3w desarrollador: Write de .arnes/config.json con sólo blancos" deny allow "$MF49" "$(w49 desarrollador "$M49" $' \n')"

# --- A4, A5, U1: CA-02 — el origen de `mv` se juzga como escritura -----------------------------------------------------
for a in - qa-tester; do
  q="${a/#-/coordinadora}"
  fila49 "A4 $q: mv hooks/lib.sh docs/x.md (destino inexistente)" deny allow "$SRC49" "$(j49 "$a" 'mv hooks/lib.sh docs/x.md')"
  fila49 "A5 $q: mv hooks/lib.sh docs/PLAN.md (destino existente)" deny allow "$SRC49" "$(j49 "$a" 'mv hooks/lib.sh docs/PLAN.md')"
  fila49 "A4 $q: mv -f docs/notas.md hooks/lib.sh /tmp (varios orígenes)" deny allow "$SRC49" "$(j49 "$a" 'mv -f docs/notas.md hooks/lib.sh /tmp')"
  fila49 "U1 $q: mv nada/../hooks/lib.sh docs/y.md (origen no determinable)" deny allow "$ND49" "$(j49 "$a" 'mv nada/../hooks/lib.sh docs/y.md')"
done

# --- C: CA-04 — lo legítimo decide igual en los dos árboles -----------------------------------------------------------
for a in - qa-tester desarrollador; do
  q="${a/#-/coordinadora}"
  fila49 "C1 $q: mv docs/notas.md docs/otra.md (nada protegido)" allow allow - "$(j49 "$a" 'mv docs/notas.md docs/otra.md')"
  fila49 "C3 $q: cat .arnes/config.json (lectura)" allow allow - "$(j49 "$a" 'cat .arnes/config.json')"
  fila49 "C6 $q: rm docs/notas.md (no protegido)" allow allow - "$(j49 "$a" 'rm docs/notas.md')"
done
fila49 "C2 desarrollador: mv hooks/lib.sh hooks/lib2.sh (el agente de código mueve código)" allow allow - "$(j49 desarrollador 'mv hooks/lib.sh hooks/lib2.sh')"
fila49 "C2 desarrollador: mv hooks/lib.sh docs/x.md" allow allow - "$(j49 desarrollador 'mv hooks/lib.sh docs/x.md')"
fila49 "C3 desarrollador: jq . .arnes/config.json (lectura)" allow allow - "$(j49 desarrollador 'jq . .arnes/config.json')"
fila49 "C4 desarrollador: Write de .arnes/config.json con contenido" allow allow - "$(w49 desarrollador "$M49" "$MC49")"
fila49 "C5 coordinadora: printf x > hooks/lib.sh (código protegido)" deny deny "$SRC49" "$(j49 - 'printf x > hooks/lib.sh')"
fila49 "C6 coordinadora: rm hooks/lib.sh (rm de otros archivos no cambia en 1.36.2, CA-08)" allow allow - "$(j49 - 'rm hooks/lib.sh')"
fila49 "C7 coordinadora: mv docs/notas.md hooks/x.sh (destino protegido, origen no)" deny deny "$SRC49" "$(j49 - 'mv docs/notas.md hooks/x.sh')"
fila49 "C7 desarrollador: mv docs/notas.md hooks/x.sh (destino protegido, origen no)" allow allow - "$(j49 desarrollador 'mv docs/notas.md hooks/x.sh')"

# --- PROC: CA-06 — procesos frente a v1.36.1 en la misma corrida, y el reloj ----------------------------------------
# Camino común (`ls -la`): 0 añadidos, de contrato. La rama de `mv` y la del manifiesto: techo de 1 añadido.
# Donde la candidata DENIEGA y v1.36.1 permitía, el techo suma la emisión del deny (un `jq`), que v1.36.1 no pagaba.
nom49="REQ-033 PROC CA-06 procesos frente a v1.36.1: ls -la no añade ninguno; mv, rm y Write del manifiesto, como mucho 1 (+1 de la emisión donde la candidata deniega y v1.36.1 permitía)"
if [ "$RV49_OK" != si ]; then v49 SKIP "$nom49  $RV49_MOT"; v49 SKIP "REQ-033 RELOJ CA-06  $RV49_MOT"
else
  f49="$RAIZ/j49-$BASHPID.json"; mal49=''; med49=''; malr49=''; medr49=''; bajo49=''
  # <techo añadido>|<B: Bash de la coordinadora; W: Write vacío; C: Write con contenido, del desarrollador>|<comando o ruta>
  pk49=("0|B|ls -la" "1|B|mv docs/notas.md docs/otra.md" "1|B|rm docs/notas.md" "1|C|$M49"
        "2|B|mv hooks/lib.sh docs/PLAN.md" "2|B|rm .arnes/config.json" "2|W|$M49")
  for k49 in "${pk49[@]}"; do
    x49="${k49%%|*}"; k49="${k49#*|}"
    case "${k49%%|*}" in
      W) printf '%s' "$(w49 desarrollador "${k49#*|}" '')" > "$f49" ;;
      C) printf '%s' "$(w49 desarrollador "${k49#*|}" "$MC49")" > "$f49" ;;
      *) printf '%s' "$(j49 - "${k49#*|}")" > "$f49" ;;
    esac
    k49="${k49#*|}"
    pr49=''; rl49=''
    [ -s "$f49" ] || { mal49+=" $k49: la entrada salió vacía, no midió"; continue; }
    for h49 in "$HOOKS_DIR" "$RV49/hooks"; do
      r49="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "49-procesos" \
        --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git readlink realpath cygpath find stat' \
        --sujeto "CLAUDE_PROJECT_DIR='$P49' bash '$h49/guard.sh' < '$f49'" 2>/dev/null)"
      if sonda_lee "$r49" && [ "${SONDA[estado]}" = ok ]; then pr49+="${SONDA[cuenta]:-x} "; else pr49+="x "; mal49+=" $k49: la sonda no midió (${SONDA_MOTIVO:-${SONDA[motivo]:-?}})"; fi
      mn49=''
      for _ in 1 2 3 4 5; do
        t049=${EPOCHREALTIME/./}; CLAUDE_PROJECT_DIR="$P49" bash "$h49/guard.sh" < "$f49" >/dev/null 2>&1; t149=$(( ${EPOCHREALTIME/./} - t049 ))
        [ -n "$mn49" ] && [ "$mn49" -le "$t149" ] || mn49=$t149
      done
      rl49+="$mn49 "
    done
    read -r pc49 pb49 <<< "$pr49"; read -r rc49 rb49 <<< "$rl49"; k49="${k49/"$P49"/<raíz>}"
    med49+=" «$k49» $pc49/$pb49"; medr49+=" «$k49» $((rc49 / 1000))/$((rb49 / 1000)) ms"
    case "$pc49$pb49" in *x*) ;; *) [ "$pc49" -le $(( pb49 + x49 )) ] || mal49+=" «$k49»: $pc49 > $pb49 + $x49" ;; esac
    # El reloj se juzga donde la candidata gasta los MISMOS procesos que v1.36.1 en la misma corrida. Donde
    # añade el declarado —el `jq` del Write del manifiesto, la emisión de un deny nuevo— la cifra se anota sin
    # juzgar: en Linux un `jq` cuesta de 8 a 14 ms sobre una base de 30 a 55 ms, y con él el 1,25× no es medible.
    if [ "$pc49" != "$pb49" ]; then :
    elif [ "$rb49" -lt 50000 ]; then bajo49+=" «$k49» ($((rb49 / 1000)) ms)"
    elif [ $(( rc49 * 100 )) -gt $(( rb49 * 125 )) ]; then malr49+=" «$k49»: $rc49 us > 1,25 × $rb49 us"; fi
  done
  rm -f "$f49"
  case "$mal49" in *'no midió'*) v49 SKIP "$nom49 $mal49" ;; '') v49 PASS "$nom49 (candidata/v1.36.1:$med49)" ;; *) v49 FAIL "$nom49 $mal49 (candidata/v1.36.1:$med49)" ;; esac
  nomr49="REQ-033 RELOJ CA-06 (operativo): con los mismos procesos que v1.36.1, el mínimo de 5 de la candidata no pasa de 1,25 × el de v1.36.1; donde añade un proceso declarado, se anota"
  # Un camino sobre el suelo que pasa del 1,25 × es FAIL aunque otro quede bajo el suelo; bajo el suelo, SKIP.
  if [ -n "$malr49" ]; then v49 FAIL "$nomr49 $malr49 (candidata/v1.36.1:$medr49)"
  elif [ -n "$bajo49" ]; then v49 SKIP "$nomr49  bajo el suelo de 50 ms en v1.36.1:$bajo49; no acredita (candidata/v1.36.1:$medr49)"
  else v49 PASS "$nomr49 (candidata/v1.36.1:$medr49)"; fi
fi
rm -rf "$RV49"
