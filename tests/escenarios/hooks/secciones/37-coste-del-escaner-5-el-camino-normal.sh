# ---------- 37 (5/5) · EL CAMINO NORMAL: LAS DOS MAGNITUDES DE CA-08 ----------
# REQ-017 CA-08, y las dos mitades de CA-06 que no viven atadas a CA-05. Aquí se mide lo
# que NO se puede pagar por arreglar la ruta crítica: un `fork` en el camino de lectura de
# una cabecera normal.
#
# LAS DOS MAGNITUDES DE CA-08 VAN JUNTAS, Y ESA ES LA LECCIÓN DE ESTA VENTANA. CA-08 de
# REQ-016 contrataba PROCESOS por llamada: 4 = 4, medido correctamente, criterio en verde
# — mientras el reloj de la ruta crítica se multiplicaba por diez. Una magnitud correcta,
# medible sin ruido y ORTOGONAL a lo que se degradó. Por eso las dos aquí y en la misma
# corrida: los procesos, porque el arreglo no vale si compra tiempo con un `fork`; y el
# reloj, porque es lo que se degradó. Son baratas (~14 s) y corren SIEMPRE.
#
# PARTE 5 DE 5 POR REQ-014 CA-18: `mat47` viene DUPLICADO de
# `37-coste-del-escaner-4-la-ruta-critica.sh`, donde está escrito su motivo largo, porque
# CA-08 necesita el árbol heredado y CA-04 + CA-19 + H-04 hacen imposible factorizarlo.
CASOS_ESPERADOS_SECCION=9
PISO_AUTONOMO_SECCION=411  # 21 preámbulo (líneas 1-21) + 100 maquinaria compartida duplicada (num47 y mat47 con la línea base, líneas 22-121) + 290 bloque indivisible mayor (CA-08 entero: la medición de las dos magnitudes, razon08_47/veredicto08_47 y los casos que lo usan —incluido el par discriminante, que TIENE que ejercer la función que decide y no una copia suya, líneas 123-412) · REQ-014 CA-18
seccion_nueva "--- 37/5 · el camino de una cabecera normal: procesos y reloj (REQ-017 CA-08 y CA-06) ---"

BANCO47="${SEC_DIR%/}/../run.sh"

# UNO A UNO, Y NO CONCATENADOS: con `"$rc$ut"` un valor VACÍO desaparece dentro de los
# dígitos del vecino y la guarda deja pasar la basura que existe para atrapar. Y tampoco en
# un solo patrón separado por barras: dentro de un `case`, el `|` de `*[!0-9|]*` NO es un
# carácter de la clase — es el separador de alternativas del propio `case`, que parte el
# patrón en `*[!0-9` y `]*` y así no dispara NUNCA (comprobado en bash 5.3 al escribir
# esto: la primera versión de esta guarda no guardaba nada).
num47() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# EL MATERIALIZADOR VUELVE A VIVIR AQUÍ, INLINE (REQ-021 CA-05, reducción de alcance del
# 2026-09-08): `sonda-linea-base.sh` sale del alcance —calibración TAUTOLÓGICA y 21 procesos
# de calibración por corrida— y el criterio se enuncia sobre LA FUNCIÓN QUE MATERIALIZA,
# donde viva. Las cuatro propiedades portadas y los dos casos medidos que cierran están
# escritos UNA vez, en `37/1`, y no se transcriben aquí. Lo que sí hay que tener delante: esto
# y `mat37` son DOS COPIAS LITERALES de la misma lógica, nada comprueba que las dos conserven
# CA-05, y el forzador observable de que una se desvíe es el RECUENTO DE SKIP de la corrida
# —que es lo que delató el caso original, no el número—. Residual AN-021-01, ventana 1.34.0.
REPO47="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT47_RUTAS='hooks tools'
MAT47_REG=''; MAT47_T0=0; MAT47_REF='-'; MAT47_ETIQ='-'
mat47_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT47_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT47_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT47_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT47_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT47_ETIQ ref=$MAT47_REF archivos=$arch"
}
mat47() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT47_T0=${EPOCHREALTIME/./}
  MAT47_REF="${ref//[[:space:]]/_}"; MAT47_ETIQ="$MAT47_REF"; MAT47_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO. Con `-d`, las dos secciones 37
  # se abstenían enteras dentro de un worktree —la copia haciendo la mitad del trabajo, el
  # caso que CA-05 cierra— mientras `git` resolvía el tag sin problema. Medido al montar los
  # dos árboles de CA-08; el motivo largo está en `37/1`, donde vive la copia gemela.
  [ -e "$REPO47/.git" ] || { mat47_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO47" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat47_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO47" ls-tree -r "$ref" -- $MAT47_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat47_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat47_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat47_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO47" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat47_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat47_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO47" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat47_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat47_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat47_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat47_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat47_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat47_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat47_reg ok - "$n" "$procs"
  return 0
}
HER47="$RAIZ/her47-$BASHPID"; HER47_OK=no; REGHER47=''
mat47 v1.32.1 "$HER47" && HER47_OK=si
REGHER47="$MAT47_REG"
# LOS NOMBRES SE FIJAN AQUÍ, FUERA DE TODA SUSTITUCIÓN, Y ESO NO ES ESTILO. `$BASHPID`
# dentro de `$( )` es el PID del SUBSHELL DE LA SUSTITUCIÓN, no el de la sección: escrito
# en línea, cada corrida guardaba su salida en un archivo con otro nombre y el inventario
# leía uno vacío. Salía «no se comparó nada» —fail-closed, que es la dirección correcta—
# pero por un motivo que no era el suyo.
OUT_ESTE47="$RAIZ/s32-este-$BASHPID"      # se le añade "-<vuelta>.txt": son TRES corridas
OUT_HER47="$RAIZ/s32-her-$BASHPID.txt"
TRAB47="$RAIZ/s32-her-trabajo-$BASHPID"   # el `TMPDIR` de la corrida heredada: ver `caso47`

