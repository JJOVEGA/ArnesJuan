# Sección 44 del banco — 44-integridad-de-la-entrada
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-007 CA-47 puntos 11 a 13 y CA-66 (versionado del 2026-10-01; QA-023-09, regresión de 104ffd1):
# los campos de la entrada llegan ENTEROS —un salto de línea dentro de uno no desplaza a los demás—,
# un `file_path` con un salto de línea es no determinable (punto 12) y un `tool_name` con un salto no
# identifica ninguna herramienta (punto 13). A NIVEL DE HOOK, con el mismo JSON PreToolUse; las filas
# llevan entre paréntesis su fila de la tabla de CA-66 (E1-E5, G1-G3, F1-F4, T1, P1).
#   N  lo que la candidata deniega (E, F, T); el motivo de la candidata se comprueba por lo que cita;
#   C  lo legítimo con el MISMO `cwd` de varias líneas (G), y C9/C10, el salto final en un `file_path`;
#   P  el análisis de la entrada, campo a campo;
#   R  el retorno de carro (QA-023-13): un `cwd` con CR no ancla, y un `file_path` o un `tool_name` con
#      CR se tratan como los que llevan un salto; con sus controles (RC, RS), su movimiento (RM) y P2.
# TRES ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`); el del fail-before —43b948a, el árbol con la
# regresión, y en el bloque R cd6afa6, el de antes de reparar QA-023-13—; y 9596e39, la referencia de
# antes de la regresión, que es la que cuenta para los movimientos. Materializados POR SHA (`mat44`,
# copia de `mat43`); sin ellos, SKIP y motivo. Cada fila juzgada por un guardián se comprueba además en
# la candidata POR `guard.sh` (CA-66, versionado, punto 3).
# Esto NO es la validación en el host: el efecto en disco lo comprueba la coordinadora.
CASOS_ESPERADOS_SECCION=363
PISO_AUTONOMO_SECCION=62  # 22 preámbulo (líneas 1-22, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO44, mat44_reg y mat44, copia de mat43, líneas 23-46) + 16 bloque indivisible mayor (fila44, líneas 97-112) · REQ-014 CA-18
seccion_nueva "--- 44 · integridad de la entrada del hook (QA-023-09 y QA-023-13; REQ-007 CA-47 puntos 11-13, CA-24 y CA-66) ---"
REPO44="${SEC_DIR%/}/../../../.."; MAT44_RUTAS='hooks'; MAT44_REG=''; MAT44_T0=0; MAT44_REF='-'
mat44_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT44_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT44_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT44_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT44_T0 )) procesos=$4 etiqueta=$MAT44_REF ref=$MAT44_REF archivos=$3"
}
# mat44 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat44() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT44_T0=${EPOCHREALTIME/./}; MAT44_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO44" ls-tree -r "$ref" -- $MAT44_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat44_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO44" archive "$ref" $MAT44_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat44_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO44" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat44_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat44_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat44_reg ok - "$n" 6
}
R43A="$RAIZ/r43-$BASHPID"; R43A_OK=no; R43A_MOT=''; R95="$RAIZ/r95-$BASHPID"; R95_OK=no; R95_MOT=''
RCD="$RAIZ/rcd-$BASHPID"; RCD_OK=no; RCD_MOT=''
if mat44 43b948a "$R43A"; then R43A_OK=si
else R43A_MOT="43b948a no se materializó (${MAT44_REG#*motivo=})"; R43A_MOT="${R43A_MOT%% corrida=*})"; fi
if mat44 9596e39 "$R95"; then R95_OK=si
else R95_MOT="9596e39 no se materializó (${MAT44_REG#*motivo=})"; R95_MOT="${R95_MOT%% corrida=*})"; fi
if mat44 cd6afa6 "$RCD"; then RCD_OK=si
else RCD_MOT="cd6afa6 no se materializó (${MAT44_REG#*motivo=})"; RCD_MOT="${RCD_MOT%% corrida=*})"; fi
# El árbol del fail-before de cada bloque: 43b948a para QA-023-09; el bloque R lo cambia a cd6afa6.
H44='QA-023-09'; FB44=43b948a; FB44_DIR="$R43A"; FB44_OK="$R43A_OK"; FB44_MOT="$R43A_MOT"
v44() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }

# --- LA PUERTA REAL -------------------------------------------------------------------------
# g44 <dir de hooks> <guardián> <json> -> D44 (deny|allow) y M44 (el motivo). El proyecto es $PROJ.
D44=''; M44=''
g44() {
  local h="$1" s="$2" json="$3" out; D44=''; M44=''; [ -n "$json" ] || return 1
  out="$(if [[ "$json" == @/* ]]; then cat -- "${json#@}"; else printf '%s' "$json"; fi | CLAUDE_PROJECT_DIR="$PROJ" bash "$h/$s" 2>>"$ERRLOG")"   # `@/ruta`: la entrada es ese archivo (NUL, vacía)
  case "$out" in *'"permissionDecision":"deny"'*) D44=deny ;; *) D44=allow ;; esac
  M44="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
