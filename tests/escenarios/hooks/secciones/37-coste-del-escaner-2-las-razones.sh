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
CASOS_ESPERADOS_SECCION=8
# EL PISO SUBE DE 200 A 551 Y NO ES UN TECHO COMPRADO: lo que crece es el bloque que NO se
# puede partir. Desde el write-back del MODO (CA-03, 2026-09-09) las dos mediciones de CA-03
# comparten instrumento (`mide37i`) y puerta (`banda37`/`razon37`), y los tres casos que
# ACREDITAN esa puerta tienen que ejercer LA PUERTA QUE DECIDE Y NO UNA COPIA SUYA —misma
# razón, misma letra, que el piso de 448 de `37/5`—. Con CA-19 (ninguna sección hace
# `source` de otra) y H-04 (en `secciones/` no cabe un auxiliar), partir este archivo
# obligaría a DUPLICAR la única puerta de las tres razones, y una puerta duplicada deja de
# ser única: el par discriminante acreditaría la copia. AVISO para la próxima comisión: con
# el piso tan cerca del total, `CA-18` casi no muerde aquí; el caso que siga no debe
# alargar esto sin volver a preguntar si la puerta puede subir al corredor (que es cambio
# de mecanismo y necesita autorización).
PISO_AUTONOMO_SECCION=551  # 35 preámbulo (líneas 1-35, con num37) + 122 maquinaria compartida duplicada (mat37 y las dos líneas base, líneas 36-157) + 394 bloque indivisible mayor (el medidor intercalado, la puerta —mil37/banda37/razon37— y los casos que la ejercen, incluido el par discriminante, líneas 159-552) · REQ-014 CA-18
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
# siendo el mínimo, que es el estadístico que CA-03 contrata. `MED37_PLAT` y `MED37_CARGA`
# salen del MISMO registro y son la mitad (ii) de la remediación de SEC-064: una medición
# —y sobre todo una abstención— que no dice DE QUÉ MÁQUINA es no se puede sumar con otra.
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

# mide37i <lib> <fn> <bytes_a> <bytes_b> <k> -> los DOS términos, en UNA sola invocación
# EL MODO DE MEDICIÓN ES PARTE DEL CRITERIO, igual que `k` (CA-03, write-back del
# 2026-09-09): las series de los dos tamaños van INTERCALADAS —a, b, a, b, …— dentro de la
# MISMA invocación. La alternancia la hace `sr_intercala` de `tests/util/sonda-reloj.sh`,
# que es su SEDE ÚNICA: aquí se USA, no se reescribe. En bloque los dos términos se miden
# en dos invocaciones, dos procesos y dos instantes, así que la dispersión del cociente la
# domina CUÁL DE LAS DOS pilló al vecino —y ninguna cota sobre la dispersión DENTRO de cada
# término la acota—; intercalar los pone bajo el mismo vecino por construcción y cuesta
# MENOS: una invocación en vez de dos. Es lo que `REQ-021 CA-02` punto 2 ya contrata para
# cualquier razón de dos sujetos, con su motivo medido en QA-017-06 (1,217 en bloque frente
# a 1,012 intercalado) y en `docs/arnes/req-017-ca-03-modo-de-medicion/` (rango del cociente
# 18,4 % y 9,4 % intercalado contra 64,4 % y 13,3 % en bloque, en dos cargas distintas).
# La línea corta es el PREFIJO de la larga: mismo relleno y los MISMOS bytes que medía el
# modo en bloque —el par S/2S no se mueve—, y una construcción en vez de dos.
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

# Milésimas -> texto, SIN fork: `printf -v` es builtin. Con la banda, un veredicto formatea
# CUATRO números —techo, cociente y los dos extremos—, y con `$(awk …)` cada uno sería un
# fork: cuatro por caso en el archivo que mide costes. Es la convención de `fmt47` en `37/5`.
MIL37=''
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

# razon37 <nombre> <us_medido> <us_base> <techo_por_mil> <qué mide> [máx_medido] [máx_base]
#         [dir de banda] [muestras]
# UNA SOLA puerta para las tres razones de esta sección, y con la regla de CA-06 metida
# dentro: si falta cualquiera de los dos términos, o si alguna serie no llega al suelo de
# 50 ms (donde el reloj deja de tener resolución frente al ruido), el caso dice SKIP CON
# EL MOTIVO Y CON EL NÚMERO QUE SÍ OBTUVO, y NUNCA PASS. Un PASS de una sonda que no pudo
# medir es exactamente el verde sobre una regresión que este REQ existe para no repetir.
# LOS CUATRO ARGUMENTOS DE ATRÁS son de CA-03 y por eso son OPCIONALES: con `dir` vacío la
# razón se juzga como se juzgaba —cociente contra techo—, que es lo que CA-04 contrata y
# aquí no se toca; con `dir` se aplica además la banda. Lo que NO es opcional es PUBLICAR:
# un cociente sin su modo, su `k`, el máximo de cada término y su máquina no es comparable
# con otro, y no poder atribuir el rojo del CI del 2026-09-09 a uno de los dos términos
# costó la investigación entera. Ampliar este mensaje alcanza a los cinco casos de la
# sección: es coste de implementación, no motivo para publicar menos.
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

