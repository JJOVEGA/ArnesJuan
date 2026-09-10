# Sección 39 (4 de 5) del banco — 39-caracter-invisible-4-el-coste
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-023 · SEC-047 (mitad 1). EL COSTE: `CA-09`, y son TRES números porque el mecanismo tiene
# tres vías ORTOGONALES de degradarse. (i) un `fork`, que el reloj de una máquina rápida
# esconde; (ii) el reloj de la ruta crítica, que los procesos no ven; y (iii) el ORDEN DE
# CRECIMIENTO en la longitud de línea, que ni el reloj de una entrada pequeña ni los procesos
# ven — y que es exactamente la regresión de 10× que la ventana 1.33.0 pagó (`${l%$CR}` era
# cuadrático y `CA-08` de REQ-016 daba verde midiendo procesos).
#
# EL SUJETO DE (iii) SE ENUNCIA POR PROPIEDAD —el escáner en el que la guarda RESIDA,
# determinado por el código— y no con el nombre de una función: la primera redacción del
# criterio anclaba el cociente en `arnes_sin_cita`, donde la guarda NO puede vivir, y así habría
# dado PASS a una guarda cuadrática.
#
# Y ESTO NO ES TEÓRICO EN ESTE REQ: LA PRIMERA VERSIÓN DE ESTA GUARDA NO CUMPLÍA SU PROPIO
# TECHO, y este caso la cazó. `${clave//[!alfabeto]/}` en un locale UTF-8 sale superlineal
# —cociente de duplicación 3,78 (1000→2000) y 5,59 (2000→4000), y 11,9 ms a 4 000 bytes—; con
# `LC_ALL=C` fijado dentro de la función de la guarda queda en 1,79 y 2,01 y además 17× más barata
# en absoluto. El método, el par de longitudes y los registros están en
# `docs/arnes/req-023-coste-y-dominio.md` §3. Esas cifras se juzgaron contra el techo ABSOLUTO de
# 2,2 que (iii) contrataba entonces; desde el write-back del 2026-09-09 lo que (iii) contrata es la
# RELACIÓN EMPAREJADA contra la línea base heredada, y esos números NO se reciclan como margen.
#
# PARTE 4 DE 5 POR REQ-014 CA-18: con los lectores y el coste en un solo archivo salían 422
# líneas contra el techo de 400. El materializador de la línea base viene DUPLICADO de la parte
# 3 y de las cinco partes de la 37 (motivo escrito UNA vez en
# `37-coste-del-escaner-1-el-dominio.sh`; residual `AN-021-01`).
CASOS_ESPERADOS_SECCION=4
PISO_AUTONOMO_SECCION=330  # 31 preámbulo (líneas 1-31) + 78 maquinaria compartida duplicada (mat94 y la línea base, líneas 33-110) + 221 bloque indivisible mayor (el medidor y las dos puertas de veredicto —mide94, razon94 y coc94— con la FORMA y la LÍNEA BASE de (iii), que no se pueden separar de lo que las publica, líneas 113-333) · REQ-014 CA-18
seccion_nueva "--- 39/4 · el carácter invisible: el coste por las tres vías (REQ-023 CA-09) ---"

