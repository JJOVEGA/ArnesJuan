# Sección 39 (5 de 5) del banco — 39-caracter-invisible-5-el-corpus
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-023 · SEC-047 (mitad 1). EL CORPUS: `CA-04` (no se estrecha NINGUNA tolerancia: el corpus
# decide campo a campo y decisión a decisión lo mismo que la versión heredada, medidas las dos en
# la misma corrida). `CA-03` —la clase, con su sorteo estratificado— se queda en la parte 2.
#
# PARTE 5 DE 5 POR REQ-014 CA-18, Y EL NÚMERO ES 5 Y NO 3 A PROPÓSITO. Sale de la parte 2, que
# llevaba la clase Y el corpus y quedó en 402 líneas contra su techo de 400 (piso 294 ⇒ gobierna
# `N`). Se numera al final, igual que se numeró la parte 4 cuando salió de la 3: renumerar las
# partes 3 y 4 para dejar el corpus en el 3 dejaría desfasadas las citas por nombre y línea que ya
# viven en `requirements/REQ-023.md` y en `docs/qa/1.34.0.md`, y una cita rota cuesta más que un
# número no contiguo.
#
# EL CORTE VA POR TEMA Y SIN DEPENDENCIAS CRUZADAS, y se verificó leyendo: este archivo no usa
# ningún nombre definido en el bloque de `CA-03`, y aquél no usa ninguno de los de aquí. El
# respaldo por máquina es el cuadre por sección: 10 = 7 + 3, y `CASOS_ESPERADOS` de `run.sh` no
# cambia, porque partir REPARTE los casos y no crea ni pierde ninguno.
#
# El materializador de la línea base (`mat92`) viene DUPLICADO de la parte 2 a propósito: cada
# sección corre en su propio subshell, ninguna hace `source` de otra, y en `secciones/` no cabe un
# archivo auxiliar. Su motivo largo y las cuatro propiedades de `REQ-021 CA-05` que porta están
# escritos UNA vez, en `37-coste-del-escaner-1-el-dominio.sh`, y no se transcriben aquí. Residual
# `AN-021-01`. Los sufijos `92`/`93` de los nombres se conservan tal como venían de la parte 2:
# renombrarlos no compra nada —cada parte es su propio subshell— y sí arriesga una errata.
CASOS_ESPERADOS_SECCION=3
PISO_AUTONOMO_SECCION=165  # 30 preámbulo (líneas 1-30) + 76 maquinaria compartida duplicada (mat92 y la línea base, líneas 32-107) + 59 bloque indivisible mayor (el evaluador EVA93, el corpus y su medición, líneas 109-167: ningún caso de CA-04 puede prescindir de ellos, así que ninguna partición de este archivo los baja) · REQ-014 CA-18
seccion_nueva "--- 39/5 · el carácter invisible: el corpus (REQ-023 CA-04) ---"

REPO92="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT92_RUTAS='hooks tools'
MAT92_REG=''; MAT92_T0=0; MAT92_REF='-'; MAT92_ETIQ='-'
mat92_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT92_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT92_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT92_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT92_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT92_ETIQ ref=$MAT92_REF archivos=$arch"
}
mat92() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT92_T0=${EPOCHREALTIME/./}
  MAT92_REF="${ref//[[:space:]]/_}"; MAT92_ETIQ="$MAT92_REF"; MAT92_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO. Con `-d`, las dos secciones 37
  # se abstenían enteras dentro de un worktree —la copia haciendo la mitad del trabajo, el
  # caso que CA-05 cierra— mientras `git` resolvía el tag sin problema. Medido al montar los
  # dos árboles de CA-08; el motivo largo está en `37/1`, donde vive la copia gemela.
  [ -e "$REPO92/.git" ] || { mat92_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO92" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat92_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO92" ls-tree -r "$ref" -- $MAT92_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat92_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat92_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat92_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO92" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat92_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat92_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO92" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat92_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat92_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat92_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat92_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat92_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat92_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat92_reg ok - "$n" "$procs"
  return 0
}
HER92="$RAIZ/her92-$BASHPID"; HER92_OK=no; REGHER92=''
mat92 v1.33.0 "$HER92" && HER92_OK=si


