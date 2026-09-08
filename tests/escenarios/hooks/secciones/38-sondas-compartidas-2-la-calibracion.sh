# ---------- 38 (2/3) · LOS INSTRUMENTOS COMPARTIDOS: LA CALIBRACIÓN Y SU PROCEDENCIA ----------
# REQ-021. Aquí no se comprueba que las sondas «midan»: se comprueba que su número SE MUEVA
# cuando el sujeto se mueve (CA-03), de dónde SALE ese número (la mitad discordante, con un
# testigo que el juez obtiene él mismo), que las cinco condiciones del testigo se cumplan o
# el caso ABORTE, y que calibrar no cueste más de 6× una medición (CA-08 (iii)).
#
# LA PROCEDENCIA NO SE LEE EN EL REGISTRO: la sonda honesta y la tautológica publican EL
# MISMO NÚMERO, y por eso cada mitad de aquí abajo lleva su FAIL-BEFORE — una copia mutada,
# o un registro neutralizado, que el juez tiene que cazar mientras el real pasa.
#
# PARTE 2 DE 3 POR REQ-014 CA-18; el motivo de la partición y el reparto de los 32 casos
# están escritos una sola vez, en `38-sondas-compartidas-1-el-registro.sh`. `num38` viene
# duplicado de allí: CA-04, CA-19 y H-04 de REQ-014 hacen imposible factorizarlo, y una
# línea copiada cuesta menos que una puerta trasera entre secciones.
CASOS_ESPERADOS_SECCION=13
PISO_AUTONOMO_SECCION=98  # 20 preámbulo (líneas 1-20, con num38) + 6 maquinaria compartida duplicada (las lecturas de la calibración y los testigos de esta corrida, líneas 27-32) + 72 bloque indivisible mayor (CA-08 (iii): iii38, las dos mediciones de referencia y sus dos casos, líneas 256-327) · REQ-014 CA-18
seccion_nueva "--- 38/2 · los instrumentos de tests/util/: la calibración y su procedencia (REQ-021 CA-03 y CA-08 (iii)) ---"

num38() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# ---------- CA-03 · LA CALIBRACIÓN, UNA POR INSTRUMENTO Y POR CORRIDA ----------
# El factor esperado y la banda viven en el JUEZ (`run.sh`), no en el archivo de la sonda:
# dentro del archivo cuestionado, ensancharla es una línea de la misma edición (SEC-036).
sonda_juzga_calibracion "REQ-021 CA-03 calibración de sonda-reloj.sh: el sujeto sensible responde al parámetro y el insensible no" reloj
sonda_juzga_calibracion "REQ-021 CA-03 calibración de sonda-procesos.sh: el sujeto sensible responde al parámetro y el insensible no" procesos

# Los registros y los testigos de ESTA corrida, leídos una vez. Cuestan cero procesos.
CALREL38=''; CALPRO38=''; TSTREL38=''; TSTPRO38=''
[ -r "$RAIZ/cal-reloj" ]       && { IFS= read -r CALREL38 < "$RAIZ/cal-reloj" 2>/dev/null || :; }
[ -r "$RAIZ/cal-procesos" ]    && { IFS= read -r CALPRO38 < "$RAIZ/cal-procesos" 2>/dev/null || :; }
[ -r "$RAIZ/testigo-reloj" ]   && { read -r TSTREL38 < "$RAIZ/testigo-reloj" 2>/dev/null || :; }
[ -r "$RAIZ/testigo-procesos" ] && { read -r TSTPRO38 < "$RAIZ/testigo-procesos" 2>/dev/null || :; }