# ---------- CA-08 · LAS DOS MAGNITUDES DEL CAMINO NORMAL ----------
mkreq_r REQ-100 no aprobado n/a estandar     # un REQ real: 6 líneas de cabecera
{ printf '# REQ-200\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n'
  _i47=1; while [ "$_i47" -le 195 ]; do printf 'Campo%03d: valor de relleno de cabecera\n' "$_i47"; _i47=$((_i47+1)); done
} > "$PROJ/requirements/REQ-200.md"
json47() {   # <REQ> -> el Edit que cierra ese REQ
  jq -n --arg fp "$PROJ/requirements/$1.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.NADA,
      tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}'
}
# EL PROCEDIMIENTO DE MEDIDA ES PARTE DEL CRITERIO (CA-08), Y LOS DOS INSTRUMENTOS QUE LO
# IMPLEMENTAN VIVEN AHORA EN `tests/util/` (REQ-021). SER47 series por árbol, INTERCALADAS
# a, b, a, b, y el estadístico es el MÍNIMO: los impone `sonda-reloj.sh`, no este archivo
# —«una disciplina que depende de que quien llama se acuerde no es una disciplina»—. Y el
# reloj se toma SIN la instrumentación de procesos, que es otra invocación y otra sonda: un
# envoltorio por proceso mide el envoltorio (CA-02 punto 5).
#
# K47=4: cada serie ronda medio segundo, diez veces por encima del suelo de 50 ms donde el
# reloj deja de distinguir del ruido. Se baja de 8 a 4 porque las series se DUPLICAN de 3 a 6:
# el coste total en llamadas al hook queda igual que antes del arreglo, y el reparto —más
# series y más cortas— es el que reduce la varianza que este criterio venía a quitar.
SER47=6   # >= 6 por árbol (CA-08, OPERATIVO: se sube con la medición)
K47=4     # repeticiones del sujeto DENTRO de cada serie
# KRAZ47 ES EL `k` DEL CONTRATO: repeticiones del PAR INTERCALADO ENTERO, cada una con SU
# propia razón. No se confunde con K47. OPERATIVO: se sube con la medición, y su valor se
# DERIVA MIDIENDO (REQ-012 CA-03), no se elige — la clase de defecto que este REQ arregla
# nació de fijar un número compatible con un argumento correcto sin comprobar que alcanzaba.
# Derivado el 2026-09-08 sobre 56 repeticiones reales en tres entornos: máquina ociosa, con 5
# vecinos del mismo tipo que el banco fabrica, y con TODO fijado a 2 CPU y 6 procesos encima
# para reproducir la FORMA del runner de la puerta requerida. El recorrido observado CRECE con
# las repeticiones y SATURA: k=4 es el menor tamaño de ventana cuya PEOR ventana ya alcanza el
# recorrido de la muestra entera en las cuatro series (2 CPU: 1,268× de 1,268× y 1,262× de
# 1,262×; con k=3 la segunda sólo veía 1,178× de 1,262×, o sea que INFRADECLARABA su ruido).
# Menos repeticiones no ven la dispersión que tienen que juzgar; más sólo cuestan reloj.
KRAZ47=4
TECHO47=1250   # ‰. EL MISMO número para la razón y para la convergencia, y no es casualidad:
               # «un instrumento tiene que resolver al menos el factor que vigila». No es un
               # techo nuevo, es el de CA-08 (ii) leído sobre la propia sonda.
