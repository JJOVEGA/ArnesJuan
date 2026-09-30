# Sección 43 del banco — 43-identidad-del-destino
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-007 CA-66 (ADR-016): las filas I1-I13, L1-L8, K1-K3, D1-D4, R1-R7, S1-S3 y M1 de la
# identidad del destino (CA-47, SEC-119) y del archivo que la puerta no puede leer (CA-45, O-11),
# más V1-V4, fuera de la tabla mínima (CA-47 punto 4, CA-49 (iv) y el no determinable por `Bash`),
# A NIVEL DE HOOK: el mismo JSON PreToolUse que recibe el hook, contra el guardián de cada fila
# y, en las que permiten, contra `guard.sh`. Esto NO es la validación en el host (CA-66, punto
# 6), que es de la coordinadora; la columna «Host» de CA-66 dice qué filas llegan desde el host.
# DOS ÁRBOLES: la CANDIDATA es `$HOOKS_DIR`; la BASE, 9596e39 materializado POR SHA (`mat43`,
# copia de `mat42`). Fila con `allow` en la base: FAIL-BEFORE, tiene que permitir de verdad allí;
# con `deny` en la base y `allow` aquí: uno de los TRES movimientos declarados (L8, R6 (c), M1 (a),
# CA-66 punto 5); con `igual`: control, decide igual en los dos. Sin la base, SKIP con su motivo.
# A mano, `ARNES_HOOKS_DIR=<hooks de 9596e39 o de 1.33.2> run.sh secciones/43-*.sh` deja en FAIL
# las filas que la candidata deniega.
CASOS_ESPERADOS_SECCION=147
PISO_AUTONOMO_SECCION=76  # 19 preámbulo (líneas 1-19, con seccion_nueva y la blanca que la sigue) + 24 maquinaria compartida duplicada (mat43_reg y mat43, copia de mat42, líneas 20-43) + 33 bloque indivisible mayor (las filas I, líneas 103-135) · REQ-014 CA-18
seccion_nueva "--- 43 · identidad del destino y archivo ilegible (REQ-007 CA-45/CA-47/CA-49/CA-60, SEC-119, O-11) ---"

REPO43="${SEC_DIR%/}/../../../.."; MAT43_RUTAS='hooks'; MAT43_REG=''; MAT43_T0=0; MAT43_REF='-'
mat43_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT43_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT43_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT43_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT43_T0 )) procesos=$4 etiqueta=$MAT43_REF ref=$MAT43_REF archivos=$3"
}
# mat43 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat43() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT43_T0=${EPOCHREALTIME/./}; MAT43_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO43" ls-tree -r "$ref" -- $MAT43_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat43_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO43" archive "$ref" $MAT43_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat43_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO43" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat43_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat43_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat43_reg ok - "$n" 6
}
BASE43="$RAIZ/base43-$BASHPID"; BASE43_OK=no; BASE43_MOT=''
if mat43 9596e39 "$BASE43"; then BASE43_OK=si
else BASE43_MOT="9596e39 no se materializó (${MAT43_REG#*motivo=})"; BASE43_MOT="${BASE43_MOT%% corrida=*})"; fi
# v43 <PASS|FAIL|SKIP> <texto>: la línea del caso y su cuenta. Juzgar un hook exige su guarda de vacío
# ANTES (invariante 1): `g43` no ejecuta sin JSON, y `fila43` pasa por `json_no_vacio`.
v43() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }

# --- LA PUERTA REAL -------------------------------------------------------------------------
# g43 <dir de hooks> <guardián> <json> -> D43 (deny|allow) y M43 (el motivo). El proyecto es $P43.
D43=''; M43=''; P43="$PROJ"
g43() {
  local h="$1" s="$2" json="$3" out; D43=''; M43=''; [ -n "$json" ] || return 1
  out="$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$P43" bash "$h/$s" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D43=deny ;; *) D43=allow ;; esac
  M43="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
