# ---------- 37 (1/5) · EL COSTE DEL ESCÁNER: EL DOMINIO DE EQUIVALENCIA ----------
# REQ-017. La guarda del CR de `arnes_sin_cita` era CUADRÁTICA en la longitud de línea:
# `${l%$CR}` es eliminación de sufijo CON PATRÓN, y bash la resuelve probando cada
# posición. El banco pagaba 92 s donde pagaba 39, y NINGÚN criterio lo veía porque el que
# había (CA-08 de REQ-016) medía PROCESOS —4 = 4, medido bien— mientras el reloj se
# multiplicaba por diez. Esta parte contrata la EQUIVALENCIA del arreglo: DENTRO del
# dominio, el estado byte a byte (CA-01); FUERA, la dirección contra un oráculo (CA-10).
#
# PARTIDA POR REQ-014 CA-18, Y LA DUPLICACIÓN ES LO QUE EL TECHO CUENTA. `37/1` medía 849
# líneas contra un techo derivado de 577 y no cabía en dos: la mitad de las razones y la
# pared salían a 431 líneas contra un techo de 400, y para que cupieran habría que declarar
# un piso de 345 —o sea un bloque indivisible de 196 líneas que no existe—, que es
# exactamente el «techo comprado deformando el sujeto» que CA-18 llama regresión. Así que va
# en tres: el dominio (aquí), las razones y la pared.
# Las tres invariantes de REQ-014 —CA-04 (subshell propio y en paralelo), CA-19 (ninguna
# sección hace `source` de otra) y H-04 (en `secciones/` no cabe un archivo auxiliar)— hacen
# IMPOSIBLE factorizar lo que dos partes comparten: se duplica o se sube al corredor, y
# subirlo es cambio de mecanismo y NO está autorizado. Por eso el materializador de la línea
# base (`mat37`) viene DUPLICADO aquí y en las otras dos partes, con su motivo escrito —el
# mismo precedente que los once renglones que `28-rotacion-seccion-2-el-estado.sh` copió de
# `28-rotacion-seccion-1-la-historia.sh`—. Y aquí NO se materializa v1.32.0: sólo la usa
# CA-04, que vive en `37-coste-del-escaner-2-las-razones.sh`.
#
# POR QUÉ NADA DE ESTE REQ SE MIDE EN SEGUNDOS está escrito donde viven las razones
# (`37-coste-del-escaner-2-las-razones.sh`), y por qué la equivalencia NO se afirma sobre
# toda entrada, más abajo, en el bloque de CA-01: ése es su sitio único.
CASOS_ESPERADOS_SECCION=6
PISO_AUTONOMO_SECCION=470  # 38 preámbulo (líneas 1-38, con CR37/LOC37/CTX37/num37) + 120 maquinaria compartida duplicada (mat37 y la línea base, líneas 39-158) + 312 bloque indivisible mayor (el corpus, el evaluador y el clasificador, que CA-01 y CA-10 comparten en UNA pasada, líneas 160-471) · REQ-014 CA-18
seccion_nueva "--- 37/1 · el coste del escáner: el dominio de equivalencia, dentro y fuera (REQ-017 CA-01 y CA-10) ---"

CR37=$'\r'
# El contexto de la máquina viaja EN EL MENSAJE de cada caso del dominio, y no es adorno:
# la partición dentro/fuera de CA-01 depende de la versión de bash y del locale, así que un
# SKIP que no los nombre no se puede distinguir de un verde vacío (CA-01, CA-10).
LOC37="${LC_ALL:-${LC_CTYPE:-${LANG:-(sin declarar)}}}"
CTX37="bash $BASH_VERSION, locale del entorno $LOC37"
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
LIB37="$HOOKS_DIR/lib.sh"

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

rm -rf "$HER37" "$CORPUS37" "$CORPD37" "$EVA37" "$CLA37" \
       "$EVHE37" "$EVHC37" "$EVEE37" "$EVEC37" "$DENTRO37" "$RES37"
