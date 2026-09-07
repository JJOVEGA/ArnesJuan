#!/usr/bin/env bash
# Autoprueba del CORREDOR del banco (REQ-014, 1.32.0).
#
# El banco certifica los hooks; esto certifica al banco. Son dos cosas distintas y por eso
# viven en dos puntos de entrada distintos: los 683 casos de `run.sh` miden el mecanismo de
# runtime, y su inventario tiene que quedar IDÉNTICO al de v1.31.0 (REQ-014 CA-12) — meter
# aquí dentro los casos que vigilan la estructura nueva rompería justo esa comparación.
#
# Qué vigila: el descubrimiento (orden y coste), el cuadre por archivo, el canario de
# sección y las invariantes de la partición. Todo contra directorios de secciones
# SINTÉTICOS (`ARNES_SECCIONES_DIR`), nunca contra el banco de verdad.
#
# Fail-before: apuntando `ARNES_CORREDOR` a un `run.sh` anterior a 1.32.0 tienen que
# fallar los casos de estructura; si pasan, no están probando lo que crees.
#   ARNES_CORREDOR=/ruta/a/v1.31.0/tests/escenarios/hooks/run.sh bash autoprueba-corredor.sh
set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORREDOR="${ARNES_CORREDOR:-$AQUI/run.sh}"
SECC_REAL="$AQUI/secciones"
PASS=0; FAIL=0
# Cuántos casos corre esta autoprueba. Se comprueba al final: la misma invariante que
# el banco exige a cada archivo de sección, aplicada al artefacto que certifica al
# corredor (QA 1.32.0, H-06).
AUTOPRUEBA_CASOS_ESPERADOS=73

command -v jq >/dev/null 2>&1 || { echo "SKIP: jq no instalado"; exit 0; }

RAIZ="$(mktemp -d)"
trap 'rm -rf "$RAIZ"' EXIT

ok()  { echo "  PASS  $1"; PASS=$((PASS + 1)); }
ko()  { echo "  FAIL  $1  $2"; FAIL=$((FAIL + 1)); }
# igual <nombre> <esperado> <obtenido>
igual() { if [ "$2" = "$3" ]; then ok "$1"; else ko "$1" "esperado=<$2> obtenido=<$3>"; fi; }
# casa <nombre> <regex> <texto>
casa() {
  if printf '%s' "$3" | grep -Eq -- "$2"; then ok "$1"
  else ko "$1" "no casa /$2/ en <$(printf '%s' "$3" | tr '\n' '|' | head -c 300)>"; fi
}
# no_casa <nombre> <regex> <texto>
no_casa() {
  if printf '%s' "$3" | grep -Eq -- "$2"; then ko "$1" "casó /$2/ y no debía"; else ok "$1"; fi
}

# --- secciones sintéticas ------------------------------------------------------
# nuevo_dir -> deja DIRSEC con un directorio de secciones vacío
nuevo_dir() { DIRSEC="$(mktemp -d "$RAIZ/sec.XXXXXX")"; }
# pon_seccion <archivo> <casos declarados o "-"> <cuerpo>
pon_seccion() {
  {
    [ "$2" = "-" ] || printf 'CASOS_ESPERADOS_SECCION=%s\n' "$2"
    printf '%s\n' "$3"
  } > "$DIRSEC/$1"
}
# corre_corredor [args...] -> deja SALIDA y RC
SALIDA=''; RC=0
corre_corredor() {
  SALIDA="$(ARNES_SECCIONES_DIR="$DIRSEC" ARNES_JOBS=4 bash "$CORREDOR" "$@" 2>&1)"; RC=$?
}

echo "Autoprueba del corredor ($CORREDOR):"

# --- CA-02 · descubrimiento determinista y en orden lexicográfico --------------
D1="$(ARNES_SOLO_DESCUBRIR=1 bash "$CORREDOR" 2>&1)"; RCD=$?
D2="$(ARNES_SOLO_DESCUBRIR=1 bash "$CORREDOR" 2>&1)"
igual "CA-02 el descubrimiento sale 0 y dice algo" "0-si" \
  "$RCD-$([ -n "$D1" ] && echo si || echo no)"
