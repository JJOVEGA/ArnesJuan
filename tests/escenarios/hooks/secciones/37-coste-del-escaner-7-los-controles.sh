# ---------- 37 (7) · LOS CONTROLES DE MEDICIÓN DEL INSTRUMENTO (CA-08 (ii) y CA-03) ----------
# REQ-030 CA-07. Las pruebas DE MEDICIÓN del procedimiento (las SINTÉTICAS del juez son 37/6).
# Por cada entrada —el REQ real de 6 líneas y la cabecera de 200— tres controles, cada uno con
# el MISMO presupuesto (`SONDA_COSTE_R`) y el MISMO juez que decide CA-08 (ii)
# (`sonda_juez_razon`, del corredor), en este orden fijo:
#   I  — este árbol contra sí mismo: razón verdadera 1,0. Si el juez dice FAIL es un FALSO AVISO.
#   W0 — contra un envoltorio SÓLO DE PRUEBAS con demora 0 que ejecuta el mismo hook: tampoco
#        puede dar FAIL.
#   WD — contra ese envoltorio con una demora FIJA por llamada (40 ms en 6 líneas, 100 ms en
#        200), sin recalibrar. El caso es PASS si el juez dice FAIL (vio la demora añadida).
# Y un séptimo, C3 (CA-07 (g), SEC-108): si el instrumento de CA-03 VE el árbol cuadrático
# v1.32.1. Es el detector mecánico de un instrumento roto que daba el `fail-before` retirado:
# PASS si lo ve, FAIL REAL si demuestra una avería, INCONCLUSO si no pudo acreditarlo.
#
# EL FAIL ESPERADO DE WD SE COMPRUEBA COMO ESPERADO y no deja el banco en rojo; el de C3 NO es
# esperado: una avería demostrada pone el banco en rojo. Un INCONCLUSO de WD o de C3 NO acredita
# el instrumento. Y detectar una demora añadida es un control DE LA PRUEBA, no su finalidad: no
# garantiza detectar una regresión interna del escáner, cuyo control sigue siendo v1.32.1.
#
# A DEMANDA, con `ARNES_SONDA_CONTROLES=1`, como 37/4 con `ARNES_COSTE_RUTA_CRITICA=1`: son
# 30 invocaciones de la sonda de reloj más las 10 medidas de C3, y lo que validan es el
# INSTRUMENTO, que sólo cambia cuando un PR toca la sonda (REQ-030 CA-08 (iii)), donde son
# obligatorios. Apagada, cada caso dice SKIP con el motivo y el sitio de su última acreditación
# —nunca PASS— y SIN la marca de inconcluso: no es una sonda que no resolvió, es una que no se
# pidió.
#
# `mat57` y `mide57` son COPIAS LITERALES de `mat37` y `mide37` de 37/2: C3 tiene que medir lo
# MISMO que CA-03 —función, tamaños, `k`, series y el `--prep` byte a byte—, y CA-04 + CA-19 +
# H-04 de REQ-014 impiden compartirlos. Sólo cambia la etiqueta (`c3-…`). Es una copia más del
# residual AN-021-01 (nada comprueba que las copias conserven CA-05 de REQ-021).
CASOS_ESPERADOS_SECCION=7
PISO_AUTONOMO_SECCION=235  # 34 preámbulo (líneas 1-34) + 95 maquinaria compartida duplicada (num57, mat57 con su registro y mide57, copias de 37/2, líneas 35-129) + 106 bloque indivisible mayor (la palanca, las entradas, el envoltorio, los seis controles y C3, líneas 131-236) · REQ-014 CA-18
seccion_nueva "--- 37/7 · los controles de medición del instrumento de CA-08 (ii) y de CA-03, a demanda (REQ-030 CA-07) ---"

