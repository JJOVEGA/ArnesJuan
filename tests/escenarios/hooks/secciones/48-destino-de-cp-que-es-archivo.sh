# Sección 48 del banco — 48-destino-de-cp-que-es-archivo
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# Hotfix 1.36.1 (F-137-10), REQ-032: «un destino que existe y es archivo se juzga como archivo, en cp, mv e
# install». Desde 1.35.0 el detector de `Bash` juzgaba además `destino/`, que sobre un archivo que existe no se
# puede recorrer: REQ-007 CA-47 lo declaraba no determinable y lo denegaba a quien no es el agente de código.
#   F, K  CA-02, y CA-03 (a): la misma matriz con `mv` e `install`, que comparten la causa (el motivo de
#         v1.36.0 cita la ruta CON la barra final en las tres órdenes);
#   A  CA-04 (un archivo protegido, por las rutas que llegan a él) · C  CA-05 (el cierre se deriva) ·
#   D  CA-06 (destino directorio) · N  CA-07 (destino inexistente) · U  CA-08 (lo que no se sabe) ·
#   T  CA-10 (`-t`, `--target-directory` y la redirección con barra final, como estaban) ·
#   G  el comando que menciona el estado terminal: restricción declarada desde la vuelta 2 (CA-15 (2)) ·
#   R  CA-15 (QA-032-01): redirección, comentario, `-t` en cualquier forma, comillas o salto de línea: la decisión
#      de v1.36.0 (R1–R13, y R14/R15 = R1 y R7–R12 con `mv` e `install`; R16 y R17, formas halladas en la pasada) ·
#   H  P-032-4 (B): un destino con más de un enlace duro vuelve a la decisión de v1.36.0 (H1–H3) ·
#   M  la excepción del manifiesto roto: la causa está también ahí y NO se repara (CA-10; registrada) ·
#   ORÁCULO  CA-01 (`cat S > D`) · P1  CA-12 (a)(b), procesos frente a v1.36.0 en la misma corrida ·
#   X, P1–P8, E1, O1, H4, L  CA-15 vuelta 2 (P-032-5 (C)): sólo una invocación simple, con opciones de la lista.
# DOS ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`) y v1.36.0 (f22b905), por SHA con `mat48` (copia de
# `mat47`); sin ella, SKIP y motivo, nunca PASS. Las filas se juzgan por guard.sh —lo que recibe el cliente—
# salvo C (guard-completado). Las que dependen de enlaces simbólicos, de una FIFO, de un directorio en modo
# 000 o de /dev/null salen SKIP con motivo donde no se pueden construir. Esto NO es la validación en el host.
CASOS_ESPERADOS_SECCION=546
PISO_AUTONOMO_SECCION=76  # 25 preámbulo (líneas 1-25, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO48, mat48_reg y mat48, copia de mat47, líneas 26-49) + 27 bloque indivisible mayor (g48, juicio48, fila48 y fila48c, líneas 73-99)
seccion_nueva "--- 48 · el destino de cp/mv/install que existe y es archivo (REQ-032, hotfix 1.36.1) ---"
REPO48="${SEC_DIR%/}/../../../.."; MAT48_RUTAS='hooks'; MAT48_REG=''; MAT48_T0=0; MAT48_REF='-'
mat48_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT48_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT48_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT48_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT48_T0 )) procesos=$4 etiqueta=$MAT48_REF ref=$MAT48_REF archivos=$3"
}
# mat48 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat48() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT48_T0=${EPOCHREALTIME/./}; MAT48_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO48" ls-tree -r "$ref" -- $MAT48_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat48_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO48" archive "$ref" $MAT48_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat48_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO48" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat48_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat48_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat48_reg ok - "$n" 6
}
RV48="$RAIZ/rv136-48-$BASHPID"; RV48_OK=no; RV48_MOT=''
if mat48 f22b905 "$RV48"; then RV48_OK=si
else RV48_MOT="v1.36.0 (f22b905) no se materializó (${MAT48_REG#*motivo=})"; RV48_MOT="${RV48_MOT%% corrida=*})"; fi
v48() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
# El proyecto: el manifiesto base (globs `src/*` y `app/*`; `app` no existe), un REQ sin estado terminal y un
# archivo fuera de todo ámbito (`docs/notas.md`), con los enlaces, la FIFO y el directorio cerrado de U.
P48="$PROJ"; R48="$P48/requirements"; PD48="$P48"
printf '# REQ-X\nEstado: en-revisión\nQA: pendiente\n' > "$R48/REQ-X.md"; printf 'n\n' > "$P48/docs/notas.md"; printf 'a\n' > "$P48/src/a.ts"
mkdir -p "$P48/docs/sub" "$P48/docs/cerrado"
ln -s notas.md "$P48/docs/enlace-notas" 2>/dev/null; ln -s ../src/a.ts "$P48/docs/enlace-src" 2>/dev/null
ln -s ../src "$P48/docs/dsrc" 2>/dev/null; ln -s sub "$P48/docs/esub" 2>/dev/null; ln -s noexiste "$P48/docs/roto" 2>/dev/null
LN48=no; LN48_MOT='aquí no se pudo crear un enlace simbólico (ln -s copia o falla): la fila no mediría un enlace'
[ -L "$P48/docs/enlace-notas" ] && [ -L "$P48/docs/enlace-src" ] && [ -L "$P48/docs/dsrc" ] && [ -L "$P48/docs/esub" ] && [ -L "$P48/docs/roto" ] && LN48=si
FI48=no; mkfifo "$P48/docs/fifo" 2>/dev/null && [ -p "$P48/docs/fifo" ] && FI48=si
chmod 000 "$P48/docs/cerrado" 2>/dev/null; CE48=no; [ -x "$P48/docs/cerrado" ] || CE48=si
NU48=no; [ -c /dev/null ] && NU48=si
# El directorio del PROCESO del hook en U4: allí `src` es un ARCHIVO; en el `cwd` de la entrada es un directorio protegido.
DP48="$RAIZ/dp48-$BASHPID"; mkdir -p "$DP48"; printf 'x\n' > "$DP48/src"
j48() {   # <cwd|-> <agente|-> <comando> -> la entrada de Bash, con el agente como subagente real (agent_id)
  jq -cn --arg c "$1" --arg a "$2" --arg k "$3" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$k}}
    + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a48",agent_type:$a} else {} end)'
}
# g48 <dir de hooks> <guardián> <json> [dir del proceso] -> D48 (deny|allow) y M48 (el motivo). Proyecto: $PD48.
D48=''; M48=''
g48() {
  local h="$1" s="$2" json="$3" out; D48=''; M48=''; [ -n "$json" ] || return 1
  out="$(cd "${4:-.}" && printf '%s' "$json" | CLAUDE_PROJECT_DIR="$PD48" bash "$h/$s" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D48=deny ;; *) D48=allow ;; esac
  [ "$D48" = allow ] || M48="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
juicio48() {   # <nombre> <allow|deny> <cita|-> — sobre D48/M48; la cita se exige al motivo de un deny
  if [ "$D48" != "$2" ]; then v48 FAIL "$1  esperado=$2 got=$D48  <${M48:0:220}>"
  elif [ "$2" = deny ] && [ "$3" != - ] && [[ "$M48" != *"$3"* ]]; then v48 FAIL "$1  el motivo no cita «$3»  <${M48:0:240}>"
  else v48 PASS "$1  ($D48)"; fi
}
# fila48 <id> <guardián> <candidata> <v1.36.0> <cita candidata|-> <cita v1.36.0|-> <json> [dir del proceso]: un caso
# por árbol. Una fila con `deny` en v1.36.0 y `allow` en la candidata es el FAIL-BEFORE: v1.36.0 tiene que denegar
# de verdad, y con la cita que se le pida (la ruta con la barra final, para M-032).
fila48() {
  local nom="REQ-032 $1" s="$2" ec="$3" ev="$4" cc="$5" cv="$6" json="$7" dp="${8:-}" etq='control, decide igual'
  [ "$ec:$ev" != allow:deny ] || etq='fail-before'
  if ! json_no_vacio "$nom" "$json"; then v48 FAIL "$nom v1.36.0  la entrada salió vacía: no se midió"; return 0; fi
  g48 "$HOOKS_DIR" "$s" "$json" "$dp"; juicio48 "$nom candidata" "$ec" "$cc"
  if [ "$RV48_OK" != si ]; then v48 SKIP "$nom v1.36.0 ($etq)  $RV48_MOT"; return 0; fi
  g48 "$RV48/hooks" "$s" "$json" "$dp"; juicio48 "$nom v1.36.0 ($etq)" "$ev" "$cv"
}
fila48c() {   # <si|no> <motivo> <fila48…>: la fila, o los dos SKIP que tendría
  if [ "$1" = si ]; then shift 2; fila48 "$@"; return 0; fi
  v48 SKIP "REQ-032 $3 candidata  $2"; v48 SKIP "REQ-032 $3 v1.36.0  $2"
}
ND48='no se pudo determinar a que archivo escribe'; SRC48='código de la app'; ROTO48='NO se puede leer'

# --- F, K: CA-02 y CA-03 (a) — la matriz, con cp, mv e install ------------------------------------------------
for o in cp mv install; do
  fila48 "F1 $o coordinadora: $o S <raíz>/requirements/REQ-X.md" guard.sh allow deny - "REQ-X.md/'" "$(j48 "$P48" - "$o S $R48/REQ-X.md")"
  fila48 "F2 $o coordinadora: $o S requirements/REQ-X.md (cwd <raíz>)" guard.sh allow deny - "requirements/REQ-X.md/'" "$(j48 "$P48" - "$o S requirements/REQ-X.md")"
  fila48 "F3 $o coordinadora: $o S <raíz>/docs/notas.md" guard.sh allow deny - "notas.md/'" "$(j48 "$P48" - "$o S $P48/docs/notas.md")"
  fila48 "F4 $o coordinadora: $o -T S <raíz>/requirements/REQ-X.md (RESTRICCIÓN: -T fuera de la lista, CA-15 (3))" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o -T S $R48/REQ-X.md")"
  fila48 "F6 $o qa-tester: $o S <raíz>/docs/notas.md" guard.sh allow deny - "notas.md/'" "$(j48 "$P48" qa-tester "$o S $P48/docs/notas.md")"
  fila48 "F7 $o analista-requerimientos: $o S <raíz>/requirements/REQ-X.md" guard.sh allow deny - "REQ-X.md/'" "$(j48 "$P48" analista-requerimientos "$o S $R48/REQ-X.md")"
  fila48c "$LN48" "$LN48_MOT" "F8 $o coordinadora: $o S <raíz>/docs/enlace-notas (-> notas.md)" guard.sh allow deny - "enlace-notas/'" "$(j48 "$P48" - "$o S $P48/docs/enlace-notas")"
  fila48 "F5 $o desarrollador: $o S <raíz>/requirements/REQ-X.md (control)" guard.sh allow allow - - "$(j48 "$P48" desarrollador "$o S $R48/REQ-X.md")"
  fila48 "K1 $o coordinadora: $o S <raíz>/docs/nuevo-inexistente.md (control)" guard.sh allow allow - - "$(j48 "$P48" - "$o S $P48/docs/nuevo-inexistente.md")"
  fila48 "K2 $o desarrollador: $o S <raíz>/src/nuevo.ts, inexistente (control)" guard.sh allow allow - - "$(j48 "$P48" desarrollador "$o S $P48/src/nuevo.ts")"
  fila48c "$LN48" "$LN48_MOT" "K4 $o coordinadora: $o S <raíz>/docs/enlace-src (-> src/a.ts, protegido)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S $P48/docs/enlace-src")"
  fila48c "$LN48" "$LN48_MOT" "K4 $o qa-tester: $o S <raíz>/docs/enlace-src (-> src/a.ts, protegido)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" qa-tester "$o S $P48/docs/enlace-src")"
