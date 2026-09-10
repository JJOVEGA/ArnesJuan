# Sección 39 (1 de 5) del banco — 39-caracter-invisible-1-la-puerta
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-023 · SEC-047 (mitad 1). LA PUERTA: `CA-01` (deny por MEDIBILIDAD, citando la línea y
# el byte en forma imprimible), `CA-02` (el DOMINIO de campos cuya ausencia ABRE, DERIVADO
# midiendo en cada corrida), `CA-05` (veredicto y motivo invariantes al locale, que llegó de la
# parte 2 en 1.34.0), `CA-08` (las dos filas medidas + los controles en las dos direcciones) y
# `CA-11` (la frontera con lo que una regla contratada sí retira).
#
# EL DEFECTO, medido por el auditor ejecutando la puerta real (R-012) e IDÉNTICO en `v1.30.3`,
# `v1.31.0`, `v1.32.0`, `v1.32.1` y `4f647c7`: un carácter que no se ve y que el normalizador
# no retira **borra un campo** de la cabecera, y para todo campo cuya AUSENCIA la puerta
# resuelve del lado que abre, borrarlo es abrirla. `hooks/guard-completado.sh` resolvía la
# ausencia de `Hallazgos abiertos:` como «no hay hallazgos».
#
# FAIL-BEFORE, Y CONTRA QUÉ ÁRBOL. Los casos marcados «(era ALLOW)» miden contra `4f647c7` —el
# árbol inmediatamente anterior a esta guarda—, no contra una versión más vieja: un
# fail-before contra la versión anterior a la regresión pasa en verde y miente. NO se
# materializa aquí desde un tag, y el motivo va escrito en vez de omitido: esa ruta es la que
# `SEC-048` describe (`docs/seguridad/registro-seguridad.md:3689`, **abierto**), y el contrato
# de `CA-08` declara que mientras ese gate humano no esté, el fail-before no se mide dentro del
# banco. Reproducible a mano, y así se midió (tabla en `docs/arnes/req-023-coste-y-dominio.md`
# §7):
#   git archive 4f647c7 hooks | tar -x -C /tmp/her23 --strip-components=1
#   ARNES_HOOKS_DIR=/tmp/her23 bash tests/escenarios/hooks/run.sh 'secciones/39-*1*.sh'
CASOS_ESPERADOS_SECCION=21
PISO_AUTONOMO_SECCION=148  # 30 preámbulo (líneas 1-30) + 8 maquinaria compartida duplicada (mk39/w39/e39 y BOM39/ZWSP39/C3_39, líneas 32-39) + 110 bloque indivisible mayor (CA-02 entero: la derivación del dominio, sus dos guardas de anti-vacuidad y el barrido con el carácter, líneas 97-206) · REQ-014 CA-18
seccion_nueva "Carácter invisible (1/3): la puerta deniega por MEDIBILIDAD (REQ-023 · SEC-047):"

# --- Maquinaria: los tres caracteres y las tres bocas -------------------------------
BOM39=$'\xef\xbb\xbf'      # U+FEFF, el que PowerShell añade al redirigir
ZWSP39=$'\xe2\x80\x8b'     # U+200B, espacio de anchura cero
C3_39=$'\xc3'              # arranque UTF-8 sin su continuación
mk39() { printf '%s\n' "$2" > "$PROJ/requirements/$1.md"; }
w39()  { emite_write "$PROJ/requirements/$1.md" "$2"; }
e39()  { emite_edit_real "$PROJ/requirements/$1.md" "$2" "$3"; }

# ---------- CA-08 (i) · LAS DOS FILAS MEDIDAS DE SEC-047 ----------
# Son los fixtures concretos que el auditor midió, NO la cobertura de la superficie: quien
# cubre la superficie es CA-02, derivándola. Estas dos no la agotan y no pretenden hacerlo.
mk39 REQ-980 '# REQ-980
Estado: en-revisión'
check_motivo "REQ-023 CA-08 fila 1: BOM delante de 'Sensible a seguridad: sí' con 'Rigor: ligero' -> deny por medibilidad (era ALLOW)" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
${BOM39}Sensible a seguridad: sí
QA: pendiente
Seguridad: pendiente
Rigor: ligero
")"
# ...y el motivo tiene que decir QUÉ campo se perdió y CON QUÉ byte, en forma imprimible: un
# carácter invisible dentro del motivo deja a la persona buscando texto que su editor no le
# muestra. Es la misma lección que el CR escrito `\r`.
check_motivo "REQ-023 CA-01 ...y el motivo nombra el campo y el byte en hexadecimal, no el carácter crudo" \
  '\\xef\\xbb\\xbfSensible a seguridad' guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
${BOM39}Sensible a seguridad: sí
QA: pendiente
Seguridad: pendiente
Rigor: ligero
")"
check_motivo "REQ-023 CA-08 fila 2: U+200B delante de 'Hallazgos abiertos:' con un hallazgo 'contrato' -> deny por medibilidad (era ALLOW)" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
${ZWSP39}Hallazgos abiertos: SEC-999 (contrato)
Sensible a seguridad: no
QA: aprobado
Rigor: estandar
")"

# ---------- CA-08 (ii) · CONTROL NEGATIVO: sin el carácter decide IGUAL QUE ANTES ----------
# Sin esto, los dos casos de arriba podrían estar denegando por cualquier otra cosa y la
# guarda sería un veto encubierto. La misma cabecera sin el carácter deniega por SU PROPIO
# motivo —el veredicto de QA—, y el motivo se cita para que se vea que no es el de la guarda.
check_motivo "REQ-023 CA-08 (ii) control negativo: la MISMA cabecera sin el carácter deniega por su propio motivo (el veredicto de QA)" \
  "el veredicto de QA es 'pendiente'" guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
Sensible a seguridad: sí
QA: pendiente
Seguridad: pendiente
Rigor: ligero
")"
check "REQ-023 CA-08 (ii) control negativo: y la fila 2 sin el carácter también deniega por el hallazgo" deny \
  guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
Hallazgos abiertos: SEC-999 (contrato)
Sensible a seguridad: no
QA: aprobado
Rigor: estandar
")"

# ---------- CA-08 (iii) · CONTROL POSITIVO: la guarda tiene que tener DIENTES ----------
# Una guarda que sólo deniega no se distingue de un veto. Un REQ cuyos veredictos SÍ autorizan
# el cierre y cuya cabecera no lleva ningún carácter de la clase CIERRA.
check "REQ-023 CA-08 (iii) control positivo: todo en verde y sin ningún carácter de la clase -> allow" allow \
  guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico
")"

# ---------- CA-01/CA-02 · LA REGLA ES DE MEDIBILIDAD, NO DE VEREDICTO ----------
# Si esto pasara, la guarda estaría juzgando veredictos y no medibilidad — y entonces la vía
# siguiente la rodearía.
check_motivo "REQ-023 CA-02 con TODOS los veredictos en verde, un BOM en 'QA:' deniega igual: es medibilidad, no veredicto" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh "$(w39 REQ-980 "# REQ-980
Estado: completado
Sensible a seguridad: sí
${BOM39}QA: aprobado
Seguridad: aprobado
Rigor: critico
")"
# EL CASO PEOR, y es el que el puntero falso de CA-01 dejaba fuera: el carácter cae sobre la
# clave del ESTADO. La puerta no lee ningún estado, así que sin la segunda mitad de la guarda
# —el estado que esa misma línea declaraba— se resolvería como «aquí no hay transición», y la
# ausencia es justo lo que esta puerta perdona: el documento quedaría diciendo `completado`
# sin que ninguna puerta lo hubiera medido NUNCA.
check_motivo "REQ-023 CA-01 el carácter sobre la clave del ESTADO no se resuelve como «no hay transición» -> deny (era ALLOW)" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh "$(w39 REQ-980 "# REQ-980
${C3_39}Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico
")"

# ---------- CA-02 · EL DOMINIO SE DERIVA MIDIENDO, NO SE ENUMERA ----------
# `SEC-050` nació de que TRES textos firmados describieran esta superficie por enumeración y
# nombraran DOS campos donde la medición encontró CUATRO — y uno de los tres era la
# remediación que el propio auditor había escrito. Así que aquí no se enumera: se deriva, en
# cada corrida, con el procedimiento que CA-02 fija —el campo declarado en el valor que MÁS
# restringe contra el campo AUSENTE, y pertenece a la clase si el segundo ABRE—. Cada campo
# nuevo del lector entra en la clase sin que ningún texto lo diga.
#
# LAS CLAVES SE DERIVAN DEL LECTOR, no se enumeran: `ARNES_CLAVES` de `hooks/lib.sh` es el
# sitio único del conjunto desde REQ-023 CA-06. Y el VALOR más restrictivo de cada una sí vive
# aquí, porque es propio de este caso; si el lector declara un campo al que esta sección no le
# da valor, el caso FALLA en vez de saltárselo en silencio.
# Se lee la constante EJECUTANDO la biblioteca en una sustitución —que es un subshell, así
# que no pisa nada de esta sección— en vez de sacarla con `sed` del texto del archivo: una
# derivación que lee CÓDIGO se rompe con la primera mudanza del código, y es exactamente lo
# que le pasó a `tools/arnes-lectura.sh` con este mismo cambio.
CLAVES39="$(. "$HOOKS_DIR/lib.sh" >/dev/null 2>&1; printf '%s' "${ARNES_CLAVES:-}")"
DOM39=(); FUERA39=(); sin_valor39=''; abren39=0
# La cabecera base de cada campo: la que hace que su valor más restrictivo DENIEGUE. No es la
# misma para todos, y eso no es un atajo: `Seguridad:` sólo se juzga con rigor efectivo
# `critico`, y `Rigor: critico` sólo muerde si hay un veredicto de seguridad que no autoriza.
base39() {   # <clave> -> BASE39 con `@@` donde va la línea del campo, y VAL39
  case "$1" in
    'QA')                   VAL39='pendiente'
      BASE39='Sensible a seguridad: no
Rigor: estandar' ;;
    'Seguridad')            VAL39='pendiente'
      BASE39='Sensible a seguridad: no