# juicio44 <nombre> <allow|deny|deny-otra> <cita|-> — sobre D44/M44. La CITA (subcadena literal: una
# ruta puede llevar saltos de línea) se exige al motivo de un `deny` de la CANDIDATA: la ruta canónica
# que designa la entrada, o la causa de no determinable. En los otros árboles se juzga la decisión,
# salvo `deny-otra`: deniega pero el motivo NO cita esa ruta —juzga otra—, la forma del regreso cuando
# la ruta desplazada da deny.
juicio44() {
  local nom="$1" esp="$2" cita="$3"
  if [ "$esp" = deny-otra ]; then
    if [ "$D44" != deny ]; then v44 FAIL "$nom  esperado=deny (juzgando otra ruta) got=$D44"
    elif [[ "$M44" == *"$cita"* ]]; then v44 FAIL "$nom  deniega citando la ruta canónica: no está juzgando otra  <${M44:0:200}>"
    else v44 PASS "$nom  (deny, juzga otra ruta)"; fi
  elif [ "$D44" != "$esp" ]; then v44 FAIL "$nom  esperado=$esp got=$D44  <${M44:0:220}>"
  elif [ "$esp" = deny ] && [ "$cita" != - ] && [[ "$M44" != *"$cita"* ]]; then v44 FAIL "$nom  el motivo no cita «$cita»  <${M44:0:240}>"
  else v44 PASS "$nom  ($D44)"; fi
}
etq44() {   # <árbol: fb (el del fail-before) | 95> <candidata> <esperado en el árbol> -> ETQ44
  case "$1:$2:$3" in
    fb:deny:allow)   ETQ44='fail-before: permite' ;;
    fb:*:deny-otra)  ETQ44='fail-before: deniega juzgando otra ruta' ;;
    fb:allow:deny)   ETQ44='deniega por el cwd desplazado: la reparación lo restituye' ;;
    95*:deny:allow)  ETQ44='permite: preexistente, de allow a deny declarado' ;;
    95*:deny:deny)   ETQ44='antes del regreso, deniega' ;;
    95*:allow:deny)  ETQ44='deniega: instancia de L8, movimiento declarado' ;;
    *)               ETQ44='control, decide igual' ;;
  esac
}
declare -A MC44=()
# fila44 <id> <guardián> <candidata> <fail-before> <9596e39> <cita|-> <json>: un caso por árbol y, si el
# guardián no es guard.sh, otro de la candidata por guard.sh. El fail-before es el árbol de FB44.
fila44() {
  local id="$1" s="$2" ec="$3" e43="$4" e95="$5" cita="$6" json="$7" nom="$H44 $1" c43
  if ! json_no_vacio "$nom candidata" "$json"; then
    json_no_vacio "$nom $FB44" "$json"; json_no_vacio "$nom 9596e39" "$json"; FAIL=$((FAIL + 3))
    [ "$s" = guard.sh ] || { json_no_vacio "$nom candidata por guard.sh" "$json"; FAIL=$((FAIL + 1)); }
    return 0
  fi
  g44 "$HOOKS_DIR" "$s" "$json"; MC44[$id]="$M44"; juicio44 "$nom candidata" "$ec" "$cita"
  if [ "$s" != guard.sh ]; then g44 "$HOOKS_DIR" guard.sh "$json"; juicio44 "$nom candidata por guard.sh" "$ec" "$cita"; fi
  etq44 fb "$ec" "$e43"
  if [ "$FB44_OK" = si ]; then g44 "$FB44_DIR/hooks" "$s" "$json"; c43=-; [ "$e43" != deny-otra ] || c43="$cita"; juicio44 "$nom $FB44: $ETQ44" "$e43" "$c43"
  else v44 SKIP "$nom $FB44: $ETQ44  $FB44_MOT"; fi
  etq44 95 "$ec" "$e95"
  if [ "$R95_OK" = si ]; then g44 "$R95/hooks" "$s" "$json"; juicio44 "$nom 9596e39: $ETQ44" "$e95" -
  else v44 SKIP "$nom 9596e39: $ETQ44  $R95_MOT"; fi
}
# j44 <herramienta> <cwd|-> <agente|-> <k=v…>: la herramienta, el `cwd` y el agente van LITERALES.
j44() {
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
P="$PROJ"; R="$PROJ/requirements"; NL=$'\n'
# Los globs de F2: un sufijo (`app/*.ts`) y un patrón exacto (`cfg/main.json`), donde la lectura
# entera de un `file_path` con salto casaría distinto que su primera línea.
jq '.codigo_app.globs = ["src/*", "app/*.ts", "cfg/main.json"]' "$P/.arnes/config.json" > "$P/.arnes/config.json.n" \
  && mv "$P/.arnes/config.json.n" "$P/.arnes/config.json"
mkdir -p "$P/app" "$P/cfg"
req44() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }
req44 "$R/REQ-900.md" pendiente; req44 "$R/REQ-901.md" aprobado; printf 'x\n' > "$P/src/a.ts"
printf '# REQ-920\nEstado: en-revisión (tras “R-4”)\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$R/REQ-920.md"
ln -s ../requirements/REQ-900.md "$P/docs/l-req.md"
# Directorios REALES con un salto de línea en el nombre: uno fuera del ámbito, uno en src/ y uno en
# requirements/. Con ellos el `cwd` de varias líneas existe, y lo legítimo tiene que seguir pasando.
NLD="$P/docs/a${NL}b"; NLS="$P/src/s${NL}t"; NLR="$R/r${NL}q"; mkdir -p "$NLD" "$NLS" "$NLR"
cierre44() { j44 Edit "$1" - "file_path=${2:-$R/REQ-900.md}" 'old_string=Estado: en-revisión' 'new_string=Estado: completado'; }
CERRADO44=$'# REQ-900\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n'
QA44="requirements/REQ-900.md': el veredicto de QA es 'pendiente'"; SRC44="'src/a.ts' es código de la app"
ND44='lleva un salto de linea, y no se sabe que archivo se escribiria'; HT44='lleva un salto de linea y no identifica ninguna herramienta'

# --- E: el `cwd` con saltos no desplaza nada: se juzga la ruta canónica -----------------------
fila44 "N1 (E1) Edit que cierra un REQ critico, cwd /tmp\\nb"   guard-completado.sh deny allow deny "$QA44" "$(cierre44 "/tmp${NL}b")"
fila44 "N2 (E1) Edit que cierra, cwd <raíz>\\n (salto final)"   guard-completado.sh deny allow deny "$QA44" "$(cierre44 "$P$NL")"
fila44 "N3 (E1) MultiEdit que cierra, cwd /tmp\\nb"             guard-completado.sh deny allow deny "requirements/REQ-900.md'" \
  "$(jq -cn --arg c "/tmp${NL}b" --arg f "$R/REQ-900.md" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:$f,edits:[{old_string:"Estado: en-revisión",new_string:"Estado: completado"}]}}')"
fila44 "N16 (E1) Write que cierra, cwd <raíz>\\n<raíz>/docs"    guard-completado.sh deny allow deny "$QA44" "$(j44 Write "$P$NL$P/docs" - "file_path=$R/REQ-900.md" "content=$CERRADO44")"
fila44 "N8 (E1) por guard.sh: Edit que cierra, cwd /tmp\\nb"    guard.sh deny allow deny "$QA44" "$(cierre44 "/tmp${NL}b")"
fila44 "N4 (E2) Write de la coordinadora a src/a.ts, cwd /tmp\\nb" guard-codigo.sh deny allow deny "$SRC44" "$(j44 Write "/tmp${NL}b" - "file_path=$P/src/a.ts" content=x)"
fila44 "N5 (E2) Write a src/a.ts, cwd <raíz>\\n<raíz>/docs"     guard-codigo.sh deny allow deny "$SRC44" "$(j44 Write "$P$NL$P/docs" - "file_path=$P/src/a.ts" content=x)"
fila44 "N9 (E2) por guard.sh: Write a src/a.ts, cwd <raíz>\\n"   guard.sh deny allow deny "$SRC44" "$(j44 Write "$P$NL" - "file_path=$P/src/a.ts" content=x)"
fila44 "N6 (E3) SEC-117 no reconstruible, cwd /tmp\\nb"         guard-completado.sh deny allow deny "requirements/REQ-920.md': esta puerta no puede reconstruir" \
  "$(j44 Edit "/tmp${NL}b" - "file_path=$R/REQ-920.md" 'old_string=en-revisión (tras "R-4")' new_string=completado)"
