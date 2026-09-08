# ---------- 38 · LOS INSTRUMENTOS COMPARTIDOS DE `tests/util/` ----------
# REQ-021. Una sonda que mide mal DEVUELVE UN NÚMERO PLAUSIBLE, y las siete instancias de la
# ventana 1.32.1–1.33.0 tienen la misma forma: el instrumento medía algo real y había dejado
# de responder al sujeto. Por eso aquí no se comprueba que las sondas «midan»: se comprueba
# que su número SE MUEVA cuando el sujeto se mueve (CA-03), que no sobrevivan a su invocación
# (CA-04), que digan lo que no pudieron hacer en vez de devolver un cero (CA-05, CA-10) y que
# el juez no pueda convertir eso en un PASS.
#
# LAS QUALITY GATES DEL MANIFIESTO NO MIRAN `tests/` y `.arnes/config.json` NO SE TOCA
# (CA-09): es código protegido bajo gate humano, y una entrada en `PENDING_APPROVAL.md`
# deniega el cierre de cualquier REQ mientras exista. La cobertura se consigue donde ya hay
# una puerta requerida corriendo, que es aquí.
# 28 → 32: entran los cuatro casos de las CINCO CONDICIONES del testigo de CA-03 (a.3), que
# es lo que esta vuelta contrata —anterioridad, no vacuidad, tamaño declarado por la sonda y
# el umbral que no sale del registro juzgado—. Este literal y el `CASOS_ESPERADOS` de
# `run.sh` se actualizan A MANO y por separado: son el control (README del banco, invariante 2).
CASOS_ESPERADOS_SECCION=32
seccion_nueva "--- 38 · las dos sondas de tests/util/: calibración, procedencia, descendencia y el juez (REQ-021) ---"

num38() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
shopt -s nullglob; UTILES38=( "$UTIL_DIR"/*.sh ); shopt -u nullglob
# Los instrumentos son DOS desde el 2026-09-08: `sonda-linea-base.sh` sale del alcance y su
# trabajo se queda INLINE en las dos secciones 37 (REQ-021 CA-05, §«La reducción de alcance»).
# La lista no se escribe a mano en cada caso: el conjunto lo define el DIRECTORIO, que es su
# sitio único, y la propiedad de CA-01 rige para todo lo que haya ahí, no para una lista.
INST38=( reloj procesos )

# ---------- CA-09 · SINTAXIS Y MODOS DE TODO `tests/util/*.sh` ----------
if [ "${#UTILES38[@]}" -eq 0 ]; then
  echo "  FAIL  REQ-021 CA-09 no hay ningún instrumento en $UTIL_DIR: un directorio vacío pasa cualquier comprobación"; FAIL=$((FAIL+1))
  echo "  FAIL  REQ-021 CA-09 modos: sin instrumentos no hay modo que comprobar"; FAIL=$((FAIL+1))
else
  malos38=''
  for f38 in "${UTILES38[@]}"; do bash -n "$f38" 2>/dev/null || malos38="$malos38 ${f38##*/}"; done
  if [ -z "$malos38" ]; then
    echo "  PASS  REQ-021 CA-09 bash -n pasa en los ${#UTILES38[@]} archivos de tests/util/ (las gates del manifiesto no miran tests/, y .arnes/config.json no se toca)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-021 CA-09 sintaxis rota en tests/util/:$malos38"; FAIL=$((FAIL+1))
  fi
  # Un instrumento SIN bit de ejecución produce exactamente el mismo registro vacío que las
  # tres sondas mudas de esta ventana: no se puede invocar, y quien lo llame mide cero.
  malos38=''
  for f38 in "${UTILES38[@]}"; do
    [ -x "$f38" ] || malos38="$malos38 ${f38##*/}(sin +x)"
    linea38=''; read -r linea38 < "$f38" 2>/dev/null || :
    case "$linea38" in '#!'*) ;; *) malos38="$malos38 ${f38##*/}(sin shebang)" ;; esac
  done
  if [ -z "$malos38" ]; then
    echo "  PASS  REQ-021 CA-01.1/CA-09 los ${#UTILES38[@]} instrumentos son ejecutables y traen shebang: se INVOCAN, no se hacen source, y por eso \$BASHPID dentro de \$( ) deja de ser expresable"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-021 CA-09 modos de tests/util/:$malos38"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-01 · UN REGISTRO POR INVOCACIÓN, Y NINGUNA DICTA VEREDICTO ----------