num94() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
BOM94=$'\xef\xbb\xbf'
mk94() { printf '%s\n' "$2" > "$PROJ/requirements/$1.md"; }
REPO94="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT94_RUTAS='hooks tools'
MAT94_REG=''; MAT94_T0=0; MAT94_REF='-'; MAT94_ETIQ='-'
mat94_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT94_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT94_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT94_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT94_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT94_ETIQ ref=$MAT94_REF archivos=$arch"
}
mat94() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT94_T0=${EPOCHREALTIME/./}
  MAT94_REF="${ref//[[:space:]]/_}"; MAT94_ETIQ="$MAT94_REF"; MAT94_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO. Con `-d`, las dos secciones 37
  # se abstenían enteras dentro de un worktree —la copia haciendo la mitad del trabajo, el
  # caso que CA-05 cierra— mientras `git` resolvía el tag sin problema. Medido al montar los
  # dos árboles de CA-08; el motivo largo está en `37/1`, donde vive la copia gemela.
  [ -e "$REPO94/.git" ] || { mat94_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO94" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat94_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO94" ls-tree -r "$ref" -- $MAT94_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat94_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat94_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat94_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO94" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat94_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat94_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO94" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat94_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat94_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat94_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat94_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat94_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat94_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat94_reg ok - "$n" "$procs"
  return 0
}
HER94="$RAIZ/her94-$BASHPID"; HER94_OK=no; REGHER94=''
mat94 v1.33.0 "$HER94" && HER94_OK=si
# EL REGISTRO SE RECOGE, y hasta aquí no se recogía: `REGHER94` nacía vacío y NADIE se lo
# asignaba, así que los dos SKIP que lo citan publicaban un PARÉNTESIS VACÍO —«no hay línea base
# v1.33.0 ()»— en vez del motivo por el que no la hay. Una abstención que no dice por qué se
# abstiene no se puede diagnosticar, y era justo la información que hacía falta para saber si el
# SKIP es diseño o avería. `instrumento`, preexistente; enrutado con REQ-024.
REGHER94="${MAT94_REG:-sin registro}"
# ---------- CA-09 · EL COSTE, POR LAS TRES VÍAS Y EN LA MISMA CORRIDA ----------
# El estadístico es el MÍNIMO de k, nunca la media: la carga sólo puede AÑADIR tiempo. Y una
# sonda que no llega a su suelo, o que no encuentra su línea base, emite SKIP CON EL MOTIVO Y
# CON EL NÚMERO QUE SÍ OBTUVO, nunca PASS.
MED94_US=''; MED94_MOTIVO=''
# LA FORMA DE LA LÍNEA QUE SE DOBLA ES EL TERCER PARÁMETRO DEL COCIENTE, Y SE PUBLICA CON ÉL
# (CA-09 (iii), write-back de QA-023-05). Un cociente de duplicación depende de TRES cosas y no
# de una: el PAR de longitudes, `k` y la FORMA de la línea —qué SEGMENTO crece y por qué camino
# del lector pasa—. Medido con el mismo par, el mismo `k` y el mismo sujeto: título **2,042**,
# clave **2,235**, valor **1,727** — un 29 % de dispersión repartido A LOS DOS LADOS del techo
# absoluto de 2,2 que (iii) contrataba entonces, así que el parámetro ausente DECIDÍA el veredicto
# y dos cocientes de formas distintas no son comparables ni entre versiones ni entre corridas. La
# forma sigue siendo parámetro con la relación emparejada: se toma sobre la MISMA forma en las dos
# versiones, y ahí es donde el intercalado al nivel de `n` la vuelve comparable.
#
# QUÉ FORMA, POR PROPIEDAD Y NO POR NOMBRE: crece el SEGMENTO DE CLAVE, partiendo de una clave
# QUE EL LECTOR RECONOCE (del conjunto único `ARNES_CLAVES`). Quedan FUERA, cada una con su
# motivo: (a) que crezca el VALOR, porque el valor NO pasa por la guarda —sirve de control y no
# acredita (iii)—; y (b) la LÍNEA DE TÍTULO, que el lector trata como clave por llevar `:` y cuyo
# alfabeto es arbitrario, pero que NINGUNA cabecera de REQ contiene: un techo afirmado sobre ella
# no dice nada del camino que la puerta recorre de verdad. Y de ahí lo que este caso NO hereda:
# las mediciones que hasta la vuelta 2 acreditaban (iii) —el 2,05 de la cata y el 2,050/2,098 del
# arreglo del locale— se tomaron sobre la línea de TÍTULO, así que no acreditan la forma
# contratada y no se reciclan como margen.
#
# EL ESQUELETO VIVE EN UN SOLO SITIO —`PAT94`—, y de él salen las dos cosas que no pueden
# separarse: lo que la sonda repite y lo que el caso publica. Cambiar la forma mueve el número y
# su etiqueta juntos, así que no se puede publicar una forma que no se midió.
#
# EL RELLENO NO SE ELIGE AQUÍ NI AHORA: es el `a` de la medición YA PUBLICADA (Historial del REQ,
# 2026-09-09: `Sensible a <n×'a'> seguridad`), porque «la elección de la forma NO depende de su
# resultado» y estrenar un relleno en la vuelta que juzga el techo sería elegirlo mirando el
# número. Lo que ese relleno mide, dicho aquí para que nadie lo descubra luego: `a` PERTENECE al
# alfabeto derivado de las claves, así que la reconstrucción de la guarda no llega a ser una
# clave, la guarda NO dispara y lo cronometrado son los dos barridos de `_arnes_clave_oculta` más
# el recorte de blancos de `arnes_norm_clave`. Un relleno de bytes AJENOS sí reconstruye la clave,
# dispara la guarda y añade `_arnes_repr_clave`: es OTRA forma de la misma clase, no está medida
# por este caso, y sustituir una por otra en la vuelta que decide el veredicto es exactamente lo
# que la cláusula anterior prohíbe.
PAT94='Sensible a @ seguridad: no'   # `@` = el hueco donde crece el relleno. UN SOLO SITIO.
REL94='a'
PRE94="${PAT94%%@*}"; POS94="${PAT94#*@}"
FORMA94="forma «clave»: crece el SEGMENTO DE CLAVE de una clave que el lector reconoce, esqueleto «$PAT94» con «@» = «$REL94» repetido hasta que la línea entera mida n bytes"
mide94() {   # <lib> <fn> <bytes> <k> -> MED94_US = mínimo de 3 series, en microsegundos
  local lib="$1" fn="$2" n="$3" k="$4" reg
  MED94_US=''; MED94_MOTIVO=''
  if [ ! -r "$lib" ]; then MED94_MOTIVO="no existe $lib"; return 1; fi
  if [ "$n" -le $(( ${#PRE94} + ${#POS94} )) ]; then
    MED94_MOTIVO="n=$n no cabe en el esqueleto «$PAT94» ($(( ${#PRE94} + ${#POS94} )) bytes de marco)"; return 1
  fi
  # El sujeto es una línea de cabecera cuya CLAVE crece a partir de una clave REAL del lector, que
  # es el camino que la puerta recorre de verdad. El esqueleto es ASCII entero a propósito: así
  # `${#l94}` cuenta bytes y no caracteres, y la longitud publicada no depende del locale.
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "$fn-$n" \
    --prep "source '$lib' >/dev/null 2>&1 || :; r94='$REL94'; l94='$PRE94'; while [ \${#l94} -lt $(( n - ${#POS94} )) ]; do l94+=\"\$r94\"; done; l94=\"\${l94:0:$(( n - ${#POS94} ))}$POS94\"" \
    --sujeto "ARNES_CITA=0; ARNES_CR=0; ARNES_OCULTA=0; $fn \"\$l94\"" 2>/dev/null)"
  if [ -z "$reg" ]; then MED94_MOTIVO='la sonda de reloj no dejó registro'; return 1; fi
  if ! sonda_lee "$reg"; then MED94_MOTIVO="$SONDA_MOTIVO"; return 1; fi
  if [ "${SONDA[estado]}" != ok ]; then
    MED94_MOTIVO="la sonda no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo} (min=${SONDA[min]:-n/a}µs)"; return 1
  fi
  if ! num94 "${SONDA[min]:-}"; then MED94_MOTIVO="la sonda no publicó un mínimo (<${SONDA[min]:-vacío}>)"; return 1; fi
  MED94_US="${SONDA[min]}"
  return 0
}
razon94() {   # <nombre> <us medido> <us base> <techo por mil> <qué mide>
  local nombre="$1" med="$2" base="$3" techo="$4" que="$5" coc
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ -z "$med" ] || [ -z "$base" ]; then
    echo "  SKIP  $nombre  no hay con qué medir: ${MED94_MOTIVO:-falta uno de los dos términos} (medido=<${med:-vacío}> base=<${base:-vacío}>)"; return 0
  fi
  if [ "$med" -lt 50000 ] || [ "$base" -lt 50000 ]; then
    # La abstención publica el número que SÍ obtuvo, y con él QUÉ estaba midiendo: un µs sin
    # su forma no es comparable con el de la vuelta siguiente (QA-023-05).
    echo "  SKIP  $nombre  serie por debajo del suelo de 50 ms (medido=${med}µs base=${base}µs, $que): el reloj no distingue del ruido"; return 0
  fi
  coc=$(( med * 1000 / base ))
  if [ "$coc" -le "$techo" ]; then
    echo "  PASS  $nombre  $que = $(awk -v c=$coc 'BEGIN{printf "%.3f", c/1000}')× (techo $(awk -v t=$techo 'BEGIN{printf "%.3f", t/1000}')×; ${med}µs sobre ${base}µs)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  $que = $(awk -v c=$coc 'BEGIN{printf "%.3f", c/1000}')× > techo $(awk -v t=$techo 'BEGIN{printf "%.3f", t/1000}')× (${med}µs sobre ${base}µs)"; FAIL=$((FAIL+1))
  fi
}

# mil94: milésimas -> `x,xxx` sin un solo proceso (`printf -v` es builtin). El `awk` de `razon94`
# se queda donde está: esa puerta la comparte (ii) y aquí no se toca nada suyo.
MIL94=''
mil94() { printf -v MIL94 '%d.%03d' "$(( ${1} / 1000 ))" "$(( ${1} % 1000 ))"; }

# (iii) LA RELACIÓN EMPAREJADA CONTRA LA LÍNEA BASE HEREDADA, con SUS CUATRO PARÁMETROS
# PUBLICADOS —el PAR de longitudes, `k`, la FORMA y la LÍNEA BASE (el tag)— y con NO MENOS DE
# TRES TOMAS Y LA DISPERSIÓN DE LA SERIE QUE EL CRITERIO CONTRATA. Sin los cuatro, la relación
# NO acredita (iii).
#
# QUÉ MAGNITUD MIDE ESTE CASO, Y POR QUÉ YA NO ES EL COCIENTE ABSOLUTO CONTRA 2,2 (write-back
# del criterio, 2026-09-09). El nivel absoluto del cociente lo paga el camino HEREDADO: con el
# mismo par, el mismo `k` y la misma forma «clave», la base `v1.33.0` mide medianas 2,492
# (`arnes_norm_clave`) y 2,446 (`arnes_campo_linea`) contra 2,295 y 2,237 de la candidata
# (`docs/qa/1.34.0-req023-vuelta3-metodo.md` §11). Un techo absoluto sobre esa magnitud lo
# incumple igual el código que este REQ NO ha escrito: no puede acreditar ni desacreditar la
# guarda. La magnitud que (iii) contrata es el DELTA —«la guarda no empeora el orden de
# crecimiento del camino en el que se inserta»— expresado como RELACIÓN EMPAREJADA entre el
# cociente de la candidata y el de la base, tomada DENTRO DE CADA TOMA de una ÚNICA tanda, con
# las dos versiones INTERCALADAS AL NIVEL DE `n`. Techo: no más de 1,000×.
#
# EL 1,000× NO SALE DE ESAS CIFRAS, Y ESA ES LA PRUEBA QUE HAY QUE PODER PASAR: es la propiedad
# estructural expresada como razón contra una línea base medida en la misma corrida. Si las
# medianas emparejadas salieran 1,05, el techo seguiría siendo 1,000 y lo que habría es un
# HALLAZGO CONTRA EL CÓDIGO. Lo que (iii) sigue cazando: una guarda cuadrática sube la relación
# a ≈ 1,10 (cálculo sobre las tomas publicadas), frente al 0,856 medido.
#
# LOS COCIENTES ABSOLUTOS SE PUBLICAN Y SON CONTROL: no acreditan (iii) ni lo desacreditan. Se
# publican porque sin ellos nadie puede rederivar la relación ni ver de quién es el número.
#
# Y EL TECHO SÓLO SE PUEDE AFIRMAR CON MARGEN MAYOR QUE LA REPRODUCIBILIDAD DEMOSTRADA EN LA
# MISMA CORRIDA. En un cociente la contaminación por carga NO es monótona —cae sobre los dos
# términos, y no en la misma proporción—, así que una toma aislada por encima del techo no
# PRUEBA que se supere y una por debajo no lo ACREDITA si la dispersión entre tomas es del orden
# del margen. LA DISPERSIÓN QUE DECIDE ES LA DE LA SERIE CONTRATADA —la de la RELACIÓN
# EMPAREJADA—, nunca la de los cocientes absolutos: son series distintas y con márgenes
# distintos, y confundirlas afirmaría un techo con la reproducibilidad de otro número. Por eso
# el caso mide la relación no menos de tres veces, publica las tomas y su dispersión, y ABSTIENE
# con los cuatro parámetros y los números —nunca PASS y nunca FAIL— cuando la dispersión alcanza
# al margen. Esto NO es holgura sobre el techo: el 1,000× no se toca, y si la forma contratada lo
# supera con margen mayor que la dispersión, el caso FALLA y es hallazgo CONTRA EL CÓDIGO.
#
# Y SI LA LÍNEA BASE NO SE PUEDE MATERIALIZAR, (iii) EMITE SKIP CON SU MOTIVO — NUNCA PASS. Es el
# precio declarado de haber corregido la magnitud: la relación exige un tag, así que este caso
# deja de ser auto-anclado y depende de la misma ruta de ejecución que CA-08 (SEC-048).
N94A=1000; N94B=2000; K94=200
BASE94=v1.33.0    # el CUARTO parámetro. Dos relaciones tomadas contra bases distintas NO son
                  # comparables, así que el tag se publica con el número.
T94=3   # tomas de la relación. OPERATIVO: MÁS son conformes y no son hallazgo; MENOS, no.
hay94() {   # <lib> <fn> -> 0 si ESA lib define ESA función
  # Sin esto, un sujeto que la base no define se cronometraría como «orden no encontrada»: barato,
  # por debajo del suelo, y el caso abstendría citando el suelo en vez del motivo verdadero.
  bash -c ". '$1' >/dev/null 2>&1; [ \"\$(type -t '$2')\" = function ]" >/dev/null 2>&1
}
coc94() {   # <nombre> <fn> <techo por mil> -> PASS/FAIL/SKIP con las tomas, la dispersión y los CUATRO parámetros
  local nombre="$1" fn="$2" techo="$3" t lo hi med disp margen que x j tmp
  local crudo='' ctrl='' orden='' ba bb ca cb qb qc rel
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  local -a q=() s=()
  que="par ${N94A}→${N94B} bytes, k=$K94, línea base $BASE94, $FORMA94"
  if [ "$HER94_OK" != si ]; then
    echo "  SKIP  $nombre  no hay línea base $BASE94 que emparejar (${MAT94_REG:-sin registro}), y el cociente ABSOLUTO no la sustituye: lo paga el camino heredado · $que"; return 0
  fi
  if ! hay94 "$HER94/hooks/lib.sh" "$fn"; then
    echo "  SKIP  $nombre  la línea base $BASE94 no define «$fn»: no hay par que emparejar · $que"; return 0
  fi
  for ((t = 1; t <= T94; t++)); do
    ba=''; bb=''; ca=''; cb=''
    # EL INTERCALADO ES AL NIVEL DE `n`, NO AL NIVEL DE VERSIÓN: para cada longitud se miden las
    # DOS versiones SEGUIDAS, así que una deriva de carga entre el bloque de 1000 y el de 2000
    # cae sobre las dos por igual — y eso es lo que vuelve comparable la RELACIÓN entre ellas.
    # Y EL ORDEN base/candidata SE ALTERNA POR TOMA Y SE PUBLICA, para que un sesgo sistemático
    # de «la segunda mide caliente» no caiga siempre del mismo lado de la relación.
    if [ $(( t % 2 )) -eq 1 ]; then
      orden='base,cand'
      mide94 "$HER94/hooks/lib.sh" "$fn" "$N94A" "$K94" && ba="$MED94_US"
      mide94 "$HOOKS_DIR/lib.sh"   "$fn" "$N94A" "$K94" && ca="$MED94_US"
      mide94 "$HER94/hooks/lib.sh" "$fn" "$N94B" "$K94" && bb="$MED94_US"
      mide94 "$HOOKS_DIR/lib.sh"   "$fn" "$N94B" "$K94" && cb="$MED94_US"
    else
      orden='cand,base'
      mide94 "$HOOKS_DIR/lib.sh"   "$fn" "$N94A" "$K94" && ca="$MED94_US"
      mide94 "$HER94/hooks/lib.sh" "$fn" "$N94A" "$K94" && ba="$MED94_US"
      mide94 "$HOOKS_DIR/lib.sh"   "$fn" "$N94B" "$K94" && cb="$MED94_US"
      mide94 "$HER94/hooks/lib.sh" "$fn" "$N94B" "$K94" && bb="$MED94_US"
    fi
    if [ -z "$ba" ] || [ -z "$bb" ] || [ -z "$ca" ] || [ -z "$cb" ]; then
      crudo="$crudo t$t($orden)=<no se pudo medir: ${MED94_MOTIVO:-sin motivo}>"; continue
    fi
    if [ "$ba" -lt 50000 ] || [ "$bb" -lt 50000 ] || [ "$ca" -lt 50000 ] || [ "$cb" -lt 50000 ]; then
      # La abstención publica los números que SÍ obtuvo: un µs sin sus parámetros no es
      # comparable con el de la vuelta siguiente (QA-023-05).
      crudo="$crudo t$t($orden)=base:${ba}→${bb}µs cand:${ca}→${cb}µs(bajo el suelo de 50 ms)"; continue
    fi
    qb=$(( bb * 1000 / ba )); qc=$(( cb * 1000 / ca ))
    rel=$(( qc * 1000 / qb ))
    q+=( "$rel" )
    mil94 "$rel"; crudo="$crudo t$t($orden)=${MIL94}×"
    mil94 "$qc"; ctrl="$ctrl t$t=cand ${MIL94}×"
    mil94 "$qb"; ctrl="$ctrl/base ${MIL94}× (${ca}→${cb} sobre ${ba}→${bb}µs)"
  done
  que="$que; $T94 tomas de la RELACIÓN:$crudo; CONTROL no acreditativo —cocientes absolutos, que paga el camino heredado—:$ctrl"
  if [ "${#q[@]}" -lt "$T94" ]; then
    echo "  SKIP  $nombre  sólo ${#q[@]} de $T94 tomas de la relación son utilizables, y con menos no hay reproducibilidad que demostrar: $que"; return 0
  fi
  # Orden por inserción, sin un proceso y sin suponer T94=3: la MEDIANA es el estadístico de las
  # tomas —una sola toma no decide nada— y con un número PAR de tomas se toma la superior, que es
  # el lado que hace el PASS más difícil.
  for x in "${q[@]}"; do
    s+=( "$x" ); j=$(( ${#s[@]} - 1 ))
    while [ "$j" -gt 0 ] && [ "${s[j-1]}" -gt "${s[j]}" ]; do
      tmp="${s[j-1]}"; s[j-1]="${s[j]}"; s[j]="$tmp"; j=$(( j - 1 ))
    done
  done
  lo="${s[0]}"; hi="${s[${#s[@]}-1]}"; med="${s[${#s[@]}/2]}"
  disp=$(( hi - lo ))
  if [ "$med" -le "$techo" ]; then margen=$(( techo - med )); else margen=$(( med - techo )); fi
  mil94 "$med"; local vmed="$MIL94"; mil94 "$techo"; local vtecho="$MIL94"
  mil94 "$disp"; local vdisp="$MIL94"; mil94 "$margen"; local vmargen="$MIL94"
  mil94 "$lo"; local vlo="$MIL94"; mil94 "$hi"; local vhi="$MIL94"
  if [ "$disp" -ge "$margen" ]; then
    # NO se puede AFIRMAR el techo: el criterio pide margen MAYOR que la reproducibilidad, así que
    # la igualdad también abstiene. Un SKIP con los números vale más que un PASS que la corrida
    # siguiente desmiente con la misma implementación. Vía conforme para llegar a afirmarlo: MÁS
    # tomas, `k` MAYOR, un PAR mayor o un host menos cargado — NUNCA cambiar la forma, subir el
    # techo ni afirmar con la dispersión de otra serie.
    echo "  SKIP  $nombre  no se puede AFIRMAR el techo: dispersión de la RELACIÓN ${vdisp}× (de ${vlo}× a ${vhi}×) >= margen ${vmargen}× contra el techo ${vtecho}× (mediana ${vmed}×) · $que"; return 0
  fi
  if [ "$med" -le "$techo" ]; then
    echo "  PASS  $nombre  mediana de la RELACIÓN ${vmed}× (techo ${vtecho}×; margen ${vmargen}× > dispersión ${vdisp}×, de ${vlo}× a ${vhi}×) · $que"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  mediana de la RELACIÓN ${vmed}× > techo ${vtecho}× (margen ${vmargen}× > dispersión ${vdisp}×, de ${vlo}× a ${vhi}×): el techo es OPERATIVO y no se sube — lo que baja es el coste de la guarda · $que"; FAIL=$((FAIL+1))
  fi
}
for fn94 in arnes_norm_clave arnes_campo_linea; do
  coc94 "REQ-023 CA-09 (iii) la guarda no empeora el orden de crecimiento de $fn94: relación emparejada contra $BASE94" "$fn94" 1000
done

# (ii) EL RELOJ DE LA RUTA CRÍTICA, contra la línea base medida EN LA MISMA CORRIDA y con los
# DOS SUJETOS INTERCALADOS en la misma invocación de la sonda: así la carga de la máquina no
# cae entera sobre uno de los dos términos.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-09 (ii)" | grep -qi -- "$FILTRO"; then
  if [ "$HER94_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  no hay línea base v1.33.0 ($REGHER94)"
  else
    rm -f "$PROJ/requirements"/*.md
    mk94 REQ-994 '# REQ-994
Estado: en-revisión'
    ENT94="$RAIZ/ent94-$BASHPID.json"
    emite_write "$PROJ/requirements/REQ-994.md" '# REQ-994
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico' > "$ENT94"
    reg94="$("$UTIL_DIR/sonda-reloj.sh" --k 4 --r 6 --etiqueta ruta-critica \
      --sujeto-a "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT94' >/dev/null 2>&1" \
      --sujeto-b "bash '$HER94/hooks/guard-completado.sh' < '$ENT94' >/dev/null 2>&1" 2>/dev/null)"
    if ! sonda_lee "$reg94"; then
      echo "  SKIP  REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  el registro de la sonda no es legible: $SONDA_MOTIVO"
    elif [ "${SONDA[estado]}" != ok ] || ! num94 "${SONDA[min_a]:-}" || ! num94 "${SONDA[min_b]:-}"; then
      echo "  SKIP  REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  la sonda no pudo medir: estado=${SONDA[estado]:-vacío} motivo=${SONDA[motivo]:-sin motivo} (a=${SONDA[min_a]:-n/a}µs b=${SONDA[min_b]:-n/a}µs)"
    else
      razon94 "REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base v1.33.0" \
        "${SONDA[min_a]}" "${SONDA[min_b]}" 1250 "razón de la evaluación entera de la puerta (k=${SONDA[k]}, r=${SONDA[r]}, sujetos intercalados)"
    fi
  fi
fi

# (i) LOS PROCESOS, que el reloj de una máquina rápida esconde. Se cuentan los de la EVALUACIÓN
# ENTERA de la puerta en los dos árboles y el delta tiene que ser 0: la guarda son dos
# expansiones de parámetro, un `case` y una llamada a `arnes_en_vocab`, todo builtins.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-09 (i)" | grep -qi -- "$FILTRO"; then
  if [ "$HER94_OK" != si ] || [ ! -r "${ENT94:-}" ]; then
    echo "  SKIP  REQ-023 CA-09 (i) la guarda no añade ni un proceso por evaluación  no hay línea base v1.33.0 o no se preparó la entrada (${REGHER94:-sin registro})"
  else
    c94a=''; c94b=''
    r94="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta este --sujeto "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT94' >/dev/null 2>&1" 2>/dev/null)"
    sonda_lee "$r94" && [ "${SONDA[estado]}" = ok ] && c94a="${SONDA[cuenta]:-}"
    r94="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta heredado --sujeto "bash '$HER94/hooks/guard-completado.sh' < '$ENT94' >/dev/null 2>&1" 2>/dev/null)"
    sonda_lee "$r94" && [ "${SONDA[estado]}" = ok ] && c94b="${SONDA[cuenta]:-}"
    if ! num94 "$c94a" || ! num94 "$c94b"; then
      echo "  SKIP  REQ-023 CA-09 (i) la guarda no añade ni un proceso por evaluación  la sonda de procesos no dejó las dos cuentas (este=<${c94a:-vacío}> heredado=<${c94b:-vacío}>): ${SONDA_MOTIVO:-${SONDA[motivo]:-sin motivo}}"
    elif [ "$c94a" -le "$c94b" ]; then
      echo "  PASS  REQ-023 CA-09 (i) la evaluación gasta $c94a procesos y la línea base $c94b: 0 añadidos"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-09 (i) la evaluación gasta $c94a procesos contra $c94b de la línea base: $(( c94a - c94b )) añadido(s), y el techo es 0"; FAIL=$((FAIL+1))
    fi
  fi
fi

rm -rf "$HER94"
