# Sección 36 (2 de 5) del banco — 36-cabecera-comentario-html-2-los-lectores
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
#
# Las otras cuatro mitades: `36-…-1-la-puerta.sh`, `36-…-3-comentar-retira.sh` y
# `36-…-5-el-cr-que-no-termina.sh` certifican QUÉ DECIDE la puerta, y
# `36-…-4-el-informe-y-los-textos.sh`, lo que el informe dice, el coste y lo que hereda un
# proyecto que ya corrió una versión afectada. Aquí, y sólo aquí, lo que la MÁQUINA LEE: que
# los dos lectores del arnés dicen lo mismo campo a campo y la INVARIANTE sobre el corpus de
# cabeceras del banco. (La 5 trae ADEMÁS un diferencial propio, acotado a la rebanada del CR
# que su guarda toca; no sustituye a éste, que recorre el corpus entero.)
CASOS_ESPERADOS_SECCION=4

# --- REQ-016: LA CABECERA TIENE NOCION DE CITA ---------------------------------------
# La regresion que esta seccion certifica, dicha sin adornos: un REQ `critico` cuyo
# veredicto de seguridad vigente NO autorizaba el cierre CERRABA si en su cabecera habia
# un rango `<!-- ... -->` con una linea que empezara por la clave del campo y un valor
# autorizante — incluso diciendo el propio comentario que era historico. Bisecada por un
# proyecto consumidor ejecutando cuatro guardianes instalados contra el mismo payload:
# 1.30.2 y 1.30.3 deniegan, 1.31.0 permite, 1.32.0 lo hereda.
#
# FAIL-BEFORE: los casos de esta seccion se corren contra los hooks heredados con
#   ARNES_HOOKS_DIR=/ruta/a/los/hooks/de/1.32.0 bash tests/escenarios/hooks/run.sh secciones/36-*.sh
# y los que llevan «(era ALLOW)» en el nombre TIENEN que fallar ahi. Un caso nuevo que
# pasa con los hooks viejos no esta probando lo que uno cree (README del banco).
  seccion_nueva "Noción de cita (2/5): los dos lectores y la invariante sobre el corpus (REQ-016):"

# ---------- CA-01 · LOS DOS LECTORES DICEN LO MISMO, campo a campo ----------
# El defecto que este arnes existe para cazar es que un lector lea distinto de otro: la
# puerta usa el de `hooks/lib.sh` y el bloque derivado usa `hooks/campos-req.awk`, que es su
# TRANSCRIPCION DECLARADA y no una segunda regla. Aqui se alimenta el MISMO documento a los
# dos y se comparan los seis campos ya normalizados por la MISMA cola
# (`arnes_campos_normaliza`), que es el camino real de las dos bocas.
LEE36="$RAIZ/lee36-$BASHPID.sh"
cat > "$LEE36" <<'SONDA36'
#!/usr/bin/env bash
set -uo pipefail
H="$1"; modo="$2"; f="$3"
# shellcheck source=/dev/null
. "$H/lib.sh"
texto=''; IFS= read -r -d '' texto < "$f" || :
if [ "$modo" = lib ]; then
  arnes_estado_cabecera "$texto"; est="$ARNES_ESTADO"
  arnes_campos_req "$texto" ''
else
  linea="$(awk -f "$H/campos-req.awk" "$f")"
  IFS=$'\001' read -r _ruta c_est c_qa c_seg c_sens c_hall c_rig <<< "$linea"
  arnes_norm_campo "$c_est"; arnes_veredicto "$ARNES_CAMPO"; est="$ARNES_VEREDICTO"
  arnes_campos_normaliza "$c_qa" "$c_seg" "$c_sens" "$c_hall" "$c_rig"
fi
printf 'Estado=<%s> QA=<%s> Seg=<%s> Sens=<%s> Hall=<%s> Rigor=<%s>\n' \
  "$est" "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR"
SONDA36