fila44 "N7 (E3) CA-49 (i) enlace dentro de la raíz, cwd /tmp\\nb" guard-completado.sh deny allow deny "'docs/l-req.md' es un ENLACE SIMBOLICO" "$(cierre44 "/tmp${NL}b" "$P/docs/l-req.md")"
# Por Bash el destino es relativo y se ancla en el `cwd` REAL de varias líneas (CA-47, punto 1).
fila44 "N10 (E4) Bash printf > ../../src/a.ts desde docs/a\\nb"  guard-codigo.sh deny deny-otra allow "'src/a.ts', que es código de la app" "$(j44 Bash "$NLD" - 'command=printf x > ../../src/a.ts')"
fila44 "N11 (E4) Bash printf > a.ts desde src/s\\nt"            guard-codigo.sh deny deny-otra allow "'src/s${NL}t/a.ts', que es código de la app" "$(j44 Bash "$NLS" - 'command=printf x > a.ts')"
fila44 "N12 (E4) Bash sed -i con el terminal desde requirements/r\\nq" guard-completado.sh deny deny-otra allow "'requirements/r${NL}q/REQ-9.md' y menciona 'completado'" \
  "$(j44 Bash "$NLR" - "command=sed -i 's/x/completado/' REQ-9.md")"
# El salto en el agente: el agente se juzga con su valor entero.
fila44 "N13 (E5) agent_type qa-tester\\ndesarrollador escribe src/a.ts" guard-codigo.sh deny allow allow "$SRC44" "$(j44 Write "$P" "qa-tester${NL}desarrollador" "file_path=$P/src/a.ts" content=x)"
fila44 "N17 (E5) agent_type desarrollador\\nqa escribe src/a.ts" guard-codigo.sh deny allow allow "$SRC44" "$(j44 Write "$P" "desarrollador${NL}qa" "file_path=$P/src/a.ts" content=x)"
fila44 "N14 (E5) agent_id a\\n1 (qa-tester) escribe src/a.ts"    guard-codigo.sh deny allow allow "$SRC44" \
  "$(jq -cn --arg c "$P" --arg f "$P/src/a.ts" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,agent_id:"a\n1",agent_type:"qa-tester",tool_input:{file_path:$f,content:"x"}}')"

# --- G: lo legítimo con el MISMO `cwd` de varias líneas (por guard.sh, las puertas juntas) -----
fila44 "C1 (G1) el desarrollador escribe src/a.ts, cwd /tmp\\nb"  guard.sh allow allow allow - "$(j44 Write "/tmp${NL}b" desarrollador "file_path=$P/src/a.ts" content=x)"
fila44 "C2 (G1) el desarrollador: Bash printf > a.ts desde src/s\\nt" guard.sh allow allow allow - "$(j44 Bash "$NLS" desarrollador 'command=printf x > a.ts')"
fila44 "C3 (G1) coordinadora escribe docs/n.md, cwd /tmp\\nb"    guard.sh allow allow allow - "$(j44 Write "/tmp${NL}b" - "file_path=$P/docs/n.md" content=x)"
fila44 "C5 (G1) cierre de un REQ en verde, cwd /tmp\\nb"         guard.sh allow allow allow - "$(cierre44 "/tmp${NL}b" "$R/REQ-901.md")"
fila44 "C7 (G1) Edit literal sin estado, cwd /tmp\\nb"            guard.sh allow allow allow - "$(j44 Edit "/tmp${NL}b" - "file_path=$R/REQ-900.md" old_string=nota 'new_string=otra nota')"
fila44 "C8 (G1) ls -la, cwd /tmp\\nb"                            guard.sh allow allow allow - "$(j44 Bash "/tmp${NL}b" - 'command=ls -la')"
fila44 "C4 (G2) coordinadora: Bash echo > n.md desde docs/a\\nb"  guard.sh allow deny allow - "$(j44 Bash "$NLD" - 'command=echo x > n.md')"
fila44 "C6 (G2) cierre de un REQ en verde, cwd docs/a\\nb"        guard.sh allow deny allow - "$(cierre44 "$NLD" "$R/REQ-901.md")"
fila44 "C11 (G3) coordinadora: Bash echo > src/a.ts desde docs/a\\nb (designa docs/a\\nb/src/a.ts)" guard.sh allow deny deny - "$(j44 Bash "$NLD" - 'command=echo x > src/a.ts')"

# --- F: un `file_path` con salto es no determinable (CA-47, punto 12) --------------------------
fila44 "C10 (F1) coordinadora escribe <raíz>/src/a.ts\\n"        guard-codigo.sh deny deny deny "$ND44" "$(j44 Write "$P" - "file_path=$P/src/a.ts$NL" content=x)"
fila44 "N18 (F1) coordinadora escribe <raíz>/src/s\\nt/a.ts"     guard-codigo.sh deny deny deny "$ND44" "$(j44 Write "$P" - "file_path=$NLS/a.ts" content=x)"
fila44 "N19 (F1) Write con el terminal y QA pendiente a <REQ>\\n" guard-completado.sh deny deny deny "$ND44" "$(j44 Write "$P" - "file_path=$R/REQ-900.md$NL" "content=$CERRADO44")"
fila44 "N20 (F1) Edit que cierra por <REQ>\\n"                   guard-completado.sh deny deny deny "$ND44" "$(cierre44 "$P" "$R/REQ-900.md$NL")"
fila44 "N21 (F2) coordinadora escribe <raíz>/app/a.ts\\n (app/*.ts)" guard-codigo.sh deny deny deny "$ND44" "$(j44 Write "$P" - "file_path=$P/app/a.ts$NL" content=x)"
fila44 "N22 (F2) coordinadora escribe <raíz>/cfg/main.json\\n (exacto)" guard-codigo.sh deny deny deny "$ND44" "$(j44 Write "$P" - "file_path=$P/cfg/main.json$NL" content=x)"
fila44 "N23 (F2) coordinadora escribe <raíz>/cfg/main.json\\nx"  guard-codigo.sh deny deny deny "$ND44" "$(j44 Write "$P" - "file_path=$P/cfg/main.json${NL}x" content=x)"
fila44 "N24 (F2) Edit de creación sin terminal sobre <REQ>\\n"    guard-completado.sh deny deny deny "$ND44" "$(j44 Edit "$P" - "file_path=$R/REQ-900.md$NL" old_string= 'new_string=# nota')"
fila44 "N25 (F2) Edit que cierra por docs/l-req.md\\n"           guard-completado.sh deny deny deny "$ND44" "$(cierre44 "$P" "$P/docs/l-req.md$NL")"
fila44 "N15 (F3) coordinadora escribe <raíz>/docs/x\\n/../../src/a.ts" guard-codigo.sh deny allow allow "$ND44" "$(j44 Write "$P" - "file_path=$P/docs/x$NL/../../src/a.ts" content=x)"
fila44 "N26 (F3) Edit que cierra por <raíz>/docs/x\\n/../../requirements/REQ-900.md" guard-completado.sh deny allow allow "$ND44" "$(cierre44 "$P" "$P/docs/x$NL/../../requirements/REQ-900.md")"
fila44 "N27 (F4) Write sin terminal a <REQ>\\n"                   guard-completado.sh deny allow allow "$ND44" "$(j44 Write "$P" - "file_path=$R/REQ-900.md$NL" $'content=# REQ-900\nEstado: en-revisión\n')"
fila44 "C9 (F4) coordinadora escribe <raíz>/docs/n.md\\n"         guard.sh deny allow allow "$ND44" "$(j44 Write "$P" - "file_path=$P/docs/n.md$NL" content=x)"
fila44 "N28 (F4) O-16: <fuera>\\n<REQ canónico>"                  guard-completado.sh deny allow allow "$ND44" "$(cierre44 "$P" "$RAIZ/fuera44/x.md$NL$R/REQ-900.md")"
fila44 "N29 (F4) el desarrollador escribe <raíz>/app/a.ts\\n"      guard-completado.sh deny allow allow "$ND44" "$(j44 Write "$P" desarrollador "file_path=$P/app/a.ts$NL" content=x)"