num57() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
REPO57="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..` y no cuesta un fork
MAT57_RUTAS='hooks tools'
MAT57_REG=''; MAT57_T0=0; MAT57_REF='-'; MAT57_ETIQ='-'
mat57_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT57_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT57_T0 ))
  # Todo valor que venga de fuera se reduce a UN campo: un espacio dentro de un valor
  # convertía las palabras siguientes en CAMPOS del registro y el juez leía otro `estado`
  # (QA-021-04), y un salto de línea sacaba el registro en dos líneas.
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT57_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT57_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT57_ETIQ ref=$MAT57_REF archivos=$arch"
}
mat57() {   # <referencia> <destino> -> 0 si el árbol quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT57_T0=${EPOCHREALTIME/./}
  MAT57_REF="${ref//[[:space:]]/_}"; MAT57_ETIQ="$MAT57_REF"; MAT57_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO (motivo largo en 37/1).
  [ -e "$REPO57/.git" ] || { mat57_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO57" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat57_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO57" ls-tree -r "$ref" -- $MAT57_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat57_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
  while IFS= read -r l || [ -n "$l" ]; do
    [ -n "$l" ] || continue
    modo="${l%% *}"; l="${l#* }"
    tipo="${l%% *}"; l="${l#* }"
    oid="${l%%$'\t'*}"; ruta="${l#*$'\t'}"
    [ "$tipo" = blob ] || continue
    n=$((n + 1))
    dirs="$dirs $dst/${ruta%/*}"
    paths="$paths$dst/$ruta"$'\n'
    oids+=("$oid"); modos+=("$modo"); rutas+=("$dst/$ruta")
    case "$modo" in *755) ejec="$ejec $dst/$ruta" ;; esac
  done <<< "$lista"
  [ "$n" -ge 1 ] || { mat57_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat57_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO57" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat57_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat57_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  # COMPRUEBA LO QUE DEJÓ, contenido y modo. Un solo `hash-object` para el lote entero.
  procs=$((procs + 1))
  calc="$(git -C "$REPO57" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat57_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat57_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat57_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat57_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat57_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat57_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat57_reg ok - "$n" "$procs"
  return 0
}
# El medidor de CA-03, copia de `mide37`: MISMO `--prep`, MISMO sujeto, 3 series; sólo la
# etiqueta lleva el prefijo `c3-`.
MED57_US=''; MED57_MOTIVO=''; MED57_REG=''
mide57() {   # <lib> <fn> <bytes> <k> -> MED57_US = mínimo de 3 series, en microsegundos
  local lib="$1" fn="$2" n="$3" k="$4" reg
  MED57_US=''; MED57_MOTIVO=''; MED57_REG=''
  if [ ! -r "$lib" ]; then MED57_MOTIVO="no existe $lib"; return 1; fi
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "c3-$fn-$n" \
    --prep "source '$lib' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; l37=''; while [ \${#l37} -lt $n ]; do l37+=\"\$s37\"; done; l37=\"\${l37:0:$n}\"" \
    --sujeto "ARNES_CITA=0; ARNES_CR=0; $fn \"\$l37\"" 2>/dev/null)"
  MED57_REG="$reg"
  if [ -z "$reg" ]; then MED57_MOTIVO='la sonda de reloj no dejó registro'; return 1; fi
  if ! sonda_lee "$reg"; then MED57_MOTIVO="$SONDA_MOTIVO"; return 1; fi
  if [ "${SONDA[estado]}" != ok ]; then
    MED57_MOTIVO="la sonda no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo} (min=${SONDA[min]:-n/a}µs)"; return 1
  fi
  if ! num57 "${SONDA[min]:-}"; then MED57_MOTIVO="la sonda no publicó un mínimo (<${SONDA[min]:-vacío}>)"; return 1; fi
  MED57_US="${SONDA[min]}"
  return 0
}

# La palanca viene de fuera y se escribe a mano: se normaliza —espacios y mayúsculas— y un
# valor que no se reconoce NO enciende los controles, pero se dice en el motivo del SKIP.
_pide57="${ARNES_SONDA_CONTROLES-}"
_pide57="${_pide57#"${_pide57%%[![:space:]]*}"}"
_pide57="${_pide57%"${_pide57##*[![:space:]]}"}"
PIDE57=no; RARO57=''
case "${_pide57,,}" in
  1|si|sí|yes|true|on) PIDE57=si ;;
  ''|0|no|false|off)   : ;;
  *)                   RARO57="$_pide57" ;;