igual "CA-02 dos corridas descubren exactamente lo mismo" "iguales" \
  "$([ "$D1" = "$D2" ] && echo iguales || echo distintos)"
igual "CA-02 el orden es el lexicográfico por nombre de archivo (LC_ALL=C)" "ordenado" \
  "$([ "$D1" = "$(printf '%s\n' "$D1" | LC_ALL=C sort)" ] && echo ordenado || echo desordenado)"
igual "CA-02 descubre los mismos archivos que hay en secciones/" "iguales" \
  "$([ "$(printf '%s\n' "$D1" | LC_ALL=C sort)" = "$(cd "$SECC_REAL" && LC_ALL=C ls -1 [0-9][0-9]-*.sh)" ] && echo iguales || echo distintos)"

# --- CA-21 · el descubrimiento no paga forks ----------------------------------
# `find`, `ls` y `sort` instrumentados y primeros en el PATH: si el corredor los llama,
# dejan rastro. En Windows cada fork cuesta entre 1,2 y 6 s y esto corre en cada vuelta.
BIN="$RAIZ/bin-instr"; mkdir -p "$BIN"
for prog in find ls sort; do
  real="$(command -v "$prog")"
  { printf '#!/usr/bin/env bash\n'
    printf 'printf "%%s\\n" "%s" >> "%s/llamadas"\n' "$prog" "$BIN"
    printf 'exec "%s" "$@"\n' "$real"
  } > "$BIN/$prog"
  chmod +x "$BIN/$prog"
done
: > "$BIN/llamadas"
PATH="$BIN:$PATH" ARNES_SOLO_DESCUBRIR=1 bash "$CORREDOR" >/dev/null 2>&1
igual "CA-21 el descubrimiento no arranca find, ls ni sort" "0" \
  "$(wc -l < "$BIN/llamadas" | tr -d ' ')"
# Control obligatorio: una sonda que no puede registrar nada no prueba que no se llamó a
# nadie, prueba que la sonda no está puesta.
: > "$BIN/llamadas"
PATH="$BIN:$PATH" bash -c 'ls >/dev/null; sort </dev/null >/dev/null'
igual "CA-21 control: la sonda SÍ registra cuando se llama a ls y a sort" "2" \
  "$(wc -l < "$BIN/llamadas" | tr -d ' ')"

# --- CA-03 · añadir y quitar una sección sin tocar el corredor -----------------
MD5_ANTES="$(md5sum "$CORREDOR" | cut -d' ' -f1)"
nuevo_dir
pon_seccion "01-una.sh" 1 'echo "  PASS  caso de la seccion UNA"; PASS=$((PASS+1))'
pon_seccion "02-otra.sh" 1 'echo "  PASS  caso de la seccion OTRA"; PASS=$((PASS+1))'
corre_corredor
casa "CA-03 una sección nueva corre sin editar run.sh (la primera)" 'caso de la seccion UNA' "$SALIDA"
casa "CA-03 una sección nueva corre sin editar run.sh (la segunda)" 'caso de la seccion OTRA' "$SALIDA"
igual "CA-03 y la vuelta sale 0" "0" "$RC"
rm -f "$DIRSEC/02-otra.sh"
corre_corredor
no_casa "CA-03 una sección retirada desaparece de la vuelta" 'caso de la seccion OTRA' "$SALIDA"
igual "CA-03 el corredor no cambió ni un byte en todo esto" "$MD5_ANTES" \
  "$(md5sum "$CORREDOR" | cut -d' ' -f1)"

# --- CA-07 · un archivo sin su número declarado ABORTA y se nombra -------------
nuevo_dir
pon_seccion "01-buena.sh" 1 'echo "  PASS  caso bueno"; PASS=$((PASS+1))'
pon_seccion "02-sin-numero.sh" - 'echo "  PASS  caso huérfano"; PASS=$((PASS+1))'
corre_corredor
casa "CA-07 sin CASOS_ESPERADOS_SECCION el corredor ABORTA" 'ABORT' "$SALIDA"
casa "CA-07 el ABORT nombra el archivo que no lo declara" '02-sin-numero\.sh' "$SALIDA"
igual "CA-07 y la vuelta sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"

