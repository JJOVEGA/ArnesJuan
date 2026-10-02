# Sección 45 del banco — 45-dependencia-del-proceso-y-cr-del-comando
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# Octava autorización del propietario (2026-10-02), punto 2, a NIVEL DE HOOK:
#   S, B  SEC-122: ningún prefijo queda fuera de la identidad del destino —un enlace corriente bajo
#         /dev/shm (cara a) y un proyecto situado bajo /dev/shm (cara b) se juzgan como en otro sitio—;
#   P, N  lo que depende del proceso que abre la ruta no recibe permiso por esa incertidumbre, y lo
#         legítimo bajo /dev (/dev/null, /dev/stderr) sigue pasando sin excepción por su nombre;
#   K, H, G  P-023-13-A: el texto del comando de `Bash` llega con sus retornos de carro, se juzga lo
#         que el shell escribe, y el delimitador de heredoc con CR —que el analizador no sigue— se
#         deniega con motivo;
#   Q     QA-023-14: la lectura de la entrada conserva el CR del dato sin recorrer el valor.
# TRES ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`), el FAIL-BEFORE 3bc7d3c y la REFERENCIA de los
# movimientos 9596e39, materializados POR SHA (`mat45`, copia de `mat44`); sin ellos, SKIP y motivo.
# Cada fila juzgada por un guardián se comprueba además en la candidata por `guard.sh`. Las filas que
# dependen de /dev/shm o de /proc se miden sólo en Linux (donde se midió; F6), y fuera, SKIP y motivo.
# Esto NO es la validación en el host.
CASOS_ESPERADOS_SECCION=160
PISO_AUTONOMO_SECCION=76  # 20 preámbulo (líneas 1-20, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO45, mat45_reg y mat45, copia de mat44, líneas 21-44) + 32 bloque indivisible mayor (g45, juicio45, fila45 y fila45c, líneas 58-89)
seccion_nueva "--- 45 · dependencia del proceso y CR del comando (SEC-122, P-023-13-A, QA-023-14; octava autorización) ---"
REPO45="${SEC_DIR%/}/../../../.."; MAT45_RUTAS='hooks'; MAT45_REG=''; MAT45_T0=0; MAT45_REF='-'
mat45_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT45_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT45_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT45_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT45_T0 )) procesos=$4 etiqueta=$MAT45_REF ref=$MAT45_REF archivos=$3"
}
# mat45 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat45() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT45_T0=${EPOCHREALTIME/./}; MAT45_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO45" ls-tree -r "$ref" -- $MAT45_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat45_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO45" archive "$ref" $MAT45_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat45_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO45" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat45_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat45_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat45_reg ok - "$n" 6
}
RFB="$RAIZ/r3bc-$BASHPID"; RFB_OK=no; RFB_MOT=''; R95="$RAIZ/r95b-$BASHPID"; R95_OK=no; R95_MOT=''
if mat45 3bc7d3c "$RFB"; then RFB_OK=si
else RFB_MOT="3bc7d3c no se materializó (${MAT45_REG#*motivo=})"; RFB_MOT="${RFB_MOT%% corrida=*})"; fi
if mat45 9596e39 "$R95"; then R95_OK=si
else R95_MOT="9596e39 no se materializó (${MAT45_REG#*motivo=})"; R95_MOT="${R95_MOT%% corrida=*})"; fi
v45() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
# ¿Se puede medir lo que depende de /dev/shm y de /proc? Sólo en Linux, donde se midió.
LNX45=no; LNX45_MOT='sólo se midió en Linux (F6 de REQ-007 CA-47); aquí no es Linux'
if [ "$(uname -s 2>/dev/null)" = Linux ]; then
  if [ -d /dev/shm ] && [ -w /dev/shm ] && [ "$(cd -P /proc/self 2>/dev/null && [ "$PWD" = "/proc/$BASHPID" ] && printf si)" = si ]; then LNX45=si
  else LNX45_MOT='Linux sin /dev/shm escribible o sin /proc/self'; fi
