# Sección 40 (2 de 4) del banco — 40-ausencia-que-abre-2-migracion-y-punteros
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 · SEC-047 (mitad 2), SEC-050, SEC-051. LA MIGRACIÓN Y LOS PUNTEROS: `CA-03` (ningún
# puntero queda falso), `CA-05` (un proyecto que no hace nada no nota nada), `CA-07` (el coste,
# por sus CUATRO vías) y `CA-11 (ii)` (ningún valor de campo se mueve). La clase derivada y el
# sitio único están en la parte 1; la conducta de la cola en `31-cola-una-sola-regla.sh`.
#
# EL CORTE VA POR TEMA Y SIN DEPENDENCIAS CRUZADAS: este archivo no usa ningún nombre de la
# parte 1 ni ella ninguno de aquí. `mat40` viene DUPLICADO —cada sección es su propio subshell y
# en `secciones/` no cabe un auxiliar—; su motivo está en `37-coste-del-escaner-1-el-dominio.sh`.
# ⚠ ESTE ARCHIVO ESTÁ EN 400 LÍNEAS, QUE ES SU TECHO EXACTO (`REQ-014 CA-18`, `N` gobierna
# porque el piso × 1,25 no llega): una línea más y la autoprueba aborta. Quien añada un caso
# aquí PARTE la sección; no sube el techo ni infla el piso para caber.
CASOS_ESPERADOS_SECCION=9
PISO_AUTONOMO_SECCION=194  # 16 preámbulo (líneas 1-16) + 74 maquinaria compartida duplicada (mat40 y la línea base, líneas 18-91) + 104 bloque indivisible mayor (el corpus con sus fixtures, el evaluador por documento y el veredicto del guardián, líneas 93-196: ningún caso de CA-03, CA-05 ni CA-11 puede prescindir de ellos) · REQ-014 CA-18
seccion_nueva "--- 40/2 · la ausencia que abre: migración, punteros y coste (REQ-024 CA-03, CA-05, CA-07, CA-11) ---"

REPO40="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT40_RUTAS='hooks tools'
MAT40_REG=''; MAT40_T0=0; MAT40_REF='-'; MAT40_ETIQ='-'
mat40_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT40_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT40_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT40_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT40_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT40_ETIQ ref=$MAT40_REF archivos=$arch"
}
mat40() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT40_T0=${EPOCHREALTIME/./}
  MAT40_REF="${ref//[[:space:]]/_}"; MAT40_ETIQ="$MAT40_REF"; MAT40_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO.
  [ -e "$REPO40/.git" ] || { mat40_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO40" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat40_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO40" ls-tree -r "$ref" -- $MAT40_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat40_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat40_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat40_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO40" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat40_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat40_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO40" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat40_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat40_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat40_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat40_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat40_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat40_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat40_reg ok - "$n" "$procs"
  return 0
}
HER40="$RAIZ/her40-$BASHPID"; HER40_OK=no; REGHER40=''
mat40 v1.33.0 "$HER40" && HER40_OK=si
REGHER40="${MAT40_REG:-sin registro}"

# El corpus es el de `requirements/` de este árbol MÁS los del proyecto de prueba SIN MIGRAR: el
# `Dado` de CA-05 incluye los dos, y el segundo es la vía conforme escrita ANTES de medir. MEDIDO
# el 2026-09-09: de los 27 REQ del árbol **0** omiten un campo de la clase, así que el suelo se
# cumple APORTANDO los fixtures —lo que el criterio manda— y no rebajándolo.
CLASE40='QA|Sensible a seguridad|Hallazgos abiertos|Rigor'
P40="$RAIZ/p40-$BASHPID"
mkdir -p "$P40/.arnes" "$P40/requirements" "$P40/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$P40/.arnes/config.json"   # SIN la llave: proyecto sin migrar
printf '# ESTADO\n' > "$P40/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P40/PENDING_APPROVAL.md"
cp "$REPO40"/requirements/REQ-*.md "$P40/requirements/" 2>/dev/null || :
# Un fixture por campo de la clase: declara los otros tres y OMITE ése — los REQ heredados que
# un proyecto sin migrar tiene por todas partes. Sin ellos la equivalencia es cierta por vacío.
i40=0
while IFS= read -r k40; do
  [ -n "$k40" ] || continue
  i40=$((i40 + 1))
  { printf '# REQ-95%s — sin «%s»\nEstado: en-revisión\nSeguridad: n/a\n' "$i40" "$k40"
    [ "$k40" = 'QA' ]                   || printf 'QA: aprobado\n'
    [ "$k40" = 'Sensible a seguridad' ] || printf 'Sensible a seguridad: no\n'
    [ "$k40" = 'Hallazgos abiertos' ]   || printf 'Hallazgos abiertos: (ninguno)\n'
    [ "$k40" = 'Rigor' ]                || printf 'Rigor: estandar\n'
    printf '\n## Historia\nFixture de REQ-024 CA-05.\n'; } > "$P40/requirements/REQ-95$i40.md"