FACTOR47=2000  # ‰. La regresión SINTÉTICA del par discriminante (b): no menos de 2×
               # (OPERATIVO: se baja con la medición, siempre estrictamente por encima del
               # techo). Suelo derivado: techo × el peor recorrido medido de la razón
               # (1,250 × 1,400, las cinco corridas de CI sobre código idéntico) = 1,750.
# EL TECHO DE COSTE DE LA GUARDA, porque (ii) corre en la puerta requerida de `main`. Lo que
# la guarda AÑADE son las repeticiones 2..KRAZ47: con k=1 no hay recorrido que juzgar. Medido
# el 2026-09-08, banco entero con `JOBS=6`, mínimo de 3 vueltas: 49,19 s sin la guarda y
# 77,19 s con ella, o sea +28,0 s = 0,569× de lo que la puerta costaba. TECHO 0,750×
# (OPERATIVO: se BAJA con la medición; es techo y nunca igualdad), que deja ~32 % de margen
# sobre lo medido y SÍ muerde: subir k a 6 lo pondría en ~0,95× y el techo lo vería.
# NO lo vigila un caso, y el motivo se escribe en vez de omitirse: el numerador sólo se puede
# medir cronometrando la puerta ENTERA desde dentro de una de sus secciones —circular—, y toda
# versión local del cociente sale fijada por construcción en (KRAZ47-1)/1, que no mide nada.
# Se acredita en el Historial del REQ con su corrida, como CA-05 (i) y (ii). Y cabe frente a
# lo que protege: la regresión que este REQ arregla valía 92 s en esa misma puerta. No se
# declara como constante a propósito: una constante que nadie lee finge ser una palanca.
# Milésimas -> texto, SIN fork: `printf -v` es builtin y no abre subshell. Un `$(awk …)` por
# número eran ~10 forks por caso en el archivo que mide forks.
FMT47=''
fmt47() { printf -v FMT47 '%d.%03d×' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }
declare -A PROCS47 REPS47
falta47=''
JSON47="$RAIZ/json47-$BASHPID.json"
for _cual47 in REQ-100 REQ-200; do
  json47 "$_cual47" > "$JSON47" 2>/dev/null
  if [ ! -s "$JSON47" ]; then falta47="el JSON de $_cual47 salió vacío: el hook no habría recibido entrada"; continue; fi
  # Los procesos, una vez por árbol: es un recuento, no una medida de reloj, y no tiene ruido.
  for _arb47 in este heredado; do
    _hd47="$HOOKS_DIR"; [ "$_arb47" = heredado ] && _hd47="$HER47/hooks"
    if [ "$_arb47" = heredado ] && [ "$HER47_OK" != si ]; then falta47="sin línea base v1.32.1"; continue; fi
    _reg47="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "$_cual47-$_arb47" \
      --sujeto "CLAUDE_PROJECT_DIR='$PROJ' bash '$_hd47/guard-completado.sh' < '$JSON47'" 2>/dev/null)"
    if sonda_lee "$_reg47" && [ "${SONDA[estado]}" = ok ] && num47 "${SONDA[cuenta]:-}"; then
      PROCS47["$_cual47-$_arb47"]="${SONDA[cuenta]}"
    else
      falta47="la sonda de procesos no midió (${SONDA_MOTIVO:-estado=${SONDA[estado]:-?} motivo=${SONDA[motivo]:-?}})"
    fi
  done
  # Y EL RELOJ, INTERCALADO EN UNA SOLA INVOCACIÓN. La alternancia la hace la sonda: las dos
  # series consecutivas de árboles distintos ven el mismo vecindario, y en bloque cada árbol
  # veía vecinos distintos (QA-017-06: 1,217 en bloque frente a 1,012 intercalado).
  #
  # Y EL PAR ENTERO SE REPITE KRAZ47 VECES, cada repetición con SU razón: la dispersión que
  # (ii) tiene que juzgar es la de la RAZÓN entre pares, y una sola invocación no la puede
  # exhibir —da un punto, y un punto no tiene recorrido—. Sin línea base no se mide: el
  # veredicto necesita los dos brazos, y medir uno solo sería pagar KRAZ47 pares para acabar
  # igualmente en SKIP.
  REPS47["$_cual47"]=''
  if [ "$HER47_OK" != si ]; then
    falta47="sin línea base v1.32.1"
  else
    for ((_n47 = 1; _n47 <= KRAZ47; _n47++)); do
      _reg47="$("$UTIL_DIR/sonda-reloj.sh" --k "$K47" --r "$SER47" --etiqueta "$_cual47-r$_n47" \
        --sujeto-a "CLAUDE_PROJECT_DIR='$PROJ' bash '$HOOKS_DIR/guard-completado.sh' < '$JSON47' >/dev/null 2>&1" \
        --sujeto-b "CLAUDE_PROJECT_DIR='$PROJ' bash '$HER47/hooks/guard-completado.sh' < '$JSON47' >/dev/null 2>&1" 2>/dev/null)"
      if sonda_lee "$_reg47" && [ "${SONDA[estado]}" = ok ]; then
        REPS47["$_cual47"]="${REPS47[$_cual47]} ${SONDA[min_a]:-}:${SONDA[min2_a]:-}:${SONDA[min_b]:-}:${SONDA[min2_b]:-}"
      else
        # La repetición entra IGUAL, vacía: una repetición que no midió no se descarta en
        # silencio —eso encogería la k sin decirlo—, se lleva el caso entero a SKIP.
        falta47="la sonda de reloj no midió en la repetición $_n47 (${SONDA_MOTIVO:-estado=${SONDA[estado]:-?} motivo=${SONDA[motivo]:-?}})"
        REPS47["$_cual47"]="${REPS47[$_cual47]} :::"
      fi
    done
  fi
