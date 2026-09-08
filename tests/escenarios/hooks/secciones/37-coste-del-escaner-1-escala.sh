# ---------- 37 (1/2) · EL COSTE DEL ESCÁNER: ESCALA, EQUIVALENCIA Y LA PARED ----------
# REQ-017. La guarda del CR de `arnes_sin_cita` era CUADRÁTICA en la longitud de línea:
# `${l%$CR}` es eliminación de sufijo CON PATRÓN, y bash la resuelve probando cada
# posición. El banco pagaba 92 s donde pagaba 39, y NINGÚN criterio lo veía porque el que
# había (CA-08 de REQ-016) medía PROCESOS —4 = 4, medido bien— mientras el reloj se
# multiplicaba por diez. Esta sección contrata la magnitud que sí se degradó.
#
# POR QUÉ TODO AQUÍ SON RAZONES Y NO SEGUNDOS. Un techo en segundos lo falsea la máquina
# y lo falsea la carga —esta misma ventana midió lo que pasa cuando una sonda desbocada
# envenena el reloj de otra medición—. Un COCIENTE DE DUPLICACIÓN responde a la pregunta
# que se degradó (el orden de crecimiento) y la velocidad de la máquina se cancela
# algebraicamente; una RAZÓN contra una línea base medida en la MISMA corrida cancela la
# máquina por construcción. Y el estadístico es el MÍNIMO de k repeticiones, nunca la
# media: la carga sólo puede AÑADIR tiempo, así que el mínimo es la mejor estimación del
# coste real y la media es una mezcla de coste y de vecinos.
CASOS_ESPERADOS_SECCION=13
seccion_nueva "--- 37/1 · el coste del escáner: escala, equivalencia y la pared de los 60 s (REQ-017) ---"

