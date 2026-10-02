# ---------- 37 (4/5) · LA RUTA CRÍTICA DEL BANCO ----------
# REQ-017 CA-05 y la mitad de CA-06 que la prueba. Aquí se mide lo que de verdad se paga en
# cada PR (`32-huecos-auditoria-r001`, la ruta crítica).
#
# QUÉ CORRE POR DEFECTO Y QUÉ NO. La comparación de CA-05 contra la ruta crítica NO corre
# por defecto —cuesta lo que costaba el defecto, porque ES el defecto corriendo— y se
# enciende con `ARNES_COSTE_RUTA_CRITICA=1`; apagada dice SKIP citando el número acreditado
# y su fecha, nunca PASS.
#
# Y LAS PUERTAS DE CA-05 SE PRUEBAN AUNQUE LA COMPARACIÓN ESTÉ APAGADA. Las tres decisiones
# —«¿produjo casos esta corrida?», «¿terminó en verde?» y «¿esta muerte prueba el
# vencimiento?»— viven en funciones puras, así que se les dan entradas sintéticas y se
# comprueba su veredicto en milisegundos. Es lo que faltaba en la vuelta 0 (QA-017-03 y
# QA-017-04): la puerta corría sólo cuando se encendía la palanca, y nadie comprobaba nunca
# que la puerta cerrase. Por eso el bloque de CA-06 va AQUÍ y no en la otra parte: es el
# bloque atado a CA-05, y separarlo dejaría la puerta sin quien la ejerza.
#
# PARTE 4 DE 5 POR REQ-014 CA-18: `37/2` medía 679 líneas contra un techo de 585 y cabe en
# DOS. Aquí van CA-05 y su CA-06; las dos magnitudes del camino normal (CA-08) van en
# `37-coste-del-escaner-5-el-camino-normal.sh`. `mat47` viene DUPLICADO allí a propósito:
# CA-04, CA-19 y H-04 de REQ-014 hacen imposible factorizarlo.
CASOS_ESPERADOS_SECCION=4
PISO_AUTONOMO_SECCION=463  # 28 preámbulo (líneas 1-28) + 92 maquinaria compartida duplicada (mat47 y la línea base, líneas 29-120) + 269 bloque indivisible mayor (CA-05 entero: caso47, valida47, corre47, la medición y veredicto47, líneas 122-390) + 74 bloque atado a él (CA-06 prueba las dos puertas de CA-05, líneas 392-465) · REQ-014 CA-18
seccion_nueva "--- 37/4 · la ruta crítica del banco (REQ-017 CA-05, con la mitad de CA-06 que la prueba) ---"

BANCO47="${SEC_DIR%/}/../run.sh"
INV47="${SEC_DIR%/}/../inventario.sh"

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

# ---------- CA-05 · LA RUTA CRÍTICA: ACREDITACIÓN DE FAIL-BEFORE, NO PUERTA DE CADA PR ----------
# La sección 32 corrida AISLADA y con `ARNES_JOBS=1` contra los dos árboles, en la misma
# máquina y la misma corrida: así la velocidad de la máquina se cancela y lo que queda es
# la razón.
#
# APAGADA POR DEFECTO, Y EL MOTIVO ESTÁ MEDIDO. La corrida heredada cuesta lo que costaba
# el defecto (~76 s en Linux) porque ES el defecto corriendo: pagarla en cada vuelta deja
# el banco en ~145 s, es decir la PUERTA REQUERIDA de `main` más lenta que la regresión de
# 92 s que este REQ arregla, y de forma permanente. Además la línea base es un TAG
# CONGELADO: acreditada la razón, deja de medir la evolución de este árbol y envejece
# hacia el lado que abre. La vigilancia permanente del coste la contrata CA-03 —el orden
# de crecimiento, auto-anclado, sin tag y en milisegundos—. Aquí se acredita una vez, con
# su número y su fecha, y se repite a mano con `ARNES_COSTE_RUTA_CRITICA=1`.
#
# EL DENOMINADOR NO SE MIDE: SE ACOTA, Y LA COTA QUEDA PROBADA. La heredada se lanza bajo
# `timeout` de 4 × mín(este árbol), derivado en ESTA misma corrida y DESPUÉS del
# numerador. Un plazo en segundos escrito a mano sería el reloj absoluto que todo este REQ
# combate —lo falsea la máquina, el runner y `nice`—; derivado del numerador, la máquina se
# cancela igual que en una razón. Si el plazo VENCE, entonces heredada > 4 × este y el
# cociente es ≤ 0,25×: la desigualdad contratada queda DEMOSTRADA, no estimada, y lo único
# que se deja de conocer es el VALOR de la razón, que el criterio no pide. Por eso el
# vencimiento es un resultado POSITIVO —PASS— y nunca un SKIP: un SKIP ahí convertiría el
# hallazgo en silencio. Si la heredada TERMINA dentro del plazo, el cociente es > 0,25× y
# el caso FALLA.
ACRED47='0,125× — 9,60 s frente a 76,19 s, medido el 2026-09-07'

