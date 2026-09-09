# Sección 28 del banco — 28-rotacion-seccion-1-la-historia
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=32
PISO_AUTONOMO_SECCION=87  # 9 preámbulo + 42 maquinaria compartida duplicada + 36 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-004: rotar UNA seccion; el contrato no se toca -------------------------------
  seccion_nueva "Rotacion de UNA seccion (la historia se archiva, el contrato no):"

# rsec_proj <activo> <conservar-json> <umbral> <orden> [archivo_dir] [seccion]
rsec_proj() {
  RP2="$(mktemp -d)"; mkdir -p "$RP2/.arnes" "$RP2/requirements"
  jq -n --argjson a "$1" --argjson c "$2" --argjson u "$3" --arg o "$4" \
        --arg ad "${5:-}" --arg se "${6:-## Historial de cambios}" \
    '{agentes:{agente_codigo:"desarrollador"}, requirements_dir:"requirements",
      rotacion:{activo:$a, artefactos:[
        ({glob:"requirements/REQ-*.md", seccion:$se, umbral_bytes:$u, orden:$o}
         + (if $c == null then {} else {conservar_entradas:$c} end)
         + (if $ad == "" then {} else {archivo_dir:$ad} end))]}}' > "$RP2/.arnes/config.json"
}
# rsec_req <archivo> <n entradas> [crlf]
rsec_req() {
  local f="$1" n="$2" crlf="${3:-}" i
  { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: (ninguno)\nRigor: critico\n\n' "$(basename "$f" .md)"
    printf '## Criterios de aceptación\n- CA-01 — el contrato, que no se rota jamas\n\n'
    printf '## Historial de cambios\nPreambulo de la seccion.\n\n'
    for i in $(seq -w 1 "$n"); do
      printf -- '- 2026-01-%s: entrada %s con texto suficiente para pasar del umbral declarado\n' "$i" "$i"
      printf '  continuacion indentada de %s\n| tabla | fila |\n' "$i"
    done
    printf '\n## Notas / alcance\nfinal intacto\n'
  } > "$f"
  [ -n "$crlf" ] && { sed 's/$/\r/' "$f" > "$f.crlf" && mv "$f.crlf" "$f"; }
  return 0
}
rsec_corre() {
  local json
  json="$(CLAUDE_PROJECT_DIR="$1" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$1" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
}
rsec_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
rsec_cnt() {   # <patron> <archivo> -> cuenta, y 0 si el archivo no existe
  local n
  n="$(grep -c -- "$1" "$2" 2>/dev/null)" || n=0
  [ -n "$n" ] || n=0
  printf '%s' "$n"
}
rsec_ent() { rsec_cnt '^- 2026' "$1"; }

# CA-01: apagada, no toca nada. Reestructurar el documento de una persona no puede ser
# el comportamiento por defecto.
rsec_proj false 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-400.md" 60
cp "$RP2/requirements/REQ-400.md" "$RP2/antes.md"
rsec_corre "$RP2"; rsec_corre "$RP2"
rsec_check "CA-01 apagada: dos paradas y ni un byte cambia" "iguales-no" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-400.md" && echo iguales || echo distintos)-$([ -d "$RP2/requirements/historial" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-02/03/04/07/19: el reparto, y sobre todo lo que NO se toca.
rsec_proj true 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-401.md" 60
cp "$RP2/requirements/REQ-401.md" "$RP2/antes.md"
rsec_corre "$RP2"; RSEC_RC=$?
rsec_check "CA-02 quedan 20 entradas y 40 se archivan" "20-40" \
  "$(rsec_ent "$RP2/requirements/REQ-401.md")-$(rsec_ent "$RP2/requirements/historial/REQ-401.md")"
rsec_check "CA-02 un solo puntero al archivo" "1" "$(rsec_cnt 'historial/REQ-401.md' "$RP2/requirements/REQ-401.md")"
rsec_check "CA-03 la cabecera y las demas secciones, byte a byte" "iguales" \
  "$(cmp -s <(sed '/^## Historial de cambios$/,/^## Notas/{/^## Notas/!d}' "$RP2/antes.md") \
            <(sed '/^## Historial de cambios$/,/^## Notas/{/^## Notas/!d}' "$RP2/requirements/REQ-401.md") && echo iguales || echo distintos)"
