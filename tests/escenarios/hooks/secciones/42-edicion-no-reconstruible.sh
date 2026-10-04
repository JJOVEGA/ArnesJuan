# Sección 42 del banco — 42-edicion-no-reconstruible
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-023 CA-13 (SEC-117, ADR-015): un `Edit`/`MultiEdit` de `requirements/` que la puerta no puede
# reconstruir se DENIEGA, sea cual sea su `new_string`. Hasta df550fa se juzgaba su FRAGMENTO y se
# permitía si no escribía `estado: <terminal>`: en el host real (CLI 2.1.285) un `old_string` con
# comillas rectas donde el archivo las tiene tipográficas CERRÓ un REQ `critico` con QA y seguridad
# pendientes y un `contrato` abierto (`1c8c81c:sec117-real/`). El REQ-900 de las filas es el suyo.
# DOS ÁRBOLES (CA-13 (v)): la CANDIDATA es `$HOOKS_DIR`; la BASE, df550fa materializado POR SHA
# (`mat42`, copia de `mat41`). Toda fila que la candidata deniega PERMITE en df550fa —si no, el
# fail-before no está demostrado y el caso FALLA—, y las de control deciden IGUAL en los dos. Sin
# la base, lo que la necesita dice SKIP con su motivo, nunca PASS. A mano,
# `ARNES_HOOKS_DIR=<hooks de df550fa o de 1.33.2> run.sh secciones/42-*.sh` deja en FAIL las filas
# que la candidata deniega.
CASOS_ESPERADOS_SECCION=29
PISO_AUTONOMO_SECCION=77  # 18 preámbulo (líneas 1-18, con seccion_nueva y la blanca que la sigue) + 24 maquinaria compartida duplicada (mat42_reg y mat42, copia de mat41, líneas 19-42) + 35 bloque indivisible mayor (la tabla de filas C1-C13, líneas 78-112) · REQ-014 CA-18
seccion_nueva "--- 42 · edición que la puerta no puede reconstruir (REQ-023 CA-13, SEC-117) ---"

REPO42="${SEC_DIR%/}/../../../.."; MAT42_RUTAS='hooks'; MAT42_REG=''; MAT42_T0=0; MAT42_REF='-'
mat42_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT42_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT42_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT42_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT42_T0 )) procesos=$4 etiqueta=$MAT42_REF ref=$MAT42_REF archivos=$3"
}
# mat42 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat42() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT42_T0=${EPOCHREALTIME/./}; MAT42_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO42" ls-tree -r "$ref" -- $MAT42_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat42_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO42" archive "$ref" $MAT42_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat42_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO42" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat42_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat42_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat42_reg ok - "$n" 6
}
BASE42="$RAIZ/base42-$BASHPID"; BASE42_OK=no; BASE42_MOT=''
if mat42 df550fa "$BASE42"; then BASE42_OK=si
else BASE42_MOT="df550fa no se materializó (${MAT42_REG#*motivo=})"; BASE42_MOT="${BASE42_MOT%% corrida=*})"; fi
# v42 <PASS|FAIL|SKIP> <texto>: la línea del caso y su cuenta. Juzgar un hook exige su guarda de vacío
# ANTES (invariante 1): `g42` no ejecuta sin JSON, y `fila42` pasa por `json_no_vacio`.
v42() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }

# --- LA PUERTA REAL: el mismo JSON PreToolUse que recibe el hook -------------------------
# g42 <dir de hooks> <json> -> D42 (deny|allow) y M42 (el motivo, decodificado por jq)
D42=''; M42=''
g42() {
  local h="$1" json="$2" out; D42=''; M42=''; [ -n "$json" ] || return 1
  out="$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$PROJ" bash "$h/guard-completado.sh" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D42=deny ;; *) D42=allow ;; esac
  M42="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
declare -A MC42=() JS42=()
# fila42 <id> <esperado en la candidata> <df550fa: allow|igual> <patrón del motivo|-> <json>
# Dos casos: la decisión de la candidata (y su motivo), y la de df550fa —fail-before si la fila
# deniega, control si permite—. Los dos hooks juzgan el MISMO disco, que ninguno escribe.
fila42() {
  local id="$1" esp="$2" base="$3" pat="$4" json="$5" nom="REQ-023 CA-13 $1 candidata" nb d
  nb="REQ-023 CA-13 $1 df550fa: control, decide igual"; [ "$base" != allow ] || nb="REQ-023 CA-13 $1 df550fa: fail-before, permite"
  if ! json_no_vacio "$nom" "$json"; then FAIL=$((FAIL + 1)); return 0; fi
  JS42[$id]="$json"; g42 "$HOOKS_DIR" "$json"; d="$D42"; MC42[$id]="$M42"
  if [ "$d" != "$esp" ]; then v42 FAIL "$nom  esperado=$esp got=$d  <${M42:0:200}>"
  elif [ "$pat" != - ] && ! grep -Eq -- "$pat" <<< "$M42"; then v42 FAIL "$nom  el motivo no casa /$pat/  <${M42:0:240}>"
  else v42 PASS "$nom  ($d)"; fi
  if [ "$BASE42_OK" != si ]; then v42 SKIP "$nb  $BASE42_MOT"; return 0; fi
  g42 "$BASE42/hooks" "$json"
  if [ "$base" = allow ] && [ "$D42" != allow ]; then v42 FAIL "$nb  df550fa=$D42: el fail-before no está demostrado  <${M42:0:160}>"
  elif [ "$base" = igual ] && [ "$D42" != "$d" ]; then v42 FAIL "$nb  df550fa=$D42 candidata=$d"
  else v42 PASS "$nb  (df550fa $D42)"; fi
}

