# Sección 39 (4 de 4) del banco — 39-caracter-invisible-4-el-coste
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
# —cociente de duplicación 3,78 (1000→2000) y 5,59 (2000→4000) contra un techo de 2,2, y 11,9 ms
# a 4 000 bytes—; con `LC_ALL=C` fijado dentro de la función de la guarda queda en 1,79 y 2,01 y
# además 17× más barata en absoluto. El método, el par de longitudes y los registros están en
# `docs/arnes/req-023-coste-y-dominio.md` §3.
#
# PARTE 4 DE 4 POR REQ-014 CA-18: con los lectores y el coste en un solo archivo salían 422
# líneas contra el techo de 400. El materializador de la línea base viene DUPLICADO de la parte
# 3 y de las cinco partes de la 37 (motivo escrito UNA vez en
# `37-coste-del-escaner-1-el-dominio.sh`; residual `AN-021-01`).
CASOS_ESPERADOS_SECCION=4
PISO_AUTONOMO_SECCION=185  # 29 preámbulo (líneas 1-29) + 77 maquinaria compartida duplicada (mat94 y la línea base, líneas 31-107) + 79 bloque indivisible mayor (mide94 y razon94, el medidor y la única puerta de las razones, líneas 112-190) · REQ-014 CA-18
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
# ---------- CA-09 · EL COSTE, POR LAS TRES VÍAS Y EN LA MISMA CORRIDA ----------
# El estadístico es el MÍNIMO de k, nunca la media: la carga sólo puede AÑADIR tiempo. Y una
# sonda que no llega a su suelo, o que no encuentra su línea base, emite SKIP CON EL MOTIVO Y
# CON EL NÚMERO QUE SÍ OBTUVO, nunca PASS.
MED94_US=''; MED94_MOTIVO=''
mide94() {   # <lib> <fn> <bytes> <k> -> MED94_US = mínimo de 3 series, en microsegundos
  local lib="$1" fn="$2" n="$3" k="$4" reg
  MED94_US=''; MED94_MOTIVO=''
  if [ ! -r "$lib" ]; then MED94_MOTIVO="no existe $lib"; return 1; fi
  # El sujeto es una línea de cabecera de tipo TÍTULO: clave larga y con bytes ajenos, que es
  # el camino LENTO de la guarda —el que limpia y compara—. Medir con una clave corta y limpia
  # daría verde a una guarda cuadrática, que es la forma (d) una vuelta más.
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "$fn-$n" \
    --prep "source '$lib' >/dev/null 2>&1 || :; s94='# REQ-023 — El carácter que no se ve apaga el enforcement, y '; l94=''; while [ \${#l94} -lt $n ]; do l94+=\"\$s94\"; done; l94=\"\${l94:0:$n}: pendiente\"" \
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
    echo "  SKIP  $nombre  no hay con qué medir: ${MED94_MOTIVO:-falta uno de los dos términos} (medido=<${med:-vacío}> base=<${base:-vacío}>)"; SKIP=$((SKIP+1)); return 0
  fi
  if [ "$med" -lt 50000 ] || [ "$base" -lt 50000 ]; then
    echo "  SKIP  $nombre  serie por debajo del suelo de 50 ms (medido=${med}µs base=${base}µs): el reloj no distingue del ruido"; SKIP=$((SKIP+1)); return 0
  fi
  coc=$(( med * 1000 / base ))
  if [ "$coc" -le "$techo" ]; then
    echo "  PASS  $nombre  $que = $(awk -v c=$coc 'BEGIN{printf "%.3f", c/1000}')× (techo $(awk -v t=$techo 'BEGIN{printf "%.3f", t/1000}')×; ${med}µs sobre ${base}µs)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  $que = $(awk -v c=$coc 'BEGIN{printf "%.3f", c/1000}')× > techo $(awk -v t=$techo 'BEGIN{printf "%.3f", t/1000}')× (${med}µs sobre ${base}µs)"; FAIL=$((FAIL+1))
  fi
}