# --- CA-08 · el cuadre por archivo dice CUÁL y CUÁNTO --------------------------
nuevo_dir
pon_seccion "01-cuadra.sh" 1 'echo "  PASS  caso que cuadra"; PASS=$((PASS+1))'
pon_seccion "02-le-falta-uno.sh" 5 'echo "  PASS  unico caso"; PASS=$((PASS+1))'
corre_corredor
casa "CA-08 el ABORT nombra el archivo descuadrado" '02-le-falta-uno\.sh' "$SALIDA"
casa "CA-08 y dice la diferencia (declarados vs ejecutados)" 'declara 5 casos y ejecutó 1' "$SALIDA"
no_casa "CA-08 y NO acusa al archivo que sí cuadra" '01-cuadra\.sh.*declara' "$SALIDA"
igual "CA-08 y la vuelta sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"

# --- CA-10 · canario de sección: un subshell que muere no se traga -------------
nuevo_dir
pon_seccion "01-viva.sh" 1 'echo "  PASS  caso de la seccion viva"; PASS=$((PASS+1))'
pon_seccion "02-muere.sh" 2 'echo "  PASS  caso antes de morir"; PASS=$((PASS+1))
exit 7
echo "  PASS  caso que nunca llega"; PASS=$((PASS+1))'
corre_corredor
casa "CA-10 el ABORT nombra el archivo cuyo subshell murió" '02-muere\.sh' "$SALIDA"
casa "CA-10 y dice su código de salida" 'código de salida 7' "$SALIDA"
casa "CA-10 y lo distingue de una sección de cero casos" 'No se cuenta como sección de cero casos' "$SALIDA"
igual "CA-10 y la corrida entera sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"
casa "CA-10 la sección viva sigue habiendo corrido" 'caso de la seccion viva' "$SALIDA"

# --- CA-04 · un ayudante definido dentro de una sección no cruza a otra --------
# Y cuando eso pasa, el banco lo dice a gritos: no se convierte en un caso ausente.
nuevo_dir
pon_seccion "01-presta.sh" 1 'ayudante_prestado() { echo "  PASS  $1"; PASS=$((PASS+1)); }
ayudante_prestado "caso del que presta"'
pon_seccion "02-toma-prestado.sh" 1 'ayudante_prestado "caso del que toma prestado"'
corre_corredor
no_casa "CA-04 el ayudante de otra sección no existe (el caso no se ejecuta)" \
  'caso del que toma prestado' "$SALIDA"
casa "CA-04 y el corredor lo reporta como fallo ruidoso, nombrando el archivo" \
  '02-toma-prestado\.sh' "$SALIDA"
