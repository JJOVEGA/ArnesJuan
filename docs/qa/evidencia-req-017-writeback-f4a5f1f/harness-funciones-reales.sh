#!/usr/bin/env bash
FILTRO=""; PASS=0; FAIL=0
UTIL_DIR="/home/juan/dev/ArnesJuan/tests/util"
num37() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# --- Árboles heredados: la línea base se materializa ENTERA o no se materializa ------
# REQ-021 CA-05, con su sujeto reescrito el 2026-09-08: el criterio gobierna EL
# MATERIALIZADOR DONDE VIVA, y desde la reducción de alcance vive AQUÍ, inline.
# `sonda-linea-base.sh` SALE del alcance de REQ-021 (decisión del propietario) porque era la
# causa de los tres problemas más duros a la vez: su calibración era TAUTOLÓGICA —el factor
# salía del PARÁMETRO, así que `2N/N = 2000` por aritmética, hiciera la sonda algo o nada, y
# una copia que no materializaba nada dio PASS (QA-021-01)—, sus 21 procesos de calibración
# por corrida volvían insatisfacible CA-08 (i) contra un presupuesto total de 18, y cuatro de
# los procesos de (i.2) eran internos de `git` que nadie elige.
# Lo que se conserva son las PROPIEDADES de CA-05, portadas aquí:
#   (1) cada archivo materializado coincide con el objeto DEL ÁRBOL DE ESA REFERENCIA y queda
#       con EL MODO DEL OBJETO EN ESE ÁRBOL —no «todo `*.sh` es ejecutable», que al
#       materializar `tests/` dejaba `secciones/*.sh` con bit y rompía la invariante CA-27 del
#       propio banco EN LA COPIA (DEV-021-08); el modo del objeto es además lo que ya se está
#       leyendo para comparar contra el árbol, así que enunciarlo así no añade trabajo: quita
#       una excepción—;
#   (2) publica `archivos=<n>`, para que un árbol A MEDIAS se vea sin abrirlo;
#   (3) cuando NO puede, `estado=sin-linea-base` CON el motivo, y nunca un árbol parcial ni
#       un `ok`;
#   (4) publica en el registro de UNA línea de CA-01 punto 2 y lo lee el PARSER ÚNICO
#       (`sonda_lee`), así que CA-08 (0), CA-06 y CA-10 siguen siendo exigibles sobre él. Lo
#       que NO hereda es la calibración de CA-03 ni las comprobaciones de CA-09, y por eso NO
#       declara `vivos`: el campo se enuncia sobre EL EMISOR y no sobre el formato
#       (CA-10 punto 2), porque exigirle a quien no puede observarlo es un FAIL garantizado.
# Los dos casos medidos que esto cierra: un árbol copiado SIN `.git` —el tag no se
# materializaba, media comprobación salía SKIP y la razón dio 2,008× donde el trabajo entero
# da 0,964×, y lo delató el RECUENTO DE SKIP, no el número— y `git show` sin bit de ejecución,
# que dejaba al canario sin arrancar: la corrida salía «sin casos», un SKIP correcto por un
# motivo que no era el suyo.
# LO QUE ESTO NO TAPA: `mat37` y `mat47` siguen siendo DOS COPIAS LITERALES de la misma
# lógica y nada comprueba que las dos conserven CA-05. Es el residual AN-021-01, con dueño y
# ventana 1.34.0 — no algo que este código resuelva.
REPO37="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..` y no cuesta un fork
MAT37_RUTAS='hooks tools'
MAT37_REG=''; MAT37_T0=0; MAT37_REF='-'; MAT37_ETIQ='-'
mat37_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT37_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT37_T0 ))
  # Todo valor que venga de fuera se reduce a UN campo: un espacio dentro de un valor
  # convertía las palabras siguientes en CAMPOS del registro y el juez leía otro `estado`
  # (QA-021-04), y un salto de línea sacaba el registro en dos líneas.
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT37_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT37_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT37_ETIQ ref=$MAT37_REF archivos=$arch"
}
mil37() { printf -v MIL37 '%d.%03d' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }

# banda37 <mín_num> <máx_num> <mín_den> <máx_den> <techo‰> <dir: no-excede|excede>
#   -> BAN37_V (PASS|FAIL|SKIP) · BAN37_LO · BAN37_HI, en milésimas
# LA BANDA, QUE ES LO QUE CA-03 CONTRATA DESDE EL 2026-09-09. Con el mínimo y el máximo de
# cada término la corrida acota los cocientes COMPATIBLES con lo que midió —de
# mín(num)/máx(den) a máx(num)/mín(den)— y el veredicto sólo se emite si NO depende del
# ruido que la propia corrida publica: PASS sólo si TODA la banda cae del lado conforme,
# FAIL sólo si toda cae del NO conforme, y en cuanto el techo cae DENTRO, SKIP con la banda,
# el cociente y el techo (CA-06). La unanimidad es DE CONTRATO: no admite mayoría, promedio
# ni «el mejor de los dos extremos». No cuesta ninguna repetición nueva: sale de cifras que
# la sonda YA emite (`REQ-021 CA-02` punto 3).
# LA DIRECCIÓN ES UN DATO Y NO DOS FUNCIONES: la directa es conforme cuando el cociente NO
# pasa del techo y el fail-before cuando SÍ lo pasa, y las dos tienen que endurecerse por
# el MISMO código o dejan de acreditar el mismo cociente.
# LA GUARDA SÓLO PUEDE ESTRECHAR, y aquí es demostrable: `lo ≤ coc ≤ hi` por construcción,
# así que un PASS con banda implica el mismo veredicto sin ella en las DOS direcciones —
# nunca convierte un FAIL en PASS—. Se PRUEBA abajo con un par discriminante y no se
# argumenta: este REQ lleva tres afirmaciones de esa clase que resultaron falsas al
# ejecutarlas. Una dirección no reconocida no decide y NO calla: devuelve 1 y quien llama
# se abstiene citando el valor (fail-closed con diagnóstico, no fail-closed mudo).
BAN37_V=''; BAN37_LO=''; BAN37_HI=''
banda37() {
  local mn="$1" xn="$2" md="$3" xd="$4" techo="$5" dir="$6"
  BAN37_V=''; BAN37_LO=''; BAN37_HI=''
  BAN37_LO=$(( mn * 1000 / xd )); BAN37_HI=$(( xn * 1000 / md )); BAN37_V=SKIP
  case "$dir" in
    no-excede) if [ "$BAN37_HI" -le "$techo" ]; then BAN37_V=PASS; elif [ "$BAN37_LO" -gt "$techo" ]; then BAN37_V=FAIL; fi ;;
    excede)    if [ "$BAN37_LO" -gt "$techo" ]; then BAN37_V=PASS; elif [ "$BAN37_HI" -le "$techo" ]; then BAN37_V=FAIL; fi ;;
    *)         BAN37_V=''; return 1 ;;
  esac
  return 0
}
MED37_US=''; MED37_MAX=''; MED37_MOTIVO=''; MED37_REG=''; MED37_PLAT=''; MED37_CARGA=''
mide37() {   # <lib> <fn> <bytes> <k> -> MED37_US/MED37_MAX = mínimo y máximo de 3 series, µs
  local lib="$1" fn="$2" n="$3" k="$4" reg
  MED37_US=''; MED37_MAX=''; MED37_MOTIVO=''; MED37_REG=''; MED37_PLAT=''; MED37_CARGA=''
  if [ ! -r "$lib" ]; then MED37_MOTIVO="no existe $lib"; return 1; fi
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "$fn-$n" \
    --prep "source '$lib' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; l37=''; while [ \${#l37} -lt $n ]; do l37+=\"\$s37\"; done; l37=\"\${l37:0:$n}\"" \
    --sujeto "ARNES_CITA=0; ARNES_CR=0; $fn \"\$l37\"" 2>/dev/null)"
  MED37_REG="$reg"
  if [ -z "$reg" ]; then MED37_MOTIVO='la sonda de reloj no dejó registro'; return 1; fi
  if ! sonda_lee "$reg"; then MED37_MOTIVO="$SONDA_MOTIVO"; return 1; fi
  MED37_PLAT="${SONDA[plataforma]:-n/a}"; MED37_CARGA="${SONDA[carga]:-n/a}"
  if [ "${SONDA[estado]}" != ok ]; then
    MED37_MOTIVO="la sonda no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo} (min=${SONDA[min]:-n/a}µs)"; return 1
  fi
  if ! num37 "${SONDA[min]:-}"; then MED37_MOTIVO="la sonda no publicó un mínimo (<${SONDA[min]:-vacío}>)"; return 1; fi
  MED37_US="${SONDA[min]}"
  # Si la sonda no publicara el máximo, el caso sigue midiendo con el mínimo y sólo pierde
  # una cifra del mensaje. Por eso su ausencia NO es motivo de abstención.
  MED37_MAX="${SONDA[max]:-}"
  return 0
}
MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''
mide37i() {
  local lib="$1" fn="$2" na="$3" nb="$4" k="$5" reg x
  MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''; MED37_MOTIVO=''; MED37_REG=''
  MED37_PLAT=''; MED37_CARGA=''
  if [ ! -r "$lib" ]; then MED37_MOTIVO="no existe $lib"; return 1; fi
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "$fn-$na-vs-$nb-intercalado" \
    --prep "source '$lib' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; a37=''; while [ \${#a37} -lt $na ]; do a37+=\"\$s37\"; done; a37=\"\${a37:0:$na}\"; b37=\"\${a37:0:$nb}\"" \
    --sujeto-a "ARNES_CITA=0; ARNES_CR=0; $fn \"\$a37\"" \
    --sujeto-b "ARNES_CITA=0; ARNES_CR=0; $fn \"\$b37\"" 2>/dev/null)"
  MED37_REG="$reg"
  if [ -z "$reg" ]; then MED37_MOTIVO='la sonda de reloj no dejó registro'; return 1; fi
  if ! sonda_lee "$reg"; then MED37_MOTIVO="$SONDA_MOTIVO"; return 1; fi
  MED37_PLAT="${SONDA[plataforma]:-n/a}"; MED37_CARGA="${SONDA[carga]:-n/a}"
  MED37_A="${SONDA[min_a]:-}"; MED37_AX="${SONDA[max_a]:-}"
  MED37_B="${SONDA[min_b]:-}"; MED37_BX="${SONDA[max_b]:-}"
  for x in "$MED37_A" "$MED37_AX" "$MED37_B" "$MED37_BX"; do
    num37 "$x" && continue
    MED37_MOTIVO="la sonda no publicó los cuatro términos del par intercalado: estado=${SONDA[estado]:-?} motivo=${SONDA[motivo]:-sin motivo}"
    MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''; return 1
  done
  # `estado=suelo` NO se descarta: las cuatro cifras están completas y son «el número que
  # sí obtuvo», que es lo que CA-06 obliga a citar. El suelo lo juzga `razon37`, que es
  # donde vive la regla de los 50 ms para las tres razones de esta sección — reimplementarla
  # aquí sería la segunda transcripción que siempre acaba desfasada.
  case "${SONDA[estado]}" in
    ok)    ;;
    suelo) MED37_MOTIVO="la sonda declaró estado=suelo (${SONDA[motivo]:-sin motivo})" ;;
    *)     MED37_MOTIVO="la sonda no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo}"
           MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''; return 1 ;;
  esac
  return 0
}
BAN37_V=''; BAN37_LO=''; BAN37_HI=''
banda37() {
  local mn="$1" xn="$2" md="$3" xd="$4" techo="$5" dir="$6"
  BAN37_V=''; BAN37_LO=''; BAN37_HI=''
  BAN37_LO=$(( mn * 1000 / xd )); BAN37_HI=$(( xn * 1000 / md )); BAN37_V=SKIP
  case "$dir" in
    no-excede) if [ "$BAN37_HI" -le "$techo" ]; then BAN37_V=PASS; elif [ "$BAN37_LO" -gt "$techo" ]; then BAN37_V=FAIL; fi ;;
    excede)    if [ "$BAN37_LO" -gt "$techo" ]; then BAN37_V=PASS; elif [ "$BAN37_HI" -le "$techo" ]; then BAN37_V=FAIL; fi ;;
    *)         BAN37_V=''; return 1 ;;
  esac
  return 0
}
razon37() {
  local nombre="$1" med="$2" base="$3" techo="$4" que="$5"
  local xmed="${6:-}" xbase="${7:-}" dir="${8:-}" mue="${9:-}" coc ev qc qt lo hi
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  mil37 "$techo"; qt="$MIL37"
  # La evidencia se arma UNA vez y sale en TODAS las ramas —PASS, FAIL y las abstenciones—:
  # es lo que hace atribuible el próximo rojo, no el adorno del SKIP.
  ev="mín/máx ${med:-n/a}/${xmed:-n/a}µs sobre ${base:-n/a}/${xbase:-n/a}µs · techo $qt×${mue:+ · $mue}"
  if [ -z "$med" ] || [ -z "$base" ]; then
    echo "  SKIP  $nombre  no hay con qué medir: ${MED37_MOTIVO:-falta uno de los dos términos} (medido=<${med:-vacío}> base=<${base:-vacío}>) · $ev"; return 0
  fi
  if [ "$med" -lt 50000 ] || [ "$base" -lt 50000 ]; then
    echo "  SKIP  $nombre  serie por debajo del suelo de 50 ms: el reloj no distingue del ruido · $ev"; return 0
  fi
  coc=$(( med * 1000 / base )); mil37 "$coc"; qc="$MIL37"
  if [ -n "$dir" ]; then
    if ! num37 "$xmed" || ! num37 "$xbase"; then
      echo "  SKIP  $nombre  la banda necesita el MÁXIMO de los dos términos y no llegó (máx medido=<${xmed:-vacío}> máx base=<${xbase:-vacío}>) · $ev"; return 0
    fi
    if ! banda37 "$med" "$xmed" "$base" "$xbase" "$techo" "$dir"; then
      echo "  SKIP  $nombre  dirección de banda no reconocida <$dir>: la puerta no puede decidir · $ev"; return 0
    fi
    mil37 "$BAN37_LO"; lo="$MIL37"; mil37 "$BAN37_HI"; hi="$MIL37"
    ev="$que = $qc× · banda compatible [$lo×, $hi×] · $ev"
    case "$BAN37_V" in
      PASS) echo "  PASS  $nombre  TODA la banda cae del lado conforme · $ev"; PASS=$((PASS+1)) ;;
      FAIL) echo "  FAIL  $nombre  TODA la banda cae del lado NO conforme · $ev"; FAIL=$((FAIL+1)) ;;
      *)    echo "  SKIP  $nombre  el techo $qt× cae DENTRO de la banda: el veredicto dependería del ruido de esta corrida · $ev" ;;
    esac
    return 0
  fi
  if [ "$coc" -le "$techo" ]; then
    echo "  PASS  $nombre  $que = $qc× (techo $qt×; ${med}µs sobre ${base}µs) · $ev"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  $que = $qc× > techo $qt× (${med}µs sobre ${base}µs) · $ev"; FAIL=$((FAIL+1))
  fi
}