declare -A MC43=()
# fila43 <id> <guardián> <esperado en la candidata> <9596e39: allow|deny|igual> <patrón del motivo|-> <json>
# Los dos hooks juzgan el MISMO disco, que ninguno escribe.
fila43() {
  local id="$1" s="$2" esp="$3" base="$4" pat="$5" json="$6" nom="REQ-007 CA-66 $1 candidata" nb d
  case "$base" in
    allow) nb="REQ-007 CA-66 $1 9596e39: fail-before, permite" ;;
    deny)  nb="REQ-007 CA-66 $1 9596e39: movimiento declarado de deny a allow, deniega" ;;
    *)     nb="REQ-007 CA-66 $1 9596e39: control, decide igual" ;;
  esac
  if ! json_no_vacio "$nom" "$json"; then FAIL=$((FAIL + 1)); return 0; fi
  g43 "$HOOKS_DIR" "$s" "$json"; d="$D43"; MC43[$id]="$M43"
  if [ "$d" != "$esp" ]; then v43 FAIL "$nom  esperado=$esp got=$d  <${M43:0:220}>"
  elif [ "$pat" != - ] && ! grep -Eq -- "$pat" <<< "$M43"; then v43 FAIL "$nom  el motivo no casa /$pat/  <${M43:0:240}>"
  else v43 PASS "$nom  ($d)"; fi
  if [ "$BASE43_OK" != si ]; then v43 SKIP "$nb  $BASE43_MOT"; return 0; fi
  g43 "$BASE43/hooks" "$s" "$json"
  if [ "$base" = allow ] && [ "$D43" != allow ]; then v43 FAIL "$nb  9596e39=$D43: el fail-before no está demostrado  <${M43:0:160}>"
  elif [ "$base" = deny ] && [ "$D43" != deny ]; then v43 FAIL "$nb  9596e39=$D43: el movimiento declarado no se reproduce"
  elif [ "$base" = igual ] && [ "$D43" != "$d" ]; then v43 FAIL "$nb  9596e39=$D43 candidata=$d"
  else v43 PASS "$nb  (9596e39 $D43)"; fi
}
# Emisor propio porque las filas necesitan un `cwd` distinto de la raíz, o ninguno (CA-47, punto 1),
# y los emisores compartidos fijan `cwd` en la raíz. j43 <herramienta> <cwd|-> <agente|-> <k=v…>
j43() {
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
QA43="veredicto de QA es 'pendiente'"; SRC43='código de la app'; ND43='no se pudo determinar a que archivo escribe'
LEE43='no se puede leer entero como archivo de texto'; BSH43="menciona 'completado'"; P="$PROJ"; R="$PROJ/requirements"
cierre43() { j43 Edit "$P" - "file_path=$1" 'old_string=Estado: en-revisión' 'new_string=Estado: completado'; }
src43()    { j43 Write "${2:-$P}" - "file_path=$1" 'content=hola'; }
sed43()    { j43 Bash "${2:-$P}" - "command=sed -i 's/en-revisión/completado/' $1"; }
req43()    { printf '# %s\nEstado: %s\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n\n## Historia\nProyecto temporal del banco.\n' "${1##*/}" "${2:-en-revisión}" > "$1"; }
req43 "$R/REQ-900.md"; printf 'x\n' > "$P/src/a.ts"; printf '# AGENTS\n' > "$P/AGENTS.md"
FUERA43="$RAIZ/fuera43-$BASHPID"; mkdir -p "$FUERA43/x" "$FUERA43/y" "$FUERA43/reqs"; printf 'x\n' > "$FUERA43/real.md"
ln -s ../requirements "$P/docs/enlace"; ln -s ../src "$P/docs/enlace-src"; ln -s "$FUERA43/y" "$P/docs/ext"
ln -s "$P/requirements" "$FUERA43/e"; ln -s "$P/src" "$FUERA43/es"; ln -s real.md "$FUERA43/enl.md"
ln -s "$R/REQ-900.md" "$FUERA43/l.md"; ln -s "$P/src/a.ts" "$FUERA43/l.ts"
ln -s ../src/a.ts "$P/docs/l-src.md"; ln -s ../requirements/REQ-900.md "$P/docs/l-req.md"; ln -s ../AGENTS.md "$P/docs/claude.md"

# --- I: rutas equivalentes hacia el MISMO archivo protegido ---------------------------------
fila43 "I1 req" guard-completado.sh deny igual "$QA43" "$(cierre43 "$R/REQ-900.md")"
fila43 "I1 src" guard-codigo.sh     deny igual "$SRC43" "$(src43 "$P/src/a.ts")"
fila43 "I2 req" guard-completado.sh deny igual "$BSH43" "$(sed43 requirements/REQ-900.md)"
fila43 "I2 src" guard-codigo.sh     deny igual "$SRC43" "$(j43 Bash "$P" - 'command=printf x > src/a.ts')"
fila43 "I3 req" guard-completado.sh deny allow "$QA43" "$(cierre43 "$P/docs/../requirements/REQ-900.md")"
fila43 "I3 src" guard-codigo.sh     deny allow "$SRC43" "$(src43 "$P/docs/../src/a.ts")"
fila43 "I4 req" guard-completado.sh deny allow "$QA43" "$(cierre43 "$P/././requirements/REQ-900.md")"
fila43 "I4 src" guard-codigo.sh     deny allow "$SRC43" "$(src43 "$P/././src/a.ts")"
fila43 "I5 req" guard-completado.sh deny igual "$QA43" "$(cierre43 "$P//requirements//REQ-900.md")"
fila43 "I5 src" guard-codigo.sh     deny igual "$SRC43" "$(src43 "$P//src//a.ts")"
fila43 "I6 req" guard-completado.sh deny allow "$BSH43" "$(sed43 docs/../requirements/REQ-900.md)"
fila43 "I6 src" guard-codigo.sh     deny allow "$SRC43" "$(j43 Bash "$P" - 'command=printf x > docs/../src/a.ts')"
fila43 "I7 req" guard-completado.sh deny allow "$BSH43" "$(sed43 ../requirements/REQ-900.md "$P/docs")"
fila43 "I7 src" guard-codigo.sh     deny allow "$SRC43" "$(j43 Bash "$P/src" - 'command=printf x > a.ts')"
# I8 (b) necesita una raíz bajo /tmp: la del banco lo está si mktemp usa /tmp; si no, se hace una.
case "$P/" in /tmp/*) P8="$P"; B8='' ;; *) P8="$(mktemp -d /tmp/arnes43-XXXXXX)"; B8="$P8"
  mkdir -p "$P8/.arnes" "$P8/requirements"; cp "$P/.arnes/config.json" "$P8/.arnes/"; cp "$P/PENDING_APPROVAL.md" "$P8/"; req43 "$P8/requirements/REQ-900.md" ;; esac
fila43 "I8 /tmp/.. delante" guard-completado.sh deny allow "$BSH43" "$(sed43 "/tmp/..$R/REQ-900.md")"
P43="$P8"; fila43 "I8 raíz bajo /tmp" guard-completado.sh deny allow "$BSH43" "$(sed43 "$P8/requirements/REQ-900.md")"; P43="$P"
fila43 "I9 req" guard-completado.sh deny allow "$QA43" "$(cierre43 "$P/docs/enlace/REQ-900.md")"
fila43 "I9 src" guard-codigo.sh     deny allow "$SRC43" "$(src43 "$P/docs/enlace-src/a.ts")"
fila43 "I10 req" guard-completado.sh deny allow "$QA43" "$(cierre43 "$FUERA43/e/REQ-900.md")"
fila43 "I10 src" guard-codigo.sh     deny allow "$SRC43" "$(src43 "$FUERA43/es/a.ts")"
P11="$RAIZ/p11-$BASHPID"; mkdir -p "$P11/.arnes" "$P11/src"; cp "$P/.arnes/config.json" "$P11/.arnes/"
cp "$P/PENDING_APPROVAL.md" "$P11/"; ln -s "$FUERA43/reqs" "$P11/requirements"; req43 "$FUERA43/reqs/REQ-900.md"
P43="$P11"; fila43 "I11 (a) requirements es un enlace de fuera" guard-completado.sh deny igual "$QA43" "$(cierre43 "$P11/requirements/REQ-900.md")"
fila43 "I11 (b) su destino, directo" guard-completado.sh deny allow "$QA43" "$(cierre43 "$FUERA43/reqs/REQ-900.md")"; P43="$P"
fila43 "I12 req" guard-completado.sh deny allow "$QA43" "$(cierre43 "$FUERA43/l.md")"
fila43 "I12 src" guard-codigo.sh     deny allow "$SRC43" "$(src43 "$FUERA43/l.ts")"
fila43 "I13 src" guard-codigo.sh     deny allow "$SRC43" "$(j43 Bash "$P" - 'command=echo x > docs/l-src.md')"
fila43 "I13 req" guard-completado.sh deny allow "$BSH43" "$(sed43 docs/l-req.md)"

# --- L: lo legítimo fuera del ámbito se preserva (por `guard.sh`, las dos puertas) ---------
fila43 "L1 docs/notas.md"         guard.sh allow igual - "$(src43 "$P/docs/notas.md")"
fila43 "L1 docs/../docs/notas.md" guard.sh allow igual - "$(src43 "$P/docs/../docs/notas.md")"
fila43 "L1 fuera de la raíz"      guard.sh allow igual - "$(src43 "$FUERA43/x/notas.md")"
fila43 "L2" guard.sh allow igual - "$(src43 "$P/docs/ext/f.md")"
fila43 "L3" guard.sh allow igual - "$(src43 "$FUERA43/enl.md")"
fila43 "L4 por I3" guard.sh allow igual - "$(j43 Write "$P" desarrollador "file_path=$P/docs/../src/a.ts" content=hola)"
fila43 "L4 por I9" guard.sh allow igual - "$(j43 Write "$P" desarrollador "file_path=$P/docs/enlace-src/a.ts" content=hola)"
fila43 "L5 cp a src/" guard-codigo.sh deny igual "$SRC43" "$(j43 Bash "$P" - 'command=cp /tmp/x.ts src/')"
fila43 "L5 mv a src"  guard-codigo.sh deny igual "$SRC43" "$(j43 Bash "$P" - 'command=mv /tmp/x.ts src')"
fila43 "L6" guard.sh allow igual - "$(j43 Bash "$P" - 'command=ls -la')"
fila43 "L7" guard.sh allow igual - "$(j43 Bash "$P" - 'command=echo x > docs/claude.md')"
fila43 "L8" guard.sh allow deny - "$(j43 Bash "$P/docs" - 'command=echo x > src/a.ts')"

# --- K: creación legítima; «todavía no existe» no es «no se pudo determinar» ----------------
nuevo43=$'# REQ-930\nEstado: borrador\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n'
fila43 "K1 requirements/"       guard.sh allow igual - "$(j43 Write "$P" - "file_path=$R/REQ-930.md" "content=$nuevo43")"
fila43 "K1 subdirectorio nuevo" guard.sh allow igual - "$(j43 Write "$P" - "file_path=$R/nuevo43/REQ-931.md" "content=$nuevo43")"
fila43 "K2 requirements/"       guard-completado.sh deny igual "$QA43" "$(j43 Write "$P" - "file_path=$R/REQ-930.md" "content=${nuevo43/borrador/completado}")"
fila43 "K2 subdirectorio nuevo" guard-completado.sh deny igual "$QA43" "$(j43 Write "$P" - "file_path=$R/nuevo43/REQ-931.md" "content=${nuevo43/borrador/completado}")"
fila43 "K3" guard.sh allow igual - "$(j43 Edit "$P" - "file_path=$P/docs/enlace/REQ-932.md" old_string= "new_string=$nuevo43")"

# --- D: el destino que no se puede determinar no recibe permiso silencioso ------------------
mkdir -p "$P/cerrado43"; chmod 000 "$P/cerrado43"; ln -s bucle43 "$P/bucle43"
fila43 "D1 req" guard-completado.sh deny allow "$ND43.*sobre un directorio que todavia no existe" "$(cierre43 "$P/nuevo43/../requirements/REQ-900.md")"
fila43 "D1 src" guard-codigo.sh     deny allow "$ND43.*sobre un directorio que todavia no existe" "$(src43 "$P/nuevo43/../src/a.ts")"
if [ "${EUID:-1}" -eq 0 ]; then
  v43 SKIP "REQ-007 CA-66 D2 req  como administrador los permisos no se aplican (CA-66, punto 3)"; v43 SKIP "REQ-007 CA-66 D2 req 9596e39  ídem"
  v43 SKIP "REQ-007 CA-66 D2 src  como administrador los permisos no se aplican (CA-66, punto 3)"; v43 SKIP "REQ-007 CA-66 D2 src 9596e39  ídem"
else
  fila43 "D2 req" guard-completado.sh deny allow "$ND43.*no se puede recorrer" "$(cierre43 "$P/cerrado43/../requirements/REQ-900.md")"
  fila43 "D2 src" guard-codigo.sh     deny allow "$ND43.*no se puede recorrer" "$(src43 "$P/cerrado43/../src/a.ts")"
fi
chmod 755 "$P/cerrado43"
fila43 "D3 req" guard-completado.sh deny allow "$ND43.*no se puede recorrer" "$(cierre43 "$P/bucle43/../requirements/REQ-900.md")"
fila43 "D3 src" guard-codigo.sh     deny allow "$ND43.*no se puede recorrer" "$(src43 "$P/bucle43/../src/a.ts")"
fila43 "D4 guard-codigo"     guard-codigo.sh     deny allow "$ND43.*directorio de trabajo" "$(src43 docs/notas.md -)"
fila43 "D4 guard-completado" guard-completado.sh deny allow "$ND43.*directorio de trabajo" "$(src43 docs/notas.md -)"
# Fuera de la tabla mínima (no exhaustiva), por propiedad: las dos lecturas que designan archivos
# distintos (CA-47, punto 4), el enlace dentro de la raíz escrito con `..` (CA-49 (iv)) y la regla de
# `Bash` ante un destino no determinable en guard-completado: deniega sólo si menciona el terminal.
fila43 "V1 divergencia" guard-completado.sh deny allow "$ND43.*designan archivos distintos" "$(cierre43 "$P/docs/enlace/../requirements/REQ-900.md")"
fila43 "V2 CA-49 (iv)"  guard-completado.sh deny allow 'ENLACE SIMBOLICO situado dentro del proyecto' "$(cierre43 "$P/docs/../docs/l-req.md")"
fila43 "V3 Bash no determinable, sin mención" guard-completado.sh allow igual - "$(j43 Bash "$P" - 'command=echo x > nuevo43/../requirements/REQ-900.md')"
fila43 "V4 Bash no determinable, con mención" guard-completado.sh deny allow "$ND43" "$(sed43 nuevo43/../requirements/REQ-900.md)"

# --- R: el REQ que la puerta no puede leer entero (CA-45 (ii)) ------------------------------
{ printf '# REQ-910 '; printf '\000'; printf ' nota\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n'; } > "$R/REQ-910.md"
{ printf '# REQ-911 '; printf '\000'; printf ' nota\nEstado: ado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n'; } > "$R/REQ-911.md"
# REQ-912 en UTF-16LE con BOM, como lo dejó el host en la medición de bf47f37: cada carácter ASCII
# seguido de un byte 0x00. El formato se arma como texto (`\000`, `\n`) y lo escribe `printf`.
t43=$'# REQ-912\nEstado: en-revision\nQA: pendiente\nnota\n'; f43='\xff\xfe'
for ((i43 = 0; i43 < ${#t43}; i43++)); do c43="${t43:i43:1}"; [ "$c43" != $'\n' ] || c43='\n'; f43+="$c43\\000"; done
printf "$f43" > "$R/REQ-912.md"
req43 "$R/REQ-913.md"; chmod 000 "$R/REQ-913.md"; mkdir -p "$R/REQ-914.md"
fila43 R1 guard-completado.sh deny allow "$LEE43.*byte NUL" "$(j43 Edit "$P" - "file_path=$R/REQ-910.md" old_string=nota 'new_string=otra anotacion')"
fila43 R2 guard-completado.sh deny igual "$LEE43" "$(j43 Edit "$P" - "file_path=$R/REQ-910.md" old_string=nota 'new_string=nota: completado en la historia')"
fila43 R3 guard-completado.sh deny allow "$LEE43" "$(j43 Edit "$P" - "file_path=$R/REQ-911.md" 'old_string=Estado: ' 'new_string=Estado: complet')"
fila43 R4 guard-completado.sh deny allow "$LEE43.*UTF-16" "$(j43 Edit "$P" - "file_path=$R/REQ-912.md" old_string=nota new_string=otra)"
if [ "${EUID:-1}" -eq 0 ]; then
  v43 SKIP "REQ-007 CA-66 R5  como administrador los permisos no se aplican (CA-66, punto 3)"; v43 SKIP "REQ-007 CA-66 R5 9596e39  ídem"
else
  fila43 R5 guard-completado.sh deny allow "$LEE43.*permiso de lectura" "$(j43 Edit "$P" - "file_path=$R/REQ-913.md" old_string=nota new_string=otra)"
fi
chmod 644 "$R/REQ-913.md"
w43() { j43 Write "$P" - "file_path=$R/REQ-910.md" "content=# REQ-910
Estado: $1
Sensible a seguridad: sí
QA: $2
Seguridad: $2
Rigor: critico
"; }
fila43 "R6 (a) sin el estado terminal" guard.sh allow igual - "$(w43 en-revisión pendiente)"
fila43 "R6 (b) terminal y QA pendiente" guard-completado.sh deny igual "$QA43" "$(w43 completado pendiente)"
fila43 "R6 (c) terminal y todo en verde" guard.sh allow deny - "$(w43 completado aprobado)"
fila43 R7 guard-completado.sh deny igual "$LEE43.*no es un archivo regular" "$(j43 Edit "$P" - "file_path=$R/REQ-914.md" old_string=x new_string=y)"

# --- S: SEC-117 se conserva por la identidad del destino (REQ-023 CA-13) --------------------
printf '# REQ-920\nEstado: en-revisión (tras “R-4”)\nPrioridad: alta\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$R/REQ-920.md"
req43 "$R/REQ-921.md" completado
fila43 S1 guard.sh allow igual - "$(j43 Edit "$P" - "file_path=$R/REQ-920.md" 'old_string=Prioridad: alta' 'new_string=Prioridad: media')"
fila43 "S2 (a) canónica" guard-completado.sh deny igual 'no puede reconstruir' "$(j43 Edit "$P" - "file_path=$R/REQ-920.md" 'old_string=en-revisión (tras "R-4")' new_string=completado)"
fila43 "S2 (b) por I3"   guard-completado.sh deny allow 'no puede reconstruir' "$(j43 Edit "$P" - "file_path=$P/docs/../requirements/REQ-920.md" 'old_string=en-revisión (tras "R-4")' new_string=completado)"
fila43 "S3 canónica" guard.sh allow igual - "$(j43 Edit "$P" - "file_path=$R/REQ-921.md" 'old_string=Estado: completado' 'new_string=Estado: en-progreso')"
fila43 "S3 por I9"   guard.sh allow igual - "$(j43 Edit "$P" - "file_path=$P/docs/enlace/REQ-921.md" 'old_string=Estado: completado' 'new_string=Estado: en-progreso')"

# --- M1: la reparación del manifiesto roto, por identidad (CA-60) ---------------------------
PM="$RAIZ/pm43-$BASHPID"; mkdir -p "$PM/.arnes" "$PM/docs" "$PM/src" "$PM/requirements"; printf '{ "codigo_app": ' > "$PM/.arnes/config.json"
cp "$P/PENDING_APPROVAL.md" "$PM/"; P43="$PM"
fila43 "M1 (a) ruta equivalente al manifiesto, sola" guard.sh allow deny - "$(j43 Bash "$PM" - "command=printf '{}' > docs/../.arnes/config.json")"
fila43 "M1 (b) acompañada de otra ruta" guard-codigo.sh deny igual 'NO se puede leer' "$(j43 Bash "$PM" - "command=printf '{}' > docs/../.arnes/config.json; echo x > docs/x.md")"
fila43 "M1 (c) destino no determinable" guard-codigo.sh deny igual 'NO se puede leer' "$(j43 Bash "$PM" - "command=printf '{}' > nuevo43/../.arnes/config.json")"
P43="$P"

# --- Los motivos: la causa, y ninguna otra herramienta como salida (CA-45, CA-47 punto 7) ---
nom43="REQ-007 CA-66 los motivos de D y R dicen su causa y no nombran otra herramienta como salida"; mal43=''
for id43 in "D1 req" "D1 src" "D3 req" "D4 guard-codigo" R1 R3 R4 R7; do
  m43="${MC43[$id43]:-}"; [ -n "$m43" ] || { mal43+=" $id43: sin motivo"; continue; }
  grep -Eqi '(^|[^a-z])(bash|write|edit|multiedit|shell|consola|terminal|python)([^a-z]|$)' <<< "$m43" && mal43+=" $id43: <${m43:0:120}>"
  grep -Eq 'Para corregirlo, ' <<< "$m43" || mal43+=" $id43: no dice como corregirlo"
done
if [ -n "$mal43" ]; then v43 FAIL "$nom43 $mal43"; else v43 PASS "$nom43"; fi
# El tope del motivo (SEC-118 no se hereda): una ruta de más de 4096 caracteres es no determinable,
# y el motivo cita como mucho 200 bytes de ella.
L43="$P/"; for ((i43 = 0; i43 < 830; i43++)); do L43+='abcd/'; done; L43+='a.ts'
j43x="$(src43 "$L43")"; nom43="REQ-007 CA-66 una ruta de ${#L43} caracteres: no determinable, y el motivo cita 200 bytes y cabe con holgura"
if ! json_no_vacio "$nom43" "$j43x"; then FAIL=$((FAIL + 1))
else
  g43 "$HOOKS_DIR" guard-codigo.sh "$j43x"
  if [ "$D43" = deny ] && [[ "$M43" == *"se muestran los primeros 200"* ]] && [ "${#M43}" -lt 1500 ]; then v43 PASS "$nom43  (${#M43} bytes)"
  else v43 FAIL "$nom43  decisión=$D43 motivo=${#M43} bytes  <${M43:0:200}>"; fi
fi

# --- CA-48 (i.1): 0 procesos añadidos respecto a 9596e39, salvo 1 por enlace resuelto -------
nom43="REQ-007 CA-48 (i.1) procesos frente a 9596e39: I1 y /dev/stderr y ls -la no añaden ninguno; L3 (enlace resuelto) como mucho 1"
if [ "$BASE43_OK" != si ]; then v43 SKIP "$nom43  $BASE43_MOT"
else
  f43="$RAIZ/j43-$BASHPID.json"; mal43=''; med43=''
  for c43 in "guard-completado.sh|0|$(cierre43 "$R/REQ-900.md")" "guard-codigo.sh|0|$(src43 "$P/src/a.ts")" \
             "guard.sh|0|$(j43 Bash "$P" - 'command=echo x > /dev/stderr')" "guard.sh|0|$(j43 Bash "$P" - 'command=ls -la')" \
             "guard.sh|1|$(src43 "$FUERA43/enl.md")"; do
    s43="${c43%%|*}"; t43="${c43#*|}"; x43="${t43%%|*}"; printf '%s' "${t43#*|}" > "$f43"; pr43=''
    for a43 in "$HOOKS_DIR" "$BASE43/hooks"; do
      r43="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "43-$s43" \
        --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git readlink realpath cygpath' \
        --sujeto "CLAUDE_PROJECT_DIR='$P' bash '$a43/$s43' < '$f43'" 2>/dev/null)"
      if sonda_lee "$r43" && [ "${SONDA[estado]}" = ok ]; then pr43+="${SONDA[cuenta]:-x} "; else pr43+="x "; mal43+=" $s43: la sonda no midió (${SONDA_MOTIVO:-${SONDA[motivo]:-?}})"; fi
    done
    read -r pc43 pb43 <<< "$pr43"; med43+=" $s43 $pc43/$pb43 (+$x43)"
    case "$pc43$pb43" in *x*) ;; *) [ "$pc43" -le $(( pb43 + x43 )) ] || mal43+=" $s43: $pc43 > $pb43 + $x43" ;; esac
  done
  rm -f "$f43"
  case "$mal43" in *'no midió'*) v43 SKIP "$nom43 $mal43" ;; '') v43 PASS "$nom43 ($med43)" ;; *) v43 FAIL "$nom43 $mal43 ($med43)" ;; esac
fi
rm -rf "$FUERA43" "$P11" "$PM"; [ -z "$B8" ] || rm -rf "$B8"
