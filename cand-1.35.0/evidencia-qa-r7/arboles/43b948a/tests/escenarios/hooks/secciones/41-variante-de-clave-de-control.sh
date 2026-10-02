# Sección 41 del banco — 41-variante-de-clave-de-control
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-023 (mitad 1 de SEC-047, ADR-014): una VARIANTE de una clave de control —la clave escrita de
# otra forma— o una clave de control declarada MÁS DE UNA VEZ deja la cabecera AMBIGUA, y una cabecera
# ambigua no deja cerrar. Hasta 1.34.0 la variante se leía como AUSENCIA, y la ausencia abre: un BOM
# delante de `Sensible a seguridad: sí` cerraba un `critico` sin QA ni auditoría (R-012).
# TRES ÁRBOLES (CA-08): la CANDIDATA es `$HOOKS_DIR`; la BASE, 713ac68 materializado POR SHA (`mat41`);
# N, la instalación estable 1.33.2 (`ARNES_HOOKS_N`), sólo en el fail-before de las filas R —no tiene
# REQ-031—. Sin un árbol, lo que lo necesita dice SKIP con el motivo, nunca PASS. A mano,
# `ARNES_HOOKS_DIR=<hooks de 713ac68 o de 1.33.2> run.sh secciones/41-*.sh` deja en FAIL las filas R.
CASOS_ESPERADOS_SECCION=169
PISO_AUTONOMO_SECCION=119  # 15 preámbulo (líneas 1-15, con seccion_nueva) + 24 maquinaria compartida duplicada (mat41_reg y mat41, el materializador de la línea base, líneas 16-39) + 80 bloque indivisible mayor (el brazo de CA-08: g41, json41, fila41, fb41, ctrl41, cpos41 y rfila41, líneas 51-130) · REQ-014 CA-18
seccion_nueva "--- 41 · cabecera ambigua: variante de clave de control o clave repetida (REQ-023) ---"