fi
P45="$PROJ"; NL=$'\n'; CR=$'\r'
# g45 <dir de hooks> <guardián> <json> -> D45 (deny|allow) y M45 (el motivo). El proyecto es $P45.
D45=''; M45=''
g45() {
  local h="$1" s="$2" json="$3" out; D45=''; M45=''; [ -n "$json" ] || return 1
  out="$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$P45" bash "$h/$s" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D45=deny ;; *) D45=allow ;; esac
  M45="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
juicio45() {   # <nombre> <allow|deny> <cita|-> — sobre D45/M45; la cita se exige al motivo de un deny
  if [ "$D45" != "$2" ]; then v45 FAIL "$1  esperado=$2 got=$D45  <${M45:0:220}>"
  elif [ "$2" = deny ] && [ "$3" != - ] && [[ "$M45" != *"$3"* ]]; then v45 FAIL "$1  el motivo no cita «$3»  <${M45:0:240}>"
  else v45 PASS "$1  ($D45)"; fi
}
# fila45 <id> <guardián> <candidata> <3bc7d3c> <9596e39> <cita|-> <json>: un caso por árbol y, si el
# guardián no es guard.sh, otro de la candidata por guard.sh. La cita se exige sólo en la candidata.
# `<guardián>:solo` mide sólo ese guardián (la fila que mide justo lo que otro guardián cambiaría).
fila45() {
  local id="$1" s="${2%:solo}" ec="$3" efb="$4" e95="$5" cita="$6" json="$7" nom="REQ-007 octava $1" g=1
  [ "$s" != guard.sh ] && [ "$s" = "$2" ] || g=0
  if ! json_no_vacio "$nom candidata" "$json"; then FAIL=$((FAIL + 2 + g)); return 0; fi
  g45 "$HOOKS_DIR" "$s" "$json"; juicio45 "$nom candidata" "$ec" "$cita"
  if [ "$g" = 1 ]; then g45 "$HOOKS_DIR" guard.sh "$json"; juicio45 "$nom candidata por guard.sh" "$ec" "$cita"; fi
  if [ "$RFB_OK" = si ]; then g45 "$RFB/hooks" "$s" "$json"; juicio45 "$nom 3bc7d3c (fail-before o control)" "$efb" -
  else v45 SKIP "$nom 3bc7d3c  $RFB_MOT"; fi
  if [ "$R95_OK" = si ]; then g45 "$R95/hooks" "$s" "$json"; juicio45 "$nom 9596e39 (referencia de los movimientos)" "$e95" -
  else v45 SKIP "$nom 9596e39  $R95_MOT"; fi
}
fila45c() {   # <si|no> <motivo> <fila45…>: la fila, o tantos SKIP como casos tendría
  if [ "$1" = si ]; then shift 2; fila45 "$@"; return 0; fi
  local mot="$2" k n=3; shift 2; case "$2" in guard.sh|*:solo) ;; *) n=4 ;; esac
  for ((k = 0; k < n; k++)); do v45 SKIP "REQ-007 octava $1 ($((k + 1))/$n)  $mot"; done
}
jq '.codigo_app.globs = ["src/*", "app/*.ts"]' "$P45/.arnes/config.json" > "$P45/.arnes/c45" && mv "$P45/.arnes/c45" "$P45/.arnes/config.json"
mkdir -p "$P45/app"; R="$P45/requirements"; printf 'x\n' > "$P45/src/a.ts"
req45() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }
req45 "$R/REQ-900.md" pendiente; req45 "$R/REQ-901.md" aprobado
printf '# REQ-920\nEstado: en-revisión (tras “R-4”)\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$R/REQ-920.md"
j45() {   # <herramienta> <cwd|-> <agente|-> <k=v…>: todo LITERAL, saltos y CR incluidos
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
cierre45() { j45 Edit "${2:-$P45}" - "file_path=$1" 'old_string=Estado: en-revisión' 'new_string=Estado: completado'; }
QA45="veredicto de QA es 'pendiente'"; SRC45="código de la app"; ND45='no se pudo determinar a que archivo escribe'
PRO45='depende del proceso que la abre'; HCR45='delimitador contiene un retorno de carro'; ENL45='ENLACE SIMBOLICO situado dentro del proyecto'
FUERA45="$RAIZ/fuera45-$BASHPID"; mkdir -p "$FUERA45"; SHM45="/dev/shm/arnes-banco45-$BASHPID"
if [ "$LNX45" = si ]; then
  mkdir -p "$SHM45"; ln -s "$R" "$SHM45/req"; ln -s "$P45/src" "$SHM45/src"; ln -s "$P45/src/a.ts" "$SHM45/a.ts"
  ln -s /proc/self/cwd "$FUERA45/pc"
fi

# --- S: SEC-122, cara (a) — enlaces corrientes bajo /dev/shm (resolución de nombres) -------------
fila45c "$LNX45" "$LNX45_MOT" "S1 Edit /dev/shm/<enlace a requirements>/REQ-900.md cierra en rojo" guard-completado.sh deny allow allow "$QA45" "$(cierre45 "$SHM45/req/REQ-900.md")"
fila45c "$LNX45" "$LNX45_MOT" "S2 coordinadora: Write /dev/shm/<enlace a src>/a.ts" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Write "$P45" - "file_path=$SHM45/src/a.ts" content=x)"
fila45c "$LNX45" "$LNX45_MOT" "S3 sed -i que cierra por /dev/shm/<enlace>/REQ-900.md" guard-completado.sh deny allow allow "menciona 'completado'" "$(j45 Bash "$P45" - "command=sed -i 's/en-revisión/completado/' $SHM45/req/REQ-900.md")"
fila45c "$LNX45" "$LNX45_MOT" "S4 coordinadora: echo x > /dev/shm/<enlace de archivo a src/a.ts>" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$P45" - "command=echo x > $SHM45/a.ts")"
fila45c "$LNX45" "$LNX45_MOT" "S5 SEC-117 no reconstruible por /dev/shm/<enlace>/REQ-920.md" guard-completado.sh deny allow allow 'no puede reconstruir' "$(j45 Edit "$P45" - "file_path=$SHM45/req/REQ-920.md" 'old_string=en-revisión (tras "R-4")' new_string=completado)"
fila45c "$LNX45" "$LNX45_MOT" "S6 el desarrollador: echo x > /dev/shm/<enlace a src>/a.ts (control)" guard.sh allow allow allow - "$(j45 Bash "$P45" desarrollador "command=echo x > $SHM45/src/a.ts")"