esac
ACRED57='ensayo en CI del 2026-09-26 (rama evidencia/prueba-despacho-2026-09-14, sondas-coste/ensayo-ci/resultados.md §2); la de cada cambio de la sonda, en docs/qa/ de su REQ'
motivo57() {   # <nombre del caso> -> la línea SKIP de un control que no se pidió
  local m="no se pide: control del instrumento, a demanda con ARNES_SONDA_CONTROLES=1; última acreditación: $ACRED57"
  [ -z "$RARO57" ] || m="ARNES_SONDA_CONTROLES=<$RARO57> no se reconoce y NO enciende los controles; $m"
  echo "  SKIP  $1  $m"
}
mkreq_r REQ-100 no aprobado n/a estandar     # el mismo REQ real de 6 líneas que 37/5
{ printf '# REQ-200\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n'
  _i57=1; while [ "$_i57" -le 195 ]; do printf 'Campo%03d: valor de relleno de cabecera\n' "$_i57"; _i57=$((_i57+1)); done
} > "$PROJ/requirements/REQ-200.md"
# El envoltorio sólo de pruebas: duerme la demora pedida (0 = nada) y ejecuta el MISMO hook.
WRAP57="$RAIZ/lento57-$BASHPID.sh"
printf '#!/usr/bin/env bash\n[ "${1:-0}" = 0 ] || sleep "$1"\nexec bash "%s/guard-completado.sh"\n' "$HOOKS_DIR" > "$WRAP57"
chmod +x "$WRAP57"
JSON57="$RAIZ/json57-$BASHPID.json"
for _cual57 in REQ-100 REQ-200; do
  _etq57="un REQ real de 6 líneas"; _d57=0.040
  [ "$_cual57" = REQ-200 ] && { _etq57="una cabecera de 200 líneas"; _d57=0.100; }
  A57="CLAUDE_PROJECT_DIR='$PROJ' bash '$HOOKS_DIR/guard-completado.sh' < '$JSON57' >/dev/null 2>&1"
  if [ "$PIDE57" = si ]; then
    jq -n --arg fp "$PROJ/requirements/$_cual57.md" \
      '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.NADA,
        tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$JSON57" 2>/dev/null
  fi
  for _ctl57 in I W0 WD; do
    case "$_ctl57" in
      I)  B57="$A57"; nom57="REQ-030 CA-07 control I ($_etq57): sujetos idénticos, razón verdadera 1,0" ;;
      W0) B57="CLAUDE_PROJECT_DIR='$PROJ' bash '$WRAP57' 0 < '$JSON57' >/dev/null 2>&1"
          nom57="REQ-030 CA-07 control W0 ($_etq57): envoltorio de pruebas con demora 0" ;;
      WD) B57="CLAUDE_PROJECT_DIR='$PROJ' bash '$WRAP57' $_d57 < '$JSON57' >/dev/null 2>&1"
          nom57="REQ-030 CA-07 control WD ($_etq57): envoltorio de pruebas con demora fija de ${_d57}s por llamada" ;;
    esac
    if [ -n "$FILTRO" ] && ! printf '%s' "$nom57" | grep -qi -- "$FILTRO"; then continue; fi
    if [ "$PIDE57" != si ]; then motivo57 "$nom57"; continue; fi
    if [ ! -s "$JSON57" ]; then echo "  SKIP  $nom57  [INCONCLUSO] el JSON de $_cual57 salió vacío: el hook no habría recibido entrada"; continue; fi
    # La referencia va en el brazo `a` y este árbol en el `b`, como en el ensayo: la razón es
    # referencia / este árbol, así que una demora añadida la sube por encima del techo.
    lista57=''; _t57=${EPOCHREALTIME/./}
    for ((_n57 = 1; _n57 <= SONDA_COSTE_R; _n57++)); do
      _reg57="$("$UTIL_DIR/sonda-reloj.sh" --k 4 --r 6 --etiqueta "control-$_cual57-$_ctl57-$_n57" \
        --sujeto-a "$B57" --sujeto-b "$A57" 2>/dev/null)"
      if sonda_lee "$_reg57" && [ "${SONDA[estado]}" = ok ]; then
        lista57+="${SONDA[min_a]:-x}:${SONDA[min2_a]:-x}:${SONDA[min_b]:-x}:${SONDA[min2_b]:-x} "
      else
        lista57+="x:x:x:x "   # no midió: entra como NO RESUELTA
      fi
    done
    _t57=$(( ${EPOCHREALTIME/./} - _t57 )); printf -v _t57 '%d,%01d s' "$(( _t57 / 1000000 ))" "$(( _t57 % 1000000 / 100000 ))"
    sal57="$(sonda_juez_razon "$nom57" 1250 "$lista57")"
    ev57="${sal57#"  "????"  $nom57  "}"   # lo que el juez publicó tras el nombre
    case "$_ctl57:$sal57" in
      I:"  PASS  "*|W0:"  PASS  "*) echo "  PASS  $nom57  el juez no dio aviso ($_t57): $ev57" ;;
      I:"  FAIL  "*|W0:"  FAIL  "*) echo "  FAIL  $nom57  FALSO AVISO: el juez dijo FAIL sobre una razón que no cambió ($_t57): $ev57" ;;
      WD:"  FAIL  "*)               echo "  PASS  $nom57  el juez vio la demora añadida ($_t57): $ev57" ;;
      WD:"  PASS  "*)               echo "  FAIL  $nom57  el juez NO vio la demora añadida ($_t57): $ev57" ;;
      WD:"  SKIP  "*)               echo "  SKIP  $nom57  [INCONCLUSO] el juez se abstuvo y eso NO acredita detección ($_t57): ${ev57#\[INCONCLUSO\] }" ;;
      *:"  SKIP  "*)                echo "  SKIP  $nom57  [INCONCLUSO] el juez se abstuvo ($_t57): ${ev57#\[INCONCLUSO\] }" ;;
      *)                            echo "  FAIL  $nom57  el juez no emitió una línea reconocible: <${sal57:0:120}>" ;;
    esac
  done