# --- CA-13 (v): LA TABLA DE CASOS MÍNIMOS, más tres caminos que comparten la reconstrucción -------
R42="$PROJ/requirements"; P42='no puede reconstruir el documento que quedaria escrito'
EP='Estado: en-revisión (tras “R-4”)'; RECT='en-revisión (tras "R-4")'   # RECTAS: no están en el archivo
cab42() { printf '# REQ-%s — prueba SEC-117\n%s\nPrioridad: alta\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: SEC-1 (contrato)\nRigor: critico\n\n## Historia\nProyecto temporal del banco; sin datos reales.\n' "$1" "$2" > "$R42/REQ-$1.md"; }
cab42 900 "$EP"
fila42 C1 deny allow "la unica edicion de este Edit.*$P42" "$(emite_edit_real "$R42/REQ-900.md" "$RECT" 'completado')"
fila42 C2 deny allow "edicion 1 de 2 de este MultiEdit.*$P42" \
  "$(emite_multiedit "$R42/REQ-900.md" "$RECT" 'completado' 'Prioridad: alta' 'Prioridad: media')"
# C3: el escape de seis caracteres (barra, u y cuatro hex) que el `Edit` del host desescapa; la barra
# se escribe con $'\x5c' para que ningún editor lo convierta en el carácter antes de guardarlo.
B42=$'\x5c'; U42="en-revisi${B42}u00f3n (tras ${B42}u201cR-4${B42}u201d)"
fila42 C3 deny allow "$P42" "$(emite_edit_real "$R42/REQ-900.md" "$U42" 'completado')"
fila42 C4 deny allow "$P42, porque su old_string esta vacio y el archivo ya existe" "$(emite_edit_real "$R42/REQ-900.md" '' 'completado')"
rm -f "$R42/REQ-905.md"   # C5 y C6: CREACIÓN (el archivo no existe, una edición, `old_string` vacío)
fila42 C5 deny allow "veredicto de QA es 'pendiente'" \
  "$(emite_edit_real "$R42/REQ-905.md" '' $'# REQ-905\n**Estado:** completado\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n')"
rm -f "$R42/REQ-906.md"
fila42 C6 allow igual - \
  "$(emite_edit_real "$R42/REQ-906.md" '' $'# REQ-906\n**Estado:** borrador\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n')"
fila42 C7 allow igual - "$(emite_edit_real "$R42/REQ-900.md" 'Prioridad: alta' 'Prioridad: media')"
cab42 908 'Estado: completado (tras “R-4”)'
fila42 C8 allow igual - "$(emite_edit_real "$R42/REQ-908.md" 'Estado: completado' 'Estado: en-progreso')"
fila42 C9 deny allow "$P42" "$(emite_edit_real "$R42/REQ-908.md" 'completado (tras "R-4")' 'en-progreso')"
printf '# Requisitos\nCada REQ lleva su “cabecera” como la plantilla.\n' > "$R42/README.md"
fila42 C10 deny allow "$P42" "$(emite_edit_real "$R42/README.md" 'su "cabecera"' 'su cabecera')"
# C11-C13, no exhaustivos: `replace_all`, una creación de DOS ediciones (no es una creación) y el
# CRLF, la única normalización de la reconstrucción: si dejara de aplicarse, C13 se denegaría por
# no reconstruible sobre un archivo legítimo en vez de cerrar.
fila42 C11 deny allow "$P42" "$(emite_edit_real "$R42/REQ-900.md" "$RECT" 'completado' 1)"
rm -f "$R42/REQ-912.md"
fila42 C12 deny allow "edicion 1 de 2 de este MultiEdit.*el archivo no existe y esta llamada no es una creacion" \
  "$(emite_multiedit "$R42/REQ-912.md" '' $'# REQ-912\nEstado: borrador' 'borrador' 'en-progreso')"