# Se leen los registros de calibración que el corredor ya tomó en esta corrida: no cuesta un
# solo proceso, y son registros reales, no imitaciones. El diagnóstico va por la salida de
# error, y tampoco ahí puede llevar la forma con la que el corredor cuenta casos: una sonda
# es el brazo, no el juez.
regs38=0; lineas38=0; veredicto38=''
for inst38 in "${INST38[@]}"; do
  [ -r "$RAIZ/cal-$inst38" ] || continue
  regs38=$((regs38 + 1))
  n38=0
  while IFS= read -r linea38 || [ -n "$linea38" ]; do
    n38=$((n38 + 1))
    case "$linea38" in '  PASS  '*|'  FAIL  '*|'  SKIP  '*) veredicto38="$veredicto38 $inst38(stdout)" ;; esac
  done < "$RAIZ/cal-$inst38"
  lineas38=$((lineas38 + n38))
  if [ -s "$RAIZ/cal-$inst38.err" ]; then
    while IFS= read -r linea38 || [ -n "$linea38" ]; do
      case "$linea38" in '  PASS  '*|'  FAIL  '*|'  SKIP  '*) veredicto38="$veredicto38 $inst38(stderr)" ;; esac
    done < "$RAIZ/cal-$inst38.err"
  fi
done
if [ "$regs38" -eq "${#INST38[@]}" ] && [ "$lineas38" -eq "${#INST38[@]}" ] && [ -z "$veredicto38" ]; then
  echo "  PASS  REQ-021 CA-01.2/CA-01.3 las ${#INST38[@]} sondas emiten UN registro de UNA línea y ninguna imprime una línea con la forma que el corredor usa para contar casos"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-021 CA-01.2/CA-01.3 $regs38 registros y $lineas38 líneas (se esperaban ${#INST38[@]} y ${#INST38[@]}); líneas con forma de caso:${veredicto38:- ninguna}"; FAIL=$((FAIL+1))
fi

# CA-01.5 · UN CAMPO OBLIGATORIO AUSENTE ES UN ERROR CON MOTIVO, NUNCA UN CERO — la misma
# forma que el campo `QA:` ausente, que PERMITE donde `QA: pendiente` deniega. Y con la clase
# mal escrita: `*[!0-9|]*` dentro de un `case` no dispara NUNCA.
falla38=''
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y us=100 procesos=0 vivos=0" \
  || falla38="$falla38 <un registro completo se rechazó: $SONDA_MOTIVO>"
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y procesos=0 vivos=0" \
  && falla38="$falla38 <un registro SIN el campo 'us' se aceptó>"
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y us= procesos=0 vivos=0" \
  && falla38="$falla38 <un 'us' vacío se aceptó como si fuera cero>"
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y us=12x procesos=0 vivos=0" \
  && falla38="$falla38 <un 'us' no numérico se aceptó>"
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y us=100 procesos=|1 vivos=0" \
  && falla38="$falla38 <un 'procesos' con la barra que rompe la clase de un case se aceptó>"
sonda_lee "" && falla38="$falla38 <un registro vacío se aceptó>"
sonda_lee "esto no es un registro" && falla38="$falla38 <un texto sin campos se aceptó>"
# `vivos` es obligatorio SÓLO en el emisor que puede observarlo (CA-10 punto 2): ausente en
# un instrumento de tests/util/ es ILEGIBLE; ausente en el materializador INLINE de CA-05 es
# conforme, porque no hereda CA-04 y exigirle un campo que no puede observar sería un FAIL
# garantizado. Y `procesos=no-aplica` se acepta y NO es un cero (QA-021-07).
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y us=100 procesos=0" \
  && falla38="$falla38 <un instrumento de tests/util/ SIN 'vivos' se aceptó>"
sonda_lee "sonda=linea-base modo=medicion estado=ok corrida=x invocacion=y us=100 procesos=6 archivos=42" \
  || falla38="$falla38 <el materializador inline, que NO puede observar 'vivos', se rechazó: $SONDA_MOTIVO>"
sonda_lee "sonda=reloj modo=medicion estado=ok corrida=x invocacion=y us=100 procesos=no-aplica vivos=0" \
  || falla38="$falla38 <procesos=no-aplica se rechazó, y es lo único honesto que el reloj puede publicar: $SONDA_MOTIVO>"
if [ -z "$falla38" ]; then
  echo "  PASS  REQ-021 CA-01.5/CA-10.2 el parser valida cada campo POR SEPARADO —ausente, vacío y no numérico son errores con motivo, nunca un cero—, exige 'vivos' sólo a quien puede observarlo y acepta procesos=no-aplica sin confundirlo con un cero"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-021 CA-01.5/CA-10.2 el parser dejó pasar:$falla38"; FAIL=$((FAIL+1))
fi

# QA-021-04 · LA PUERTA DE CA-10 NO SE EVADE. Tres defectos que se COMPONÍAN y convertían
# un `estado=sin-linea-base` en `estado=ok` —el juez dejaba pasar como MEDICIÓN una sonda que
# no había podido medir—: (1) el registro no escapaba nada, así que un valor con un espacio
# dejaba de ser un valor y sus palabras con `=` se volvían CAMPOS; (2) `for par in $reg` iba
# sin comillas, así que sobre esas palabras se hacía además EXPANSIÓN DE NOMBRES DE ARCHIVO y
# el significado del registro dependía del contenido del directorio de trabajo (medido con un
# archivo llamado `estado=ok` en el `cwd`); y (3) el parser no detectaba CLAVE REPETIDA, y
# dejaba ganar a la última aparición. La mitad del emisor se comprueba abajo, en el caso del
# registro con espacios y saltos de línea.
nom38="REQ-021 QA-021-04 el parser no se puede inyectar: clave repetida es ILEGIBLE, y un valor con metacaracteres de glob no se expande contra el directorio de trabajo"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  base38="sonda=linea-base modo=medicion corrida=$ARNES_CORRIDA invocacion=i us=1 procesos=1"
  # (1)+(3) La inyección por espacio produce `estado` DOS VECES: ambiguo, no legible.
  sonda_lee "$base38 estado=sin-linea-base motivo=la-referencia-no-resuelve:zzz estado=ok archivos=desconocido" \
    && falla38="$falla38 <la inyección por espacio se aceptó y dejó estado=${SONDA[estado]:-?}>"
  case "${SONDA_MOTIVO:-}" in *REPETIDA*) ;; *) falla38="$falla38 <el motivo no dice que la clave esté repetida: ${SONDA_MOTIVO:-vacío}>" ;; esac
  # …y la repetición se detecta también cuando los dos valores son iguales: lo ambiguo no es
  # el valor, es que haya dos.
  sonda_lee "$base38 estado=ok estado=ok archivos=1" \
    && falla38="$falla38 <una clave repetida con el MISMO valor se aceptó>"
  # (2) Un valor con `*` llega LITERAL: si hubiera glob, el campo valdría un nombre de archivo
  # del `cwd` y el registro significaría cosas distintas según dónde se lea.
  if sonda_lee "$base38 estado=ok etiqueta=* archivos=1"; then
    [ "${SONDA[etiqueta]}" = '*' ] || falla38="$falla38 <etiqueta=* se expandió a <${SONDA[etiqueta]}>: el registro depende del cwd>"
  else
    falla38="$falla38 <un registro legítimo con un asterisco en un valor se rechazó: $SONDA_MOTIVO>"
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# QA-021-04, la mitad del EMISOR: el valor que transporta la inyección viene de FUERA
# —`--etiqueta`, `--ref`, y un `motivo=…:<ruta>` con una ruta del árbol medido—, así que se
# reduce a UN campo antes de emitir. Y con un salto de línea el registro salía en DOS y la
# segunda la contaba el `awk` de recuento como un caso: una sonda dictando veredicto.
nom38="REQ-021 CA-01.2/CA-01.3 un valor con espacios o saltos de línea no parte el registro ni fabrica un veredicto"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  reg38="$("$UTIL_DIR/sonda-reloj.sh" --k 1 --r 1 --sujeto ':' --etiqueta "$(printf 'x\n  PASS  inyectado estado=ok')" 2>/dev/null)"
  falla38=''
  n38=0
  while IFS= read -r linea38 || [ -n "$linea38" ]; do
    n38=$((n38 + 1))
    case "$linea38" in '  PASS  '*|'  FAIL  '*|'  SKIP  '*) falla38="$falla38 <el registro trae una línea con forma de caso>" ;; esac
  done <<< "$reg38"
  [ "$n38" -eq 1 ] || falla38="$falla38 <el registro salió en $n38 líneas>"
  if sonda_lee "$reg38"; then
    [ "${SONDA[estado]}" = suelo ] || falla38="$falla38 <la etiqueta inyectada cambió estado a ${SONDA[estado]}>"
    case "${SONDA[etiqueta]}" in *' '*) falla38="$falla38 <la etiqueta conserva un espacio y sigue siendo dos campos>" ;; esac
  else
    falla38="$falla38 <el registro con la etiqueta inyectada no se puede leer: $SONDA_MOTIVO>"
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (1 línea, etiqueta=${SONDA[etiqueta]}, estado=${SONDA[estado]} intacto)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# CA-01.4 · UN SOLO PARSER, Y EL README DE `tests/util/` APUNTA A ÉL SIN TRANSCRIBIRLO: dos
# transcripciones de la misma regla se desfasan (la familia de REQ-003 y REQ-009).
lee38="$UTIL_DIR/README.md"
falla38=''
if [ ! -r "$lee38" ]; then falla38=' no hay README en tests/util/'; else
  apunta38=no; transcribe38=no
  while IFS= read -r linea38 || [ -n "$linea38" ]; do
    case "$linea38" in *sonda_lee*) case "$linea38" in *run.sh*) apunta38=si ;; esac ;; esac
    case "$linea38" in *'${par%%='*|*'${par#*='*) transcribe38=si ;; esac
  done < "$lee38"
  [ "$apunta38" = si ] || falla38="$falla38 el README no apunta a sonda_lee en run.sh;"
  [ "$transcribe38" = no ] || falla38="$falla38 el README TRANSCRIBE el parser en vez de apuntar a él;"