# LA PREGUNTA NO ES «¿TERMINÓ?», ES «¿ESTA CORRIDA PRODUJO UNA MEDICIÓN?» — y son distintas
# justo donde duele. Una corrida que termina EN ROJO no midió lo que cuesta correr la
# sección: midió lo que cuesta fallarla, y además falla ANTES, así que mide MENOS. Medido
# por QA (QA-017-03, vuelta 1): con los hooks sustituidos por un sello que siempre permite,
# la sección 32 sale en 14 FAIL, rc 1 y 3,79 s en vez de ~9,6 s; el plazo derivado cae a
# 16 s, la heredada vence de sobra y las DOS mitades daban PASS — incluida la que se llama
# «la comparación no se compra dejando de probar». Es decir: el criterio que existe para
# impedir comprar la comparación dejando de probar, la compraba dejando de probar.
#
# El rc del corredor es la señal correcta y no hay que fabricar ninguna: `run.sh` sale 0
# SÓLO con 0 FAIL, con el cuadre por archivo cerrado (ningún caso perdido) y sin procesos
# vivos. El recuento de casos se conserva porque es la evidencia DIRECTA —y porque un
# corredor que muere antes de imprimir nada también devuelve un rc—.
#
# UNO A UNO, Y NO CONCATENADOS: con `"$rc$ut"` un valor VACÍO desaparece dentro de los
# dígitos del vecino y la guarda deja pasar la basura que existe para atrapar. Y tampoco en
# un solo patrón separado por barras: dentro de un `case`, el `|` de `*[!0-9|]*` NO es un
# carácter de la clase — es el separador de alternativas del propio `case`, que parte el
# patrón en `*[!0-9` y `]*` y así no dispara NUNCA (comprobado en bash 5.3 al escribir
# esto: la primera versión de esta guarda no guardaba nada).
num47() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