QA: aprobado
Rigor: critico' ;;
    'Sensible a seguridad') VAL39='sí'
      BASE39='QA: pendiente
Seguridad: pendiente
Rigor: ligero' ;;
    'Hallazgos abiertos')   VAL39='SEC-999 (contrato)'
      BASE39='Sensible a seguridad: no
QA: aprobado
Rigor: estandar' ;;
    'Rigor')                VAL39='critico'
      BASE39='Sensible a seguridad: no
QA: aprobado
Seguridad: pendiente' ;;
    'Estado')               VAL39='completado'
      BASE39='Sensible a seguridad: no
QA: pendiente
Rigor: estandar' ;;
    *) return 1 ;;
  esac
  return 0
}
# `Estado:` es el campo del que depende que la puerta llegue a juzgar, así que su cabecera lo
# lleva en `@@` y las demás lo llevan fijo.
doc39() {   # <clave> <linea del campo, o vacío> -> el documento entero
  local k="$1" linea="$2"
  if [ "$k" = 'Estado' ]; then printf '# REQ-981\n%s\n%s\n' "$linea" "$BASE39"
  else printf '# REQ-981\nEstado: completado\n%s\n%s\n' "$linea" "$BASE39"; fi
}
dec39() {   # <documento> -> `deny` | `allow`
  local out
  out="$(corre guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-981.md" "$1")")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi
}
mk39 REQ-981 '# REQ-981
Estado: en-revisión'
while IFS= read -r k39; do
  [ -n "$k39" ] || continue
  base39 "$k39" || { sin_valor39="$k39"; continue; }
  if [ "$(dec39 "$(doc39 "$k39" "$k39: $VAL39")")" = deny ] &&
     [ "$(dec39 "$(doc39 "$k39" '')")" = allow ]; then
    DOM39+=("$k39"); abren39=$((abren39 + 1))
  else
    FUERA39+=("$k39")
  fi