# Los pares del corpus: <documento CON el rango> y <el mismo SIN el rango>. Van en dos
# arrays paralelos separados por \001 para que ningun salto de linea los parta.
CON36=(); SIN36=()
par36() { CON36+=("$1"); SIN36+=("$2"); }
par36 '# R
Estado: en-revisión
QA: aprobado
Seguridad: con-hallazgos
<!-- **Seguridad:** aprobado -->' '# R
Estado: en-revisión
QA: aprobado
Seguridad: con-hallazgos'
par36 '# R
Estado: en-revisión
<!--
**QA:** aprobado
**Seguridad:** aprobado
**Rigor:** ligero
-->
QA: pendiente
Seguridad: pendiente
Sensible a seguridad: sí' '# R
Estado: en-revisión
QA: pendiente
Seguridad: pendiente
Sensible a seguridad: sí'
par36 '# R
Estado: en-revisión <!-- se cerró el 3 -->
QA: aprobado
Seguridad: n/a
Hallazgos abiertos: <!-- SEC-9 (usuario/dinero) --> (ninguno)' '# R
Estado: en-revisión
QA: aprobado
Seguridad: n/a
Hallazgos abiertos:  (ninguno)'
par36 '# R
<!-- Estado: completado -->
Estado: en-revisión
QA: aprobado
Seguridad: n/a' '# R
Estado: en-revisión
QA: aprobado
Seguridad: n/a'
par36 '# R
Estado: en-revisión
QA: aprobado <!-- ronda 1 --> <!-- ronda 2 -->
Seguridad: n/a' '# R
Estado: en-revisión
QA: aprobado  
Seguridad: n/a'
par36 '# R
Estado: en-revisión
QA: aprobado
<!-- Rigor: critico
     Seguridad: pendiente -->
Seguridad: n/a' '# R
Estado: en-revisión
QA: aprobado
Seguridad: n/a'
# Un rango que envuelve la seccion entera: el `## ` sigue terminando la cabecera (arriba).
par36 '# R
Estado: en-revisión
QA: aprobado
Seguridad: n/a
<!-- una nota larga
que ocupa dos renglones -->' '# R
Estado: en-revisión
QA: aprobado
Seguridad: n/a'
# UN CR SUELTO EN MITAD DE LA LINEA: el unico agujero que el fuzz diferencial de QA
# encontro (1.500 cabeceras y 4.000 lineas, 0 divergencias sin CR). Las dos
# transcripciones descontaban el retorno de carro en momentos distintos —bash TODOS antes
# de escanear el rango, el awk solo el FINAL—, asi que `-\r->` era un `-->` para la puerta
# y no para el bloque derivado (H-01). Para las dos, y para cualquier persona, el rango
# sigue ABIERTO: se traga las dos declaraciones de abajo.
par36 "# R
Estado: en-revisión
QA: aprobado
Seguridad: con-hallazgos
<!-- historia -$(printf '\r')->
**Seguridad:** aprobado
QA: pendiente
-->" '# R
Estado: en-revisión
QA: aprobado
Seguridad: con-hallazgos'

# LA RUTA SE CALCULA UNA VEZ Y SE USA EN LOS DOS SITIOS. Antes se escribia el documento en
# `"$RAIZ/doc36-$BASHPID.md"` y se le pasaba a la sonda esa MISMA expresion dentro de un
# `$( )`, donde `$BASHPID` es el pid del subshell de la sustitucion y NO el del shell que
# escribio: la sonda recibia una ruta inexistente, su `read` fallaba y los seis campos
# salian VACIOS. Los 7 pares comparaban vacio contra vacio, asi que el caso pasaba tambien
# contra los hooks de 1.32.0 — el tell de una prueba que no mide (H-02.b).
DOC36="$RAIZ/doc36-$BASHPID.md"
lee36() {   # <modo> <documento> -> deja SALIDA36 ; 1 si la sonda no dijo nada
  local salida
  printf '%s\n' "$2" > "$DOC36"
  salida="$(bash "$LEE36" "$HOOKS_DIR" "$1" "$DOC36" 2>>"$ERRLOG")"
  SALIDA36="$salida"
  [ -n "$salida" ]
}
malos36=0; comparados36=0; primer36=''
for idx36 in "${!CON36[@]}"; do
  if ! lee36 lib "${CON36[idx36]}"; then malos36=$((malos36+1)); continue; fi
  con_lib36="$SALIDA36"
  if ! lee36 awk "${CON36[idx36]}"; then malos36=$((malos36+1)); continue; fi
  con_awk36="$SALIDA36"
  if ! lee36 lib "${SIN36[idx36]}"; then malos36=$((malos36+1)); continue; fi
  sin_lib36="$SALIDA36"
  comparados36=$((comparados36+1))
  if [ "$con_lib36" != "$con_awk36" ] || [ "$con_lib36" != "$sin_lib36" ]; then
    malos36=$((malos36+1))
    [ -n "$primer36" ] || primer36="par $idx36: lib(con)=$con_lib36 awk(con)=$con_awk36 lib(sin)=$sin_lib36"
  fi