# --- T: un `tool_name` con salto no identifica ninguna herramienta (CA-47, punto 13) -----------
fila44 "T1 (T1) coordinadora: Write\\n a src/a.ts"              guard-codigo.sh deny allow allow "$HT44" "$(j44 "Write$NL" "$P" - "file_path=$P/src/a.ts" content=x)"
fila44 "T2 (T1) coordinadora: Bash\\n con echo x > src/a.ts"     guard-codigo.sh deny deny deny "$HT44" "$(j44 "Bash$NL" "$P" - 'command=echo x > src/a.ts')"
fila44 "T3 (T1) coordinadora: Edit\\n que cierra un REQ"         guard-completado.sh deny allow allow "$HT44" "$(j44 "Edit$NL" "$P" - "file_path=$R/REQ-900.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila44 "T4 (T1) el desarrollador: Write\\n a src/a.ts"           guard-completado.sh deny allow allow "$HT44" "$(j44 "Write$NL" "$P" desarrollador "file_path=$P/src/a.ts" content=x)"

# --- Los motivos de F y T: su causa, y ninguna herramienta como salida (CA-47, puntos 7, 12 y 13) ---
nom44="QA-023-09 los motivos de F y T dicen su causa y cómo corregirla, y no nombran ninguna herramienta como salida"; mal44=''
for id44 in "C10 (F1) coordinadora escribe <raíz>/src/a.ts\\n" "N19 (F1) Write con el terminal y QA pendiente a <REQ>\\n" \
            "N24 (F2) Edit de creación sin terminal sobre <REQ>\\n" "N15 (F3) coordinadora escribe <raíz>/docs/x\\n/../../src/a.ts" \
            "T1 (T1) coordinadora: Write\\n a src/a.ts" "T3 (T1) coordinadora: Edit\\n que cierra un REQ"; do
  m44="${MC44[$id44]:-}"; [ -n "$m44" ] || { mal44+=" ${id44%% *}: sin motivo"; continue; }
  r44="${m44#*lleva un salto de linea}"   # la causa y lo que sigue, sin la cita (que puede ser el nombre recibido)
  [ "$r44" != "$m44" ] || mal44+=" ${id44%% *}: no dice su causa"
  grep -Eqi '(^|[^a-z])(bash|write|edit|multiedit|shell|consola|terminal|python)([^a-z]|$)' <<< "$r44" && mal44+=" ${id44%% *}: <${r44:0:120}>"
  case "${id44%% *}" in T*) ;; *) [[ "$m44" == *'Para corregirlo, escribe la ruta sin saltos de linea'* ]] || mal44+=" ${id44%% *}: no dice como corregirlo" ;; esac
done
if [ -n "$mal44" ]; then v44 FAIL "$nom44 $mal44"; else v44 PASS "$nom44"; fi

# --- P: el análisis de la entrada, campo a campo (lib directa) ---------------------------------
# Un salto de línea en CADA campo, y al final de uno: los seis llegan intactos a la candidata, y en
# 43b948a se desplazan. Se compara la forma `%q` de los seis, que hace visible cada salto.
P44_IN="$(jq -cn '{tool_name:"Bash",agent_id:"a\n1",agent_type:"qa\nx",cwd:"/tmp\nb\n",tool_input:{file_path:"f\ng",command:"ls\n  x > y"}}')"
printf -v P44_ESP '%q|' Bash "a${NL}1" "qa${NL}x" "/tmp${NL}b$NL" "f${NL}g" "ls$NL  x > y"
p44() {   # <dir de hooks> -> P44 (los seis campos en %q)
  P44="$( . "$1/lib.sh" 2>/dev/null; ARNES_INPUT="$P44_IN"; ARNES_INPUT_LISTO=''; arnes_parse_input
          printf '%q|' "$ARNES_TOOL" "$ARNES_AGENT_ID" "$ARNES_AGENT_TYPE" "${ARNES_CWD-}" "$ARNES_FP" "$ARNES_CMD" )"
}
nom44="QA-023-09 P1 (P1) arnes_parse_input conserva los seis campos con saltos de línea en cada uno"
p44 "$HOOKS_DIR"
if [ -z "$P44" ]; then v44 FAIL "$nom44  candidata: el análisis no devolvió nada"
elif [ "$P44" = "$P44_ESP" ]; then v44 PASS "$nom44  candidata"
else v44 FAIL "$nom44  candidata: <$P44> en vez de <$P44_ESP>"; fi
if [ "$R43A_OK" != si ]; then v44 SKIP "$nom44  43b948a (fail-before)  $R43A_MOT"
else
  p44 "$R43A/hooks"
  if [ -n "$P44" ] && [ "$P44" != "$P44_ESP" ]; then v44 PASS "$nom44  43b948a (fail-before): los desplaza  <$P44>"
  else v44 FAIL "$nom44  43b948a (fail-before): no los desplaza, el caso no distingue  <$P44>"; fi
fi