MOT47C=''; NC47=0
# DOS PREGUNTAS, Y SEPARARLAS ES EL ARREGLO DE QA-017-09. «¿Produjo esta corrida algún caso?»
# y «¿terminó en verde?» no son la misma pregunta, y el denominador de CA-05 sólo puede
# responder la primera: cuando el plazo VENCE no hay rc de corredor que juzgar —lo mató
# `timeout`— pero sí hay salida que mirar. Mientras las dos vivieron juntas, la rama del
# vencimiento no consultaba ninguna, y una heredada que se cuelga SIN PRODUCIR UN CASO
# publicaba «≤ 0,250× — DEMOSTRADO».
#
# Y HAY QUE MIRAR EN DOS SITIOS, PORQUE LA SEÑAL OBVIA ES CONSTANTE-CERO — medido al implementar
# esto, y es la misma clase que `ADR-004` diagnosticó en CA-01: una comprobación correcta sobre
# la señal equivocada. `run.sh` NO imprime nada hasta que todas sus secciones terminan (junta los
# `out-$i` al final), así que una corrida heredada matada por `timeout` deja **cero bytes**
# SIEMPRE, trabajara o no. Exigirle «que su salida no esté vacía» no distingue una corrida
# bloqueada de una que lleva 36 s midiendo: las manda a las dos a SKIP, y con eso el único PASS
# de CA-05 (i) desaparece — una guarda insatisfacible no es una guarda estricta.
#
# La señal que SÍ distingue es lo que la corrida dejó ESCRITO MIENTRAS CORRÍA. Por eso a la
# heredada se le fija `TMPDIR`: su `mktemp -d` cae dentro de un directorio que esta sección
# conoce, y ahí están los `out-*` que las secciones van llenando caso a caso. Medido: matada a
# los 12 s deja **37 casos**; una que no arranca —el árbol sin bit de ejecución, un hook
# esperando en `stdin`— deja **0**, que es exactamente la distinción que QA-017-09 pide.
caso47() {   # <archivo de salida> [<dir donde la corrida dejó su trabajo>] -> 0 si produjo casos
  local salida="${1:-}" trab="${2:-}" nc=0
  MOT47C=''; NC47=0
  if [ -n "$salida" ] && [ -r "$salida" ] && [ -s "$salida" ]; then
    nc="$(grep -c '^  \(PASS\|FAIL\|SKIP\)  ' "$salida" 2>/dev/null || true)"
  fi
  if [ "${nc:-0}" -eq 0 ] && [ -n "$trab" ] && [ -d "$trab" ]; then
    nc="$(cat "$trab"/*/out-* 2>/dev/null | grep -c '^  \(PASS\|FAIL\|SKIP\)  ' || true)"
  fi
  if [ "${nc:-0}" -eq 0 ]; then
    if [ -z "$salida" ] || [ ! -r "$salida" ]; then
      MOT47C="no hay salida que leer (<${salida:-vacío}>) ni trabajo escrito en disco"
    elif [ ! -s "$salida" ]; then
      MOT47C="la salida está vacía y no dejó un solo caso escrito mientras corría"
    else
      MOT47C="no produjo un solo caso: no es una corrida rápida, es una que no midió"
    fi
    return 1
  fi
  NC47="$nc"; return 0
}
valida47() {   # <archivo de salida> <rc del corredor> -> 0 si esa corrida midió; si no, MOT47C dice por qué
  local salida="${1:-}" rc="${2:-}" nf
  MOT47C=''
  if ! num47 "$rc"; then
    MOT47C="el corredor no devolvió un código de salida legible (<${rc:-vacío}>): sin él no se sabe si esa corrida pasó"; return 1
  fi
  caso47 "$salida" || return 1
  nf="$(grep -c '^  FAIL  ' "$salida" 2>/dev/null || true)"
  if [ "$rc" -ne 0 ]; then
    MOT47C="terminó EN ROJO (rc=$rc; ${nf:-0} FAIL de ${NC47:-0} casos): una corrida que falla no mide lo que cuesta una corrida que pasa, y falla antes de terminarla, así que mide MENOS"
    return 1
  fi
  return 0
}
# EL MOTIVO VIAJA POR LA SALIDA, NO POR UNA VARIABLE, y eso no es estilo: `corre47` se
# llama dentro de `$( )`, que es un subshell, así que un `MOT47C` puesto ahí dentro muere
# con él y el caso diría «no se pudo medir» sin decir por qué. Un fail-closed silencioso es
# un bug de diagnóstico.
corre47() {   # <dir de hooks> <archivo de salida> -> imprime µs, o el motivo por el que no midió (rc 1)
  local hd="$1" salida="$2" t0 t1 rc
  [ -n "${EPOCHREALTIME:-}" ] || { printf 'no hay EPOCHREALTIME: sin reloj no hay medición\n'; return 1; }
  t0=${EPOCHREALTIME/./}
  ARNES_JOBS=1 ARNES_HOOKS_DIR="$hd" bash "$BANCO47" secciones/32-huecos-auditoria-r001.sh > "$salida" 2>&1
  rc=$?
  t1=${EPOCHREALTIME/./}
  valida47 "$salida" "$rc" || { printf '%s\n' "$MOT47C"; return 1; }
  printf '%s\n' "$((t1 - t0))"
}