done
fila48 "K3 coordinadora: cat S > <raíz>/requirements/REQ-X.md (control)" guard.sh allow allow - - "$(j48 "$P48" - "cat S > $R48/REQ-X.md")"

# --- A: CA-04 — un archivo protegido que existe, por las rutas que llegan a él: deny antes y después -------------
for o in cp mv install; do
  fila48 "A1 $o coordinadora: $o S <raíz>/src/a.ts" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S $P48/src/a.ts")"
  fila48 "A2 $o qa-tester: $o S <raíz>/src/a.ts" guard.sh deny deny "$SRC48" - "$(j48 "$P48" qa-tester "$o S $P48/src/a.ts")"
  fila48 "A3 $o coordinadora: $o S src/a.ts (cwd <raíz>)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S src/a.ts")"
  fila48 "A4 $o coordinadora: $o S ../src/a.ts (cwd <raíz>/docs)" guard.sh deny deny "$SRC48" - "$(j48 "$P48/docs" - "$o S ../src/a.ts")"
  fila48 "A5 $o coordinadora: $o S ./src/../src/a.ts" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S ./src/../src/a.ts")"
  fila48 "A6 $o coordinadora: $o S <raíz>/src//a.ts" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S $P48/src//a.ts")"
  fila48c "$LN48" "$LN48_MOT" "A7 $o coordinadora: $o S docs/dsrc/a.ts (dsrc -> ../src)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S docs/dsrc/a.ts")"