# ---------- CA-03 · EL COCIENTE DE DUPLICACIÓN ----------
# La propiedad estructural: doblar la entrada y comparar el cociente de los mínimos.
# Lineal ≈ 2, cuadrático ≈ 4. La velocidad de la máquina se cancela.
# k=20 sobre 70 000 bytes es lo que hace falta para pasar el suelo de 50 ms EN ESTE ÁRBOL
# (con k=10 la serie corta se queda en ~49 ms y la sonda tendría que decir SKIP).
S37=70000
u1_37=''; u2_37=''; x1_37=''; x2_37=''
if mide37i "$LIB37" arnes_sin_cita "$(( S37 * 2 ))" "$S37" 20; then
  u2_37="$MED37_A"; x2_37="$MED37_AX"; u1_37="$MED37_B"; x1_37="$MED37_BX"
fi
razon37 "REQ-017 CA-03 el escáner no crece más que linealmente: doblar la línea no cuadruplica" \
  "$u2_37" "$u1_37" 2600 "cociente de duplicación (${S37}→$(( S37 * 2 )) bytes), que NO debe pasar del techo" \
  "$x2_37" "$x1_37" no-excede "modo=intercalado k=20 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"

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
# `sonda-reloj.sh` tiene DOS parámetros: `--k` son las repeticiones DENTRO de una serie y
# `--r` son las SERIES, que es sobre lo que se toma el mínimo. Las dos sondas de esta
# sección pasan `--r 3` FIJO, así que el fail-before con k=1 toma el mínimo de 3 muestras,
# las MISMAS que la directa con k=20. El estadístico nunca estuvo apagado.
#
# Y subir k o r no ayuda: EMPEORA, medido sobre este mismo tag con N=5 por configuración y
# round-robin en la misma ronda (`01-evidencia.md`): con carga 17,6-23,3 el rango del
# cociente da 64,4 % (k=1 r=3) · 52,8 % (k=1 r=15) · 23,9 % (k=2 r=9) · 50,0 % (k=8 r=3), y
# con carga 3,4-7,1 da 13,3 % (k=1 r=3) contra 66,0 % (k=3 r=9). El mecanismo: alargar cada
# invocación SEPARA MÁS EN EL TIEMPO a los dos términos. Por eso lo que se movió el
# 2026-09-09 fue el MODO —intercalado, arriba— y `k` sigue constreñida sólo por el suelo; y
# se movió en LAS DOS mediciones a la vez, porque un fail-before medido con otro instrumento
# dejaría de acreditar el mismo cociente que la directa (CA-03).
h1_37=''; h2_37=''; x1h_37=''; x2h_37=''
if [ "$HER37_OK" != si ]; then
  MED37_MOTIVO='no hay línea base v1.32.1 (tag ausente o árbol a medias)'
elif mide37i "$HER37/hooks/lib.sh" arnes_sin_cita "$(( S37 * 2 ))" "$S37" 1; then
  h2_37="$MED37_A"; x2h_37="$MED37_AX"; h1_37="$MED37_B"; x1h_37="$MED37_BX"
fi
# UN SOLO NOMBRE para los cinco veredictos, con la evidencia detrás de DOS espacios, que es
# la convención de `razon37` y la que `inventario.sh` necesita: así normaliza las magnitudes
# y un PASS que se vuelve FAIL o SKIP sigue siendo EL MISMO caso, en vez de leerse como uno
# que desaparece y otro que nace —que es justo lo que CA-02 existe para detectar—. Hasta el
# 2026-09-09 PASS y FAIL llevaban el número DENTRO del nombre y cada rama nombraba un caso
# distinto. Y desde el write-back del modo, este caso pasa por LA MISMA puerta que la
# medición directa con la dirección invertida: es la única forma de que las dos acrediten el
# mismo cociente contra el mismo techo con el mismo instrumento.
razon37 'REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático' \
  "$h2_37" "$h1_37" 2600 "el mismo cociente sobre v1.32.1 (${S37}→$(( S37 * 2 )) bytes), que SÍ debe pasar del techo" \
  "$x2h_37" "$x1h_37" excede "modo=intercalado k=1 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"