# ---------- CA-04 · Y NO SE ESTRECHA NINGUNA TOLERANCIA ----------
# Las dos versiones juzgan el MISMO corpus en la MISMA corrida, y tiene que salir lo mismo
# CAMPO A CAMPO y DECISIÓN A DECISIÓN. El corpus se descubre por GLOB en el directorio de
# secciones del corredor —sitio único de ese corpus— más las cabeceras de los REQ del árbol.
EVA93="$RAIZ/eva93-$BASHPID.sh"
cat > "$EVA93" <<'EVA'
#!/usr/bin/env bash
# <lib> — lo que el lector resuelve por línea; con `-doc`, la DECISIÓN entera sobre un
# documento. Un proceso por árbol: los dos definen las MISMAS funciones y se pisarían.
set -uo pipefail
. "$1" >/dev/null 2>&1 || exit 3
# LA GUARDA SE IMPRIME, Y CON LA VARIABLE QUE LE TOCA A CADA MITAD (QA-023-08) ------------
# Este evaluador no miraba la guarda en ninguna de sus dos mitades, y la guarda es lo UNICO
# por lo que esta version puede decidir distinto de la heredada. Consecuencia medida: la mitad
# por linea NO PODIA FALLAR —comparaba clave, valor y decorada, que es la propiedad de CA-06
# (la guarda es OBSERVACIONAL, no cambia ningun valor de campo)— y publicaba ese verde con el
# nombre de CA-04, que es el unico criterio que vigila la SOBRE-DENEGACION. Un caso que pasa
# en las dos versiones no mide nada.
#
# Y LA VARIABLE NO ES LA MISMA EN LAS DOS MITADES, tambien medido: `ARNES_OCULTA` es ESTADO
# ACUMULADO DEL LLAMADOR —se pone a 0 al empezar una cabecera y se consulta al acabarla—, asi
# que en un barrido linea a linea es PEGAJOSA y diverge en todas las lineas posteriores a la
# primera que dispare: 25 309 divergencias sobre 25 309 lineas, que es ruido. Por linea la
# variable es `ARNES_CLAVE_OCULTA`, que `arnes_norm_clave` reinicia en cada llamada. Por
# documento es `ARNES_OCULTA`, que es donde la puerta la consulta, y se imprime DOS VECES
# —tras `arnes_campos_req` y tras `arnes_estado_cabecera`— porque son dos recorridos y cada
# uno la reinicia: sin las dos, el recorrido del estado terminal se queda sin vigilar.
#
# `${...:-}` EN LAS DOS: la version heredada no define ninguna de estas variables, y sin
# normalizarlas a «no dispara» divergirian TODAS las lineas por la AUSENCIA de la variable en
# vez de por la guarda — el mismo verde por vacio con otro disfraz.
if [ "${2:-}" = -doc ]; then
  t=''; IFS= read -r -d '' t < "$3" || true
  arnes_campos_req "$t" ''
  printf 'qa=%s|seg=%s|sens=%s|hall=%s|rigor=%s|cita=%s|cr=%s|dudosa=%s\n' \
    "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR" \
    "$ARNES_CITA_ABIERTA" "$ARNES_CR_INTERIOR" "${ARNES_SENS_DUDOSA:-}"
  printf 'oculta=%s|oclave=%s|orepr=%s|oestado=%s\n' \
    "${ARNES_OCULTA:-0}" "${ARNES_OCULTA_CLAVE:-}" "${ARNES_OCULTA_REPR:-}" "${ARNES_OCULTA_ESTADO:-}"
  arnes_estado_cabecera "$t"
  printf 'estado=%s|citado=%s|cita=%s|cr=%s\n' "$ARNES_ESTADO" "$ARNES_ESTADO_CITADO" "$ARNES_ESTADO_CITA" "$ARNES_ESTADO_CR"
  printf 'oculta-estado=%s|oclave=%s|orepr=%s|oestado=%s\n' \
    "${ARNES_OCULTA:-0}" "${ARNES_OCULTA_CLAVE:-}" "${ARNES_OCULTA_REPR:-}" "${ARNES_OCULTA_ESTADO:-}"
  exit 0
fi
ARNES_CITA=0; ARNES_CR=0
nk=0; nv=0; nd=0; n=0; ng=0
while IFS= read -r l; do
  # Las cuatro primeras columnas son las OBSERVACIONALES (CA-06) y se comparan estrictas; la
  # quinta y la sexta son la guarda (CA-04) y se comparan contandolas y publicandolas, porque
  # ahi las dos versiones TIENEN que diferir en alguna linea o el caso no mide nada.
  if arnes_campo_linea "$l"; then
    printf 'CAMPO\t%s\t%s\t%s\t%s\t%s\n' "$ARNES_CLAVE" "$ARNES_VALOR" "$ARNES_CLAVE_DECORADA" \
      "${ARNES_CLAVE_OCULTA:-0}" "${ARNES_CLAVE_OCULTA_REPR:-}"
    n=$((n+1))
    case "$ARNES_CLAVE" in *[!$'\x20'-$'\x7e']*) nk=$((nk+1)) ;; esac
    case "$ARNES_VALOR" in *[!$'\x20'-$'\x7e']*) nv=$((nv+1)) ;; esac
    [ "$ARNES_CLAVE_DECORADA" = 1 ] && nd=$((nd+1))
  else
    printf 'NADA\t-\t-\t-\t%s\t%s\n' "${ARNES_CLAVE_OCULTA:-0}" "${ARNES_CLAVE_OCULTA_REPR:-}"
  fi
  [ "${ARNES_CLAVE_OCULTA:-0}" = 1 ] && ng=$((ng+1))