done
rm -f "$JSON47"

# EL VEREDICTO DE CA-08 (ii), EN UNA FUNCIÓN PURA — y pura para poder probar la abstención con
# entradas sintéticas: en una corrida sana la sonda CONVERGE, así que el camino que más
# importa es justamente el que nunca se recorrería.
#
# LA SONDA DECLARA SU RESOLUCIÓN ANTES DE JUZGAR. Medido en la vuelta 1 con el procedimiento
# sin implementar: 26 medidas, 2 en rojo (1,252× y 1,443× contra 1,250×) y 1 de cada 4 vueltas
# del banco completo EN EL MODO DE LA PUERTA REQUERIDA salió roja, con `load` 0,91 al arrancar
# —así que la carga previa no lo explica—. Que la causa es el instrumento y no el arreglo lo
# dice la misma serie: en aislamiento la razón da 0,821–1,010, y un coste real no puede ser
# negativo, luego 0,821–1,443 sobre el MISMO estimando es varianza de la sonda.
#
# Por eso, además de intercalar, se compara el SEGUNDO MÍNIMO con el MÍNIMO de CADA árbol
# contra el PROPIO techo, y si lo supera el caso se ABSTIENE: nunca PASS y nunca FAIL. Esa
# comprobación SE QUEDA COMO ESTABA —mismo umbral, mismo SKIP— y desde el 2026-09-08 está
# marcada NECESARIA Y NO SUFICIENTE: responde «¿se asentó CADA serie?», no «¿puede ESTE
# COCIENTE distinguir el factor que vigila?». Acota la dispersión DENTRO de cada brazo, y el
# ruido de la razón viene de las condiciones ENTRE brazos: dos series pueden converger cada
# una bajo el techo y su cociente oscilar por encima. Medido sobre CINCO corridas de la puerta
# requerida con CÓDIGO IDÉNTICO —ningún commit tocó `hooks/`, `tools/` ni `.github/`, R-019—:
# la razón recorre 0,973–1,364 (factor 1,40) contra un techo de 1,25, o sea que el techo VIVE
# DENTRO del ruido del instrumento; el 0,973× cierra la discusión, porque una regresión real
# no puede ser MÁS RÁPIDA que la línea base. Y los dos rojos son justo aquellos en que UN
# brazo converge al borde (1,232× y 1,249× contra 1,250×) mientras el otro converge holgado.
#
# ENCIMA DE ELLA, LA RESOLUCIÓN SOBRE LA RAZÓN, que es la magnitud que (ii) juzga: KRAZ47
# repeticiones del par, y el veredicto sólo se emite si NO depende del ruido. PASS si máx(r)
# <= techo (conforme en TODAS), FAIL si mín(r) > techo (excedido en TODAS, así que no lo puso
# ahí el vecino) y SKIP en cuanto el techo cae DENTRO del recorrido. La unanimidad es DE
# CONTRATO: es la definición de «la decisión no depende del ruido», y no admite mayoría,
# promedio ni «la mejor de k». El techo NO se toca: es `operativo` y su dirección es BAJAR.
R47=''; MOT47=''; CONV47=0
razon08_47() {   # <ue:ue2:uh:uh2 en µs> -> R47 y CONV47, o R47 vacío y MOT47 con el motivo
  local rep="$1" ue ue2 uh uh2 ce ch x
  R47=''; MOT47=''; CONV47=0
  ue="${rep%%:*}"; x="${rep#*:}"; ue2="${x%%:*}"; x="${x#*:}"; uh="${x%%:*}"; uh2="${x##*:}"
  for x in "$ue" "$ue2" "$uh" "$uh2"; do
    num47 "$x" && [ "$x" -gt 0 ] && continue
    MOT47="la sonda no dio $SER47 series por árbol con sus dos mínimos (este ${ue:-vacío}/${ue2:-vacío}µs · heredada ${uh:-vacío}/${uh2:-vacío}µs)"; return 0
  done
  if [ "$uh" -lt 50000 ] || [ "$ue" -lt 50000 ]; then
    MOT47="serie por debajo del suelo de 50 ms (este ${ue}µs · heredada ${uh}µs): el reloj no distingue del ruido"; return 0
  fi
  ce=$(( ue2 * 1000 / ue )); ch=$(( uh2 * 1000 / uh ))
  CONV47="$ce"; [ "$ch" -gt "$ce" ] && CONV47="$ch"
  if [ "$CONV47" -gt "$TECHO47" ]; then
    fmt47 "$ce"; x="$FMT47"; fmt47 "$ch"; ce="$FMT47"; fmt47 "$TECHO47"; ch="$FMT47"
    MOT47="la sonda NO convergió: segundo mínimo / mínimo = $x (este) y $ce (heredada), por encima de su propio techo $ch — no puede distinguir una regresión de su ruido, y sobre eso no se firma"
    return 0
  fi
  R47=$(( ue * 1000 / uh ))
}
# `guarda` = no reproduce la regla ANTERIOR —una razón, un veredicto— y existe sólo para la
# segunda mitad del par discriminante (a): sin ella, un SKIP no demuestra que lo haya causado
# la guarda. No toca los contadores: no es un caso, es el testigo de uno.
veredicto08_47() {   # <nombre> <guarda: si|no> <rep...>, rep = ue:ue2:uh:uh2 en µs
  local nombre="$1" guarda="$2"; shift 2
  local rep n=0 rmin='' rmax='' cmax=0 lista='' techo mn mx rec
  fmt47 "$TECHO47"; techo="$FMT47"
  if [ "$guarda" = no ]; then
    for rep in "$@"; do
      razon08_47 "$rep"
      if [ -z "$R47" ]; then echo "  SKIP  $nombre  $MOT47"; continue; fi
      fmt47 "$R47"
      if [ "$R47" -le "$TECHO47" ]; then echo "  PASS  $nombre  $FMT47 <= $techo"
      else echo "  FAIL  $nombre  $FMT47 > $techo"; fi
    done
    return 0
  fi
  for rep in "$@"; do
    n=$((n + 1))
    razon08_47 "$rep"
    [ -n "$R47" ] || { echo "  SKIP  $nombre  repetición $n de $#: $MOT47"; return 0; }
    if [ "$CONV47" -gt "$cmax" ]; then cmax="$CONV47"; fi
    fmt47 "$R47"; lista="$lista $FMT47"
    if [ -z "$rmin" ] || [ "$R47" -lt "$rmin" ]; then rmin="$R47"; fi
    if [ -z "$rmax" ] || [ "$R47" -gt "$rmax" ]; then rmax="$R47"; fi
  done
  [ "$n" -ge 1 ] || { echo "  SKIP  $nombre  no llegó ninguna repetición del par intercalado"; return 0; }
  rec=$(( rmax * 1000 / rmin ))
  fmt47 "$rmin"; mn="$FMT47"; fmt47 "$rmax"; mx="$FMT47"; fmt47 "$rec"; rec="$FMT47"; fmt47 "$cmax"; cmax="$FMT47"
  # Las k razones, el recorrido y el techo se publican SIEMPRE, decida lo que decida: son la
  # evidencia de que la decisión no depende del ruido, no el adorno del SKIP.
  lista="$n razones:$lista · recorrido $rec · techo $techo · peor convergencia $cmax"
  if [ "$rmax" -le "$TECHO47" ]; then
    echo "  PASS  $nombre  máx(r) $mx <= techo en las $lista"; PASS=$((PASS+1))
  elif [ "$rmin" -gt "$TECHO47" ]; then
    echo "  FAIL  $nombre  mín(r) $mn > techo en TODAS: es regresión, no ruido — $lista"; FAIL=$((FAIL+1))
  else
    echo "  SKIP  $nombre  el techo cae DENTRO del recorrido observado [$mn, $mx]: el instrumento no distingue el factor que vigila — $lista"
  fi
}

