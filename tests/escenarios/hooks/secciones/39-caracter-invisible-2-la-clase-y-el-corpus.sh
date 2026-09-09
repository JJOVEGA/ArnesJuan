# Sección 39 (2 de 4) del banco — 39-caracter-invisible-2-la-clase-y-el-corpus
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-023 · SEC-047 (mitad 1). LA CLASE Y EL CORPUS: `CA-03` (la clase se cierra por
# CONSTRUCCIÓN, no por lista: tres familias declaradas MÁS un SORTEO ESTRATIFICADO en dos
# estratos derivados de la constante de claves, tres procedimientos, veredicto POR RAMA y las
# tiradas de cada rama publicadas junto a la semilla) y `CA-04` (no se estrecha NINGUNA
# tolerancia: el corpus decide campo a campo y decisión a decisión lo mismo que la heredada,
# medidas las dos en la misma corrida). `CA-05` se mudó a la parte 1 en 1.34.0.
#
# ESTE ARCHIVO ESTÁ ESCRITO PARA QUE UNA IMPLEMENTACIÓN POR LISTA DE PROHIBIDOS LO INCUMPLA
# —ensanchar la lista sería la SEXTA derrota medida de esa vía aquí (`ADR-002`, SEC-020,
# SEC-024, SEC-025, H-01)— Y PARA QUE UN SORTEO QUE NO PUEDE FALLAR LO INCUMPLA TAMBIÉN: el
# pool tecleado que tuvo hasta 1.34.0 daba verde por construcción (`QA-023-02`).
#
# PARTE 2 DE 4 POR REQ-014 CA-18. El materializador de la línea base viene DUPLICADO de la
# parte 3 y de las cinco partes de la 37 a propósito: cada sección corre en su propio subshell,
# ninguna hace `source` de otra, y en `secciones/` no cabe un archivo auxiliar. Su motivo largo
# y las cuatro propiedades de `REQ-021 CA-05` que porta están escritos UNA vez, en
# `37-coste-del-escaner-1-el-dominio.sh`, y no se transcriben aquí. Residual `AN-021-01`.
CASOS_ESPERADOS_SECCION=10
PISO_AUTONOMO_SECCION=294  # 25 preámbulo (líneas 1-25) + 76 maquinaria compartida duplicada (mat93 y la línea base, líneas 27-102) + 193 bloque indivisible mayor (CA-03 entero: la derivación de los dos estratos y de las claves desde la constante, el sorteo del universo, los tres procedimientos, las tres cabeceras, las familias y las tiradas con su veredicto por rama, líneas 103-295) · REQ-014 CA-18
seccion_nueva "--- 39/2 · el carácter invisible: la clase y el corpus (REQ-023 CA-03 y CA-04) ---"

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
# El DOMINIO declarado son tres familias; encima va un SORTEO ESTRATIFICADO sobre el universo
# —cualquier punto de código, sin restricción previa—. Con el universo puesto en «la clase de
# CA-01» el sorteo necesitaría un ORÁCULO, y con el de la propia guarda el caso pasaría POR
# CONSTRUCCIÓN: la forma (d) que REQ-021 cazó en 1.33.0.
SEM93="${ARNES_SEM_39:-$(( (RANDOM << 15) ^ RANDOM ^ ${BASHPID} ))}"
RANDOM=$(( SEM93 % 32768 ))
# (i) control C0 salvo tabulador/LF/CR; (ii) anchura cero y formato; (iii) UTF-8 mal formado:
# arranque sin continuación, continuación huérfana, sobrelarga y sustituto codificado.
FAM93_1=($'\x01' $'\x07' $'\x0b' $'\x0c' $'\x1b' $'\x1f')
FAM93_2=($'\xef\xbb\xbf' $'\xe2\x80\x8b' $'\xe2\x80\x8c' $'\xe2\x80\x8d' $'\xe2\x80\x8e' $'\xe2\x80\x8f' $'\xe2\x81\xa0' $'\xc2\xad')
FAM93_3=($'\xc3' $'\xe2\x80' $'\xa0' $'\xbf' $'\xc0\xaf' $'\xe0\x80\xaf' $'\xed\xa0\x80' $'\xf5\x80\x80\x80')
# EL SORTEO SUSTITUYE A UN POOL ESCRITO A MANO que era tautología: `QA-023-02` midió que sus
# doce entradas estaban todas FUERA del alfabeto, así que las ocho tiradas denegaban POR
# CONSTRUCCIÓN — y que con `U+0020` dentro el caso habría fallado. LOS DOS ESTRATOS SALEN DE LA
# CONSTANTE ÚNICA DE CLAVES (CA-06): (E1) el COMPLEMENTO del alfabeto, (E2) el alfabeto MISMO;
# derivados AQUÍ de `ARNES_CLAVES` y no de `ARNES_CLAVES_ALFA`, porque reusar la derivación de
# la guarda heredaría su error y seguiría verde.
CONST93="$(bash -c '. "$1" >/dev/null 2>&1 || exit 3
  printf "%s\n%s\n%s\n%s\n" "${ARNES_CLAVES:-}" "${ARNES_CLAVE_SENS:-}" "${ARNES_CLAVE_HALL:-}" "${ARNES_CLAVE_ESTADO:-}"' \
  _ "$HOOKS_DIR/lib.sh" 2>/dev/null)"
{ IFS= read -r CLAVES93; IFS= read -r SENS93; IFS= read -r HALL93; IFS= read -r EST93; } <<< "$CONST93"
ALFA93=''; LISTA93=(); MULTI93=(); BLANCO93=''
_r93="${CLAVES93//|/}"
while [ -n "$_r93" ]; do
  _c93="${_r93:0:1}"; _r93="${_r93:1}"
  case "$ALFA93" in *"$_c93"*) ;; *) ALFA93="$ALFA93$_c93" ;; esac