REPO41="${SEC_DIR%/}/../../../.."; MAT41_RUTAS='hooks tools'; MAT41_REG=''; MAT41_T0=0; MAT41_REF='-'
mat41_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT41_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT41_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT41_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT41_T0 )) procesos=$4 etiqueta=$MAT41_REF ref=$MAT41_REF archivos=$3"
}
# mat41 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat41() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT41_T0=${EPOCHREALTIME/./}; MAT41_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO41" ls-tree -r "$ref" -- $MAT41_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat41_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO41" archive "$ref" $MAT41_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat41_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO41" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat41_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat41_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat41_reg ok - "$n" 6
}
BASE41="$RAIZ/base41-$BASHPID"; BASE41_OK=no; BASE41_MOT=''
if mat41 713ac68 "$BASE41"; then BASE41_OK=si
else BASE41_MOT="713ac68 no se materializó (${MAT41_REG#*motivo=})"; BASE41_MOT="${BASE41_MOT%% corrida=*})"; fi
H41N="${ARNES_HOOKS_N:-$HOME/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks}"; N41_OK=no; N41_MOT="no está la instalación estable 1.33.2 en $H41N"
[ -f "$H41N/guard-completado.sh" ] && [ -f "$H41N/lib.sh" ] && { N41_OK=si; N41_MOT=''; }
LOCU41=''; [ "$(LC_ALL=C.UTF-8 bash -c 'x=é; printf %s "${#x}"' 2>/dev/null)" = 1 ] && LOCU41=C.UTF-8   # CA-05: sin C.UTF-8, SKIP
LOC41="${LOCU41:-C}"; CTRL41="$(sed -n "s/^ARNES_CLAVES_CONTROL='\\(.*\\)'\$/\\1/p" "$HOOKS_DIR/lib.sh" 2>/dev/null)"
# v41 <PASS|FAIL|SKIP> <texto>: la línea del caso y su cuenta. Juzgar un hook exige su guarda de vacío
# ANTES (invariante 1): `g41` no ejecuta sin JSON, y quien compara dos árboles lo comprueba él mismo.
v41() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }

# --- LA PUERTA REAL: el mismo JSON PreToolUse que recibe el hook -------------------------
F41="$PROJ/requirements/REQ-941.md"; D41=''; M41=''; J41=''; C41=''
# g41 <dir de hooks> <locale> <json> -> D41 (deny|allow) y M41 (motivo, tal como lo codifica jq)
g41() {
  local h="$1" loc="$2" json="$3" out suf='"}}'; D41=''; M41=''; [ -n "$json" ] || return 1
  out="$(printf '%s' "$json" | LC_ALL="$loc" CLAUDE_PROJECT_DIR="$PROJ" bash "$h/guard-completado.sh" 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D41=deny ;; *) D41=allow ;; esac
  M41="${out#*\"permissionDecisionReason\":\"}"; [ "$M41" != "$out" ] || M41=''; M41="${M41%%"$suf"*}"
}
cab41() { local l; C41="$1"; shift; for l in "$@"; do [ -z "$l" ] || C41+=$'\n'"$l"; done; }
# json41 <E|W> <cabecera en disco> <old> <new> [crlf] -> escribe el disco y deja J41 (1 si salió vacío)
json41() {
  local disco res eol=$'\n'; disco="# REQ-941"$'\n'"$2"$'\n\n## Historia\n\nTexto.'; res="${disco/"$3"/"$4"}"
  [ -z "${5:-}" ] || { disco="${disco//$'\n'/$'\r\n'}"; res="${res//$'\n'/$'\r\n'}"; eol=$'\r\n'; }
  printf '%s' "$disco$eol" > "$F41"
  if [ "$1" = E ]; then J41="$(emite_edit_real "$F41" "$3" "$4")"; else J41="$(emite_write "$F41" "$res$eol")"; fi
  [ -n "$J41" ]
}
declare -A DC41=() DB41=() DN41=() MC41=() MB41=(); DOCS41=(); LOCN41=0; LOCDIF41=0; LOCPRI41=''
# fila41 <id> <vías E|W|EW> <esperado> <patrón del motivo|-> <cabecera> <old> <new> [crlf]
fila41() {
  local id="$1" esp="$3" pat="$4" via nom d m; DOCS41+=("$5")
  for via in E W; do
    case "$2" in *"$via"*) ;; *) continue ;; esac
    nom="REQ-023 CA-08 $id (Write)"; [ "$via" = W ] || nom="REQ-023 CA-08 $id (Edit)"
    json41 "$via" "$5" "$6" "$7" "${8:-}"
    if ! json_no_vacio "$nom" "$J41"; then FAIL=$((FAIL+1)); continue; fi
    g41 "$HOOKS_DIR" "$LOC41" "$J41"; d="$D41"; m="$M41"; DC41["$id:$via"]="$d"; MC41["$id:$via"]="$m"
    if [ -n "$LOCU41" ]; then g41 "$HOOKS_DIR" C "$J41"; LOCN41=$((LOCN41 + 1))
      [ "$D41" = "$d" ] && [ "$M41" = "$m" ] || { LOCDIF41=$((LOCDIF41 + 1)); LOCPRI41="${LOCPRI41:-$id:$via}"; }; fi
    [ "$BASE41_OK" != si ] || { g41 "$BASE41/hooks" "$LOC41" "$J41"; DB41["$id:$via"]="$D41"; MB41["$id:$via"]="$M41"; }
    case "$id" in R*) [ "$N41_OK" != si ] || { g41 "$H41N" "$LOC41" "$J41"; DN41["$id:$via"]="$D41"; } ;; esac
    if [ "$d" != "$esp" ]; then v41 FAIL "$nom  esperado=$esp got=$d  <${m:0:200}>"
    elif [ "$pat" != - ] && ! grep -Eq -- "$pat" <<< "$m"; then v41 FAIL "$nom  el motivo no casa /$pat/  <${m:0:240}>"
    # CA-01 (iii): en el motivo de la cabecera ambigua no queda NINGÚN byte >= 0x80 ni de control crudo.
    elif [[ "$pat" == *AMBIGUA* ]] && LC_ALL=C grep -q '[^ -~]' <<< "$m"; then v41 FAIL "$nom  el motivo lleva bytes sin escapar  <${m:0:240}>"
    else v41 PASS "$nom  ($d)"; fi
  done
}
# fb41 <id>: (i) fail-before — allow en 713ac68 y en 1.33.2, deny en la candidata, en cada vía.
fb41() {
  local id="$1" via k mal='' vistas=0 nom="REQ-023 CA-08 (i) $1 fail-before: allow en 713ac68 y en 1.33.2, deny en la candidata"
  for via in E W; do
    k="$id:$via"; [ -n "${DC41[$k]:-}" ] || continue; vistas=$((vistas + 1))
    [ "${DC41[$k]}" = deny ] || mal+=" $via: candidata=${DC41[$k]}"
    [ "$BASE41_OK" != si ] || [ "${DB41[$k]}" = allow ] || mal+=" $via: 713ac68=${DB41[$k]} (el fail-before no está demostrado)"
    [ "$N41_OK" != si ] || [ "${DN41[$k]}" = allow ] || mal+=" $via: 1.33.2=${DN41[$k]} (el fail-before no está demostrado)"
  done
  if [ "$vistas" -eq 0 ] || [ -n "$mal" ]; then v41 FAIL "$nom ${mal:- no corrió ninguna vía}"
  elif [ "$BASE41_OK" != si ] || [ "$N41_OK" != si ]; then v41 SKIP "$nom  ${BASE41_MOT}${BASE41_MOT:+; }${N41_MOT}"
  else v41 PASS "$nom ($vistas vía(s))"; fi
}
# ctrl41 <id> <vías> <cabecera sin la variante o la repetición> <old> <new>: (ii) control negativo.
ctrl41() {
  local via db mal='' nom="REQ-023 CA-08 (ii) $1 control negativo: sin la variante o la repetición decide igual en 713ac68 y en la candidata"
  if [ "$BASE41_OK" != si ]; then v41 SKIP "$nom  $BASE41_MOT"; return 0; fi
  for via in E W; do
    case "$2" in *"$via"*) ;; *) continue ;; esac
    json41 "$via" "$3" "$4" "$5"; if ! json_no_vacio "$nom" "$J41"; then FAIL=$((FAIL + 1)); return 0; fi
    g41 "$BASE41/hooks" "$LOC41" "$J41"; db="$D41:${M41:0:60}"
    g41 "$HOOKS_DIR" "$LOC41" "$J41"; [ "$D41:${M41:0:60}" = "$db" ] || mal+=" $via: 713ac68=<$db> candidata=<$D41:${M41:0:60}>"
  done
  if [ -n "$mal" ]; then v41 FAIL "$nom $mal"; else v41 PASS "$nom (${db%%:*})"; fi
}
# cpos41 <id> [motivo]: (iii) control positivo — la base 713ac68 decide igual (y, con `motivo`, dice lo mismo).
cpos41() {
  local via k mal='' nom="REQ-023 CA-08 (iii) $1 control positivo: 713ac68 y la candidata deciden igual${2:+ y con el mismo motivo}"
  if [ "$BASE41_OK" != si ]; then v41 SKIP "$nom  $BASE41_MOT"; return 0; fi
  for via in E W; do
    k="$1:$via"; [ -n "${DC41[$k]:-}" ] || continue
    [ "${DC41[$k]}" = "${DB41[$k]}" ] || mal+=" $via: 713ac68=${DB41[$k]} candidata=${DC41[$k]}"
    [ -z "${2:-}" ] || [ "${MC41[$k]}" = "${MB41[$k]}" ] || mal+=" $via: el motivo difiere"
  done
  if [ -n "$mal" ]; then v41 FAIL "$nom $mal"; else v41 PASS "$nom"; fi
}
# rfila41 <id> <vías> <patrón> <cabecera> <cabecera de control> [old new [old new de control]]
rfila41() {
  local o="${6:-Estado: en-revisión}" n="${7:-Estado: completado}"
  fila41 "$1" "$2" deny "AMBIGUA.*$3" "$4" "$o" "$n"; fb41 "$1"; ctrl41 "$1" "$2" "$5" "${8:-$o}" "${9:-$n}"
}

