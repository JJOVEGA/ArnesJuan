# Sección 40 (1 de 2) del banco — 40-ausencia-que-abre-1-la-clase-derivada
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 · SEC-047 (mitad 2), SEC-050. LA CLASE DERIVADA: `CA-01` (la propiedad se enuncia por
# DIRECCIÓN y el dominio de campos se DERIVA midiendo, no se enumera) y `CA-02` (un solo sitio,
# con la dirección declarada EN él, y un campo nuevo que no la declare se NOMBRA). El radio de
# migración (`CA-05`), el puntero (`CA-03`) y el coste (`CA-07`) están en la parte 2.
#
# LO QUE ESTA SECCIÓN NO PUEDE ENUMERAR, y es la mitad del criterio: el DOMINIO de claves de
# cabecera no se escribe aquí. Se extrae de `ARNES_CLAVES` —el sitio único que REQ-023 CA-06
# creó y del que derivan también los dos despachos y la guarda de medibilidad—, así que un
# campo nuevo del lector entra en la medición sin tocar el banco. Una lista escrita aquí
# envejecería hacia el lado que ABRE, que es exactamente la falta de forma de `SEC-050`.
#
# LO QUE SÍ SE ESCRIBE AQUÍ, dicho para que nadie lo confunda con lo de arriba: el VALOR con el
# que cada campo se restringe y el valor con el que se permite. No es el dominio y no puede
# derivarse del código —«el valor que más restringe» de `Hallazgos abiertos:` es un hallazgo de
# clase `contrato`, que ningún vocabulario declara—. Y por eso el caso es FAIL-CLOSED: una clave
# del dominio para la que esta sección no tenga fixture **aborta con SKIP nombrándola**, nunca
# pasa por omisión.
#
# El materializador de la línea base (`mat24`) viene DUPLICADO de la parte 2 a propósito: cada
# sección corre en su propio subshell, ninguna hace `source` de otra, y en `secciones/` no cabe
# un archivo auxiliar. Su motivo largo y las cuatro propiedades de `REQ-021 CA-05` que porta
# están escritos UNA vez, en `37-coste-del-escaner-1-el-dominio.sh`, y no se transcriben aquí.
# Residual `AN-021-01`.
CASOS_ESPERADOS_SECCION=7
PISO_AUTONOMO_SECCION=200  # 31 preámbulo (líneas 1-31) + 74 maquinaria compartida duplicada (mat24 y la línea base, líneas 33-106) + 95 bloque indivisible mayor (el dominio extraído, los fixtures y el evaluador de veredicto, líneas 107-201: ningún caso de CA-01 ni de CA-02 puede prescindir de ellos) · REQ-014 CA-18
seccion_nueva "--- 40/1 · la ausencia que abre: la clase derivada (REQ-024 CA-01, CA-02) ---"

REPO24="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT24_RUTAS='hooks tools'
MAT24_REG=''; MAT24_T0=0; MAT24_REF='-'; MAT24_ETIQ='-'
mat24_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT24_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT24_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT24_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT24_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT24_ETIQ ref=$MAT24_REF archivos=$arch"
}
mat24() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT24_T0=${EPOCHREALTIME/./}
  MAT24_REF="${ref//[[:space:]]/_}"; MAT24_ETIQ="$MAT24_REF"; MAT24_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO.
  [ -e "$REPO24/.git" ] || { mat24_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO24" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat24_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO24" ls-tree -r "$ref" -- $MAT24_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat24_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat24_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat24_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO24" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat24_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat24_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO24" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat24_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat24_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat24_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat24_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat24_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat24_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat24_reg ok - "$n" "$procs"
  return 0
}
HER24="$RAIZ/her24-$BASHPID"; HER24_OK=no; REGHER24=''
mat24 v1.33.0 "$HER24" && HER24_OK=si
REGHER24="${MAT24_REG:-sin registro}"