done
_r93="$CLAVES93"
while [ -n "$_r93" ]; do
  _k93="${_r93%%|*}"
  [ -n "$_k93" ] && LISTA93+=("$_k93")
  case "$_k93" in *[[:blank:]]*)
    MULTI93+=("$_k93")
    _p93="${_k93%%[[:blank:]]*}"; BLANCO93="${_k93:${#_p93}:1}" ;;
  esac
  case "$_r93" in *'|'*) _r93="${_r93#*|}" ;; *) break ;; esac
done
# UNA ENTRADA DE E1: punto de código sorteado del UNIVERSO y aceptado sólo si NO está en el
# alfabeto. Fuera quedan sólo los que no son «algo insertado en una línea»: LF y CR la TERMINAN
# (el CR tiene su guarda, REQ-016 CA-12) y los sustitutos no son escalares —su forma CODIFICADA
# ya es la familia (iii)—. Es la exclusión que el propio criterio hace en la familia (i). Y el
# escape va en DOS pasos: `printf '\U%08x'` resuelve los del FORMATO ANTES de sustituir `%08x` y
# devuelve la cadena literal `\U000b388f` — medido, y este caso lo cazó en su primera corrida.
sortea_e1_93() {   # -> ENT93 ; 1 si ocho intentos no dieron ninguna
  local n i h
  for i in 1 2 3 4 5 6 7 8; do
    n=$(( ((RANDOM << 15 | RANDOM) % 1114111) + 1 ))
    case "$n" in 10|13) continue ;; esac
    { [ "$n" -ge 55296 ] && [ "$n" -le 57343 ]; } && continue
    printf -v h '%08x' "$n"; printf -v ENT93 "\\U$h" 2>/dev/null || continue
    case "${ENT93:-}" in ''|'\'*|[$ALFA93]) continue ;; esac
    return 0
  done
  ENT93=''; return 1
}
# LOS TRES PROCEDIMIENTOS que fija el criterio. (P1) INSERTAR en posición ESTRICTAMENTE INTERNA
# —al borde, un blanco es SANGRÍA, tolerancia existente (REQ-016 CA-04) que CA-04 prohíbe
# estrechar—; (P2) SUSTITUIR el blanco interno de una clave multi-palabra; (P3) DUPLICARLO, con
# la entrada tomada de la clave misma. P2 con el blanco como entrada sería la identidad, no un
# procedimiento: no se sortea, y por eso el blanco de E2 va por P1 o por P3.
inyecta93() {   # <clave> <P1|P2|P3> <entrada> -> CORR93 ; 1 si el procedimiento no aplica
  local k="$1" p="$2" e="$3" pre suf pos; CORR93=''
  case "$p" in
    P1) [ "${#k}" -ge 3 ] || return 1
        pos=$(( (RANDOM % (${#k} - 1)) + 1 )); CORR93="${k:0:pos}$e${k:pos}" ;;
    P2|P3) case "$k" in *[[:blank:]]*) ;; *) return 1 ;; esac
        pre="${k%%[[:blank:]]*}"; suf="${k#*[[:blank:]]}"
        [ "$p" = P2 ] && CORR93="$pre$e$suf" || CORR93="$pre$BLANCO93$BLANCO93$suf" ;;
  esac
  [ -n "$CORR93" ]
}
mk93() { printf '%s\n' "$2" > "$PROJ/requirements/$1.md"; }
# La base de las FAMILIAS: todo en verde y sin ningún carácter de la clase, así que CIERRA;
# encima se INSERTA la entrada. Si no cerrara, «todas denegaron» sería cierto por vacío.
base93() { printf '# REQ-990\nEstado: completado\n%sSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nRigor: critico\n' "$1"; }
# LAS TRES CABECERAS DEL SORTEO, una por clave corrompible: hechas para que la AUSENCIA de esa
# clave ABRA la puerta —las dos filas de SEC-047 y la del estado terminal—. Que abran no se
# afirma aquí: se MIDE por tirada contra la heredada, abajo.
docs93() {   # <clave original> <clave corrompida> -> documento, o 1 si esa clave no tiene fixture
  local k="$1" c="$2"
  case "$k" in
    "$SENS93") printf '# REQ-990\nEstado: completado\n%s: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: ligero\n' "$c" ;;
    "$HALL93") printf '# REQ-990\nEstado: completado\n%s: SEC-9 (contrato)\nSensible a seguridad: no\nQA: aprobado\nRigor: estandar\n' "$c" ;;
    "$EST93")  printf '# REQ-990\n%s: completado\nSensible a seguridad: no\nQA: pendiente\nRigor: ligero\n' "$c" ;;
    *) return 1 ;;
  esac
}
dech93() {   # <directorio de hooks> <documento> -> `deny` | `allow`
  local out; out="$(printf '%s' "$(emite_write "$PROJ/requirements/REQ-990.md" "$2")" | "$1/guard-completado.sh" 2>/dev/null)"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi
}
dec93() { dech93 "$HOOKS_DIR" "$(base93 "$1")"; }   # <inserción en la base> -> deny | allow
mk93 REQ-990 '# REQ-990
Estado: en-revisión'
# ANTI-VACUIDAD (1 de 2): la base sin corromper tiene que PERMITIR, o no habría nada que denegar.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-03 anti-vacuidad" | grep -qi -- "$FILTRO"; then
  if [ "$(dec93 '')" = allow ]; then
    echo "  PASS  REQ-023 CA-03 anti-vacuidad: la base sin ningún carácter de la clase PERMITE, así que hay algo que denegar"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 anti-vacuidad: la base ya deniega sin carácter ninguno: «todas denegaron» sería cierto por vacío"; FAIL=$((FAIL+1))
  fi
