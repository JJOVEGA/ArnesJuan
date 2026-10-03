# Sección 46 del banco — 46-heredocs-y-continuaciones-de-linea
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# Novena autorización del propietario (2026-10-03), fase 2, a NIVEL DE HOOK — REQ-007 CA-47 puntos 18
# y 19 y CA-66 (versionado de la fase 2):
#   HC  SEC-124: una línea del cuerpo de un heredoc que es su delimitador seguido de un retorno de
#       carro, y no es la última, se deniega por la forma, con motivo que cita SEC-124 y sin alterar
#       el comando (filas HC1-HC9 de CA-66);
#   LC  SEC-125: se juzga el destino que escribe el shell —una continuación de línea no basta por sí
#       sola para denegar—, y la «Excepción nombrada» LC10 se deniega por la forma, a todo agente, en
#       las cuatro puertas, con motivo que cita SEC-125 y LC10 (filas LC1-LC10 de CA-66).
# CUATRO ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`), el FAIL-BEFORE 3f96e6b (el código de befc17a,
# antes de esta fase) y las REFERENCIAS de los movimientos 9596e39 y v1.33.2, materializados POR SHA o
# por etiqueta (`mat46`, copia de `mat45`); sin ellos, SKIP y motivo. Cada fila juzgada por un guardián
# se comprueba además en la candidata por `guard.sh`; las de LC10, por las cuatro puertas. Los casos se
# construyen reutilizando la evidencia de R-047 por referencia a su identificador (CA-66, punto 3).
# Esto NO es la validación en el host.
CASOS_ESPERADOS_SECCION=65
PISO_AUTONOMO_SECCION=75  # 20 preambulo (líneas 1-20, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO46, mat46_reg y mat46, copia de mat45, líneas 21-44) + 31 bloque indivisible mayor (g46, juicio46 y fila46, líneas 59-89)
seccion_nueva "--- 46 · heredocs y continuaciones de línea (SEC-124, SEC-125, LC10; novena autorización, fase 2) ---"
REPO46="${SEC_DIR%/}/../../../.."; MAT46_RUTAS='hooks'; MAT46_REG=''; MAT46_T0=0; MAT46_REF='-'
mat46_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT46_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT46_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT46_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT46_T0 )) procesos=$4 etiqueta=$MAT46_REF ref=$MAT46_REF archivos=$3"
}
# mat46 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat46() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT46_T0=${EPOCHREALTIME/./}; MAT46_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO46" ls-tree -r "$ref" -- $MAT46_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat46_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO46" archive "$ref" $MAT46_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat46_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO46" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat46_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat46_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat46_reg ok - "$n" 6
}
# Los tres árboles de referencia: el fail-before 3f96e6b y las referencias 9596e39 y v1.33.2.
RFB46="$RAIZ/r3f9-$BASHPID"; RFB46_OK=no; RFB46_MOT=''
if mat46 3f96e6b "$RFB46"; then RFB46_OK=si
else RFB46_MOT="3f96e6b no se materializó (${MAT46_REG#*motivo=})"; RFB46_MOT="${RFB46_MOT%% corrida=*})"; fi
R95_46="$RAIZ/r95c-$BASHPID"; R95_46_OK=no; R95_46_MOT=''
if mat46 9596e39 "$R95_46"; then R95_46_OK=si
else R95_46_MOT="9596e39 no se materializó (${MAT46_REG#*motivo=})"; R95_46_MOT="${R95_46_MOT%% corrida=*})"; fi
R133="$RAIZ/r133-$BASHPID"; R133_OK=no; R133_MOT=''
if mat46 v1.33.2 "$R133"; then R133_OK=si
else R133_MOT="v1.33.2 no se materializó (${MAT46_REG#*motivo=})"; R133_MOT="${R133_MOT%% corrida=*})"; fi
v46() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
P46="$PROJ"; NL=$'\n'; CR=$'\r'
# g46 <dir de hooks> <guardián> <json> -> D46 (deny|allow) y M46 (el motivo). El proyecto es $P46.
D46=''; M46=''
g46() {
  local h="$1" s="$2" json="$3" out; D46=''; M46=''; [ -n "$json" ] || return 1
  out="$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$P46" bash "$h/$s" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D46=deny ;; *) D46=allow ;; esac
  M46="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