# ---------- EL DOMINIO, EXTRAÍDO DEL SITIO DONDE EL LECTOR LO DECLARA ----------
# `ARNES_CLAVES` (hooks/lib.sh) y ni una clave escrita aquí. Se lee cargando la biblioteca en
# un subshell: si algún día el conjunto se muda, este caso lo sigue por su nombre y no por su
# forma literal en el archivo —una derivación que lee TEXTO de código se rompe con la primera
# mudanza (es el defecto que `tools/arnes-lectura.sh` acabó de retirar en 1.34.0)—.
# Y la DIRECCIÓN declarada de cada clave, del MISMO sitio único: es lo que dice qué claves son
# `n/a` —el sujeto de la transición— y por tanto quedan fuera de la medición POR DECLARACIÓN, no
# por una excepción escrita en el banco.
DIR24="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; printf "%s" "$ARNES_AUSENCIA"' _ "$HOOKS_DIR")"
dir24() {   # <clave> -> imprime la dirección declarada, o vacío si no declara ninguna
  local r
  case "$DIR24" in *"|$1|"*) r="${DIR24#*"|$1|"}"; printf '%s' "${r%%|*}" ;; esac
}
# Las claves que la PLANTILLA de `requirements/README.md` manda escribir. Se extraen del bloque
# cercado de «## Plantilla», hasta la primera sección: una clave que la máquina lee y que la
# plantilla no manda escribir es una clave que nadie va a escribir (CA-01, condición (b)).
TPL24="$(awk '/^## Plantilla/ { p = 1; next }
              p && /^```/      { c++; if (c == 2) exit; next }
              p && c == 1 && /^## / { exit }
              p && c == 1 && /^[^ #`][^:]*:/ { k = $0; sub(/:.*$/, "", k); print k }' \
          "$REPO24/requirements/README.md" 2>/dev/null | tr '\n' '|')"
# CERRADO POR LOS DOS LADOS, como `ARNES_CLAVES`: la comparacion es `|clave|` y sin la barra
# inicial la PRIMERA clave de la plantilla no casaba nunca — `Estado` salia como «una clave que
# la plantilla no manda escribir» siendo la primera que manda escribir.
TPL24="|$TPL24"

# ---------- LOS FIXTURES: el valor que MÁS restringe y el que permite, por clave ----------
declare -A RESTR24=() PERM24=()
RESTR24['QA']='pendiente';                 PERM24['QA']='aprobado'
RESTR24['Seguridad']='pendiente';          PERM24['Seguridad']='aprobado'
RESTR24['Sensible a seguridad']='sí';      PERM24['Sensible a seguridad']='no'
RESTR24['Hallazgos abiertos']='SEC-1 (contrato)'; PERM24['Hallazgos abiertos']='(ninguno)'
RESTR24['Rigor']='critico';                PERM24['Rigor']='estandar'
# EL RESTO DE LA CABECERA, por clave: los valores de los OTROS campos con los que la retirada
# de ÉSTE es lo único que cambia el veredicto. No es un recetario uniforme y no puede serlo:
# `Sensible a seguridad: sí` y `Rigor: critico` sólo muerden cuando `Seguridad:` no está
# aprobado, así que su fixture necesita `Seguridad: pendiente` — y entonces el par
# base/retirada sólo discrimina si el nivel declarado es `ligero`. Se escribe por clave y el
# propio caso comprueba que cada base DENIEGA en la heredada; si no, ABSTIENE nombrándola.
declare -A OTROS24=()
OTROS24['QA']='Seguridad: aprobado
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: estandar'
OTROS24['Seguridad']='QA: aprobado
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: critico'
OTROS24['Sensible a seguridad']='QA: aprobado
Seguridad: pendiente
Hallazgos abiertos: (ninguno)
Rigor: ligero'
OTROS24['Hallazgos abiertos']='QA: aprobado
Seguridad: aprobado
Sensible a seguridad: no
Rigor: estandar'
OTROS24['Rigor']='QA: aprobado
Seguridad: pendiente
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)'