# --- CA-08: LA TABLA DE CASOS MÍNIMOS (F0 cierra; cada fila dice qué cambia) ---------------
E0='Estado: en-revisión'; EC='Estado: completado'; S0='Sensible a seguridad: sí'; Q0='QA: aprobado'
G0='Seguridad: aprobado'; H0='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; HC='Hallazgos abiertos: SEC-1 (contrato)'
BOM=$'\xef\xbb\xbf'; ZW=$'\xe2\x80\x8b'; NB=$'\xc2\xa0'; QP='QA: pendiente'; GP='Seguridad: pendiente'; RL='Rigor: ligero'
VH="variante de 'Hallazgos abiertos:'"; B3='357.{1,2}273.{1,2}277'
cab41 "$E0" "$S0" "$Q0" "$G0" "$HC" "$R0"; CHC="$C41"
cab41 "$E0" "$S0" "$Q0" "$G0" 'Hallazgos  abiertos: SEC-1 (contrato)' "$R0"; rfila41 R1 EW "$VH" "$C41" "$CHC"
cab41 "$E0" "$S0" "$Q0" "$G0" 'Hallazgos abiertos: QA-2 (instrumento)' 'HALLAZGOS ABIERTOS: SEC-1 (contrato)' "$R0"; r="$C41"
cab41 "$E0" "$S0" "$Q0" "$G0" 'Hallazgos abiertos: QA-2 (instrumento)' "$R0"; rfila41 R2 EW "$VH" "$r" "$C41"
cab41 "$E0" "$S0" "$Q0" "$G0" "$BOM$HC" "$R0"; rfila41 R3 EW "${B3}Hallazgos abiertos.*$VH" "$C41" "$CHC"
cab41 "$E0" "$S0" "$Q0" "$G0" "Hallazgos abier${ZW}tos: SEC-1 (contrato)" "$R0"; rfila41 R4 EW "342.{1,2}200.{1,2}213tos.*$VH" "$C41" "$CHC"
cab41 "$E0" "$S0" "$Q0" "$G0" "Hallazgos${NB}abiertos: SEC-1 (contrato)" "$R0"; rfila41 R5 EW "302.{1,2}240abiertos.*$VH" "$C41" "$CHC"
cab41 "$E0" "$S0" "$Q0" "$G0" "- $HC" "$R0"; rfila41 R6 EW "$VH" "$C41" "$CHC"
cab41 "$E0" "$S0" "$QP" "$GP" "$H0" "$RL"; CS="$C41"
cab41 "$E0" 'SENSIBLE A  SEGURIDAD: sí' "$QP" "$GP" "$H0" "$RL"; rfila41 R7 EW "variante de 'Sensible a seguridad:'" "$C41" "$CS"
cab41 "$E0" "$BOM$S0" "$QP" "$GP" "$H0" "$RL"; rfila41 R8 EW "${B3}Sensible.*variante de 'Sensible a seguridad:'" "$C41" "$CS"; CR8="$C41"
# Por `Write` el byte suelto viaja en JSON y jq lo cambia por U+FFFD: sigue siendo variante, y el motivo lo dice.
cab41 "$E0" "$S0" "$Q0" "$G0" $'\xc3'"$HC" "$R0"; rfila41 R9 EW "(303|357.{1,2}277.{1,2}275)Hallazgos.*$VH" "$C41" "$CHC"
cab41 "$E0" "$S0" "$QP" "$G0" "$H0" "$R0"; CQ="$C41"
cab41 "$E0" "$S0" 'qa: pendiente' "$G0" "$H0" "$R0"; rfila41 R10 EW "variante de 'QA:'" "$C41" "$CQ"
cab41 "$E0" 'Sensible a seguridad: no' "$Q0" "$GP" "$H0" "$R0"; r="$C41"
cab41 "$E0" 'Sensible a seguridad: no' "$Q0" "$GP" "$H0" 'RIGOR: critico'; rfila41 R11 EW "variante de 'Rigor:'" "$C41" "$r"
rfila41 R12 E "variante de 'Estado:'" "$CQ" "$CQ" "$E0" 'ESTADO: completado' "$E0" "$EC"
cab41 "$E0" "$S0" "$QP" "$GP" "$H0" "$RL" 'Sensible a seguridad: no'; rfila41 R13 EW "'Sensible a seguridad:' declarada 2 veces" "$C41" "$CS"
cab41 "$E0" "$S0" '1. QA: pendiente' "$G0" "$H0" "$R0"; rfila41 R14 EW "variante de 'QA:'" "$C41" "$CQ"
cab41 "$E0" "$S0" "$QP" "$G0" "$H0" "$R0" "$Q0"; rfila41 R15 EW "'QA:' declarada 2 veces" "$C41" "$CQ"
cab41 "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0"; CF0="$C41"
cab41 "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "$Q0"; rfila41 R16 EW "'QA:' declarada 2 veces" "$C41" "$CF0"
rfila41 R17 EW "'Estado:' declarada 2 veces" "$CF0" "$CF0" "$R0" "$R0"$'\n'"$EC" "$E0" "$EC"
cab41 "$E0" "$S0" "$Q0" "$G0" "$BOM- $HC" "$R0"; rfila41 R18 EW "${B3}- Hallazgos.*$VH" "$C41" "$CHC"
fila41 A1 EW allow - "$CF0" "$E0" "$EC"; cpos41 A1
cab41 "$E0" "$S0" "$Q0" "$G0" '**Hallazgos abiertos:** (ninguno)' "$R0"; fila41 A2 EW allow - "$C41" "$E0" "$EC"; cpos41 A2
cab41 "$E0" "$Q0"; fila41 A3 EW allow - "$C41" "$E0" "$EC"; cpos41 A3
cab41 "$E0" 'Módulo: hooks' 'Versión destino: 1.35.0' "$S0" "$Q0" 'Nota: la seguridad del estado se revisa aparte.' "$G0" "$H0" "$R0"; fila41 A4 EW allow - "$C41" "$E0" "$EC"; cpos41 A4
cab41 "$E0" "$S0" "$Q0" "$G0" "$H0" '<!-- Hallazgos  abiertos: SEC-1 (contrato) -->' "$R0"; fila41 A5 EW allow - "$C41" "$E0" "$EC"; cpos41 A5
cab41 "$EC" "$S0" "$Q0" "$G0" "$H0" "$R0" "$Q0"; fila41 A6 EW allow - "$C41" "$EC" 'Estado: en-progreso'; cpos41 A6
cab41 "$E0" "$S0" 'qa: pendiente' "$G0" "$H0" "$R0" 'Prioridad: alta'; fila41 A7 EW allow - "$C41" 'Prioridad: alta' 'Prioridad: media'; cpos41 A7
fila41 A8 EW allow - "$CF0"$'\n## Notas\nHallazgos  abiertos: SEC-1 (contrato)' "$E0" "$EC"; cpos41 A8
cab41 "$E0" "$S0" "$Q0" "$G0" "$H0" '**Rigor**: critico'; fila41 A9 EW allow - "$C41" "$E0" "$EC"; cpos41 A9
n41=0; for s41 in '> Estado: completado' '«Estado»: completado' '(QA): pendiente' '[Rigor]: ligero' 'Q&A: pendiente'; do
  n41=$((n41 + 1)); fila41 "S$n41" EW allow - "$CF0"$'\n'"$s41" "$E0" "$EC"; cpos41 "S$n41"
done
cab41 "$E0" "$S0" "$Q0" "$G0" "$HC" "$R0" "$H0"; fila41 U1 EW deny "declara 'Hallazgos abiertos:' 2 veces" "$C41" "$E0" "$EC"
case "${MC41[U1:E]}${MC41[U1:W]}" in *AMBIGUA*) v41 FAIL "REQ-023 CA-08 U1 el motivo de este REQ se coló junto al de CA-A12" ;;
  *) v41 PASS "REQ-023 CA-08 U1 sólo el motivo de REQ-031 CA-A12, sin el de este REQ" ;; esac
