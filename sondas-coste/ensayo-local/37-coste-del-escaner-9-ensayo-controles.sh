#!/usr/bin/env bash
# ENSAYO LOCAL (2026-09-25, autorizado por el propietario): CONTROLES del procedimiento propuesto
# para CA-08 (ii). Vive SÓLO en el árbol de ensayo; no es parte del banco. Tres controles por
# entrada (REQ-100 de 6 líneas, REQ-200 de 200 líneas), en este orden fijo:
#   I  — sujetos IDÉNTICOS (este árbol contra este árbol): razón verdadera 1,0. Un FAIL es un
#        falso aviso de regresión.
#   W0 — este árbol contra un envoltorio con demora 0 que exec el mismo hook: mide el coste del
#        envoltorio; tampoco puede dar FAIL.
#   WD — este árbol contra el envoltorio con demora FIJADA ANTES (D100=40 ms, D200=100 ms por
#        llamada): detecta una DEMORA AÑADIDA, no una regresión interna del escáner. Se espera FAIL.
# El juez es EXACTAMENTE el de la propuesta (se extrae de 37/5 parcheado), con el mismo presupuesto.
CASOS_ESPERADOS_SECCION=6
PISO_AUTONOMO_SECCION=60
seccion_nueva "--- 37/9 · ENSAYO: controles del procedimiento propuesto (idénticos, envoltorio 0, demora fija) ---"
num47() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
SER47=6; K47=4; TECHO47=1250; REP47=${ARNES_SONDA_REP:-5}; MINRES47=3
PASS=${PASS:-0}; FAIL=${FAIL:-0}
eval "$(sed -n '/^veredicto08r_47()/,/^}/p' "$SEC_DIR/37-coste-del-escaner-5-el-camino-normal.sh")"
mkreq_r REQ-100 no aprobado n/a estandar
{ printf '# REQ-200\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n'
  _i=1; while [ "$_i" -le 195 ]; do printf 'Campo%03d: valor de relleno de cabecera\n' "$_i"; _i=$((_i+1)); done
} > "$PROJ/requirements/REQ-200.md"
WRAP49="$RAIZ/lento49-$BASHPID.sh"
printf '#!/usr/bin/env bash\n[ "${1:-0}" = 0 ] || sleep "$1"\nexec bash "%s/guard-completado.sh"\n' "$HOOKS_DIR" > "$WRAP49"; chmod +x "$WRAP49"
JSON49="$RAIZ/json49-$BASHPID.json"
for _cual in REQ-100 REQ-200; do
  jq -n --arg fp "$PROJ/requirements/$_cual.md" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.NADA,tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$JSON49"
  _etq="un REQ real de 6 líneas"; _D=0.040; [ "$_cual" = REQ-200 ] && { _etq="una cabecera de 200 líneas"; _D=0.100; }
  A49="CLAUDE_PROJECT_DIR='$PROJ' bash '$HOOKS_DIR/guard-completado.sh' < '$JSON49' >/dev/null 2>&1"
  for _ctl in I W0 WD; do
    case "$_ctl" in
      I)  B49="$A49"; nom="ENSAYO control I ($_etq): sujetos idénticos, razón verdadera 1,0 — nunca FAIL" ;;
      W0) B49="CLAUDE_PROJECT_DIR='$PROJ' bash '$WRAP49' 0 < '$JSON49' >/dev/null 2>&1"; nom="ENSAYO control W0 ($_etq): envoltorio con demora 0 — nunca FAIL" ;;
      WD) B49="CLAUDE_PROJECT_DIR='$PROJ' bash '$WRAP49' $_D < '$JSON49' >/dev/null 2>&1"; nom="ENSAYO control WD ($_etq): envoltorio con demora fija ${_D}s por llamada — se espera FAIL (detecta DEMORA AÑADIDA, no regresión interna)" ;;
    esac
    lista49=''
    for _n in $(seq 1 "$REP47"); do
      _t0=${EPOCHREALTIME/./}
      _reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$K47" --r "$SER47" --etiqueta "ensayo-$_cual-$_ctl-$_n" --sujeto-a "$B49" --sujeto-b "$A49" 2>/dev/null)"
      _t1=${EPOCHREALTIME/./}
      if sonda_lee "$_reg" && [ "${SONDA[estado]}" = ok ]; then lista49+="${SONDA[min_a]:-x}:${SONDA[min2_a]:-x}:${SONDA[min_b]:-x}:${SONDA[min2_b]:-x} "; else lista49+="x:x:x:x "; fi
      echo "  ·   ENSAYO dato $_cual $_ctl rep=$_n us=$(( _t1 - _t0 )) reg=[${lista49##* }]" | sed 's/reg=\[\]/reg=[vacio]/'
    done
    veredicto08r_47 "$nom" "$lista49"
  done
done
rm -f "$JSON49" "$WRAP49"