fi
# ANTI-VACUIDAD (2 de 2): ninguna familia sin entradas; los estratos salidos de la constante
# —sin `ARNES_CLAVES` el sorteo no tendría universo—; y toda clave multi-palabra del lector con
# su cabecera aquí, para que una clave nueva se NOMBRE en vez de saltarse en silencio.
sinfix93=''
for k93 in ${MULTI93[@]+"${MULTI93[@]}"}; do docs93 "$k93" "$k93" >/dev/null || sinfix93="$sinfix93 «$k93»"; done
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-03 las tres familias" | grep -qi -- "$FILTRO"; then
  if [ "${#FAM93_1[@]}" -ge 1 ] && [ "${#FAM93_2[@]}" -ge 1 ] && [ "${#FAM93_3[@]}" -ge 1 ] \
     && [ "${#LISTA93[@]}" -ge 2 ] && [ "${#MULTI93[@]}" -ge 1 ] && [ -n "$BLANCO93" ] && [ -z "$sinfix93" ]; then
    echo "  PASS  REQ-023 CA-03 las tres familias aportan entradas (${#FAM93_1[@]} + ${#FAM93_2[@]} + ${#FAM93_3[@]}), los dos estratos se derivan de las ${#LISTA93[@]} claves (alfabeto de ${#ALFA93}) y las ${#MULTI93[@]} multi-palabra traen cabecera"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 una familia quedó vacía (${#FAM93_1[@]}/${#FAM93_2[@]}/${#FAM93_3[@]}), los estratos no se derivaron de la constante (claves=${#LISTA93[@]} alfabeto=${#ALFA93}) o hay multi-palabra sin cabecera:$sinfix93 — el dominio no mediría nada"; FAIL=$((FAIL+1))
  fi
fi
fam93() {   # <nombre> <entradas...> — la propiedad familia por familia: TODAS deniegan
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
# LAS TIRADAS. Cada una toma un estrato y un procedimiento, corrompe una clave y mide DOS veces:
# la heredada y esta versión. Sólo CUENTA en su rama si la heredada ABRIÓ — si ya denegaba, ese
# deny no lo produjo la guarda, y contarlo es la tautología que `QA-023-02` cazó. Las cuatro
# primeras están ESTRATIFICADAS (E1×P1, E1×P2, el blanco de E2 por P1, y P3, sin sorteo); las
# cuatro últimas son libres, y son las que traen lo que nadie ha pensado.
R1_93=0; R2_93=0; R3_93=0; MAL1_93=''; MAL2_93=''; PUB3_93=''; NOBASE_93=0
hex93() { printf '%s' "$1" | od -An -tx1 | tr -d ' \n'; }
tirada93() {   # <E1|E2|BLANCO|-> <P1|P2|P3>
  local est="$1" p="$2" k doc her act rama
  case "$est" in
    E1)     sortea_e1_93 || return 0 ;;
    E2)     ENT93="${ALFA93:$(( RANDOM % ${#ALFA93} )):1}" ;;
    BLANCO) ENT93="$BLANCO93" ;;
    *)      ENT93="$BLANCO93" ;;   # P3 no sortea: su entrada es el blanco de la clave misma
  esac
  # P2 y P3 exigen clave multi-palabra; P1 puede ir a cualquiera con fixture.
  case "$p" in
    P1) k="${LISTA93[$(( RANDOM % ${#LISTA93[@]} ))]}"; docs93 "$k" "$k" >/dev/null || k="$SENS93" ;;
    *)  k="${MULTI93[$(( RANDOM % ${#MULTI93[@]} ))]}" ;;
  esac
  # La entrada que ES el blanco no se sustituye a sí misma: P2 sería la identidad.
  [ "$p" = P2 ] && [ "$ENT93" = "$BLANCO93" ] && p=P1
  inyecta93 "$k" "$p" "$ENT93" || return 0
  doc="$(docs93 "$k" "$CORR93")" || return 0
  her=allow
  [ "$HER92_OK" = si ] && her="$(dech93 "$HER92/hooks" "$doc")"
  if [ "$HER92_OK" != si ] || [ "$her" != allow ]; then NOBASE_93=$((NOBASE_93 + 1)); return 0; fi
  act="$(dech93 "$HOOKS_DIR" "$doc")"
  # LA RAMA, según el criterio: (1) E1 por P1 o P2 -> DENY; (2) P3 y el blanco de E2 -> DENY;
  # (3) E2 que NO es blanco -> se publica y NO se juzga (fuera de la propiedad de CA-01).
  rama=1
  case "$ENT93" in [$ALFA93]) rama=3 ;; esac
  { [ "$p" = P3 ] || [ "$ENT93" = "$BLANCO93" ]; } && rama=2
  case "$rama" in
    1) R1_93=$((R1_93 + 1)); [ "$act" = deny ] || MAL1_93="$MAL1_93 <$p:$(hex93 "$ENT93")>" ;;
    2) R2_93=$((R2_93 + 1)); [ "$act" = deny ] || MAL2_93="$MAL2_93 <$p:$(hex93 "$ENT93")>" ;;
    3) R3_93=$((R3_93 + 1)); PUB3_93="$PUB3_93 <$p:$(hex93 "$ENT93")=$act>" ;;
  esac
}
tirada93 E1 P1; tirada93 E1 P2; tirada93 BLANCO P1; tirada93 '-' P3
_ES93=(E1 E2 BLANCO); _PR93=(P1 P2 P3)
for _t93 in 1 2 3 4; do tirada93 "${_ES93[$(( RANDOM % 3 ))]}" "${_PR93[$(( RANDOM % 3 ))]}"; done
# LAS TIRADAS POR RAMA SE PUBLICAN JUNTO A LA SEMILLA: nadie debe leer «todas denegaron» sobre
# tiradas que no exigían nada, y un fallo se reproduce con `ARNES_SEM_39`.
echo "        REQ-023 CA-03 sorteo estratificado · semilla $SEM93 (repetible con ARNES_SEM_39=$SEM93) ·" \
     "tiradas por rama: 1(E1→DENY)=$R1_93 · 2(blanco→DENY)=$R2_93 · 3(E2 no blanco, fuera de la propiedad de CA-01, se publica y no se juzga)=$R3_93$PUB3_93 · descartadas por no abrir en la heredada=$NOBASE_93"
