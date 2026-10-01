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
#   P  el análisis de la entrada, campo a campo.
# TRES ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`); 43b948a, el árbol con la regresión (fail-before);
# y 9596e39, la referencia de antes de la regresión, que es la que cuenta para los movimientos. Los dos,
# materializados POR SHA (`mat44`, copia de `mat43`); sin ellos, SKIP y motivo. Cada fila juzgada por
# un guardián se comprueba además en la candidata POR `guard.sh` (CA-66, versionado, punto 3).
# Esto NO es la validación en el host: el efecto en disco lo comprueba la coordinadora.
CASOS_ESPERADOS_SECCION=167
PISO_AUTONOMO_SECCION=59  # 19 preámbulo (líneas 1-19, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO44, mat44_reg y mat44, copia de mat43, líneas 20-43) + 16 bloque indivisible mayor (fila44, líneas 89-104) · REQ-014 CA-18
seccion_nueva "--- 44 · integridad de la entrada del hook (QA-023-09; REQ-007 CA-47 puntos 11-13, CA-24 y CA-66) ---"
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
if mat44 43b948a "$R43A"; then R43A_OK=si
else R43A_MOT="43b948a no se materializó (${MAT44_REG#*motivo=})"; R43A_MOT="${R43A_MOT%% corrida=*})"; fi
if mat44 9596e39 "$R95"; then R95_OK=si
else R95_MOT="9596e39 no se materializó (${MAT44_REG#*motivo=})"; R95_MOT="${R95_MOT%% corrida=*})"; fi
v44() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }

# --- LA PUERTA REAL -------------------------------------------------------------------------
# g44 <dir de hooks> <guardián> <json> -> D44 (deny|allow) y M44 (el motivo). El proyecto es $PROJ.
D44=''; M44=''
g44() {
  local h="$1" s="$2" json="$3" out; D44=''; M44=''; [ -n "$json" ] || return 1
  out="$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$PROJ" bash "$h/$s" 2>>"$ERRLOG")"
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
etq44() {   # <árbol> <candidata> <esperado en el árbol> -> ETQ44
  case "$1:$2:$3" in
    43*:deny:allow)  ETQ44='fail-before: permite' ;;
    43*:*:deny-otra) ETQ44='fail-before: deniega juzgando otra ruta' ;;
    43*:allow:deny)  ETQ44='deniega por el cwd desplazado: la reparación lo restituye' ;;
    95*:deny:allow)  ETQ44='permite: preexistente, de allow a deny declarado' ;;
    95*:deny:deny)   ETQ44='antes del regreso, deniega' ;;
    95*:allow:deny)  ETQ44='deniega: instancia de L8, movimiento declarado' ;;
    *)               ETQ44='control, decide igual' ;;
  esac
}
declare -A MC44=()
# fila44 <id> <guardián> <candidata> <43b948a> <9596e39> <cita|-> <json>: un caso por árbol y, si el
# guardián no es guard.sh, otro de la candidata por guard.sh.
fila44() {
  local id="$1" s="$2" ec="$3" e43="$4" e95="$5" cita="$6" json="$7" nom="QA-023-09 $1" c43
  if ! json_no_vacio "$nom candidata" "$json"; then
    json_no_vacio "$nom 43b948a" "$json"; json_no_vacio "$nom 9596e39" "$json"; FAIL=$((FAIL + 3))
    [ "$s" = guard.sh ] || { json_no_vacio "$nom candidata por guard.sh" "$json"; FAIL=$((FAIL + 1)); }
    return 0
  fi
  g44 "$HOOKS_DIR" "$s" "$json"; MC44[$id]="$M44"; juicio44 "$nom candidata" "$ec" "$cita"
  if [ "$s" != guard.sh ]; then g44 "$HOOKS_DIR" guard.sh "$json"; juicio44 "$nom candidata por guard.sh" "$ec" "$cita"; fi
  etq44 43 "$ec" "$e43"
  if [ "$R43A_OK" = si ]; then g44 "$R43A/hooks" "$s" "$json"; c43=-; [ "$e43" != deny-otra ] || c43="$cita"; juicio44 "$nom 43b948a: $ETQ44" "$e43" "$c43"
  else v44 SKIP "$nom 43b948a: $ETQ44  $R43A_MOT"; fi
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
rm -rf "$R43A" "$R95"