done <<< "${CLASE40//|/$'\n'}"

# El evaluador POR DOCUMENTO: lo que el lector resuelve de una cabecera, con el suelo de
# sensibilidad y el rigor EFECTIVOS. Un proceso por árbol: definen las MISMAS funciones.
EVA40="$RAIZ/eva40-$BASHPID.sh"
cat > "$EVA40" <<'EVA'
#!/usr/bin/env bash
set -uo pipefail
. "$1" >/dev/null 2>&1 || exit 3
shift
for f; do
  t=''; IFS= read -r -d '' t < "$f" || true
  arnes_campos_req "$t" ''
  # SE COMPARA EL VALOR DE CADA CAMPO, y las banderas NUEVAS (`ARNES_SENS_AUSENTE`,
  # `ARNES_RIGOR_AUSENTE`) NO lo son: son observacion para que un motivo pueda nombrar el campo
  # que falta, y la heredada no las define. Meterlas en la huella haria el caso INSATISFACIBLE
  # —divergiria en todo REQ que omita un campo, justo los que el suelo exige— (QA-023-08).
  printf '%s\tqa=%s|seg=%s|sens=%s|hall=%s|rigor=%s|dudosa=%s|cita=%s|cr=%s\n' \
    "${f##*/}" "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR" \
    "${ARNES_SENS_DUDOSA:-}" "$ARNES_CITA_ABIERTA" "$ARNES_CR_INTERIOR"
  arnes_estado_cabecera "$t"; printf '%s\testado=%s|citado=%s\n' "${f##*/}" "$ARNES_ESTADO" "$ARNES_ESTADO_CITADO"
done
EVA
chmod +x "$EVA40"
# EL VEREDICTO DEL GUARDIAN. La edicion viaja pequeña y el guardian lee el documento DEL DISCO:
# asi el JSON no crece con el REQ (el corpus tiene uno de 297 KB y un `--arg` de ese tamaño deja
# el JSON vacio, o sea un caso que no mide nada).
ver40() {   # <hooks-dir> <archivo REQ> <exige:true|false> -> DENY|ALLOW
  local est o
  printf '%s\n' "$MANIFIESTO_BASE" | jq ".campos.ausencia_exige = $3" > "$P40/.arnes/config.json"
  est="$(awk '/^## /{exit} /^[Ee]stado:/{print; exit}' "$2")"
  [ -n "$est" ] || { printf 'SIN-ESTADO'; return 0; }
  o="$(CLAUDE_PROJECT_DIR="$P40" jq -n --arg fp "$2" --arg os "$est" \
        '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
          tool_input:{file_path:$fp,old_string:$os,new_string:"Estado: completado"}}' \
      | CLAUDE_PROJECT_DIR="$P40" "$1/guard-completado.sh" 2>/dev/null)"
  # LAS DOS FORMAS DEL JSON: `jq` no pone espacio tras el `:` y el ayudante `check` del corredor
  # lo casa con una expresion. Un glob con el espacio dentro daria ALLOW a TODA denegacion.
  case "$o" in
    *'"permissionDecision":"deny"'*|*'"permissionDecision": "deny"'*) printf 'DENY' ;;
    *) printf 'ALLOW' ;;
  esac
}
# ---------- CA-03 · EL PUNTERO DE REQ-016 CA-11, SEGUIDO AL PIE DE LA LETRA ----------
# El puntero manda a `hooks/guard-completado.sh` y dice que ahí vive la lista EXHAUSTIVA de qué
# campos perdona la ausencia. El control tiene que NOMBRAR no menos de 1 campo de la clase que
# ese archivo no decide, con su denominador: si no nombra ninguno, la sonda no está midiendo.
# `SEC-050` midió que el que falta es el que retira el SUELO de rigor. Medido: 2 de 4
# (`Sensible a seguridad` y `Rigor`, los dos en `hooks/lib.sh`).
#
# «AL PIE DE LA LETRA» NO SE MIDE CON UN `grep` DE TEXTO: el archivo MENCIONA en prosa casi
# todas las claves, la cadena responde «está» para las cuatro y el control no discrimina nada
# (escrito así dio 1 de 4, y la clave equivocada). Se DERIVA: se localiza cada llamada a
# `arnes_resuelve_ausencia`, se resuelve su primer argumento —una constante `ARNES_CLAVE_*`— a
# la clave que vale de verdad y se anota EN QUÉ ARCHIVO vive. La clave sale del código, así que
# un renombrado interno no vuelve cierto un puntero falso.
declare -A SITIO40=()
while IFS= read -r ln40; do
  [ -n "$ln40" ] || continue
  arg40="${ln40#*arnes_resuelve_ausencia \"}"; arg40="\"${arg40%%\"*}\""
  case "$arg40" in '""') continue ;; esac
  k40="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; eval "printf %s $2"' _ "$HOOKS_DIR" "$arg40" 2>/dev/null)"
  [ -n "$k40" ] || continue
  a40="${ln40%%:*}"; SITIO40["$k40"]="${a40##*/}"