igual "CA-04 y la vuelta sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"
# --- H-01 · UN solo sitio para el conjunto de ayudantes, y que sea cierto -----------
# QA 1.32.0 (H-01): CA-04 apuntaba al README del banco como sitio único del conjunto, y
# el README no lo declaraba —tenía una lista de SEIS, escrita a mano, con «todos» delante,
# que ya era falsa el mismo día: `corre`, `ver_corre` y `mide_hook` ejecutan un hook y no
# estaban—. Peor: el README decía lo contrario que el criterio (él apuntaba al corredor).
# Dos sitios y ninguno cierto.
#
# El write-back del analista resolvió por la vía que la máquina puede comprobar: el sitio
# único es EL CORREDOR, y CA-04 escribe que no debe haber una segunda lista en ninguna
# otra parte. Así que aquí NO se exige que el README enumere el conjunto —se exige lo
# contrario—, y se vigilan las dos formas en que el README puede volver a mentir:
#   (a) nombrar un ayudante que el corredor no define (puntero muerto), y
#   (b) volver a escribir la lista cerrada, que es lo que envejeció.
# `ARNES_README_BANCO` existe por lo mismo que `ARNES_CORREDOR`: para poder medir el
# fail-before de estos casos contra el README anterior sin tocar el del árbol.
README_BANCO="${ARNES_README_BANCO:-$AQUI/README.md}"
awk 'index($0, "source \"${SECCIONES[") { exit }
     /^[A-Za-z_][A-Za-z_0-9]*\(\)[ \t]*\{/ { n = $0; sub(/\(\).*/, "", n); print n }' \
  "$CORREDOR" | LC_ALL=C sort > "$RAIZ/ayudantes.txt"
AY_CORREDOR="$(tr '\n' ' ' < "$RAIZ/ayudantes.txt")"
# (a) todo nombre entre acentos graves del README que sea un ayudante del corredor, existe;
#     y ninguno de los que nombra ha dejado de existir. Se listan los que NO existen.
FANTASMAS="$(awk '
  NR == FNR { real[$1] = 1; next }
  {
    n = split($0, t, "`")
    for (i = 2; i <= n; i += 2)
      if (t[i] ~ /^[a-z_][a-z_0-9]*$/ && t[i] ~ /(check|corre|emite|mkreq|setcfg|setgates|json_no_vacio|diag|mide_hook|seccion_nueva|cronometra)/ && !(t[i] in real))
        malos[t[i]] = 1
  }
  END { for (k in malos) printf "%s ", k }' "$RAIZ/ayudantes.txt" "$README_BANCO")"
igual "H-01 el README no nombra ningún ayudante que el corredor ya no defina" "" "$FANTASMAS"
# (b) ninguna línea del README reenumera el conjunto: 4 o más ayudantes distintos en la
#     misma línea es la forma (a) que REQ-012 CA-02 prohíbe, y es exactamente cómo estaba
#     escrita la lista que envejeció. Tres o menos son ejemplos, que CA-04 sí admite.
RENUMERA="$(awk '
  NR == FNR { real[$1] = 1; next }
  {
    c = 0; delete visto
    n = split($0, t, "`")
    for (i = 2; i <= n; i += 2)
      if ((t[i] in real) && !(t[i] in visto)) { visto[t[i]] = 1; c++ }
    if (c >= 4) printf "linea %d con %d ayudantes; ", FNR, c
  }' "$RAIZ/ayudantes.txt" "$README_BANCO")"
igual "H-01 y ninguna línea del README reenumera el conjunto (el sitio único es el corredor)" "" "$RENUMERA"
# La invariante 1, aplicada AL CORREDOR y no sólo a las secciones: el README afirma que
# todo ayudante compartido que dicta PASS/FAIL lleva guarda. Se comprueba, no se cree.
SIN_GUARDA="$(awk 'index($0, "source \"${SECCIONES[") { exit }
  function cierra() {
    if (fn == "") return
    if (ver && !gua) printf "%s ", fn
    fn = ""
  }
  /^[A-Za-z_][A-Za-z_0-9]*\(\)[ \t]*\{/ { cierra(); fn = $0; sub(/\(\).*/, "", fn); ver = 0; gua = 0 }
  fn != "" {
    if ($0 ~ /  (PASS|FAIL)  /) ver = 1
    if ($0 ~ /json_no_vacio/ || $0 ~ /-[zn] +"?\$[{]?[a-z_]/) gua = 1
    if ($0 ~ /^\}/) cierra()
  }
  END { cierra() }' "$CORREDOR")"
igual "H-01 en el corredor, todo ayudante que dicta PASS/FAIL lleva su guarda de vacío" "" "$SIN_GUARDA"
# Y que el conjunto derivado se VE de verdad desde dentro de una sección: la lista no se
# escribe aquí tampoco, se le pasa a la sección sintética la que acaba de derivarse.
nuevo_dir
pon_seccion "01-ve-los-ayudantes.sh" 1 "faltan=\"\"
for ayudante in $AY_CORREDOR; do
  declare -F \"\$ayudante\" >/dev/null || faltan=\"\$faltan \$ayudante\"
done
if [ -z \"\$faltan\" ]; then echo \"  PASS  ayudantes compartidos vistos\"; PASS=\$((PASS+1))
else echo \"  FAIL  faltan ayudantes compartidos:\$faltan\"; FAIL=\$((FAIL+1)); fi"
corre_corredor
casa "CA-04 los ayudantes compartidos del corredor SÍ se ven desde una sección" \
  'PASS  ayudantes compartidos vistos' "$SALIDA"
igual "CA-04 y la sección que sólo usa los compartidos sale 0" "0" "$RC"

# --- CA-06 · quien juzga un hook dentro de una sección lleva su guarda ---------
nuevo_dir
pon_seccion "01-sin-guarda.sh" 1 'mal_check() {
  local out
  out="$(printf "%s" "$2" | "$HOOKS_DIR/guard-codigo.sh")"
  echo "  PASS  $1"; PASS=$((PASS+1))
}
mal_check "caso sin guarda" ""'
corre_corredor
casa "CA-06 un ayudante de sección que juzga un hook sin guarda ABORTA" \
  'invariante 1 rota' "$SALIDA"
casa "CA-06 el ABORT nombra el archivo y la función" '01-sin-guarda\.sh.*mal_check' "$SALIDA"
# QA 1.32.0 (H-03): la evasión medida — el mismo ayudante PARTIDO EN DOS. La primera
# versión del control exigía que ejecutar el hook y dictar el veredicto ocurrieran en la
# misma función, y escribir dos funciones lo rodeaba: `1 PASS, 0 FAIL`, rc 0, con un caso
# de entrada vacía en verde. Un control que se evade sin ocultar nada no es un control.
nuevo_dir
pon_seccion "01-evasion-dos-funciones.sh" 1 'mi_corre() { printf "%s" "$2" | "$HOOKS_DIR/guard-codigo.sh" 2>/dev/null; }
mi_check() { local out; out="$(mi_corre "$1" "")"; echo "  PASS  $1"; PASS=$((PASS+1)); }
mi_check "caso que juzga un hook con entrada VACIA"'
corre_corredor
casa "CA-06 partir el ayudante en dos (ejecuta una, juzga otra) NO evade el control" \
  'invariante 1 rota' "$SALIDA"
casa "CA-06 el ABORT nombra la función que dicta el veredicto, no la que ejecuta" \
  '01-evasion-dos-funciones\.sh.*mi_check' "$SALIDA"
no_casa "CA-06 y el caso sin guarda no llegó a salir en verde" \
  'PASS  caso que juzga un hook con entrada VACIA' "$SALIDA"
igual "CA-06 y la vuelta sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"
# Control: si la guarda vive en el eslabón que EJECUTA, la cadena está guardada y no se
# aborta. Sin esto, el arreglo podría estar prohibiendo partir funciones, que no es la regla.
nuevo_dir
pon_seccion "01-guarda-en-el-otro-eslabon.sh" 1 'mi_corre() {
  json_no_vacio "$1" "$2" || return 1
  printf "%s" "$2" | "$HOOKS_DIR/guard-codigo.sh" 2>/dev/null
}
mi_check() { local out; out="$(mi_corre "$1" "$2")" || { FAIL=$((FAIL+1)); return 0; }; echo "  PASS  $1"; PASS=$((PASS+1)); }
mi_check "caso con la guarda en el eslabon que ejecuta" "$(emite_edit "$PROJ/docs/x.md" "" "" "hola")"'
corre_corredor
igual "CA-06 control: la guarda en el eslabón que ejecuta basta (ni ABORT ni rojo)" "0-si" \
  "$RC-$(printf '%s' "$SALIDA" | grep -q 'caso con la guarda en el eslabon' && echo si || echo no)"