juicio46() {   # <nombre> <allow|deny> <cita|-> — sobre D46/M46; la cita se exige al motivo de un deny
  if [ "$D46" != "$2" ]; then v46 FAIL "$1  esperado=$2 got=$D46  <${M46:0:220}>"
  elif [ "$2" = deny ] && [ "$3" != - ] && [[ "$M46" != *"$3"* ]]; then v46 FAIL "$1  el motivo no cita «$3»  <${M46:0:240}>"
  else v46 PASS "$1  ($D46)"; fi
}
# fila46 <id> <guardián> <candidata> <3f96e6b> <9596e39> <v1.33.2> <cita|-> <json>: un caso por árbol y,
# si el guardián no es guard.sh, otro de la candidata por guard.sh. La cita se exige sólo en la candidata.
# `<guardián>:solo` mide sólo ese guardián. Una columna de referencia con `-` no se mide (ni cuenta).
fila46() {
  local id="$1" s="${2%:solo}" ec="$3" efb="$4" e95="$5" e133="$6" cita="$7" json="$8" nom="REQ-007 novena $1" g=1
  [ "$s" != guard.sh ] && [ "$s" = "$2" ] || g=0
  if ! json_no_vacio "$nom candidata" "$json"; then FAIL=$((FAIL + 2 + g)); return 0; fi
  g46 "$HOOKS_DIR" "$s" "$json"; juicio46 "$nom candidata" "$ec" "$cita"
  if [ "$g" = 1 ]; then g46 "$HOOKS_DIR" guard.sh "$json"; juicio46 "$nom candidata por guard.sh" "$ec" "$cita"; fi
  if [ "$RFB46_OK" = si ]; then g46 "$RFB46/hooks" "$s" "$json"; juicio46 "$nom 3f96e6b (fail-before o control)" "$efb" -
  else v46 SKIP "$nom 3f96e6b  $RFB46_MOT"; fi
  if [ "$e95" != - ]; then
    if [ "$R95_46_OK" = si ]; then g46 "$R95_46/hooks" "$s" "$json"; juicio46 "$nom 9596e39 (referencia de los movimientos)" "$e95" -
    else v46 SKIP "$nom 9596e39  $R95_46_MOT"; fi
  fi
  if [ "$e133" != - ]; then
    if [ "$R133_OK" = si ]; then g46 "$R133/hooks" "$s" "$json"; juicio46 "$nom v1.33.2 (referencia de los movimientos)" "$e133" -
    else v46 SKIP "$nom v1.33.2  $R133_MOT"; fi
  fi
}
# El proyecto efímero: la coordinadora emite con `codigo_app.globs: ["src/*"]` (CA-66, punto 3).
jq '.codigo_app.globs = ["src/*"]' "$P46/.arnes/config.json" > "$P46/.arnes/c46" && mv "$P46/.arnes/c46" "$P46/.arnes/config.json"
R="$P46/requirements"; printf 'x\n' > "$P46/src/a.ts"
req46() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }
req46 "$R/REQ-900.md" pendiente; req46 "$R/REQ-901.md" aprobado
j46() {   # <herramienta> <cwd|-> <agente|-> <k=v…>: todo LITERAL, saltos y CR incluidos
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
# Las citas que el contrato exige al motivo de un deny (CA-66, punto 3).
S124='SEC-124'; S125='SEC-125'; LC10C='LC10'; QA46="veredicto de QA es 'pendiente'"; SRC46="código de la app"

# --- HC: SEC-124, el delimitador seguido de retorno de carro dentro del cuerpo (CA-47, punto 18) ------
HC1="cat <<EOF > docs/x.md$CR${NL}x${NL}EOF$CR${NL}echo y > src/a.ts${NL}EOF$NL"   # t3 H2 de R-047 §3, copiado de la evidencia
fila46 "HC1 coordinadora: t3 H2 — el cuerpo lleva EOF<CR> y detrás echo y > src/a.ts, tras el EOF real (SEC-124)" guard-codigo.sh deny allow deny deny "$S124" "$(j46 Bash "$P46" - "command=$HC1")"

TAB=$'\t'; HCR46='delimitador contiene un retorno de carro'
# HC2-HC4: t4 E1, E2 (<<- con tabulador) y E9 (delimitador citado) de R-047 §3, copiados de la evidencia.
HC2="cat <<EOF > docs/x.md${NL}x${NL}EOF$CR${NL}echo E1 > src/a.ts${NL}EOF$NL"
HC3="cat <<-EOF > docs/x.md${NL}x${NL}${TAB}EOF$CR${NL}echo E2 > src/a.ts${NL}EOF$NL"
HC4="cat <<'EOF'${NL}EOF$CR${NL}echo E9 > src/a.ts${NL}EOF$NL"
fila46 "HC2 coordinadora: t4 E1 — EOF<CR> en el cuerpo, detrás echo > src/a.ts, luego EOF (SEC-124)" guard-codigo.sh deny allow deny deny "$S124" "$(j46 Bash "$P46" - "command=$HC2")"
fila46 "HC3 coordinadora: t4 E2 — <<- con <TAB>EOF<CR> en el cuerpo, detrás echo > src/a.ts (SEC-124)" guard-codigo.sh deny allow deny deny "$S124" "$(j46 Bash "$P46" - "command=$HC3")"
fila46 "HC4 coordinadora: t4 E9 — delimitador citado, EOF<CR> en el cuerpo, detrás echo > src/a.ts (SEC-124)" guard-codigo.sh deny allow deny deny "$S124" "$(j46 Bash "$P46" - "command=$HC4")"
# HC5: la forma de HC1 emitida por el desarrollador (restricción aceptada): deny por guard-completado y guard.sh; guard-codigo sólo, allow.
fila46 "HC5a el desarrollador: la forma de HC1 por guard-completado y guard.sh (SEC-124, restricción aceptada)" guard-completado.sh deny allow allow allow "$S124" "$(j46 Bash "$P46" desarrollador "command=$HC1")"
fila46 "HC5b el desarrollador: la forma de HC1 por guard-codigo sólo (podía escribir)" guard-codigo.sh:solo allow allow allow allow - "$(j46 Bash "$P46" desarrollador "command=$HC1")"
# HC6: la forma de HC1 con una orden inocua detrás del EOF<CR> (restricción aceptada).
HC6="cat <<EOF > docs/x.md${NL}x${NL}EOF$CR${NL}true${NL}EOF$NL"
fila46 "HC6 coordinadora: la forma de HC1 con true detrás del EOF<CR> (SEC-124, restricción aceptada)" guard-codigo.sh deny allow allow allow "$S124" "$(j46 Bash "$P46" - "command=$HC6")"
# HC7: control — esa misma línea como última del comando.
fila46 "HC7 coordinadora: EOF<CR> como última línea del comando (control)" guard.sh allow allow allow allow - "$(j46 Bash "$P46" - "command=cat <<EOF > docs/x.md${NL}x${NL}EOF$CR$NL")"
# HC8: controles — H4 de la sección 45 y un heredoc ordinario de delimitador citado.
fila46 "HC8a coordinadora: H4 de la 45, CR sólo en el cuerpo (control)" guard.sh allow allow allow allow - "$(j46 Bash "$P46" - "command=cat > docs/x.md <<'EOF'${NL}cuerpo$CR${NL}EOF$NL")"
fila46 "HC8b coordinadora: heredoc ordinario de delimitador citado (control)" guard.sh allow allow allow allow - "$(j46 Bash "$P46" - "command=cat <<'EOF' > docs/x.md${NL}x${NL}EOF$NL")"
# HC9: H1-H3, H5 y H6 de la sección 45 (delimitador con CR, punto 17): sus veredictos de hoy; v1.33.2 no se mide aquí (lo mide la 45 en su fail-before).
H1_46="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR${NL}echo x > src/a.ts$NL"; H2_46="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR$NL"
fila46 "HC9.1 coordinadora: H1 de la 45 (punto 17)" guard-codigo.sh deny deny deny - "$HCR46" "$(j46 Bash "$P46" - "command=$H1_46")"
fila46 "HC9.2 coordinadora: H2 de la 45 (punto 17)" guard-codigo.sh deny deny allow - "$HCR46" "$(j46 Bash "$P46" - "command=$H2_46")"
fila46 "HC9.3 coordinadora: H3 de la 45 (punto 17)" guard-codigo.sh deny deny allow - "$HCR46" "$(j46 Bash "$P46" - "command=cat <<${CR}EOF${NL}don't${NL}${CR}EOF${NL}echo x > 'src/a.ts'$NL")"
fila46 "HC9.5 el desarrollador: H5 de la 45 por guard-codigo sólo (punto 17)" guard-codigo.sh:solo allow allow allow - - "$(j46 Bash "$P46" desarrollador "command=$H2_46")"
fila46 "HC9.6 el desarrollador: H6 de la 45 por guard-completado (punto 17)" guard-completado.sh deny deny allow - "$HCR46" "$(j46 Bash "$P46" desarrollador "command=$H2_46")"

# --- LC: SEC-125, el destino que escribe el shell y la Excepción nombrada LC10 (CA-47, punto 19) -------
# (filas LC1-LC10: se añaden una a una)

rm -rf "$RFB46" "$R95_46" "$R133"