fi
if [ -z "$falla38" ]; then
  echo "  PASS  REQ-021 CA-01.4 tests/util/README.md apunta al único parser (sonda_lee, en el corredor) y no lo transcribe"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-021 CA-01.4$falla38"; FAIL=$((FAIL+1))
fi

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

# ---------- CA-04 · NINGUNA SONDA SOBREVIVE A SU INVOCACIÓN, POR DESCENDENCIA ----------
# CON UN HIJO DIRECTO NO VALE: lo pasa una implementación ingenua, que es la que este
# criterio existe para descartar. El sujeto deja vivo un NIETO —el caso medido de 1.32.1 no
# era un proceso que la sonda lanzara, sino un descendiente creado por el sujeto—.
ABU38="$RAIZ/abuelo38-$BASHPID.sh"
printf '#!/usr/bin/env bash\nbash -c "exec sleep 120" &\nexec sleep 120\n' > "$ABU38"
chmod +x "$ABU38"
PIDA38="$RAIZ/pid38-a-$BASHPID"; PIDB38="$RAIZ/pid38-b-$BASHPID"
reg38="$("$UTIL_DIR/sonda-reloj.sh" --k 1 --r 1 --etiqueta nieto \
  --sujeto "bash '$ABU38' >/dev/null 2>&1 & echo \$! > '$PIDA38'; sleep 0.3" 2>/dev/null)"