nuevo_dir
pon_seccion "01-con-guarda.sh" 1 'bien_check() {
  local out
  json_no_vacio "$1" "$2" || { FAIL=$((FAIL+1)); return 0; }
  out="$(printf "%s" "$2" | "$HOOKS_DIR/guard-codigo.sh")"
  echo "  PASS  $1"; PASS=$((PASS+1))
}
bien_check "caso con guarda" "$(emite_edit "$PROJ/docs/x.md" "" "" "hola")"'
corre_corredor
igual "CA-06 control: con la guarda puesta, ni ABORT ni ruido" "0-si" \
  "$RC-$(printf '%s' "$SALIDA" | grep -q 'caso con guarda' && echo si || echo no)"

# --- H-11 · «guarda equivalente» es una PROPIEDAD, no una lista de tres literales --
# QA 1.32.0 (H-11): la guarda se reconocía por tres cadenas fijas, una de ellas atada al
# NOMBRE de la variable (`-z "$out"`). La misma guarda con la variable llamada `o`
# provocaba ABORT sobre código correcto. Un falso positivo en un control que aborta la
# vuelta entera es un control que alguien acaba quitando.
nuevo_dir
pon_seccion "01-guarda-con-otro-nombre.sh" 1 'mi_corre() {
  local o
  o="$(printf "%s" "$2" | "$HOOKS_DIR/guard-codigo.sh" 2>/dev/null)"
  [ -z "$o" ] && { echo "  FAIL  $1 (la herramienta no dijo nada)"; return 1; }
  printf "%s" "$o"
}
mi_check() {
  local out
  out="$(mi_corre "$1" "$2")" || { FAIL=$((FAIL+1)); return 0; }
  echo "  PASS  $1"; PASS=$((PASS+1))
}
mi_check "caso con guarda cuya variable se llama o" "$(emite_edit "$PROJ/src/app.ts" "" "" "hola")"'
corre_corredor
igual "H-11 una guarda equivalente con OTRO nombre de variable no aborta (ni falso positivo)" "0-si" \
  "$RC-$(printf '%s' "$SALIDA" | grep -q 'caso con guarda cuya variable se llama o' && echo si || echo no)"