# --- P: lo que depende del proceso que abre la ruta ---------------------------------------------
fila45c "$LNX45" "$LNX45_MOT" "P1 coordinadora: echo x > /proc/self/cwd/src/a.ts, cwd <raíz> (el shell escribe src/a.ts)" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$P45" - 'command=echo x > /proc/self/cwd/src/a.ts')"
fila45c "$LNX45" "$LNX45_MOT" "P2 coordinadora: lo mismo con cwd <raíz>/docs (designa docs/src/a.ts)" guard.sh allow allow allow - "$(j45 Bash "$P45/docs" - 'command=echo x > /proc/self/cwd/src/a.ts')"
fila45c "$LNX45" "$LNX45_MOT" "P3 coordinadora: Write /proc/self/cwd/src/a.ts (escribe el host, cuyo cwd no se conoce)" guard-codigo.sh deny allow allow "$PRO45" "$(j45 Write "$P45" - "file_path=/proc/self/cwd/src/a.ts" content=x)"
fila45c "$LNX45" "$LNX45_MOT" "P4 Edit /proc/self/root<raíz>/requirements/REQ-900.md cierra en rojo" guard-completado.sh deny allow allow "$QA45" "$(cierre45 "/proc/self/root$R/REQ-900.md")"
fila45c "$LNX45" "$LNX45_MOT" "P5 coordinadora: echo x > <fuera>/pc/src/a.ts (pc -> /proc/self/cwd), cwd <raíz>" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$P45" - "command=echo x > $FUERA45/pc/src/a.ts")"
fila45c "$LNX45" "$LNX45_MOT" "P6 coordinadora: echo x > /dev/fd/9/a.ts (una ruta detrás de un descriptor)" guard-codigo.sh deny allow allow "$PRO45" "$(j45 Bash "$P45" - 'command=echo x > /dev/fd/9/a.ts')"
fila45c "$LNX45" "$LNX45_MOT" "P7 coordinadora: echo x > /proc/self/cwd/src/a.ts sin cwd en la entrada" guard-codigo.sh deny allow allow "$PRO45" "$(j45 Bash - - 'command=echo x > /proc/self/cwd/src/a.ts')"
fila45c "$LNX45" "$LNX45_MOT" "P8 el desarrollador: echo x > /proc/self/cwd/src/a.ts (control)" guard.sh allow allow allow - "$(j45 Bash "$P45" desarrollador 'command=echo x > /proc/self/cwd/src/a.ts')"
fila45c "$LNX45" "$LNX45_MOT" "P9 coordinadora: Write /dev/stderr (descriptor del proceso del host: de allow a deny, declarado)" guard-codigo.sh deny allow allow "$PRO45" "$(j45 Write "$P45" - "file_path=/dev/stderr" content=x)"