# ---------- CA-03 (c) · EL TAMAÑO SE DERIVA DEL SUELO, NO SE ESCRIBE A MANO ----------
# Medido lo que costaba el absoluto (QA-021-06): con `--n 200000` fijo el ejercicio
# INSENSIBLE quedaba a ~72 ms, es decir a 1,4× del suelo de 50 ms, donde el ruido del
# planificador domina — y 5 de 30 calibraciones caían fuera de banda, 2 con la máquina EN
# REPOSO, cada una invalidando toda medición de reloj de la corrida y enrojeciendo la puerta
# requerida. En una máquina bastante más rápida el mismo absoluto habría dicho `suelo`.
nom38="REQ-021 CA-03 (c) el tamaño de cada mitad se DERIVA del suelo medido en esta corrida, se publica, y ninguna mitad queda pegada al suelo"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  if ! sonda_lee "$CALREL38"; then falla38=" la calibración de reloj no se puede leer: $SONDA_MOTIVO"
  elif [ "${SONDA[estado]}" != ok ]; then falla38=" la calibración no salió ok: ${SONDA[estado]}/${SONDA[motivo]:-}"
  else
    for c38 in cal_n cal_margen cal_ns_vuelta suelo min_a min_b; do
      num38 "${SONDA[$c38]:-}" || falla38="$falla38 $c38=<${SONDA[$c38]:-vacío}> no es un número;"
    done
    if [ -z "$falla38" ]; then
      [ "${SONDA[cal_margen]}" -ge 4 ] || falla38="$falla38 el margen sobre el suelo bajó a ${SONDA[cal_margen]}× (sólo puede subir de 4);"
      # LAS DOS MITADES POR ENCIMA DEL SUELO CON MARGEN, que es lo que arregla la fragilidad:
      # se exige al menos margen−1 veces el suelo para dejar holgura de ruido a la propia
      # comprobación, y en particular al INSENSIBLE, que era el que derivaba.
      # EL SUELO CON EL QUE SE DECIDE ES EL DEL JUEZ (`SONDA_SUELO_US`), no el `suelo=` que
      # publica el instrumento juzgado: es la condición 5 de (a.3) —quien es juzgado no
      # aporta la vara— y aquí valía igual, a una línea del sitio donde se midió el fallo.
      # El campo se sigue exigiendo NUMÉRICO arriba (es condición de la medida, CA-06) y se
      # sigue publicando en el veredicto; lo que no hace es decidir.
      esp38=$(( SONDA_SUELO_US * (SONDA[cal_margen] - 1) ))
      [ "${SONDA[min_a]}" -ge "$esp38" ] || falla38="$falla38 el sensible base mide ${SONDA[min_a]}µs y no llega a ${esp38}µs;"
      [ "${SONDA[min_b]}" -ge "$esp38" ] || falla38="$falla38 el insensible base mide ${SONDA[min_b]}µs y no llega a ${esp38}µs (es el que derivaba a 1,4× del suelo);"
      # …Y EL TAMAÑO SE RE-DERIVA AQUÍ desde el coste por vuelta que la sonda publicó: si
      # `cal_n` fuera un absoluto escrito a mano, no cuadraría con `cal_ns_vuelta`. El env
      # sólo puede SUBIRLO, así que se exige `>=`, nunca igualdad.
      der38=$(( SONDA_SUELO_US * SONDA[cal_margen] * 1000 / SONDA[cal_ns_vuelta] ))
      [ "${SONDA[cal_n]}" -ge $(( der38 * 7 / 10 )) ] \
        || falla38="$falla38 cal_n=${SONDA[cal_n]} queda por debajo de lo que su propio cal_ns_vuelta deriva (~$der38);"
    fi
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (cal_n=${SONDA[cal_n]} derivado de ${SONDA[cal_ns_vuelta]}ns/vuelta para ${SONDA[cal_margen]}× el suelo de ${SONDA_SUELO_US}µs que declara el JUEZ —la sonda publica suelo=${SONDA[suelo]}µs y no decide—; sensible ${SONDA[min_a]}µs · insensible ${SONDA[min_b]}µs, ninguno pegado al suelo)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-03 (a.2) · LA MITAD DISCORDANTE: DE DÓNDE SALE EL FACTOR ----------
# LA PROCEDENCIA NO SE LEE EN EL REGISTRO: la sonda honesta y la tautológica publican EL
# MISMO NÚMERO. Medido (QA-021-01): el factor de `sonda-linea-base.sh` salía del PARÁMETRO
# —`2N/N = 2000` por aritmética, hiciera la sonda algo o nada—, una copia mutada que no
# materializaba, no verificaba y no comprobaba el bit publicó `cal_a=2000 cal_b=1000`, y EL
# JUEZ REAL DIJO PASS. La identidad de camino no protege de eso: la mutación borra el camino
# entero y el factor no se mueve. Así que el juez contrasta la MAGNITUD publicada contra un
# TESTIGO QUE ÉL MISMO OBTIENE, y el caso publica los dos números para que un fallo se
# reproduzca sin volver a montarlo.
sonda_juzga_discordante "REQ-021 CA-03 (a.2) la magnitud de sonda-reloj.sh sale de OBSERVAR el sujeto: bajo el suelo dice suelo y no publica número" reloj "$CALREL38" "$TSTREL38" pasa
sonda_juzga_discordante "REQ-021 CA-03 (a.2) la magnitud de sonda-procesos.sh sale de OBSERVAR el sujeto: coincide con el testigo que el juez contó, no con el parámetro" procesos "$CALPRO38" "$TSTPRO38" pasa

