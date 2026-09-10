# Sección 39 (3 de 5) del banco — 39-caracter-invisible-3-los-lectores-y-el-coste
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-023 · SEC-047 (mitad 1). LOS LECTORES: `CA-06` (los cuatro lectores no divergen y la
# guarda es OBSERVACIONAL: no cambia NINGÚN valor de campo, así que la transcripción declarada
# de `hooks/campos-req.awk` sigue diciendo lo mismo), `CA-07` (el informe no calla sobre lo que
# la puerta se niega a medir) y `CA-12` (la noción de cita no gana una transcripción y la cola
# de aprobaciones cuenta exactamente lo mismo, anclado a ESTE corpus y a ESTA comparación).
#
# EL COSTE —`CA-09`, con sus tres vías— vive en la parte 4, y no por gusto: con las cuatro cosas
# juntas este archivo llegaba a 422 líneas contra el techo de 400 de `REQ-014 CA-18`. El corte
# va por tema y en un punto sin dependencias cruzadas: la parte 4 no usa ningún nombre definido
# aquí, y por eso el materializador de la línea base viene DUPLICADO en las dos (mismo motivo
# que en las cinco partes de la 37, escrito UNA vez en `37-coste-del-escaner-1-el-dominio.sh`;
# residual `AN-021-01`). Los casos se reparten: no se crean ni se pierden.
CASOS_ESPERADOS_SECCION=7
PISO_AUTONOMO_SECCION=181  # 18 preámbulo (líneas 1-18) + 77 maquinaria compartida duplicada (mat93 y la línea base, líneas 20-96) + 86 bloque indivisible mayor (CA-12 entero: el contador de la cola, su corpus de siete formas y la comparación contra la heredada, líneas 179-264) · REQ-014 CA-18
seccion_nueva "--- 39/3 · el carácter invisible: los lectores (REQ-023 CA-06, CA-07 y CA-12) ---"

num93() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
REPO93="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT93_RUTAS='hooks tools'
MAT93_REG=''; MAT93_T0=0; MAT93_REF='-'; MAT93_ETIQ='-'
mat93_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT93_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT93_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT93_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT93_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT93_ETIQ ref=$MAT93_REF archivos=$arch"
}
mat93() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT93_T0=${EPOCHREALTIME/./}
  MAT93_REF="${ref//[[:space:]]/_}"; MAT93_ETIQ="$MAT93_REF"; MAT93_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO. Con `-d`, las dos secciones 37
  # se abstenían enteras dentro de un worktree —la copia haciendo la mitad del trabajo, el
  # caso que CA-05 cierra— mientras `git` resolvía el tag sin problema. Medido al montar los
  # dos árboles de CA-08; el motivo largo está en `37/1`, donde vive la copia gemela.
  [ -e "$REPO93/.git" ] || { mat93_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO93" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat93_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO93" ls-tree -r "$ref" -- $MAT93_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat93_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
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
  [ "$n" -ge 1 ] || { mat93_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat93_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO93" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat93_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat93_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO93" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat93_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat93_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat93_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat93_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  i=0
  while [ "$i" -lt "$n" ]; do
    case "${modos[i]}" in
      *755) [ -x "${rutas[i]}" ] || { mat93_reg sin-linea-base "objeto-ejecutable-sin-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; } ;;
      *)    if [ -x "${rutas[i]}" ]; then mat93_reg sin-linea-base "objeto-no-ejecutable-con-bit:${rutas[i]##*/}" desconocido "$procs"; return 1; fi ;;
    esac
    i=$((i + 1))
  done
  mat93_reg ok - "$n" "$procs"
  return 0
}
HER93="$RAIZ/her93-$BASHPID"; HER93_OK=no; REGHER93=''
mat93 v1.33.0 "$HER93" && HER93_OK=si

BOM93=$'\xef\xbb\xbf'
mk93() { printf '%s\n' "$2" > "$PROJ/requirements/$1.md"; }

