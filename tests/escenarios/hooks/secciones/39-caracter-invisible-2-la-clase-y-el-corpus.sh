# Sección 39 (2 de 3) del banco — 39-caracter-invisible-2-la-clase-y-el-corpus
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-023 · SEC-047 (mitad 1). LA CLASE Y EL CORPUS: `CA-03` (la clase se cierra por
# CONSTRUCCIÓN, no por lista: tres familias declaradas MÁS una entrada RESERVADA sorteada en
# cada corrida, con su semilla publicada), `CA-04` (y no se estrecha NINGUNA tolerancia: el
# corpus decide campo a campo y decisión a decisión lo mismo que la versión heredada, medidas
# las dos en la misma corrida) y `CA-05` (el veredicto y el motivo son invariantes al locale).
#
# ESTE ARCHIVO ESTÁ ESCRITO PARA QUE UNA IMPLEMENTACIÓN POR LISTA DE PROHIBIDOS LO INCUMPLA, y
# eso es su razón de ser. Si los casos pasan con las familias declaradas y falla el de la
# entrada reservada, el hallazgo es CONTRA EL CÓDIGO y no contra el criterio: ensanchar la
# lista sería la SEXTA derrota medida de esa vía en este repositorio (`ADR-002`, SEC-020,
# SEC-024, SEC-025, H-01).
#
# PARTE 2 DE 3 POR REQ-014 CA-18. El materializador de la línea base viene DUPLICADO de la
# parte 3 y de las cinco partes de la 37 a propósito: cada sección corre en su propio subshell,
# ninguna hace `source` de otra, y en `secciones/` no cabe un archivo auxiliar. Su motivo largo
# y las cuatro propiedades de `REQ-021 CA-05` que porta están escritos UNA vez, en
# `37-coste-del-escaner-1-el-dominio.sh`, y no se transcriben aquí. Residual `AN-021-01`.
CASOS_ESPERADOS_SECCION=10
PISO_AUTONOMO_SECCION=178  # 24 preámbulo (líneas 1-24) + 77 maquinaria compartida duplicada (mat93 y la línea base, líneas 26-102) + 77 bloque indivisible mayor (CA-04 entero: los dos evaluadores diferenciales, la cosecha del corpus, sus tres suelos de anti-vacuidad y las dos comparaciones, líneas 178-254) · REQ-014 CA-18
seccion_nueva "--- 39/2 · el carácter invisible: la clase y el corpus (REQ-023 CA-03, CA-04 y CA-05) ---"

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

# ---------- CA-03 · LA CLASE SE CIERRA POR CONSTRUCCIÓN, NO POR LISTA ----------
# El DOMINIO declarado son tres familias; la entrada RESERVADA se sortea en cada corrida del
# COMPLEMENTO de esas familias —universo: cualquier punto de código, sin restricción previa—.
# Y ése es el punto: si el universo fuera «la clase de CA-01», el sorteo necesitaría un ORÁCULO
# de la clase, y si el oráculo fuese la misma tabla que usa la guarda, el caso pasaría POR
# CONSTRUCCIÓN. Es la forma (d) que REQ-021 cazó en la ventana 1.33.0.
#
# EL PROCEDIMIENTO de inyección lo fija el criterio y no el implementador: la entrada se
# INSERTA en una línea que declara un campo RECONOCIDO por el lector, dejando la clave por lo
# demás intacta.
SEM93="${ARNES_SEM_39:-$(( (RANDOM << 15) ^ RANDOM ^ ${BASHPID} ))}"
RANDOM=$(( SEM93 % 32768 ))
# (i) bytes de control C0 distintos de tabulador, LF y CR, presentes en el disco;
# (ii) puntos de código de anchura cero o de formato;
# (iii) secuencias UTF-8 mal formadas: arranque sin continuación, continuación huérfana,
#       sobrelarga y sustituto codificado.
FAM93_1=($'\x01' $'\x07' $'\x0b' $'\x0c' $'\x1b' $'\x1f')
FAM93_2=($'\xef\xbb\xbf' $'\xe2\x80\x8b' $'\xe2\x80\x8c' $'\xe2\x80\x8d' $'\xe2\x80\x8e' $'\xe2\x80\x8f' $'\xe2\x81\xa0' $'\xc2\xad')
FAM93_3=($'\xc3' $'\xe2\x80' $'\xa0' $'\xbf' $'\xc0\xaf' $'\xe0\x80\xaf' $'\xed\xa0\x80' $'\xf5\x80\x80\x80')
# LA RESERVADA: un punto de código sorteado del complemento. Se sortea entre los imprimibles
# de tres planos —griego/cirílico, CJK, emoji, más selectores y separadores— y se DESCARTA
# cualquiera que caiga en las familias declaradas, para que sea de verdad del complemento.
RES93_POOL=('Ω' 'Ж' '漢' '😀' $'\xef\xb8\x8f' $'\xf3\xa0\x81\xa1' $'\xe2\x80\xa8' $'\xe2\x80\xa9' '☃' '𝔄' 'ᅟ' '·')
res93=''
for _i93 in 1 2 3 4 5 6 7 8; do
  cand93="${RES93_POOL[$(( RANDOM % ${#RES93_POOL[@]} ))]}"
  hay93=no
  for x93 in "${FAM93_1[@]}" "${FAM93_2[@]}" "${FAM93_3[@]}"; do [ "$x93" = "$cand93" ] && hay93=si; done
  [ "$hay93" = no ] && { res93="$cand93"; break; }
done
mk93() { printf '%s\n' "$2" > "$PROJ/requirements/$1.md"; }
# La base: todo en verde y sin ningún carácter de la clase, así que CIERRA. Sobre ella se
# INSERTA la entrada dentro de una clave reconocida. Si la base no cerrara, «todas denegaron»
# sería cierto por vacío y este caso no mediría nada.
base93() { printf '# REQ-990\nEstado: completado\n%sSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nRigor: critico\n' "$1"; }
dec93() {   # <inserción> -> `deny` | `allow`
  local out
  out="$(corre guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-990.md" "$(base93 "$1")")")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi
}
mk93 REQ-990 '# REQ-990
Estado: en-revisión'
# ANTI-VACUIDAD (1 de 2): la línea base heredada tiene que PERMITIR. Si denegara, «todas
# denegaron» sería cierto sin que la guarda hubiera hecho nada.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-03 anti-vacuidad" | grep -qi -- "$FILTRO"; then
  if [ "$(dec93 '')" = allow ]; then
    echo "  PASS  REQ-023 CA-03 anti-vacuidad: la base sin ningún carácter de la clase PERMITE, así que hay algo que denegar"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 anti-vacuidad: la base ya deniega sin carácter ninguno: «todas denegaron» sería cierto por vacío"; FAIL=$((FAIL+1))
  fi
