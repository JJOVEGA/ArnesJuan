# Sección 50 del banco — 50-rigor-proporcional
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-034 (1.37 · 1): la política de rigor vive en el manifiesto del proyecto CONSUMIDOR y NINGUNA puerta la lee.
#   B1  CA-04: la plantilla trae `rigor_politica` válido con los cinco ámbitos ·
#   B2  CA-10: la orden literal de `arnes-upgrade` sobre los fixtures (a)–(e) ·
#   B3  CA-06: los cinco cierres deciden igual sin el bloque y con él (completo, vacío, tipos erróneos), sin aviso ·
#   PROC CA-06: 0 procesos añadidos en el camino común (de contrato).
# DOS ÁRBOLES por fila: la CANDIDATA (hooks de `$HOOKS_DIR`; plantillas y skills del árbol de `$TPL_DIR`) y v1.36.2
# (46ee7ca), por SHA con `mat50` (copia de `mat49`); sin ella, SKIP y motivo, nunca PASS. B1 y B2 son fail-before
# (en v1.36.2 no se cumplen); B3 y PROC son controles (la puerta no cambia: CA-06, `git diff v1.36.2 -- hooks/` vacío).
CASOS_ESPERADOS_SECCION=56
PISO_AUTONOMO_SECCION=79  # 14 preámbulo (líneas 1-14, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO50, mat50_reg y mat50, copia de mat49, líneas 15-38) + 41 bloque indivisible mayor (B3: REQ, variantes, g50, cierres y su bucle, líneas 170-210)
seccion_nueva "--- 50 · rigor proporcional: la política vive en el manifiesto y la puerta no la lee (REQ-034, 1.37 · 1) ---"
REPO50="${SEC_DIR%/}/../../../.."; MAT50_RUTAS='hooks templates skills'; MAT50_REG=''; MAT50_T0=0; MAT50_REF='-'
mat50_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT50_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT50_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT50_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT50_T0 )) procesos=$4 etiqueta=$MAT50_REF ref=$MAT50_REF archivos=$3"
}
# mat50 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat50() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT50_T0=${EPOCHREALTIME/./}; MAT50_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO50" ls-tree -r "$ref" -- $MAT50_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat50_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO50" archive "$ref" $MAT50_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat50_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO50" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat50_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat50_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat50_reg ok - "$n" 6
}
RV50="$RAIZ/rv1362-50-$BASHPID"; RV50_OK=no; RV50_MOT=''
if mat50 46ee7ca "$RV50"; then RV50_OK=si
else RV50_MOT="v1.36.2 (46ee7ca) no se materializó (${MAT50_REG#*motivo=})"; RV50_MOT="${RV50_MOT%% corrida=*})"; fi
v50() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
ARB50=''; MOT50=''; ORD50=''; RC50=0; OUT50=''; ERR50=''; FX50="$RAIZ/fx50-$BASHPID"; FXD50=''

# --- B1: CA-04 — la plantilla del manifiesto trae la política, con los cinco ámbitos y el de arnés precargado -------
# tpl50 <plantilla> -> 0 si, con los marcadores sustituidos como lo haría `arnes-init`, es JSON y su `rigor_politica`
# cumple CA-04; si no, 1 y MOT50. Los marcadores se sustituyen con expansión de parámetros: sin procesos.
tpl50() {
  local t='' p=''
  MOT50=''
  [ -r "$1" ] || { MOT50='la plantilla no se puede leer'; return 1; }
  t="$(<"$1")"
  p='{{ARNES_VERSION}}'; t="${t//"$p"/0.0.0}"
  p='{{CODIGO_APP_GLOBS}}'; t="${t//"$p"/}"
  p='{{QUALITY_GATES_JSON}}'; t="${t//"$p"/}"
  for p in DINERO SESION SEGURIDAD DATOS; do p="{{RIGOR_${p}_JSON}}"; t="${t//"$p"/[]}"; done
  case "$t" in *'{{'*) MOT50='quedan marcadores sin sustituir'; return 1 ;; esac
  jq -e . >/dev/null 2>&1 <<< "$t" || { MOT50='no es JSON tras sustituir los marcadores'; return 1; }
  jq -e '.rigor_politica as $r | ($r | type) == "object" and $r.defecto == "ligero" and ($r.ambitos | type) == "object"
         and ([$r.ambitos | (.dinero, .sesion, .seguridad, .datos, .arnes)]
              | all(. as $v | $v == "ninguno" or (($v | type) == "array" and all($v[]; type == "string"))))
         and (([".arnes/*", "AGENTS.md", "CLAUDE.md", ".claude/*"] - $r.ambitos.arnes) | length) == 0' \
    >/dev/null 2>&1 <<< "$t" || { MOT50='sin rigor_politica válido con los cinco ámbitos y el de arnés precargado'; return 1; }
}
b1_50() { tpl50 "$ARB50/templates/arnes-config.json.tpl"; }