cpos41 U1 motivo; fila41 U2 EW deny "es de clase 'contrato'" "$CHC" "$E0" "$EC"; cpos41 U2
fila41 U3a EW allow - "$CF0" "$E0" "$EC" crlf; fila41 U3b EW deny "AMBIGUA.*variante de 'Sensible a seguridad:'" "$CR8" "$E0" "$EC" crlf
mal41=''; for k41 in E W; do
  [ "${DC41[U3a:$k41]}" = "${DC41[A1:$k41]}" ] && [ "${DC41[U3b:$k41]}" = "${DC41[R8:$k41]}" ] || mal41+=" candidata/$k41"
  [ "$BASE41_OK" != si ] || { [ "${DB41[U3a:$k41]}" = "${DB41[A1:$k41]}" ] && [ "${DB41[U3b:$k41]}" = "${DB41[R8:$k41]}" ]; } || mal41+=" 713ac68/$k41"
done
nom41="REQ-023 CA-08 (iii) U3 cada árbol decide en CRLF como en LF (A1 y R8, las dos vías)"; if [ -n "$mal41" ]; then v41 FAIL "$nom41:$mal41"; elif [ "$BASE41_OK" != si ]; then v41 SKIP "$nom41  (sólo la candidata: $BASE41_MOT)"; else v41 PASS "$nom41"; fi
n41=0; for f41 in $'Hallazg\xd0\xbes abiertos: SEC-1 (contrato)' 'Hallazgo abierto: SEC-1 (contrato)' \
           "$(for ((i = 0; i < 90; i++)); do printf '%s' "$ZW"; done)$HC" $'Hallazgos abiertos\xef\xbc\x9a SEC-1 (contrato)' "-$NB$HC"; do
  n41=$((n41 + 1)); cab41 "$E0" "$S0" "$Q0" "$G0" "$f41" "$R0"; fila41 "F$n41" EW allow - "$C41" "$E0" "$EC"; cpos41 "F$n41"
done
if [ -z "$LOCU41" ]; then v41 SKIP "REQ-023 CA-05 C.UTF-8 frente a C  esta máquina no tiene C.UTF-8"   # CA-05: veredicto y motivo
elif [ "$LOCN41" -gt 0 ] && [ "$LOCDIF41" -eq 0 ]; then v41 PASS "REQ-023 CA-05 los $LOCN41 casos de CA-08 dan veredicto y motivo idénticos bajo C.UTF-8 y C"
else v41 FAIL "REQ-023 CA-05 $LOCDIF41 de $LOCN41 casos cambian con el locale (el primero: $LOCPRI41)"; fi

# --- Las sondas de lectura: se INVOCAN con el árbol que toque (candidata o 713ac68) ----------
SON41="$RAIZ/son41-$BASHPID.sh"
cat > "$SON41" <<'SONDA41'
set -uo pipefail; H="$1"; modo="$2"; lista="$3"; . "$H/lib.sh"
while IFS= read -r f; do
  t=''; IFS= read -r -d '' t < "$f" || :
  case "$modo" in
    lib) arnes_estado_cabecera "$t"; e="$ARNES_ESTADO"; arnes_campos_req "$t" '' ;;
    awk) IFS=$'\001' read -r _r e q s n h r <<< "$(awk -f "$H/campos-req.awk" "$f")"
         arnes_norm_campo "$e"; arnes_veredicto "$ARNES_CAMPO"; e="$ARNES_VEREDICTO"; arnes_campos_normaliza "$q" "$s" "$n" "$h" "$r" ;;
    amb) arnes_campos_req "$t" ''; printf '%s\n' "${ARNES_AMBIGUA:-x}"; continue ;;
    lin) ARNES_CITA=0; ARNES_CR=0; while IFS= read -r l; do case "$l" in '## '*) break ;; esac
         arnes_campo_linea "$l" && printf '<%s>=<%s> ' "$ARNES_CLAVE" "$ARNES_VALOR"; done <<< "$t"; echo; continue ;;
    cola) arnes_cola_pendientes "$f"; printf '%s rc=%s\n' "${ARNES_COLA:-}" "$?"; continue ;;
  esac
  printf 'E=<%s> QA=<%s> Seg=<%s> Sens=<%s> Hall=<%s> Rigor=<%s>\n' "$e" "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR"
done < "$lista"
SONDA41
# lista41 <prefijo> <documentos...> -> escribe cada uno y deja la lista en LISTA41
lista41() { local p="$1" d i=0; shift; LISTA41="$RAIZ/$p-$BASHPID.lst"; : > "$LISTA41"
  for d in "$@"; do i=$((i + 1)); printf '%s\n' "$d" > "$RAIZ/$p-$BASHPID-$i.md"; printf '%s\n' "$RAIZ/$p-$BASHPID-$i.md" >> "$LISTA41"; done; }
son41() { bash "$SON41" "$1" "$2" "$LISTA41" 2>>"$ERRLOG"; }   # <hooks> <modo>

# --- CA-02: el dominio de campos se DERIVA midiendo, y la clase cabe en la constante ---------
CAMPOS41="$(sed -n -e "s/.*case \"\$ARNES_CLAVE\" in '\([^']*\)').*/\1/p" \
  -e "s/^[[:space:]]*'\([A-Za-z][^']*\)')[[:space:]]*ARNES_[A-Z]*=\"\$ARNES_VALOR\".*/\1/p" "$HOOKS_DIR/lib.sh" | sort -u)"
declare -A CTX41=([Estado]="$QP" [QA]='' [Seguridad]="$R0"$'\n'"$Q0" ['Sensible a seguridad']="$RL"$'\n'"$QP"$'\n'"$GP" \
  ['Hallazgos abiertos']="$Q0" [Rigor]=$'Sensible a seguridad: no\n'"$Q0"$'\n'"$GP")
declare -A VAL41=([Estado]=completado [QA]=pendiente [Seguridad]=pendiente ['Sensible a seguridad']='sí' ['Hallazgos abiertos']='SEC-1 (contrato)' [Rigor]=critico)
dec41() { D41=''; json41 W "$2" "$2" "$3" && g41 "$1" "$LOC41" "$J41"; }   # <hooks> <disco> <resultante> -> D41 ('' sin JSON)
clase41=''; sinfix41=''; vardeny41=''; baseabre41=0; n41=0
while IFS= read -r k41; do
  [ -n "$k41" ] || continue; n41=$((n41 + 1))
  [ -n "${VAL41[$k41]+x}" ] || { sinfix41+=" $k41"; continue; }
  # Por `Write` el campo que falta en lo entrante se lee del disco: el disco NO lo declara, o la «ausencia» mediría el disco.
  c41="${CTX41[$k41]}"; v41k="${k41^^}"; [ "$v41k" != "$k41" ] || v41k="${k41,,}"; dis41="$E0"$'\n'"$c41"
  if [ "$k41" = Estado ]; then pres41="$EC"$'\n'"$c41"; aus41="$c41"; var41="$v41k: completado"$'\n'"$c41"
  else pres41="$EC"$'\n'"$c41"$'\n'"$k41: ${VAL41[$k41]}"; aus41="$EC"$'\n'"$c41"; var41="$EC"$'\n'"$c41"$'\n'"$v41k: ${VAL41[$k41]}"; fi
  dec41 "$HOOKS_DIR" "$dis41" "$pres41"; p41="$D41"; dec41 "$HOOKS_DIR" "$dis41" "$aus41"
  [ "$p41" = deny ] && [ "$D41" = allow ] || continue
  clase41+="${clase41:+, }$k41"
  dec41 "$HOOKS_DIR" "$dis41" "$var41"; [ "$D41" = deny ] || vardeny41+=" $k41"
  [ "$BASE41_OK" != si ] || { dec41 "$BASE41/hooks" "$dis41" "$var41"; [ "$D41" != allow ] || baseabre41=$((baseabre41 + 1)); }