done <<< "$(grep -n 'arnes_resuelve_ausencia "' "$HOOKS_DIR"/*.sh 2>/dev/null)"
FUERA40=''; DENTRO40=0; NCLASE40=0
while IFS= read -r k40; do
  [ -n "$k40" ] || continue
  NCLASE40=$((NCLASE40 + 1))
  if [ "${SITIO40[$k40]:-}" = 'guard-completado.sh' ]; then DENTRO40=$((DENTRO40 + 1))
  else FUERA40="$FUERA40 «$k40»→${SITIO40[$k40]:-ningún llamador}"; fi
done <<< "${CLASE40//|/$'\n'}"
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-03" | grep -qi -- "$FILTRO"; then
  if [ -n "$FUERA40" ]; then
    echo "  PASS  REQ-024 CA-03 control del puntero: siguiendo REQ-016 CA-11 al pie de la letra, $((NCLASE40 - DENTRO40)) de los $NCLASE40 campos de la clase NO tienen su ausencia decidida en hooks/guard-completado.sh —$FUERA40—, así que el sitio único de CA-02 es OTRO archivo y CA-03 resuelve por su salida (ii): REQ-016 vuelve a en-progreso y su CA-11 se reescribe con el puntero real. ESTE CASO PUBLICA LA MEDICIÓN Y NO ACREDITA CA-03: el write-back es del analista y no se ha hecho"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-03 control del puntero: no nombra NINGÚN campo de la clase fuera del archivo que el puntero cita, así que la sonda no está midiendo (SEC-050 midió que falta el que retira el suelo de rigor)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-05 · RADIO DE MIGRACIÓN, y CA-11 (ii) · NINGÚN VALOR SE MUEVE ----------
CORP40=(); OMITEN40=0
for f40 in "$P40"/requirements/REQ-*.md; do [ -f "$f40" ] && CORP40+=("$f40"); done
for f40 in ${CORP40[@]+"${CORP40[@]}"}; do
  h40="$(awk '/^## /{exit} {print}' "$f40")"
  while IFS= read -r k40; do
    [ -n "$k40" ] || continue
    case "$h40" in *"$k40:"*) ;; *) OMITEN40=$((OMITEN40 + 1)); break ;; esac
  done <<< "${CLASE40//|/$'\n'}"