done

# --- C: CA-05 — el cierre de un REQ por cp/mv/install sigue derivándose a Edit/Write ----------------------------
for o in cp mv install; do
  for a in - desarrollador; do
    fila48 "C1 $o ${a/#-/coordinadora}: $o S <raíz>/requirements/REQ-X.md && echo completado" guard-completado.sh deny deny "Hazlo con Edit/Write" - "$(j48 "$P48" "$a" "$o S $R48/REQ-X.md && echo completado")"
  done
done

# --- D: CA-06 — un destino que es un directorio se juzga como `directorio/`, como en v1.36.0 -----------------------
for o in cp mv install; do
  fila48 "D1 $o coordinadora: $o S <raíz>/src (directorio protegido)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S $P48/src")"
  fila48 "D2 $o coordinadora: $o S <raíz>/src/ (directorio protegido, con barra)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S $P48/src/")"
  fila48 "D3 $o desarrollador: $o S src (control)" guard.sh allow allow - - "$(j48 "$P48" desarrollador "$o S src")"
  fila48 "D4 $o coordinadora: $o S <raíz>/docs (directorio no protegido)" guard.sh allow allow - - "$(j48 "$P48" - "$o S $P48/docs")"
  fila48 "D5 $o coordinadora: $o S <raíz>/docs/ (no protegido, con barra)" guard.sh allow allow - - "$(j48 "$P48" - "$o S $P48/docs/")"
  fila48c "$LN48" "$LN48_MOT" "D6 $o coordinadora: $o S docs/dsrc (enlace a un directorio protegido)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S docs/dsrc")"
  fila48c "$LN48" "$LN48_MOT" "D7 $o coordinadora: $o S docs/esub (enlace a un directorio no protegido)" guard.sh allow allow - - "$(j48 "$P48" - "$o S docs/esub")"