# CA-04 es una invariante de SEGURIDAD, no una comodidad: el hook escribe en
# requirements/ desde una parada, fuera de la via que vigila guard-completado. Una
# rotacion que pudiera tocar la cabecera seria un camino para cerrar o firmar un REQ
# sin puerta alguna.
rsec_check "CA-04 los campos de la cabecera, intactos" "$(sed -n '2,7p' "$RP2/antes.md" | md5sum)" \
  "$(sed -n '2,7p' "$RP2/requirements/REQ-401.md" | md5sum)"
rsec_check "CA-07 ninguna continuacion queda huerfana" "60-60" \
  "$(( $(rsec_cnt 'continuacion indentada' "$RP2/requirements/REQ-401.md") + $(rsec_cnt 'continuacion indentada' "$RP2/requirements/historial/REQ-401.md") ))-$(( $(rsec_ent "$RP2/requirements/REQ-401.md") + $(rsec_ent "$RP2/requirements/historial/REQ-401.md") ))"
rsec_check "CA-18 la entrada mas reciente se queda en el documento" "1" \
  "$(rsec_cnt '2026-01-60' "$RP2/requirements/REQ-401.md")"
rsec_check "CA-19 el puntero dice cuantas quedan" "1" \
  "$(rsec_cnt 'quedan las 20 más recientes' "$RP2/requirements/REQ-401.md")"
rsec_check "el hook sale 0 (una parada no se bloquea)" "0" "$RSEC_RC"
# CA-05: idempotencia. Sin ella, cada parada se lleva otro trozo del documento.
rsec_corre "$RP2"; rsec_corre "$RP2"
rsec_check "CA-05 idempotente: tres paradas, mismo reparto y un solo puntero" "20-40-1" \
  "$(rsec_ent "$RP2/requirements/REQ-401.md")-$(rsec_ent "$RP2/requirements/historial/REQ-401.md")-$(rsec_cnt 'historial/REQ-401.md' "$RP2/requirements/REQ-401.md")"
rm -rf "$RP2"

# CA-06: el umbral manda sobre el numero de entradas.
rsec_proj true 20 9999999 nuevo-al-final
rsec_req "$RP2/requirements/REQ-402.md" 200
rsec_corre "$RP2"
rsec_check "CA-06 bajo el umbral no se toca nada, haya las entradas que haya" "200-no" \
  "$(rsec_ent "$RP2/requirements/REQ-402.md")-$([ -d "$RP2/requirements/historial" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-09/CA-10: un archivo que casa el glob pero no tiene la seccion no se toca; y cada
# REQ rota a SU propio archivo.
rsec_proj true 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-403.md" 60
rsec_req "$RP2/requirements/REQ-404.md" 60
printf '# REQ-405\nEstado: en-revisión\n\n## Criterios\n- sin seccion de historia\n' > "$RP2/requirements/REQ-405.md"
cp "$RP2/requirements/REQ-405.md" "$RP2/antes405.md"
rsec_corre "$RP2"
rsec_check "CA-09 sin la seccion declarada, el archivo no se toca" "iguales-no" \
  "$(cmp -s "$RP2/antes405.md" "$RP2/requirements/REQ-405.md" && echo iguales || echo distintos)-$([ -e "$RP2/requirements/historial/REQ-405.md" ] && echo si || echo no)"
rsec_check "CA-10 cada REQ a su propio archivo de historia" "40-40-0" \
  "$(rsec_ent "$RP2/requirements/historial/REQ-403.md")-$(rsec_ent "$RP2/requirements/historial/REQ-404.md")-$(( $(rsec_cnt 'entrada 01 con texto' "$RP2/requirements/historial/REQ-403.md") - 1 ))"
rm -rf "$RP2"