pid38=''; [ -r "$PIDA38" ] && { read -r pid38 < "$PIDA38" || :; }
nom38="REQ-021 CA-04.1 la sonda mata y DECLARA a su descendencia hasta el NIETO, sin apoyarse en jobs"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  if ! sonda_lee "$reg38"; then falla38=" el registro no se puede leer: $SONDA_MOTIVO"
  else
    num38 "${SONDA[vivos]:-}" || falla38="$falla38 vivos=<${SONDA[vivos]:-vacío}> no es un número (un cero publicado y un campo ausente no son lo mismo);"
    [ "${SONDA[vivos]:-0}" -ge 2 ] || falla38="$falla38 declaró ${SONDA[vivos]:-0} vivos y el sujeto dejó al menos abuelo y nieto;"
    [ "${SONDA[descendencia]:-}" = ninguna ] && falla38="$falla38 no pudo recorrer la descendencia en esta plataforma;"
  fi
  if [ -n "$pid38" ] && kill -0 "$pid38" 2>/dev/null; then falla38="$falla38 el hijo directo SIGUIÓ VIVO tras la invocación;"; fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (vivos=${SONDA[vivos]}, mecanismo ${SONDA[descendencia]}; el sujeto deja abuelo y nieto y ninguno sobrevive)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi
# FAIL-BEFORE, y sin él lo de arriba no prueba nada: EL MISMO SUJETO sin esa mitad deja al
# nieto vivo. Se recoge a mano, porque si no envenenaría el reloj de la sección siguiente.
nom38="REQ-021 CA-04.1 fail-before: el mismo sujeto SIN la mitad de descendencia deja vivo al nieto"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  bash -c "bash '$ABU38' >/dev/null 2>&1 & echo \$! > '$PIDB38'; sleep 0.3" >/dev/null 2>&1
  pidb38=''; [ -r "$PIDB38" ] && { read -r pidb38 < "$PIDB38" || :; }
  nieto38=''
  [ -n "$pidb38" ] && [ -r "/proc/$pidb38/task/$pidb38/children" ] && { read -r nieto38 < "/proc/$pidb38/task/$pidb38/children" || :; }
  if [ -n "$pidb38" ] && kill -0 "$pidb38" 2>/dev/null; then
    echo "  PASS  $nom38  (PID $pidb38 y su descendencia siguen vivos sin la barrida; esta sección los recoge)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38  el sujeto no dejó nada vivo ni siquiera sin la barrida: el caso de arriba no prueba nada"; FAIL=$((FAIL+1))
  fi
  for p38 in $nieto38 $pidb38; do kill -9 "$p38" 2>/dev/null || :; done
fi
rm -f "$ABU38" "$PIDA38" "$PIDB38"