# --- N: lo legítimo bajo /dev sigue pasando, sin excepción por su nombre ---------------------------
fila45 "N1 coordinadora: ls -la > /dev/null 2>&1" guard.sh allow allow allow - "$(j45 Bash "$P45" - 'command=ls -la > /dev/null 2>&1')"
fila45 "N2 coordinadora: echo hola > /dev/stderr" guard.sh allow allow allow - "$(j45 Bash "$P45" - 'command=echo hola > /dev/stderr')"
fila45 "N3 coordinadora: echo hola > /dev/stdout" guard.sh allow allow allow - "$(j45 Bash "$P45" - 'command=echo hola > /dev/stdout')"
fila45 "N4 coordinadora: echo hola > /dev/fd/2" guard.sh allow allow allow - "$(j45 Bash "$P45" - 'command=echo hola > /dev/fd/2')"
fila45 "N5 coordinadora: echo hola | tee /dev/stderr" guard.sh allow allow allow - "$(j45 Bash "$P45" - 'command=echo hola | tee /dev/stderr')"
fila45 "N6 coordinadora: Write /dev/null" guard.sh allow allow allow - "$(j45 Write "$P45" - "file_path=/dev/null" content=x)"

# --- K: el retorno de carro del texto del comando (P-023-13-A): se juzga lo que el shell escribe ---
ln -s ../src/a.ts "$P45/docs/k$CR" 2>/dev/null; ln -s ../requirements/REQ-900.md "$P45/docs/r$CR" 2>/dev/null
LK45=no; LK45_MOT='aquí no se pudo crear un enlace simbólico con un retorno de carro en el nombre'
[ -L "$P45/docs/k$CR" ] && [ -L "$P45/docs/r$CR" ] && LK45=si
fila45c "$LK45" "$LK45_MOT" "K1 coordinadora: printf x > k\\r (CR final), cwd docs; k\\r -> src/a.ts" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$P45/docs" - "command=printf x > k$CR")"
fila45c "$LK45" "$LK45_MOT" "K2 coordinadora: printf x > k\\r\\ntrue (CR antes de un salto), cwd docs" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$P45/docs" - "command=printf x > k$CR${NL}true")"
fila45c "$LK45" "$LK45_MOT" "K3 sed -i que cierra por docs/r\\r (enlace al REQ en rojo)" guard-completado.sh deny allow allow "menciona 'completado'" "$(j45 Bash "$P45" - "command=sed -i 's/en-revisión/completado/' docs/r$CR")"
fila45c "$LK45" "$LK45_MOT" "K4 coordinadora: echo x | tee docs/k\\r" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$P45" - "command=echo x | tee docs/k$CR")"
fila45 "K5 coordinadora: printf x > docs/n.md\\r (escribe docs/n.md\\r, fuera)" guard.sh allow allow allow - "$(j45 Bash "$P45" - "command=printf x > docs/n.md$CR")"
fila45 "K6 coordinadora: printf x > app/a.ts\\r (no casa app/*.ts: de deny a allow, declarado)" guard.sh allow deny deny - "$(j45 Bash "$P45" - "command=printf x > app/a.ts$CR")"
fila45 "K7 coordinadora: printf x > app/a.ts (control: casa app/*.ts)" guard-codigo.sh deny deny deny "$SRC45" "$(j45 Bash "$P45" - 'command=printf x > app/a.ts')"
fila45 "K8 coordinadora: echo hola\\r\\nls\\r\\n (comando CRLF sin escrituras)" guard.sh allow allow allow - "$(j45 Bash "$P45" - "command=echo hola$CR${NL}ls$CR$NL")"