done
if [ "$comparados36" -eq 0 ]; then
  echo "  FAIL  REQ-016 CA-01 la sonda de paridad no comparó NI UN par: no midió nada"; diag; FAIL=$((FAIL+1))
elif [ "$malos36" -eq 0 ]; then
  echo "  PASS  REQ-016 CA-01 los dos lectores y la cabecera sin el rango coinciden campo a campo ($comparados36 pares)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-01 $malos36 de $comparados36 pares discrepan — $primer36"; diag; FAIL=$((FAIL+1))
fi

# EL HUECO DEL RANGO ES UN ESPACIO, NUNCA NADA. Pegar los dos extremos FABRICARIA una clave
# que nadie escribio, y un comentario solo puede estrechar el juicio de la puerta.
#
# SE EXIGEN LAS DOS MITADES, y la segunda es la que faltaba: que `Estado` salga VACIO no
# prueba nada por si solo, porque una lectura que no ocurrio produce exactamente eso
# (H-02.c: con la ruta mal calculada, los seis campos salian vacios y el caso pasaba por la
# razon equivocada). Asi que se comprueba tambien que el `QA: pendiente` de FUERA del rango
# SI se leyo: solo entonces «Estado vacio» significa «no se fabrico».
hueco36=0
for modo36 in lib awk; do
  if lee36 "$modo36" '# R
Est<!-- ojo -->ado: completado
QA: pendiente'; then
    case "$SALIDA36" in
      'Estado=<> QA=<pendiente>'*) ;;
      *) hueco36=$((hueco36+1)) ;;
    esac
  else hueco36=$((hueco36+1)); fi
done
if [ "$hueco36" -eq 0 ]; then
  echo "  PASS  REQ-016 CA-02 'Est<!--x-->ado:' NO fabrica un campo y el 'QA:' de fuera del rango sí se lee"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-02 el hueco del rango fabricó un campo, o la lectura no ocurrió, en $hueco36 lector(es) — última salida: <$SALIDA36>"; diag; FAIL=$((FAIL+1))
fi

# ---------- CA-02 · LA INVARIANTE, SOBRE EL CORPUS Y NO SOBRE UN EJEMPLO ----------
# «Añadir un rango de comentario a una cabecera no convierte ningun `deny` de la puerta de
# cierre en `allow`.» No es un caso: es una propiedad, asi que se ejerce sobre el CORPUS DE
# CABECERAS DEL BANCO y no sobre un ejemplo elegido.
#
# DE DONDE SALE EL CORPUS: de un glob sobre el directorio de secciones —el mismo que
# descubre el corredor, que es el sitio unico de ese corpus— cosechando toda RACHA CONTIGUA
# de lineas que declaran un campo de cabecera. Las claves NO se enumeran aqui: se DERIVAN
# del lector de `hooks/lib.sh`. Asi la propiedad crece sola cuando alguien añade casos, que
# es lo contrario de una lista escrita a mano.
#
# QUE APORTA CADA MITAD: el corpus aporta los VEREDICTOS; el intento de cierre lo pone este
# caso, anteponiendo el estado terminal —que gobierna por ser la PRIMERA aparicion—, porque
# una puerta que no juzga ningun cierre no puede regresar en ninguna direccion.
#
# LO QUE LA PROPIEDAD NO CUBRE, dicho para no fingir: COMENTAR una linea de veredicto que
# ya existia no es «añadir un rango», es RETIRAR una declaracion, y un campo ausente es
# justo lo que la puerta perdona por compatibilidad con los REQ anteriores a los veredictos.
# Esa direccion tiene su propio criterio —CA-11, «comentar una declaracion la retira»— y su
# propia mitad de esta seccion (`-3-comentar-retira.sh`), que comprueba la EQUIVALENCIA con
# borrar la linea. Aqui se acota, no se ignora; y NO se dice que el informe lo haga visible,
# porque QA midio que calla (un campo declarado solo dentro de un comentario no es una clave
# decorada ni una doble declaracion, que son las dos cosas de las que habla CA-05/CA-06).
CLAVES36="$(sed -n \
  -e "s/.*case \"\$ARNES_CLAVE\" in '\([^']*\)').*/\1/p" \
  -e "s/^[[:space:]]*'\([A-Za-z][^']*\)')[[:space:]]*ARNES_[A-Z]*=\"\$ARNES_VALOR\".*/\1/p" \
  "$HOOKS_DIR/lib.sh" | sort -u | paste -sd'|' -)"