# --- B2: CA-10 — la orden literal de `arnes-upgrade`, ejecutada sobre los fixtures (a)–(e) ----------------------------
# orden50 <SKILL.md> -> ORD50: el bloque de código que sigue al marcador `<!-- orden: rigor_politica`; vacía si no está.
orden50() {
  local l='' en=0 o=''
  ORD50=''
  [ -r "$1" ] || return 0
  while IFS= read -r l || [ -n "$l" ]; do
    case "$en:$l" in
      0:*'<!-- orden: rigor_politica'*) en=1 ;;
      1:*'```'*) en=2 ;;
      2:*'```'*) ORD50="$o"; return 0 ;;
      2:*) o+="$l"$'\n' ;;
    esac
  done < "$1"
  return 0   # sin cierre del bloque no hay orden
}
# corre50 <proyecto>: lo que la skill manda —ejecutar la orden en la raíz y, SÓLO con código 0, escribir su salida
# entera en el manifiesto (el `Write`)—. Deja RC50, OUT50 y ERR50; 1 si la skill no trae la orden.
corre50() {
  RC50=127; OUT50=''; ERR50=''
  [ -n "$ORD50" ] || { MOT50='la skill no trae la orden de rigor_politica'; return 1; }
  OUT50="$(cd "$1" && bash -c "$ORD50" 2>"$FX50/err")"; RC50=$?
  ERR50="$(<"$FX50/err")"
  if [ "$RC50" -eq 0 ] && [ -n "$OUT50" ]; then printf '%s\n' "$OUT50" > "$1/.arnes/config.json"; fi
  return 0
}
fx50_nuevo() {   # <nombre> -> FXD50, un proyecto instalado sin el bloque
  FXD50="$FX50/$1"; mkdir -p "$FXD50/.arnes" "$FXD50/requirements"
  printf '%s\n' "$MANIFIESTO_BASE" > "$FXD50/.arnes/config.json"
}
fxa50() {   # (a) sin bloque -> con bloque, los cinco ámbitos en [] y nada más cambia (claves, orden, valores)
  local antes=''
  fx50_nuevo a; antes="$(jq -c . "$FXD50/.arnes/config.json")"
  corre50 "$FXD50" || return 1
  [ "$RC50" -eq 0 ] || { MOT50="la orden no añadió el bloque (código $RC50: ${ERR50:0:120})"; return 1; }
  jq -e '.rigor_politica.defecto == "ligero" and (.rigor_politica.ambitos | [.dinero, .sesion, .seguridad, .datos, .arnes] | all(. == []))' \
    "$FXD50/.arnes/config.json" >/dev/null 2>&1 || { MOT50='el bloque no trae los cinco ámbitos en []'; return 1; }
  [ "$(jq -c 'del(.rigor_politica)' "$FXD50/.arnes/config.json")" = "$antes" ] || { MOT50='cambió el manifiesto fuera del bloque'; return 1; }
}
fxb50() {   # (b) con el bloque ya editado -> conservado byte a byte, y la orden lo dice
  fx50_nuevo b
  printf '{\n  "codigo_app": { "globs": ["src/*"] },\n\n  "rigor_politica": { "defecto": "ligero",\n    "ambitos": { "dinero": ["src/pagos/*"], "sesion": "ninguno", "seguridad": [], "datos": ["db/*"], "arnes": [".arnes/*"] } }\n}\n' \
    > "$FXD50/.arnes/config.json"
  cp "$FXD50/.arnes/config.json" "$FXD50/antes.json"
  corre50 "$FXD50" || return 1
  [ "$RC50" -ne 0 ] && [ -n "$ERR50" ] || { MOT50="la orden no se abstuvo (código $RC50)"; return 1; }
  cmp -s "$FXD50/antes.json" "$FXD50/.arnes/config.json" || { MOT50='el bloque editado no se conservó byte a byte'; return 1; }
}
fxc50() {   # (c) segunda pasada -> archivo idéntico
  fx50_nuevo c
  corre50 "$FXD50" || return 1
  [ "$RC50" -eq 0 ] || { MOT50="la primera pasada falló (código $RC50)"; return 1; }
  cp "$FXD50/.arnes/config.json" "$FXD50/antes.json"
  corre50 "$FXD50" || return 1
  [ "$RC50" -ne 0 ] || { MOT50='la segunda pasada volvió a escribir'; return 1; }
  cmp -s "$FXD50/antes.json" "$FXD50/.arnes/config.json" || { MOT50='la segunda pasada cambió el archivo'; return 1; }
}
fxd50() {   # (d) manifiesto ilegible -> no se toca y se informa
  fx50_nuevo d
  printf '{ "agentes": \n' > "$FXD50/.arnes/config.json"; cp "$FXD50/.arnes/config.json" "$FXD50/antes.json"
  corre50 "$FXD50" || return 1
  [ "$RC50" -ne 0 ] || { MOT50='la orden aceptó un manifiesto ilegible'; return 1; }
  [ -n "$ERR50" ] || { MOT50='no informó nada'; return 1; }
  cmp -s "$FXD50/antes.json" "$FXD50/.arnes/config.json" || { MOT50='tocó el manifiesto ilegible'; return 1; }
}
fxd2_50() {   # (d) con 0 bytes (F-137-17): no se toca y se informa, como cualquier manifiesto ilegible
  fx50_nuevo d2
  : > "$FXD50/.arnes/config.json"
  corre50 "$FXD50" || return 1
  [ "$RC50" -ne 0 ] && [ -n "$ERR50" ] || { MOT50="no informó el manifiesto vacío (código $RC50)"; return 1; }
  [ ! -s "$FXD50/.arnes/config.json" ] || { MOT50='escribió sobre el manifiesto vacío'; return 1; }
}
fxe50() {   # (e) el `Rigor:` de todo REQ existente y su `AGENTS.md` no cambian (hash)
  local antes='' despues=''
  fx50_nuevo e
  printf '# REQ-001\nEstado: pendiente\nRigor: estandar\n' > "$FXD50/requirements/REQ-001.md"
  printf '# REQ-002\nEstado: completado\nSensible a seguridad: sí\nRigor: critico\n' > "$FXD50/requirements/REQ-002.md"
  printf '# REQ-003\nEstado: en-revisión\n' > "$FXD50/requirements/REQ-003.md"
  printf '# AGENTS.md\n§6 sin declaración de vía.\n' > "$FXD50/AGENTS.md"
  antes="$(cd "$FXD50" && cksum AGENTS.md requirements/*.md)"
  corre50 "$FXD50" || return 1
  [ "$RC50" -eq 0 ] || { MOT50="la migración no se aplicó (código $RC50)"; return 1; }
  despues="$(cd "$FXD50" && cksum AGENTS.md requirements/*.md)"
  [ "$antes" = "$despues" ] || { MOT50='cambió un REQ o el AGENTS.md'; return 1; }
}
# fila50 <id> <función>: la misma función sobre la candidata (cumple) y sobre v1.36.2 (no cumple: fail-before).
fila50() {
  local nom="REQ-034 $1"
  ARB50="${TPL_DIR%/*}"; orden50 "$ARB50/skills/arnes-upgrade/SKILL.md"; mkdir -p "$FX50"
  if "$2"; then v50 PASS "$nom candidata"; else v50 FAIL "$nom candidata  $MOT50"; fi
  if [ "$RV50_OK" != si ]; then v50 SKIP "$nom v1.36.2 (fail-before)  $RV50_MOT"; return 0; fi
  ARB50="$RV50"; orden50 "$ARB50/skills/arnes-upgrade/SKILL.md"
  if "$2"; then v50 FAIL "$nom v1.36.2 (fail-before)  ya se cumple en v1.36.2: el caso no discrimina"
  else v50 PASS "$nom v1.36.2 (fail-before)  ($MOT50)"; fi
}
fila50 "B1 CA-04: la plantilla trae rigor_politica válido con los cinco ámbitos" b1_50
fila50 "B2 CA-10 (a): sin bloque -> con bloque, cinco ámbitos [] y nada más cambia" fxa50
fila50 "B2 CA-10 (b): bloque ya editado -> conservado byte a byte" fxb50
fila50 "B2 CA-10 (c): segunda pasada -> archivo idéntico" fxc50
fila50 "B2 CA-10 (d): manifiesto ilegible -> no se toca y se informa" fxd50
fila50 "B2 CA-10 (d): manifiesto de 0 bytes -> no se toca y se informa (F-137-17)" fxd2_50
fila50 "B2 CA-10 (e): el Rigor: de los REQ y el AGENTS.md no cambian (hash)" fxe50