# CA-11: CRLF. La fuga medida en 1.27.0 —3 -> 6 -> 9 en tres pasadas— no puede volver.
rsec_proj true 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-406.md" 60 crlf
rsec_corre "$RP2"; rsec_corre "$RP2"; rsec_corre "$RP2"
rsec_check "CA-11 CRLF: tres paradas, mismo reparto y sin duplicar" "20-40" \
  "$(rsec_ent "$RP2/requirements/REQ-406.md")-$(rsec_ent "$RP2/requirements/historial/REQ-406.md")"
rm -rf "$RP2"

# CA-13: contencion LEXICA. `../fuera` no se escribe, y el origen no se toca.
rsec_proj true 20 1000 nuevo-al-final ../fuera
rsec_req "$RP2/requirements/REQ-407.md" 60
cp "$RP2/requirements/REQ-407.md" "$RP2/antes.md"
rsec_corre "$RP2"
rsec_check "CA-13 archivo_dir con .. no escribe nada y no toca el origen" "iguales-no" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-407.md" && echo iguales || echo distintos)-$([ -e "$RP2/../fuera" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-14: contencion FISICA. Ruta relativa limpia que, RESUELTA, sale del proyecto por un
# enlace simbolico. La misma regla que `estado_derivado.archivo` desde 1.29.1.
if ln -s /tmp /tmp/arnes-enlace-test-$$ 2>/dev/null; then
  rm -f /tmp/arnes-enlace-test-$$
  rsec_proj true 20 1000 nuevo-al-final salida
  FUERA="$(mktemp -d)"
  ln -s "$FUERA" "$RP2/salida"
  rsec_req "$RP2/requirements/REQ-408.md" 60
  cp "$RP2/requirements/REQ-408.md" "$RP2/antes.md"
  rsec_corre "$RP2"
  rsec_check "CA-14 archivo_dir que sale por un enlace simbolico -> nada fuera" "iguales-0" \
    "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-408.md" && echo iguales || echo distintos)-$(ls -1 "$FUERA" | wc -l | tr -d ' ')"
  rm -rf "$RP2" "$FUERA"
else
  echo "  SKIP  CA-14 contencion fisica: esta plataforma no crea enlaces simbolicos"; SKIP=$((SKIP+1))
fi

# CA-15: archivo_dir dentro del proyecto -> ahi, y no junto al documento.
rsec_proj true 20 1000 nuevo-al-final historial-global
rsec_req "$RP2/requirements/REQ-409.md" 60
rsec_corre "$RP2"
rsec_check "CA-15 archivo_dir interno: escribe ahi y no junto al documento" "40-no" \
  "$(rsec_ent "$RP2/historial-global/REQ-409.md")-$([ -e "$RP2/requirements/historial/REQ-409.md" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-16: manifiesto malformado -> se ignora esa entrada, nada se toca, la parada sale 0.
rsec_proj true '"veinte"' 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-410.md" 60
cp "$RP2/requirements/REQ-410.md" "$RP2/antes.md"
rsec_corre "$RP2"; RSEC_RC=$?
rsec_check "CA-16 conservar_entradas no numerico: se ignora y sale 0" "iguales-0" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-410.md" && echo iguales || echo distintos)-$RSEC_RC"
rm -rf "$RP2"

# CA-20: el nombre de la seccion se compara EXACTO, nunca por prefijo. Declarar
# `## Historial` no puede llevarse por delante `## Historial de cambios`: la rotacion
# escribiria en una seccion que el proyecto no nombro.
rsec_proj true 20 1000 nuevo-al-final "" "## Historial"
rsec_req "$RP2/requirements/REQ-411.md" 60
cp "$RP2/requirements/REQ-411.md" "$RP2/antes.md"
rsec_corre "$RP2"
rsec_check "CA-20 '## Historial' no casa '## Historial de cambios' (exacto, no prefijo)" "iguales" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-411.md" && echo iguales || echo distintos)"
# QA 1.31.0: HALLAZGO QA-102 — REQ-004 CA-09 pide dos cosas y solo se cumple una: no
# rotar (arriba) Y DECIRLO. Un artefacto declarado cuya seccion no existe es un error de
# mapeo que hay que ver; hoy `arnes_rotar_seccion` sale con `return 0` en silencio.
rsec_check "QA-102 CA-09: la seccion declarada no encontrada emite arnes_warn" "hay-aviso" \
  "$( [ -s "$ERRLOG" ] && echo hay-aviso || echo silencio)"