REPO37="$(cd "${SEC_DIR%/}/../../../.." 2>/dev/null && pwd || true)"
CR37=$'\r'
# El contexto de la máquina viaja EN EL MENSAJE de cada caso del dominio, y no es adorno:
# la partición dentro/fuera de CA-01 depende de la versión de bash y del locale, así que un
# SKIP que no los nombre no se puede distinguir de un verde vacío (CA-01, CA-10).
LOC37="${LC_ALL:-${LC_CTYPE:-${LANG:-(sin declarar)}}}"
CTX37="bash $BASH_VERSION, locale del entorno $LOC37"
num37() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# --- Árboles heredados: la línea base se materializa, no se supone --------------
# Sin `tar` ni `git archive`: `git show` archivo a archivo, que es lo que hay en toda
# plataforma donde este banco corre. Si el tag no está (clon superficial, tarball), la
# sonda NO puede medir y sus casos dicen SKIP con el motivo — CA-06.
mat37() {   # <tag> <destino> -> 0 si el árbol quedó materializado
  local tag="$1" dst="$2" f lista
  [ -n "$REPO37" ] || return 1
  git -C "$REPO37" rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1 || return 1
  lista="$(git -C "$REPO37" ls-tree -r --name-only "$tag" hooks tools 2>/dev/null)"
  [ -n "$lista" ] || return 1
  mkdir -p "$dst/hooks" "$dst/tools" 2>/dev/null || return 1
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    git -C "$REPO37" show "$tag:$f" > "$dst/$f" 2>/dev/null || return 1
  done <<< "$lista"
  [ -s "$dst/hooks/lib.sh" ] || return 1
  # `git show` escribe el CONTENIDO, no el modo: sin el bit de ejecución un árbol heredado
  # sirve para `source` y para `bash script`, pero no para invocarlo directamente.
  chmod +x "$dst"/hooks/*.sh "$dst"/tools/*.sh 2>/dev/null || true
  return 0
}
HER37="$RAIZ/her37-321-$BASHPID"; HER37_OK=no
mat37 v1.32.1 "$HER37" && HER37_OK=si
BAS37="$RAIZ/her37-320-$BASHPID"; BAS37_OK=no
mat37 v1.32.0 "$BAS37" && BAS37_OK=si
LIB37="$HOOKS_DIR/lib.sh"

# --- El medidor, en su propio proceso -----------------------------------------
# Cada árbol define las MISMAS funciones: medirlos en un solo proceso mediría el último
# que se cargó. Un proceso por serie, y NADA que sobreviva a la sección (CA-06).
MED37="$RAIZ/med37-$BASHPID.sh"
cat > "$MED37" <<'MED37FIN'
LIB="$1"; FN="$2"; N="$3"; K="$4"
[ -n "${EPOCHREALTIME:-}" ] || { printf 'SIN-RELOJ\n'; exit 2; }
source "$LIB" >/dev/null 2>&1 || { printf 'SIN-LIB\n'; exit 1; }
declare -F "$FN" >/dev/null 2>&1 || { printf 'SIN-FN\n'; exit 1; }
s=''; while [ ${#s} -lt 512 ]; do s+='Estado: en-revision -- relleno de cabecera '; done
l=''; while [ ${#l} -lt "$N" ]; do l+="$s"; done; l="${l:0:N}"
t0=${EPOCHREALTIME/./}
for ((i=0;i<K;i++)); do ARNES_CITA=0; ARNES_CR=0; "$FN" "$l"; done
t1=${EPOCHREALTIME/./}
printf '%s\n' "$((t1-t0))"
MED37FIN

MED37_US=''; MED37_MOTIVO=''
mide37() {   # <lib> <fn> <bytes> <k> -> MED37_US = mínimo de 3 series, en microsegundos
  local lib="$1" fn="$2" n="$3" k="$4" r u
  MED37_US=''; MED37_MOTIVO=''
  if [ ! -r "$lib" ]; then MED37_MOTIVO="no existe $lib"; return 1; fi
  for r in 1 2 3; do
    u="$(bash "$MED37" "$lib" "$fn" "$n" "$k" 2>/dev/null)"
    case "$u" in
      ''|*[!0-9]*) MED37_MOTIVO="el medidor no devolvió un número (<${u:-vacío}>)"; MED37_US=''; return 1 ;;
    esac
    if [ -z "$MED37_US" ] || [ "$u" -lt "$MED37_US" ]; then MED37_US="$u"; fi
  done
  return 0
}

# razon37 <nombre> <us_medido> <us_base> <techo_por_mil> <qué mide>
# UNA SOLA puerta para las tres razones de esta sección, y con la regla de CA-06 metida
# dentro: si falta cualquiera de los dos términos, o si alguna serie no llega al suelo de
# 50 ms (donde el reloj deja de tener resolución frente al ruido), el caso dice SKIP CON
# EL MOTIVO Y CON EL NÚMERO QUE SÍ OBTUVO, y NUNCA PASS. Un PASS de una sonda que no pudo
# medir es exactamente el verde sobre una regresión que este REQ existe para no repetir.
razon37() {
  local nombre="$1" med="$2" base="$3" techo="$4" que="$5" coc
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ -z "$med" ] || [ -z "$base" ]; then
    echo "  SKIP  $nombre  no hay con qué medir: ${MED37_MOTIVO:-falta uno de los dos términos} (medido=<${med:-vacío}> base=<${base:-vacío}>)"; return 0
  fi
  if [ "$med" -lt 50000 ] || [ "$base" -lt 50000 ]; then
    echo "  SKIP  $nombre  serie por debajo del suelo de 50 ms (medido=${med}µs base=${base}µs): el reloj no distingue del ruido"; return 0
  fi
  coc=$(( med * 1000 / base ))
  if [ "$coc" -le "$techo" ]; then
    echo "  PASS  $nombre  $que = $(awk -v c=$coc 'BEGIN{printf "%.3f", c/1000}')× (techo $(awk -v t=$techo 'BEGIN{printf "%.3f", t/1000}')×; ${med}µs sobre ${base}µs)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  $que = $(awk -v c=$coc 'BEGIN{printf "%.3f", c/1000}')× > techo $(awk -v t=$techo 'BEGIN{printf "%.3f", t/1000}')× (${med}µs sobre ${base}µs)"; FAIL=$((FAIL+1))
  fi
}

# ---------- CA-01 Y CA-10 · EL CORPUS ÚNICO Y LA PARTICIÓN QUE SE MIDE EN LA CORRIDA ----
# No se enumeran salidas esperadas a mano: se corre la implementación de este árbol y la
# heredada sobre el MISMO corpus y se comparan sus estados BYTE A BYTE. Enumerar a mano es
# cómo se escribe una prueba que acredita lo que el autor creía, no lo que la función hace.
# El corpus vive AQUÍ y sólo aquí (CA-01), con semilla fija para que el CI repita la misma
# corrida, y lleva ADEMÁS las fronteras nombradas: si el azar no las produce, están igual.
#
# PERO LA EQUIVALENCIA NO SE AFIRMA SOBRE TODA ENTRADA, Y ESO ES EL CRITERIO, NO UNA COARTADA
# (`ADR-004`). Bajo un locale UTF-8 la eliminación de sufijo CON PATRÓN de la heredada no se
# comporta byte a byte sobre secuencias multibyte inválidas: ahí «el estado de la heredada»
# NO DESIGNA UN OBJETO ÚNICO —depende del locale—, así que una igualdad contra él no está
# definida hasta decir bajo cuál. El DOMINIO DE EQUIVALENCIA es el conjunto de entradas
# sobre las que la heredada publica UN ÚNICO Y EL MISMO estado en k evaluaciones bajo el
# locale del entorno Y k bajo `LC_ALL=C`: determinismo E invariancia de locale, las dos, y
# basta que falle una para quedar fuera. Lo de fuera no se deja sin contratar: se contrata
# APARTE, en CA-10, como DIRECCIÓN contra un ORÁCULO —la heredada bajo `LC_ALL=C`, único
# sitio donde existe un valor correcto contra el que medir—.
#
# LA PARTICIÓN SE CALCULA CON LA HEREDADA SOLA, Y ESO ES PARTE DEL CRITERIO. Un dominio
# definido como «las entradas donde los dos árboles coinciden» convierte CA-01 en un criterio
# que NO PUEDE FALLAR, y un criterio que no puede fallar no es una puerta. Por eso el orden de
# aquí abajo no es estilo: las dos evaluaciones de la HEREDADA van primero, la partición se
# calcula con ellas y sólo DESPUÉS se evalúa este árbol.
#
# Y EL CORPUS NO SE ESTRECHA HASTA QUE LA CLASE DESAPAREZCA — que es la forma de verde que
# esta ventana persigue (QA-017-02, y la alternativa D de `ADR-004`). El alfabeto del
# generador lleva fichas de byte >= 0x80 que NO forman UTF-8 válido, y hay además un bloque
# SISTEMÁTICO —el corpus que QA midió— para que la clase no dependa del azar. Si el corpus la
# PIERDE, los casos FALLAN; si es la MÁQUINA la que no tiene el defecto, dicen SKIP. La
# asimetría es deliberada: un corpus estrechado es trabajo retirado y tiene que doler; una
# máquina sin el defecto es falta de sujeto, y poner rojo ahí acaba con alguien apagando el
# caso.
CORPUS37="$RAIZ/corpus37-$BASHPID"
BINV37=$'\xc3\x5c\x0d\x5d\x0d'   # la línea exacta de QA-017-01: c3 5c CR ] CR
{
  printf '%s\n' ''                               # línea vacía
  printf '%s\n' "$CR37"                          # sólo el carácter
  printf '%s\n' "${CR37}Estado: completado"      # CR en la primera posición
  printf '%s\n' "Estado: completado$CR37"        # CR sólo al final (transporte)
  printf '%s\n' "Esta${CR37}do: completado$CR37" # CR final Y otro interior
  printf '%s\n' 'Estado: completado'             # sin ningún CR
  printf '%s\n' "<!$CR37-- comentario -->"       # CR partiendo el delimitador de apertura
  printf '%s\n' "<!-- comentario --$CR37>"       # ...y el de cierre
  printf '%s\n' "<!--$CR37 abre y no cierra"     # CR adyacente a <!--
  printf '%s\n' "cierra --> resto$CR37"          # CR adyacente a -->
  printf '%s\n' '<!-- uno --> QA: aprobado <!-- dos -->'
  printf '%s\n' '<!-- rango que abre'
  printf '%s\n' 'dentro del rango'
  printf '%s\n' 'y aquí --> Seguridad: aprobado'
  printf '%s\n' "$BINV37"                        # byte multibyte inválido y CR interior
  # EL BLOQUE SISTEMÁTICO, y por qué no basta con el azar: la clase que separa las dos
  # mitades de este REQ tiene que estar en el corpus SIEMPRE, no cuando la semilla quiera.
  # Son las 7 cabezas × 5 colas × 3 prefijos que QA midió (QA-017-01): `c3a9` está entre las
  # cabezas a propósito —es UTF-8 VÁLIDO— para que el corpus no confunda «multibyte» con
  # «inválido», que son la propiedad de la máquina y la propiedad que aquí importa.
  for _pre37 in '' 'Estado: ' 'QA: '; do
    for _cab37 in $'\xc3' $'\xc3\x5c' $'\xe2' $'\xf0' $'\xc3\xa9' $'\xff' $'\xc3\x5c\x0d\x5d'; do
      for _col37 in $'\x0d' $'\x0d\x5d\x0d' $'\x5d\x0d' $'\x0d\x0d' ''; do
        printf '%s\n' "$_pre37$_cab37$_col37"
      done
    done
  done
  RANDOM=20260907   # semilla fija: el CI repite la misma corrida
  for _i37 in $(seq 1 200); do
    _l37=''; _n37=$(( RANDOM % 40 ))
    for _j37 in $(seq 0 "$_n37"); do
      case $(( RANDOM % 12 )) in
        0) _l37+="$CR37" ;;    1) _l37+='<!--' ;;  2) _l37+='-->' ;;
        3) _l37+='Estado: ' ;; 4) _l37+='x' ;;     5) _l37+=' ' ;;
        6) _l37+='<!' ;;       7) _l37+='--' ;;
        # Las cuatro fichas de la clase, TAMBIÉN en el azar: sin ellas el generador produce
        # 200 líneas que acreditan la equivalencia sobre el caso fácil (QA-017-02).
        8) _l37+=$'\xc3' ;;    9) _l37+=$'\xc3\x5c' ;;
        10) _l37+=$'\xff' ;;   *) _l37+=$'\xe2' ;;
      esac
    done
    printf '%s\n' "$_l37"
  done
} > "$CORPUS37"

# ¿EL CORPUS CONSERVA LA CLASE? Se le pregunta AL CORPUS, byte a byte y bajo `LC_ALL=C`, así
# que la respuesta no depende de la versión de bash ni del locale de la máquina — que es
# justo lo que CA-01 exige de esta mitad: «se comprueba sobre el corpus, sin depender de la
# máquina». La gramática de UTF-8 cabe en una expresión regular sobre CLASES de byte: se
# traduce cada byte a su clase (A = ASCII, c = continuación, 2/3/4 = cabecera de n bytes,
# X = byte imposible) y una línea es UTF-8 válido si y sólo si su traducción casa
# `^(A|2c|3cc|4ccc)*$`. Cada `tr` posterior sólo puede tocar bytes >= 0x80, porque el primero
# ya mandó TODO lo ASCII a la 'A': no hay colisión entre las clases y sus propias letras.
NINV37="$( LC_ALL=C tr '\000-\011\013-\177' 'A' < "$CORPUS37" \
         | LC_ALL=C tr '\200-\277' 'c' \
         | LC_ALL=C tr '\300-\301\365-\377' 'X' \
         | LC_ALL=C tr '\302-\337' '2' \
         | LC_ALL=C tr '\340-\357' '3' \
         | LC_ALL=C tr '\360-\364' '4' \
         | LC_ALL=C grep -Evc '^(A|2c|3cc|4ccc)*$' || true )"
FALTA37=''
for _p37 in "$CR37" "${CR37}Estado" "completado$CR37" "Esta${CR37}do" "<!$CR37--" "<!--$CR37" \
            "-->" '<!-- rango que abre' "$BINV37" $'\xff' $'\xc3\x5c' $'\xe2' $'\xf0'; do
  LC_ALL=C grep -qF -- "$_p37" "$CORPUS37" || FALTA37="$FALTA37 <$(printf '%s' "$_p37" | cat -v)>"
done
N37="$(grep -c '^' "$CORPUS37" || true)"
CLASE37_FALTA=no
{ [ -n "$FALTA37" ] || ! num37 "$NINV37" || [ "$NINV37" -lt 1 ]; } && CLASE37_FALTA=si

# --- El evaluador: k evaluaciones dentro del MISMO proceso ---------------------
# El no determinismo que aquí se busca aparece ENTRE LLAMADAS, no entre procesos, así que k
# evaluaciones en procesos distintos no medirían la propiedad que CA-01 nombra. El locale es
# el del proceso —lo fija quien invoca—, y por eso hay una invocación por locale.
#
# NO SE TOCA LO MEDIDO. El estado se imprime CRUDO, sin sustituir ni recortar: escapar aquí el
# CR con `${l//...}` metería EN EL INSTRUMENTO la misma familia de operación con patrón que
# hace no determinista a `arnes_norm_clave` (QA-017-07), y entonces la clasificación estaría
# midiendo la sonda. Quien quiera leerlo lo pasa por `cat -v`, y eso hace el diagnóstico.
EVA37="$RAIZ/eva37-$BASHPID.sh"
cat > "$EVA37" <<'EVA37FIN'
LIB="$1"; CORPUS="$2"; K="$3"; MODO="$4"
source "$LIB" >/dev/null 2>&1 || { printf 'SIN-LIB\n'; exit 1; }
declare -F arnes_sin_cita >/dev/null 2>&1 || { printf 'SIN-FN\n'; exit 1; }
n=0
if [ "$MODO" = indep ]; then
  # `<n>:<r>:<cita>,<cr>:<ARNES_LINEA>|<ARNES_CR_LINEA>` — los dos primeros campos no pueden
  # llevar ':' ni ',', así que el resto se recupera entero por muy raro que sea el texto.
  while IFS= read -r l || [ -n "$l" ]; do
    n=$((n+1)); r=0
    while [ "$r" -lt "$K" ]; do
      r=$((r+1))
      ARNES_CITA=0; ARNES_CR=0; ARNES_CR_LINEA=''; ARNES_LINEA='__sin_tocar__'
      arnes_sin_cita "$l"
      printf '%s:%s:%s,%s:%s|%s\n' "$n" "$r" "$ARNES_CITA" "$ARNES_CR" "$ARNES_LINEA" "$ARNES_CR_LINEA"
    done
  done < "$CORPUS"
else
  # En SECUENCIA el estado cruza líneas, así que la unidad no es la entrada sino el
  # RECORRIDO entero: se repite k veces y se dice si el recorrido REPITE, que es la misma
  # propiedad del dominio aplicada a un documento en vez de a una línea.
  primera=''; repite=si; r=0
  while [ "$r" -lt "$K" ]; do
    r=$((r+1)); n=0; acc=''
    ARNES_CITA=0; ARNES_CR=0; ARNES_CR_LINEA=''
    while IFS= read -r l || [ -n "$l" ]; do
      n=$((n+1)); ARNES_LINEA='__sin_tocar__'
      arnes_sin_cita "$l"
      acc+="$n:$ARNES_CITA,$ARNES_CR:$ARNES_LINEA|$ARNES_CR_LINEA"$'\n'
    done < "$CORPUS"
    [ "$n" -gt 0 ] || { printf 'CORPUS-VACIO\n'; exit 1; }
    if [ "$r" -eq 1 ]; then primera="$acc"; elif [ "$acc" != "$primera" ]; then repite=no; fi
  done
  printf 'REPITE %s\n' "$repite"
  printf '%s' "$primera"
fi
[ "$n" -gt 0 ] || { printf 'CORPUS-VACIO\n'; exit 1; }
EVA37FIN

# --- El clasificador: una sola pasada que alimenta a CA-01 Y a CA-10 -----------
# SE PAGA UNA VEZ. Las dos mitades del dominio necesitan exactamente la misma medición, y
# hacerla dos veces sería además dos transcripciones de la misma regla, que se desfasan.
CLA37="$RAIZ/cla37-$BASHPID.sh"
cat > "$CLA37" <<'CLA37FIN'
# <her-env> <her-C> <este-env> <este-C> <k> <salida: índices DENTRO>
HE="$1"; HC="$2"; EE="$3"; EC="$4"; K="$5"; OUT="$6"
declare -A hed het hcd hct eed eet ecd ect CLASE
N=0
carga() {   # <archivo> <array de decisiones> <array de textos>
  local -n _d="$2" _t="$3"
  local linea idx s rep dec txt
  while IFS= read -r linea || [ -n "$linea" ]; do
    idx="${linea%%:*}"; s="${linea#*:}"
    case "$idx" in ''|*[!0-9]*) continue ;; esac
    rep="${s%%:*}"; s="${s#*:}"
    dec="${s%%:*}"; txt="${s#*:}"
    _d["$idx $rep"]="$dec"; _t["$idx $rep"]="$txt"
    [ "$idx" -le "$N" ] || N="$idx"
  done < "$1"
}

# --- PASO 1: LA PARTICIÓN, CON LA HEREDADA SOLA -------------------------------
# Aquí todavía no se ha leído ni un byte de este árbol, y no es una casualidad del orden en
# que se escribió: es la regla 3 de `ADR-004`. Un dominio que mirase a este árbol para
# decidir la pertenencia haría de CA-01 un criterio que no puede fallar.
carga "$HE" hed het
carga "$HC" hcd hct
[ "$N" -gt 0 ] || { printf 'VACIO\n'; exit 1; }
dentro=0; fuera=0; noclas=0; ids=''
for ((i = 1; i <= N; i++)); do
  # (a) ¿HAY ORÁCULO? Un oráculo que no repite no es un oráculo: si la heredada tampoco
  # publica UNA decisión bajo `LC_ALL=C`, la entrada NO ES CLASIFICABLE y se cuenta aparte,
  # en vez de comparar contra un valor que no existe.
  o="${hcd[$i 1]-}"; ok=si
  for ((r = 2; r <= K; r++)); do [ "${hcd[$i $r]-}" = "$o" ] || { ok=no; break; }; done
  if [ "$ok" != si ]; then CLASE[$i]=noclas; noclas=$((noclas + 1)); continue; fi
  # (b) ¿UN ÚNICO Y EL MISMO ESTADO en las 2k evaluaciones? Las dos propiedades a la vez:
  # que repita (determinismo) y que decida lo mismo en los dos locales (invariancia).
  e0="${hed[$i 1]-}:${het[$i 1]-}"; ok=si
  for ((r = 1; r <= K; r++)); do
    [ "${hed[$i $r]-}:${het[$i $r]-}" = "$e0" ] || { ok=no; break; }
    [ "${hcd[$i $r]-}:${hct[$i $r]-}" = "$e0" ] || { ok=no; break; }
  done
  if [ "$ok" = si ]; then CLASE[$i]=dentro; dentro=$((dentro + 1)); ids+="$i"$'\n'
  else CLASE[$i]=fuera; fuera=$((fuera + 1)); fi
done
printf '%s' "$ids" > "$OUT"

# --- PASO 2: AHORA SÍ, ESTE ÁRBOL ---------------------------------------------
carga "$EE" eed eet
carga "$EC" ecd ect
ca01div=0; ca01nodet=0; ca10i=0; ca10ii=0; herdet=0; herinv=0; ej01=''; ej10=''
for ((i = 1; i <= N; i++)); do
  case "${CLASE[$i]-}" in
    dentro)
      # CA-01: este árbol determinista sobre el dominio, y su estado IGUAL byte a byte al de
      # la heredada — los CUATRO valores, no sólo la decisión.
      e0="${eed[$i 1]-}:${eet[$i 1]-}"; ok=si
      for ((r = 2; r <= K; r++)); do [ "${eed[$i $r]-}:${eet[$i $r]-}" = "$e0" ] || { ok=no; break; }; done
      if [ "$ok" != si ]; then
        ca01nodet=$((ca01nodet + 1))
        [ -n "$ej01" ] || ej01="entrada $i: este árbol NO repite dentro del dominio (<$e0> frente a <${eed[$i 2]-}:${eet[$i 2]-}>)"
      fi
      h0="${hed[$i 1]-}:${het[$i 1]-}"
      if [ "$e0" != "$h0" ]; then
        ca01div=$((ca01div + 1))
        [ -n "$ej01" ] || ej01="entrada $i: heredada <$h0> · este <$e0>"
      fi ;;
    fuera)
      # CA-10 (i): la DECISIÓN de este árbol, determinista E invariante al locale. Fuera del
      # dominio NO se contrata el valor del texto (`ARNES_LINEA`, `ARNES_CR_LINEA`): se
      # construye con las mismas operaciones con patrón de QA-017-07, y contratarlo sería
      # contratar un defecto ajeno y preexistente.
      d0="${eed[$i 1]-}"; ok=si
      for ((r = 2; r <= K; r++)); do [ "${eed[$i $r]-}" = "$d0" ] || { ok=no; break; }; done
      if [ "$ok" = si ]; then
        for ((r = 1; r <= K; r++)); do [ "${ecd[$i $r]-}" = "$d0" ] || { ok=no; break; }; done
      fi
      if [ "$ok" != si ]; then
        ca10i=$((ca10i + 1))
        [ -n "$ej10" ] || ej10="entrada $i: este árbol no decide siempre lo mismo (<$d0> · env <${eed[$i 2]-}> · C <${ecd[$i 1]-}>)"
      fi
      # CA-10 (ii): y esa decisión es la DEL ORÁCULO. Sin esto, (i) lo cumpliría también una
      # implementación que decidiera siempre lo mismo: constante, no correcta.
      if [ "$d0" != "${hcd[$i 1]-}" ]; then
        ca10ii=$((ca10ii + 1))
        [ -n "$ej10" ] || ej10="entrada $i: oráculo <${hcd[$i 1]-}> · este <$d0>"
      fi
      # CA-10 (iii): lo que la HEREDADA incumple bajo el locale del entorno. Se REGISTRA y no
      # se falla por ello: es el fail-before de este criterio, no su puerta.
      hd0="${hed[$i 1]-}"; ok=si
      for ((r = 2; r <= K; r++)); do [ "${hed[$i $r]-}" = "$hd0" ] || { ok=no; break; }; done
      [ "$ok" = si ] || herdet=$((herdet + 1))
      [ "$hd0" = "${hcd[$i 1]-}" ] || herinv=$((herinv + 1)) ;;
  esac
done
printf 'N %s\nDENTRO %s\nFUERA %s\nNOCLAS %s\nCA01DIV %s\nCA01NODET %s\nCA10I %s\nCA10II %s\nHERDET %s\nHERINV %s\n' \
  "$N" "$dentro" "$fuera" "$noclas" "$ca01div" "$ca01nodet" "$ca10i" "$ca10ii" "$herdet" "$herinv"
[ -z "$ej01" ] || printf 'EJ01 %s\n' "$ej01"
[ -z "$ej10" ] || printf 'EJ10 %s\n' "$ej10"
CLA37FIN

K37=6   # k >= 3 en CA-01 y CA-10, y es OPERATIVO: se sube con la medición. QA midió con 6.
EVHE37="$RAIZ/ev37-her-env-$BASHPID"; EVHC37="$RAIZ/ev37-her-c-$BASHPID"
EVEE37="$RAIZ/ev37-este-env-$BASHPID"; EVEC37="$RAIZ/ev37-este-c-$BASHPID"
DENTRO37="$RAIZ/ev37-dentro-$BASHPID"; RES37="$RAIZ/ev37-resumen-$BASHPID"
CORPD37="$RAIZ/corpus37-dentro-$BASHPID"
declare -A CNT37
CLAS37_OK=no; CLAS37_MOTIVO=''
if [ "$HER37_OK" != si ]; then
  CLAS37_MOTIVO="no hay línea base: el tag v1.32.1 no está en este clon"
else
  # LA HEREDADA PRIMERO, LOS DOS LOCALES, Y LA PARTICIÓN SALE DE AHÍ. Sólo después este árbol.
  bash          "$EVA37" "$HER37/hooks/lib.sh" "$CORPUS37" "$K37" indep > "$EVHE37" 2>/dev/null
  LC_ALL=C bash "$EVA37" "$HER37/hooks/lib.sh" "$CORPUS37" "$K37" indep > "$EVHC37" 2>/dev/null
  bash          "$EVA37" "$LIB37"              "$CORPUS37" "$K37" indep > "$EVEE37" 2>/dev/null
  LC_ALL=C bash "$EVA37" "$LIB37"              "$CORPUS37" "$K37" indep > "$EVEC37" 2>/dev/null
  if bash "$CLA37" "$EVHE37" "$EVHC37" "$EVEE37" "$EVEC37" "$K37" "$DENTRO37" > "$RES37" 2>/dev/null; then
    while IFS=' ' read -r _k37 _v37; do CNT37[$_k37]="$_v37"; done < "$RES37"
    if num37 "${CNT37[N]:-}" && [ "${CNT37[N]:-0}" -gt 0 ]; then CLAS37_OK=si
    else CLAS37_MOTIVO="el clasificador no devolvió una partición legible"; fi
  else
    CLAS37_MOTIVO='el clasificador no pudo leer las cuatro evaluaciones (¿corpus vacío, o un lib.sh que no carga?)'
  fi
fi

# El corpus DENTRO del dominio, en el orden del corpus: es sobre él, y sólo sobre él, sobre
# el que CA-01 afirma la igualdad byte a byte.
if [ "$CLAS37_OK" = si ]; then
  declare -A ESDENTRO37
  while IFS= read -r _i37; do [ -n "$_i37" ] && ESDENTRO37[$_i37]=1; done < "$DENTRO37"
  { _n37=0
    while IFS= read -r _l37 || [ -n "$_l37" ]; do
      _n37=$((_n37 + 1))
      [ -z "${ESDENTRO37[$_n37]:-}" ] || printf '%s\n' "$_l37"
    done < "$CORPUS37"
  } > "$CORPD37"
fi

# guarda37 <nombre> — LAS DOS DECISIONES QUE COMPARTEN CA-01 Y CA-10, en un solo sitio:
# FALLA si el corpus perdió la clase (culpa de este banco, y tiene que doler) y SKIP CITANDO
# bash, locale y recuentos si es la máquina la que no tiene el defecto (falta de sujeto).
# Devuelve 1 cuando ya ha emitido veredicto.
guarda37() {
  local nombre="$1"
  if [ "$CLASE37_FALTA" = si ]; then
    echo "  FAIL  $nombre  el corpus ($N37 entradas) perdió la clase que CA-01 declara: $NINV37 líneas con UTF-8 inválido y faltan${FALTA37:- (ninguna ficha nombrada)}"; FAIL=$((FAIL + 1)); return 1
  fi
  if [ "$CLAS37_OK" != si ]; then
    echo "  SKIP  $nombre  no se pudo clasificar el corpus: ${CLAS37_MOTIVO:-sin motivo} ($CTX37)"; return 1
  fi
  if [ "${CNT37[FUERA]:-0}" -eq 0 ]; then
    echo "  SKIP  $nombre  esta máquina no tiene el defecto — $CTX37; dentro ${CNT37[DENTRO]:-0} · fuera 0 · no clasificables ${CNT37[NOCLAS]:-0} de ${CNT37[N]:-0}. Con locale C/POSIX el conjunto de fuera es vacío POR CONSTRUCCIÓN: el entorno y el oráculo son el mismo locale"; return 1
  fi
  return 0
}
PART37="dentro ${CNT37[DENTRO]:-0} · fuera ${CNT37[FUERA]:-0} · no clasificables ${CNT37[NOCLAS]:-0} de ${CNT37[N]:-0}"
ej37() { [ -z "${1:-}" ] || printf '%s\n' "$1" | cat -v | head -3 | sed 's/^/          /'; }

# ---------- CA-01 · LA EQUIVALENCIA, DENTRO DEL DOMINIO ----------
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-01 diferencial dentro del dominio" | grep -qi -- "$FILTRO"; then
  nom37="REQ-017 CA-01 diferencial dentro del dominio: cada línea por separado (ARNES_LINEA/CITA/CR/CR_LINEA)"
  if guarda37 "$nom37"; then
    if [ "${CNT37[CA01DIV]:-1}" -eq 0 ] && [ "${CNT37[CA01NODET]:-1}" -eq 0 ]; then
      echo "  PASS  $nom37  ($PART37; estado idéntico byte a byte y este árbol repite k=$K37)"; PASS=$((PASS + 1))
    else
      echo "  FAIL  $nom37  ${CNT37[CA01DIV]:-?} divergencias y ${CNT37[CA01NODET]:-?} no determinismos DENTRO del dominio, donde CA-01 exige 0 ($PART37):"; FAIL=$((FAIL + 1))
      ej37 "${CNT37[EJ01]:-}"
    fi
  fi
fi

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-01 en secuencia" | grep -qi -- "$FILTRO"; then
  nom37="REQ-017 CA-01 ...y en secuencia, que es donde el estado de cita y de CR cruza líneas"
  if guarda37 "$nom37"; then
    # EL DOMINIO, APLICADO AL RECORRIDO. La pertenencia se calculó línea a línea con el
    # estado en cero; en secuencia una línea puede evaluarse con la cita abierta, que es OTRO
    # camino. Así que la MISMA propiedad se le exige al recorrido entero antes de comparar:
    # si la heredada no lo repite en los dos locales, el recorrido no está en el dominio.
    sqhe37="$RAIZ/sq37-her-env-$BASHPID"; sqhc37="$RAIZ/sq37-her-c-$BASHPID"
    sqee37="$RAIZ/sq37-este-env-$BASHPID"
    bash          "$EVA37" "$HER37/hooks/lib.sh" "$CORPD37" "$K37" secuencia > "$sqhe37" 2>/dev/null
    LC_ALL=C bash "$EVA37" "$HER37/hooks/lib.sh" "$CORPD37" "$K37" secuencia > "$sqhc37" 2>/dev/null
    bash          "$EVA37" "$LIB37"              "$CORPD37" "$K37" secuencia > "$sqee37" 2>/dev/null
    rhe37=''; rhc37=''; ree37=''
    IFS= read -r rhe37 < "$sqhe37" || true
    IFS= read -r rhc37 < "$sqhc37" || true
    IFS= read -r ree37 < "$sqee37" || true
    if [ "$rhe37" != 'REPITE si' ] || [ "$rhc37" != 'REPITE si' ] || ! cmp -s "$sqhe37" "$sqhc37"; then
      echo "  SKIP  $nom37  el RECORRIDO no está en el dominio: la heredada no lo repite igual en los dos locales (env <${rhe37:-vacío}> · C <${rhc37:-vacío}>) — $CTX37, $PART37"
    elif [ "$ree37" != 'REPITE si' ]; then
      echo "  FAIL  $nom37  este árbol NO repite el recorrido en k=$K37 pasadas del mismo proceso (<${ree37:-vacío}>)"; FAIL=$((FAIL + 1))
    elif cmp -s "$sqhe37" "$sqee37"; then
      echo "  PASS  $nom37  ($PART37; el recorrido de las ${CNT37[DENTRO]:-0} entradas del dominio sale idéntico byte a byte)"; PASS=$((PASS + 1))
    else
      echo "  FAIL  $nom37  el recorrido difiere de v1.32.1 dentro del dominio:"; FAIL=$((FAIL + 1))
      diff "$sqhe37" "$sqee37" 2>/dev/null | cat -v | head -6 | sed 's/^/          /'
    fi
    rm -f "$sqhe37" "$sqhc37" "$sqee37"
  fi
fi

# El corpus tiene que CONTENER las fronteras que CA-01 nombra Y la clase de la que depende la
# partición entera: un corpus generado que no las produjera dejaría la equivalencia acreditada
# sobre el caso fácil, y la mitad de CA-10 sin sujeto para siempre.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-01 el corpus conserva" | grep -qi -- "$FILTRO"; then
  if [ "$CLASE37_FALTA" != si ]; then
    echo "  PASS  REQ-017 CA-01 el corpus conserva las fronteras nombradas y la clase que no puede perder ($N37 entradas, $NINV37 con UTF-8 inválido, semilla fija)"; PASS=$((PASS + 1))
  else
    echo "  FAIL  REQ-017 CA-01 el corpus ($N37 entradas, $NINV37 con UTF-8 inválido) perdió trabajo:${FALTA37:- ninguna ficha nombrada falta, pero no queda ni una entrada de la clase}"; FAIL=$((FAIL + 1))
  fi
fi

# ---------- CA-10 · FUERA DEL DOMINIO SE CONTRATA LA DIRECCIÓN, CONTRA UN ORÁCULO ----------
# Tres casos, uno por mitad, de la MISMA pasada de clasificación. Cada uno publica bash,
# locale y el recuento de la partición: ése es el dato con el que un SKIP se distingue de un
# verde vacío. Un caso que no pueda nombrar su recuento no está midiendo la partición.
ora37() {   # <nombre> — la guarda del ORÁCULO, además de las dos de `guarda37`
  local nombre="$1"
  guarda37 "$nombre" || return 1
  if [ "${CNT37[NOCLAS]:-0}" -ne 0 ]; then
    echo "  SKIP  $nombre  ${CNT37[NOCLAS]} entradas NO son clasificables: la heredada tampoco publica una decisión única bajo LC_ALL=C, y un oráculo que no repite no es un oráculo — $CTX37, $PART37"; return 1
  fi
  return 0
}
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-10 (i)" | grep -qi -- "$FILTRO"; then
  nom37="REQ-017 CA-10 (i) fuera del dominio este árbol decide siempre lo mismo, y lo mismo en los dos locales"
  if ora37 "$nom37"; then
    if [ "${CNT37[CA10I]:-1}" -eq 0 ]; then
      echo "  PASS  $nom37  0 de ${CNT37[FUERA]} violaciones de determinismo o invariancia de la DECISIÓN (k=$K37 por locale) — $CTX37, $PART37"; PASS=$((PASS + 1))
    else
      echo "  FAIL  $nom37  ${CNT37[CA10I]} de ${CNT37[FUERA]} entradas de fuera en que este árbol no decide siempre lo mismo — $CTX37, $PART37:"; FAIL=$((FAIL + 1))
      ej37 "${CNT37[EJ10]:-}"
    fi
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-10 (ii)" | grep -qi -- "$FILTRO"; then
  nom37="REQ-017 CA-10 (ii) ...y esa decisión es la del ORÁCULO: la heredada bajo LC_ALL=C"
  if ora37 "$nom37"; then
    if [ "${CNT37[CA10II]:-1}" -eq 0 ]; then
      echo "  PASS  $nom37  las ${CNT37[FUERA]} entradas de fuera coinciden con el oráculo; sin esta mitad, (i) la cumpliría también una implementación CONSTANTE — $CTX37, $PART37"; PASS=$((PASS + 1))
    else
      echo "  FAIL  $nom37  ${CNT37[CA10II]} de ${CNT37[FUERA]} entradas de fuera en que este árbol se aparta del oráculo — $CTX37, $PART37:"; FAIL=$((FAIL + 1))
      ej37 "${CNT37[EJ10]:-}"
    fi
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-10 (iii)" | grep -qi -- "$FILTRO"; then
  nom37="REQ-017 CA-10 (iii) fail-before: la heredada bajo el locale del entorno NO cumple (i) o (ii), y se registra sin fallar por ello"
  if ora37 "$nom37"; then
    _inc37=$(( ${CNT37[HERDET]:-0} + ${CNT37[HERINV]:-0} ))
    if [ "$_inc37" -ge 1 ]; then
      # NUNCA FAIL: lo que la heredada incumpla no es un defecto de este árbol. Y nunca PASS
      # vacío: si no incumpliera nada, (i) y (ii) las cumpliría cualquier implementación y
      # este criterio no tendría sujeto — que es falta de sujeto, o sea SKIP.
      echo "  PASS  $nom37  la heredada incumple el DETERMINISMO en ${CNT37[HERDET]:-0} de ${CNT37[FUERA]} y la INVARIANCIA DE LOCALE en ${CNT37[HERINV]:-0} de ${CNT37[FUERA]}; este árbol, 0 y 0 — $CTX37, $PART37"; PASS=$((PASS + 1))
    else
      echo "  SKIP  $nom37  en esta máquina la heredada cumple las dos propiedades sobre las ${CNT37[FUERA]} entradas de fuera: sin incumplimiento no hay fail-before que registrar — $CTX37, $PART37"
    fi
  fi
fi

# ---------- CA-03 · EL COCIENTE DE DUPLICACIÓN ----------
# La propiedad estructural: doblar la entrada y comparar el cociente de los mínimos.
# Lineal ≈ 2, cuadrático ≈ 4. La velocidad de la máquina se cancela.
# k=20 sobre 70 000 bytes es lo que hace falta para pasar el suelo de 50 ms EN ESTE ÁRBOL
# (con k=10 la serie corta se queda en ~49 ms y la sonda tendría que decir SKIP).
S37=70000
u1_37=''; u2_37=''
mide37 "$LIB37" arnes_sin_cita "$S37"          20 && u1_37="$MED37_US"
mide37 "$LIB37" arnes_sin_cita "$(( S37 * 2 ))" 20 && u2_37="$MED37_US"
razon37 "REQ-017 CA-03 el escáner no crece más que linealmente: doblar la línea no cuadruplica" \
  "$u2_37" "$u1_37" 2600 "cociente de duplicación (${S37}→$(( S37 * 2 )) bytes, k=20)"

# FAIL-BEFORE. Un cociente verde no prueba nada si la sonda daría verde también sobre el
# árbol enfermo: se comprueba que sobre v1.32.1 el MISMO cociente se pasa del techo. Con
# k=1 basta —el árbol cuadrático cruza el suelo de 50 ms de sobra— y así el fail-before
# cuesta segundos en vez de medio minuto.
h1_37=''; h2_37=''
if [ "$HER37_OK" = si ]; then
  mide37 "$HER37/hooks/lib.sh" arnes_sin_cita "$S37"           1 && h1_37="$MED37_US"
  mide37 "$HER37/hooks/lib.sh" arnes_sin_cita "$(( S37 * 2 ))" 1 && h2_37="$MED37_US"
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-03 fail-before" | grep -qi -- "$FILTRO"; then
  if [ -z "$h1_37" ] || [ -z "$h2_37" ]; then
    echo "  SKIP  REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático  no hay línea base v1.32.1 (${MED37_MOTIVO:-tag ausente})"
  elif [ "$h1_37" -lt 50000 ] || [ "$h2_37" -lt 50000 ]; then
    echo "  SKIP  REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático  serie bajo el suelo de 50 ms (${h1_37}µs / ${h2_37}µs)"
  else
    coc37=$(( h2_37 * 1000 / h1_37 ))
    if [ "$coc37" -gt 2600 ]; then
      echo "  PASS  REQ-017 CA-03 fail-before: sobre v1.32.1 el mismo cociente da $(awk -v c=$coc37 'BEGIN{printf "%.3f", c/1000}')× y se pasa del techo 2,600×"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-017 CA-03 fail-before: sobre v1.32.1 el cociente da $(awk -v c=$coc37 'BEGIN{printf "%.3f", c/1000}')× y NO se pasa: la sonda no distingue el defecto que este REQ arregla"; FAIL=$((FAIL+1))
    fi
  fi
fi

# ---------- CA-04 · LA RAZÓN CONTRA LA ÚLTIMA VERSIÓN SIN LA GUARDA ----------
# DESVIACIÓN DECLARADA, y no es un atajo: v1.32.0 NO TIENE `arnes_sin_cita` —la noción de
# cita nace en 1.32.1 (REQ-016)—, así que la comparación literal «su `arnes_sin_cita`» no
# existe. Lo comparable es la MISMA BOCA: la función que recibe una línea cruda de
# cabecera y devuelve un campo. En v1.32.0 es `arnes_norm_clave`; en este árbol es
# `arnes_campo_linea`, que es `arnes_sin_cita` MÁS `arnes_norm_clave`. Se compara el
# camino entero contra el camino entero, que además es la lectura ESTRICTA: mide el coste
# que la guarda AÑADIÓ, incluyéndose a sí misma.
c37=''; b37=''
mide37 "$LIB37" arnes_campo_linea 140000 10 && c37="$MED37_US"
[ "$BAS37_OK" = si ] && { mide37 "$BAS37/hooks/lib.sh" arnes_norm_clave 140000 10 && b37="$MED37_US"; }
razon37 "REQ-017 CA-04 el camino de campo no cuesta más de 2× lo que costaba en v1.32.0 (140 000 bytes sin CR)" \
  "$c37" "$b37" 2000 "razón contra v1.32.0"

# FAIL-BEFORE de CA-04, con k=2: el árbol enfermo se pasa de 2× por goleada.
ch37=''; cb37=''
if [ "$HER37_OK" = si ] && [ "$BAS37_OK" = si ]; then
  mide37 "$HER37/hooks/lib.sh" arnes_campo_linea 140000 2 && ch37="$MED37_US"
  mide37 "$BAS37/hooks/lib.sh" arnes_norm_clave  140000 2 && cb37="$MED37_US"
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-04 fail-before" | grep -qi -- "$FILTRO"; then
  if [ -z "$ch37" ] || [ -z "$cb37" ] || [ "$ch37" -lt 50000 ]; then
    echo "  SKIP  REQ-017 CA-04 fail-before: la razón delata a v1.32.1  falta línea base o serie bajo el suelo (v1.32.1=<${ch37:-vacío}>µs v1.32.0=<${cb37:-vacío}>µs)"
  else
    r37=$(( ch37 * 1000 / cb37 ))
    if [ "$r37" -gt 2000 ]; then
      echo "  PASS  REQ-017 CA-04 fail-before: v1.32.1 cuesta $(awk -v c=$r37 'BEGIN{printf "%.3f", c/1000}')× lo de v1.32.0 y se pasa del techo 2,000×"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-017 CA-04 fail-before: v1.32.1 cuesta $(awk -v c=$r37 'BEGIN{printf "%.3f", c/1000}')× y NO se pasa: el caso pasaría contra el árbol enfermo"; FAIL=$((FAIL+1))
    fi
  fi
fi

# ---------- CA-06 · UNA SONDA QUE NO PUEDE MEDIR DICE SKIP, NUNCA PASS ----------
# Se comprueba sobre la sonda REAL, no sobre una imitación: se le pide una línea base que
# no existe y se mira qué VEREDICTO habría emitido. Un instrumento que ante la ausencia
# de datos responde PASS es peor que no tener instrumento, porque además tranquiliza.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-06 sin línea base" | grep -qi -- "$FILTRO"; then
  sal37="$( { razon37 "sonda-de-prueba" "" "123456" 2000 "x"; razon37 "sonda-de-prueba" "1000" "1000" 2000 "x"; } 2>&1 )"
  nskip37="$(printf '%s\n' "$sal37" | grep -c '^  SKIP ' || true)"
  npass37="$(printf '%s\n' "$sal37" | grep -c '^  PASS ' || true)"
  if [ "${nskip37:-0}" -eq 2 ] && [ "${npass37:-0}" -eq 0 ]; then
    echo "  PASS  REQ-017 CA-06 sin línea base y bajo el suelo de 50 ms la sonda emite SKIP con motivo, nunca PASS"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-017 CA-06 sin línea base la sonda emitió $nskip37 SKIP y $npass37 PASS (se esperaban 2 y 0)"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan: `razon37` corrió dentro de una sustitución de comandos, que
# es un subshell, así que sus PASS/FAIL murieron con él. Se dice porque un lector que no
# lo sepa creerá que este caso descuadra el recuento de la sección.

# ---------- CA-09 · LA PARED DE LOS 60 s: SE MIDE, NO SE MUEVE ----------
# Un hook `PreToolUse` muere a los 60 s y UN HOOK MUERTO NO DENIEGA. Mover esa pared es
# SEC-030, preexistente en los DOS árboles y con dueño propio: aquí sólo se MIDE y se
# deja escrito, que es lo que CA-09 exige. El tamaño de los 60 s se extrapola desde el
# ORDEN DE CRECIMIENTO medido en la misma corrida (dos tamaños, cociente de duplicación),
# que es exactamente la metodología que CA-07 escribe: nunca un reloj absoluto.
PARED37="$RAIZ/pared37-$BASHPID.sh"
cat > "$PARED37" <<'PARED37FIN'
HD="$1"; PR="$2"; N="$3"
[ -n "${EPOCHREALTIME:-}" ] || { printf 'SIN-RELOJ\n'; exit 2; }
s=''; while [ ${#s} -lt 2048 ]; do s+='relleno de una sola linea de cabecera '; done
l=''; while [ ${#l} -lt "$N" ]; do l+="$s"; done; l="${l:0:N}"
printf '# REQ-900\nEstado: completado\n%s\n' "$l" > "$PR/doc37.txt"
# El contenido va por STDIN: `jq --arg` revienta el límite de UN argumento (128 KB) y
# devuelve JSON VACÍO — el hook no recibe nada, responde en 0,1 s y la sonda mide cero.
jq -Rs --arg fp "$PR/requirements/REQ-900.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.NADA,tool_input:{file_path:$fp,content:.}}' \
  < "$PR/doc37.txt" > "$PR/in37.json" 2>/dev/null
[ -s "$PR/in37.json" ] || { printf 'SIN-JSON\n'; exit 3; }
t0=${EPOCHREALTIME/./}
CLAUDE_PROJECT_DIR="$PR" timeout 120 bash "$HD/guard-completado.sh" < "$PR/in37.json" >/dev/null 2>&1
t1=${EPOCHREALTIME/./}
printf '%s\n' "$((t1-t0))"
PARED37FIN
printf '# REQ-900\nEstado: en-revisión\n' > "$PROJ/requirements/REQ-900.md"
pared37() {   # <dir de hooks> -> imprime los KB extrapolados (rc 0), o el motivo (rc 1)
  # EL COSTE FIJO SE RESTA ANTES DE MEDIR EL ORDEN, y sin eso la sonda MIENTE. A 96 KB el
  # arranque del hook (bash + jq + manifiesto) todavía pesa tanto como el escaneo, así que
  # el cociente de duplicación crudo sale ~1,3 sobre un camino que es cuadrático: la
  # extrapolación resultante colocaba la pared en 4,25 MB donde la medición directa a
  # 256/512/1024 KB la pone en 1,5. Se mide el término que crece —t(n) menos t(0)— que es
  # lo único de lo que depende el orden.
  #
  # DEVUELVE UN NÚMERO, NO UN TEXTO CON FORMA DE MB, y eso no es estilo: mientras esta sonda
  # imprimía «1,60 MB» el caso daba PASS por la FORMA de la cadena y nunca comparó nada
  # (QA-017-10). Un número se puede comparar con el de al lado; una cadena bonita, no.
  local hd="$1" u0 ua ub n=98304 kb x
  u0="$(bash "$PARED37" "$hd" "$PROJ" 0            2>/dev/null)"
  ua="$(bash "$PARED37" "$hd" "$PROJ" "$n"         2>/dev/null)"
  ub="$(bash "$PARED37" "$hd" "$PROJ" "$(( n*2 ))" 2>/dev/null)"
  # Uno a uno y no concatenados: con "$u0$ua$ub" un valor VACÍO desaparece dentro de los
  # dígitos del vecino y la guarda deja pasar la basura que existe para atrapar.
  for x in "$u0" "$ua" "$ub"; do
    num37 "$x" || { printf 'la sonda no devolvió un número (<%s> <%s> <%s>)' "${u0:-vacío}" "${ua:-vacío}" "${ub:-vacío}"; return 1; }
  done
  if [ "$(( ua - u0 ))" -lt 20000 ] || [ "$(( ub - u0 ))" -le "$(( ua - u0 ))" ]; then
    printf 'no medible en este rango: a %d KB el coste todavía lo domina el arranque (%d ms de arranque sobre %d ms)' \
      "$(( n*2/1024 ))" "$(( u0/1000 ))" "$(( ub/1000 ))"
    return 1
  fi
  kb="$(awk -v u0="$u0" -v ua="$ua" -v ub="$ub" -v n="$(( n*2 ))" 'BEGIN{
    a = ua - u0; b = ub - u0
    p = log(b/a)/log(2)
    if (p <= 0.05) { print "ORDEN-PLANO"; exit }
    kb = (n * exp(log((60e6 - u0)/b)/p))/1024
    if (kb > 1048576) print "FUERA-DE-RANGO"; else printf "%d", kb }')"
  case "$kb" in
    ORDEN-PLANO)    printf 'el orden medido es plano: en este rango el coste no depende del tamaño'; return 1 ;;
    FUERA-DE-RANGO) printf 'la extrapolación se va por encima de 1 GB: no hay régimen de crecimiento que medir'; return 1 ;;
    ''|*[!0-9]*)    printf 'la extrapolación no dio un número (<%s>)' "${kb:-vacío}"; return 1 ;;
  esac
  printf '%s' "$kb"
}

# LO ÚNICO QUE CA-09 CONTRATA SOBRE LA PARED ES LA DIRECCIÓN, Y PAREADA DENTRO DE SU PROPIA
# CORRIDA. La MAGNITUD y su dispersión (>= 6 corridas por árbol y rango) son del Historial de
# REQ-017 y de SEC-030, y aquí no se acreditan: la sonda NO REPITE —1,08 · 1,32 · 1,78 · 2,64
# · 2,65 · 3,98 MB en seis corridas del mismo árbol (QA-017-05)— y una cifra sin rango no se
# puede auditar. Lo que sí se sostiene es la dirección. Por eso lo que se publica aquí es una
# RAZÓN, que es la forma en que este REQ contrata todo lo demás, y no un tamaño.
#
# Y LA SONDA DECLARA SU RESOLUCIÓN ANTES DE JUZGAR, POR LA MISMA REGLA QUE CA-08 (ii) Y CON EL
# MISMO MOTIVO MEDIDO. Con UNA medida por árbol este caso salió ROJO 1 de cada 6 corridas
# —0,632× sobre un árbol cuya pared está de verdad más lejos, y con la máquina en reposo—,
# que es un rojo espurio en la PUERTA REQUERIDA de `main` y el camino más corto a que alguien
# lo apague. La causa no es el arreglo: es la sonda, que es de SEC-030 y cuya dispersión
# medida es un factor ~3,7 sobre el mismo árbol. Arreglarla NO es de este REQ; declarar que
# no resuelve, SÍ — y CA-09 lo nombra por su nombre: «si la sonda no converge, SKIP».
#
# Por eso se toman DOS medidas por árbol, INTERCALADAS (este, her, este, her) —en bloque los
# dos árboles ven vecinos distintos, que es la lección de QA-017-06—, y se compara por
# RANGOS, no por puntos:
#   * la dirección se afirma sólo si el PEOR de este árbol supera al MEJOR de la heredada;
#   * se niega sólo si el MEJOR de este árbol queda por debajo del PEOR de la heredada;
#   * y si los rangos SE SOLAPAN, la sonda no distingue la dirección de su propio ruido y el
#     caso se ABSTIENE con motivo. Un rojo tiene que significar regresión.
#
# Sin `FILTRO` dentro: la decisión se prueba abajo con entradas sintéticas llamándola por otro
# nombre, y un filtro comprobado aquí dentro dejaría esa prueba muda en cuanto alguien filtre.
dir09_37() {   # <nombre> <KB este·1> <KB este·2> <KB v1.32.1·1> <KB v1.32.1·2> (o motivos)
  local nombre="$1" e1="${2:-}" e2="${3:-}" h1="${4:-}" h2="${5:-}" emin emax hmin hmax x
  for x in "$e1" "$e2"; do
    num37 "$x" && [ "$x" -gt 0 ] && continue
    echo "  SKIP  $nombre  la sonda no midió este árbol en las dos pasadas: ${x:-sin motivo}"; return 0
  done
  for x in "$h1" "$h2"; do
    num37 "$x" && [ "$x" -gt 0 ] && continue
    echo "  SKIP  $nombre  la sonda no midió v1.32.1 al lado, y una comparación pareada necesita las dos: ${x:-sin motivo}"; return 0
  done
  if [ "$e1" -le "$e2" ]; then emin="$e1"; emax="$e2"; else emin="$e2"; emax="$e1"; fi
  if [ "$h1" -le "$h2" ]; then hmin="$h1"; hmax="$h2"; else hmin="$h2"; hmax="$h1"; fi
  if [ "$emin" -ge "$hmax" ]; then
    echo "  PASS  $nombre  el PEOR de este árbol vale $(awk -v c=$(( emin * 1000 / hmax )) 'BEGIN{printf "%.3f", c/1000}')× el MEJOR de v1.32.1 medido EN ESTA MISMA corrida (>= 1,000×; los rangos no se solapan, así que la dirección no es ruido). La magnitud es del Historial y de SEC-030"; PASS=$((PASS+1))
  elif [ "$emax" -lt "$hmin" ]; then
    echo "  FAIL  $nombre  el MEJOR de este árbol vale $(awk -v c=$(( emax * 1000 / hmin )) 'BEGIN{printf "%.3f", c/1000}')× el PEOR de v1.32.1: la pared BAJÓ en todos los emparejamientos, que es lo contrario de lo único que CA-09 contrata"; FAIL=$((FAIL+1))
  else
    echo "  SKIP  $nombre  los rangos de las dos pasadas SE SOLAPAN (este $(awk -v c=$(( emin * 1000 / hmax )) 'BEGIN{printf "%.3f", c/1000}')×–$(awk -v c=$(( emax * 1000 / hmin )) 'BEGIN{printf "%.3f", c/1000}')× de v1.32.1): la sonda no distingue la dirección de su propio ruido, y su dispersión (~3,7 sobre el mismo árbol) es de SEC-030, no de este REQ"
  fi
}

nom09_37="REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida"
if [ -z "$FILTRO" ] || printf '%s' "$nom09_37" | grep -qi -- "$FILTRO"; then
  sinher09_37='no hay línea base: el tag v1.32.1 no está en este clon'
  e1_37="$(pared37 "$HOOKS_DIR")" || true
  h1_37="$sinher09_37"; [ "$HER37_OK" != si ] || h1_37="$(pared37 "$HER37/hooks")" || true
  e2_37="$(pared37 "$HOOKS_DIR")" || true
  h2_37="$sinher09_37"; [ "$HER37_OK" != si ] || h2_37="$(pared37 "$HER37/hooks")" || true
  dir09_37 "$nom09_37" "$e1_37" "$e2_37" "$h1_37" "$h2_37"
fi

# La DECISIÓN de arriba, con entradas sintéticas y en milisegundos. Sin esto, la única
# propiedad que CA-09 contrata no tiene puerta: el caso anterior daba PASS porque el número
# impreso tenía forma de MB, así que habría seguido en verde con este árbol POR DEBAJO de la
# heredada — que es exactamente lo contrario de lo contratado (QA-017-10). Y probar la
# decisión aquí es además la única forma de acreditar la rama FAIL sin fabricar una regresión
# real de la pared, que no hay de dónde sacar.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-09 la dirección se COMPRUEBA" | grep -qi -- "$FILTRO"; then
  nom37="REQ-017 CA-09 la dirección se COMPRUEBA por rangos, no se publica: por debajo es FAIL y el solapamiento es SKIP"
  obs09_37="$( {
    dir09_37 sonda-de-prueba 2048 2200 1000 1100   # rangos disjuntos por arriba: la dirección
    dir09_37 sonda-de-prueba 1100 1200 1000 1100   # se tocan justo: «no menor» incluye la igualdad
    dir09_37 sonda-de-prueba  800  900 1000 1100   # disjuntos POR DEBAJO: aquí el caso viejo daba PASS
    dir09_37 sonda-de-prueba  900 1200 1000 1100   # SOLAPAN: la sonda no resuelve, se abstiene
    dir09_37 sonda-de-prueba 'no medible' 1200 1000 1100   # sin una de las dos pasadas de este árbol
    dir09_37 sonda-de-prueba 1000 1200 'no medible' 1100   # sin la heredada al lado: no hay pareja
    dir09_37 sonda-de-prueba 1000 1200 0 1100      # un cero no es una medida
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp09_37='PASS PASS FAIL SKIP SKIP SKIP SKIP '
  if [ "$obs09_37" = "$esp09_37" ]; then
    echo "  PASS  $nom37  (7 pares de rangos → $obs09_37)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom37  se esperaba <$esp09_37> y se obtuvo <$obs09_37>"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `dir09_37` corrió dentro de una sustitución de comandos,
# que es un subshell, y sus PASS/FAIL murieron con él.

rm -rf "$HER37" "$BAS37" "$CORPUS37" "$CORPD37" "$MED37" "$EVA37" "$CLA37" "$PARED37" \
       "$EVHE37" "$EVHC37" "$EVEE37" "$EVEC37" "$DENTRO37" "$RES37"