done

# --- N: CA-07 — un destino que no existe: lo protege su forma de directorio, que se conserva ---------------------
for o in cp mv install; do
  fila48 "N1 $o coordinadora: $o S <raíz>/app (inexistente; casa app/* por su forma de directorio)" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S $P48/app")"
done

# --- U: CA-08 — lo que no se puede afirmar que sea un archivo regular se juzga como en v1.36.0 -------------------
CE48_MOT='el directorio en modo 000 se deja recorrer (se corre como administrador): la fila no mediría «no determinable»'
for o in cp mv install; do
  fila48c "$CE48" "$CE48_MOT" "U1 $o coordinadora: $o S docs/cerrado/x (un directorio que no se puede recorrer)" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o S docs/cerrado/x")"
  fila48 "U2 $o coordinadora: $o S docs/notas.md sin cwd en la entrada" guard.sh deny deny "$ND48" - "$(j48 - - "$o S docs/notas.md")"
  fila48 "U3 $o coordinadora: $o S <raíz>/docs/noexiste/../notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o S $P48/docs/noexiste/../notas.md")"
  fila48 "U4 $o coordinadora: $o S src, cwd <raíz> y el proceso del hook donde src es un archivo" guard.sh deny deny "$SRC48" - "$(j48 "$P48" - "$o S src")" "$DP48"
  fila48 "U5 $o coordinadora: $o S <raíz>/docs/notas.md/ (barra final sobre un archivo)" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o S $P48/docs/notas.md/")"
  fila48c "$LN48" "$LN48_MOT" "U6 $o coordinadora: $o S docs/roto (enlace roto)" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o S docs/roto")"
  fila48c "$FI48" 'aquí no se pudo crear una FIFO' "U7 $o coordinadora: $o S docs/fifo (una FIFO)" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o S docs/fifo")"
  fila48c "$NU48" '/dev/null no es aquí un dispositivo de caracteres' "U8 $o coordinadora: $o S /dev/null (un dispositivo)" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "$o S /dev/null")"