no_casa "H-11 y no acusa a ninguna función de romper la invariante 1" 'invariante 1 rota' "$SALIDA"
# Y la propiedad no es «cualquier variable»: el filtro de nombre de caso (`[ -n "$FILTRO" ]`)
# está en 31 ayudantes de sección y NO es una guarda. Si contara, el control quedaría
# abierto de par en par aparentando seguir cerrado.
nuevo_dir
pon_seccion "01-filtro-no-es-guarda.sh" 1 'mal_check() {
  local out
  if [ -n "$FILTRO" ] && ! printf "%s" "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  out="$(printf "%s" "$2" | "$HOOKS_DIR/guard-codigo.sh")"
  echo "  PASS  $1"; PASS=$((PASS+1))
}
mal_check "caso cuyo unico -n es el del FILTRO" ""'
corre_corredor
casa "H-11 el filtro de nombre de caso NO cuenta como guarda: sigue abortando" \
  '01-filtro-no-es-guarda\.sh: la funcion mal_check' "$SALIDA"

# --- H-10 · `diag` garantiza el salto de línea final, o el cuadre pierde un caso ---
# QA 1.32.0 (H-10): `diag` era `sed`, que copia el último renglón tal cual. Con un
# `$ERRLOG` sin `\n` final, la línea `  PASS ` siguiente se pegaba detrás, dejaba de
# empezar por `^  PASS ` y el awk del recuento no la veía: el ABORT del cuadre acusaba a
# `CASOS_ESPERADOS_SECCION` y el culpable era un diagnóstico sin salto. Fail-closed, sí,
# pero mandando a investigar al sitio equivocado — el mismo vicio que H-07.
nuevo_dir
pon_seccion "01-diag-sin-salto.sh" 2 'printf "%s" "un stderr que NO termina en salto de linea" > "$ERRLOG"
echo "  FAIL  caso que diagnostica"; FAIL=$((FAIL+1))
diag
echo "  PASS  el caso siguiente al diagnostico"; PASS=$((PASS+1))'
corre_corredor
casa "H-10 tras un diag sin salto final, el caso siguiente sigue empezando línea" \
  '^  PASS  el caso siguiente al diagnostico' "$SALIDA"
no_casa "H-10 y el cuadre por archivo no acusa en falso a CASOS_ESPERADOS_SECCION" \
  'declara 2 casos y ejecutó 1' "$SALIDA"
casa "H-10 el diagnóstico sigue saliendo, con su prefijo" 'stderr\| un stderr que NO termina' "$SALIDA"