# --- H: el delimitador de un heredoc con CR — el analizador no lo sigue, y se deniega con motivo ---
H1="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR${NL}echo x > src/a.ts$NL"; H2="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR$NL"
fila45 "H1 coordinadora: heredoc CRLF citado y después echo x > src/a.ts" guard-codigo.sh deny deny deny "$HCR45" "$(j45 Bash "$P45" - "command=$H1")"
fila45 "H2 coordinadora: heredoc CRLF citado a docs/x.md (de allow a deny, declarado)" guard-codigo.sh deny allow allow "$HCR45" "$(j45 Bash "$P45" - "command=$H2")"
fila45 "H3 coordinadora: delimitador que empieza por CR y comillas en el cuerpo (preexistente)" guard-codigo.sh deny allow allow "$HCR45" "$(j45 Bash "$P45" - "command=cat <<${CR}EOF${NL}don't${NL}${CR}EOF${NL}echo x > 'src/a.ts'$NL")"
fila45 "H4 coordinadora: heredoc con CR sólo en el cuerpo (delimitador limpio)" guard.sh allow allow allow - "$(j45 Bash "$P45" - "command=cat > docs/x.md <<'EOF'${NL}cuerpo$CR${NL}EOF$NL")"
fila45 "H5 el desarrollador: H2 por guard-codigo (podía escribir)" guard-codigo.sh:solo allow allow allow - "$(j45 Bash "$P45" desarrollador "command=$H2")"
fila45 "H6 el desarrollador: H2 por guard-completado (sin análisis no se sabe si toca un REQ)" guard-completado.sh deny allow allow "$HCR45" "$(j45 Bash "$P45" desarrollador "command=$H2")"

# --- G: guard-git juzga el comando que recibe git (git rechaza el argumento con CR) ---------------
fila45 "G1 git reset --hard\\r (opción desconocida para git: de deny a allow, declarado)" guard-git.sh allow deny deny - "$(j45 Bash "$P45" - "command=git reset --hard$CR")"
fila45 "G2 git reset --hard (control)" guard-git.sh deny deny deny "reset --hard" "$(j45 Bash "$P45" - 'command=git reset --hard')"
fila45 "G3 git reset --hard \\r (el CR es otro argumento: --hard se ve)" guard-git.sh deny deny deny "reset --hard" "$(j45 Bash "$P45" - "command=git reset --hard $CR")"

# --- B: SEC-122, cara (b) — el proyecto situado bajo /dev/shm ------------------------------------
PB45="$SHM45/proj"
if [ "$LNX45" = si ]; then
  mkdir -p "$PB45/requirements" "$PB45/src" "$PB45/docs"; cp -r "$P45/.arnes" "$P45/PENDING_APPROVAL.md" "$PB45/"
  req45 "$PB45/requirements/REQ-900.md" pendiente; req45 "$PB45/requirements/REQ-901.md" aprobado; printf 'x\n' > "$PB45/src/a.ts"
  ln -s ../requirements/REQ-900.md "$PB45/docs/enlace.md"; ln -s ../src/a.ts "$PB45/docs/a-enlace.ts"; ln -s ../src "$PB45/docs/dsrc"
  P45="$PB45"
fi
fila45c "$LNX45" "$LNX45_MOT" "B1 Edit por docs/enlace.md (enlace en el último componente) que cierra" guard-completado.sh deny allow deny "$ENL45" "$(cierre45 "$PB45/docs/enlace.md" "$PB45")"
fila45c "$LNX45" "$LNX45_MOT" "B2 coordinadora: Write por docs/a-enlace.ts (-> src/a.ts)" guard-codigo.sh deny allow deny "$ENL45" "$(j45 Write "$PB45" - "file_path=$PB45/docs/a-enlace.ts" content=x)"
fila45c "$LNX45" "$LNX45_MOT" "B3 Edit literal sin estado sobre un REQ que existe (3bc7d3c lo sobredenegaba)" guard.sh allow deny allow - "$(j45 Edit "$PB45" - "file_path=$PB45/requirements/REQ-900.md" old_string=nota 'new_string=otra nota')"
fila45c "$LNX45" "$LNX45_MOT" "B4 coordinadora: echo x > docs/dsrc/a.ts (directorio enlazado)" guard-codigo.sh deny allow allow "$SRC45" "$(j45 Bash "$PB45" - 'command=echo x > docs/dsrc/a.ts')"
fila45c "$LNX45" "$LNX45_MOT" "B5 cierre en verde de REQ-901 (3bc7d3c lo sobredenegaba)" guard.sh allow deny allow - "$(cierre45 "$PB45/requirements/REQ-901.md" "$PB45")"
P45="$PROJ"