done

# --- T: CA-10 — `-t`/`--target-directory` y la redirección con barra final quedan como estaban -------------------
fila48 "T1 coordinadora: cp -t src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "cp -t src docs/notas.md")"
fila48 "T2 coordinadora: cp --target-directory=src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "cp --target-directory=src docs/notas.md")"
fila48 "T3 coordinadora: cp -vt src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "cp -vt src docs/notas.md")"
fila48 "T4 coordinadora: mv -t src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "mv -t src docs/notas.md")"
fila48 "T5 coordinadora: install -t src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "install -t src docs/notas.md")"
fila48 "T6 coordinadora: echo x > docs/notas.md/ (redirección con barra final)" guard.sh deny deny "$ND48" - "$(j48 "$P48" - "echo x > docs/notas.md/")"

# --- R: CA-15 (QA-032-01, P-032-3 (A)) — si el segmento no permite asegurar que el último operando es el destino,
# la decisión es la de v1.36.0. Desde la coordinadora y desde qa-tester; `<raíz>/2` es un archivo regular (R2, R3).
printf '2\n' > "$P48/2"
for a in - qa-tester; do
  q="${a/#-/coordinadora}"
  for o in cp mv install; do
    if [ "$o" = cp ]; then
      fila48 "R2 $o $q: $o S src/a.ts 2>/dev/null (con un archivo 2)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S src/a.ts 2>/dev/null")"
      fila48 "R3 $o $q: $o S src/a.ts 2>&1 (con un archivo 2)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S src/a.ts 2>&1")"
      fila48 "R4 $o $q: $o S src/a.ts  # copia de docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S src/a.ts  # copia de docs/notas.md")"
      fila48 "R5 $o $q: $o -t src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o -t src docs/notas.md")"
      fila48 "R6 $o $q: $o -rt src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o -rt src docs/notas.md")"
      fila48 "R13 $o $q: $o \"-t\" requirements docs/notas.md && echo completado" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o \"-t\" requirements docs/notas.md && echo completado")"
      fila48 "R16 $o $q: $o docs/notas.md \"src/a.ts\" (el último operando entre comillas)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o docs/notas.md \"src/a.ts\"")"
      fila48 "R17 $o $q: $o S src/a.ts, salto de línea, echo docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S src/a.ts"$'\n'"echo docs/notas.md")"
    fi
    fila48 "R1 $o $q: $o S src/a.ts < docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S src/a.ts < docs/notas.md")"
    fila48 "R7 $o $q: $o \"-t\" src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o \"-t\" src docs/notas.md")"
    fila48 "R8 $o $q: $o '-t' src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o '-t' src docs/notas.md")"
    fila48 "R9 $o $q: $o \\-t src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o \\-t src docs/notas.md")"
    fila48 "R10 $o $q: $o -\"\"t src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o -\"\"t src docs/notas.md")"
    fila48 "R11 $o $q: $o \"--target-directory=src\" docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o \"--target-directory=src\" docs/notas.md")"
    fila48 "R12 $o $q: T=-t; $o \$T src docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "T=-t; $o \$T src docs/notas.md")"
  done
done

# --- G: el comando menciona el estado terminal; desde la vuelta 2 (P-032-5 (C)) es una RESTRICCIÓN declarada -----
for o in cp mv install; do
  for a in - desarrollador; do
    fila48 "G1 $o ${a/#-/coordinadora}: $o S <raíz>/docs/notas.md && echo completado (RESTRICCIÓN: no es una sola invocación, CA-15 (2))" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S $P48/docs/notas.md && echo completado")"
  done
done