# ---------- CA-06 · LOS CUATRO LECTORES NO DIVERGEN, Y LA GUARDA ES OBSERVACIONAL ----------
# La puerta usa el lector de `hooks/lib.sh`; el bloque derivado usa `hooks/campos-req.awk`, que
# es su TRANSCRIPCIÓN DECLARADA y no una segunda regla. Se alimenta el MISMO documento a los
# dos y se comparan los seis campos ya normalizados por la MISMA cola (`arnes_campos_normaliza`),
# que es el camino real de las dos bocas. Si la guarda cambiara un valor de campo, el awk
# tendría que cambiar con ella — y ese archivo está FUERA de `Archivos:` de este REQ a
# propósito: tener que tocarlo es la señal de que la guarda dejó de ser observacional.
LEE93="$RAIZ/lee93-$BASHPID.sh"
cat > "$LEE93" <<'SONDA93'
#!/usr/bin/env bash
set -uo pipefail
H="$1"; modo="$2"; f="$3"
# shellcheck source=/dev/null
. "$H/lib.sh"
texto=''; IFS= read -r -d '' texto < "$f" || :
if [ "$modo" = lib ]; then
  arnes_campos_req "$texto" ''
  arnes_estado_cabecera "$texto"; est="$ARNES_ESTADO"
else
  linea="$(awk -f "$H/campos-req.awk" "$f")"
  IFS=$'\001' read -r _ruta c_est c_qa c_seg c_sens c_hall c_rig <<< "$linea"
  arnes_norm_campo "$c_est"; arnes_veredicto "$ARNES_CAMPO"; est="$ARNES_VEREDICTO"
  arnes_campos_normaliza "$c_qa" "$c_seg" "$c_sens" "$c_hall" "$c_rig"
fi
printf 'Estado=<%s> QA=<%s> Seg=<%s> Sens=<%s> Hall=<%s> Rigor=<%s>\n' \
  "$est" "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR"
SONDA93
chmod +x "$LEE93"
# El corpus de esta comparación: los REQ del árbol MÁS un documento con un invisible en cada
# uno de los campos que el lector reconoce. Los del árbol acreditan que nada cambió; los del
# invisible, que la guarda OBSERVA y no altera el valor que los dos lectores publican.
DOCS93=(); i93=0
for f93 in "$REPO93"/requirements/*.md; do
  [ -f "$f93" ] || continue
  case "${f93##*/}" in README.md) continue ;; esac
  DOCS93+=("$f93")
done
CLAVES93="$(. "$HOOKS_DIR/lib.sh" >/dev/null 2>&1; printf '%s' "${ARNES_CLAVES:-}")"
while IFS= read -r k93; do
  [ -n "$k93" ] || continue
  i93=$((i93 + 1))
  printf '# REQ-99%s\nEstado: completado\n%s%s: aprobado\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nRigor: critico\n' \
    "$i93" "$BOM93" "$k93" > "$RAIZ/doc93-$BASHPID-$i93.md"
  DOCS93+=("$RAIZ/doc93-$BASHPID-$i93.md")
done <<< "${CLAVES93//|/$'\n'}"
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-06 los dos lectores" | grep -qi -- "$FILTRO"; then
  div93=0; primero93=''
  for f93 in "${DOCS93[@]}"; do
    a93="$(bash "$LEE93" "$HOOKS_DIR" lib "$f93" 2>/dev/null)"
    b93="$(bash "$LEE93" "$HOOKS_DIR" awk "$f93" 2>/dev/null)"
    if [ -z "$a93" ] || [ "$a93" != "$b93" ]; then div93=$((div93 + 1)); [ -n "$primero93" ] || primero93="${f93##*/}"; fi
  done
  if [ "${#DOCS93[@]}" -lt 7 ]; then
    echo "  FAIL  REQ-023 CA-06 el corpus de lectores cosechó ${#DOCS93[@]} documentos y el lector declara $i93 campos: la comparación no mediría nada"; FAIL=$((FAIL+1))
  elif [ "$div93" -eq 0 ]; then
    echo "  PASS  REQ-023 CA-06 0 divergencias entre hooks/lib.sh y hooks/campos-req.awk sobre ${#DOCS93[@]} documentos ($i93 con un invisible, uno por campo del lector)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-06 $div93 de ${#DOCS93[@]} documentos divergen entre los dos lectores (el primero, $primero93): la guarda dejó de ser OBSERVACIONAL"; FAIL=$((FAIL+1))
  fi