printf '# REQ-913\r\nEstado: en-revisión\r\nSensible a seguridad: no\r\nQA: aprobado\r\nSeguridad: n/a\r\n' > "$R42/REQ-913.md"
fila42 C13 allow igual - \
  "$(emite_edit_real "$R42/REQ-913.md" $'Estado: en-revisión\nSensible a seguridad: no' $'Estado: completado\nSensible a seguridad: no')"

# --- CA-13 (ii): EL MOTIVO — qué edición, el old_string escapado, la salida, ninguna otra herramienta ---
m42="${MC42[C1]:-}"; nom42="REQ-023 CA-13 (ii) motivo de C1: old_string escapado, edición verificable, sin bytes crudos ni otra herramienta"
if [ -z "$m42" ]; then v42 FAIL "$nom42  (C1 no dejó motivo)"
elif [[ "$m42" != *"\$'en-revisi\\303\\263n (tras \"R-4\")'"* ]]; then v42 FAIL "$nom42  no enseña el old_string escapado  <${m42:0:240}>"
elif [[ "$m42" != *"lee el archivo y repite la edicion con un old_string copiado LITERALMENTE"* ]]; then v42 FAIL "$nom42  no explica la edición verificable"
elif LC_ALL=C grep -q '[^ -~]' <<< "$m42"; then v42 FAIL "$nom42  lleva bytes >= 0x80 o de control sin escapar"
elif grep -Eqi 'bash|write|shell|consola|terminal' <<< "$m42"; then v42 FAIL "$nom42  propone otra herramienta  <${m42:0:240}>"
else v42 PASS "$nom42"; fi
# El tope: un old_string de 4 000 bytes multibyte enseña 80 bytes escapados, y el motivo mide unos
# pocos cientos de bytes —lejos de los 128 KiB de un argumento de `jq`: no hereda SEC-118—.
L42=''; for ((i42 = 0; i42 < 2000; i42++)); do L42+='ñ'; done
cab42 900 "$EP"; j42="$(emite_edit_real "$R42/REQ-900.md" "$L42" 'completado')"
nom42="REQ-023 CA-13 (ii) tope: de un old_string de 4000 bytes enseña 80, escapados, y el motivo cabe con holgura"
if ! json_no_vacio "$nom42" "$j42"; then FAIL=$((FAIL + 1))
else
  # ${#M42} cuenta bytes porque el motivo es ASCII entero, y eso mismo lo exige la condición de abajo.
  g42 "$HOOKS_DIR" "$j42"; n42=${#M42}; c42=''; for ((i42 = 0; i42 < 40; i42++)); do c42+='\303\261'; done
  if [ "$D42" = deny ] && [[ "$M42" == *"\$'$c42'... (mide 4000 bytes; se muestran los primeros 80)"* ]] && [ "$n42" -lt 2000 ] \
     && ! LC_ALL=C grep -q '[^ -~]' <<< "$M42"; then v42 PASS "$nom42  ($n42 bytes)"
  else v42 FAIL "$nom42  decisión=$D42 motivo=$n42 bytes  <${M42:0:200}>"; fi
fi

# --- CA-13 (viii): EL COSTE — 0 procesos añadidos respecto a df550fa, con la sonda de procesos ----
nom42="REQ-023 CA-13 (viii) 0 procesos añadidos respecto a df550fa en C1 (no reconstruible) y C7 (reconstruible)"
if [ "$BASE42_OK" != si ]; then v42 SKIP "$nom42  $BASE42_MOT"
else
  f42="$RAIZ/j42-$BASHPID.json"; mal42=''; med42=''; cab42 900 "$EP"
  for c42 in C1 C7; do
    printf '%s' "${JS42[$c42]:-}" > "$f42"; [ -s "$f42" ] || { mal42+=" $c42: sin JSON"; continue; }
    for a42 in "$HOOKS_DIR" "$BASE42/hooks"; do
      r42="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "42-$c42" \
        --sujeto "CLAUDE_PROJECT_DIR='$PROJ' bash '$a42/guard-completado.sh' < '$f42'" 2>/dev/null)"
      if sonda_lee "$r42" && [ "${SONDA[estado]}" = ok ]; then med42+="${SONDA[cuenta]:-x} "; else med42+="x "; mal42+=" $c42: la sonda no midió (${SONDA_MOTIVO:-${SONDA[motivo]:-?}})"; fi
    done
  done
  rm -f "$f42"; read -r p1c p1b p7c p7b <<< "$med42"
  if [ -n "$mal42" ]; then v42 SKIP "$nom42 $mal42"
  elif [ "$p1c" -le "$p1b" ] && [ "$p7c" -le "$p7b" ]; then v42 PASS "$nom42  (C1 $p1c frente a $p1b; C7 $p7c frente a $p7b; menos es conforme)"
  else v42 FAIL "$nom42  C1 $p1c frente a $p1b; C7 $p7c frente a $p7b"; fi
fi