# La palanca viene de FUERA y se escribe a mano, así que se normaliza antes de comparar
# —espacios y mayúsculas— y un valor que no se reconoce NO enciende la medición... pero
# tampoco se calla: se dice en el motivo del SKIP. Un fail-closed silencioso es un bug de
# diagnóstico, y aquí se leería como «no lo pedí» cuando la verdad es «lo pediste mal».
_pide47="${ARNES_COSTE_RUTA_CRITICA-}"
_pide47="${_pide47#"${_pide47%%[![:space:]]*}"}"
_pide47="${_pide47%"${_pide47##*[![:space:]]}"}"
PIDE47=no; RARO47=''
case "${_pide47,,}" in
  1|si|sí|yes|true|on) PIDE47=si ;;
  ''|0|no|false|off)   : ;;
  *)                   RARO47="$_pide47" ;;
esac

u_este47=''; inv47=''; inv47_igual=si; ncasos47=0
plazo47=''; rc_her47=''; ut_her47=''; motivo47=''
TIMEOUT47="$(type -P timeout 2>/dev/null || true)"
if [ "$PIDE47" != si ]; then
  motivo47="no se pide: evidencia acreditada en el Historial de REQ-017 ($ACRED47); es acreditación de fail-before, no puerta de cada PR — se repite con ARNES_COSTE_RUTA_CRITICA=1"
  [ -z "$RARO47" ] || motivo47="ARNES_COSTE_RUTA_CRITICA=<$RARO47> no se reconoce y NO enciende la medición; $motivo47"
elif [ "$HER47_OK" != si ]; then
  motivo47="no hay línea base: el tag v1.32.1 no está en este clon"
elif [ -z "$TIMEOUT47" ]; then
  # CA-06 nombra este caso: sin `timeout` el denominador sólo se puede MEDIR, y medirlo es
  # justo lo que cuesta 76 s. Antes que estimar la cota, se dice que no se puede acotar.
  motivo47="no hay 'timeout' en el PATH, y el denominador se ACOTA con él en vez de medirse"
elif [ ! -r "$BANCO47" ] || [ ! -r "$INV47" ]; then
  motivo47="no encuentro el corredor o el inventario junto a esta sección"
