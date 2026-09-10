# ---------- 37 (2/5) · EL COSTE DEL ESCÁNER: LAS RAZONES ----------
# REQ-017. La escala (CA-03), la razón contra la última versión sin la guarda (CA-04) y la
# regla de que una sonda que no pudo medir dice SKIP y nunca PASS (CA-06).
#
# POR QUÉ TODO AQUÍ SON RAZONES Y NO SEGUNDOS. Un techo en segundos lo falsea la máquina
# y lo falsea la carga —esta misma ventana midió lo que pasa cuando una sonda desbocada
# envenena el reloj de otra medición—. Un COCIENTE DE DUPLICACIÓN responde a la pregunta
# que se degradó (el orden de crecimiento) y la velocidad de la máquina se cancela
# algebraicamente; una RAZÓN contra una línea base medida en la MISMA corrida cancela la
# máquina por construcción. Y el estadístico es el MÍNIMO de k repeticiones, nunca la
# media: la carga sólo puede AÑADIR tiempo, así que el mínimo es la mejor estimación del
# coste real y la media es una mezcla de coste y de vecinos.
#
# PARTE 2 DE 5 POR REQ-014 CA-18: `mat37` viene DUPLICADO de las otras partes de 37/1 a
# propósito —CA-04, CA-19 y H-04 hacen imposible factorizarlo, y subirlo al corredor es
# cambio de mecanismo no autorizado—. Su motivo largo, y las cuatro propiedades de CA-05
# que porta, están escritos UNA vez, en `37-coste-del-escaner-1-el-dominio.sh`. Ésta es la
# única parte que materializa ADEMÁS v1.32.0: sólo la usa CA-04.
CASOS_ESPERADOS_SECCION=5
PISO_AUTONOMO_SECCION=200  # 24 preámbulo (líneas 1-24) + 122 maquinaria compartida duplicada (mat37 y las dos líneas base, líneas 25-146) + 54 bloque indivisible mayor (mide37 y razon37, el medidor y la única puerta de las tres razones, líneas 148-201) · REQ-014 CA-18
seccion_nueva "--- 37/2 · el coste del escáner: la escala y las razones (REQ-017 CA-03, CA-04 y CA-06) ---"

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
mat37() {   # <referencia> <destino> -> 0 si el árbol quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT37_T0=${EPOCHREALTIME/./}
  MAT37_REF="${ref//[[:space:]]/_}"; MAT37_ETIQ="$MAT37_REF"; MAT37_REG=''
  # `-e` Y NO `-d`, Y ESTÁ MEDIDO: en un `git worktree` —y en un submódulo— `.git` es un
  # ARCHIVO con un `gitdir:` dentro, no un directorio. Con `-d` este materializador decía
  # `sin-linea-base` en un worktree mientras `git` resolvía el tag perfectamente, así que las
  # dos secciones 37 se abstenían enteras: la copia haciendo la MITAD DEL TRABAJO, que es
  # exactamente el caso que CA-05 existe para cerrar, reintroducido por la guarda. Lo cazó la
  # medición de CA-08, que necesita dos árboles y por tanto un worktree. El código anterior a
  # la mudanza no tenía esta guarda; la trajo la sonda que sale del alcance.
  [ -e "$REPO37/.git" ] || { mat37_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  # Lo que decide es que `git` RESUELVA la referencia a un árbol, no de qué tipo sea: tag,
  # commit y rama dan exactamente el mismo trabajo (CA-05).
  procs=$((procs + 1))
  git -C "$REPO37" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat37_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  # Una sola llamada da la lista, LOS MODOS y los identificadores de objeto: la comprobación
  # del punto 1 no paga un recorrido aparte.
  procs=$((procs + 1))
  lista="$(git -C "$REPO37" ls-tree -r "$ref" -- $MAT37_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat37_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat37_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat37_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO37" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat37_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat37_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  # COMPRUEBA LO QUE DEJÓ, contenido y modo. Un solo `hash-object` para el lote entero.
  procs=$((procs + 1))
  calc="$(git -C "$REPO37" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat37_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat37_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat37_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat37_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat37_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat37_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat37_reg ok - "$n" "$procs"
  return 0
}
HER37="$RAIZ/her37-321-$BASHPID"; HER37_OK=no; REGHER37=''
mat37 v1.32.1 "$HER37" && HER37_OK=si
REGHER37="$MAT37_REG"
BAS37="$RAIZ/her37-320-$BASHPID"; BAS37_OK=no
mat37 v1.32.0 "$BAS37" && BAS37_OK=si
LIB37="$HOOKS_DIR/lib.sh"

# --- El medidor: `sonda-reloj.sh`, que impone el estadístico ------------------
# Cada árbol define las MISMAS funciones, así que medirlos en un solo proceso mediría el
# último que se cargó: la sonda corre en SU PROPIO proceso y se le pasa la carga del árbol
# en `--prep`, una vez por invocación en vez de una por serie. El mínimo de r series lo
# impone ella (CA-02), no este archivo: la regla ya estaba escrita y se incumplió dos veces.
# Se expone `MED37_MAX` junto al mínimo porque un veredicto que publica un mínimo y NO su
# máximo no dice si la sonda CONVERGIÓ, y sin eso un rojo no se puede atribuir: el FAIL del
# CI del 2026-09-09 publicaba el cociente y nada más, así que no había forma de saber cuál
# de los dos términos se había movido. El máximo es EVIDENCIA, no juez: quien decide sigue
# siendo el mínimo, que es el estadístico que CA-03 contrata.
MED37_US=''; MED37_MAX=''; MED37_MOTIVO=''; MED37_REG=''
mide37() {   # <lib> <fn> <bytes> <k> -> MED37_US/MED37_MAX = mínimo y máximo de 3 series, µs
  local lib="$1" fn="$2" n="$3" k="$4" reg
  MED37_US=''; MED37_MAX=''; MED37_MOTIVO=''; MED37_REG=''
  if [ ! -r "$lib" ]; then MED37_MOTIVO="no existe $lib"; return 1; fi
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "$fn-$n" \
    --prep "source '$lib' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; l37=''; while [ \${#l37} -lt $n ]; do l37+=\"\$s37\"; done; l37=\"\${l37:0:$n}\"" \
    --sujeto "ARNES_CITA=0; ARNES_CR=0; $fn \"\$l37\"" 2>/dev/null)"
  MED37_REG="$reg"
  if [ -z "$reg" ]; then MED37_MOTIVO='la sonda de reloj no dejó registro'; return 1; fi
  if ! sonda_lee "$reg"; then MED37_MOTIVO="$SONDA_MOTIVO"; return 1; fi
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
# árbol enfermo: se comprueba que sobre v1.32.1 el MISMO cociente se pasa del techo. Se
# mide con k=1 porque el árbol cuadrático cruza el suelo de 50 ms de sobra —una sola
# llamada sobre 70 000 bytes costó entre 77 ms y 392 ms ahí, en 40 mediciones del
# 2026-09-09, contra 4,4 ms en el árbol sano— y así el fail-before cuesta segundos.
#
# POR QUÉ k SIGUE EN 1, CONTRA LA PRIMERA LECTURA DEL ROJO DEL CI, Y ESTÁ MEDIDO. El
# 2026-09-09 este caso dio 2,329× en el CI (FAIL) contra 3,379× en la corrida anterior
# sobre EL MISMO tag inmutable, y la primera explicación fue que «con k=1 no hay mínimo que
# tomar: la única muestra ES el mínimo». Eso es falso, y la confusión está en que
# `sonda-reloj.sh` tiene DOS parámetros: `--k` son las repeticiones DENTRO de una serie
# (`sr_serie`) y `--r` son las SERIES, que es sobre lo que se toma el mínimo (`sr_minimo`).
# `mide37` pasa `--r 3` FIJO en todas sus llamadas, así que el fail-before con k=1 toma el
# mínimo de 3 muestras, las MISMAS que la medición directa con k=20. El estadístico nunca
# estuvo apagado.
#
# Y subir k no sólo no ayuda: EMPEORA. Medido sobre este mismo tag, N=5 por configuración,
# configuraciones INTERCALADAS round-robin en la misma corrida y con el `loadavg` que
# publica la propia sonda (si no se publica, una dispersión ancha no se puede atribuir):
#   carga 17,6-23,3 → k=1 r=3: rango 64,4 % · k=1 r=15: 52,8 % · k=2 r=9: 23,9 % · k=8 r=3: 50,0 %
#   carga 3,4-7,1   → k=1 r=3: rango 13,3 % · k=3 r=9: 66,0 %
# No hay dirección estable en k ni en r, y el mecanismo explica por qué: los dos términos
# se miden en DOS invocaciones distintas, en dos procesos y en dos instantes, de modo que la
# dispersión del cociente la domina cuál de las dos pilló al vecino — y subir k o r alarga
# cada invocación, las separa MÁS en el tiempo y hace más probable que vean entornos
# distintos. Lo que sí es estable, medido en las dos cargas, es medir los dos términos
# INTERCALADOS en una sola invocación (`--sujeto-a`/`--sujeto-b`, rango 18,4 % y 9,4 %, y
# más barato): es lo que `REQ-021 CA-02` punto 2 ya contrata para una razón, con su motivo
# medido en QA-017-06 (1,217 en bloque contra 1,012 intercalado). NO se aplica aquí porque
# cambia el INSTRUMENTO y no un parámetro suyo: el fail-before dejaría de acreditar «el
# mismo cociente» que la medición directa, y la decisión de mover las DOS mediciones a
# intercalado es del analista y del coordinador, no de este archivo. Queda en el informe.
h1_37=''; h2_37=''; x1_37=''; x2_37=''
if [ "$HER37_OK" = si ]; then
  mide37 "$HER37/hooks/lib.sh" arnes_sin_cita "$S37"           1 && { h1_37="$MED37_US"; x1_37="$MED37_MAX"; }
  mide37 "$HER37/hooks/lib.sh" arnes_sin_cita "$(( S37 * 2 ))" 1 && { h2_37="$MED37_US"; x2_37="$MED37_MAX"; }
fi
# UN SOLO NOMBRE para los cuatro veredictos, con la evidencia detrás de DOS espacios, que es
# la convención de `razon37` y la que `inventario.sh` necesita: así normaliza las magnitudes
# y un PASS que se vuelve FAIL o SKIP sigue siendo EL MISMO caso, en vez de leerse como uno
# que desaparece y otro que nace —que es justo lo que CA-02 existe para detectar—. Hasta
# hoy PASS y FAIL llevaban el número DENTRO del nombre y cada rama nombraba un caso distinto.
NOM37_FB='REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático'
# Las cifras que hacen atribuible el próximo rojo: la k, las series, y de cada término su
# mínimo Y su máximo. Con sólo el cociente no se puede saber si se movió el numerador, el
# denominador o los dos, y sin eso el rojo no se distingue del ruido del vecino.
MUE37_FB="k=1 series=3 · ${S37}B min=${h1_37:-n/a}µs max=${x1_37:-n/a}µs · $(( S37 * 2 ))B min=${h2_37:-n/a}µs max=${x2_37:-n/a}µs"
if [ -z "$FILTRO" ] || printf '%s' "$NOM37_FB" | grep -qi -- "$FILTRO"; then
  if [ -z "$h1_37" ] || [ -z "$h2_37" ]; then
    echo "  SKIP  $NOM37_FB  no hay línea base v1.32.1 (${MED37_MOTIVO:-tag ausente}) · $MUE37_FB"
  elif [ "$h1_37" -lt 50000 ] || [ "$h2_37" -lt 50000 ]; then
    echo "  SKIP  $NOM37_FB  serie bajo el suelo de 50 ms: el reloj no distingue del ruido · $MUE37_FB"
  else
    coc37=$(( h2_37 * 1000 / h1_37 ))
    if [ "$coc37" -gt 2600 ]; then
      echo "  PASS  $NOM37_FB  sobre v1.32.1 el mismo cociente da $(awk -v c=$coc37 'BEGIN{printf "%.3f", c/1000}')× y se pasa del techo 2,600× · $MUE37_FB"; PASS=$((PASS+1))
    else
      echo "  FAIL  $NOM37_FB  sobre v1.32.1 el cociente da $(awk -v c=$coc37 'BEGIN{printf "%.3f", c/1000}')× y NO se pasa del techo 2,600×: la sonda no distingue el defecto que este REQ arregla · $MUE37_FB"; FAIL=$((FAIL+1))
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

rm -rf "$HER37" "$BAS37"