fi
# ANTI-VACUIDAD (2 de 2): ninguna familia puede quedarse sin entradas.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-03 las tres familias" | grep -qi -- "$FILTRO"; then
  if [ "${#FAM93_1[@]}" -ge 1 ] && [ "${#FAM93_2[@]}" -ge 1 ] && [ "${#FAM93_3[@]}" -ge 1 ] && [ -n "$res93" ]; then
    echo "  PASS  REQ-023 CA-03 las tres familias aportan entradas (${#FAM93_1[@]} + ${#FAM93_2[@]} + ${#FAM93_3[@]}) y la reservada se sorteó"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 una familia quedó vacía (${#FAM93_1[@]}/${#FAM93_2[@]}/${#FAM93_3[@]}) o la reservada salió vacía: el dominio no mediría nada"; FAIL=$((FAIL+1))
  fi
fi
# Y AHORA LA PROPIEDAD, familia por familia: TODAS deniegan.
fam93() {   # <nombre> <entradas...>
  local nombre="$1"; shift
  local mal='' n=0 e
  if [ -n "$FILTRO" ] && ! printf '%s' "REQ-023 CA-03 $nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  for e in "$@"; do
    n=$((n + 1))
    [ "$(dec93 "$e")" = deny ] || mal="$mal <$(printf '%s' "$e" | od -An -tx1 | tr -d ' \n')>"
  done
  if [ "$n" -ge 1 ] && [ -z "$mal" ]; then
    echo "  PASS  REQ-023 CA-03 $nombre: las $n entradas insertadas en una clave reconocida DENIEGAN"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 $nombre: permitieron (bytes en hex):$mal"; FAIL=$((FAIL+1))
  fi
}
fam93 "familia (i) bytes de control C0"        "${FAM93_1[@]}"
fam93 "familia (ii) anchura cero y formato"    "${FAM93_2[@]}"
fam93 "familia (iii) UTF-8 mal formado"        "${FAM93_3[@]}"
# LA RESERVADA, con su semilla publicada para que un fallo se reproduzca. Este caso es el que
# una implementación por LISTA DE PROHIBIDOS incumple.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-03 la entrada RESERVADA" | grep -qi -- "$FILTRO"; then
  if [ "$(dec93 "$res93")" = deny ]; then
    echo "  PASS  REQ-023 CA-03 la entrada RESERVADA del complemento (semilla $SEM93, bytes $(printf '%s' "$res93" | od -An -tx1 | tr -d ' \n')) DENIEGA"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 la entrada RESERVADA permitió (semilla $SEM93, bytes $(printf '%s' "$res93" | od -An -tx1 | tr -d ' \n')): la guarda está hecha por LISTA y la clase no está cerrada"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-05 · EL VEREDICTO Y EL MOTIVO SON INVARIANTES AL LOCALE ----------
# Motivo, y está medido dos veces en este arnés: una clasificación que dependa de `LC_CTYPE`
# DENIEGA en el CI de Linux y PERMITE en Windows/MSYS —que es donde viven los proyectos
# consumidores y de donde sale el BOM—: sería un fallo en abierto POR ENTORNO, invisible en la
# puerta requerida de `main`. Se comparan la salida ENTERA de las dos, en la misma corrida.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-05" | grep -qi -- "$FILTRO"; then
  JSON93="$(emite_write "$PROJ/requirements/REQ-990.md" "$(base93 $'\xef\xbb\xbf')")"
  u93="$(LC_ALL=C.UTF-8 corre guard-completado.sh "$JSON93")"
  c93="$(LC_ALL=C       corre guard-completado.sh "$JSON93")"
  if [ -n "$u93" ] && [ "$u93" = "$c93" ]; then
    echo "  PASS  REQ-023 CA-05 el veredicto y el motivo son IDÉNTICOS bajo el locale del entorno y bajo LC_ALL=C"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-05 la salida difiere por locale (C.UTF-8 vacía=$([ -z "$u93" ] && echo si || echo no)): un fail-open POR ENTORNO"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-04 · Y NO SE ESTRECHA NINGUNA TOLERANCIA ----------
# Las dos versiones juzgan el MISMO corpus en la MISMA corrida, y tiene que salir lo mismo
# CAMPO A CAMPO y DECISIÓN A DECISIÓN. El corpus se descubre por GLOB en el directorio de
# secciones del corredor —sitio único de ese corpus— más las cabeceras de los REQ del árbol.
EVA93="$RAIZ/eva93-$BASHPID.sh"
cat > "$EVA93" <<'EVA'
#!/usr/bin/env bash
# <lib> — por cada línea de la entrada, lo que el lector resuelve. Y con `-doc`, la DECISIÓN
# entera sobre un documento. Se invoca una vez por árbol: cada uno define las MISMAS
# funciones, así que en un solo proceso se mediría el último que se cargó.
set -uo pipefail
. "$1" >/dev/null 2>&1 || exit 3
if [ "${2:-}" = -doc ]; then
  t=''; IFS= read -r -d '' t < "$3" || true
  arnes_campos_req "$t" ''
  printf 'qa=%s|seg=%s|sens=%s|hall=%s|rigor=%s|cita=%s|cr=%s|dudosa=%s\n' \
    "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR" \
    "$ARNES_CITA_ABIERTA" "$ARNES_CR_INTERIOR" "${ARNES_SENS_DUDOSA:-}"
  arnes_estado_cabecera "$t"
  printf 'estado=%s|citado=%s|cita=%s|cr=%s\n' "$ARNES_ESTADO" "$ARNES_ESTADO_CITADO" "$ARNES_ESTADO_CITA" "$ARNES_ESTADO_CR"
  exit 0
fi
ARNES_CITA=0; ARNES_CR=0
nk=0; nv=0; nd=0; n=0
while IFS= read -r l; do
  if arnes_campo_linea "$l"; then
    printf 'CAMPO\t%s\t%s\t%s\n' "$ARNES_CLAVE" "$ARNES_VALOR" "$ARNES_CLAVE_DECORADA"
    n=$((n+1))
    case "$ARNES_CLAVE" in *[!$'\x20'-$'\x7e']*) nk=$((nk+1)) ;; esac
    case "$ARNES_VALOR" in *[!$'\x20'-$'\x7e']*) nv=$((nv+1)) ;; esac
    [ "$ARNES_CLAVE_DECORADA" = 1 ] && nd=$((nd+1))
  else
    printf 'NADA\t-\t-\t-\n'
  fi