else
  # EL NUMERADOR PRIMERO, Y LAS TRES CORRIDAS A ARCHIVOS DISTINTOS: de ellas salen las dos
  # mitades del criterio —el mínimo para (i) y el inventario para (ii)—, y (ii) es
  # AUTO-ANCLADO: compara este árbol consigo mismo, no contra el tag.
  for _r47 in 1 2 3; do
    _o47="$OUT_ESTE47-$_r47.txt"
    _u47="$(corre47 "$HOOKS_DIR" "$_o47")" || { motivo47="la corrida $_r47 de este árbol no midió: ${_u47:-sin motivo}"; u_este47=''; break; }
    if [ -z "$u_este47" ] || [ "$_u47" -lt "$u_este47" ]; then u_este47="$_u47"; fi
    _i47="$(bash "$INV47" "$_o47" 2>/dev/null)"
    if [ -z "$_i47" ]; then motivo47="el inventario de la corrida $_r47 de este árbol salió vacío: no se comparó nada"; u_este47=''; break; fi
    if [ -z "$inv47" ]; then
      inv47="$_i47"
      while IFS= read -r _l47; do ncasos47=$((ncasos47 + 1)); done <<< "$_i47"
    elif [ "$_i47" != "$inv47" ]; then
      inv47_igual=no; inv47_dif="$_i47"
    fi
  done
  # EL SUELO DE 50 ms, aquí y no sólo en las sondas de 37/1: un numerador dentro del ruido
  # produciría un plazo dentro del ruido, y la cota se apoyaría en él.
  if [ -n "$u_este47" ] && [ "$u_este47" -lt 50000 ]; then
    motivo47="el mínimo de este árbol se queda en ${u_este47}µs, bajo el suelo de 50 ms donde el reloj no distingue del ruido"
    u_este47=''
  fi
  if [ -n "$u_este47" ]; then
    # 4 × mín(este árbol), EN SEGUNDOS Y REDONDEADO ARRIBA. La dirección del redondeo no es
    # cosmética: con el plazo >= 4×este, que venza sigue probando heredada > 4×este.
    # Redondear ABAJO probaría una desigualdad más floja que la contratada.
    plazo47=$(( (u_este47 * 4 + 999999) / 1000000 ))
    [ "$plazo47" -ge 1 ] || plazo47=1
    # Sin `--foreground`, `timeout` pone al hijo en SU PROPIO grupo de procesos y señala al
    # grupo entero: el corredor heredado muere con sus subshells, y no queda una corrida de
    # 76 s huérfana envenenando el reloj de la sección siguiente (CA-06).
    # EL RELOJ DE ESTA CORRIDA SE GUARDA, y hace falta: el rc solo NO distingue «venció el
    # plazo» de «alguien lo mató» (QA-017-04). El transcurrido es la corroboración.
    # `TMPDIR` FIJADO A PROPÓSITO, y no es higiene: es la única forma de saber si la corrida
    # heredada llegó a MEDIR. Su `mktemp -d` cae aquí dentro, y ahí es donde las secciones van
    # escribiendo sus casos mientras corren — la salida del corredor no sirve, porque no se
    # imprime hasta el final y una corrida matada deja cero bytes trabajara o no (ver `caso47`).
    mkdir -p "$TRAB47" 2>/dev/null || true
    _t0her47=${EPOCHREALTIME/./}
    TMPDIR="$TRAB47" ARNES_JOBS=1 ARNES_HOOKS_DIR="$HER47/hooks" \
      "$TIMEOUT47" -k 5 "$plazo47" bash "$BANCO47" secciones/32-huecos-auditoria-r001.sh > "$OUT_HER47" 2>&1
    rc_her47=$?
    ut_her47=$(( ${EPOCHREALTIME/./} - _t0her47 ))
  fi
fi

