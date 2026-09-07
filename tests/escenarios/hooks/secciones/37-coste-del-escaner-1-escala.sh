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
CASOS_ESPERADOS_SECCION=9
seccion_nueva "--- 37/1 · el coste del escáner: escala, equivalencia y la pared de los 60 s (REQ-017) ---"

REPO37="$(cd "${SEC_DIR%/}/../../../.." 2>/dev/null && pwd || true)"
CR37=$'\r'

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

# ---------- CA-01 · LA EQUIVALENCIA, POR COMPARACIÓN DIFERENCIAL ----------
# No se enumeran salidas esperadas a mano: se corre la implementación de este árbol y la
# heredada sobre el MISMO corpus y se comparan sus estados BYTE A BYTE. Enumerar a mano
# es cómo se escribe una prueba que acredita lo que el autor creía, no lo que la función
# hace. El corpus vive AQUÍ y sólo aquí (CA-01), con semilla fija para que el CI repita
# la misma corrida, y lleva ADEMÁS las fronteras nombradas: si el azar no las produce,
# están igual.
CORPUS37="$RAIZ/corpus37-$BASHPID"
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
  RANDOM=20260907   # semilla fija: el CI repite la misma corrida
  for _i37 in $(seq 1 200); do
    _l37=''; _n37=$(( RANDOM % 40 ))
    for _j37 in $(seq 0 "$_n37"); do
      case $(( RANDOM % 8 )) in
        0) _l37+="$CR37" ;;   1) _l37+='<!--' ;;  2) _l37+='-->' ;;
        3) _l37+='Estado: ' ;; 4) _l37+='x' ;;    5) _l37+=' ' ;;
        6) _l37+='<!' ;;      *) _l37+='--' ;;
      esac
    done
    printf '%s\n' "$_l37"
  done
} > "$CORPUS37"

DIF37="$RAIZ/dif37-$BASHPID.sh"
cat > "$DIF37" <<'DIF37FIN'
LIB="$1"; CORPUS="$2"; MODO="$3"
source "$LIB" >/dev/null 2>&1 || { printf 'SIN-LIB\n'; exit 1; }
declare -F arnes_sin_cita >/dev/null 2>&1 || { printf 'SIN-FN\n'; exit 1; }
ARNES_CITA=0; ARNES_CR=0; ARNES_CR_LINEA=''; n=0
while IFS= read -r l || [ -n "$l" ]; do
  n=$((n+1))
  [ "$MODO" = indep ] && { ARNES_CITA=0; ARNES_CR=0; ARNES_CR_LINEA=''; }
  ARNES_LINEA='__sin_tocar__'
  arnes_sin_cita "$l"
  printf '%s|cita=%s|cr=%s|linea=<%s>|crlinea=<%s>\n' "$n" "$ARNES_CITA" "$ARNES_CR" "$ARNES_LINEA" "$ARNES_CR_LINEA"
done < "$CORPUS"
[ "$n" -gt 0 ] || { printf 'CORPUS-VACIO\n'; exit 1; }
DIF37FIN

# dif37 <nombre> <modo> — la comparación diferencial de un modo de recorrido.
dif37() {
  local nombre="$1" modo="$2" a b n
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$HER37_OK" != si ]; then
    echo "  SKIP  $nombre  no hay línea base: el tag v1.32.1 no está en este clon"; return 0
  fi
  a="$(bash "$DIF37" "$HER37/hooks/lib.sh" "$CORPUS37" "$modo" 2>/dev/null)"
  b="$(bash "$DIF37" "$LIB37" "$CORPUS37" "$modo" 2>/dev/null)"
  # Un diferencial sobre dos salidas VACÍAS sale idéntico y no ha comparado nada.
  if [ -z "$a" ] || [ -z "$b" ]; then
    echo "  FAIL  $nombre  una de las dos corridas no produjo salida (heredada=${#a} bytes, este árbol=${#b} bytes): no se comparó nada"; FAIL=$((FAIL+1)); return 0
  fi
  n="$(printf '%s\n' "$b" | grep -c '^' || true)"
  if [ "$a" = "$b" ]; then
    echo "  PASS  $nombre  ($n entradas, estado idéntico byte a byte)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  el estado difiere de v1.32.1:"; FAIL=$((FAIL+1))
    diff <(printf '%s\n' "$a") <(printf '%s\n' "$b") 2>/dev/null | head -6 | sed 's/^/          /'
  fi
}
dif37 "REQ-017 CA-01 diferencial contra v1.32.1: cada línea por separado (ARNES_LINEA/CITA/CR/CR_LINEA)" indep
dif37 "REQ-017 CA-01 ...y en secuencia, que es donde el estado de cita y de CR cruza líneas" secuencia

