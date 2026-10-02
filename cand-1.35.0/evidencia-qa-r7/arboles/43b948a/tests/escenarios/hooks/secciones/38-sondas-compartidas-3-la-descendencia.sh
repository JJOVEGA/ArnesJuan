# ---------- 38 (3/3) · LOS INSTRUMENTOS COMPARTIDOS: LA DESCENDENCIA Y EL JUEZ ----------
# REQ-021. Que ninguna sonda sobreviva a su invocación —ni el nieto, ni el descendiente
# REPARENTADO por doble fork, que el recorrido por `children` no alcanza (CA-04)—; que el
# estadístico sea el mínimo y una muestra mixta no sea publicable (CA-02); y que lo que la
# sonda no pudo hacer NO se convierta en un PASS río abajo (CA-10).
#
# EL JUEZ SE EJERCE CON ENTRADAS SINTÉTICAS Y EN MILISEGUNDOS, igual que `valida47` y
# `veredicto47` de `37/4`: una puerta que sólo se ejerce cuando alguien enciende una palanca
# es una puerta de la que nadie sabe si cierra.
#
# PARTE 3 DE 3 POR REQ-014 CA-18; el motivo de la partición y el reparto de los 32 casos
# están escritos una sola vez, en `38-sondas-compartidas-1-el-registro.sh`. `num38` y las
# DOS lecturas de la calibración de reloj de esta corrida vienen duplicadas a propósito
# —CA-04, CA-19 y H-04 de REQ-014 hacen imposible factorizarlas—: son registros que el
# corredor ya dejó en disco antes de despachar, así que leerlos no cuesta un proceso.
CASOS_ESPERADOS_SECCION=12
PISO_AUTONOMO_SECCION=103  # 19 preámbulo (líneas 1-19) + 6 maquinaria compartida duplicada (num38 y las dos lecturas de la calibración de reloj, líneas 20-25) + 78 bloque indivisible mayor (CA-04.1 el descendiente REPARENTADO con su fail-before sobre una copia mutada, líneas 71-148) · REQ-014 CA-18
seccion_nueva "--- 38/3 · los instrumentos de tests/util/: la descendencia, el estadístico y el juez (REQ-021 CA-04, CA-02 y CA-10) ---"

num38() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# Los registros y los testigos de ESTA corrida, leídos una vez. Cuestan cero procesos.
CALREL38=''; CALPRO38=''; TSTREL38=''; TSTPRO38=''
[ -r "$RAIZ/cal-reloj" ]       && { IFS= read -r CALREL38 < "$RAIZ/cal-reloj" 2>/dev/null || :; }
[ -r "$RAIZ/testigo-reloj" ]   && { read -r TSTREL38 < "$RAIZ/testigo-reloj" 2>/dev/null || :; }

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