CABS36=()
if [ -n "$CLAVES36" ] && [ -n "${SEC_DIR:-}" ]; then
  while IFS= read -r cab36; do
    [ -n "$cab36" ] && CABS36+=("$cab36")
  done < <(awk -v claves="$CLAVES36" '
      BEGIN { re = "^[ \t]*[*_`]*(" claves ")[*_`]*[ \t]*:" }
      function vuelca() { if (buf != "") print buf; buf = "" }
      FNR == 1 { vuelca() }
      { sub(/\r$/, "") }
      $0 ~ re { buf = (buf == "" ? $0 : buf "\002" $0); next }
      { vuelca() }
      END { vuelca() }
    ' "$SEC_DIR"/[0-9][0-9]-*.sh)
fi
# Un control que cosecha cero sale verde sin haber medido nada: es el fallo que este banco
# existe para no tener, asi que el tamaño del corpus es un caso por su cuenta.
if [ "${#CABS36[@]}" -ge 10 ]; then
  echo "  PASS  REQ-016 CA-02 el corpus de cabeceras se cosecha por glob del corredor (${#CABS36[@]} cabeceras)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-02 la cosecha del corpus devolvió ${#CABS36[@]} cabeceras: la propiedad no mediría nada"; FAIL=$((FAIL+1))
fi

# Los rangos que se INSERTAN. Ninguno lleva una linea que empiece por `## `: eso no es
# contenido de un comentario, es el fin estructural de la cabecera (caso de la frontera,
# arriba), y una propiedad que lo mezclara estaria midiendo dos reglas a la vez.
CITAS36=('<!--
**Seguridad:** aprobado
**QA:** aprobado
**Rigor:** ligero
**Sensible a seguridad:** no
**Hallazgos abiertos:** (ninguno)
-->' '<!-- **Seguridad:** aprobado **QA:** aprobado --> <!-- Estado: en-revisión -->')

# EL DISCO SE DEJA EN `en-revisión` Y EL DOCUMENTO VA COMO CONTENIDO ENTRANTE: es lo que
# hace que exista una TRANSICION que juzgar. Antes se escribia el mismo documento —ya con
# `Estado: completado`— en el disco y en lo entrante, asi que la puerta veia
# `est_antes == est_despues` y salia por `[ "$est_antes" != "$done_norm" ] || return 0`
# antes de mirar un solo veredicto: las 62 decisiones de base eran `allow` y «ningun `deny`
# se volvio `allow`» era cierto POR VACIO en las 186 variantes. El tell estaba a la vista
# —el caso pasaba contra los hooks de 1.32.0, que son los que tienen el fail-open— y el
# reloj tambien: era el 60 % del banco pagado por un caso vacio (H-02.a). Corregido, la
# propiedad cuesta lo mismo y tiene dientes.
DISCO36='# REQ-963
Estado: en-revisión'
decide36() {   # <documento> -> deja DECISION36 ; 1 si el caso no se ejecuto
  local json out
  printf '%s\n' "$DISCO36" > "$PROJ/requirements/REQ-963.md"
  json="$(emite_write "$PROJ/requirements/REQ-963.md" "$1")"
  if [ -z "$json" ]; then DECISION36=''; return 1; fi
  out="$(corre guard-completado.sh "$json")"
  if [ -z "$out" ]; then DECISION36='allow'; else
    if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then DECISION36=deny; else DECISION36=allow; fi
  fi
  return 0
}
printf '%s\n' "$DISCO36" > "$PROJ/requirements/REQ-963.md"
regresiones36=0; probados36=0; sondas36=0; denys36=0; primera36=''
for idx36 in "${!CABS36[@]}"; do
  cab36="${CABS36[idx36]}"
  # La racha vuelve a ser lineas; el estado terminal va DELANTE y gobierna (primera aparicion).
  cuerpo36="Estado: completado"$'\n'"${cab36//$'\002'/$'\n'}"
  if ! decide36 "# REQ-963"$'\n'"$cuerpo36"; then sondas36=$((sondas36+1)); continue; fi
  base36="$DECISION36"
  # SOLO SE VARIAN LAS BASES QUE DENIEGAN, y no es un recorte de cobertura: la propiedad
  # dice «ningun `deny` se volvio `allow`», asi que una base que ya permite NO PUEDE
  # violarla —la direccion contraria (allow -> deny) es la admitida por CA-02—. Medido: con
  # el disco en `en-revisión` la propiedad pasa a juzgar cierres de verdad y cada llamada
  # recorre la puerta entera en vez de salir en la primera comprobacion; variar las 62
  # bases costaba 38 s de los 59 del banco, que es la puerta requerida de `main`. Variar
  # solo las 33 que deniegan mide EXACTAMENTE la misma afirmacion.
  if [ "$base36" != deny ]; then continue; fi
  denys36=$((denys36+1))
  lineas36=(); while IFS= read -r ln36; do lineas36+=("$ln36"); done <<< "$cuerpo36"
  # LAS DOS FORMAS DEL RANGO SE REPARTEN POR EL CORPUS, no se multiplican con el: el producto
  # cartesiano de formas x posiciones x cabeceras cuadruplicaba el reloj del banco —que es la
  # puerta requerida de `main`— sin añadir ni una clase nueva de nada. Y las TRES posiciones
  # son las tres CLASES que existen: antes de toda declaracion, entre ellas y detras de todas.
  # La forma de una sola linea tiene ademas sus propios casos nombrados mas arriba.
  cita36="${CITAS36[$((idx36 % ${#CITAS36[@]}))]}"
  medio36=$(( ${#lineas36[@]} / 2 )); [ "$medio36" -gt 0 ] || medio36=1
  for pos36 in 0 "$medio36" "${#lineas36[@]}"; do
    var36=''
    for ((q36 = 0; q36 < ${#lineas36[@]}; q36++)); do
      [ "$q36" -eq "$pos36" ] && var36+="$cita36"$'\n'
      var36+="${lineas36[q36]}"$'\n'
    done
    [ "$pos36" -ge "${#lineas36[@]}" ] && var36+="$cita36"$'\n'
    if ! decide36 "# REQ-963"$'\n'"$var36"; then sondas36=$((sondas36+1)); continue; fi
    probados36=$((probados36+1))
    if [ "$base36" = deny ] && [ "$DECISION36" = allow ]; then
      regresiones36=$((regresiones36+1))
      [ -n "$primera36" ] || primera36="cabecera «${cab36//$'\002'/ · }» con el rango en la posición $pos36"
    fi
  done
done
# LA GUARDA QUE FALTABA, y es criterio desde el write-back de CA-02: una propiedad «ningun
# `deny` se volvio `allow`» es cierta POR VACIO si NINGUNA base deniega, asi que el numero
# de bases `deny` se comprueba igual que el banco comprueba que un selector case con algo.
# La guarda anterior miraba el TAMAÑO de la cosecha (>= 10) y no si tenia DIENTES; esta
# mitad habria delatado H-02.a el dia que se escribio. El numero va en el nombre del caso:
# un nombre que imprime «186 variantes» y no dice cuantas denegaban da impresion de
# cobertura sin darla.
if [ "$sondas36" -gt 0 ]; then
  echo "  FAIL  REQ-016 CA-02 $sondas36 variante(s) no se ejecutaron (JSON vacío): la propiedad no las midió"; diag; FAIL=$((FAIL+1))
elif [ "$probados36" -eq 0 ]; then
  echo "  FAIL  REQ-016 CA-02 la propiedad no probó ni una variante"; FAIL=$((FAIL+1))
elif [ "$denys36" -eq 0 ]; then
  echo "  FAIL  REQ-016 CA-02 ninguna de las ${#CABS36[@]} cabeceras base denegó: «ningún deny se volvió allow» sería cierto por vacío y la propiedad no mediría nada"; diag; FAIL=$((FAIL+1))
elif [ "$regresiones36" -eq 0 ]; then
  echo "  PASS  REQ-016 CA-02 ningún deny se volvió allow al insertar un rango ($probados36 variantes sobre las $denys36 cabeceras que deniegan, de ${#CABS36[@]} cosechadas)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-02 $regresiones36 de $probados36 variantes abrieron la puerta — la primera: $primera36"; FAIL=$((FAIL+1))
fi