# EL VEREDICTO SOBRE LA HEREDADA, EN UNA FUNCIÓN PURA — y pura para poder probarla con
# entradas sintéticas sin pagar los 76 s de la corrida real (abajo, en los casos de CA-06).
#
# QUÉ PRUEBA QUÉ, QUE ES LO QUE ESTABA MAL. Lo contratado es «la heredada no cabe en
# 4 × mín(este árbol)». Sólo el código **124** significa «el plazo venció»; el **137** es
# «murió por SIGKILL», y eso lo produce igual el OOM killer, un `kill` de fuera o el `-k`
# del propio `timeout`. Medido por QA (QA-017-04): matando al hijo desde fuera a los 0,6 s
# de un plazo de 60 s el rc es 137, y este caso lo leía como «≤ 0,250× — DEMOSTRADO». Y no
# es hipotético: la corrida heredada ES el camino cuadrático, el que más memoria pide, así
# que el OOM kill es su modo de muerte más probable en un runner apretado — un verde falso
# etiquetado como demostración.
#
# Por eso el PASS exige las DOS cosas y de dos instrumentos distintos: que `timeout` diga
# que venció (124) y que el reloj de pared lo corrobore (transcurrido ≥ plazo). Cualquier
# otra muerte no es un FAIL —no hemos medido que la heredada sea rápida— sino un SKIP CON
# MOTIVO, que es lo que CA-06 contrata para una sonda que no pudo medir.
veredicto47() {   # <nombre> <rc> <µs transcurridos> <plazo s> <µs mín(este)> <salida her> [<trabajo her>]
  local nombre="$1" rc="${2:-}" ut="${3:-}" plazo="${4:-}" ue="${5:-}" sal="${6:-}" trab="${7:-}" pl seg este
  if ! num47 "$rc" || ! num47 "$ut" || ! num47 "$plazo" || ! num47 "$ue"; then
    echo "  SKIP  $nombre  el instrumento no devolvió números (rc=<${rc:-vacío}> transcurrido=<${ut:-vacío}>µs plazo=<${plazo:-vacío}>s este=<${ue:-vacío}>µs)"
    return 0
  fi
  pl=$(( plazo * 1000000 ))
  seg="$(awk -v u="$ut" 'BEGIN{printf "%.2f", u/1e6}')"
  este="$(awk -v u="$ue" 'BEGIN{printf "%.2f", u/1e6}')"
  if [ "$rc" = 124 ] && [ "$ut" -ge "$pl" ]; then
    # LA MISMA PREGUNTA QUE SE LE HACE AL NUMERADOR, Y AL DENOMINADOR TAMBIÉN (QA-017-09):
    # «¿esta corrida midió algo?». Un plazo agotado por una corrida que NO ARRANCÓ no acota
    # nada. No es hipotético y tiene precedente en esta misma ventana: el árbol heredado
    # extraído sin bit de ejecución no arrancaba el corredor hijo; allí TERMINABA y caía en
    # SKIP, pero si en vez de terminar se BLOQUEA —un hook esperando en `stdin`, un cerrojo,
    # un `read` sin `</dev/null`— el plazo vence, `timeout` devuelve 124, el reloj corrobora
    # y una corrida que no midió nada se publica como DEMOSTRACIÓN. Una corrida que no midió
    # no es una corrida lenta, igual que una corrida rota no es una corrida rápida.
    if ! caso47 "$sal" "$trab"; then
      echo "  SKIP  $nombre  el plazo de ${plazo}s venció (rc=124) y el reloj lo corrobora (${seg}s), pero la corrida heredada NO MIDIÓ NADA: $MOT47C — un plazo agotado por una corrida que no arrancó no acota nada"
      return 0
    fi
    echo "  PASS  $nombre  la heredada NO terminó en ${plazo}s = 4 × mín(este árbol) ($este s) y el reloj lo corrobora (${seg}s), habiendo producido $NC47 casos: heredada > 4 × este, luego el cociente es ≤ 0,250× — DEMOSTRADO, no estimado"
    PASS=$((PASS+1)); return 0
  fi
  if [ "$rc" = 124 ]; then
    echo "  SKIP  $nombre  timeout dice que venció (rc=124) pero el reloj sólo cuenta ${seg}s de un plazo de ${plazo}s: los dos instrumentos se contradicen y una cota no se firma sobre eso"
    return 0
  fi
  if [ "$rc" -ge 128 ]; then
    echo "  SKIP  $nombre  la corrida heredada murió por la señal $((rc - 128)) a los ${seg}s de un plazo de ${plazo}s: sólo el vencimiento (rc=124) prueba que el plazo se agotó — el OOM killer, un kill de fuera y el -k del propio timeout dan todos 137, y este camino es el cuadrático, el que más memoria pide"
    return 0
  fi
  if valida47 "$sal" "$rc"; then
    echo "  FAIL  $nombre  la heredada TERMINÓ dentro de ${plazo}s = 4 × mín(este árbol) (rc=$rc, ${seg}s frente a $este s): heredada < 4 × este, luego el cociente es > 0,250×"
    FAIL=$((FAIL+1)); return 0
  fi
  echo "  SKIP  $nombre  la corrida heredada terminó a los ${seg}s de ${plazo}s sin producir una medición: $MOT47C — una cota sobre una corrida que no midió no es una cota"
}

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 reloj" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (i) la ruta crítica cuesta no más de 0,250× lo de v1.32.1"
  if [ -z "$u_este47" ]; then
    echo "  SKIP  $nom47  ${motivo47:-no se pudo medir}"
  else
    veredicto47 "$nom47" "$rc_her47" "$ut_her47" "$plazo47" "$u_este47" "$OUT_HER47" "$TRAB47"
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 inventario" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (ii) la comparación no se compra dejando de probar"
  if [ -z "$u_este47" ]; then
    echo "  SKIP  $nom47  ${motivo47:-no se pudo medir}"
  elif [ "$inv47_igual" = si ]; then
    echo "  PASS  $nom47  las 3 corridas cronometradas terminaron EN VERDE (rc=0, 0 FAIL, cuadre cerrado) y dan el MISMO inventario ordenado caso→veredicto ENTRE SÍ ($ncasos47 casos); la igualdad contra el árbol heredado la cierra CA-02 sobre el banco entero"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  el inventario cambió ENTRE corridas del MISMO árbol: la medición del numerador no es reproducible"; FAIL=$((FAIL+1))
    diff <(printf '%s\n' "$inv47") <(printf '%s\n' "${inv47_dif:-}") 2>/dev/null | head -6 | sed 's/^/          /'
  fi