# RAMA 1 y RAMA 2. Sin tiradas no hay PASS: SKIP con su motivo, nunca verde por vacío.
for _r93 in 1 2; do
  if [ "$_r93" = 1 ]; then n93="$R1_93"; m93="$MAL1_93"; d93="rama 1: entrada AJENA al alfabeto (E1) por P1 o P2 DENIEGA"
  else n93="$R2_93"; m93="$MAL2_93"; d93="rama 2: el BLANCO duplicado (P3) o insertado (E2) DENIEGA"; fi
  if [ -n "$FILTRO" ] && ! printf '%s' "REQ-023 CA-03 $d93" | grep -qi -- "$FILTRO"; then continue; fi
  if [ "$n93" -lt 1 ]; then
    echo "  SKIP  REQ-023 CA-03 $d93  esa rama se quedó sin ninguna tirada que abriera en la heredada (semilla $SEM93, descartadas $NOBASE_93$([ "$HER92_OK" = si ] || echo ", sin línea base v1.33.0: $REGHER92"))"; SKIP=$((SKIP+1))
  elif [ -z "$m93" ]; then
    echo "  PASS  REQ-023 CA-03 $d93 — las $n93 tiradas de la rama (semilla $SEM93)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-03 $d93 — PERMITIERON (semilla $SEM93, procedimiento:bytes):$m93. La clase no está cerrada: lo que pertenece al alfabeto, o lo que sustituye a un blanco, no se reconstruye"; FAIL=$((FAIL+1))
  fi