# CA-04.1 · Y EL DESCENDIENTE REPARENTADO, que el caso del nieto NO ejerce (QA-021-05).
# El sujeto del nieto deja al abuelo VIVO (`exec sleep 120`), así que la cadena de
# `/proc/<pid>/task/<tid>/children` está intacta y el recorrido lo alcanza: acredita «nieto»,
# no «reparentado». Con un DOBLE FORK el padre intermedio muere, el descendiente pasa a init
# y SALE del recorrido — medido en tres formas, las tres con `estado=ok vivos=0` publicado y
# el superviviente vivo. Es la tercera instancia de «un cero plausible con la descendencia
# viva» en este mismo criterio, después del `$BASHPID` dentro de `$( )` y del
# `read … || continue` sobre `children`; y el propio criterio nombra por su nombre la ceguera
# («ni lo que quedó reparentado»). El mecanismo elegido es una MARCA DE ENTORNO única por
# invocación: el entorno sobrevive a la reparentación y al cambio de sesión, así que caza las
# tres formas donde el grupo de procesos sólo cazaría dos.
MARCA38="$RAIZ/marca38-$BASHPID.sh"
printf '#!/usr/bin/env bash\nsh -c "(sleep 1200 & echo \\$! > \\"$1\\") & exit 0"\nexit 0\n' > "$MARCA38"
chmod +x "$MARCA38"
PIDC38="$RAIZ/pid38-c-$BASHPID"; PIDD38="$RAIZ/pid38-d-$BASHPID"
: > "$PIDC38"; : > "$PIDD38"
nom38="REQ-021 CA-04.1 el descendiente REPARENTADO se ve y se mata: el recorrido por children no lo alcanza y la marca de entorno sí"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  reg38="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta reparentado \
    --sujeto "bash '$MARCA38' '$PIDC38'; sleep 0.4; grep -q x /dev/null" 2>/dev/null)"
  pid38=''; read -r pid38 < "$PIDC38" 2>/dev/null || :
  falla38=''
  if ! sonda_lee "$reg38"; then falla38=" el registro no se puede leer: $SONDA_MOTIVO"
  else
    [ "${SONDA[estado]}" = ok ] || falla38="$falla38 estado=${SONDA[estado]} motivo=${SONDA[motivo]:-};"
    [ "${SONDA[vivos]:-0}" -ge 1 ] || falla38="$falla38 publicó vivos=${SONDA[vivos]:-?} con un descendiente reparentado vivo (el cero plausible);"
    case "${SONDA[descendencia]:-}" in *marca*) ;; *) falla38="$falla38 el mecanismo publicado (${SONDA[descendencia]:-vacío}) no incluye la marca;" ;; esac
  fi
  if [ -n "$pid38" ] && kill -0 "$pid38" 2>/dev/null; then
    falla38="$falla38 el reparentado (PID $pid38) SIGUIÓ VIVO tras la invocación;"
    kill -9 "$pid38" 2>/dev/null || :
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (vivos=${SONDA[vivos]}, mecanismo ${SONDA[descendencia]}; el doble fork lo reparenta a init y no sobrevive)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi
# FAIL-BEFORE del reparentado, sobre una COPIA y sin tocar el árbol: a la sonda se le quita
# la mitad de la marca —se deja SÓLO el recorrido por `children`, que es lo que había hasta la
# vuelta 1— y el mismo sujeto tiene que publicar `vivos=0` CON EL DESCENDIENTE VIVO. Sin esta
# mitad, el caso de arriba probaría que la sonda mata algo, no que ve lo que antes no veía.
nom38="REQ-021 CA-04.1 fail-before: sin la marca de entorno, el MISMO sujeto publica vivos=0 con el reparentado vivo"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  CIEGA38="$RAIZ/ciega38-$BASHPID"
  mkdir -p "$CIEGA38" 2>/dev/null
  falla38=''
  # La mutación deja el recorrido de `children` intacto y neutraliza la comparación de la
  # marca, que es la única mitad que ve al reparentado.
  if ! sed 's|\[ "\$sp_v" = "ARNES_SONDA_MARCA=\$SP_MARCA" \]|[ "$sp_v" = "ARNES_SONDA_MARCA=nunca-coincide" ]|' \
        "$UTIL_DIR/sonda-procesos.sh" > "$CIEGA38/ciega.sh" 2>/dev/null; then
    falla38=' no se pudo escribir la copia'
  else
    chmod +x "$CIEGA38/ciega.sh" 2>/dev/null
    cmp -s "$UTIL_DIR/sonda-procesos.sh" "$CIEGA38/ciega.sh" \
      && falla38=' la mutación NO se aplicó: el fail-before no probaría nada'
  fi
  if [ -z "$falla38" ]; then
    reg38="$("$CIEGA38/ciega.sh" --dir-trabajo "$CIEGA38" --etiqueta reparentado-ciego \
      --sujeto "bash '$MARCA38' '$PIDD38'; sleep 0.4; grep -q x /dev/null" 2>/dev/null)"
    pidd38=''; read -r pidd38 < "$PIDD38" 2>/dev/null || :
    if sonda_lee "$reg38"; then
      [ "${SONDA[vivos]:-1}" -eq 0 ] || falla38="$falla38 la copia ciega ya declaró ${SONDA[vivos]} vivos: no reproduce el defecto;"
    else falla38="$falla38 el registro de la copia ciega no se puede leer: $SONDA_MOTIVO;"; fi
    if [ -n "$pidd38" ] && kill -0 "$pidd38" 2>/dev/null; then
      kill -9 "$pidd38" 2>/dev/null || :
    else
      falla38="$falla38 sin la marca el reparentado tampoco sobrevivió: el caso de arriba no prueba nada;"
    fi
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (la copia sin la marca publica vivos=0 y deja el proceso vivo; esta sección lo recoge)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
  rm -rf "$CIEGA38"