# DEV 1.31.0 v2: un aviso que no dice CUAL archivo ni QUE seccion no obliga a nadie a
# mirar nada. CA-09 pide los dos datos, porque el error que describe es de MAPEO: alguien
# escribio un nombre de seccion y el documento tiene otro.
rsec_check "DEV 1.31.0 v2: QA-102 el aviso nombra el archivo y la seccion declarada" "si-si" \
  "$(grep -q 'REQ-411.md' "$ERRLOG" && echo si || echo no)-$(grep -q '## Historial' "$ERRLOG" && echo si || echo no)"
rm -rf "$RP2"

# DEV 1.31.0 v2: la SEGUNDA MITAD de CA-09 —el bloque derivado lo refleja—. Se prueba por
# `stop.sh`, que es como corre en produccion: la rotacion deja el dato y el bloque lo
# ensena sin volver a mirar el disco (por eso stop.sh rota ANTES de derivar).
rsec_proj true 20 1000 nuevo-al-final "" "## Historial"
mkdir -p "$RP2/docs"
printf '# ESTADO\n\n## Fase\nlo que escribio una persona\n' > "$RP2/docs/ESTADO.md"
rsec_req "$RP2/requirements/REQ-412.md" 60
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v2: QA-102 CA-09 el bloque derivado refleja la seccion no encontrada" "si-si" \
  "$(grep -q 'no contienen la sección declarada' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'REQ-412.md' "$RP2/docs/ESTADO.md" && echo si || echo no)"
rsec_check "DEV 1.31.0 v2: QA-102 lo que escribio una persona sigue fuera de los marcadores" "1" \
  "$(grep -c 'lo que escribio una persona' "$RP2/docs/ESTADO.md")"
# CONTROL: cuando la seccion SI existe no se dice nada. Un bloque que informa de lo que no
# pasa deja de servir para saber donde quedamos.
rm -rf "$RP2"
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
rsec_req "$RP2/requirements/REQ-413.md" 60
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>/dev/null
rsec_check "DEV 1.31.0 v2: QA-102 control: con la seccion encontrada el bloque no dice nada" "no-20" \
  "$(grep -q 'no contienen la sección declarada' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(rsec_ent "$RP2/requirements/REQ-413.md")"
rm -rf "$RP2"

# QA 1.31.0 v2: HALLAZGO QA-109 — la seccion SI existe, pero no tiene ni una entrada
# reconocible: esta hecha SOLO de filas de tabla. No se rota nada y NO SE DICE NADA — el
# mismo silencio que CA-09 declara inaceptable para la seccion que no existe, en la rama
# hermana. No es hipotetico: el `## Historial de cambios` de los REQ de ESTE repositorio es
# una tabla. El caso fijaba la conducta MEDIDA (silencio) y ya cambio una vez, en 1.31.0 v3,
# cuando se decidio avisar.
#
# DEV REQ-026 CA-08: y cambia OTRA VEZ, porque el criterio que lo ordena volvio a cambiar.
# Estas 60 filas no llevan fila separadora delante, asi que ya no son "una seccion sin
# entradas": son una TABLA A MEDIO HACER, y de esa rama —la tercera— responde CA-08. Lo que
# el caso exige sigue siendo lo mismo palabra por palabra (no rotar, avisar, distinguir la
# rama), y sobre eso este REQ no relaja nada: lo unico que se mueve es CUAL de las tres
# ramas responde. La rama "sin entradas" de verdad —cabecera y separadora sin ninguna fila—
# la prueba el REQ-418 de mas abajo, y su caso positivo, la seccion 28-3.
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
{ printf '# REQ-414\nEstado: en-revisión\n\n## Historial de cambios\n\n'
  i=1; while [ "$i" -le 60 ]; do
    printf '| 2026-01-01 | fila de tabla numero %s con relleno de sobra para pasar del umbral de mil bytes | causa | — |\n' "$i"
    i=$((i+1))
  done
} > "$RP2/requirements/REQ-414.md"
cp "$RP2/requirements/REQ-414.md" "$RP2/antes414.md"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
# DEV 1.31.0 v3 (QA-109): la conducta que este caso fijaba —silencio— era la medida, no
# la querida. El criterio cambia: NO ROTAR sigue igual (sin un limite seguro, cortar parte
# una entrada en dos), pero se AVISA, como en la rama que ya avisaba.
rsec_check "DEV REQ-026 CA-08: filas de tabla sin separadora: NO rota, pero AVISA" "iguales-aviso" \
  "$(cmp -s "$RP2/antes414.md" "$RP2/requirements/REQ-414.md" && echo iguales || echo distintos)-$(grep -q 'REQ-414.md' "$ERRLOG" && echo aviso || echo silencio)"
