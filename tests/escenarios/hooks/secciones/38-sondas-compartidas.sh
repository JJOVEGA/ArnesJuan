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
CASOS_ESPERADOS_SECCION=21
seccion_nueva "--- 38 · las tres sondas de tests/util/: calibración, descendencia y el juez (REQ-021) ---"

num38() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
shopt -s nullglob; UTILES38=( "$UTIL_DIR"/*.sh ); shopt -u nullglob

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
# Se leen los TRES registros de calibración que el corredor ya tomó en esta corrida: no
# cuesta un solo proceso, y son registros reales, no imitaciones. El diagnóstico va por la
# salida de error, y tampoco ahí puede llevar la forma con la que el corredor cuenta casos:
# una sonda es el brazo, no el juez.
regs38=0; lineas38=0; veredicto38=''
for inst38 in reloj procesos linea-base; do
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
if [ "$regs38" -eq 3 ] && [ "$lineas38" -eq 3 ] && [ -z "$veredicto38" ]; then
  echo "  PASS  REQ-021 CA-01.2/CA-01.3 las tres sondas emiten UN registro de UNA línea y ninguna imprime una línea con la forma que el corredor usa para contar casos"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-021 CA-01.2/CA-01.3 $regs38 registros y $lineas38 líneas (se esperaban 3 y 3); líneas con forma de caso:${veredicto38:- ninguna}"; FAIL=$((FAIL+1))
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
if [ -z "$falla38" ]; then
  echo "  PASS  REQ-021 CA-01.5 el parser valida cada campo POR SEPARADO: ausente, vacío y no numérico son errores con motivo, nunca un cero"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-021 CA-01.5 el parser dejó pasar:$falla38"; FAIL=$((FAIL+1))
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
sonda_juzga_calibracion "REQ-021 CA-03 calibración de sonda-linea-base.sh: el sujeto sensible responde al parámetro y el insensible no" linea-base

# ---------- CA-08 (iii) · CALIBRAR NO CUESTA MÁS DE 4× UNA MEDICIÓN ----------
# EN RELOJ Y EN PROCESOS, los dos en la misma corrida. Es la única mitad de CA-08 que no
# depende de una referencia congelada, así que corre SIEMPRE — y es el único indicador
# MEDIBLE de la identidad de camino de CA-03.4: una calibración que cuesta bastante más que
# cuatro mediciones no está recorriendo el camino de la medición.
TECHO38=4000   # ‰. OPERATIVO: se baja con la medición.
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
  # 0 sobre 0 es conforme y no es una razón: la sonda de reloj no lanza subprocesos propios.
  if [ "$mpr" -eq 0 ]; then rp=$(( cpr == 0 ? 0 : TECHO38 + 1 )); else rp=$(( cpr * 1000 / mpr )); fi
  if [ "$rr" -le "$TECHO38" ] && [ "$rp" -le "$TECHO38" ]; then
    echo "  PASS  $nombre  reloj $(awk -v c=$rr 'BEGIN{printf "%.3f", c/1000}')× (${cus}µs sobre ${mus}µs) y procesos $(awk -v c=$rp 'BEGIN{printf "%.3f", c/1000}')× ($cpr sobre $mpr), techo 4,000×"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  reloj $(awk -v c=$rr 'BEGIN{printf "%.3f", c/1000}')× (${cus}µs sobre ${mus}µs) y procesos $(awk -v c=$rp 'BEGIN{printf "%.3f", c/1000}')× ($cpr sobre $mpr) contra el techo 4,000×"; FAIL=$((FAIL+1))
  fi
}
# La medición de referencia usa LOS MISMOS MANDOS y EL MISMO SUJETO BASE que la calibración:
# es uno de los cuatro ejercicios, que es lo que «una medición de ese mismo instrumento»
# designa cuando el denominador no se quiere elegir a conveniencia.
mrel38="$("$UTIL_DIR/sonda-reloj.sh" --k 1 --r 3 --etiqueta referencia-iii \
  --prep "SR_CAL_N=${ARNES_SONDA_CAL_N:-200000}" \
  --sujeto 'for ((SR_CAL_I = 0; SR_CAL_I < SR_CAL_N; SR_CAL_I++)); do :; done' 2>/dev/null)"
iii38 "REQ-021 CA-08 (iii) calibrar sonda-reloj.sh no cuesta más de 4× una medición suya, en reloj y en procesos" reloj "$mrel38"

REQ38="$PROJ/requirements/REQ-380.md"
printf '# REQ-380\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nRigor: estandar\n' > "$REQ38"
JSON38="$RAIZ/json38-$BASHPID.json"
jq -n --arg fp "$REQ38" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.NADA,
  tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$JSON38" 2>/dev/null
mpro38="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta referencia-iii \
  --sujeto "CLAUDE_PROJECT_DIR='$PROJ' bash '$HOOKS_DIR/guard-completado.sh' < '$JSON38'" 2>/dev/null)"
iii38 "REQ-021 CA-08 (iii) calibrar sonda-procesos.sh no cuesta más de 4× una medición suya, en reloj y en procesos" procesos "$mpro38"

LB38="$RAIZ/lb38-$BASHPID"
mlb38="$("$UTIL_DIR/sonda-linea-base.sh" --ref HEAD --destino "$LB38" --rutas hooks --etiqueta referencia-iii 2>/dev/null)"
iii38 "REQ-021 CA-08 (iii) calibrar sonda-linea-base.sh no cuesta más de 4× una medición suya, en reloj y en procesos" linea-base "$mlb38"

# ---------- CA-05 · MEDIA LÍNEA BASE ES PEOR QUE NINGUNA ----------
nom38="REQ-021 CA-05 la sonda de línea base materializa entero, publica cuántos archivos dejó y dice con MOTIVO cuando no puede"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  falla38=''
  if ! sonda_lee "$mlb38"; then falla38=" la medición no se puede leer: $SONDA_MOTIVO"
  elif [ "${SONDA[estado]}" != ok ]; then falla38=" la medición de HEAD no salió ok: ${SONDA[estado]}/${SONDA[motivo]:-}"
  else
    arch38="${SONDA[archivos]}"
    reales38=0
    shopt -s nullglob
    for f38 in "$LB38"/hooks/*; do reales38=$((reales38 + 1)); done
    shopt -u nullglob
    num38 "$arch38" && [ "$arch38" -ge 1 ] || falla38="$falla38 archivos=<${arch38:-vacío}>;"
    [ "$reales38" -eq "${arch38:-0}" ] || falla38="$falla38 dice $arch38 archivos y en disco hay $reales38;"
    [ -x "$LB38/hooks/guard-codigo.sh" ] || falla38="$falla38 un script materializado quedó SIN bit de ejecución (git show escribe el contenido, no el modo);"
  fi
  reg38="$("$UTIL_DIR/sonda-linea-base.sh" --ref no-existe-esta-referencia-38 --destino "$RAIZ/lb38x" 2>/dev/null)"
  if sonda_lee "$reg38"; then
    [ "${SONDA[estado]}" = sin-linea-base ] || falla38="$falla38 una referencia que no resuelve dio estado=${SONDA[estado]};"
    [ "${SONDA[motivo]}" != '-' ] || falla38="$falla38 sin-linea-base sin motivo;"
    [ "${SONDA[archivos]}" = desconocido ] || falla38="$falla38 publicó archivos=${SONDA[archivos]} sin haber materializado;"
  else falla38="$falla38 el registro de la referencia inexistente no se puede leer;"; fi
  [ -e "$RAIZ/lb38x" ] && falla38="$falla38 dejó un árbol parcial detrás;"
  if [ -z "$falla38" ]; then
    echo "  PASS  $nom38  ($arch38 archivos verificados contra el objeto del árbol de HEAD, todos ejecutables; y la referencia que no resuelve da sin-linea-base con motivo y sin árbol)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38 :$falla38"; FAIL=$((FAIL+1))
  fi
fi
rm -rf "$LB38" "$RAIZ/lb38x"

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

# CA-04.4 · EL DIRECTORIO DE ENVOLTORIOS SE RETIRA TAMBIÉN EN LOS CAMINOS DE ERROR, y su
# nombre sale de su propio proceso: con nombre fijo es la clase de REQ-015 aplicada a
# EJECUTABLES, con el corredor corriendo secciones en paralelo.
nom38="REQ-021 CA-04.4 el directorio de envoltorios es privado y se retira también en el camino de error"
if [ -z "$FILTRO" ] || printf '%s' "$nom38" | grep -qi -- "$FILTRO"; then
  reg38="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" 2>/dev/null)"
  quedan38=0
  shopt -s nullglob
  for f38 in "$RAIZ"/sonda-procesos-*; do quedan38=$((quedan38 + 1)); done
  shopt -u nullglob
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
nom38="REQ-021 CA-10 el juez: estado≠ok es SKIP con motivo, registro vacío o ilegible es FAIL, y una corrida sin su calibración también"
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
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp38='PASS SKIP SKIP SKIP FAIL FAIL FAIL FAIL FAIL '
  if [ "$obs38" = "$esp38" ]; then
    echo "  PASS  $nom38  (9 registros → $obs38)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom38  se esperaba <$esp38> y se obtuvo <$obs38>"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `sonda_usable` corrió dentro de una sustitución de
# comandos, que es un subshell, y sus PASS/FAIL murieron con él.
rm -f "$JSON38" "$REQ38"