fi
rm -f "$MARCA38" "$PIDC38" "$PIDD38"

# CA-04.4 · EL DIRECTORIO DE ENVOLTORIOS SE RETIRA TAMBIÉN EN LOS CAMINOS DE ERROR, y su
# nombre sale de su propio proceso: con nombre fijo es la clase de REQ-015 aplicada a
# EJECUTABLES, con el corredor corriendo secciones en paralelo.
nom38="REQ-021 CA-04.4 el directorio de envoltorios es privado y se retira también en el camino de error"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  # EL DIRECTORIO DE TRABAJO DE ESTE CASO ES PROPIO, y eso no es limpieza: es la condición
  # para que el recuento signifique algo. Contado sobre `$RAIZ` —que 37/2 comparte y usa con
  # esta misma sonda mientras el corredor corre las secciones EN PARALELO— el glob veía
  # directorios de OTRA invocación viva y el caso salía rojo sin que nada estuviera roto
  # (medido al añadir los casos de esta vuelta). Es la clase de REQ-015 —el temporal
  # compartido— entrando esta vez por el LECTOR en vez de por el escritor.
  TRAB38="$RAIZ/trab38-$BASHPID"
  mkdir -p "$TRAB38" 2>/dev/null
  reg38="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$TRAB38" 2>/dev/null)"
  quedan38=0
  shopt -s nullglob
  for f38 in "$TRAB38"/sonda-procesos-*; do quedan38=$((quedan38 + 1)); done
  shopt -u nullglob
  rm -rf "$TRAB38"
  falla38=''
  sonda_lee "$reg38" || falla38=" el registro del camino de error no se puede leer: $SONDA_MOTIVO"
  [ "${SONDA[estado]:-}" = sin-sujeto ] || falla38="$falla38 el camino de error dio estado=${SONDA[estado]:-vacío};"
  [ "$quedan38" -eq 0 ] || falla38="$falla38 quedaron $quedan38 directorios de envoltorios detrás;"
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (estado=sin-sujeto y 0 directorios sonda-procesos-* en el temporal de la vuelta)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# CA-04.5 · UN COMPONENTE VACÍO O RELATIVO DEL PATH PONE EL DIRECTORIO DE TRABAJO DELANTE
# DE LOS BINARIOS REALES. La sonda lo DICE en vez de devolver un número.
nom38="REQ-021 CA-04.5 un PATH con componente vacío o relativo no se mide: se dice"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  for p38 in ":$PATH" "$PATH:" "$PATH::/bin" ".:$PATH"; do
    reg38="$(PATH="$p38" "$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --sujeto 'grep -q x /dev/null || :' 2>/dev/null)"
    if ! sonda_lee "$reg38" || [ "${SONDA[estado]:-}" != path-inseguro ]; then
      falla38="$falla38 <PATH '${p38:0:12}…' dio estado=${SONDA[estado]:-ilegible}>"
    fi
  done
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (las cuatro formas —':' inicial, ':' final, '::' y '.'— dan estado=path-inseguro, ninguna un número)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# CA-04.3 · LA COMPROBACIÓN DE RECURSIÓN SE HACE SOBRE LA RUTA QUE QUEDA ESCRITA EN EL
# ENVOLTORIO GENERADO, no sólo sobre la resolución previa: un envoltorio que RE-RESUELVE por
# `PATH` en tiempo de llamada reproduce el incidente de 1.32.1 con la resolución impecable.
nom38="REQ-021 CA-04.3 las rutas se resuelven con type -P y el envoltorio generado lleva la ruta ABSOLUTA, no una re-resolución por PATH"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  txt38="$UTIL_DIR/sonda-procesos.sh"
  if [ ! -r "$txt38" ]; then falla38=' no existe sonda-procesos.sh'; else
    tipoP38=no; comandov38=no; relee38=no
    while IFS= read -r linea38 || [ -n "$linea38" ]; do
      case "$linea38" in \#*) continue ;; esac
      case "$linea38" in *'type -P'*) tipoP38=si ;; esac
      case "$linea38" in *'command -v'*) comandov38=si ;; esac
      case "$linea38" in *'ruta-dentro-del-envoltorio'*|*'ruta-no-absoluta-en-el-envoltorio'*) relee38=si ;; esac
    done < "$txt38"
    [ "$tipoP38" = si ]    || falla38="$falla38 no usa type -P;"
    [ "$comandov38" = no ] || falla38="$falla38 usa command -v, que VE funciones de shell;"
    [ "$relee38" = si ]    || falla38="$falla38 no comprueba la ruta escrita en el envoltorio generado;"
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-02 · EL ESTADÍSTICO Y LA MUESTRA QUE NO ES PUBLICABLE ----------
nom38="REQ-021 CA-02.5 una muestra MIXTA —reloj bajo instrumentación de procesos— no es publicable"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  reg38="$(ARNES_SONDA_INSTRUMENTANDO=1 "$UTIL_DIR/sonda-reloj.sh" --k 1 --r 1 --sujeto ':' 2>/dev/null)"
  falla38=''
  sonda_lee "$reg38" || falla38=" el registro no se puede leer: $SONDA_MOTIVO"
  [ "${SONDA[estado]:-}" = mixta ] || falla38="$falla38 estado=${SONDA[estado]:-vacío} en vez de mixta;"
  [ "${SONDA[instrumentada]:-}" = si ] || falla38="$falla38 el registro no declara que la muestra estuvo instrumentada;"
  [ "${SONDA[min]:-}" = desconocido ] || falla38="$falla38 publicó un número (min=${SONDA[min]:-}) bajo instrumentación;"
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (un envoltorio por proceso mide el envoltorio: estado=mixta, instrumentada=si y sin número)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