# (iii) EL COCIENTE DE DUPLICACIÓN, con SU PAR DE LONGITUDES PUBLICADO. Un cociente depende del
# par con el que se toma, así que «2,2» sin decir entre qué dos longitudes no es comparable con
# nada. El par conforme conocido es 1000 → 2000, y la longitud menor es la primera a la que el
# mínimo de k supera el suelo de ruido. Se mide sobre el escáner donde la guarda RESIDE —hoy
# `arnes_norm_clave`— y sobre el de la publicación, `arnes_campo_linea`: si la guarda reside en
# más de uno, sobre TODOS ellos.
N94A=1000; N94B=2000; K94=200
for fn94 in arnes_norm_clave arnes_campo_linea; do
  u94a=''; u94b=''
  mide94 "$HOOKS_DIR/lib.sh" "$fn94" "$N94A" "$K94" && u94a="$MED94_US"
  mide94 "$HOOKS_DIR/lib.sh" "$fn94" "$N94B" "$K94" && u94b="$MED94_US"
  razon94 "REQ-023 CA-09 (iii) $fn94 no crece más que linealmente al doblar la línea" \
    "$u94b" "$u94a" 2200 "cociente de duplicación (${N94A}→${N94B} bytes, k=$K94)"
done

# (ii) EL RELOJ DE LA RUTA CRÍTICA, contra la línea base medida EN LA MISMA CORRIDA y con los
# DOS SUJETOS INTERCALADOS en la misma invocación de la sonda: así la carga de la máquina no
# cae entera sobre uno de los dos términos.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-09 (ii)" | grep -qi -- "$FILTRO"; then
  if [ "$HER94_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  no hay línea base v1.33.0 ($REGHER94)"; SKIP=$((SKIP+1))
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
      echo "  SKIP  REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  el registro de la sonda no es legible: $SONDA_MOTIVO"; SKIP=$((SKIP+1))
    elif [ "${SONDA[estado]}" != ok ] || ! num94 "${SONDA[min_a]:-}" || ! num94 "${SONDA[min_b]:-}"; then
      echo "  SKIP  REQ-023 CA-09 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  la sonda no pudo medir: estado=${SONDA[estado]:-vacío} motivo=${SONDA[motivo]:-sin motivo} (a=${SONDA[min_a]:-n/a}µs b=${SONDA[min_b]:-n/a}µs)"; SKIP=$((SKIP+1))
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
    echo "  SKIP  REQ-023 CA-09 (i) la guarda no añade ni un proceso por evaluación  no hay línea base v1.33.0 o no se preparó la entrada (${REGHER94:-sin registro})"; SKIP=$((SKIP+1))
  else
    c94a=''; c94b=''
    r94="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta este --sujeto "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT94' >/dev/null 2>&1" 2>/dev/null)"
    sonda_lee "$r94" && [ "${SONDA[estado]}" = ok ] && c94a="${SONDA[cuenta]:-}"
    r94="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta heredado --sujeto "bash '$HER94/hooks/guard-completado.sh' < '$ENT94' >/dev/null 2>&1" 2>/dev/null)"
    sonda_lee "$r94" && [ "${SONDA[estado]}" = ok ] && c94b="${SONDA[cuenta]:-}"
    if ! num94 "$c94a" || ! num94 "$c94b"; then
      echo "  SKIP  REQ-023 CA-09 (i) la guarda no añade ni un proceso por evaluación  la sonda de procesos no dejó las dos cuentas (este=<${c94a:-vacío}> heredado=<${c94b:-vacío}>): ${SONDA_MOTIVO:-${SONDA[motivo]:-sin motivo}}"; SKIP=$((SKIP+1))
    elif [ "$c94a" -le "$c94b" ]; then
      echo "  PASS  REQ-023 CA-09 (i) la evaluación gasta $c94a procesos y la línea base $c94b: 0 añadidos"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-09 (i) la evaluación gasta $c94a procesos contra $c94b de la línea base: $(( c94a - c94b )) añadido(s), y el techo es 0"; FAIL=$((FAIL+1))
    fi
  fi
fi

rm -rf "$HER94"