# ---------- CA-04 · LA RAZÓN CONTRA LA ÚLTIMA VERSIÓN SIN LA GUARDA ----------
# DESVIACIÓN DECLARADA, y no es un atajo: v1.32.0 NO TIENE `arnes_sin_cita` —la noción de
# cita nace en 1.32.1 (REQ-016)—, así que la comparación literal «su `arnes_sin_cita`» no
# existe. Lo comparable es la MISMA BOCA: la función que recibe una línea cruda de
# cabecera y devuelve un campo. En v1.32.0 es `arnes_norm_clave`; en este árbol es
# `arnes_campo_linea`, que es `arnes_sin_cita` MÁS `arnes_norm_clave`. Se compara el
# camino entero contra el camino entero, que además es la lectura ESTRICTA: mide el coste
# que la guarda AÑADIÓ, incluyéndose a sí misma.
#
# EL MODO NO SE MUEVE AQUÍ, Y NO ES OLVIDO: el intercalado que CA-03 contrata desde el
# 2026-09-09 se contrata para LAS DOS MEDICIONES DE CA-03, y CA-04 compara dos ÁRBOLES
# distintos sobre la misma línea, no dos tamaños. Que el modo correcto para esta razón sea
# también el intercalado es PLAUSIBLE y no está medido en esa evidencia, así que es otro
# write-back con su medición y no un arrastre de esta comisión. Lo único que cambia en los
# cuatro veredictos de CA-04 es que publican también el MÁXIMO de cada término y la carga
# de la máquina —evidencia, no juez: el veredicto lo sigue decidiendo el mínimo contra el
# mismo techo, y sale idéntico—.
c37=''; b37=''; cx37=''; bx37=''; cg37='n/a'; bg37='n/a'
mide37 "$LIB37" arnes_campo_linea 140000 10 && { c37="$MED37_US"; cx37="$MED37_MAX"; cg37="$MED37_CARGA"; }
[ "$BAS37_OK" = si ] && { mide37 "$BAS37/hooks/lib.sh" arnes_norm_clave 140000 10 && { b37="$MED37_US"; bx37="$MED37_MAX"; bg37="$MED37_CARGA"; }; }
razon37 "REQ-017 CA-04 el camino de campo no cuesta más de 2× lo que costaba en v1.32.0 (140 000 bytes sin CR)" \
  "$c37" "$b37" 2000 "razón contra v1.32.0" "$cx37" "$bx37" '' \
  "modo=bloque k=10 series=3 · plataforma=${MED37_PLAT:-n/a} carga medido=$cg37 base=$bg37"

# FAIL-BEFORE de CA-04, con k=2: el árbol enfermo se pasa de 2× por goleada.
# El suelo se comprueba SÓLO sobre v1.32.1 y no sobre v1.32.0, a propósito y sin cambio:
# el término que tiene que estar por encima del ruido es el que se acusa de ser caro. Ese
# reparto es de CA-04 y se conserva tal cual — por eso este veredicto no pasa por `razon37`,
# cuya regla de suelo es SIMÉTRICA y convertiría en SKIP lo que hoy pasa.
ch37=''; cb37=''; chx37=''; cbx37=''; chg37='n/a'; cbg37='n/a'
if [ "$HER37_OK" = si ] && [ "$BAS37_OK" = si ]; then
  mide37 "$HER37/hooks/lib.sh" arnes_campo_linea 140000 2 && { ch37="$MED37_US"; chx37="$MED37_MAX"; chg37="$MED37_CARGA"; }
  mide37 "$BAS37/hooks/lib.sh" arnes_norm_clave  140000 2 && { cb37="$MED37_US"; cbx37="$MED37_MAX"; cbg37="$MED37_CARGA"; }