# --- R: el retorno de carro en la entrada (QA-023-13; séptima autorización) ---------------------
# El transporte de jq retira el CR que cierra un campo. Con `cwd` = `<fuera>/d␍`, un enlace a la raíz,
# cd6afa6 anclaba en `<fuera>/d` —un directorio normal fuera— y permitía; el shell escribe en la raíz.
# Un `cwd` con CR no ancla (la relativa es no determinable); un `file_path` o un `tool_name` con CR se
# tratan como los que llevan un salto (CA-47 puntos 12 y 13). Fail-before: cd6afa6; referencia, 9596e39.
H44='QA-023-13'; FB44=cd6afa6; FB44_DIR="$RCD"; FB44_OK="$RCD_OK"; FB44_MOT="$RCD_MOT"
CR=$'\r'; FCR="$RAIZ/fuera44cr-$BASHPID"; mkdir -p "$FCR/d" "$FCR/g${NL}h"
ln -s "$P" "$FCR/d$CR"; ln -s "$P" "$FCR/e${CR}f"; ln -s "$P" "$FCR/g$CR${NL}h"
ln -s ../src/a.ts "$P/docs/l$CR"; cp "$R/REQ-900.md" "$R/REQ-901.md$CR"   # el REQ «con CR» va en rojo
CRD44="('cwd') contiene un retorno de carro"; CRF44='lleva un retorno de carro, y no se sabe que archivo se escribiria'
CRT44='lleva un retorno de carro y no identifica ninguna herramienta'
fila44 "R1 coordinadora: echo x > src/a.ts desde <fuera>/d\\r (enlace a la raíz)" guard-codigo.sh deny allow deny "$CRD44" "$(j44 Bash "$FCR/d$CR" - 'command=echo x > src/a.ts')"
fila44 "R2 sed -i que cierra un REQ en rojo desde <fuera>/d\\r"        guard-completado.sh deny allow deny "$CRD44" "$(j44 Bash "$FCR/d$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
fila44 "R3 Edit relativo que cierra un REQ en rojo desde <fuera>/d\\r" guard-completado.sh deny allow deny "$CRD44" "$(cierre44 "$FCR/d$CR" requirements/REQ-900.md)"
fila44 "R4 CR en medio: echo x > src/a.ts desde <fuera>/e\\rf"         guard.sh deny deny deny "$CRD44" "$(j44 Bash "$FCR/e${CR}f" - 'command=echo x > src/a.ts')"
fila44 "R5 CR antes de un salto: echo x > src/a.ts desde <fuera>/g\\r\\nh" guard.sh deny allow deny "$CRD44" "$(j44 Bash "$FCR/g$CR${NL}h" - 'command=echo x > src/a.ts')"
# Lo que no depende del `cwd` se juzga como siempre, con el mismo `cwd`; y la misma operación sin CR.
fila44 "RC1 coordinadora: Write ABSOLUTO a docs/n.md desde <fuera>/d\\r" guard.sh allow allow allow - "$(j44 Write "$FCR/d$CR" - "file_path=$P/docs/n.md" content=x)"
fila44 "RC2 cierre ABSOLUTO de un REQ en verde desde <fuera>/d\\r"      guard.sh allow allow allow - "$(cierre44 "$FCR/d$CR" "$R/REQ-901.md")"
fila44 "RC3 ls -la desde <fuera>/d\\r"                                 guard.sh allow allow allow - "$(j44 Bash "$FCR/d$CR" - 'command=ls -la')"
fila44 "RC4 coordinadora: Write ABSOLUTO a src/a.ts desde <fuera>/d\\r" guard.sh deny deny deny "$SRC44" "$(j44 Write "$FCR/d$CR" - "file_path=$P/src/a.ts" content=x)"
fila44 "RC5 cierre ABSOLUTO de un REQ en rojo desde <fuera>/d\\r"       guard.sh deny deny deny "$QA44" "$(cierre44 "$FCR/d$CR")"
fila44 "RC6 el desarrollador: echo x > src/a.ts desde <fuera>/d\\r"     guard.sh allow allow allow - "$(j44 Bash "$FCR/d$CR" desarrollador 'command=echo x > src/a.ts')"
fila44 "RM1 coordinadora: echo x > n.md desde <fuera>/d\\r (de allow a deny, declarado)" guard.sh deny allow allow "$CRD44" "$(j44 Bash "$FCR/d$CR" - 'command=echo x > n.md')"
fila44 "RS1 sin CR: echo x > src/a.ts desde <raíz>"                    guard.sh deny deny deny "'src/a.ts', que es código de la app" "$(j44 Bash "$P" - 'command=echo x > src/a.ts')"
fila44 "RS2 sin CR: sed -i que cierra un REQ en rojo desde <raíz>"     guard.sh deny deny deny "'requirements/REQ-900.md' y menciona 'completado'" "$(j44 Bash "$P" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
fila44 "RS3 sin CR: echo x > src/a.ts desde <fuera>/d (designa <fuera>/d/src/a.ts: L8)" guard.sh allow allow deny - "$(j44 Bash "$FCR/d" - 'command=echo x > src/a.ts')"
# El `file_path` con CR (punto 12, por coherencia): el valor recortado designaba otro archivo.
fila44 "RF1 coordinadora: Write <raíz>/docs/l\\r (enlace dentro hacia src/a.ts)" guard-codigo.sh deny allow allow "$CRF44" "$(j44 Write "$P" - "file_path=$P/docs/l$CR" content=x)"
fila44 "RF2 Edit que cierra <REQ-901.md\\r> (en rojo; REQ-901.md en verde)" guard-completado.sh deny allow allow "$CRF44" "$(cierre44 "$P" "$R/REQ-901.md$CR")"
fila44 "RF3 coordinadora: Write <raíz>/docs/n.md\\r (fuera del ámbito)" guard.sh deny allow allow "$CRF44" "$(j44 Write "$P" - "file_path=$P/docs/n.md$CR" content=x)"
fila44 "RF4 un file_path que solo es un retorno de carro"               guard.sh deny allow allow "$CRF44" "$(j44 Write "$P" - "file_path=$CR" content=x)"
# El `tool_name` con CR (punto 13, por coherencia): recortado, se juzgaba otra herramienta.
fila44 "RT1 coordinadora: Bash\\r con ls y file_path <raíz>/src/a.ts"   guard-codigo.sh deny allow allow "$CRT44" "$(j44 "Bash$CR" "$P" - 'command=ls' "file_path=$P/src/a.ts")"
fila44 "RT2 coordinadora: Edit\\r que cierra un REQ en rojo"            guard-completado.sh deny allow allow "$CRT44" "$(j44 "Edit$CR" "$P" - "file_path=$R/REQ-900.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila44 "RT3 el desarrollador: Write\\r a src/a.ts"                      guard-completado.sh deny allow allow "$CRT44" "$(j44 "Write$CR" "$P" desarrollador "file_path=$P/src/a.ts" content=x)"
fila44 "RT4 coordinadora: Bash\\r con echo x > src/a.ts (ya se denegaba)" guard.sh deny deny deny "$CRT44" "$(j44 "Bash$CR" "$P" - 'command=echo x > src/a.ts')"
nom44="QA-023-13 los motivos del retorno de carro dicen su causa y cómo corregirla, y no nombran ninguna herramienta como salida"; mal44=''
for id44 in "R1 coordinadora: echo x > src/a.ts desde <fuera>/d\\r (enlace a la raíz)" "R3 Edit relativo que cierra un REQ en rojo desde <fuera>/d\\r" \
            "RF1 coordinadora: Write <raíz>/docs/l\\r (enlace dentro hacia src/a.ts)" "RF4 un file_path que solo es un retorno de carro" \
            "RT1 coordinadora: Bash\\r con ls y file_path <raíz>/src/a.ts" "RT2 coordinadora: Edit\\r que cierra un REQ en rojo"; do
  m44="${MC44[$id44]:-}"; [ -n "$m44" ] || { mal44+=" ${id44%% *}: sin motivo"; continue; }
  r44="${m44#*retorno de carro}"   # la causa y lo que sigue, sin la cita
  [ "$r44" != "$m44" ] || mal44+=" ${id44%% *}: no dice su causa"
  grep -Eqi '(^|[^a-z])(bash|write|edit|multiedit|shell|consola|terminal|python)([^a-z]|$)' <<< "$r44" && mal44+=" ${id44%% *}: <${r44:0:120}>"
  case "${id44%% *}" in
    R1|R3) [[ "$m44" == *'Para corregirlo, escribe la ruta absoluta, o trabaja desde un directorio cuyo nombre no lleve retornos de carro'* ]] || mal44+=" ${id44%% *}: no dice como corregirlo" ;;
    RF*)   [[ "$m44" == *'Para corregirlo, escribe la ruta sin retornos de carro'* ]] || mal44+=" ${id44%% *}: no dice como corregirlo" ;;
  esac