# --- B3: CA-06 — la batería de cierres decide igual con el manifiesto sin el bloque y con él, y sin aviso nuevo -------
# El veredicto esperado es el de HOY en los cuatro manifiestos y en los dos árboles; la salida de error de cada variante
# se compara con la de `sin` del mismo cierre y árbol. Control sin movimiento: ningún deny pasa a allow.
mkreq_r REQ-501 no pendiente n/a ligero; mkreq_r REQ-502 sí aprobado pendiente ligero
mkreq_r REQ-503 no aprobado pendiente critico; mkreq_r REQ-504 sí aprobado pendiente ''
mkreq_r REQ-505 no pendiente n/a estandar
M50_SIN="$MANIFIESTO_BASE"
M50_COMPLETO="$(jq '. + {rigor_politica: {defecto: "ligero", ambitos: {dinero: ["src/pagos/*"], sesion: ["src/auth/*"], seguridad: "ninguno", datos: ["db/*"], arnes: [".arnes/*", "AGENTS.md", "CLAUDE.md", ".claude/*"]}}}' <<< "$MANIFIESTO_BASE")"
M50_VACIO="$(jq '. + {rigor_politica: {defecto: "ligero", ambitos: {dinero: [], sesion: [], seguridad: [], datos: [], arnes: []}}}' <<< "$MANIFIESTO_BASE")"
M50_TIPOS="$(jq '. + {rigor_politica: {defecto: 7, ambitos: {dinero: "si", sesion: 3, seguridad: null, datos: {}, arnes: true}}}' <<< "$MANIFIESTO_BASE")"
D50=''; E50=''; G50ERR="$RAIZ/g50-$BASHPID"   # fuera de `$( )`: dentro, `$BASHPID` es el del subshell
g50() {   # <dir de hooks> <json> -> D50 (deny|allow) y E50 (la salida de error), por guard.sh: lo que recibe el cliente
  local out=''; D50=''; E50=''; [ -n "$2" ] || return 1
  out="$(cd "$PROJ" && printf '%s' "$2" | bash "$1/guard.sh" 2>"$G50ERR")"
  case "$out" in *'"permissionDecision":"deny"'*) D50=deny ;; *) D50=allow ;; esac
  E50="$(<"$G50ERR")" || D50='sin-medir: la salida de error no se pudo leer'
}
cierres50=("1|REQ-501|allow|ligero no sensible, QA pendiente"
           "2|REQ-502|deny|ligero sensible, Seguridad pendiente"
           "3|REQ-503|deny|critico sin Seguridad aprobado"
           "4|REQ-504|deny|Rigor omitido y sensible"
           "5|REQ-505|deny|estandar con QA pendiente")
for arb50 in candidata v1.36.2; do
  h50="$HOOKS_DIR"; etq50=candidata
  [ "$arb50" = candidata ] || { h50="$RV50/hooks"; etq50='v1.36.2 (control, decide igual)'; }
  for c50 in "${cierres50[@]}"; do
    IFS='|' read -r n50 r50 esp50 d50 <<< "$c50"; base50=''
    for var50 in SIN COMPLETO VACIO TIPOS; do
      nom50="REQ-034 B3 CA-06 ($n50) $d50 · manifiesto ${var50,,} · $etq50"
      if [ "$arb50" != candidata ] && [ "$RV50_OK" != si ]; then v50 SKIP "$nom50  $RV50_MOT"; continue; fi
      mv50="M50_$var50"; printf '%s\n' "${!mv50}" > "$PROJ/.arnes/config.json"
      j50="$(emite_edit_lit "$PROJ/requirements/$r50.md" "" "" 'Estado: en-revisión' 'Estado: completado')"
      json_no_vacio "$nom50" "$j50" || continue
      g50 "$h50" "$j50"
      [ "$var50" = SIN ] && base50="$E50"
      if [ "$D50" != "$esp50" ]; then v50 FAIL "$nom50  esperado=$esp50 got=$D50  <${E50:0:200}>"
      elif [ "$E50" != "$base50" ]; then v50 FAIL "$nom50  aviso nuevo por la salida de error: <${E50:0:200}>"
      else v50 PASS "$nom50  ($D50)"; fi
    done
  done
done

# --- PROC: CA-06 — 0 procesos añadidos en el camino común (de contrato; la técnica de REQ-007 CA-59) -----------------
# La candidata con el bloque COMPLETO frente a v1.36.2 SIN él, en el mismo proyecto y la misma corrida.
f50="$RAIZ/j50-$BASHPID.json"
for p50 in "camino común: ls -la de la coordinadora|B" "cierre (1) que hoy pasa|E"; do
  IFS='|' read -r rama50 tipo50 <<< "$p50"
  nomp50="REQ-034 PROC CA-06 $rama50: procesos de la candidata con el bloque frente a v1.36.2 sin él, techo 0 añadidos"
  if [ "$RV50_OK" != si ]; then v50 SKIP "$nomp50  $RV50_MOT"; continue; fi
  case "$tipo50" in
    B) jq -cn --arg c "$PROJ" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"ls -la"}}' > "$f50" ;;
    *) emite_edit_lit "$PROJ/requirements/REQ-501.md" "" "" 'Estado: en-revisión' 'Estado: completado' > "$f50" ;;
  esac
  if [ ! -s "$f50" ]; then v50 FAIL "$nomp50  la entrada salió vacía: no se midió"; continue; fi
  pr50=''; nm50=''
  for h50 in "$HOOKS_DIR|$M50_COMPLETO" "$RV50/hooks|$M50_SIN"; do
    printf '%s\n' "${h50#*|}" > "$PROJ/.arnes/config.json"
    s50="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "50-procesos" \
      --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git readlink realpath cygpath find stat' \
      --sujeto "cd '$PROJ' && CLAUDE_PROJECT_DIR='$PROJ' bash '${h50%%|*}/guard.sh' < '$f50'" 2>/dev/null)"
    if sonda_lee "$s50" && [ "${SONDA[estado]}" = ok ]; then pr50+="${SONDA[cuenta]:-x} "; else pr50+="x "; nm50+=" (${SONDA_MOTIVO:-${SONDA[motivo]:-?}})"; fi
  done
  read -r pc50 pb50 <<< "$pr50"
  if [ -n "$nm50" ]; then v50 SKIP "$nomp50  la sonda no midió$nm50"
  elif [ "$pc50" -le "$pb50" ]; then v50 PASS "$nomp50  ($pc50/$pb50)"
  else v50 FAIL "$nomp50  $pc50 > $pb50 + 0"; fi
done
rm -f "$f50"
rm -rf "$RV50" "$FX50"