nom38="REQ-021 CA-02.1/CA-02.4 el mínimo lo impone la sonda —no hay vía para pedir la media— y bajo el suelo no publica número"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  reg38="$("$UTIL_DIR/sonda-reloj.sh" --k 1 --r 3 --sujeto ':' 2>/dev/null)"
  falla38=''
  sonda_lee "$reg38" || falla38=" el registro no se puede leer: $SONDA_MOTIVO"
  [ "${SONDA[estado]:-}" = suelo ] || falla38="$falla38 un sujeto trivial dio estado=${SONDA[estado]:-vacío} en vez de suelo;"
  num38 "${SONDA[min]:-}" || falla38="$falla38 el estado=suelo no vino con el número que sí obtuvo;"
  media38=no
  while IFS= read -r linea38 || [ -n "$linea38" ]; do
    case "$linea38" in \#*) continue ;; esac
    case "$linea38" in *--media*|*promedio*) media38=si ;; esac
  done < "$UTIL_DIR/sonda-reloj.sh"
  [ "$media38" = no ] || falla38="$falla38 la sonda ofrece una vía para pedir la media;"
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (estado=suelo con min=${SONDA[min]}µs bajo el suelo de ${SONDA[suelo]:-?}µs, y ninguna opción de media)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

nom38="REQ-021 CA-02.2/CA-02.3/CA-06 con DOS sujetos las series se alternan a,b,a,b y el registro trae los dos mínimos, los máximos, la razón y sus condiciones"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  reg38="$("$UTIL_DIR/sonda-reloj.sh" --k 1 --r 2 --etiqueta dos-sujetos \
    --sujeto-a "for ((SR_CAL_I = 0; SR_CAL_I < ${ARNES_SONDA_CAL_N:-200000}; SR_CAL_I++)); do :; done" \
    --sujeto-b "for ((SR_CAL_I = 0; SR_CAL_I < ${ARNES_SONDA_CAL_N:-200000}; SR_CAL_I++)); do :; done" 2>/dev/null)"
  falla38=''
  if ! sonda_lee "$reg38"; then falla38=" el registro no se puede leer: $SONDA_MOTIVO"
  elif [ "${SONDA[estado]}" != ok ]; then falla38=" estado=${SONDA[estado]} motivo=${SONDA[motivo]:-}"
  else
    for c38 in min_a max_a min_b max_b razon k r disp carga jobs corrida arbol plataforma; do
      [ -n "${SONDA[$c38]:-}" ] || falla38="$falla38 falta el campo $c38;"
    done
    num38 "${SONDA[razon]:-}" || falla38="$falla38 razon=<${SONDA[razon]:-vacío}> no es un número;"
    [ "${SONDA[r]:-0}" = 2 ] || falla38="$falla38 r=${SONDA[r]:-} en vez de 2;"
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (razón $(awk -v c="${SONDA[razon]}" 'BEGIN{printf "%.3f", c/1000}')× entre dos sujetos idénticos, con carga=${SONDA[carga]} y corrida declarada)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-10 · UNA SONDA QUE NO PUEDE MEDIR NO SE CONVIERTE EN PASS RÍO ABAJO ----
# Con entradas SINTÉTICAS y en milisegundos, como `valida47` y `veredicto47` de 37/2: una
# puerta que sólo se ejerce cuando alguien enciende una palanca es una puerta de la que nadie
# sabe si cierra. `estado` distinto de `ok` dice «no pude medir» —instrumento funcionando,
# SKIP—; un registro vacío o ilegible dice «no me ejecuté» —FAIL—; y una corrida sin
# calibración de su instrumento dice «no sé si estoy midiendo el sujeto» —FAIL—.
nom38="REQ-021 CA-10 el juez: estado≠ok es SKIP con motivo, registro vacío, ilegible o AMBIGUO es FAIL, y una corrida sin su calibración también"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  base38="sonda=reloj modo=medicion corrida=$ARNES_CORRIDA invocacion=i us=100000 procesos=0 vivos=0 min=90000"
  obs38="$( {
    sonda_usable p "$base38 estado=ok"            && echo "  PASS  usable"
    sonda_usable p "$base38 estado=suelo motivo=serie-bajo-el-suelo"   && echo "  PASS  no-deberia"
    sonda_usable p "$base38 estado=sin-linea-base motivo=x"            && echo "  PASS  no-deberia"
    sonda_usable p "$base38 estado=plazo-agotado motivo=x"             && echo "  PASS  no-deberia"
    sonda_usable p ""                                                   && echo "  PASS  no-deberia"
    sonda_usable p "ni un solo campo"                                   && echo "  PASS  no-deberia"
    sonda_usable p "sonda=reloj modo=medicion estado=ok corrida=$ARNES_CORRIDA invocacion=i procesos=0 vivos=0" && echo "  PASS  no-deberia"
    sonda_usable p "sonda=reloj modo=medicion estado=ok corrida=de-ayer invocacion=i us=1 procesos=0 vivos=0"   && echo "  PASS  no-deberia"
    sonda_usable p "sonda=inventada modo=medicion estado=ok corrida=$ARNES_CORRIDA invocacion=i us=1 procesos=0 vivos=0" && echo "  PASS  no-deberia"
    # QA-021-04, río abajo: el registro AMBIGUO por inyección —un `estado=ok` pisando el
    # verdadero— ya no llega al juez como medición: es ilegible, y lo ilegible es FAIL.
    sonda_usable p "$base38 estado=sin-linea-base motivo=la-ruta-no-existe estado=ok"      && echo "  PASS  no-deberia"
    # CA-10 punto 2, las tres ramas de `vivos` en un instrumento de tests/util/:
    # AUSENTE -> FAIL (ilegible, nunca un cero) · >0 en MEDICIÓN -> SKIP con el número.
    sonda_usable p "sonda=reloj modo=medicion estado=ok corrida=$ARNES_CORRIDA invocacion=i us=1 procesos=0"    && echo "  PASS  no-deberia"
    sonda_usable p "sonda=reloj modo=medicion estado=ok corrida=$ARNES_CORRIDA invocacion=i us=1 procesos=0 vivos=3" && echo "  PASS  no-deberia"
    # …y el materializador INLINE de CA-05, que NO puede observar `vivos`, sí pasa sin él:
    # el campo se enuncia sobre el EMISOR y no sobre el formato.
    sonda_usable p "sonda=linea-base modo=medicion estado=ok corrida=$ARNES_CORRIDA invocacion=i us=1 procesos=6 archivos=42" && echo "  PASS  usable"
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp38='PASS SKIP SKIP SKIP FAIL FAIL FAIL FAIL FAIL FAIL FAIL SKIP PASS '
  if [ "$obs38" = "$esp38" ]; then
    echo "  PASS  $nom38  (13 registros → $obs38)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38  se esperaba <$esp38> y se obtuvo <$obs38>"; FAIL=$((FAIL+1))
  fi