# FAIL-BEFORE, Y SIN ÉL LO DE ARRIBA NO PRUEBA NADA: si a la sonda se le QUITA LA
# OBSERVACIÓN —publicar el parámetro donde debería publicar lo medido—, la mitad discordante
# tiene que FALLAR, y la misma entrada sin esa mutación, PASAR. Sin la segunda mitad un FAIL
# no probaría que la comprobación distingue: probaría que falla (CA-03 (a.3)).
#
# PARA `procesos` SE MUTA LA SONDA DE VERDAD, en una COPIA y sin tocar el árbol: cuesta unas
# pocas invocaciones de `grep`, o sea milisegundos. PARA `reloj` se neutraliza el REGISTRO en
# vez del archivo, y el motivo no es comodidad: una segunda calibración de reloj completa
# duplicaría el reloj de esta sección en la puerta requerida, que es exactamente lo que
# CA-08 (ii) existe para acotar y el final de camino que hace que alguien apague una
# calibración. La mutación del ARCHIVO de reloj —hecha por un tercero, que es lo que la hace
# valer— es el forzador del residual de `tests/util/`, y su evidencia va al Historial del REQ.
#
# LA MUTACIÓN YA NO SE ANCLA A UN LITERAL DEL ARCHIVO, y esto es lo que cambia en esta vuelta.
# Antes era un `sed` sobre la cadena `SP_DISC_OBS="$SP_CUENTA_EJ"` —fail-closed, sí, pero esa
# línea se reescribió en esta misma vuelta y un ancla literal deja de probar lo que dice en
# cuanto alguien la toca—. Ahora se sustituye, por su DEFINICIÓN y no por su cuerpo, la única
# función que ejerce un sujeto (`sp_ejerce`, CA-03 punto 4): el reemplazo devuelve las cinco
# magnitudes POR ARITMÉTICA sobre el parámetro sin evaluar el sujeto, sin invocar el binario
# instrumentado ni una vez y sin leer el registro de los envoltorios. Es EXACTAMENTE la
# mutación que QA midió pasando (QA-021-10, receta en `docs/qa/1.33.0.md`), no una elegida
# aquí: sus factores salen 2,000 y 1,000 —en banda, indistinguibles de la honesta— y lo único
# que la delata es el testigo del juez. Si la función se renombra, `awk` no encuentra la
# definición, sale con rc 1 y el caso FALLA diciéndolo: fail-closed, que es lo correcto.
nom38="REQ-021 CA-03 (a.2) fail-before: a sonda-procesos.sh se le quita la observación en una COPIA —el único camino que ejerce el sujeto pasa a ser aritmética— y el juez la caza; la misma copia sin mutar pasa"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  COPIA38="$RAIZ/copia38-$BASHPID"
  mkdir -p "$COPIA38" 2>/dev/null
  falla38=''
  STUB38='sp_ejerce() {
  case "${1:-}" in
    sp_cal_sens)   SP_CUENTA_EJ="$SP_CAL_VECES" ;;
    sp_cal_insens) SP_CUENTA_EJ="$SP_CAL_FIJO" ;;
    *)             SP_CUENTA_EJ="$SP_CAL_N" ;;
  esac
}'
  if ! cp "$UTIL_DIR/sonda-procesos.sh" "$COPIA38/limpia.sh" 2>/dev/null; then
    falla38=' no se pudo copiar sonda-procesos.sh'
  else
    chmod +x "$COPIA38/limpia.sh"
    awk -v stub="$STUB38" '
      !dentro && /^sp_ejerce\(\)[ \t]*\{/ { print stub; dentro = 1; hecho = 1; next }
      dentro  && /^\}/                    { dentro = 0; next }
      !dentro                             { print }
      END { if (!hecho) exit 1 }
    ' "$COPIA38/limpia.sh" > "$COPIA38/mutada.sh" 2>/dev/null \
      || falla38=' la mutación NO se aplicó: no se encontró la definición de la función que ejerce el sujeto (¿la renombraron?), y sin mutación el fail-before no probaría nada'
    chmod +x "$COPIA38/mutada.sh" 2>/dev/null
    if [ -z "$falla38" ] && cmp -s "$COPIA38/limpia.sh" "$COPIA38/mutada.sh"; then
      falla38=' la mutación NO cambió el archivo: el fail-before no probaría nada'
    fi
  fi
  if [ -z "$falla38" ]; then
    # A las dos copias se les entrega EL MISMO sujeto discordante del juez y se las juzga con
    # LA MISMA terna, obtenida antes incluso de la calibración real de esta corrida.
    reglim38="$("$COPIA38/limpia.sh" --calibrar --dir-trabajo "$COPIA38" --disc-sujeto "$SONDA_DISC_PROC_SUJ" 2>/dev/null)"
    regmut38="$("$COPIA38/mutada.sh" --calibrar --dir-trabajo "$COPIA38" --disc-sujeto "$SONDA_DISC_PROC_SUJ" 2>/dev/null)"
    sonda_discordante procesos "$regmut38" "$TSTPRO38"; vmut38="$SONDA_DISC_VEREDICTO"; motmut38="$SONDA_DISC_MOTIVO"
    sonda_discordante procesos "$reglim38" "$TSTPRO38"; vlim38="$SONDA_DISC_VEREDICTO"
    [ "$vmut38" = fail ] || falla38="$falla38 la copia MUTADA dio <$vmut38> en vez de fail (registro: <$regmut38>);"
    [ "$vlim38" = ok ]   || falla38="$falla38 la copia SIN mutar dio <$vlim38> en vez de ok (${SONDA_DISC_MOTIVO:-});"
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (mutada: $motmut38 · sin mutar: pasa con la terna <$TSTPRO38>)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
  rm -rf "$COPIA38"