done
rm -f "$JSON57" "$WRAP57"

# ---------- C3 · EL INSTRUMENTO DE CA-03 VE EL ÁRBOL CUADRÁTICO (CA-07 (g), SEC-108) ----------
# Mismo cociente que CA-03 sobre v1.32.1 —70 000 → 140 000 bytes, k = 20, `SONDA_COSTE_R`
# repeticiones, resolución de CA-03 (a)—, juzgado por `sonda_juez_control_c3` (corredor). No es
# la calibración interna de 37/2, que sigue siendo precondición del caso real: es una medición
# APARTE, con su propio veredicto. Presupuesto y resultados esperados fijados en CA-07 (e) y (g)
# ANTES de ejecutarlo; la regla «ningún FAIL en 3 corridas y PASS en al menos 1» la aplican QA y
# seguridad, no esta sección.
nom57="REQ-030 CA-07 control C3 (instrumento de CA-03): el cociente de duplicación de v1.32.1 con k=20 supera 2,6×"
if [ -z "$FILTRO" ] || printf '%s' "$nom57" | grep -qi -- "$FILTRO"; then
  if [ "$PIDE57" != si ]; then
    motivo57 "$nom57"
  else
    HER57="$RAIZ/her57-321-$BASHPID"; SINBASE57=''; PARES57=''; NOMIDIO57=''
    if ! mat57 v1.32.1 "$HER57"; then
      SINBASE57='tag ausente'
      case "$MAT57_REG" in *motivo=*) SINBASE57="${MAT57_REG#*motivo=}"; SINBASE57="${SINBASE57%% *}" ;; esac
    else
      _t57=${EPOCHREALTIME/./}
      for ((_n57 = 1; _n57 <= SONDA_COSTE_R; _n57++)); do
        h1_57=''; h2_57=''
        mide57 "$HER57/hooks/lib.sh" arnes_sin_cita 70000  20 && h1_57="$MED57_US" || NOMIDIO57+="S #$_n57: ${MED57_MOTIVO//$'\n'/ }; "
        mide57 "$HER57/hooks/lib.sh" arnes_sin_cita 140000 20 && h2_57="$MED57_US" || NOMIDIO57+="2S #$_n57: ${MED57_MOTIVO//$'\n'/ }; "
        PARES57+="${h1_57:-x}:${h2_57:-x} "   # la que no midió entra como NO RESUELTA
      done
      _t57=$(( ${EPOCHREALTIME/./} - _t57 )); printf -v _t57 '%d,%01d s' "$(( _t57 / 1000000 ))" "$(( _t57 % 1000000 / 100000 ))"
      NOMIDIO57="(${_t57})${NOMIDIO57:+ · la sonda no midió: $NOMIDIO57}"
    fi
    sal57="$(sonda_juez_control_c3 "$nom57" 2600 "$PARES57" "$SINBASE57")"
    printf '%s%s\n' "$sal57" "${NOMIDIO57:+ $NOMIDIO57}"
    rm -rf "$HER57"
  fi
fi