done

# CA-05 (veredicto y motivo invariantes al locale) VIVE EN LA PARTE 1 desde 1.34.0: el sorteo
# estratificado de CA-03 dejó esta sección en el techo de `REQ-014 CA-18`.
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
# El corpus: por GLOB en secciones/ (sitio único) MÁS los REQ del árbol (`$REPO92`, de arriba).
COR93="$RAIZ/cor93-$BASHPID.txt"
: > "$COR93"
cat "$SEC_DIR"/[0-9][0-9]-*.sh >> "$COR93" 2>/dev/null || :
cat "$REPO92"/requirements/*.md   >> "$COR93" 2>/dev/null || :

# LOS TRES SUELOS DE ANTI-VACUIDAD DE CA-04, MEDIDOS y no afirmados: sin una clave no ASCII, un
# valor no ASCII y una clave decorada, la equivalencia es cierta por vacío. Si faltara alguno,
# la vía conforme es APORTAR el fixture en esta sección —que el glob recoge—, nunca rebajar el
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

# (2) DECISIÓN A DECISIÓN sobre cada REQ del árbol: los cinco campos, el estado y su cita, el
# rango abierto, el CR interior, la sensibilidad y el rigor efectivos. Es lo que caza un
# despacho «unificado de paso»: `Estado` toma la PRIMERA aparición y los demás la ÚLTIMA.
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
