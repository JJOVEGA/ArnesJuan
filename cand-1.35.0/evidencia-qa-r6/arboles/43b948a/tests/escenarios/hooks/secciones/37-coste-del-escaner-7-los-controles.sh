# ---------- 37 (7) · LOS CONTROLES DE MEDICIÓN DEL INSTRUMENTO DE CA-08 (ii) ----------
# REQ-030 CA-07. Las pruebas DE MEDICIÓN del procedimiento (las SINTÉTICAS del juez son 37/6).
# Por cada entrada —el REQ real de 6 líneas y la cabecera de 200— tres controles, cada uno con
# el MISMO presupuesto (`SONDA_COSTE_R`) y el MISMO juez que decide CA-08 (ii)
# (`sonda_juez_razon`, del corredor), en este orden fijo:
#   I  — este árbol contra sí mismo: razón verdadera 1,0. Si el juez dice FAIL es un FALSO AVISO.
#   W0 — contra un envoltorio SÓLO DE PRUEBAS con demora 0 que ejecuta el mismo hook: tampoco
#        puede dar FAIL.
#   WD — contra ese envoltorio con una demora FIJA por llamada (40 ms en 6 líneas, 100 ms en
#        200), sin recalibrar. El caso es PASS si el juez dice FAIL (vio la demora añadida).
# El control del instrumento de CA-03 (C3) NO vive aquí: vive en 37/2 y juzga la misma
# calibración que decide CA-03 (decisión D del propietario; QA-030-07).
#
# EL FAIL ESPERADO SE COMPRUEBA COMO ESPERADO y no deja el banco en rojo: en el ensayo el WD
# ponía el check rojo a propósito; aquí el caso traduce lo que dijo el juez. Un INCONCLUSO de
# WD NO acredita detección: sale INCONCLUSO, marcado `[instrumento]` y contado. Y detectar una
# demora añadida es un control DE LA PRUEBA, no su finalidad: no garantiza detectar una
# regresión interna del escáner, cuyo control sigue siendo la calibración contra v1.32.1 (37/2).
#
# A DEMANDA, con `ARNES_SONDA_CONTROLES=1`, como 37/4 con `ARNES_COSTE_RUTA_CRITICA=1`: son
# 30 invocaciones de la sonda de reloj por corrida (mediana medida 4,5 s cada una en local) y
# lo que validan es el INSTRUMENTO, que sólo cambia cuando un PR toca la sonda (REQ-030 CA-08
# (iii)), donde son obligatorios. Apagada, cada caso dice SKIP con el motivo y el sitio de su
# última acreditación —nunca PASS— y SIN la marca de inconcluso: no es una sonda que no
# resolvió, es una que no se pidió.
CASOS_ESPERADOS_SECCION=6  # 6 → 7 en la vuelta 3 (C3) y 7 → 6 por la decisión D: C3 se muda a 37/2
PISO_AUTONOMO_SECCION=104  # 29 preámbulo (líneas 1-29) + 0 maquinaria compartida duplicada (el juez y la sonda viven en el corredor y en tests/util/) + 75 bloque indivisible mayor (la palanca, las entradas, el envoltorio y el bucle de los seis controles, líneas 30-104) · REQ-014 CA-18
seccion_nueva "--- 37/7 · los controles de medición del instrumento de CA-08 (ii), a demanda (REQ-030 CA-07) ---"

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
    if [ "$PIDE57" != si ]; then
      mot57="no se pide: control del instrumento, a demanda con ARNES_SONDA_CONTROLES=1; última acreditación: $ACRED57"
      [ -z "$RARO57" ] || mot57="ARNES_SONDA_CONTROLES=<$RARO57> no se reconoce y NO enciende los controles; $mot57"
      echo "  SKIP  $nom57  $mot57"; continue
    fi
    if [ ! -s "$JSON57" ]; then echo "  SKIP  $nom57  [INCONCLUSO] [instrumento] el JSON de $_cual57 salió vacío: el hook no habría recibido entrada"; continue; fi
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
    # El juez de CA-08 (ii) rotula su abstención como RENDIMIENTO; aquí es un CONTROL, así que
    # esa marca se retira y el caso se rotula INSTRUMENTO (REQ-030 CA-05 (a-bis)).
    ev57="${ev57#\[INCONCLUSO\] \[rendimiento\] }"
    case "$_ctl57:$sal57" in
      I:"  PASS  "*|W0:"  PASS  "*) echo "  PASS  $nom57  el juez no dio aviso ($_t57): $ev57" ;;
      I:"  FAIL  "*|W0:"  FAIL  "*) echo "  FAIL  $nom57  FALSO AVISO: el juez dijo FAIL sobre una razón que no cambió ($_t57): $ev57" ;;
      WD:"  FAIL  "*)               echo "  PASS  $nom57  el juez vio la demora añadida ($_t57): $ev57" ;;
      WD:"  PASS  "*)               echo "  FAIL  $nom57  el juez NO vio la demora añadida ($_t57): $ev57" ;;
      WD:"  SKIP  "*)               echo "  SKIP  $nom57  [INCONCLUSO] [instrumento] el juez se abstuvo y eso NO acredita detección ($_t57): $ev57" ;;
      *:"  SKIP  "*)                echo "  SKIP  $nom57  [INCONCLUSO] [instrumento] el juez se abstuvo ($_t57): $ev57" ;;
      *)                            echo "  FAIL  $nom57  el juez no emitió una línea reconocible: <${sal57:0:120}>" ;;
    esac
  done
done
rm -f "$JSON57" "$WRAP57"