fi

nom38="REQ-021 CA-03 (a.2) fail-before: un registro de reloj SIN la observación —el parámetro donde va lo medido— lo caza el juez, y el real pasa"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  if ! sonda_lee "$CALREL38"; then falla38=" la calibración de reloj no se puede leer: $SONDA_MOTIVO"
  else
    # Se construye EXACTAMENTE lo que publica una sonda que calcula sin medir: la magnitud
    # pasa a ser el parámetro y, al quedar por encima del suelo, el estado deja de ser `suelo`.
    mut38="${CALREL38/ disc_obs=${SONDA[disc_obs]} / disc_obs=${SONDA[disc_param]} }"
    mut38="${mut38/ disc_estado=suelo / disc_estado=ok }"
    if [ "$mut38" = "$CALREL38" ]; then falla38=' la neutralización no cambió el registro: el fail-before no probaría nada'; fi
  fi
  if [ -z "$falla38" ]; then
    sonda_discordante reloj "$mut38" "$TSTREL38"; vmut38="$SONDA_DISC_VEREDICTO"; motmut38="$SONDA_DISC_MOTIVO"
    sonda_discordante reloj "$CALREL38" "$TSTREL38"; vlim38="$SONDA_DISC_VEREDICTO"
    [ "$vmut38" = fail ] || falla38="$falla38 el registro neutralizado dio <$vmut38> en vez de fail;"
    [ "$vlim38" = ok ]   || falla38="$falla38 el registro real dio <$vlim38> en vez de ok (${SONDA_DISC_MOTIVO:-});"
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (neutralizado: $motmut38 · real: pasa con la terna <$TSTREL38>)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-03 (a.3) · LAS CINCO CONDICIONES DEL TESTIGO: SI NO SE CUMPLEN, ABORTA ----
# LO QUE FALLÓ NO FUE LA COMPARACIÓN, FUE EL TESTIGO (QA-021-10). El juez de antes sabía
# comparar dos números, y dos números que salen de la misma fuente COINCIDEN SIEMPRE: `3 = 3`
# con `disc_obs = cal_n − 1` y un testigo contado sobre las marcas que escribía la propia
# sonda. Un juez que no comprueba de dónde sale su propio testigo no juzga: refleja. Así que
# las condiciones de (a.3) se ejercen UNA A UNA contra el juez REAL, con entradas sintéticas y
# en microsegundos —el precedente son `valida47`/`veredicto47` de `37/2`—, y su veredicto tiene
# que ser ABORT: ni PASS ni SKIP. La condición 2 (el valor lo produce el juez) no se ejerce
# aparte: su forma comprobable ES la 3, y así lo dice el criterio.
#
# Las piezas de las ternas reales se parten con el MISMO ayudante del juez (sede única), y si
# no son legibles los casos FALLAN diciéndolo en vez de abortar en vacío: un caso que «aborta»
# porque su entrada era basura acredita lo mismo que uno que no corrió.
sonda_terna_parte "$TSTPRO38"; tvalpro38="$SONDA_T_VALOR"; tantpro38="$SONDA_T_ANTES"; tinvpro38="$SONDA_T_INVOCA"
sonda_terna_parte "$TSTREL38"; tvalrel38="$SONDA_T_VALOR"; tantrel38="$SONDA_T_ANTES"; tinvrel38="$SONDA_T_INVOCA"
ternas38=si
for v38 in "$tvalpro38" "$tantpro38" "$tinvpro38" "$tvalrel38" "$tantrel38" "$tinvrel38"; do
  num38 "$v38" || ternas38=no