fi

# ---------- CA-06 · LAS DOS PUERTAS DE CA-05, PROBADAS CON ENTRADAS SINTÉTICAS ----------
# Las dos comprobaciones de aquí abajo son la misma familia que este REQ combate —DAR VERDE
# SIN HABER MEDIDO— pero una capa más arriba: no en el escáner, sino en la prueba que lo
# certifica. Vienen de la vuelta 1 de QA (QA-017-03 y QA-017-04) y cuestan MILISEGUNDOS,
# porque las dos decisiones viven en funciones puras: `valida47` (¿esta corrida midió?) y
# `veredicto47` (¿esta muerte prueba el vencimiento?). Probarlas contra la corrida real
# habría costado 76 s y sólo habría cubierto el camino que ese día se diera.
#
# FAIL-BEFORE, para que conste cómo se reproduce: con los cuerpos de esas dos funciones
# revertidos a los de antes de esta vuelta —`valida47` sin mirar el rc, y `veredicto47`
# aceptando `137` como vencimiento— los dos casos salen en FAIL. Es la única forma de saber
# que miden: una prueba nueva que pasa también contra el código viejo no probó nada.
ROJO47="$RAIZ/val47-rojo-$BASHPID.txt"
LIMPIO47="$RAIZ/val47-limpio-$BASHPID.txt"
MUDO47="$RAIZ/val47-mudo-$BASHPID.txt"
{ _i47=1; while [ "$_i47" -le 26 ]; do echo "  PASS  caso sintético $_i47"; _i47=$((_i47+1)); done
  _i47=1; while [ "$_i47" -le 14 ]; do echo "  FAIL  caso sintético en rojo $_i47"; _i47=$((_i47+1)); done
  echo "Resultado: 26 PASS, 14 FAIL"; } > "$ROJO47"
{ _i47=1; while [ "$_i47" -le 40 ]; do echo "  PASS  caso sintético $_i47"; _i47=$((_i47+1)); done
  echo "Resultado: 40 PASS, 0 FAIL"; } > "$LIMPIO47"
printf 'ABORT: el canario no arranca; no se lanzó ni una sección\n' > "$MUDO47"
# El trabajo que una corrida MATADA deja en disco: el `out-<n>` que su sección iba llenando. Es
# la vía por la que el positivo real de CA-05 acredita que la heredada estaba midiendo cuando el
# plazo la mató, y sin este par sintético nadie sabría que esa vía sigue abierta.
TRABSINT47="$RAIZ/trabsint47-$BASHPID"; mkdir -p "$TRABSINT47/tmp.sintetico"
{ _i47=1; while [ "$_i47" -le 37 ]; do echo "  PASS  caso escrito al vuelo $_i47"; _i47=$((_i47+1)); done
} > "$TRABSINT47/tmp.sintetico/out-0"
TRABVACIO47="$RAIZ/trabvacio47-$BASHPID"; mkdir -p "$TRABVACIO47/tmp.sintetico"

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 corrida en rojo" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (i)/(ii) una corrida que termina EN ROJO no cuenta como medición: deciden el rc y los casos, no el número de líneas"
  falla47=''
  # 14 FAIL y rc=1: es la reproducción exacta de QA-017-03 (hooks sustituidos por un sello
  # que siempre permite → 3,79 s en vez de ~9,6 s → plazo 16 s → dos PASS falsos).
  valida47 "$ROJO47"   1 && falla47="$falla47 <14 FAIL con rc=1 se aceptó como medición>"
  valida47 "$LIMPIO47" 0 || falla47="$falla47 <una corrida limpia se rechazó: $MOT47C>"
  valida47 "$MUDO47"   0 && falla47="$falla47 <una corrida sin un solo caso se aceptó como medición>"
  valida47 "$LIMPIO47" 1 && falla47="$falla47 <40 PASS pero rc=1 (cuadre roto o proceso vivo) se aceptó como medición>"
  valida47 "$LIMPIO47" '' && falla47="$falla47 <un rc ilegible se aceptó como medición>"
  if [ -z "$falla47" ]; then
    echo "  PASS  $nom47"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47 :$falla47"; FAIL=$((FAIL+1))
  fi