done <<< "$CAMPOS41"
if [ -n "$clase41" ] && [ -z "$sinfix41" ]; then v41 PASS "REQ-023 CA-02 dominio derivado del lector ($n41 campos) y clase medida en esta corrida: $clase41"
else v41 FAIL "REQ-023 CA-02 el dominio no se pudo derivar (clase=<$clase41>, campos sin fixture:${sinfix41:- ninguno}): aborta"; fi
fuera41=''; while IFS= read -r k41; do case "|$CTRL41|" in *"|$k41|"*) ;; *) fuera41+=" $k41" ;; esac; done <<< "${clase41//, /$'\n'}"
if [ -n "$CTRL41" ] && [ -z "$fuera41" ] && [ -n "$clase41" ]; then v41 PASS "REQ-023 CA-02 todo campo de la clase es clave de control de la constante"
else v41 FAIL "REQ-023 CA-02 campos de la clase que la constante no contiene:${fuera41:- (no hay constante en $HOOKS_DIR/lib.sh)}"; fi
if [ -n "$clase41" ] && [ -z "$vardeny41" ]; then v41 PASS "REQ-023 CA-02 declarado por una variante, cada campo de la clase DENIEGA"
else v41 FAIL "REQ-023 CA-02 la variante se resolvió como ausencia en:${vardeny41:- (clase vacía)}"; fi
if [ "$BASE41_OK" != si ]; then v41 SKIP "REQ-023 CA-02 anti-vacuidad contra la base  $BASE41_MOT"
elif [ "$baseabre41" -gt 0 ]; then v41 PASS "REQ-023 CA-02 anti-vacuidad: $baseabre41 campo(s) de la clase abren con la variante en 713ac68"
else v41 FAIL "REQ-023 CA-02 ningún campo de la clase abre contra 713ac68: la propiedad sería cierta por vacío (aborta)"; fi

# --- CA-03: la clase descartada, por CONSTRUCCIÓN — tres familias y una entrada al AZAR -------
SEM41="${ARNES_SEMILLA_41:-$(( (${EPOCHSECONDS:-1} ^ $$) & 32767 ))}"; RANDOM="$SEM41"
u841() { local c=$1 o   # <punto de código> -> U41, en bytes UTF-8 (sin depender del locale)
  if ((c < 0x80)); then printf -v o '\\%03o' "$c"; elif ((c < 0x800)); then printf -v o '\\%03o\\%03o' $((0xC0|c>>6)) $((0x80|c&63)); elif ((c < 0x10000)); then
    printf -v o '\\%03o\\%03o\\%03o' $((0xE0|c>>12)) $((0x80|c>>6&63)) $((0x80|c&63)); else printf -v o '\\%03o\\%03o\\%03o\\%03o' $((0xF0|c>>18)) $((0x80|c>>12&63)) $((0x80|c>>6&63)) $((0x80|c&63)); fi; printf -v U41 "$o"; }
F1_41=(); for c41 in 1 2 3 4 5 6 7 8 11 12 {14..31} 127; do u841 "$c41"; F1_41+=("$U41"); done
F2_41=(); for c41 in 0xAD 0x200B 0x200C 0x200D 0x200E 0x200F 0x202A 0x202E 0x2060 0x2066 0x2069 0xFEFF; do u841 "$c41"; F2_41+=("$U41"); done
F3_41=($'\xc3' $'\x80' $'\xc0\xaf' $'\xed\xa0\x80')
# El universo: todo punto >= U+0080 salvo los nueve delimitadores (y los sustitutos, que UTF-8 no codifica),
# los C0 salvo LF, CR y NUL, DEL y el espacio (32 y 33 del sorteo). Una guarda por lista de prohibidos lo incumple.
while :; do
  if (( RANDOM % 8 == 0 )); then c41=$(( RANDOM % 34 )); ((c41 == 0 || c41 == 10 || c41 == 13)) && continue; ((c41 == 32)) && c41=127; ((c41 == 33)) && c41=32
  else c41=$(( 0x80 + (RANDOM * 32768 + RANDOM) % (0x110000 - 0x80) )); ((c41 >= 0xD800 && c41 <= 0xDFFF)) && continue
    case "$c41" in 171|187|8216|8217|8220|8221|8222|8249|8250) continue ;; esac; fi; break
done
u841 "$c41"; RES41="$U41"; printf -v CP41 'U+%04X' "$c41"; q41="$(LC_ALL=C; printf '%q' "$RES41")"
cab41 "$E0" "$Q0" "$HC"; json41 E "$C41" "$E0" "$EC"; JE41="$J41"   # la edición es la misma; cambia el disco
fam41() {   # <nombre> <entradas...>: cada una INSERTADA en una posición sorteada de la clave canónica
  local nom="REQ-023 CA-03 $1" e p mal=0 n=0 ab=0; shift
  for e in "$@"; do
    p=$(( RANDOM % 19 )); n=$((n + 1)); cab41 "$E0" "$Q0" "${HC:0:p}$e${HC:p}"
    printf '# REQ-941\n%s\n\n## Historia\n' "$C41" > "$F41"
    g41 "$HOOKS_DIR" "$LOC41" "$JE41" && [ "$D41" = deny ] || mal=$((mal + 1))
    [ "$BASE41_OK" != si ] || { g41 "$BASE41/hooks" "$LOC41" "$JE41"; [ "$D41" != allow ] || ab=$((ab + 1)); }
  done
  ABRE41=$((ABRE41 + ab)); VACIA41=$((VACIA41 + (n == 0)))
  if [ "$n" -gt 0 ] && [ "$mal" -eq 0 ]; then v41 PASS "$nom  $n/$n DENY en la candidata (713ac68 las dejaba cerrar: $ab/$n)"
  else v41 FAIL "$nom  $mal de $n no denegaron en la candidata (o no se ejecutaron)"; fi
}
ABRE41=0; VACIA41=0
fam41 "(i) bytes de control C0 (salvo tab, LF, CR y NUL) y DEL" "${F1_41[@]}"
fam41 "(ii) puntos de anchura cero o de formato" "${F2_41[@]}"
fam41 "(iii) UTF-8 mal formado: arranque sin continuación, continuación huérfana, sobrelarga, sustituto" "${F3_41[@]}"
fam41 "(reservada) entrada al azar $CP41 = $q41, semilla ARNES_SEMILLA_41=$SEM41 (bash $BASH_VERSION)" "$RES41"
if [ "$BASE41_OK" != si ]; then v41 SKIP "REQ-023 CA-03 anti-vacuidad contra la base  $BASE41_MOT"
elif [ "$VACIA41" -eq 0 ] && [ "$ABRE41" -gt 0 ]; then v41 PASS "REQ-023 CA-03 anti-vacuidad: ninguna familia vacía y $ABRE41 entradas abrían en 713ac68"
else v41 FAIL "REQ-023 CA-03 anti-vacuidad: familias vacías=$VACIA41, entradas que abrían en 713ac68=$ABRE41 (aborta)"; fi