# --- Q: la lectura de la entrada conserva el CR del dato (QA-023-14), sin recorrer el valor --------
Q45_IN="$(jq -cn '{tool_name:"Bash\r",cwd:"/tmp",tool_input:{file_path:"a\r\nb\r",command:"ls\r\nx > y\r"}}')"
printf -v Q45_ESP '%q|' "Bash$CR" "a$CR${NL}b$CR" "ls$CR${NL}x > y$CR" 1 0 1
q45() {   # <dir de hooks> [dir con un jq envoltorio delante en el PATH] -> Q45
  Q45="$( [ -z "${2:-}" ] || PATH="$2:$PATH"; . "$1/lib.sh" 2>/dev/null; ARNES_INPUT="$Q45_IN"; ARNES_INPUT_LISTO=''; arnes_parse_input
          printf '%q|' "$ARNES_TOOL" "$ARNES_FP" "$ARNES_CMD" "${ARNES_TOOL_CR-}" "${ARNES_CWD_CR-}" "${ARNES_FP_CR-}" )"
}
nom45="QA-023-14 Q1 arnes_parse_input conserva el CR final y el que precede a un salto, en tool_name, file_path y command"
q45 "$HOOKS_DIR"
if [ "$Q45" = "$Q45_ESP" ]; then v45 PASS "$nom45  candidata"; else v45 FAIL "$nom45  candidata: <$Q45> en vez de <$Q45_ESP>"; fi
if [ "$RFB_OK" != si ]; then v45 SKIP "$nom45  3bc7d3c (fail-before)  $RFB_MOT"
else
  q45 "$RFB/hooks"
  if [ -n "$Q45" ] && [ "$Q45" != "$Q45_ESP" ]; then v45 PASS "$nom45  3bc7d3c (fail-before): los pierde  <$Q45>"
  else v45 FAIL "$nom45  3bc7d3c (fail-before): no los pierde, el caso no distingue  <$Q45>"; fi
fi
# El transporte del jq de Windows, EMULADO sobre Linux (no es Windows): un envoltorio que añade un CR a
# cada línea de la salida. La primera línea lo delata y se retira exactamente ese CR.
JQW45="$RAIZ/jqw45-$BASHPID"; mkdir -p "$JQW45"; JQR45="$(command -v jq)"
printf '#!/usr/bin/env bash\nset -o pipefail\n"%s" "$@" | sed '"'"'s/$/\\r/'"'"'\n' "$JQR45" > "$JQW45/jq"; chmod +x "$JQW45/jq"
nom45="QA-023-14 Q2 con un jq que añade CR a cada línea (emulación del de Windows), los valores llegan iguales"
q45 "$HOOKS_DIR" "$JQW45"
if [ "$Q45" = "$Q45_ESP" ]; then v45 PASS "$nom45  candidata"; else v45 FAIL "$nom45  candidata: <$Q45> en vez de <$Q45_ESP>"; fi
Q45_IN="$(jq -cn '{tool_name:"Write",cwd:"/tmp",tool_input:{file_path:"/tmp/f",command:"ls"}}')"; printf -v Q45_ESP '%q|' Write /tmp/f ls 0 0 0
nom45="QA-023-14 Q3 sin CR en el dato, el jq que añade CR no deja ninguno (ningún falso positivo)"
q45 "$HOOKS_DIR" "$JQW45"
if [ "$Q45" = "$Q45_ESP" ]; then v45 PASS "$nom45  candidata"; else v45 FAIL "$nom45  candidata: <$Q45> en vez de <$Q45_ESP>"; fi
rm -rf "$RFB" "$R95" "$FUERA45" "$JQW45"; [ "$LNX45" != si ] || rm -rf "$SHM45"