for _cual47 in REQ-100 REQ-200; do
  _etq47="un REQ real de 6 líneas"; [ "$_cual47" = REQ-200 ] && _etq47="una cabecera de 200 líneas"
  nom47="REQ-017 CA-08 (i) $_etq47: 0 procesos añadidos respecto a v1.32.1"
  if [ -z "$FILTRO" ] || printf '%s' "$nom47" | grep -qi -- "$FILTRO"; then
    pe47="${PROCS47[$_cual47-este]:-}"; ph47="${PROCS47[$_cual47-heredado]:-}"
    if [ -z "$pe47" ] || [ -z "$ph47" ]; then
      echo "  SKIP  $nom47  ${falta47:-no se pudo medir} (este=<${pe47:-vacío}> heredado=<${ph47:-vacío}>)"
    elif [ "$pe47" -le "$ph47" ]; then
      echo "  PASS  $nom47  $pe47 procesos frente a $ph47 (menos es conforme)"; PASS=$((PASS+1))
    else
      echo "  FAIL  $nom47  $pe47 procesos frente a $ph47: el arreglo compró tiempo con un fork"; FAIL=$((FAIL+1))
    fi
  fi
  nom47="REQ-017 CA-08 (ii) $_etq47: el reloj no sube más de 1,25× el de v1.32.1"
  if [ -z "$FILTRO" ] || printf '%s' "$nom47" | grep -qi -- "$FILTRO"; then
    reps47="${REPS47[$_cual47]:-}"
    if [ -z "${reps47// /}" ]; then
      echo "  SKIP  $nom47  ${falta47:-no se pudo medir}: no llegó ninguna repetición del par intercalado"
    else
      veredicto08_47 "$nom47" si $reps47   # SIN comillas a propósito: una palabra por repetición
    fi
  fi