# Los casos son ERRORES DE MAPEO DISTINTOS y piden acciones distintas: en uno se corrige el
# nombre de la seccion en el manifiesto, en otro el formato de la seccion o la expectativa de
# rotarla. Un aviso que no los distinga manda a mirar el archivo equivocado, asi que se exige
# que el texto diga que la seccion SI esta, que nombre la averia de ESTA rama —la estructura
# de tabla ambigua (REQ-026 CA-08)— y que NO reutilice el texto de las otras dos.
rsec_check "DEV REQ-026 CA-08: el aviso DISTINGUE 'tabla ambigua' de 'sin entradas' y de 'no existe'" "si-si-no-no" \
  "$(grep -q 'ESTRUCTURA DE TABLA es AMBIGUA' "$ERRLOG" && echo si || echo no)-$(grep -q "SI contiene la seccion '## Historial de cambios'" "$ERRLOG" && echo si || echo no)-$(grep -q 'ENTRADA reconocible' "$ERRLOG" && echo si || echo no)-$(grep -q 'NO contiene la seccion' "$ERRLOG" && echo si || echo no)"
# Y la segunda mitad de CA-09, igual que en las ramas hermanas: el bloque derivado lo
# refleja, con el archivo de ejemplo, sin volver a mirar el disco. Aqui es lo que evita que
# el fail-closed sea invisible: el stderr de una parada no sobrevive a la sesion, y sin esta
# linea la seccion se queda sin rotar durante meses sin que nadie se entere.
rsec_check "DEV REQ-026 CA-08: el bloque derivado refleja la estructura de tabla ambigua" "si-si-no" \
  "$(grep -q 'estructura de tabla ambigua' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'REQ-414.md' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'sin ninguna entrada reconocible' "$RP2/docs/ESTADO.md" && echo si || echo no)"
rm -rf "$RP2"