# --- CA-17 · corrida parcial: cuadre global suspendido, el de la sección no ----
nuevo_dir
pon_seccion "07-elegida.sh" 1 'echo "  PASS  caso de la elegida"; PASS=$((PASS+1))'
pon_seccion "19-la-otra.sh" 1 'echo "  PASS  caso de la otra"; PASS=$((PASS+1))'
corre_corredor "secciones/07-*.sh"
casa "CA-17 con un selector corre sólo esa sección" 'caso de la elegida' "$SALIDA"
no_casa "CA-17 y no corre las demás" 'caso de la otra' "$SALIDA"
casa "CA-17 el cuadre TOTAL queda suspendido, y lo dice" 'vuelta parcial.*cuadre TOTAL queda suspendido' "$SALIDA"
igual "CA-17 y no aborta en falso" "0" "$RC"
nuevo_dir
pon_seccion "07-descuadra.sh" 9 'echo "  PASS  caso solitario"; PASS=$((PASS+1))'
corre_corredor "07-descuadra.sh"
casa "CA-17 en parcial, el cuadre DE LA SECCIÓN se sigue exigiendo" '07-descuadra\.sh' "$SALIDA"
igual "CA-17 y por eso sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"
nuevo_dir
pon_seccion "01-unica.sh" 1 'echo "  PASS  caso unico"; PASS=$((PASS+1))'
corre_corredor "secciones/99-no-existe.sh"
casa "CA-17 un selector que no casa con nada ABORTA (no degrada a filtro)" \
  "ningún archivo de sección casa" "$SALIDA"
igual "CA-17 y sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"

# --- Descubrimiento: nada en secciones/ se queda fuera en silencio ------------
# QA 1.32.0 (H-04): un archivo SIN la extensión `.sh` no lo alcanzaba ni el glob del
# corredor ni el bucle `*.sh` de esta autoprueba: quedaba fuera de las dos redes y la
# vuelta salía verde sin mencionarlo. El respaldo era el cuadre total, y en vuelta
# parcial el cuadre total está suspendido por diseño.
nuevo_dir
pon_seccion "01-buena.sh" 1 'echo "  PASS  caso bueno"; PASS=$((PASS+1))'
pon_seccion "40-sin-extension" 1 'echo "  PASS  caso que nadie iba a ejecutar"; PASS=$((PASS+1))'
corre_corredor
casa "H-04 un archivo de secciones/ sin extensión .sh ABORTA en vez de ignorarse" \
  'ABORT.*NO iba a ejecutar' "$SALIDA"
casa "H-04 y el ABORT lo nombra" '40-sin-extension' "$SALIDA"
igual "H-04 y la vuelta sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"
nuevo_dir
pon_seccion "01-buena.sh" 1 'echo "  PASS  caso bueno"; PASS=$((PASS+1))'
pon_seccion "zz-huerfana.sh" 1 'echo "  PASS  otro que nadie iba a ejecutar"; PASS=$((PASS+1))'
corre_corredor
casa "H-04 un archivo .sh que no casa NN- tampoco se ignora" 'zz-huerfana\.sh' "$SALIDA"

# QA 1.32.0 (H-05): una entrada que SÍ casa el patrón pero no es un archivo legible —un
# directorio `43-dir.sh`— mataba `lee_casos_declarados` bajo `set -u` y se llevaba el
# bucle del cuadre entero: sin `ABORT:` y sin línea `Resultado:`. Fail-closed, sí, pero
# indiagnosticable, que es lo contrario de lo que esta estructura viene a dar.
nuevo_dir
pon_seccion "01-buena.sh" 1 'echo "  PASS  caso bueno"; PASS=$((PASS+1))'
mkdir "$DIRSEC/43-dir.sh"
corre_corredor
casa "H-05 un directorio con nombre de sección ABORTA y lo nombra" '43-dir\.sh' "$SALIDA"
no_casa "H-05 y no muere con 'unbound variable'" 'unbound variable' "$SALIDA"
igual "H-05 y la vuelta sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"

# --- CA-09 · el canario va ANTES del descubrimiento ---------------------------
# Con HOOKS_DIR apuntando a un directorio sin hooks, el canario tiene que abortar la
# corrida entera antes de ejecutar una sola sección.
nuevo_dir
pon_seccion "01-no-deberia-correr.sh" 1 'echo "  PASS  esta sección no debería haber corrido"; PASS=$((PASS+1))'
SALIDA="$(ARNES_SECCIONES_DIR="$DIRSEC" ARNES_HOOKS_DIR="$RAIZ/sin-hooks" bash "$CORREDOR" 2>&1)"; RC=$?
casa "CA-09 sin hooks el canario aborta la corrida entera" 'ABORT: el canario no denegó' "$SALIDA"
no_casa "CA-09 y no llegó a ejecutarse ninguna sección" 'esta sección no debería haber corrido' "$SALIDA"
igual "CA-09 y sale distinta de 0" "no-cero" "$([ "$RC" -ne 0 ] && echo no-cero || echo cero)"