# --- M: la excepción del manifiesto roto — la causa también está aquí, y NO se repara (CA-10; registrada) ---------
PM48="$RAIZ/pm48-$BASHPID"; mkdir -p "$PM48/.arnes" "$PM48/docs"; printf '{ "codigo_app": ' > "$PM48/.arnes/config.json"
cp "$P48/PENDING_APPROVAL.md" "$PM48/"; PD48="$PM48"
fila48 "M1 coordinadora: cp S .arnes/config.json con el manifiesto roto (no se repara: como en v1.36.0)" guard.sh deny deny "$ROTO48" - "$(j48 "$PM48" - "cp S .arnes/config.json")"
fila48 "M2 coordinadora: printf '{}' > .arnes/config.json con el manifiesto roto (control: la reparación pasa)" guard.sh allow allow - - "$(j48 "$PM48" - "printf '{}' > .arnes/config.json")"
PD48="$P48"

# --- O: el oráculo de CA-01 — con el destino existente, la orden decide como `cat S > D` -------------------------
nom48="REQ-032 ORÁCULO CA-01: sobre cada destino que existe (F1-F8, K4, A1-A4), cp, mv e install deciden como cat S > D"
mal48=''; n48=0
dests48=("$P48|-|$R48/REQ-X.md" "$P48|-|requirements/REQ-X.md" "$P48|-|$P48/docs/notas.md" "$P48|qa-tester|$P48/docs/notas.md"
  "$P48|analista-requerimientos|$R48/REQ-X.md" "$P48|desarrollador|$R48/REQ-X.md" "$P48|-|$P48/src/a.ts" "$P48|qa-tester|$P48/src/a.ts"
  "$P48|-|src/a.ts" "$P48/docs|-|../src/a.ts")
[ "$LN48" != si ] || dests48+=("$P48|-|$P48/docs/enlace-notas" "$P48|-|$P48/docs/enlace-src" "$P48|qa-tester|$P48/docs/enlace-src")
for e48 in "${dests48[@]}"; do
  IFS='|' read -r c48 a48 d48 <<< "$e48"
  jc48="$(j48 "$c48" "$a48" "cat S > $d48")"; [ -n "$jc48" ] || { mal48+=" (vacío: cat $d48)"; continue; }
  g48 "$HOOKS_DIR" guard.sh "$jc48"; ref48="$D48"
  for o in cp mv install; do
    g48 "$HOOKS_DIR" guard.sh "$(j48 "$c48" "$a48" "$o S $d48")"; n48=$((n48 + 1))
    [ "$D48" = "$ref48" ] || mal48+=" $o ${a48/#-/coordinadora} $d48: $D48 frente a cat $ref48;"
  done
done
if [ -n "$mal48" ]; then v48 FAIL "$nom48 $mal48"; else v48 PASS "$nom48  ($n48 comparaciones, todas iguales)"; fi

# --- H: P-032-4 (B) — un destino con más de un enlace duro vuelve a la decisión de v1.36.0 ------------------------
# En este proyecto se protege además `hooks/*`. Si el sistema no crea enlaces duros, SKIP con motivo.
jq '.codigo_app.globs += ["hooks/*"]' "$P48/.arnes/config.json" > "$P48/.arnes/c48" && mv "$P48/.arnes/c48" "$P48/.arnes/config.json"
mkdir -p "$P48/hooks"; printf 'l\n' > "$P48/hooks/lib.sh"; printf 'h\n' > "$P48/docs/h3-a"
ln "$P48/hooks/lib.sh" "$P48/docs/hl-lib" 2>/dev/null; ln "$P48/src/a.ts" "$P48/docs/hl-a" 2>/dev/null; ln "$P48/docs/h3-a" "$P48/docs/h3-b" 2>/dev/null
HL48=no; HL48_MOT='aquí no se pudo crear un enlace duro: la fila no mediría un enlace duro'
[ "$P48/docs/hl-lib" -ef "$P48/hooks/lib.sh" ] && [ "$P48/docs/hl-a" -ef "$P48/src/a.ts" ] && [ "$P48/docs/h3-b" -ef "$P48/docs/h3-a" ] && HL48=si
for a in - qa-tester; do
  q="${a/#-/coordinadora}"
  for o in cp mv install; do
    fila48c "$HL48" "$HL48_MOT" "H1 $o $q: $o S docs/hl-lib (enlace duro a hooks/lib.sh, protegido)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S docs/hl-lib")"
    fila48c "$HL48" "$HL48_MOT" "H2 $o $q: $o S docs/hl-a (enlace duro a src/a.ts, protegido)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S docs/hl-a")"
    fila48c "$HL48" "$HL48_MOT" "H3 $o $q: $o S docs/h3-b (enlace duro entre dos archivos de docs/, ninguno protegido: deny, RESTRICCIÓN ACEPTADA por P-032-4 (B))" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$o S docs/h3-b")"
  done