done
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-05 anti-vacuidad" | grep -qi -- "$FILTRO"; then
  if [ "${#CORP40[@]}" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-05 anti-vacuidad y denominador  el corpus quedó vacío: no hay nada que juzgar"
  elif [ "$OMITEN40" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-05 anti-vacuidad y denominador  ninguno de los ${#CORP40[@]} REQ del corpus omite un campo de la clase: la equivalencia sería cierta por vacío. Vía conforme: aportar el fixture, nunca rebajar el suelo"
  else
    echo "  PASS  REQ-024 CA-05 anti-vacuidad y denominador: ${#CORP40[@]} REQ juzgados, $OMITEN40 omiten al menos un campo de la clase ($NCLASE40 campos)"; PASS=$((PASS+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-05 decisión a decisión" | grep -qi -- "$FILTRO"; then
  if [ "$HER40_OK" != si ]; then
    echo "  SKIP  REQ-024 CA-05 decisión a decisión sobre un proyecto SIN MIGRAR  no hay línea base v1.33.0 ($REGHER40)"
  elif [ "$OMITEN40" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-05 decisión a decisión sobre un proyecto SIN MIGRAR  el corpus no llega al suelo de anti-vacuidad ($OMITEN40 omisiones)"
  else
    mal40=0; prim40=''
    for f40 in ${CORP40[@]+"${CORP40[@]}"}; do
      a40="$(ver40 "$HOOKS_DIR" "$f40" false)"; b40="$(ver40 "$HER40/hooks" "$f40" false)"
      if [ "$a40" != "$b40" ]; then mal40=$((mal40 + 1)); [ -n "$prim40" ] || prim40="${f40##*/}($b40→$a40)"; fi
    done
    if [ "$mal40" -eq 0 ]; then
      echo "  PASS  REQ-024 CA-05 decisión a decisión: los ${#CORP40[@]} REQ del proyecto SIN MIGRAR reciben el MISMO veredicto de la puerta en las dos versiones ($OMITEN40 de ellos omiten un campo de la clase)"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-024 CA-05 decisión a decisión: $mal40 de ${#CORP40[@]} REQ deciden DISTINTO sin haber activado nada (el primero, $prim40). Un proyecto que no hace nada tiene que no notar nada"; FAIL=$((FAIL+1))
    fi
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-11 (ii)" | grep -qi -- "$FILTRO"; then
  if [ "$HER40_OK" != si ]; then
    echo "  SKIP  REQ-024 CA-11 (ii) los cuatro lectores devuelven el mismo valor que antes  no hay línea base v1.33.0 ($REGHER40)"
  else
    # LOS CUATRO LECTORES sobre el MISMO corpus: la puerta (su lector de campos), el informe, el
    # bloque derivado (`hooks/campos-req.awk`) y `tools/arnes-paralelo.sh`. Se compara el VALOR
    # entre las dos versiones: este REQ cambia la DIRECCIÓN de la ausencia, no el valor de
    # ningún campo, así que la transcripción declarada en awk no necesita ni una línea.
    d40=''
    cmp -s <(bash "$EVA40" "$HOOKS_DIR/lib.sh" ${CORP40[@]+"${CORP40[@]}"} 2>/dev/null) \
           <(bash "$EVA40" "$HER40/hooks/lib.sh" ${CORP40[@]+"${CORP40[@]}"} 2>/dev/null) || d40="$d40 puerta"
    cmp -s <(bash "$HOOKS_DIR/../tools/arnes-lectura.sh" "$P40" 2>/dev/null | grep -v '^Lectura del arnés') \
           <(bash "$HER40/tools/arnes-lectura.sh" "$P40" 2>/dev/null | grep -v '^Lectura del arnés') || d40="$d40 informe"
    cmp -s <(awk -f "$HOOKS_DIR/campos-req.awk" ${CORP40[@]+"${CORP40[@]}"} 2>/dev/null) \
           <(awk -f "$HER40/hooks/campos-req.awk" ${CORP40[@]+"${CORP40[@]}"} 2>/dev/null) || d40="$d40 bloque-derivado"
    cmp -s <(bash "$HOOKS_DIR/../tools/arnes-paralelo.sh" "$P40" REQ-951 REQ-952 2>&1) \
           <(bash "$HER40/tools/arnes-paralelo.sh" "$P40" REQ-951 REQ-952 2>&1) || d40="$d40 paralelo"
    if [ -z "$d40" ]; then
      echo "  PASS  REQ-024 CA-11 (ii) los CUATRO lectores devuelven exactamente lo mismo que v1.33.0 sobre los ${#CORP40[@]} REQ: ningún valor de campo se movió"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-024 CA-11 (ii) hay lectores que cambian de opinión:$d40. Este REQ cambia la DIRECCIÓN de la ausencia, no el VALOR de ningún campo"; FAIL=$((FAIL+1))
    fi
  fi
fi
# ---------- CA-07 · EL COSTE, POR LAS CUATRO VÍAS Y EN LA MISMA CORRIDA ----------
num40() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }   # ¿entero?
ENT40="$RAIZ/ent40-$BASHPID.json"
emite_write "$P40/requirements/REQ-951.md" '# REQ-951
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Hallazgos abiertos: (ninguno)
Rigor: critico' > "$ENT40"
STOP40="$RAIZ/stop40-$BASHPID.json"
CLAUDE_PROJECT_DIR="$P40" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}' > "$STOP40"
MED40=0; LO40=0; HI40=0; V40=''
med40() {   # <n...> -> MED40 (con un número PAR de tomas, la superior: el lado que hace el PASS más difícil)
  local x j tmp; local -a s=()
  for x in "$@"; do
    s+=( "$x" ); j=$(( ${#s[@]} - 1 ))
    while [ "$j" -gt 0 ] && [ "${s[j-1]}" -gt "${s[j]}" ]; do tmp="${s[j-1]}"; s[j-1]="${s[j]}"; s[j]="$tmp"; j=$(( j - 1 )); done
  done
  MED40="${s[${#s[@]}/2]}"; LO40="${s[0]}"; HI40="${s[${#s[@]}-1]}"
}
mil40() { printf -v V40 '%d.%03d' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }
# (i) LOS PROCESOS, que el reloj de una máquina rápida esconde. La llave viaja DENTRO de la
# llamada a jq que cada punto de entrada ya hacía, así que el delta es 0 —por evaluación de la
# puerta Y por parada, los dos caminos del criterio—.
proc40() {   # <nombre> <sujeto de este árbol> <sujeto heredado> <qué camino>
  local nombre="$1" a='' b='' r
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$HER40_OK" != si ]; then echo "  SKIP  $nombre  no hay línea base v1.33.0 ($REGHER40)"; return 0; fi
  r="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta este --sujeto "$2" 2>/dev/null)"
  sonda_lee "$r" && [ "${SONDA[estado]}" = ok ] && a="${SONDA[cuenta]:-}"
  r="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta heredado --sujeto "$3" 2>/dev/null)"
  sonda_lee "$r" && [ "${SONDA[estado]}" = ok ] && b="${SONDA[cuenta]:-}"
  if ! num40 "$a" || ! num40 "$b"; then
    echo "  SKIP  $nombre  la sonda de procesos no dejó las dos cuentas (este=<${a:-vacío}> heredado=<${b:-vacío}>): ${SONDA_MOTIVO:-${SONDA[motivo]:-sin motivo}}"; return 0
  fi
  if [ "$a" -le "$b" ]; then
    echo "  PASS  $nombre  $4 gasta $a procesos y la línea base $b: 0 añadidos"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  $4 gasta $a procesos contra $b de la línea base: $(( a - b )) añadido(s), y el techo es 0"; FAIL=$((FAIL+1))
  fi
}
proc40 "REQ-024 CA-07 (i) la llave de activación no añade ni un proceso por evaluación de la puerta" \
  "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT40' >/dev/null 2>&1" \
  "bash '$HER40/hooks/guard-completado.sh' < '$ENT40' >/dev/null 2>&1" "la evaluación de la puerta"
proc40 "REQ-024 CA-07 (i) ni un proceso por PARADA (el bloque derivado lee la llave en la misma llamada)" \
  "bash '$HOOKS_DIR/estado-derivado.sh' < '$STOP40' >/dev/null 2>&1" \
  "bash '$HER40/hooks/estado-derivado.sh' < '$STOP40' >/dev/null 2>&1" "la parada"
# (ii) EL RELOJ DE LA RUTA CRÍTICA, con los DOS SUJETOS INTERCALADOS en la misma invocación de
# la sonda: así la carga de la máquina no cae entera sobre uno de los dos términos. El techo es
# OPERATIVO y no se sube: si sale > 1,25×, es hallazgo contra el código.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-07 (ii)" | grep -qi -- "$FILTRO"; then
  if [ "$HER40_OK" != si ]; then
    echo "  SKIP  REQ-024 CA-07 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  no hay línea base v1.33.0 ($REGHER40)"
  else
    r40="$("$UTIL_DIR/sonda-reloj.sh" --k 4 --r 6 --etiqueta ruta-critica-024 \
      --sujeto-a "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT40' >/dev/null 2>&1" \
      --sujeto-b "bash '$HER40/hooks/guard-completado.sh' < '$ENT40' >/dev/null 2>&1" 2>/dev/null)"
    m40=''
    if ! sonda_lee "$r40"; then m40="el registro de la sonda no es legible: $SONDA_MOTIVO"
    elif [ "${SONDA[estado]}" != ok ] || ! num40 "${SONDA[min_a]:-}" || ! num40 "${SONDA[min_b]:-}"; then
      m40="la sonda no pudo medir: estado=${SONDA[estado]:-vacío} motivo=${SONDA[motivo]:-sin motivo} (a=${SONDA[min_a]:-n/a}µs b=${SONDA[min_b]:-n/a}µs)"
    elif [ "${SONDA[min_a]}" -lt 50000 ] || [ "${SONDA[min_b]}" -lt 50000 ]; then
      m40="serie por debajo del suelo de 50 ms (a=${SONDA[min_a]}µs b=${SONDA[min_b]}µs): el reloj no distingue del ruido"
    fi
    if [ -n "$m40" ]; then
      echo "  SKIP  REQ-024 CA-07 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  $m40"
    else
      c40=$(( SONDA[min_a] * 1000 / SONDA[min_b] )); mil40 "$c40"
      if [ "$c40" -le 1250 ]; then
        echo "  PASS  REQ-024 CA-07 (ii) el reloj de la ruta crítica = ${V40}× (techo 1.250×; ${SONDA[min_a]}µs sobre ${SONDA[min_b]}µs, k=${SONDA[k]} r=${SONDA[r]}, sujetos intercalados)"; PASS=$((PASS+1))
      else
        echo "  FAIL  REQ-024 CA-07 (ii) el reloj de la ruta crítica = ${V40}× > techo 1.250× (${SONDA[min_a]}µs sobre ${SONDA[min_b]}µs): el techo es OPERATIVO y no se sube"; FAIL=$((FAIL+1))
      fi
    fi
  fi
fi
# (iii) y (iv) SON AUTO-ANCLADOS y ORTOGONALES: doblar el NÚMERO DE ENTRADAS y doblar la
# LONGITUD DE UNA LÍNEA degradan por caminos distintos. EL ESTADÍSTICO ES LA MEDIANA DE 5 TOMAS
# DE LA RELACIÓN Y LA DISPERSIÓN ES LA MAD, no el rango: el rango es monótono no decreciente, así
# que «más tomas» no puede estrecharlo nunca y la vía conforme para afirmar el techo quedaría
# cerrada por construcción (lección medida en `CA-09 (iii)` de REQ-023).
coc40() {   # <nombre> <archivo 2n> <archivo n> <k> <techo por mil> <el par, en texto>
  local nombre="$1" fa="$2" fb="$3" k="$4" techo="$5" par="$6" t r a b lo hi med mad marg
  local vm vt vmad vma vlo vhi
  local -a q=() d=()
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  for t in 1 2 3 4 5; do
    r="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "coc40-$t" \
      --prep ". '$HOOKS_DIR/lib.sh' >/dev/null 2>&1" \
      --sujeto-a "arnes_cola_pendientes '$fa'" --sujeto-b "arnes_cola_pendientes '$fb'" 2>/dev/null)"
    # UN REGISTRO VACIO NO ES UNA MEDIDA: la toma no se ejecutó. Se descarta, nunca se cuenta.
    [ -n "$r" ] || continue
    sonda_lee "$r" || continue
    [ "${SONDA[estado]}" = ok ] || continue
    a="${SONDA[min_a]:-}"; b="${SONDA[min_b]:-}"
    num40 "$a" && num40 "$b" || continue
    # El suelo va por TOMA: una serie bajo 50 ms no distingue del ruido y no entra en la mediana.
    [ "$a" -ge 50000 ] && [ "$b" -ge 50000 ] || continue
    q+=( $(( a * 1000 / b )) )
  done
  [ "${#q[@]}" -ge 3 ] || { echo "  SKIP  $nombre  sólo ${#q[@]} de 5 tomas son utilizables (suelo de 50 ms por serie, k=$k): con menos no hay mediana que defender · $par"; return 0; }
  med40 "${q[@]}"; med="$MED40"; lo="$LO40"; hi="$HI40"
  for a in "${q[@]}"; do if [ "$a" -ge "$med" ]; then d+=( $(( a - med )) ); else d+=( $(( med - a )) ); fi; done
  med40 "${d[@]}"; mad="$MED40"
  if [ "$med" -le "$techo" ]; then marg=$(( techo - med )); else marg=$(( med - techo )); fi
  mil40 "$med"; vm="$V40"; mil40 "$techo"; vt="$V40"; mil40 "$mad"; vmad="$V40"
  mil40 "$marg"; vma="$V40"; mil40 "$lo"; vlo="$V40"; mil40 "$hi"; vhi="$V40"
  if [ "$mad" -ge "$marg" ]; then
    echo "  SKIP  $nombre  no se puede AFIRMAR el techo: MAD ${vmad}× >= margen ${vma}× contra el techo ${vt}× (mediana ${vm}×, ${#q[@]} tomas de ${vlo}× a ${vhi}×). Vía conforme: más tomas, k mayor o un host menos cargado — nunca subir el techo ni cambiar el par · $par"; return 0
  fi
  if [ "$med" -le "$techo" ]; then
    echo "  PASS  $nombre  mediana ${vm}× (techo ${vt}×; margen ${vma}× > MAD ${vmad}×, ${#q[@]} tomas de ${vlo}× a ${vhi}×) · $par"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  mediana ${vm}× > techo ${vt}× (margen ${vma}× > MAD ${vmad}×): el techo es OPERATIVO y no se sube — lo que baja es el coste del lector · $par"; FAIL=$((FAIL+1))
  fi
}
# Los fixtures de la cola. El PAR se publica CON su cociente: un cociente de duplicación sin
# decir entre qué dos puntos se tomó no es comparable con nada (QA-023-05).
#
# `k = 8` NO es redondo: pone la serie MÁS CORTA (el término `n`) sobre el suelo de 50 ms con
# margen. Medido: a `k = 3` el término bajo dio 0 de 5 tomas utilizables y el caso ABSTUVO —una
# abstención no acredita nada, ni repitiéndola—; a `k = 4` quedaba en el filo (46-84 ms según la
# carga), o sea que el veredicto lo decidía el host. Subir `k` es la vía conforme; el techo, no.
COLA40_N=400; COLA40_L=1000
for m40 in "$COLA40_N" $(( COLA40_N * 2 )); do
  { echo '## Pendientes'; for ((j40 = 0; j40 < m40; j40++)); do printf '### [2026-09-05] (dev) — decision %d\n' "$j40"; done
  } > "$RAIZ/e40-$m40-$BASHPID.md"
done
for m40 in "$COLA40_L" $(( COLA40_L * 2 )); do
  rel40=''; while [ "${#rel40}" -lt "$m40" ]; do rel40+='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; done
  { echo '## Pendientes'; for ((j40 = 0; j40 < 20; j40++)); do printf '### [2026-09-05] (dev) — %s\n' "${rel40:0:m40}"; done
  } > "$RAIZ/l40-$m40-$BASHPID.md"
done
coc40 "REQ-024 CA-07 (iii) doblar el NÚMERO DE ENTRADAS mantiene el lector de la cola lineal" \
  "$RAIZ/e40-$(( COLA40_N * 2 ))-$BASHPID.md" "$RAIZ/e40-$COLA40_N-$BASHPID.md" 8 2200 \
  "par de tamaños: $COLA40_N → $(( COLA40_N * 2 )) entradas de '## Pendientes', longitud de línea constante"
coc40 "REQ-024 CA-07 (iv) doblar la LONGITUD DE UNA LÍNEA de entrada mantiene el lector lineal" \
  "$RAIZ/l40-$(( COLA40_L * 2 ))-$BASHPID.md" "$RAIZ/l40-$COLA40_L-$BASHPID.md" 8 2200 \
  "par de longitudes: $COLA40_L → $(( COLA40_L * 2 )) bytes de línea de entrada, 20 entradas constantes"

rm -rf "$HER40" "$P40" "$EVA40" "$ENT40" "$STOP40" "$RAIZ"/e40-*-"$BASHPID".md "$RAIZ"/l40-*-"$BASHPID".md