done
falta38="las ternas de testigo de esta corrida no son legibles (procesos=<$TSTPRO38> reloj=<$TSTREL38>): sin ellas el caso no probaría nada"

# CONDICIÓN 3 · ANTERIORIDAD. Es la que convierte «testigo independiente» en algo que se
# comprueba: se le da al juez la terna real con las dos marcas INVERTIDAS —testigo obtenido
# 1 µs DESPUÉS de la invocación— y todo lo demás intacto.
nom38="REQ-021 CA-03 (a.3) cond. 3 ANTERIORIDAD: un testigo que el juez no tenía ANTES de invocar la sonda ABORTA el caso, no lo pasa"
if [ "$ternas38" != si ]; then
  if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
    echo "  FAIL  $nom38  $falta38"; FAIL=$((FAIL+1))
  fi
else
  sonda_juzga_discordante "$nom38" procesos "$CALPRO38" "$tvalpro38 $(( tinvpro38 + 1 )) $tinvpro38" aborta
fi

# CONDICIÓN 1 · NO VACUIDAD: el testigo no coincide con el parámetro. Se construye la
# colisión a propósito, poniendo como testigo el `disc_param` que la sonda publicó.
nom38="REQ-021 CA-03 (a.3) cond. 1 NO VACUIDAD: un testigo IGUAL al parámetro ABORTA —su verde sería cierto por vacío, y una colisión es un defecto del dimensionado—"
ppro38=''
sonda_lee "$CALPRO38" && ppro38="${SONDA[disc_param]:-}"
if [ "$ternas38" != si ] || ! num38 "${ppro38:-}"; then
  if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
    echo "  FAIL  $nom38  $falta38 (disc_param=<${ppro38:-vacío}>)"; FAIL=$((FAIL+1))
  fi
else
  sonda_juzga_discordante "$nom38" procesos "$CALPRO38" "$ppro38 $tantpro38 $tinvpro38" aborta
fi

# CONDICIÓN 4 · el tamaño del sujeto discordante lo fija el JUEZ y la sonda NO lo declara. Se
# le devuelve al registro el campo que tenía hasta esta vuelta (`disc_veces=`), que es por
# donde el parámetro y el testigo volvían a salir de la misma fuente.
nom38="REQ-021 CA-03 (a.3) cond. 4: si el registro DECLARA el tamaño del sujeto discordante, el caso ABORTA —ese tamaño es del juez—"
regdec38="${CALPRO38/ disc_param=/ disc_veces=3 disc_param=}"
if [ "$ternas38" != si ] || [ -z "$CALPRO38" ] || [ "$regdec38" = "$CALPRO38" ]; then
  if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
    echo "  FAIL  $nom38  no se pudo construir el registro con el tamaño declarado (¿cambió el nombre del campo?): $falta38"; FAIL=$((FAIL+1))
  fi