fi
# Y `tools/arnes-paralelo.sh`, el cuarto lector: `Archivos:` queda FUERA de la constante a
# propósito, así que la guarda CALLA sobre ella — y eso NO es un fail-open, porque la ausencia
# de ese campo se resuelve del lado que CIERRA en su propio lector: responde `SIN DECLARAR`,
# colisiona con todos y sale != 0. Sin este caso, el silencio de la guarda ahí no estaría
# medido y sería un hueco en vez de una frontera.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-06 el cuarto lector" | grep -qi -- "$FILTRO"; then
  mk93 REQ-995 "# REQ-995
Estado: en-revisión
${BOM93}Archivos: hooks/lib.sh"
  mk93 REQ-996 '# REQ-996
Estado: en-revisión
Archivos: hooks/lib.sh'
  sal93="$(bash "$REPO93/tools/arnes-paralelo.sh" --proyecto "$PROJ" REQ-995 REQ-996 2>&1)"; rc93=$?
  if [ "$rc93" -ne 0 ] && printf '%s' "$sal93" | grep -qi 'SIN DECLARAR'; then
    echo "  PASS  REQ-023 CA-06 el invisible sobre 'Archivos:' NO lo ve la guarda y arnes-paralelo responde SIN DECLARAR con rc=$rc93: fail-closed en su propio lector"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-06 el invisible sobre 'Archivos:' dejó a arnes-paralelo en rc=$rc93 sin decir SIN DECLARAR: la frontera sería un hueco"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-07 · EL INFORME NO CALLA SOBRE LO QUE LA PUERTA SE NIEGA A MEDIR ----------