done

# --- Vuelta 2 (QA-032-02, P-032-5 (C)): la marca sólo se retira en UNA invocación simple de cp/mv/install -------
# Lo demás conserva la decisión de v1.36.0. L: opciones de la lista (M-032). `docs/lista` dice `src/a.ts`.
printf 'src/a.ts\n' > "$P48/docs/lista"
X5E=allow   # X5, medido el 2026-10-15: v1.36.0 PERMITE (el detector toma `\` por destino); se exige igualdad. Familia de F-137-14 (1.36.2)
FF48="$RAIZ/ff48-$BASHPID"; FN48="$RAIZ/fn48-$BASHPID"; RP48="$RAIZ/rp48-$BASHPID"; RPF48="$RAIZ/rpf48-$BASHPID"
mkdir -p "$FF48" "$FN48" "$RP48" "$RPF48"; printf '#!/bin/sh\nexit 1\n' > "$FF48/find"; printf '#!/bin/sh\nexit 0\n' > "$FN48/find"; chmod +x "$FF48/find" "$FN48/find"
# PATH sin `find` (H4c) y su control con `find` (H4k): sólo lo que los hooks usan; el control dice si basta.
for b in jq grep git readlink realpath mktemp cat tail head sed awk tr cut sort wc ls cp mv rm ln mkdir dirname basename stat date sleep touch chmod tee cmp iconv timeout env sh bash uname cygpath; do
  x="$(type -P "$b" 2>/dev/null)" && { ln -s "$x" "$RP48/$b"; ln -s "$x" "$RPF48/$b"; }