else
  sonda_juzga_discordante "$nom38" procesos "$regdec38" "$TSTPRO38" aborta
fi

# CONDICIÓN 5 · la vara no la aporta el juzgado. Se le da al juez el registro real del reloj
# con un `suelo=` de 1 µs —un suelo con el que TODO queda por encima y el caso abortaría—: si
# el veredicto NO cambia, es que el umbral con el que decide es el suyo. Es la dirección
# comprobable de la condición: leer el campo cambiaría el veredicto, y no lo cambia.
nom38="REQ-021 CA-03 (a.3) cond. 5: el umbral con que el juez decide NO sale del registro juzgado —un reloj que publique suelo=1µs no compra su propia abstención—"
regsue38="${CALREL38% suelo=*} suelo=1"
if [ "$ternas38" != si ] || [ -z "$CALREL38" ] || [ "$regsue38" = "$CALREL38" ]; then
  if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
    echo "  FAIL  $nom38  no se pudo reescribir el campo suelo= del registro del reloj: $falta38"; FAIL=$((FAIL+1))
  fi
else
  sonda_juzga_discordante "$nom38" reloj "$regsue38" "$TSTREL38" pasa
fi

# ---------- CA-08 (iii) · CALIBRAR NO CUESTA MÁS DE 6× UNA MEDICIÓN ----------
# EN RELOJ Y EN PROCESOS, los dos en la misma corrida. Es la única mitad de CA-08 que no
# depende de una referencia congelada, así que corre SIEMPRE — y es el único indicador
# MEDIBLE de la identidad de camino de CA-03.4: una calibración que cuesta bastante más que
# los ejercicios que CA-03 contrata no está recorriendo el camino de la medición.
#
# EL 6 NO ES UNA HOLGURA: ES LA SUMA TÉRMINO A TÉRMINO de lo que CA-03 contrata —1 el
# sensible base, 2 el sensible al doble (que cuesta el doble POR CONSTRUCCIÓN), 1+1 el
# insensible en los dos tamaños y 1 la mitad discordante, que puede costar menos y nunca
# más—. El 4 anterior contaba «cuatro ejercicios» COMO SI COSTARAN LO MISMO: la suma correcta
# del MISMO contrato era 5, y 6 con la discordante. Y ese techo mal derivado no ahorró coste:
# compró su encaje con la capacidad de discriminar del instrumento —el insensible se fijó a
# N/4, a 1,4× del suelo, y la calibración se volvió flaky en la puerta requerida—. Un techo
# derivado de otro criterio se RE-DERIVA en la misma edición que cambia ese criterio.
TECHO38=6000   # ‰. OPERATIVO: se baja con la medición.
iii38() {   # <nombre> <instrumento> <registro de la medición de referencia>
  local nombre="$1" inst="$2" reg="${3:-}" cus cpr mus mpr rr rp
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ -z "$reg" ]; then
    echo "  FAIL  $nombre  la medición de referencia no dejó registro: sin denominador no hay razón"; FAIL=$((FAIL+1)); return 0
  fi
  sonda_lee "$reg" || { echo "  FAIL  $nombre  la medición de referencia no se puede leer: $SONDA_MOTIVO"; FAIL=$((FAIL+1)); return 0; }
  if [ "${SONDA[estado]}" != ok ]; then
    echo "  SKIP  $nombre  la medición de referencia no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo}"; return 0
  fi
  mus="${SONDA[us]}"; mpr="${SONDA[procesos]}"
  [ -r "$RAIZ/cal-$inst" ] || { echo "  SKIP  $nombre  esta corrida no calibró '$inst'"; return 0; }
  reg=''; IFS= read -r reg < "$RAIZ/cal-$inst" 2>/dev/null || :
  sonda_lee "$reg" || { echo "  FAIL  $nombre  la calibración no se puede leer: $SONDA_MOTIVO"; FAIL=$((FAIL+1)); return 0; }
  cus="${SONDA[us]}"; cpr="${SONDA[procesos]}"
  if [ "$mus" -le 0 ]; then echo "  SKIP  $nombre  el denominador de reloj es cero"; return 0; fi
  rr=$(( cus * 1000 / mus ))
  # QA-021-07: la mitad en PROCESOS ya no se presenta como `0,000×` sobre un contador que
  # nunca se incrementaba —0/0 pasando en vacío—. Si el instrumento publica `no-aplica`, esa
  # mitad NO SE PUEDE MEDIR y se dice: SKIP con el motivo, nunca un cero disfrazado de razón.
  case "$mpr:$cpr" in
    *no-aplica*)
      echo "  SKIP  $nombre  reloj $(awk -v c=$rr 'BEGIN{printf "%.3f", c/1000}')× (${cus}µs sobre ${mus}µs) cabe en el techo 6,000×, pero la mitad en PROCESOS no es medible en este instrumento: publica procesos=no-aplica (contarlos exigiría instrumentar, y una muestra mixta no es publicable, CA-02.5)"
      return 0 ;;
  esac
  if [ "$mpr" -eq 0 ]; then
    echo "  SKIP  $nombre  el denominador en procesos es cero: 0 sobre $cpr no es una razón"; return 0
  fi
  rp=$(( cpr * 1000 / mpr ))
  if [ "$rr" -le "$TECHO38" ] && [ "$rp" -le "$TECHO38" ]; then
    echo "  PASS  $nombre  reloj $(awk -v c=$rr 'BEGIN{printf "%.3f", c/1000}')× (${cus}µs sobre ${mus}µs) y procesos $(awk -v c=$rp 'BEGIN{printf "%.3f", c/1000}')× ($cpr sobre $mpr), techo 6,000×"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  reloj $(awk -v c=$rr 'BEGIN{printf "%.3f", c/1000}')× (${cus}µs sobre ${mus}µs) y procesos $(awk -v c=$rp 'BEGIN{printf "%.3f", c/1000}')× ($cpr sobre $mpr) contra el techo 6,000×"; FAIL=$((FAIL+1))
  fi
}
# LA MEDICIÓN DE REFERENCIA USA LOS MANDOS QUE LA CALIBRACIÓN PUBLICÓ, y eso es lo que hace a
# (iii) INVARIANTE A `r`: numerador y denominador llevan los mismos, así que subir `r` —la
# palanca gratis de CA-03 (d)— no mueve esta razón y sólo cuesta reloj, que es lo que mide
# (ii). Con los mandos escritos a mano en este archivo, subir `r` en el corredor habría
# multiplicado la razón por 5/3 y (iii) habría salido en rojo sin que nada se degradara.
nrel38=''; rrel38=''
if sonda_lee "$CALREL38"; then nrel38="${SONDA[cal_n]:-}"; rrel38="${SONDA[r]:-}"; fi
npro38=''
if sonda_lee "$CALPRO38"; then npro38="${SONDA[cal_n]:-}"; fi
mrel38=''
if num38 "${nrel38:-}" && num38 "${rrel38:-}"; then
  mrel38="$("$UTIL_DIR/sonda-reloj.sh" --k 1 --r "$rrel38" --etiqueta referencia-iii \
    --sujeto "for ((SR_CAL_I = 0; SR_CAL_I < $nrel38; SR_CAL_I++)); do :; done" 2>/dev/null)"
fi
iii38 "REQ-021 CA-08 (iii) calibrar sonda-reloj.sh no cuesta más de 6× una medición suya con los MISMOS mandos" reloj "$mrel38"

mpro38=''
if num38 "${npro38:-}"; then
  mpro38="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta referencia-iii \
    --sujeto "for ((SP_REF_I = 0; SP_REF_I < $npro38; SP_REF_I++)); do grep -q x /dev/null || :; done" 2>/dev/null)"
fi
iii38 "REQ-021 CA-08 (iii) calibrar sonda-procesos.sh no cuesta más de 6× una medición suya con los MISMOS mandos" procesos "$mpro38"