fi

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 muerte por señal" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (i) sólo el vencimiento del plazo, y con el reloj de acuerdo, prueba la cota: una muerte por señal dice SKIP"
  # Plazo de 60 s en todas: lo que cambia es CÓMO murió y CUÁNDO. `u_este47` no se toca —la
  # función es pura y recibe todo por argumentos—, así que esto vale igual con la palanca
  # apagada, que es como corre el banco por defecto.
  obs47="$( {
    veredicto47 sonda-de-prueba 137     600000 60 9000000 "$LIMPIO47"   # matada desde fuera a los 0,6 s: QA-017-04
    veredicto47 sonda-de-prueba 137   61000000 60 9000000 "$LIMPIO47"   # sobrevivió al plazo, pero murió por señal
    veredicto47 sonda-de-prueba 124   60000000 60 9000000 "$LIMPIO47"   # el positivo real: venció y el reloj lo dice
    veredicto47 sonda-de-prueba 124   60000000 60 9000000 "$MUDO47"   "$TRABVACIO47"  # venció SIN producir un caso: QA-017-09 (A)
    veredicto47 sonda-de-prueba 124   60000000 60 9000000 ''          "$TRABVACIO47"  # venció y su salida NI EXISTE: QA-017-09 (C)
    veredicto47 sonda-de-prueba 124   60000000 60 9000000 ''          "$TRABSINT47"   # venció TRABAJANDO: la salida está vacía pero dejó 37 casos escritos — el positivo REAL
    veredicto47 sonda-de-prueba 124    1000000 60 9000000 "$LIMPIO47" "$TRABSINT47"   # 124 con el reloj corto: instrumentos en contra
    veredicto47 sonda-de-prueba   0    9000000 60 9000000 "$LIMPIO47"                 # terminó limpia dentro del plazo: eso SÍ es FAIL
    veredicto47 sonda-de-prueba   0    9000000 60 9000000 "$MUDO47"                   # terminó sin medir nada: no acota nada
    veredicto47 sonda-de-prueba  ''    9000000 60 9000000 "$LIMPIO47"                 # sin rc: el instrumento no devolvió números
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp47='SKIP SKIP PASS SKIP SKIP PASS SKIP FAIL SKIP SKIP '
  if [ "$obs47" = "$esp47" ]; then
    echo "  PASS  $nom47  (10 formas de terminar → $obs47)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  se esperaba <$esp47> y se obtuvo <$obs47>"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `veredicto47` corrió dentro de una sustitución de
# comandos, que es un subshell, y sus PASS/FAIL murieron con él. Se dice porque un lector
# que no lo sepa creerá que estos casos descuadran el recuento de la sección.


rm -rf "$HER47" "$OUT_HER47" "$TRAB47" "$OUT_ESTE47"-1.txt "$OUT_ESTE47"-2.txt \
       "$OUT_ESTE47"-3.txt "$ROJO47" "$LIMPIO47" "$MUDO47" "$TRABSINT47" "$TRABVACIO47"