# Medido en la ventana anterior por qué hace falta: sobre el caso peligroso equivalente el
# informe respondía «Ningún valor anómalo» con rc=0 (REQ-016, H-03). Aquí el diff TAMPOCO lo
# muestra, así que el informe es la ÚNICA superficie donde una persona puede verlo antes de
# intentar cerrar. Por la VÍA ÚNICA por la que ya reporta anomalías: salida != 0.
rm -f "$PROJ/requirements"/*.md
mk93 REQ-997 "# REQ-997
Estado: completado
${BOM93}Sensible a seguridad: sí
QA: pendiente
Rigor: ligero"
LP="$PROJ"; LEC="$REPO93/tools/arnes-lectura.sh"; ERRLOG="$RAIZ/errlec93-$BASHPID.txt"
lec_check "REQ-023 CA-07 el informe nombra el REQ, la clave y el byte en hexadecimal, y sale 1" \
  1 'REQ-997' si
lec_check "REQ-023 CA-07 ...y dice la consecuencia: la puerta de cierre DENIEGA" \
  1 'la puerta de cierre DENIEGA' si
# EL CASO QUE EL INFORME SE COMÍA: si el carácter cae sobre la clave del ESTADO, el informe
# descartaba el archivo como «nota, no REQ» y salía con rc=0 sobre el documento más peligroso
# que hay. Por eso el aviso va ANTES de ese descarte.
rm -f "$PROJ/requirements"/*.md
mk93 REQ-998 "# REQ-998
${BOM93}Estado: completado
Sensible a seguridad: sí
QA: pendiente"
lec_check "REQ-023 CA-07 el invisible sobre la clave del ESTADO no se cuenta como «archivo sin Estado»: sale 1 y lo nombra" \
  1 'REQ-998' si
# Y EL CONTROL EN LA OTRA DIRECCIÓN: sin el carácter, el informe no inventa una anomalía. Un
# informe que grita por lo inofensivo deja de leerse, y entonces tampoco se lee lo que sí importa.
rm -f "$PROJ/requirements"/*.md
mk93 REQ-999 '# REQ-999
Estado: completado
Módulo: hooks (el escáner)
Versión destino: 1.34.0
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico'
lec_check "REQ-023 CA-07 control: sin el carácter —y con 'Módulo:' y 'Versión destino:'— el informe sale 0 y no inventa nada" \
  0 'cabecera no medible' no

# ---------- CA-12 · LA COLA NO GANA UNA TRANSCRIPCIÓN, Y CUENTA LO MISMO ----------
# `arnes_cola_pendientes` tiene su PROPIA noción de comentario, de grano de LÍNEA, declarada
# por escrito en la cabecera de `arnes_sin_cita` como frontera deliberada. Unificarla cambiaría
# el CONTEO —`### Real <!-- nota -->` pasa a contar— y un cambio de conteo en la cola es un
# cambio de veredicto en la puerta, es decir un cambio del contrato de REQ-009 (CA-04/CA-07),
# que está `completado`. Quien implemente esta guarda está editando esa misma función y ese
# mismo archivo en la misma ventana, así que la deriva se caza MIDIENDO y no recordando.
#
# LA NO-REGRESIÓN ESTÁ ANCLADA a ESTE corpus y a ESTA comparación, y no es la afirmación
# abierta «la cola nunca cambia su conteo»: `REQ-024 CA-08/CA-09` la cambia donde declara
# cambiarla, con su ADR, y con el anclaje no rompe nada de aquí.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-12" | grep -qi -- "$FILTRO"; then
  if [ "$HER93_OK" != si ]; then
    echo "  SKIP  REQ-023 CA-12 la cola cuenta exactamente lo mismo que la versión heredada  no hay línea base v1.33.0 ($REGHER93)"
  else
    COLA93="$RAIZ/cola93-$BASHPID.sh"
    cat > "$COLA93" <<'CUENTA93'
#!/usr/bin/env bash
set -uo pipefail
. "$1" >/dev/null 2>&1 || exit 3
if arnes_cola_pendientes "$2"; then printf '%s|rc=0\n' "$ARNES_COLA"; else printf '%s|rc=%s\n' "${ARNES_COLA:-}" "$?"; fi
CUENTA93
    # El corpus de colas: las formas que el banco ya ejerce, incluidas las dos que REQ-024
    # cambiará a propósito (el rango sin cerrar y el cierre huérfano). Aquí se comprueba que
    # ESTE REQ no las movió.
    CQ93=(); cq93() { CQ93+=("$1"); }
    cq93 '## Pendientes

## Resueltas'
    cq93 '## Pendientes

### [2026-09-09] (dev) — una

### [2026-09-09] (dev) — dos

## Resueltas'
    cq93 '## Pendientes

### Real <!-- nota al margen -->

## Resueltas'
    cq93 '## Pendientes

<!--
### comentada
-->

## Resueltas'
    cq93 '## Pendientes

<!-- rango que abre y no cierra
### tragada

## Resueltas'
    cq93 '## Pendientes

### Migrar A --> B

## Resueltas'
    cq93 '## Pendientes
### pegada al encabezado
## Resueltas'
    mal93=0; n93=0
    for c93 in "${CQ93[@]}"; do
      n93=$((n93 + 1))
      printf '%s\n' "$c93" > "$PROJ/PENDING_APPROVAL.md"
      x93="$(bash "$COLA93" "$HOOKS_DIR/lib.sh"  "$PROJ/PENDING_APPROVAL.md" 2>/dev/null)"
      y93="$(bash "$COLA93" "$HER93/hooks/lib.sh" "$PROJ/PENDING_APPROVAL.md" 2>/dev/null)"
      [ -n "$x93" ] && [ "$x93" = "$y93" ] || mal93=$((mal93 + 1))
    done
    printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
    if [ "$n93" -ge 5 ] && [ "$mal93" -eq 0 ]; then
      echo "  PASS  REQ-023 CA-12 la cola cuenta lo mismo y devuelve el mismo rc en las $n93 formas del corpus, contra v1.33.0"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-023 CA-12 $mal93 de $n93 formas de la cola cambiaron de conteo o de rc: esta guarda movió lo que REQ-009 contrata"; FAIL=$((FAIL+1))
    fi
  fi
fi


rm -rf "$HER93"