done
x="$(type -P find 2>/dev/null)" && ln -s "$x" "$RPF48/find"
for a in - qa-tester; do
  q="${a/#-/coordinadora}"
  for o in cp mv install; do
    fila48 "X1 $o $q: echo src/a.ts | xargs $o docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "echo src/a.ts | xargs $o docs/notas.md")"
    fila48 "X2 $o $q: xargs -a docs/lista $o docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "xargs -a docs/lista $o docs/notas.md")"
    fila48 "X5 $o $q: find src -name a.ts -exec $o docs/notas.md {} \; (igual que v1.36.0: allow, familia de F-137-14)" guard.sh "$X5E" "$X5E" - - "$(j48 "$P48" "$a" "find src -name a.ts -exec $o docs/notas.md {} \;")"
  done
  fila48 "X3 mv $q: cat docs/lista | xargs mv docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "cat docs/lista | xargs mv docs/notas.md")"
  fila48 "X4 install $q: cat docs/lista | xargs install docs/notas.md" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "cat docs/lista | xargs install docs/notas.md")"
  for k in 'P1|\cp' 'P2|command cp' 'P3|sudo cp' 'P4|nice cp' 'P5|env cp' 'P6|timeout 5 cp' 'P7|VAR=x cp' 'P8|/bin/cp'; do
    e='deny'; c="$ND48"; m=''
    # P1, medido el 2026-10-15: v1.36.0 PERMITE `\cp …` (el detector no la reconoce como `cp`: no ve ninguna escritura);
    # CA-15 pide entonces la igualdad. Familia de F-137-14.
    [ "${k%%|*}" != P1 ] || { e=allow; c=-; m=' (igual que v1.36.0: allow, el detector no ve la orden; familia de F-137-14)'; }
    fila48 "${k%%|*} $q: ${k#*|} S docs/notas.md$m" guard.sh "$e" "$e" "$c" - "$(j48 "$P48" "$a" "${k#*|} S docs/notas.md")"
  done
  for k in '&& echo hecho' '; ls' '| cat' '> /dev/null'; do
    fila48 "E1 $q: cp S docs/notas.md $k (RESTRICCIÓN: no es una sola invocación)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "cp S docs/notas.md $k")"
  done
  for k in 'cp -T' 'cp --' 'cp -b' 'install -m 644'; do
    fila48 "O1 $q: $k S docs/notas.md (opción fuera de la lista)" guard.sh deny deny "$ND48" - "$(j48 "$P48" "$a" "$k S docs/notas.md")"
  done
  for k in 'cp -fv' 'mv -n' 'install -pv' 'cp --force --verbose'; do
    fila48 "L1 $q: $k S docs/notas.md (opciones de la lista: M-032)" guard.sh allow deny - "notas.md/'" "$(j48 "$P48" "$a" "$k S docs/notas.md")"
  done
  # H4: el número de enlaces ilegible —find que falla, que no dice nada, ausente del PATH— y el control del PATH.
  j="$(j48 "$P48" "$a" "cp S docs/notas.md")"
  ( PATH="$FF48:$PATH"; fila48 "H4a $q: cp S docs/notas.md con un find que falla" guard.sh deny deny "$ND48" - "$j" )
  ( PATH="$FN48:$PATH"; fila48 "H4b $q: cp S docs/notas.md con un find sin salida" guard.sh deny deny "$ND48" - "$j" )
  ( PATH="$RP48"; fila48 "H4c $q: cp S docs/notas.md sin find en el PATH" guard.sh deny deny "$ND48" - "$j" )
  ( PATH="$RPF48"; fila48 "H4k $q: cp S docs/notas.md con ese mismo PATH y find (control: el PATH basta)" guard.sh allow deny - "notas.md/'" "$j" )
done

# --- P: CA-12 (a)(b) — procesos frente a v1.36.0 en la misma corrida: 0 añadidos ----------------------------------
nom48="REQ-032 PROC CA-12 procesos frente a v1.36.0: ls -la y npm run build (camino común) no añaden ninguno; la rama del destino existente (F3; H3, enlace duro) añade como mucho el find de P-032-4 (B)"
if [ "$RV48_OK" != si ]; then v48 SKIP "$nom48  $RV48_MOT"
else
  f48="$RAIZ/j48-$BASHPID.json"; mal48=''; med48=''
  pk48=('ls -la' 'npm run build' "cp S $P48/docs/notas.md"); [ "$HL48" != si ] || pk48+=("cp S $P48/docs/h3-b")
  for k48 in "${pk48[@]}"; do
    printf '%s' "$(j48 "$P48" - "$k48")" > "$f48"; pr48=''
    [ -s "$f48" ] || { mal48+=" $k48: la entrada salió vacía, no midió"; continue; }
    for h48 in "$HOOKS_DIR" "$RV48/hooks"; do
      r48="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "48-procesos" \
        --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git readlink realpath cygpath find stat' \
        --sujeto "CLAUDE_PROJECT_DIR='$P48' bash '$h48/guard.sh' < '$f48'" 2>/dev/null)"
      if sonda_lee "$r48" && [ "${SONDA[estado]}" = ok ]; then pr48+="${SONDA[cuenta]:-x} "; else pr48+="x "; mal48+=" $k48: la sonda no midió (${SONDA_MOTIVO:-${SONDA[motivo]:-?}})"; fi
    done
    read -r pc48 pb48 <<< "$pr48"; k48="${k48/"$P48"/<raíz>}"; med48+=" «$k48» $pc48/$pb48"
    x48=0; case "$k48" in cp*) x48=1 ;; esac   # la rama del destino existente: el `find` declarado (P-032-4 (B))
    case "$pc48$pb48" in *x*) ;; *) [ "$pc48" -le $(( pb48 + x48 )) ] || mal48+=" «$k48»: $pc48 > $pb48 + $x48" ;; esac
  done
  rm -f "$f48"
  case "$mal48" in *'no midió'*) v48 SKIP "$nom48 $mal48" ;; '') v48 PASS "$nom48 (candidata/v1.36.0:$med48)" ;; *) v48 FAIL "$nom48 $mal48 (candidata/v1.36.0:$med48)" ;; esac
fi
chmod 755 "$P48/docs/cerrado" 2>/dev/null; rm -rf "$RV48" "$DP48" "$PM48"