# CONTROL de los tres de arriba: con la MISMA seccion y el MISMO umbral, pero con
# entradas de verdad, no se avisa nada y se rota. Sin este control, un aviso emitido
# siempre —o una rotacion rota— pasaria por acierto.
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
rsec_req "$RP2/requirements/REQ-415.md" 60
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v3: QA-109 control: con entradas de verdad ni aviso ni mencion en el bloque" "silencio-no-20" \
  "$(grep -q 'ENTRADA reconocible' "$ERRLOG" && echo aviso || echo silencio)-$(grep -q 'sin ninguna entrada reconocible' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(rsec_ent "$RP2/requirements/REQ-415.md")"
rm -rf "$RP2"

# DEV 1.31.0 v4 (CA-36 de REQ-004): LOS DOS CONTROLES QUE FALTABAN. El criterio declara
# tres y solo uno tenia caso. Sin el de abajo, un aviso emitido SIEMPRE pasaria por acierto.
#
# (i) POR DEBAJO DEL UMBRAL NO SE AVISA. La rotacion ni siquiera mira la seccion de un
# archivo que no pesa lo suficiente, asi que no hay error de mapeo que contar: un bloque
# que informa de lo que no pasa deja de servir para saber donde quedamos.
# La MISMA seccion sin entradas del caso de arriba (una tabla), pero con solo 3 filas: no
# llega al umbral. El aviso es para lo que se quiso rotar y no se rotó, no ruido de cada
# parada (CA-06 intacto).
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
{ printf '# REQ-416\nEstado: en-revisión\n\n## Historial de cambios\n\n'
  i=1; while [ "$i" -le 3 ]; do printf '| 2026-01-01 | fila %s | causa | — |\n' "$i"; i=$((i+1)); done
} > "$RP2/requirements/REQ-416.md"
cp "$RP2/requirements/REQ-416.md" "$RP2/antes416.md"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v4: CA-36 bajo el umbral: ni se rota, ni se avisa, ni el bloque lo dice" "iguales-silencio-no" \
  "$(cmp -s "$RP2/antes416.md" "$RP2/requirements/REQ-416.md" && echo iguales || echo distintos)-$(grep -q 'REQ-416.md' "$ERRLOG" && echo aviso || echo silencio)-$(grep -qE 'no contienen la sección declarada|sin ninguna entrada reconocible' "$RP2/docs/ESTADO.md" && echo si || echo no)"
rm -rf "$RP2"

# (ii) LAS DOS AVERIAS A LA VEZ: dos avisos DISTINTOS y dos lineas DISTINTAS en el bloque.
# Son errores de mapeo distintos y piden acciones distintas —alli el nombre de la seccion
# en el manifiesto, aqui el formato de la seccion—, asi que no pueden sumarse en un solo
# contador ni compartir texto. Cada rama por separado ya tenia caso; su CONVIVENCIA no, y
# es donde una sumaria a la otra sin que nadie lo viera.
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
{ printf '# REQ-417\nEstado: en-revisión\n\n## Otra seccion cualquiera\n\n'
  i=1; while [ "$i" -le 40 ]; do printf -- '- relleno %s para pasar del umbral de mil bytes sin traer la seccion declarada\n' "$i"; i=$((i+1)); done
} > "$RP2/requirements/REQ-417.md"
# DEV REQ-026 CA-08/CA-09: la seccion de REQ-418 se REESCRIBE para que siga siendo la rama
# "sin entradas". Antes eran 40 filas sin separadora y esa forma ya la responde CA-08, asi
# que la convivencia que este caso mide se habria mudado sola de par y la rama "sin
# entradas" se habria quedado sin ninguna. Ahora es lo que de verdad no tiene ni una
# entrada: prosa de relleno para pasar del umbral, y una tabla con cabecera y separadora
# CORRECTAS y NINGUNA fila de datos (CA-09).
{ printf '# REQ-418\nEstado: en-revisión\n\n## Historial de cambios\n'
  i=1; while [ "$i" -le 40 ]; do printf 'prosa de relleno %s para pasar del umbral de mil bytes sin traer ni una entrada\n' "$i"; i=$((i+1)); done
  printf '\n| Fecha | Causa |\n|---|---|\n'
} > "$RP2/requirements/REQ-418.md"
cp "$RP2/requirements/REQ-417.md" "$RP2/antes417.md"; cp "$RP2/requirements/REQ-418.md" "$RP2/antes418.md"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v4: CA-36 las dos averias juntas: dos avisos, uno por rama" "si-si" \
  "$(grep -q 'REQ-417.md' "$ERRLOG" && echo si || echo no)-$(grep -q 'REQ-418.md' "$ERRLOG" && echo si || echo no)"
rsec_check "DEV 1.31.0 v4: CA-36 las dos averias juntas: dos lineas DISTINTAS en el bloque" "si-si" \
  "$(grep -q 'no contienen la sección declarada' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'sin ninguna entrada reconocible' "$RP2/docs/ESTADO.md" && echo si || echo no)"
rsec_check "DEV 1.31.0 v4: CA-36 y con las dos averias no se rota NADA" "iguales-iguales" \
  "$(cmp -s "$RP2/antes417.md" "$RP2/requirements/REQ-417.md" && echo iguales || echo distintos)-$(cmp -s "$RP2/antes418.md" "$RP2/requirements/REQ-418.md" && echo iguales || echo distintos)"
rm -rf "$RP2"