fi
# UN SOLO NOMBRE Y LA EVIDENCIA DETRÁS DE DOS ESPACIOS, igual que el fail-before de CA-03 y
# por la misma razón medida: hasta hoy el SKIP se llamaba «la razón delata a v1.32.1» y el
# PASS metía el número DENTRO del nombre, así que las tres ramas nombraban casos distintos.
# Y el defecto era peor de lo que parecía: SIN los dos espacios, `inventario.sh` lee la
# línea ENTERA como nombre, donde sólo normaliza los numerales en notación de magnitud —así
# que los µs recién publicados sobrevivían crudos y la línea cambiaba en cada corrida—.
# Medido al implementar esto: tres corridas del banco daban tres inventarios distintos por
# esta línea. Es la misma clase que CA-02 existe para cazar, del lado del oráculo.
NOM37_04='REQ-017 CA-04 fail-before: la razón delata a v1.32.1'
MUE37_04="mín/máx v1.32.1 ${ch37:-n/a}/${chx37:-n/a}µs sobre v1.32.0 ${cb37:-n/a}/${cbx37:-n/a}µs · techo 2.000× · modo=bloque k=2 series=3 · plataforma=${MED37_PLAT:-n/a} carga heredada=$chg37 base=$cbg37"
# La carga NO se publica como `v1.32.1=2.46`, y es una lección del oráculo: un numeral
# pegado a un nombre por un punto DESIGNA (`v1.32.1`), así que `inventario.sh` conserva ese
# token entero —carga incluida— y la línea cambiaba en cada corrida. Se nombra el árbol con
# una palabra y el valor queda como magnitud, que es lo que es.
if [ -z "$FILTRO" ] || printf '%s' "$NOM37_04" | grep -qi -- "$FILTRO"; then
  if [ -z "$ch37" ] || [ -z "$cb37" ] || [ "$ch37" -lt 50000 ]; then
    echo "  SKIP  $NOM37_04  falta línea base o serie bajo el suelo (v1.32.1=<${ch37:-vacío}>µs v1.32.0=<${cb37:-vacío}>µs) · $MUE37_04"
  else
    r37=$(( ch37 * 1000 / cb37 )); mil37 "$r37"
    if [ "$r37" -gt 2000 ]; then
      echo "  PASS  $NOM37_04  v1.32.1 cuesta $MIL37× lo de v1.32.0 y se pasa del techo 2.000× · $MUE37_04"; PASS=$((PASS+1))
    else
      echo "  FAIL  $NOM37_04  v1.32.1 cuesta $MIL37× y NO se pasa: el caso pasaría contra el árbol enfermo · $MUE37_04"; FAIL=$((FAIL+1))
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

# ---------- CA-03 · LA BANDA, PROBADA CON ENTRADAS SINTÉTICAS ----------
# En una corrida sana la banda cabe bajo el techo, así que el camino que de verdad importa
# —la abstención— no se recorrería nunca y nadie sabría si cierra. Es la misma lección que
# cerró QA-017-03, QA-017-04 y la cláusula de convergencia de CA-08 (ii): una guarda que
# sólo corre cuando una palanca la enciende no está acreditada. Las cifras se eligen
# DISTINTAS ENTRE SÍ y distintas del techo, para que ninguna se dé por presente por haber
# casado con otra. Cada entrada es `mín_num máx_num mín_den máx_den dir`, en µs.
BAN37_TABLA=(
  '200000 210000 100000 105000 no-excede'   # banda [1.904, 2.100] entera bajo el techo -> PASS
  '400000 410000 100000 102000 no-excede'   # banda [3.921, 4.100] entera encima         -> FAIL
  '250000 300000 100000 120000 no-excede'   # techo DENTRO, cociente 2.500 conforme      -> SKIP
  '270000 320000 100000 120000 no-excede'   # techo DENTRO, cociente 2.700 NO conforme   -> SKIP
  '400000 410000 100000 102000 excede'      # el fail-before: toda la banda se pasa      -> PASS
  '200000 210000 100000 105000 excede'      # ...y aquí no se pasa ninguna                -> FAIL
  '270000 320000 100000 120000 excede'      # techo DENTRO en la dirección invertida     -> SKIP
)
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-03 la banda decide en las dos direcciones" | grep -qi -- "$FILTRO"; then
  nom37b='REQ-017 CA-03 la banda decide en las dos direcciones: PASS y FAIL sólo por unanimidad, y el techo dentro de la banda es SKIP'
  obs37b="$( { for _e37 in "${BAN37_TABLA[@]}"; do
        set -- $_e37; razon37 sonda-de-prueba "$1" "$3" 2600 x "$2" "$4" "$5"
      done
      razon37 sonda-de-prueba 270000 100000 2600 x '' 120000 no-excede   # sin el máximo del numerador
      razon37 sonda-de-prueba  40000  20000 2600 x  41000  21000 no-excede   # bajo el suelo de 50 ms
      razon37 sonda-de-prueba 270000 100000 2600 x 320000 120000 al-revés   # dirección no reconocida
    } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp37b='PASS FAIL SKIP SKIP PASS FAIL SKIP SKIP SKIP SKIP '
  if [ "$obs37b" = "$esp37b" ]; then
    echo "  PASS  $nom37b  (10 entradas → $obs37b)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom37b  se esperaba <$esp37b> y se obtuvo <$obs37b>"; FAIL=$((FAIL+1))
  fi
