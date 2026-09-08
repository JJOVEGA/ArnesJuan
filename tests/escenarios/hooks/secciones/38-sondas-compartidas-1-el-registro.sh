# ---------- 38 (1/3) · LOS INSTRUMENTOS COMPARTIDOS: EL REGISTRO Y SU PARSER ----------
# REQ-021. Una sonda que mide mal DEVUELVE UN NÚMERO PLAUSIBLE, y las siete instancias de la
# ventana 1.32.1–1.33.0 tienen la misma forma: el instrumento medía algo real y había dejado
# de responder al sujeto. Esta parte cubre la mitad de FORMA: que los instrumentos se puedan
# invocar (CA-09), que emitan UN registro de UNA línea sin dictar veredicto (CA-01), y que el
# parser único no se pueda inyectar ni confundir un campo ausente con un cero.
#
# LAS QUALITY GATES DEL MANIFIESTO NO MIRAN `tests/` y `.arnes/config.json` NO SE TOCA
# (CA-09): es código protegido bajo gate humano, y una entrada en `PENDING_APPROVAL.md`
# deniega el cierre de cualquier REQ mientras exista. La cobertura se consigue donde ya hay
# una puerta requerida corriendo, que es aquí.
#
# PARTIDA EN TRES POR REQ-014 CA-18. La sección 38 medía 828 líneas contra un techo de 400
# —su piso, 133, no llega a 320 = N/k, así que su techo lo pone `N` y no `piso × k`— y NO
# cabe en dos: dos mitades salen a ~424 líneas. Los cortes van por tema y en puntos sin
# dependencias cruzadas: ninguna parte usa un nombre definido en otra (verificado, el mismo
# precedente que las secciones 28 y 33). Los 32 casos se REPARTEN —7 aquí, 13 en la
# calibración y 12 en la descendencia—; no se crea ni se pierde ninguno, y `CASOS_ESPERADOS`
# del corredor no cambia. `num38` viene duplicado en las tres a propósito: CA-04, CA-19 y
# H-04 de REQ-014 hacen imposible factorizarlo.
CASOS_ESPERADOS_SECCION=7
PISO_AUTONOMO_SECCION=65  # 24 preámbulo (líneas 1-24) + 7 maquinaria compartida duplicada (num38 y el conjunto que define el DIRECTORIO, líneas 25-31) + 34 bloque indivisible mayor (QA-021-04, las tres inyecciones del parser en un solo caso, líneas 119-152) · REQ-014 CA-18
seccion_nueva "--- 38/1 · los instrumentos de tests/util/: el registro y su parser (REQ-021 CA-09 y CA-01) ---"

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