done

# LA CLÁUSULA DE CONVERGENCIA, PROBADA CON ENTRADAS SINTÉTICAS Y EN MILISEGUNDOS. En una
# corrida sana la sonda converge, así que el camino que de verdad importa —la abstención— no
# se recorrería nunca y nadie sabría si cierra. Es la misma lección que cerró QA-017-03 y
# QA-017-04 una capa más arriba: la puerta corría sólo cuando la palanca la encendía.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-08 (ii) la sonda que no converge se ABSTIENE" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-08 (ii) la sonda que no converge se ABSTIENE: nunca PASS y nunca FAIL, y la abstención manda sobre el rojo"
  obs08_47="$( {
    veredicto08_47 sonda-de-prueba si 1000000:1050000:1000000:1020000   # converge y está bajo el techo
    veredicto08_47 sonda-de-prueba si 1300000:1310000:1000000:1020000   # converge y lo CRUZA: eso sí es FAIL
    veredicto08_47 sonda-de-prueba si 1000000:1400000:1000000:1020000   # este árbol no converge (1,400×)
    veredicto08_47 sonda-de-prueba si 1000000:1050000:1000000:1400000   # la heredada no converge
    veredicto08_47 sonda-de-prueba si 1300000:1700000:1000000:1020000   # cruzaría el techo Y no converge (1,308×): manda la abstención
    veredicto08_47 sonda-de-prueba si        '':1050000:1000000:1020000 # falta un número
    veredicto08_47 sonda-de-prueba si   40000:41000:40000:41000         # bajo el suelo de 50 ms
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp08_47='PASS FAIL SKIP SKIP SKIP SKIP SKIP '
  if [ "$obs08_47" = "$esp08_47" ]; then
    echo "  PASS  $nom47  (7 sondas → $obs08_47)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  se esperaba <$esp08_47> y se obtuvo <$obs08_47>"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `veredicto08_47` corrió dentro de una sustitución de