done
printf 'RESUMEN\t%s\t%s\t%s\t%s\n' "$n" "$nk" "$nv" "$nd" >&2
EVA
chmod +x "$EVA93"
# El corpus: por GLOB en el directorio de secciones del corredor (sitio único) MÁS los REQ del
# árbol. `$REPO92` es la raíz del repositorio y ya la fija el materializador de arriba.
COR93="$RAIZ/cor93-$BASHPID.txt"
: > "$COR93"
cat "$SEC_DIR"/[0-9][0-9]-*.sh >> "$COR93" 2>/dev/null || :
cat "$REPO92"/requirements/*.md   >> "$COR93" 2>/dev/null || :

# LOS TRES SUELOS DE ANTI-VACUIDAD DE CA-04, medidos sobre el corpus que se acaba de cosechar y
# NO afirmados: sin una clave no ASCII, un valor no ASCII y una clave decorada, la equivalencia
# es cierta por vacío y no acredita nada. Si faltara alguno, la vía conforme que el contrato
# deja escrita es APORTAR el fixture en esta sección —que el glob recoge—, nunca rebajar el
# suelo. Medido el 2026-09-09: 135 / 264 / 827 sólo con las secciones, así que no hizo falta.
RES93=''; N93=0; NK93=0; NV93=0; ND93=0
SAL93="$RAIZ/sal93-$BASHPID.txt"; ERR93="$RAIZ/err93-$BASHPID.txt"
bash "$EVA93" "$HOOKS_DIR/lib.sh" < "$COR93" > "$SAL93" 2>"$ERR93" || :
RES93="$(awk -F'\t' '$1 == "RESUMEN" { print $2, $3, $4, $5 }' "$ERR93")"
read -r N93 NK93 NV93 ND93 <<< "${RES93:-0 0 0 0}"
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-04 anti-vacuidad" | grep -qi -- "$FILTRO"; then
  if [ "${N93:-0}" -ge 1 ] && [ "${NK93:-0}" -ge 1 ] && [ "${NV93:-0}" -ge 1 ] && [ "${ND93:-0}" -ge 1 ]; then
    echo "  PASS  REQ-023 CA-04 anti-vacuidad: el corpus trae $N93 líneas con campo, $NK93 con clave no ASCII, $NV93 con valor no ASCII y $ND93 con clave decorada"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-04 anti-vacuidad: el corpus no llega a los tres suelos (campo=$N93 clave-no-ascii=$NK93 valor-no-ascii=$NV93 decorada=$ND93): la equivalencia sería cierta por vacío. Aporta el fixture que falte EN ESTA SECCIÓN; no se rebaja el suelo"; FAIL=$((FAIL+1))
  fi
fi

# (1) CAMPO A CAMPO, las dos versiones sobre el mismo corpus y en la misma corrida.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-04 campo a campo" | grep -qi -- "$FILTRO"; then
  if [ "$HER92_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-04 campo a campo: el corpus decide idéntico que la versión heredada  no hay línea base v1.33.0 ($REGHER92)"; SKIP=$((SKIP+1))
  elif [ "${N93:-0}" -lt 1 ]; then
    echo "  SKIP  REQ-023 CA-04 campo a campo: el corpus decide idéntico que la versión heredada  el corpus cosechó 0 líneas con campo"; SKIP=$((SKIP+1))
  else
    HSAL93="$RAIZ/hsal93-$BASHPID.txt"
    bash "$EVA93" "$HER92/hooks/lib.sh" < "$COR93" > "$HSAL93" 2>/dev/null || :
    DIF93="$(cmp -s "$SAL93" "$HSAL93" && echo 0 || echo 1)"
    if [ "$DIF93" = 0 ]; then
      echo "  PASS  REQ-023 CA-04 campo a campo: las dos versiones resuelven IGUAL las $N93 líneas con campo del corpus (clave, valor y decorada)"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-04 campo a campo: la guarda cambió lo que el lector resuelve — $(diff "$HSAL93" "$SAL93" 2>/dev/null | grep -c '^[<>]') líneas de diferencia. La guarda tiene que ser OBSERVACIONAL"; FAIL=$((FAIL+1))
    fi
  fi
fi

# (2) DECISIÓN A DECISIÓN, sobre cada REQ del árbol: los cinco campos, el estado, el estado
# citado, el rango abierto, el CR interior, la sensibilidad efectiva y el rigor efectivo.
# Es lo que caza un despacho «unificado de paso» que iguale la precedencia: `Estado` toma la
# PRIMERA aparición y los demás la ÚLTIMA, y esa asimetría no se toca.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-04 decisión a decisión" | grep -qi -- "$FILTRO"; then
  if [ "$HER92_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-04 decisión a decisión sobre los REQ del árbol  no hay línea base v1.33.0 ($REGHER92)"; SKIP=$((SKIP+1))
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
      echo "  SKIP  REQ-023 CA-04 decisión a decisión sobre los REQ del árbol  no se encontró ningún REQ que juzgar"; SKIP=$((SKIP+1))
    elif [ "$mal93" -eq 0 ]; then
      echo "  PASS  REQ-023 CA-04 decisión a decisión: los $ndoc93 REQ del árbol deciden IGUAL en las dos versiones"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-04 decisión a decisión: $mal93 de $ndoc93 REQ deciden distinto (el primero, $primero93)"; FAIL=$((FAIL+1))
    fi
  fi
fi

rm -rf "$HER92"
