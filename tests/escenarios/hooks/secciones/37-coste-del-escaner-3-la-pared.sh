# ---------- 37 (3/5) · EL COSTE DEL ESCÁNER: LA PARED DE LOS 60 s ----------
# REQ-017 CA-09. Un hook `PreToolUse` muere a los 60 s y UN HOOK MUERTO NO DENIEGA. Mover
# esa pared es SEC-030, preexistente en los DOS árboles y con dueño propio: aquí sólo se
# MIDE la dirección y se deja escrita.
#
# PARTE 3 DE 5 POR REQ-014 CA-18, y esta parte es CASI TODA su propio piso: preámbulo más
# el materializador duplicado más el bloque de CA-09 son todo el archivo menos tres líneas.
# Eso no es prolijidad, es lo que CA-18 (i) dice de un piso alto —«un archivo cuyo piso es
# 461 no se lee más barato partiéndolo»—: este archivo YA NO SE PUEDE PARTIR MÁS, y su
# derivación lo enseña término a término para que un lector lo pueda falsificar.
# `mat37` viene DUPLICADO de las otras partes de 37/1 (CA-04 + CA-19 + H-04 lo imponen); su
# motivo largo está escrito una sola vez, en `37-coste-del-escaner-1-el-dominio.sh`.
CASOS_ESPERADOS_SECCION=2
PISO_AUTONOMO_SECCION=283  # 18 preámbulo (líneas 1-18) + 119 maquinaria compartida duplicada (mat37 y la línea base, líneas 19-137) + 146 bloque indivisible mayor (PARED37, pared37 y dir09_37 con sus dos casos, líneas 139-284) · REQ-014 CA-18
seccion_nueva "--- 37/3 · el coste del escáner: la pared de los 60 s (REQ-017 CA-09) ---"

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

rm -rf "$HER37" "$PARED37"