done <<< "${CLAVES39//|/$'\n'}"

# ANTI-VACUIDAD, y también es criterio: un dominio vacío, o uno en el que ningún campo produce
# `allow` al retirarlo, hace que «todos denegaron» sea cierto POR VACÍO. Un instrumento que
# ante la ausencia de datos responde verde es la familia de defecto que REQ-020 existe para
# cazar, así que el tamaño del dominio es un caso por su cuenta.
if [ -n "$sin_valor39" ]; then
  echo "  FAIL  REQ-023 CA-02 el lector declara el campo '$sin_valor39' y esta sección no le da valor más restrictivo: el dominio no lo mediría"; FAIL=$((FAIL+1))
elif [ "${#DOM39[@]}" -ge 1 ] && [ "$abren39" -ge 1 ]; then
  echo "  PASS  REQ-023 CA-02 el dominio se DERIVA midiendo: ${#DOM39[@]} de $(( ${#DOM39[@]} + ${#FUERA39[@]} )) campos del lector abren al faltar [${DOM39[*]}] · fuera [${FUERA39[*]:-ninguno}]"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-023 CA-02 el dominio derivado quedó VACÍO (${#DOM39[@]} campos, $abren39 abren): la propiedad no mediría nada"; FAIL=$((FAIL+1))
fi
# Y AHORA LA PROPIEDAD, sobre CADA campo del dominio derivado: el carácter lo borra y la puerta
# DENIEGA — y por MEDIBILIDAD, no por «el campo falta», que sería un `allow` con otro nombre en
# cuanto el rigor declarado fuese `ligero`.
mal39=''; n39=0
for k39 in "${DOM39[@]}"; do
  base39 "$k39" || continue
  out39="$(corre guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-981.md" "$(doc39 "$k39" "${BOM39}$k39: $VAL39")")")"
  n39=$((n39 + 1))
  printf '%s' "$out39" | grep -Eq '"permissionDecision": *"deny"' || { mal39="$mal39 $k39(allow)"; continue; }
  printf '%s' "$out39" | grep -q 'INSERTADO DENTRO DE LA CLAVE' || mal39="$mal39 $k39(otro-motivo)"
done
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-02 el carácter" | grep -qi -- "$FILTRO"; then
  if [ "$n39" -ge 1 ] && [ -z "$mal39" ]; then
    echo "  PASS  REQ-023 CA-02 el carácter borra el campo y la puerta DENIEGA por medibilidad en los $n39 campos del dominio derivado"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-02 el carácter no denegó por medibilidad en:${mal39:- (dominio vacío: 0 campos ejercidos)}"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-11 · LA FRONTERA CON LO QUE UNA REGLA CONTRATADA SÍ RETIRA ----------
# Si la retirada de la declaración la DECIDE una regla contratada del lector —la noción de
# rango de comentario de REQ-016, firmada en R-009—, entonces es el dominio de la SEMÁNTICA DE
# LA AUSENCIA, que es una decisión y no un defecto, y se revisa en REQ-024. Este REQ no la
# toca: la ausencia se sigue perdonando exactamente como antes.
#
# Y EL CASO QUE LA MEDICIÓN HACE FALLAR, escrito como caso porque la elección obvia del sitio
# de la guarda lo incumple: publicando la guarda desde la llamada CRUDA de
# `arnes_estado_cabecera` (`hooks/lib.sh`, la que recibe la línea pre-cita a propósito), las
# formas SIN ESPACIO disparan y la de CON espacio no — un falso positivo cuyo veredicto
# depende de si quien escribió el comentario puso un espacio.
mk39 REQ-982 '# REQ-982
Estado: en-revisión'
check "REQ-023 CA-11 campo comentado SIN espacio ('<!--Rigor: ligero-->') decide igual que antes: la guarda NO dispara" allow \
  guard-completado.sh "$(w39 REQ-982 "# REQ-982
Estado: completado
<!--Rigor: ligero-->
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
")"
check "REQ-023 CA-11 ...y CON espacio decide lo mismo: el veredicto no depende de ese espacio" allow \
  guard-completado.sh "$(w39 REQ-982 "# REQ-982
Estado: completado
<!-- Rigor: ligero -->
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
")"
check "REQ-023 CA-11 '<!--Estado: completado -->' comentado sin espacio: sigue sin declarar el estado -> allow, sin guarda" allow \
  guard-completado.sh "$(w39 REQ-982 "# REQ-982
Estado: completado
<!--Estado: en-revisión -->
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
")"
# La ausencia LISA Y LLANA se sigue perdonando: es REQ-016 CA-11 y este REQ no lo cambia.
check "REQ-023 CA-11 la AUSENCIA de un campo se sigue perdonando exactamente como antes -> allow" allow \
  guard-completado.sh "$(w39 REQ-982 "# REQ-982
Estado: completado
Sensible a seguridad: no
Rigor: estandar
")"

# ---------- LAS BOCAS: la detección vive en el escáner, la publicación en la entrada ----------
# BOCA `Edit` — el carácter vive en DISCO y la edición sólo cambia el valor del estado, así que
# quien tenía que verlo es la RECONSTRUCCIÓN del documento resultante.
mk39 REQ-983 "# REQ-983
Estado: en-revisión
${BOM39}Sensible a seguridad: sí
QA: pendiente
Rigor: ligero"
check_motivo "REQ-023 boca Edit: el BOM vive en DISCO y la edición sólo cambia el estado -> deny (era ALLOW)" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh \
  "$(e39 REQ-983 'Estado: en-revisión' 'Estado: completado')"
# BOCA FRAGMENTO — un `Edit` cuyo `old_string` NO está en el archivo: la herramienta fallará
# entera, pero la puerta juzga el fragmento como siempre y ahí la guarda entra por
# `ARNES_OCULTA`, que publica `arnes_campos_req`. Es una rama distinta del hook, con su propio
# `arnes_deny`, y sin este caso quedaba sin medir.
mk39 REQ-984 '# REQ-984
Estado: en-revisión
Sensible a seguridad: sí
QA: aprobado
Rigor: critico'
check_motivo "REQ-023 boca fragmento (old_string ausente): el carácter del fragmento entrante también deniega" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-984.md" '' '' "Estado: completado
${ZWSP39}Seguridad: aprobado")"

# ---------- LO QUE LA GUARDA NO PUEDE TOCAR ----------
# REABRIR NO SE BLOQUEA. Es una de las tres fronteras conformes, y sin este caso un REQ con un
# invisible quedaría atrapado en `completado` para siempre.
mk39 REQ-985 "# REQ-985
Estado: completado
${BOM39}Sensible a seguridad: sí
QA: aprobado
Rigor: critico"
check "REQ-023 reabrir un REQ con un invisible en la cabecera NO se bloquea -> allow" allow \
  guard-completado.sh "$(e39 REQ-985 'Estado: completado' 'Estado: en-progreso')"
# LA FRONTERA ESTRUCTURAL: los campos valen SÓLO en la cabecera, y la guarda también. Un BOM
# debajo del primer `## ` no es asunto de esta puerta — si lo fuera, cualquier REQ con un
# fragmento pegado de otro sitio dejaría de poder cerrarse, y la fricción termina con alguien
# apagando el guard (AGENTS.md §13).
mk39 REQ-986 '# REQ-986
Estado: en-revisión'
check "REQ-023 frontera: un BOM delante de una clave DEBAJO del primer '## ' no es cabecera -> allow" allow \
  guard-completado.sh "$(w39 REQ-986 "# REQ-986
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico

## Historial
${BOM39}Sensible a seguridad: no
")"
# LAS CLAVES QUE NO SON DEL LECTOR: la guarda CALLA. `Módulo:` y `Versión destino:` llevan
# letra no ASCII EN LA CLAVE —los escribe la plantilla de `requirements/README.md`—, así que una
# guarda escrita «en positivo» sobre el alfabeto ASCII las denegaría. Es la mitad que decide si
# el arreglo sirve: un conjunto admitido demasiado estrecho produce fricción constante.
check "REQ-023 CA-04 'Módulo:' y 'Versión destino:' en la cabecera: la guarda calla -> allow" allow \
  guard-completado.sh "$(w39 REQ-986 "# REQ-986
Estado: completado
Módulo: hooks (el escáner de cabecera)
Versión destino: 1.34.0
Prioridad: alta
NFR relacionados: (ninguno)
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico
")"
# Y LA CLAVE DECORADA sigue gobernando (REQ-016 CA-04): el marcado se retira ANTES de que la
# guarda pregunte, así que `**Estado:**` no es un invisible.
check "REQ-023 CA-04 la clave DECORADA sigue gobernando y no dispara la guarda -> deny por el veredicto" deny \
  guard-completado.sh "$(w39 REQ-986 "# REQ-986
**Estado:** completado
**Sensible a seguridad:** sí
**QA:** pendiente
Rigor: critico
")"

# ---------- CA-05 · EL VEREDICTO Y EL MOTIVO SON INVARIANTES AL LOCALE ----------
# Vive aquí, con «la puerta», desde 1.34.0: el sorteo estratificado de `CA-03` dejó la parte 2
# en el techo de `REQ-014 CA-18`. El motivo del criterio está medido dos veces en este arnés:
# una clasificación que dependa de `LC_CTYPE` DENIEGA en el CI de Linux y PERMITE en
# Windows/MSYS —donde viven los proyectos consumidores y de donde sale el BOM—, y sería un
# fallo en abierto POR ENTORNO, invisible en la puerta requerida de `main`. Se compara la
# salida ENTERA de las dos, en la misma corrida.
if [ -z "$FILTRO" ] || printf '%s' "REQ-023 CA-05" | grep -qi -- "$FILTRO"; then
  JSON39="$(w39 REQ-986 "# REQ-986
Estado: completado
${BOM39}Sensible a seguridad: sí
QA: pendiente
Seguridad: pendiente
Rigor: ligero
")"
  u39="$(LC_ALL=C.UTF-8 corre guard-completado.sh "$JSON39")"
  c39="$(LC_ALL=C       corre guard-completado.sh "$JSON39")"
  if [ -n "$u39" ] && [ "$u39" = "$c39" ]; then
    echo "  PASS  REQ-023 CA-05 el veredicto y el motivo son IDÉNTICOS bajo el locale del entorno y bajo LC_ALL=C"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-023 CA-05 la salida difiere por locale (C.UTF-8 vacía=$([ -z "$u39" ] && echo si || echo no)): un fail-open POR ENTORNO"; FAIL=$((FAIL+1))
  fi
fi