# --- CA-04: ninguna tolerancia se estrecha — el corpus del banco (por glob) y los REQ reales ---
CABS41=()
while IFS= read -r l41; do [ -n "$l41" ] && CABS41+=("${l41//$'\002'/$'\n'}"); done < <(awk -v claves="$(printf '%s' "$CAMPOS41" | paste -sd'|' -)" '
  BEGIN { re = "^[ \t]*[*_`]*(" claves ")[*_`]*[ \t]*:" }
  function vuelca() { if (buf != "") print buf; buf = "" }
  FNR == 1 { vuelca() } { sub(/\r$/, "") } $0 ~ re { buf = (buf == "" ? $0 : buf "\002" $0); next } { vuelca() } END { vuelca() }
' "$SEC_DIR"/[0-9][0-9]-*.sh)
nb41=${#CABS41[@]}; DIS41=(); RES41=()
for c41 in "${CABS41[@]}"; do DIS41+=("$E0"); RES41+=("$EC"$'\n'"$c41"); done
for f41 in "$REPO41"/requirements/REQ-*.md; do
  [ -f "$f41" ] || continue; c41=''; e41=0
  while IFS= read -r l41; do case "$l41" in '## '*) break ;; 'Estado:'*) [ "$e41" = 1 ] || { e41=1; l41="$E0"; } ;; esac; c41+="${c41:+$'\n'}$l41"; done < "$f41"
  DIS41+=("$c41"); RES41+=("${c41/"$E0"/"$EC"}")
done
ntot41=${#RES41[@]}; todo41="$(printf '%s\n' "${RES41[@]}")"; av41=''
# Here-string, no tubería: con `pipefail`, el SIGPIPE del escritor ante un `grep -q` que sale antes se leía «no está».
LC_ALL=C grep -q '^[^:]*[^ -~][^:]*:' <<< "$todo41" || av41+=' clave-no-ASCII'; LC_ALL=C grep -q '^[^:]*:.*[^ -~]' <<< "$todo41" || av41+=' valor-no-ASCII'
grep -Eq '^[ \t]*[*_`]+[A-Za-z][^:]*[*_`]*:' <<< "$todo41" || av41+=' clave-decorada'
if [ "$nb41" -ge 10 ] && [ "$ntot41" -gt "$nb41" ] && [ -z "$av41" ]; then v41 PASS "REQ-023 CA-04 corpus: $nb41 cabeceras del banco por glob + $((ntot41 - nb41)) REQ de requirements/, con clave no ASCII, valor no ASCII y clave decorada"
else v41 FAIL "REQ-023 CA-04 corpus insuficiente ($nb41 del banco, $ntot41 en total; falta:${av41:- nada}): la equivalencia sería cierta por vacío"; fi
lista41 cor41 "${RES41[@]}"
if [ "$BASE41_OK" != si ]; then v41 SKIP "REQ-023 CA-04 valores idénticos campo a campo  $BASE41_MOT"; v41 SKIP "REQ-023 CA-04 decisiones idénticas salvo ambigüedad  $BASE41_MOT"
else
  vc41="$(son41 "$HOOKS_DIR" lib)"; vb41="$(son41 "$BASE41/hooks" lib)"
  if [ -n "$vc41" ] && [ "$vc41" = "$vb41" ]; then v41 PASS "REQ-023 CA-04 los $ntot41 documentos dan el mismo valor en cada campo que 713ac68"
  else v41 FAIL "REQ-023 CA-04 valores distintos de 713ac68: $(diff <(printf '%s\n' "$vb41") <(printf '%s\n' "$vc41") | head -3 | tr '\n' ' ')"; fi
  mapfile -t amb41 < <(son41 "$HOOKS_DIR" amb); dif41=''; exp41=0; reqamb41=0
  for ((i = 0; i < ntot41; i++)); do
    [ "$i" -lt "$nb41" ] || [ "${amb41[i]:-}" != 1 ] || reqamb41=$((reqamb41 + 1))
    json41 W "${DIS41[i]}" "${DIS41[i]}" "${RES41[i]}" || { dif41+=" #$i(JSON vacío)"; continue; }
    g41 "$BASE41/hooks" "$LOC41" "$J41"; db41="$D41"; g41 "$HOOKS_DIR" "$LOC41" "$J41"; [ "$D41" != "$db41" ] || continue
    # Cada diferencia: denegación por ambigüedad Y un oráculo INDEPENDIENTE (awk, no el lector) que ve la variante o la repetición.
    if [ "$D41" = deny ] && [ "${amb41[i]:-}" = 1 ] && [[ "$M41" == *AMBIGUA* ]] && awk -v k="$CTRL41" '
      BEGIN { n = split(k, c, "|"); for (j = 1; j <= n; j++) { s = tolower(c[j]); gsub(/[^a-z]/, "", s); esq[s] = c[j] } }
      /^## / { exit } index($0, ":") { x = substr($0, 1, index($0, ":") - 1); t = x; gsub(/^[ \t*_`]+|[ \t*_`]+$/, "", t)
        s = tolower(x); gsub(/[^a-z]/, "", s); if (s in esq) { v[s]++; if (t != esq[s]) r = 1 } }
      END { for (s in v) if (v[s] > 1) r = 1; exit !r }' <<< "${RES41[i]}"; then exp41=$((exp41 + 1))
    else dif41+=" #$i(713ac68=$db41 candidata=$D41 <${M41:0:80}>)"; fi
  done
  if [ -z "$dif41" ]; then v41 PASS "REQ-023 CA-04 las $ntot41 decisiones coinciden con 713ac68 salvo $exp41 denegaciones por cabecera ambigua, cada una con variante o repetición real (REQ de requirements/ ambiguos: $reqamb41)"
  else v41 FAIL "REQ-023 CA-04 decisiones distintas sin explicar:$dif41"; fi