# comandos, que es un subshell, y sus PASS/FAIL murieron con él.

# EL PAR DISCRIMINANTE, SIN EL CUAL LA GUARDA NO ACREDITA NADA — Y SE EJECUTA, NO SE ARGUMENTA.
# «La abstención no tapa una regresión real» es una afirmación sobre cómo se comporta el
# mecanismo, y este REQ lleva TRES de esa clase que resultaron falsas al ejecutarlas.
#
# EL FORZADOR ES SINTÉTICO Y AFECTA SÓLO A PARTE DE LAS REPETICIONES, que es la vía que el
# criterio admite al lado de la contención real con `JOBS=6`. Se toma ésta porque es
# DETERMINISTA y no le cuesta reloj a la puerta requerida: una contención real que unas veces
# dispersa y otras no sería un rojo intermitente en la puerta requerida, que es exactamente el
# modo de fallo que este REQ existe para quitar. La razón VERDADERA es 1,0 —el árbol medido
# contra sí mismo— en las cuatro repeticiones, y el forzador infla el brazo «este» de UNA de
# ellas hasta 1,364×, la magnitud del rojo real medido en CI sobre código idéntico. Los dos
# brazos CONVERGEN en las cuatro (1,010×), así que la abstención no puede venir de la guarda
# anterior: si sale, sale de la del recorrido.
DISP47='1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000 1364000:1374000:1000000:1010000 1000000:1010000:1000000:1010000'
LIMPIO47='1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000'
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-08 (ii) par discriminante NEGATIVO" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-08 (ii) par discriminante NEGATIVO: dispersión ensanchada SIN regresión da SKIP, y con la guarda desactivada la MISMA entrada da PASS o FAIL según la repetición"
  con47="$(veredicto08_47 sonda-de-prueba si $DISP47 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  sin47="$(veredicto08_47 sonda-de-prueba no $DISP47 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  if [ "$con47" = 'SKIP ' ] && [ "$sin47" = 'PASS PASS FAIL PASS ' ]; then
    echo "  PASS  $nom47  (con la guarda: $con47· sin ella: $sin47— el rojo lo quita la guarda, no la entrada)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  con la guarda se esperaba <SKIP > y salió <$con47>; sin ella se esperaba <PASS PASS FAIL PASS > y salió <$sin47>"; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-08 (ii) par discriminante POSITIVO" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-08 (ii) par discriminante POSITIVO: una regresión sintética de 2× da FAIL y no SKIP, y sin regresión ni forzador da PASS"
  # La regresión se aplica SOBRE la entrada dispersa del caso (a) —forzador incluido—, no
  # sobre una limpia: lo que hay que demostrar es que la abstención no se traga una regresión
  # ESTANDO el ruido presente, que es cuando la abstención sería la respuesta cómoda.
  reg47=''
  for _r47 in $DISP47; do
    _ue47="${_r47%%:*}"; _x47="${_r47#*:}"
    reg47="$reg47 $(( _ue47 * FACTOR47 / 1000 )):$(( ${_x47%%:*} * FACTOR47 / 1000 )):${_x47#*:}"
  done
  obsreg47="$(veredicto08_47 sonda-de-prueba si $reg47 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  obslim47="$(veredicto08_47 sonda-de-prueba si $LIMPIO47 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  if [ "$obsreg47" = 'FAIL ' ] && [ "$obslim47" = 'PASS ' ]; then
    echo "  PASS  $nom47  (con la regresión de 2×: $obsreg47· sin ella y sin forzador: $obslim47)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  con la regresión se esperaba <FAIL > y salió <$obsreg47>; sin ella se esperaba <PASS > y salió <$obslim47>"; FAIL=$((FAIL+1))
  fi
fi

# La sonda de procesos se comprueba A SÍ MISMA: si el envoltorio se resolviera a sí mismo
# —el fallo real de 1.32.1— la sonda tiene que DECIRLO y no dar un número. Se le da un
# PATH que ya contiene un `grep` falso y se exige que no lo tome por el binario real.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-06 el envoltorio no se resuelve a sí mismo" | grep -qi -- "$FILTRO"; then
  trampa47="$RAIZ/trampa47-$BASHPID"; mkdir -p "$trampa47"
  printf '#!/bin/sh\nexit 0\n' > "$trampa47/grep"; chmod +x "$trampa47/grep"
  # EL NOMBRE SE FIJA AQUÍ, FUERA DE TODA SUSTITUCIÓN, y esto no es estilo: `$BASHPID`
  # dentro de `$( )` es el PID del SUBSHELL DE LA SUSTITUCIÓN, no el de la sección. Escrito
  # en línea, el archivo que se escribe y el que se lee llevan nombres distintos y la sonda
  # mide un sujeto que no existe. Volvió a ocurrir al mudar esta sección a `tests/util/`.
  jsontrampa47="$RAIZ/trampa47-json-$BASHPID.json"
  json47 REQ-100 > "$jsontrampa47" 2>/dev/null
  sal47="$(PATH="$trampa47:$PATH" "$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" \
    --sujeto "CLAUDE_PROJECT_DIR='$PROJ' bash '$HOOKS_DIR/guard-completado.sh' < '$jsontrampa47'" 2>/dev/null)"
  # `type -P` resuelve al PRIMER grep del PATH, que es la trampa; lo que se exige es que la
  # sonda no acabe apuntándose a su propio directorio ni devuelva basura.
  if ! sonda_lee "$sal47"; then
    echo "  FAIL  REQ-017 CA-06 la sonda de procesos no dejó registro legible con un binario sombreado en el PATH: $SONDA_MOTIVO"; FAIL=$((FAIL+1))
  elif [ "${SONDA[estado]}" = envoltorio-recursivo ]; then
    echo "  PASS  REQ-017 CA-06 el envoltorio detecta y denuncia resolverse a sí mismo (<${SONDA[motivo]}>)"; PASS=$((PASS+1))
  elif [ "${SONDA[estado]}" = ok ] && num47 "${SONDA[cuenta]:-}"; then
    echo "  PASS  REQ-017 CA-06 el envoltorio resuelve rutas absolutas antes de tocar el PATH y no se llama a sí mismo (<${SONDA[cuenta]}> procesos)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-017 CA-06 la sonda de procesos respondió estado=${SONDA[estado]} motivo=${SONDA[motivo]:-} cuenta=<${SONDA[cuenta]:-vacío}> con un binario sombreado en el PATH"; FAIL=$((FAIL+1))
  fi
  rm -f "$jsontrampa47"
  rm -rf "$trampa47"
fi

# ---------- CA-06 · EL CORREDOR ACUSA A LA SECCIÓN QUE DEJA UN PROCESO VIVO ----------
# Se comprueba sobre el corredor REAL, con una sección sintética que deja un proceso
# corriendo, igual que hace `autoprueba-corredor.sh`. Es la mitad de CA-06 que no vive en
# la sonda sino en quien cierra la sección.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-06 el corredor acusa" | grep -qi -- "$FILTRO"; then
  sint47="$RAIZ/sint47-$BASHPID"; mkdir -p "$sint47"
  { echo 'CASOS_ESPERADOS_SECCION=1'
    echo 'sleep 120 &'
    echo 'echo "  PASS  seccion sintetica que deja una sonda viva"'
  } > "$sint47/90-deja-sonda-viva.sh"
  out47="$(ARNES_SECCIONES_DIR="$sint47" bash "$BANCO47" 2>&1)"
  rc47=$?
  vivos47="$(printf '%s' "$out47" | grep -c 'dejando procesos vivos' || true)"
  if [ -z "$out47" ]; then
    echo "  FAIL  REQ-017 CA-06 el corredor acusa a la sección que deja un proceso vivo  la autoprueba no imprimió nada"; FAIL=$((FAIL+1))
  elif [ "${vivos47:-0}" -ge 1 ] && [ "$rc47" -ne 0 ]; then
    echo "  PASS  REQ-017 CA-06 el corredor acusa POR SU NOMBRE a la sección que deja un proceso vivo, y la vuelta sale en rojo"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-017 CA-06 el corredor no acusó el proceso vivo (rc=$rc47, avisos=$vivos47): una sonda huérfana envenenaría la vuelta siguiente"; FAIL=$((FAIL+1))
    printf '%s' "$out47" | tail -4 | sed 's/^/          /'
  fi
  rm -rf "$sint47"
fi

rm -rf "$HER47"