# ---------- EL EVALUADOR: el veredicto de UNA versión sobre UNA cabecera ----------
P24="$RAIZ/p24-$BASHPID"
mkdir -p "$P24/.arnes" "$P24/requirements" "$P24/docs"
printf '# ESTADO\n' > "$P24/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P24/PENDING_APPROVAL.md"
J24="$(CLAUDE_PROJECT_DIR="$P24" jq -n --arg fp "$P24/requirements/REQ-940.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"completado"}}')"
eva24() {   # <hooks-dir> <exige:true|false> <cuerpo de cabecera> -> DENY|ALLOW
  local o
  printf '%s\n' "$MANIFIESTO_BASE" | jq ".campos.ausencia_exige = $2" > "$P24/.arnes/config.json"
  printf '# REQ-940\nEstado: en-revisión\n%s\n' "$3" > "$P24/requirements/REQ-940.md"
  o="$(printf '%s' "$J24" | CLAUDE_PROJECT_DIR="$P24" "$1/guard-completado.sh" 2>/dev/null)"
  # LAS DOS FORMAS DEL JSON, y no es purismo: `jq` escribe `"permissionDecision":"deny"` sin
  # espacio y el ayudante `check` del corredor lo casa con una EXPRESION (`: *"deny"`). Un glob
  # con el espacio dentro daba ALLOW a TODA denegacion —o sea, verde a los dos lados del par— y
  # asi se escribio este caso la primera vez. La leccion es la del canario: un `allow` esperado
  # tambien lo cumple un caso que no llego a medir.
  case "$o" in
    *'"permissionDecision":"deny"'*|*'"permissionDecision": "deny"'*) printf 'DENY' ;;
    *) printf 'ALLOW' ;;
  esac
}
# La cabecera con la clave `k` puesta en `$2` (`restr` | `perm` | `sin`), y las demás en los
# valores que su fixture declara.
cab24() {   # <clave> <restr|perm|sin> -> el cuerpo de la cabecera
  case "$2" in
    sin)   printf '%s' "${OTROS24[$1]}" ;;
    restr) printf '%s\n%s: %s' "${OTROS24[$1]}" "$1" "${RESTR24[$1]}" ;;
    *)     printf '%s\n%s: %s' "${OTROS24[$1]}" "$1" "${PERM24[$1]}" ;;
  esac
}

# ---------- LA MEDICIÓN: M, las `n/a`, N contra la línea base, y la clase de HOY ----------
M24=0; NA24=0; MED24=0; SINFIX24=''; NOFIX24=''; NOBASE24=''
N24=0; CLASEN24=''; HOY24=0; CLASEH24=''
# Las claves llevan BLANCOS (`Sensible a seguridad`), así que el recorrido va por el
# delimitador del sitio único y no por palabras: partirlas por espacios fabricaría claves que
# nadie escribió y el dominio medido dejaría de ser el del lector.
CLAVES24="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; printf "%s" "$ARNES_CLAVES"' _ "$HOOKS_DIR")"
while IFS= read -r k24; do
  [ -n "$k24" ] || continue
  M24=$((M24 + 1))
  case "$TPL24" in *"|$k24|"*) ;; *) SINFIX24="$SINFIX24 «$k24»" ;; esac
  d24="$(dir24 "$k24")"
  if [ -z "$d24" ]; then NOFIX24="$NOFIX24 «$k24»(sin dirección declarada)"; continue; fi
  if [ "$d24" = 'n/a' ]; then NA24=$((NA24 + 1)); continue; fi
  if [ -z "${OTROS24[$k24]:-}" ] || [ -z "${RESTR24[$k24]:-}" ]; then
    NOFIX24="$NOFIX24 «$k24»(sin fixture en esta sección)"; continue
  fi
  MED24=$((MED24 + 1))
  # La línea base: ¿el fixture RESTRINGE de verdad? Si su base no deniega, el par no
  # discrimina y esta clave no se puede medir — se nombra y no se cuenta como conforme.
  if [ "$HER24_OK" = si ]; then
    if [ "$(eva24 "$HER24/hooks" false "$(cab24 "$k24" restr)")" != DENY ]; then
      NOBASE24="$NOBASE24 «$k24»(su base no deniega en v1.33.0)"; continue
    fi
    if [ "$(eva24 "$HER24/hooks" false "$(cab24 "$k24" sin)")" = ALLOW ]; then
      N24=$((N24 + 1)); CLASEN24="$CLASEN24 «$k24»"
    fi
  fi
  # HOY, sobre un proyecto que ha ACTIVADO la exigencia: la clase tiene que quedar VACÍA.
  if [ "$(eva24 "$HOOKS_DIR" true "$(cab24 "$k24" restr)")" = DENY ] &&
     [ "$(eva24 "$HOOKS_DIR" true "$(cab24 "$k24" sin)")" = ALLOW ]; then
    HOY24=$((HOY24 + 1)); CLASEH24="$CLASEH24 «$k24»"
  fi