fi

# --- CA-06: los lectores no divergen (y la base tampoco); el conjunto se lee de UNA constante --
pfx41=$'# REQ-941\n'; lista41 doc41 "${DOCS41[@]/#/$pfx41}"
cl41="$(son41 "$HOOKS_DIR" lib)"; mal41=''; [ -n "$cl41" ] && [ "$cl41" = "$(son41 "$HOOKS_DIR" awk)" ] || mal41+=' puerta<>campos-req.awk'
[ "$BASE41_OK" != si ] || { cmp -s "$HOOKS_DIR/campos-req.awk" "$BASE41/hooks/campos-req.awk" || mal41+=' campos-req.awk-cambió'
  [ "$cl41" = "$(son41 "$BASE41/hooks" lib)" ] || mal41+=' valores<>713ac68'; [ "$(son41 "$HOOKS_DIR" lin)" = "$(son41 "$BASE41/hooks" lin)" ] || mal41+=' línea<>713ac68'; }
nom41="REQ-023 CA-06 puerta, informe, campos-req.awk y arnes-paralelo (arnes_campo_linea) leen igual que 713ac68 en los ${#DOCS41[@]} documentos de CA-08"
if [ -n "$mal41" ]; then v41 FAIL "$nom41 $mal41"; elif [ "$BASE41_OK" != si ]; then v41 SKIP "$nom41  $BASE41_MOT"; else v41 PASS "$nom41"; fi
# Ni esqueletos ni listas de claves tecleados, y una clave añadida a la constante (antes del primer uso, como en el fuente).
tec41="$(cat "$HOOKS_DIR/lib.sh" "$HOOKS_DIR/guard-completado.sh" | grep -Ec 'hallazgosabiertos|sensibleaseguridad|Estado, QA, Seguridad')"
nue41=''; for a41 in '' 'Aprobacion humana'; do nue41+="$(bash -c '. "$1/lib.sh"; [ -z "$3" ] || ARNES_CLAVES_CONTROL+="|$3"; arnes_campos_req "$2" ""
  printf %s "$ARNES_AMBIGUA"' _ "$HOOKS_DIR" "$E0"$'\nAPROBACION  HUMANA: x' "$a41" 2>>"$ERRLOG")"; done
grep -q "^ARNES_CLAVE_ESTADO='Estado'" "$HOOKS_DIR/lib.sh" && case "|$CTRL41|" in *'|Estado|'*) nue41+=1 ;; esac
if [ "$tec41" = 0 ] && [ "$nue41" = 011 ]; then v41 PASS "REQ-023 CA-06 ningún esqueleto ni lista de claves tecleados; una clave añadida a la constante queda cubierta sin editar nada más"
else v41 FAIL "REQ-023 CA-06 esqueletos o listas tecleados: $tec41; clave añadida (antes/después/Estado en la constante): <$nue41>, se esperaba <011>"; fi

# --- CA-07: el informe no calla lo que la puerta deniega -------------------------------------
LP="$RAIZ/lp41-$BASHPID"; mkdir -p "$LP/.arnes" "$LP/requirements"; printf '%s\n' "$MANIFIESTO_BASE" > "$LP/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$LP/PENDING_APPROVAL.md"; printf '# REQ-9701\n%s\n%s\n%s\n' "$E0" "$Q0" "$BOM$HC" > "$LP/requirements/REQ-9701.md"
lec_check "REQ-023 CA-07 una variante invisible es anomalía (sale 1) y nombra el REQ y la clave" 1 'REQ-9701 +Hallazgos abiertos:' si
lec_check "REQ-023 CA-07 ...con la línea escapada, como el motivo de la puerta" 1 'linea 4: .{3}357.273.277Hallazgos abiertos: SEC-1 \(contrato\). \(variante de .Hallazgos abiertos:.' si
lec_check "REQ-023 CA-07 ...y la consecuencia: la puerta de cierre DENIEGA" 1 'la puerta de cierre DENIEGA mientras siga así' si
rm -f "$LP/requirements/"*; printf '# REQ-9702\n%s\n%s\n%s\n' "$E0" "$Q0" "$Q0" > "$LP/requirements/REQ-9702.md"
lec_check "REQ-023 CA-07 una clave de control repetida SIN decorar también es anomalía" 1 "'QA:' declarada 2 veces" si
rm -f "$LP/requirements/"*; printf '# REQ-9703\nESTADO: completado\n%s\n' "$Q0" > "$LP/requirements/REQ-9703.md"
lec_check "REQ-023 CA-07 también en un archivo que el informe cuenta como nota (sin Estado legible)" 1 'REQ-9703 +Estado:' si
rm -f "$LP/requirements/"*; printf '# REQ-9704\n%s\n%s\n%s\n' "$E0" "$HC" "$H0" > "$LP/requirements/REQ-9704.md"
lec_check "REQ-023 CA-07 'Hallazgos abiertos' repetida (la de REQ-031 CA-A12) también se informa" 1 "'Hallazgos abiertos:' declarada 2 veces" si
rm -f "$LP/requirements/"*; printf '# REQ-9705\n%s\n**QA:** aprobado\n' "$E0" > "$LP/requirements/REQ-9705.md"
lec_check "REQ-023 CA-07 sin variantes ni repeticiones nada nuevo: la decorada única sigue siendo aviso de forma (sale 0)" 0 'cabecera ambigua' no

# --- CA-09 y CA-05, por PROPIEDADES: leyendo el código y contando invocaciones ---------------
cod41="$( { awk '/^(_arnes_deriva_esqueletos|_arnes_clave_control|arnes_ambigua_item|arnes_ambigua_motivo|arnes_campos_req)\(\)/,/^}/' "$HOOKS_DIR/lib.sh"
  awk '/CABECERA AMBIGUA \(REQ-023/,/est_despues" = "\$done_norm" \] \|\| return 0/' "$HOOKS_DIR/guard-completado.sh"; } | grep -v '^[[:space:]]*#')"