fi

# EL PAR DISCRIMINANTE, que es lo que hace segura a la guarda: la banda sólo puede
# ESTRECHAR. Se compara, entrada por entrada, el veredicto CON banda contra el que habría
# dado el cociente solo — y ese segundo lo calcula ESTE caso, no la función juzgada: un
# oráculo que saliera del código medido no podría fallar (la clase de CA-01, `ADR-004`).
# Se exigen las dos mitades: que NINGUNA entrada pase de FAIL a PASS, y que ALGUNA cambie
# de veredicto a abstención en cada dirección — sin la segunda, «no convierte un FAIL en
# PASS» lo cumpliría también una guarda que no hiciera nada.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-03 par discriminante" | grep -qi -- "$FILTRO"; then
  nom37c='REQ-017 CA-03 par discriminante: la banda sólo puede ESTRECHAR — nunca convierte un FAIL en PASS, y sí convierte veredictos en abstención'
  mal37c=''; fs37c=0; ps37c=0
  for _e37 in "${BAN37_TABLA[@]}"; do
    set -- $_e37
    _coc37=$(( $1 * 1000 / $3 ))
    if [ "$5" = no-excede ]; then
      _sin37=FAIL; [ "$_coc37" -le 2600 ] && _sin37=PASS
    else
      _sin37=FAIL; [ "$_coc37" -gt 2600 ] && _sin37=PASS
    fi
    banda37 "$1" "$2" "$3" "$4" 2600 "$5" || { mal37c="$mal37c <$_e37: la banda no supo decidir>"; continue; }
    [ "$_sin37" = FAIL ] && [ "$BAN37_V" = PASS ] && mal37c="$mal37c <$_e37: sin banda FAIL y con banda PASS>"
    [ "$_sin37" = FAIL ] && [ "$BAN37_V" = SKIP ] && fs37c=$((fs37c + 1))
    [ "$_sin37" = PASS ] && [ "$BAN37_V" = SKIP ] && ps37c=$((ps37c + 1))
  done
  [ "$fs37c" -ge 1 ] || mal37c="$mal37c <ninguna entrada pasó de FAIL a abstención: la guarda no decide>"
  [ "$ps37c" -ge 1 ] || mal37c="$mal37c <ninguna entrada pasó de PASS a abstención: la guarda no decide>"
  if [ -z "$mal37c" ]; then
    echo "  PASS  $nom37c  (${#BAN37_TABLA[@]} entradas: 0 de FAIL a PASS · $fs37c de FAIL a abstención · $ps37c de PASS a abstención)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom37c $mal37c"; FAIL=$((FAIL+1))
  fi
fi

# Y EL CONTENIDO DEL SKIP, NO SÓLO SU PALABRA. La autoprueba de arriba reduce cada salida
# a su veredicto y descarta el mensaje entero, así que una guarda cuyo contrato es LO QUE
# DICE quedaría verificada sólo por LO QUE DECIDE — por ese hueco se perdió el tercer
# elemento del SKIP de CA-08 (ii) sin que nada del banco lo viera (QA-017-16, `contrato`).
# CA-03 contrata TRES cifras en la abstención: la banda, el cociente y el techo.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-03 el SKIP de la banda cita las TRES cifras" | grep -qi -- "$FILTRO"; then
  nom37d='REQ-017 CA-03 el SKIP de la banda cita las TRES cifras: la banda, el cociente y el techo'
  sal37d="$( razon37 sonda-de-prueba 270000 100000 2600 x 320000 120000 no-excede 2>&1 )"
  falta37d=''
  case "$sal37d" in *'  SKIP  '*) ;; *) falta37d="$falta37d el-SKIP" ;; esac
  case "$sal37d" in *'2.250×'*) ;; *) falta37d="$falta37d el-extremo-bajo-de-la-banda(2.250)" ;; esac
  case "$sal37d" in *'3.200×'*) ;; *) falta37d="$falta37d el-extremo-alto-de-la-banda(3.200)" ;; esac
  case "$sal37d" in *'2.700×'*) ;; *) falta37d="$falta37d el-cociente(2.700)" ;; esac
  case "$sal37d" in *'2.600×'*) ;; *) falta37d="$falta37d el-techo(2.600)" ;; esac
  if [ -z "$falta37d" ]; then
    echo "  PASS  $nom37d  (banda 2.250×-3.200×, cociente 2.700×, techo 2.600×: las cuatro citadas)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom37d  al mensaje de la abstención le falta:$falta37d — <$sal37d>"; FAIL=$((FAIL+1))
  fi
fi

rm -rf "$HER37" "$BAS37"