done <<< "${CLAVES24//|/$'\n'}"

# CA-01 · ANTI-VACUIDAD Y DENOMINADOR. Se publica en CADA corrida y aborta con SKIP —nunca
# PASS— si M = 0, si N = 0 o si el dominio no está CONTENIDO en las claves de la plantilla.
# «Ningún campo abre» es cierto por vacío cuando no había ninguno que abriera, y un instrumento
# que ante la ausencia de datos responde verde es la familia que REQ-020 existe para cazar.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-01 anti-vacuidad" | grep -qi -- "$FILTRO"; then
  if [ "$HER24_OK" != si ]; then
    echo "  SKIP  REQ-024 CA-01 anti-vacuidad y denominador  no hay línea base v1.33.0 ($REGHER24): N no se puede derivar"
  elif [ "$M24" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-01 anti-vacuidad y denominador  el dominio extraído del lector tiene M=0 claves: no hay nada que medir"
  elif [ -n "$SINFIX24" ]; then
    echo "  SKIP  REQ-024 CA-01 anti-vacuidad y denominador  el dominio NO está contenido en la plantilla de requirements/README.md: la máquina lee$SINFIX24 y la plantilla no manda escribirla(s) — una clave que nadie va a escribir"
  elif [ -n "$NOFIX24$NOBASE24" ]; then
    echo "  SKIP  REQ-024 CA-01 anti-vacuidad y denominador  hay claves del dominio que esta sección no puede medir:$NOFIX24$NOBASE24 (fail-closed: se nombran, no se omiten)"
  elif [ "$N24" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-01 anti-vacuidad y denominador  N=0 contra v1.33.0: ningún campo abría, así que «la clase queda vacía» sería cierto por vacío"
  else
    echo "  PASS  REQ-024 CA-01 anti-vacuidad y denominador: M=$M24 claves del lector ($NA24 n/a por declaración, $MED24 medidas), M ⊆ las ${TPL24//|/ } de la plantilla, y N=$N24 contra v1.33.0 —$CLASEN24—"; PASS=$((PASS+1))
  fi
fi
# CA-01 · LA CLASE DERIVADA QUEDA VACÍA sobre un proyecto que ha ACTIVADO la exigencia.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-01 la clase derivada" | grep -qi -- "$FILTRO"; then
  if [ "$MED24" -lt 1 ] || [ -n "$NOFIX24" ]; then
    echo "  SKIP  REQ-024 CA-01 la clase derivada queda vacía  no se pudo medir el dominio entero ($MED24 medidas de $M24;$NOFIX24)"
  elif [ "$HOY24" -eq 0 ]; then
    echo "  PASS  REQ-024 CA-01 la clase derivada queda VACÍA: ninguna de las $MED24 claves medidas ABRE al faltar (gobiernan o deniegan nombrando el campo)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-01 la clase derivada NO queda vacía: $HOY24 clave(s) siguen abriendo al faltar —$CLASEH24—. La ausencia se está resolviendo del lado que ABRE (SEC-047)"; FAIL=$((FAIL+1))
  fi
fi
# CA-01 · EL DISCRIMINANTE. Sin esta mitad el verde de arriba no acredita nada: también lo daría
# una comprobación que no mide. La versión HEREDADA tiene que abrir en al menos una clave.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-01 discriminante" | grep -qi -- "$FILTRO"; then
  if [ "$HER24_OK" != si ]; then
    echo "  SKIP  REQ-024 CA-01 discriminante: la heredada SÍ abre  no hay línea base v1.33.0 ($REGHER24)"
  elif [ "$N24" -ge 1 ]; then
    echo "  PASS  REQ-024 CA-01 discriminante: v1.33.0 ABRE en $N24 de las $MED24 claves medidas —$CLASEN24— y esta versión en 0: el par decide DISTINTO"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-01 discriminante: v1.33.0 no abre en ninguna clave, así que el caso no está midiendo la propiedad (R-013 §2 midió 4 de 6)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-02 · UN SOLO SITIO, Y SE MIDE POR MUTACIÓN ----------
# No se mide leyendo el código: se muta SÓLO la tabla del sitio único y se mira si los DOS
# sitios de bash cambian de opinión. `hooks/lib.sh` decide la ausencia del suelo de
# sensibilidad y del nivel de rigor; `hooks/guard-completado.sh`, la de los veredictos y la de
# la clase del hallazgo. Si alguno conservara su propia decisión, mutar la tabla no le haría
# nada — que es exactamente lo que este criterio prohíbe.
MUT24="$RAIZ/mut24-$BASHPID"
mkdir -p "$MUT24"; cp -r "$HOOKS_DIR" "$MUT24/hooks"
# La mutación pone `n/a` donde la tabla decía `deniega` (campo de la puerta: `QA`) y donde
# decía `gobierna:` (campo de lib.sh: `Rigor`). Con `n/a` la ausencia deja de exigir nada, así
# que las dos claves tienen que volver a ABRIR — en las dos, o el sitio no es uno.
sed -i "s/|deniega|/|n\/a|/g; s/|gobierna:\$ARNES_AUSENCIA_GOBIERNA_SENS|/|n\/a|/; s/|gobierna:\$ARNES_AUSENCIA_GOBIERNA_RIGOR|/|n\/a|/" "$MUT24/hooks/lib.sh"
chk24a() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; diag; FAIL=$((FAIL+1)); fi
}
chk24a "REQ-024 CA-02 sin mutar y con la exigencia activa, los dos sitios DENIEGAN la ausencia" \
  "DENY|DENY" "$(eva24 "$HOOKS_DIR" true "$(cab24 'QA' sin)")|$(eva24 "$HOOKS_DIR" true "$(cab24 'Rigor' sin)")"
chk24a "REQ-024 CA-02 mutada SOLO la tabla, los DOS vuelven a abrir (la decisión está en 1 sitio)" \
  "ALLOW|ALLOW" "$(eva24 "$MUT24/hooks" true "$(cab24 'QA' sin)")|$(eva24 "$MUT24/hooks" true "$(cab24 'Rigor' sin)")"

# CA-02 · EL DISCRIMINANTE QUE NOMBRA LA CLAVE. Un campo de cabecera NUEVO añadido al lector
# SIN declarar su dirección en el sitio único tiene que hacer FALLAR al banco NOMBRÁNDOLO. Un
# `rc≠0` a secas lo pasaría también una comprobación que falla siempre, así que se exigen las
# dos mitades EN LA MISMA CORRIDA: con la inyección falla y cita la clave; sin ella, pasa.
INY24="$RAIZ/iny24-$BASHPID"
mkdir -p "$INY24"; cp -r "$HOOKS_DIR" "$INY24/hooks"
sed -i "s/^ARNES_CLAVES=\"\$ARNES_CLAVE_QA/ARNES_CLAVE_NUEVO='Campo nuevo'\nARNES_CLAVES=\"\$ARNES_CLAVE_NUEVO|\$ARNES_CLAVE_QA/" "$INY24/hooks/lib.sh"
# La comprobación es la MISMA que corre arriba, aislada: para cada clave del dominio del
# lector, ¿declara dirección en el sitio único? Fail-closed y nombrando.
falta24() {   # <hooks-dir> -> imprime las claves del dominio SIN dirección declarada
  bash -c '. "$1/lib.sh" >/dev/null 2>&1
    while IFS= read -r k; do
      [ -n "$k" ] || continue
      arnes_ausencia "$k" || printf "%s " "$k"
    done <<< "${ARNES_CLAVES//|/$'"'"'\n'"'"'}"' _ "$1"
}
chk24a "REQ-024 CA-02 discriminante (i): una clave nueva sin dirección declarada se NOMBRA" \
  "Campo nuevo " "$(falta24 "$INY24/hooks")"
chk24a "REQ-024 CA-02 discriminante (ii): sin la inyección, la misma comprobación pasa" \
  "" "$(falta24 "$HOOKS_DIR")"

rm -rf "$HER24" "$MUT24" "$INY24" "$P24"