fi

# CA-10 punto 2, la TERCERA rama: `vivos > 0` en un registro de CALIBRACIÓN es FAIL, no SKIP.
# Una calibración tomada con descendencia viva no acredita que el instrumento responda al
# sujeto, y por CA-03 punto 5 arrastra a todas las mediciones de su corrida — mientras una
# MEDICIÓN con `vivos > 0` sólo se abstiene. La distinción no es un matiz: es la diferencia
# entre «este número está contaminado» y «no sé si estoy midiendo el sujeto».
nom38="REQ-021 CA-10.2 vivos>0 en una CALIBRACIÓN es FAIL y en una MEDICIÓN es SKIP: no es el mismo hecho"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  if ! sonda_lee "$CALREL38"; then falla38=" la calibración de reloj no se puede leer: $SONDA_MOTIVO"
  else
    [ "${SONDA[vivos]}" = 0 ] || falla38="$falla38 la calibración real de esta corrida trae vivos=${SONDA[vivos]};"
    vivo38="${CALREL38/ vivos=0 / vivos=2 }"
    [ "$vivo38" != "$CALREL38" ] || falla38="$falla38 no se pudo construir el registro con descendencia viva;"
  fi
  if [ -z "$falla38" ]; then
    if sonda_calibracion_falla reloj "$vivo38" "$TSTREL38"; then
      case "$SONDA_CAL_MOTIVO" in *'descendientes VIVOS'*) ;; *) falla38="$falla38 falla, pero por otro motivo: $SONDA_CAL_MOTIVO;" ;; esac
    else
      falla38="$falla38 una calibración con vivos=2 se aceptó;"
    fi
    if sonda_calibracion_falla reloj "$CALREL38" "$TSTREL38"; then
      falla38="$falla38 la calibración real se rechazó: $SONDA_CAL_MOTIVO;"
    fi
  fi
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  (la misma calibración con vivos=2 es FAIL y con vivos=0 pasa; en medición el mismo hecho da SKIP, arriba)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `sonda_usable` corrió dentro de una sustitución de
# comandos, que es un subshell, y sus PASS/FAIL murieron con él.