pro41="$(printf '%s\n' "$cod41" | grep -En '\$\([^(]|`|<\(|>\(|[^|] \| [^|]|^[[:space:]]*\([^(]|\b(sed|tr|awk|grep|cut|iconv|perl|python3?|jq|cat|head|tail|wc|od)\b' | head -2)"
pri41="$(awk '/^_arnes_clave_control\(\)/{f=1;next} f && /ARNES_CLAVE[^_]|\$\{#?k[}:%#\/]|"\$k"/{print;exit}' "$HOOKS_DIR/lib.sh")"
if [ -n "$cod41" ] && [ -z "$pro41" ] && [[ "$pri41" == *ARNES_CLAVE_CONTROL_MAX_BYTES* ]]; then v41 PASS "REQ-023 CA-09 (i) y (iii) el código nuevo no crea procesos, y lo primero que hace con la clave es medirla en bytes"
else v41 FAIL "REQ-023 CA-09 (i)/(iii) código=<${#cod41}> construcciones que crean procesos=<$pro41> primera operación sobre la clave=<$pri41>"; fi
cla41="$(awk '/^(_arnes_deriva_esqueletos|_arnes_clave_control|arnes_ambigua_item)\(\)/,/^}/' "$HOOKS_DIR/lib.sh" | grep -v '^[[:space:]]*#')"
if [ "$(grep -c 'local LC_ALL=C' <<< "$cla41")" -ge 2 ] && ! grep -Eq '\[[^]]*[[:alnum:]]-[[:alnum:]][^]]*\]|\[\[:' <<< "$cla41"; then v41 PASS "REQ-023 CA-05 la clasificación corre bajo LC_ALL=C y sin rangos ni clases sujetos a colación"
else v41 FAIL "REQ-023 CA-05 la clasificación depende del locale (falta LC_ALL=C o hay rangos/clases)"; fi
CUE41="$RAIZ/cue41-$BASHPID.sh"
printf '%s\n' 'H="$1"; . "$H/lib.sh"; . "$H/guard-completado.sh"; NC=0; NV=0' 'eval "o_nk() $(declare -f arnes_norm_clave | tail -n +2)"; eval "o_nv() $(declare -f arnes_norm_campo | tail -n +2)"' \
  'arnes_norm_clave() { NC=$((NC + 1)); o_nk "$@"; }; arnes_norm_campo() { NV=$((NV + 1)); o_nv "$@"; }' 'trap '\''printf "%s %s" "$NC" "$NV" >&3'\'' EXIT; arnes_preludio || exit 0; arnes_guard_completado' > "$CUE41"
cue41() { [ -n "$J41" ] && printf '%s' "$J41" | CLAUDE_PROJECT_DIR="$PROJ" bash "$CUE41" "$1" 3>&1 >/dev/null 2>>"$ERRLOG"; }
m2_41=''; m4_41=''
for ca41 in A1 R17 R12; do
  case "$ca41" in A1) json41 W "$CF0" "$E0" "$EC"; ex41=0 ;; R17) json41 W "$CF0" "$R0" "$R0"$'\n'"$EC"; ex41=1 ;; R12) json41 W "$CQ" "$E0" 'ESTADO: completado'; ex41=1 ;; esac
  if [ "$BASE41_OK" != si ]; then break; fi; kc41=''; kb41=''; read -r kc41 vc41 <<< "$(cue41 "$HOOKS_DIR")"; read -r kb41 vb41 <<< "$(cue41 "$BASE41/hooks")"
  [ -n "$kc41" ] && [ -n "$kb41" ] && [ "$kc41" -gt 0 ] && [ "$kc41" -le "$kb41" ] || m2_41+=" $ca41: arnes_norm_clave $kc41 frente a $kb41"
  [ -n "$vc41" ] && [ -n "$vb41" ] && [ "$vc41" -le $((vb41 + ex41)) ] || m4_41+=" $ca41: arnes_norm_campo $vc41 frente a $vb41 (+$ex41 admitidas)"
done
for q41 in "(ii) recorridos: no más invocaciones de arnes_norm_clave que 713ac68|$m2_41" "(iv) normalizaciones: ninguna añadida sin ambigüedad, y sólo la del Estado que no gobierna con ella|$m4_41"; do
  if [ "$BASE41_OK" != si ]; then v41 SKIP "REQ-023 CA-09 ${q41%%|*}  $BASE41_MOT"
  elif [ -z "${q41#*|}" ]; then v41 PASS "REQ-023 CA-09 ${q41%%|*} (A1, R17, R12 por Write)"; else v41 FAIL "REQ-023 CA-09 ${q41%%|*}:${q41#*|}"; fi
done

# --- CA-11: un campo legítimamente comentado SIN espacio decide exactamente como en la base ----
for ca41 in "$CF0"$'\n<!--Estado: completado -->' "$E0"$'\nSensible a seguridad: no\n'"$QP"$'\n'"$GP"$'\n<!--Rigor: ligero-->'; do
  nom41="REQ-023 CA-11 '${ca41##*$'\n'}' decide y motiva igual que 713ac68"; mal41=''
  if [ "$BASE41_OK" != si ]; then v41 SKIP "$nom41  $BASE41_MOT"; continue; fi
  for via in E W; do json41 "$via" "$ca41" "$E0" "$EC" || { mal41+=" $via(JSON vacío)"; continue; }
    g41 "$BASE41/hooks" "$LOC41" "$J41"; b41="$D41|$M41"; g41 "$HOOKS_DIR" "$LOC41" "$J41"; [ "$D41|$M41" = "$b41" ] || mal41+=" $via"; done
  if [ -z "$mal41" ]; then v41 PASS "$nom41 (${b41%%|*})"; else v41 FAIL "$nom41: difiere en$mal41"; fi
done

# --- CA-12: la noción de cita no gana transcripciones y la cola cuenta y devuelve lo mismo ------
lista41 cola41 $'## Pendientes\n\n## Resueltas' $'## Pendientes\n### a\n### b\n### c' $'## Pendientes\n<!--\n### [x] (y) - z\n-->\n## Resueltas' \
  $'## Pendientes\n### Real <!-- nota -->' $'## Pendientes\n<!-- sin cerrar\n### a' $'## Pendientes (2 abiertas)\n### una' $'##Pendientes\n### una' $'## Pendientes\n### una\n#### sub'
nc41="$(grep -v '^[[:space:]]*#' "$HOOKS_DIR/lib.sh" | grep -c "'<!--'")"; co41="$(son41 "$HOOKS_DIR" cola)"
if [ "$BASE41_OK" != si ]; then v41 SKIP "REQ-023 CA-12 (i) y (ii) contra la base  $BASE41_MOT"
elif [ "$nc41" -le "$(grep -v '^[[:space:]]*#' "$BASE41/hooks/lib.sh" | grep -c "'<!--'")" ] && [ -n "$co41" ] && [ "$co41" = "$(son41 "$BASE41/hooks" cola)" ]; then
  v41 PASS "REQ-023 CA-12 (i) y (ii) ninguna transcripción nueva de la cita, y arnes_cola_pendientes cuenta y devuelve lo mismo que 713ac68 en 8 colas"
else v41 FAIL "REQ-023 CA-12 transcripciones de la cita o conteo de la cola distintos de 713ac68"; fi