# El corpus tiene que CONTENER las fronteras que CA-01 nombra: un corpus generado que no
# las produjera dejaría la equivalencia acreditada sobre el caso fácil.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-01 fronteras" | grep -qi -- "$FILTRO"; then
  falta37=''
  for _p37 in "$CR37" "${CR37}Estado" "completado$CR37" "Esta${CR37}do" "<!$CR37--" "<!--$CR37" "-->" '<!-- rango que abre'; do
    grep -qF -- "$_p37" "$CORPUS37" || falta37="$falta37 <$(printf '%s' "$_p37" | cat -v)>"
  done
  n37="$(grep -c '^' "$CORPUS37" || true)"
  if [ -z "$falta37" ] && [ "${n37:-0}" -ge 200 ]; then
    echo "  PASS  REQ-017 CA-01 fronteras nombradas presentes en el corpus ($n37 entradas, semilla fija)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-017 CA-01 al corpus ($n37 entradas) le faltan fronteras:$falta37"; FAIL=$((FAIL+1))
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
pared37() {   # <dir de hooks> -> imprime el tamaño de los 60 s, o un motivo
  # EL COSTE FIJO SE RESTA ANTES DE MEDIR EL ORDEN, y sin eso la sonda MIENTE. A 96 KB el
  # arranque del hook (bash + jq + manifiesto) todavía pesa tanto como el escaneo, así que
  # el cociente de duplicación crudo sale ~1,3 sobre un camino que es cuadrático: la
  # extrapolación resultante colocaba la pared en 4,25 MB donde la medición directa a
  # 256/512/1024 KB la pone en 1,5. Se mide el término que crece —t(n) menos t(0)— que es
  # lo único de lo que depende el orden.
  local hd="$1" u0 ua ub n=98304
  u0="$(bash "$PARED37" "$hd" "$PROJ" 0            2>/dev/null)"
  ua="$(bash "$PARED37" "$hd" "$PROJ" "$n"         2>/dev/null)"
  ub="$(bash "$PARED37" "$hd" "$PROJ" "$(( n*2 ))" 2>/dev/null)"
  case "$u0$ua$ub" in ''|*[!0-9]*) printf 'no medible (<%s> <%s> <%s>)' "${u0:-vacío}" "${ua:-vacío}" "${ub:-vacío}"; return 1 ;; esac
  if [ "$(( ua - u0 ))" -lt 20000 ] || [ "$(( ub - u0 ))" -le "$(( ua - u0 ))" ]; then
    printf 'no medible en este rango: a %d KB el coste todavía lo domina el arranque (%.0f ms de %.0f ms)' \
      "$(( n*2/1024 ))" "$(awk -v x="$u0" 'BEGIN{print x/1000}')" "$(awk -v x="$ub" 'BEGIN{print x/1000}')"
    return 1
  fi
  awk -v u0="$u0" -v ua="$ua" -v ub="$ub" -v n="$(( n*2 ))" 'BEGIN{
    a = ua - u0; b = ub - u0
    p = log(b/a)/log(2)
    mb = (n * exp(log((60e6 - u0)/b)/p))/1048576
    if (mb > 1024) printf "> 1 GB (orden medido %.2f, coste casi independiente del tamaño; %.2f s a %d KB)", p, ub/1e6, n/1024
    else printf "%.2f MB (orden medido %.2f; %.2f s a %d KB, arranque %.2f s)", mb, p, ub/1e6, n/1024, u0/1e6 }'
}
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-09" | grep -qi -- "$FILTRO"; then
  este37="$(pared37 "$HOOKS_DIR")"
  her09_37="(sin línea base v1.32.1)"; [ "$HER37_OK" = si ] && her09_37="$(pared37 "$HER37/hooks")"
  bas09_37="(sin línea base v1.32.0)"; [ "$BAS37_OK" = si ] && bas09_37="$(pared37 "$BAS37/hooks")"
  echo "          medición CA-09 · tamaño de documento en que el hook alcanza los 60 s (una sola línea de cabecera):"
  echo "            este árbol : $este37"
  echo "            v1.32.1    : $her09_37"
  echo "            v1.32.0    : $bas09_37"
  case "$este37" in
    *MB*) echo "  PASS  REQ-017 CA-09 la pared de los 60 s queda MEDIDA y escrita para SEC-030 (no se mueve aquí)"; PASS=$((PASS+1)) ;;
    *)    echo "  SKIP  REQ-017 CA-09 la pared de los 60 s no se pudo medir: $este37" ;;
  esac
fi

rm -rf "$HER37" "$BAS37" "$CORPUS37" "$MED37" "$DIF37" "$PARED37"