done
if [ -n "$mal44" ]; then v44 FAIL "$nom44 $mal44"; else v44 PASS "$nom44"; fi
# P2: el CR se cuenta antes del transporte; el `cwd` con CR no ancla, y el CR final del `tool_name` y del
# `file_path` llega (en cd6afa6, recortado).
P44_IN="$(jq -cn '{tool_name:"Bash\r",cwd:"/tmp/d\r",tool_input:{file_path:"/tmp/f\r",command:"ls"}}')"
printf -v P44_ESP '%q|' "Bash$CR" '' "/tmp/f$CR" ls 1 1 1
p44cr() {   # <dir de hooks> -> P44
  P44="$( . "$1/lib.sh" 2>/dev/null; ARNES_INPUT="$P44_IN"; ARNES_INPUT_LISTO=''; arnes_parse_input
          printf '%q|' "$ARNES_TOOL" "${ARNES_CWD-}" "$ARNES_FP" "$ARNES_CMD" "${ARNES_TOOL_CR-}" "${ARNES_CWD_CR-}" "${ARNES_FP_CR-}" )"
}
nom44="QA-023-13 P2 arnes_parse_input cuenta el retorno de carro antes del transporte"; p44cr "$HOOKS_DIR"
if [ "$P44" = "$P44_ESP" ]; then v44 PASS "$nom44  candidata"; else v44 FAIL "$nom44  candidata: <$P44> en vez de <$P44_ESP>"; fi
if [ "$RCD_OK" != si ]; then v44 SKIP "$nom44  cd6afa6 (fail-before)  $RCD_MOT"
else
  p44cr "$RCD/hooks"
  if [ -n "$P44" ] && [ "$P44" != "$P44_ESP" ]; then v44 PASS "$nom44  cd6afa6 (fail-before): lo recorta  <$P44>"
  else v44 FAIL "$nom44  cd6afa6 (fail-before): no lo recorta, el caso no distingue  <$P44>"; fi
fi