done
printf 'RESUMEN\t%s\t%s\t%s\t%s\t%s\n' "$n" "$nk" "$nv" "$nd" "$ng" >&2
EVA
chmod +x "$EVA93"
# El corpus: por GLOB en secciones/ (sitio único) MÁS los REQ del árbol (`$REPO92`, de arriba).
COR93="$RAIZ/cor93-$BASHPID.txt"
: > "$COR93"
cat "$SEC_DIR"/[0-9][0-9]-*.sh >> "$COR93" 2>/dev/null || :
cat "$REPO92"/requirements/*.md   >> "$COR93" 2>/dev/null || :

# LOS TRES SUELOS DE ANTI-VACUIDAD DE CA-04, MEDIDOS y no afirmados: sin una clave no ASCII, un
# valor no ASCII y una clave decorada, la equivalencia es cierta por vacío. Si faltara alguno,
# la vía conforme es APORTAR el fixture en esta sección —que el glob recoge—, nunca rebajar el
# suelo. Medido el 2026-09-09: 135 / 264 / 827 sólo con las secciones, así que no hizo falta.
#
# Y UN CUARTO SUELO, QUE NO ES UNO DE LOS TRES DE CA-04 SINO SU CONDICION DE MEDIBILIDAD
# (QA-023-08): el corpus tiene que contener AL MENOS UNA linea donde la guarda DISPARE. Sin
# ella las dos versiones coinciden en las seis columnas y el «0 divergencias» de la mitad (1)
# es cierto POR VACIO en el unico eje del que CA-04 habla. Es el mismo defecto que los tres
# suelos de arriba, un eje mas alla, y va aqui —en el caso de anti-vacuidad— porque es
# exactamente eso: la comprobacion de que hay algo que comparar. La version heredada no
# dispara NUNCA (no tiene guarda), asi que este recuento sobre ESTE arbol ES el numero de
# divergencias contra ella y no hace falta la linea base para medirlo.
RES93=''; N93=0; NK93=0; NV93=0; ND93=0; NG93=0
SAL93="$RAIZ/sal93-$BASHPID.txt"; ERR93="$RAIZ/err93-$BASHPID.txt"
bash "$EVA93" "$HOOKS_DIR/lib.sh" < "$COR93" > "$SAL93" 2>"$ERR93" || :
RES93="$(awk -F'\t' '$1 == "RESUMEN" { print $2, $3, $4, $5, $6 }' "$ERR93")"
read -r N93 NK93 NV93 ND93 NG93 <<< "${RES93:-0 0 0 0 0}"
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-04 anti-vacuidad" | grep -qi -- "$FILTRO"; then
  if [ "${N93:-0}" -ge 1 ] && [ "${NK93:-0}" -ge 1 ] && [ "${NV93:-0}" -ge 1 ] && [ "${ND93:-0}" -ge 1 ] && [ "${NG93:-0}" -ge 1 ]; then
    echo "  PASS  REQ-023 CA-04 anti-vacuidad: el corpus trae $N93 líneas con campo, $NK93 con clave no ASCII, $NV93 con valor no ASCII, $ND93 con clave decorada y $NG93 donde la guarda DISPARA (sin esta última la equivalencia no mediría la guarda)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-04 anti-vacuidad: el corpus no llega a los suelos (campo=$N93 clave-no-ascii=$NK93 valor-no-ascii=$NV93 decorada=$ND93 guarda-dispara=$NG93): la equivalencia sería cierta por vacío. Aporta el fixture que falte EN ESTA SECCIÓN; no se rebaja el suelo"; FAIL=$((FAIL+1))
  fi
fi

# (1) CAMPO A CAMPO, las dos versiones sobre el mismo corpus y en la misma corrida.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-04 campo a campo" | grep -qi -- "$FILTRO"; then
  if [ "$HER92_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-04 campo a campo: el corpus decide idéntico que la versión heredada  no hay línea base v1.33.0 ($REGHER92)"
  elif [ "${N93:-0}" -lt 1 ]; then
    echo "  SKIP  REQ-023 CA-04 campo a campo: el corpus decide idéntico que la versión heredada  el corpus cosechó 0 líneas con campo"
  else
    HSAL93="$RAIZ/hsal93-$BASHPID.txt"
    bash "$EVA93" "$HER92/hooks/lib.sh" < "$COR93" > "$HSAL93" 2>/dev/null || :
    # LAS COLUMNAS OBSERVACIONALES SE COMPARAN ESTRICTAS Y LA DE LA GUARDA SE PUBLICA, y no es
    # lo mismo (QA-023-08): exigir identidad en las SEIS haria el criterio insatisfacible —una
    # guarda que no cambia ninguna decision no existe—, y no imprimir la guarda deja el caso
    # sin poder fallar en su propio eje. Se separan: 1-4 estrictas (CA-06, observacional),
    # 5-6 contadas y publicadas (CA-04, sobre-denegacion), y el suelo de arriba exige >= 1.
    OBS93="$RAIZ/obs93-$BASHPID.txt"; HOBS93="$RAIZ/hobs93-$BASHPID.txt"
    cut -f1-4 "$SAL93"  > "$OBS93"
    cut -f1-4 "$HSAL93" > "$HOBS93"
    DIF93="$(cmp -s "$OBS93" "$HOBS93" && echo 0 || echo 1)"
    # Divergencias de la GUARDA, con su primera representacion imprimible para diagnosticarla.
    GUA93="$(awk -F'\t' 'NR==FNR { b[FNR] = ($5 == "" ? 0 : $5); next } (($5 == "" ? 0 : $5) + 0) != (b[FNR] + 0) { n++ } END { print n + 0 }' "$HSAL93" "$SAL93")"
    GUAR93="$(awk -F'\t' 'NR==FNR { b[FNR] = ($5 == "" ? 0 : $5); next } (($5 == "" ? 0 : $5) + 0) != (b[FNR] + 0) { print $6; exit }' "$HSAL93" "$SAL93")"
    if [ "$DIF93" = 0 ]; then
      echo "  PASS  REQ-023 CA-04 campo a campo: las dos versiones resuelven IGUAL las $N93 líneas con campo del corpus (clave, valor y decorada) — y la GUARDA difiere en ${GUA93:-0} de ellas, que es lo que hace comparable la mitad de CA-04 (la primera: «${GUAR93:-ninguna}»). Que NINGUNA caiga en un REQ del árbol lo mide el caso siguiente, no éste"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-04 campo a campo: la guarda cambió lo que el lector resuelve — $(diff "$HOBS93" "$OBS93" 2>/dev/null | grep -c '^[<>]') líneas de diferencia en clave/valor/decorada. La guarda tiene que ser OBSERVACIONAL"; FAIL=$((FAIL+1))
    fi
  fi
fi

# (2) DECISIÓN A DECISIÓN sobre cada REQ del árbol: los cinco campos, el estado y su cita, el
# rango abierto, el CR interior, la sensibilidad y el rigor efectivos. Es lo que caza un
# despacho «unificado de paso»: `Estado` toma la PRIMERA aparición y los demás la ÚLTIMA.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-04 decisión a decisión" | grep -qi -- "$FILTRO"; then
  if [ "$HER92_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-04 decisión a decisión sobre los REQ del árbol  no hay línea base v1.33.0 ($REGHER92)"
  else
    ndoc93=0; mal93=0; primero93=''
    for f93 in "$REPO92"/requirements/*.md; do
      [ -f "$f93" ] || continue
      case "${f93##*/}" in README.md) continue ;; esac
      ndoc93=$((ndoc93 + 1))
      x93="$(bash "$EVA93" "$HOOKS_DIR/lib.sh"      -doc "$f93" 2>/dev/null)"
      y93="$(bash "$EVA93" "$HER92/hooks/lib.sh" -doc "$f93" 2>/dev/null)"
      if [ "$x93" != "$y93" ]; then mal93=$((mal93 + 1)); [ -n "$primero93" ] || primero93="${f93##*/}"; fi
    done
    if [ "$ndoc93" -lt 1 ]; then
      echo "  SKIP  REQ-023 CA-04 decisión a decisión sobre los REQ del árbol  no se encontró ningún REQ que juzgar"
    elif [ "$mal93" -eq 0 ]; then
      echo "  PASS  REQ-023 CA-04 decisión a decisión: los $ndoc93 REQ del árbol deciden IGUAL en las dos versiones, y la GUARDA no dispara en ninguno (0 divergencias de ARNES_OCULTA en los dos recorridos de cabecera): ninguna SOBRE-DENEGACIÓN sobre un REQ real"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-04 decisión a decisión: $mal93 de $ndoc93 REQ deciden distinto (el primero, $primero93). Si la diferencia está en 'oculta=', la guarda SOBRE-DENIEGA una cabecera legítima del árbol y eso es exactamente lo que CA-04 prohíbe"; FAIL=$((FAIL+1))
    fi
  fi
fi

rm -rf "$HER92"