# --- Estructura del árbol real: CA-01, CA-11, CA-18, CA-19, CA-27 -------------
igual "CA-01 run.sh no contiene ninguna definición seccion_NN()" "0" \
  "$(grep -cE '^seccion_[0-9]+\(\)' "$CORREDOR" || true)"
igual "CA-01 existe secciones/ con un archivo por sección" "si" \
  "$([ -d "$SECC_REAL" ] && echo si || echo no)"
MALOS=""
for f in "$SECC_REAL"/*.sh; do
  case "${f##*/}" in [0-9][0-9]-*.sh) ;; *) MALOS="$MALOS ${f##*/}" ;; esac
done
igual "CA-01 todos los archivos de secciones/ se llaman NN-<slug>.sh" "" "$MALOS"

SIN_SINTAXIS=""; SIN_NUMERO=""; LARGOS=""; ACOPLADOS=""; MODO_RARO=""
for f in "$SECC_REAL"/[0-9][0-9]-*.sh; do
  b="${f##*/}"
  bash -n "$f" 2>/dev/null || SIN_SINTAXIS="$SIN_SINTAXIS $b"
  grep -qE '^CASOS_ESPERADOS_SECCION=[0-9]+' "$f" || SIN_NUMERO="$SIN_NUMERO $b"
  [ "$(grep -c '' "$f")" -le 400 ] || LARGOS="$LARGOS $b($(grep -c '' "$f"))"
  grep -qE '^[[:space:]]*(source|\.)[[:space:]]+.*secciones/' "$f" && ACOPLADOS="$ACOPLADOS $b"
  [ -x "$f" ] && MODO_RARO="$MODO_RARO $b"
done
igual "CA-11 bash -n pasa en todos los archivos de sección" "" "$SIN_SINTAXIS"
igual "CA-07 todos declaran su CASOS_ESPERADOS_SECCION" "" "$SIN_NUMERO"
igual "CA-18 ningún archivo de sección pasa de 400 líneas" "" "$LARGOS"
igual "CA-19 ningún archivo de sección hace source de otro" "" "$ACOPLADOS"
igual "CA-27 los archivos de sección no llevan bit de ejecución (se hacen source)" "" "$MODO_RARO"
igual "CA-27 run.sh sí conserva su bit de ejecución" "si" \
  "$([ -x "$CORREDOR" ] && echo si || echo no)"

igual "H-06 la autoprueba declara su propio cuadre una sola vez" "1" \
  "$(grep -c '^AUTOPRUEBA_CASOS_ESPERADOS=' "${BASH_SOURCE[0]}")"

echo "-------------------------------------------"
echo "Autoprueba: $PASS PASS, $FAIL FAIL"
# --- Invariante 2 del banco, aplicada AQUÍ (QA 1.32.0, H-06) -------------------
# La autoprueba exigía a cada sección declarar cuántos casos corre, y era el único
# artefacto de la cadena sin esa red: QA borró un caso y salió `50 PASS, 0 FAIL`, rc 0.
# Un caso que desaparece produce cero líneas, que es exactamente lo que produce un caso
# que pasó limpio; sólo el número declarado los distingue. Y esto certifica al corredor
# que certifica a los hooks: es el sitio donde menos se puede prescindir de la red.
if [ $((PASS + FAIL)) -ne "$AUTOPRUEBA_CASOS_ESPERADOS" ]; then
  echo "ABORT: corrieron $((PASS + FAIL)) casos (PASS $PASS · FAIL $FAIL) y se declararon $AUTOPRUEBA_CASOS_ESPERADOS."
  echo "       O falta un caso por el camino, o alguien añadió uno y no actualizó"
  echo "       AUTOPRUEBA_CASOS_ESPERADOS. Las dos cosas hay que mirarlas."
  exit 1
fi
[ "$FAIL" -eq 0 ]