# --- SEC-120: una entrada que `jq` no puede leer o trocear no pasa (REQ-007 CA-47 punto 20; CA-69) -----
# Los vectores de R-045-A §4, por su descripción: V1 y V2, un `MultiEdit` con las ediciones como cadena o
# como número; V3, un `Edit` que cierra un REQ `critico` en rojo con una clave extra de 10001 niveles (jq:
# «Exceeds depth limit for parsing»); V4 (control), el mismo con 9000 niveles. Por propiedad:
#   L  jq no puede LEER la entrada -> deny a TODO agente, por guard.sh y por cada guardián que juzga la
#      herramienta (las del `matcher` de hooks/hooks.json); L6, otra causa: la entrada truncada;
#   T  la lee pero no puede TROCEAR las ediciones que guard-completado necesita -> esa puerta deniega. En
#      T3 y T4 falla el troceo de jq, y `ARNES_JQ` conserva la lectura anterior (la otra mitad de §4);
#   K  la puerta que no necesita esa parte decide como siempre, y V4 deniega por el veredicto;
#   I  los modos inertes —sin jq, sin manifiesto— no cambian; P3, `arnes_parse_input` tras una lectura buena.
# DOS ÁRBOLES por caso: la CANDIDATA y v1.35.0 (3956a6f, la línea base de CA-69 punto 1, por SHA con `mat44`);
# sin ella, SKIP y motivo, nunca PASS. L y T citan su motivo propio (IL120, TR120), y el de L no puede
# interpolar la clave anidada (CA-67). A nivel de hook en Linux/WSL2; el host no se ejerce.
RV135="$RAIZ/rv135-$BASHPID"; RV135_OK=no; RV135_MOT=''
if mat44 3956a6f "$RV135"; then RV135_OK=si
else RV135_MOT="v1.35.0 no se materializó (${MAT44_REG#*motivo=})"; RV135_MOT="${RV135_MOT%% corrida=*})"; fi
printf -v A120 '%10001s' ''; printf -v B120 '%10001s' ''; HONDO120="${A120// /[}${B120// /]}"
printf -v A120 '%9000s' ''; printf -v B120 '%9000s' ''; MEDIO120="${A120// /[}${B120// /]}"
# fila120 <id> <candidata> <v1.35.0> <cita|-> <json> <guardianes…>: por guardián, un caso en cada árbol.
fila120() {
  local id="$1" ec="$2" ev="$3" cita="$4" json="$5" s nom; shift 5
  case "$ec:$ev" in deny:allow) ETQ44='fail-before: permite' ;; *) ETQ44='control, decide igual' ;; esac
  for s in "$@"; do
    nom="SEC-120 $id por $s"
    json_no_vacio "$nom candidata" "$json" || { json_no_vacio "$nom v1.35.0" "$json"; FAIL=$((FAIL + 2)); continue; }
    g44 "$HOOKS_DIR" "$s" "$json"
    if [ "$D44" = deny ] && [[ "$M44" == *'[[[[[[[[[[[[[[[['* ]]; then v44 FAIL "$nom candidata  el motivo interpola la clave anidada  <${M44:0:120}>"
    else juicio44 "$nom candidata" "$ec" "$cita"; fi
    if [ "$RV135_OK" = si ]; then g44 "$RV135/hooks" "$s" "$json"; juicio44 "$nom v1.35.0: $ETQ44" "$ev" -
    else v44 SKIP "$nom v1.35.0: $ETQ44  $RV135_MOT"; fi
  done
}
E120="$(cierre44 "$P")"; ED120="$(j44 Edit "$P" desarrollador "file_path=$R/REQ-900.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
W120="$(j44 Write "$P" desarrollador "file_path=$P/src/a.ts" content=x)"; B120="$(j44 Bash "$P" desarrollador 'command=ls -la')"
M120="$(jq -cn --arg c "$P" --arg f "$P/docs/n.md" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:$f,edits:[{old_string:"a",new_string:"b"}]}}')"
me120() {   # <file_path> <edits, en JSON> [agente, en jq] -> un MultiEdit con esas ediciones
  local x='{}'; [ -z "${3:-}" ] || x="$3"
  jq -cn --arg c "$P" --arg f "$1" --argjson e "$2" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:$f,edits:$e}} + '"$x"
}
V1_120="$(me120 "$R/REQ-900.md" '"[{\"old_string\":\"Estado: en-revisión\",\"new_string\":\"Estado: completado\"}]"')"
T6_120="$(j44 Bash "$P" - 'command=echo x > src/a.ts')"; GJ120='guard.sh guard-codigo.sh guard-completado.sh'; IL120='la entrada de esta llamada no se pudo leer'; TR120="'requirements/REQ-900.md': su tool_input no tiene la forma"
fila120 "L1 (V3) Edit de la coordinadora que cierra un REQ critico en rojo, clave de 10001 niveles" deny allow "$IL120" "${E120%?},\"x\":$HONDO120}" $GJ120
fila120 "L2 (V3) el mismo cierre del desarrollador"                         deny allow "$IL120" "${ED120%?},\"x\":$HONDO120}" $GJ120
fila120 "L3 (V3 por Write) el desarrollador escribe src/a.ts"              deny allow "$IL120" "${W120%?},\"x\":$HONDO120}" $GJ120
fila120 "L4 (V3 por MultiEdit) la coordinadora edita docs/n.md"            deny allow "$IL120" "${M120%?},\"x\":$HONDO120}" $GJ120
fila120 "L5 (V3 por Bash) ls -la del desarrollador"                        deny allow "$IL120" "${B120%?},\"x\":$HONDO120}" guard-git.sh $GJ120
fila120 "L6 entrada truncada: Bash echo x > src/a.ts de la coordinadora, sin la llave final" deny allow "$IL120" \
  "${T6_120%?}" guard-git.sh $GJ120
fila120 "T1 (V1) MultiEdit que cierra un REQ en rojo con las ediciones como cadena" deny allow "$TR120" "$V1_120" guard.sh guard-completado.sh
fila120 "T2 (V2) MultiEdit sobre un REQ en rojo con las ediciones como número" deny allow "$TR120" "$(me120 "$R/REQ-900.md" 1)" guard.sh guard-completado.sh
fila120 "T3 MultiEdit que cierra un REQ en rojo con las ediciones como objeto" deny allow "$TR120" \
  "$(me120 "$R/REQ-900.md" '{"old_string":"Estado: en-revisión","new_string":"Estado: completado"}')" guard.sh guard-completado.sh
fila120 "T4 MultiEdit sobre un REQ en rojo con las ediciones como lista de cadenas" deny allow "$TR120" "$(me120 "$R/REQ-900.md" '["Estado: completado"]')" guard.sh guard-completado.sh
fila120 "K1 (V1) la puerta de código no necesita las ediciones: REQ-900 no es código" allow allow - "$V1_120" guard-codigo.sh
fila120 "K2 MultiEdit de la coordinadora a src/a.ts con las ediciones como cadena" deny deny "$SRC44" "$(me120 "$P/src/a.ts" '"x"')" guard-codigo.sh
fila120 "K3 MultiEdit del desarrollador a src/a.ts con las ediciones como cadena" allow allow - \
  "$(me120 "$P/src/a.ts" '"x"' '{agent_id:"a1",agent_type:"desarrollador"}')" guard.sh
# K4 sólo es CONTROL si el `jq` en uso lee 9000 niveles. Medido (docs/qa/REQ-007.md, «CI del PR #60: K4 (V4) en
# Ubuntu»): jq 1.8.2 lee la clave con 9998 y no con 9999; el jq 1.7.1 de ubuntu-24.04 —el del CI— la lee con 254 y no
# con 255. Con ese jq V4 es ILEGIBLE: la candidata tiene que denegar por IL120 (si no, FAIL) y el caso no mide el
# control —SKIP con motivo, nunca PASS—; v1.35.0 se registra con lo que decida (allow es el fail-open de SEC-120).
K4_120="${E120%?},\"x\":$MEDIO120}"
if jq -e 'has("x")' <<< "$K4_120" >/dev/null 2>&1; then
  fila120 "K4 (V4) el cierre de L1 con 9000 niveles: deniega por el veredicto" deny deny "$QA44" "$K4_120" guard.sh guard-completado.sh
else
  JQV120="$(jq --version 2>&1)"; JQV120="${JQV120:0:40}"
  for s in guard.sh guard-completado.sh; do
    nom="SEC-120 K4 (V4) el cierre de L1 con 9000 niveles: deniega por el veredicto por $s"
    g44 "$HOOKS_DIR" "$s" "$K4_120"
    if [ "$D44" = deny ] && [[ "$M44" == *'[[[[[[[[[[[[[[[['* ]]; then v44 FAIL "$nom candidata  el motivo interpola la clave anidada  <${M44:0:120}>"
    elif [ "$D44" = deny ] && [[ "$M44" == *"$IL120"* ]]; then
      v44 SKIP "$nom candidata  el jq en uso ($JQV120) no lee 9000 niveles: V4 es ilegible y deniega por «$IL120»; el control no se mide (lo ilegible lo cubren L1-L9)"
    else juicio44 "$nom candidata (V4 ilegible con $JQV120)" deny "$IL120"; fi   # sólo llega aquí lo que no deniega por IL120: FAIL
    if [ "$RV135_OK" = si ]; then g44 "$RV135/hooks" "$s" "$K4_120"
      v44 SKIP "$nom v1.35.0: control, decide igual  el jq en uso ($JQV120) no lee 9000 niveles: decide $D44 (allow es el fail-open de SEC-120); el control no se mide"
    else v44 SKIP "$nom v1.35.0: control, decide igual  $RV135_MOT"; fi
  done
fi
# Pasada correctiva (QA-007-03 y QA-007-04): la entrada vacía o con un NUL —leída de un archivo: una variable no
# guarda NUL— es ilegible; y `false` en `file_path` o en `command` no es texto. Fail-before también contra aba1c9b.
F120="$RAIZ/f120-$BASHPID"; mkdir -p "$F120"; : > "$F120/vacia"; printf '\0%s' "$B120" > "$F120/nul-objeto"; printf '%s\0%s' "$B120" "$T6_120" > "$F120/objeto-nul-escritura"
fila120 "L7 (QA-007-03) entrada vacía, 0 bytes"                            deny allow "$IL120" "@$F120/vacia" guard-git.sh $GJ120
fila120 "L8 (QA-007-03) un NUL y detrás el ls -la del desarrollador"        deny allow "$IL120" "@$F120/nul-objeto" guard-git.sh $GJ120
fila120 "L9 (QA-007-03) el ls -la del desarrollador, un NUL y una escritura a src/a.ts" deny allow "$IL120" "@$F120/objeto-nul-escritura" guard-git.sh $GJ120
NT120="de esta llamada no es texto"; jf120() { jq -cn --arg c "$P" "{hook_event_name:\"PreToolUse\",cwd:\$c} + $1"; }; FD120="$(jf120 '{agent_id:"a1",agent_type:"desarrollador",tool_name:"Edit",tool_input:{file_path:false,old_string:"a",new_string:"b"}}')"
fila120 "F1 (QA-007-04) Write de la coordinadora con file_path false"       deny allow "'file_path' $NT120" "$(jf120 '{tool_name:"Write",tool_input:{file_path:false,content:"x"}}')" $GJ120
fila120 "F2 (QA-007-04) Bash de la coordinadora con command false"           deny allow "'command' $NT120" "$(jf120 '{tool_name:"Bash",tool_input:{command:false}}')" guard-git.sh $GJ120
fila120 "F3 (QA-007-04) Edit del desarrollador con file_path false"         deny allow "'file_path' $NT120" "$FD120" guard.sh guard-completado.sh
fila120 "K5 (QA-007-04, SEC-128) la puerta de código deniega también al desarrollador un file_path que no es texto: F3" deny allow "'file_path' $NT120" "$FD120" guard-codigo.sh
# I: V3 en modo inerte —sin jq en el PATH, o en un proyecto sin manifiesto—: sin decisión, y sin jq con aviso.
VAC120="$RAIZ/vac120-$BASHPID"; Q120="$RAIZ/q120-$BASHPID"; mkdir -p "$VAC120" "$Q120/requirements"; cp "$R/REQ-900.md" "$Q120/requirements/"
VQ120="$(cierre44 "$Q120" "$Q120/requirements/REQ-900.md")"; VQ120="${VQ120%?},\"x\":$HONDO120}"
for arb120 in candidata v1.35.0; do
  h120="$HOOKS_DIR"; [ "$arb120" = candidata ] || h120="$RV135/hooks"
  for modo120 in 'sin jq' 'sin manifiesto'; do
    nom120="SEC-120 I ($modo120) V3 por guard.sh $arb120: inerte, como siempre"
    if [ "$arb120" != candidata ] && [ "$RV135_OK" != si ]; then v44 SKIP "$nom120  $RV135_MOT"; continue; fi
    if [ "$modo120" = 'sin jq' ]; then o120="$(printf '%s' "${E120%?},\"x\":$HONDO120}" | CLAUDE_PROJECT_DIR="$PROJ" PATH="$VAC120" "$BASH" "$h120/guard.sh" 2>&1)"
    else o120="$(printf '%s' "$VQ120" | CLAUDE_PROJECT_DIR="$Q120" "$BASH" "$h120/guard.sh" 2>&1)"; fi
    if [[ "$o120" == *'"permissionDecision"'* ]]; then v44 FAIL "$nom120  decidió: <${o120:0:160}>"
    elif [ "$modo120" = 'sin jq' ] && [[ "$o120" != *'jq no encontrado'* ]]; then v44 FAIL "$nom120  sin el aviso de jq: <${o120:0:160}>"
    else v44 PASS "$nom120  (sin decisión)"; fi
  done
done
# P3: tras una lectura buena, otra que jq no puede leer no deja en ninguna variable el valor de la primera.
P120_BUENA="$(j44 Bash /tmp/c120 qa-tester file_path=/tmp/f120 'command=ls /tmp/k120')"
p120() {   # <dir de hooks> -> P120: «fin» si ninguna variable conserva la lectura anterior (sin «fin», no midió)
  P120="$( . "$1/lib.sh" 2>/dev/null; local -a a b; local i
    ARNES_INPUT="$P120_BUENA"; ARNES_INPUT_LISTO=''; arnes_parse_input
    a=("$ARNES_TOOL" "$ARNES_AGENT_ID" "$ARNES_AGENT_TYPE" "${ARNES_CWD-}" "$ARNES_FP" "$ARNES_CMD" "$ARNES_JQ")
    ARNES_INPUT="${E120%?},\"x\":$HONDO120}"; ARNES_INPUT_LISTO=''; arnes_parse_input 2>/dev/null
    b=("$ARNES_TOOL" "$ARNES_AGENT_ID" "$ARNES_AGENT_TYPE" "${ARNES_CWD-}" "$ARNES_FP" "$ARNES_CMD" "$ARNES_JQ")
    for i in 0 1 2 3 4 5 6; do [ -n "${a[i]}" ] || printf 'vacia-%s ' "$i"; [ "${a[i]}" != "${b[i]}" ] || printf 'conserva-%s ' "$i"; done; printf fin )"
}
nom120="SEC-120 P3 arnes_parse_input: ninguna variable conserva la lectura anterior si jq no puede leer"
p120 "$HOOKS_DIR"; if [ "$P120" = fin ]; then v44 PASS "$nom120  candidata"; else v44 FAIL "$nom120  candidata: <$P120>"; fi
if [ "$RV135_OK" != si ]; then v44 SKIP "$nom120  v1.35.0 (control, R-046)  $RV135_MOT"
else p120 "$RV135/hooks"; if [ "$P120" = fin ]; then v44 PASS "$nom120  v1.35.0 (control, R-046)"; else v44 FAIL "$nom120  v1.35.0 (control, R-046): <$P120>"; fi; fi
rm -rf "$R43A" "$R95" "$RCD" "$FCR" "$RV135" "$VAC120" "$Q120" "$F120"
