# ---------- 37 (2/2) · LA RUTA CRÍTICA DEL BANCO Y EL CAMINO NORMAL ----------
# REQ-017. Aquí se mide lo que de verdad se paga en cada PR (`32-huecos-auditoria-r001`,
# la ruta crítica) y lo que NO se puede pagar por arreglarlo (un `fork` en el camino de
# lectura de una cabecera normal).
#
# LAS DOS MAGNITUDES DE CA-08 VAN JUNTAS, Y ESA ES LA LECCIÓN DE ESTA VENTANA. CA-08 de
# REQ-016 contrataba PROCESOS por llamada: 4 = 4, medido correctamente, criterio en verde
# — mientras el reloj de la ruta crítica se multiplicaba por diez. Una magnitud correcta,
# medible sin ruido y ORTOGONAL a lo que se degradó. Por eso las dos aquí y en la misma
# corrida: los procesos, porque el arreglo no vale si compra tiempo con un `fork`; y el
# reloj, porque es lo que se degradó.
#
# QUÉ CORRE POR DEFECTO Y QUÉ NO. CA-08 y las dos mitades de CA-06 corren SIEMPRE: son
# baratas (~13 s) y auto-ancladas o de instrumento. La comparación de CA-05 contra la
# ruta crítica NO corre por defecto —cuesta lo que costaba el defecto, porque ES el
# defecto corriendo— y se enciende con `ARNES_COSTE_RUTA_CRITICA=1`; apagada dice SKIP
# citando el número acreditado y su fecha, nunca PASS. El árbol heredado se materializa
# igual, porque CA-08 lo necesita.
#
# Y LAS DOS PUERTAS DE CA-05 SE PRUEBAN AUNQUE LA COMPARACIÓN ESTÉ APAGADA. Las decisiones
# «¿esta corrida midió?» y «¿esta muerte prueba el vencimiento?» viven en funciones puras,
# así que se les dan entradas sintéticas y se comprueba su veredicto en milisegundos. Es lo
# que faltaba en la vuelta 0 (QA-017-03 y QA-017-04): la puerta corría sólo cuando se
# encendía la palanca, y nadie comprobaba nunca que la puerta cerrase.
CASOS_ESPERADOS_SECCION=10
seccion_nueva "--- 37/2 · la ruta crítica del banco y el camino de una cabecera normal (REQ-017) ---"

REPO47="$(cd "${SEC_DIR%/}/../../../.." 2>/dev/null && pwd || true)"
BANCO47="${SEC_DIR%/}/../run.sh"
INV47="${SEC_DIR%/}/../inventario.sh"

mat47() {   # <tag> <destino> -> 0 si el árbol heredado quedó materializado
  local tag="$1" dst="$2" f lista
  [ -n "$REPO47" ] || return 1
  git -C "$REPO47" rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1 || return 1
  lista="$(git -C "$REPO47" ls-tree -r --name-only "$tag" hooks tools 2>/dev/null)"
  [ -n "$lista" ] || return 1
  mkdir -p "$dst/hooks" "$dst/tools" 2>/dev/null || return 1
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    git -C "$REPO47" show "$tag:$f" > "$dst/$f" 2>/dev/null || return 1
  done <<< "$lista"
  [ -s "$dst/hooks/lib.sh" ] || return 1
  # `git show` escribe el CONTENIDO, no el modo: sin esto los hooks heredados quedan sin
  # bit de ejecución y el canario del corredor hijo no arranca. La corrida heredada salía
  # entonces «sin casos» —un SKIP correcto pero por el motivo equivocado— y CA-05 dejaba
  # de medir en silencio, que es exactamente lo que esta sección existe para no permitir.
  chmod +x "$dst"/hooks/*.sh "$dst"/tools/*.sh 2>/dev/null || true
  return 0
}
HER47="$RAIZ/her47-$BASHPID"; HER47_OK=no
mat47 v1.32.1 "$HER47" && HER47_OK=si
# LOS NOMBRES SE FIJAN AQUÍ, FUERA DE TODA SUSTITUCIÓN, Y ESO NO ES ESTILO. `$BASHPID`
# dentro de `$( )` es el PID del SUBSHELL DE LA SUSTITUCIÓN, no el de la sección: escrito
# en línea, cada corrida guardaba su salida en un archivo con otro nombre y el inventario
# leía uno vacío. Salía «no se comparó nada» —fail-closed, que es la dirección correcta—
# pero por un motivo que no era el suyo.
OUT_ESTE47="$RAIZ/s32-este-$BASHPID"      # se le añade "-<vuelta>.txt": son TRES corridas
OUT_HER47="$RAIZ/s32-her-$BASHPID.txt"

# ---------- CA-05 · LA RUTA CRÍTICA: ACREDITACIÓN DE FAIL-BEFORE, NO PUERTA DE CADA PR ----------
# La sección 32 corrida AISLADA y con `ARNES_JOBS=1` contra los dos árboles, en la misma
# máquina y la misma corrida: así la velocidad de la máquina se cancela y lo que queda es
# la razón.
#
# APAGADA POR DEFECTO, Y EL MOTIVO ESTÁ MEDIDO. La corrida heredada cuesta lo que costaba
# el defecto (~76 s en Linux) porque ES el defecto corriendo: pagarla en cada vuelta deja
# el banco en ~145 s, es decir la PUERTA REQUERIDA de `main` más lenta que la regresión de
# 92 s que este REQ arregla, y de forma permanente. Además la línea base es un TAG
# CONGELADO: acreditada la razón, deja de medir la evolución de este árbol y envejece
# hacia el lado que abre. La vigilancia permanente del coste la contrata CA-03 —el orden
# de crecimiento, auto-anclado, sin tag y en milisegundos—. Aquí se acredita una vez, con
# su número y su fecha, y se repite a mano con `ARNES_COSTE_RUTA_CRITICA=1`.
#
# EL DENOMINADOR NO SE MIDE: SE ACOTA, Y LA COTA QUEDA PROBADA. La heredada se lanza bajo
# `timeout` de 4 × mín(este árbol), derivado en ESTA misma corrida y DESPUÉS del
# numerador. Un plazo en segundos escrito a mano sería el reloj absoluto que todo este REQ
# combate —lo falsea la máquina, el runner y `nice`—; derivado del numerador, la máquina se
# cancela igual que en una razón. Si el plazo VENCE, entonces heredada > 4 × este y el
# cociente es ≤ 0,25×: la desigualdad contratada queda DEMOSTRADA, no estimada, y lo único
# que se deja de conocer es el VALOR de la razón, que el criterio no pide. Por eso el
# vencimiento es un resultado POSITIVO —PASS— y nunca un SKIP: un SKIP ahí convertiría el
# hallazgo en silencio. Si la heredada TERMINA dentro del plazo, el cociente es > 0,25× y
# el caso FALLA.
ACRED47='0,125× — 9,60 s frente a 76,19 s, medido el 2026-09-07'

# LA PREGUNTA NO ES «¿TERMINÓ?», ES «¿ESTA CORRIDA PRODUJO UNA MEDICIÓN?» — y son distintas
# justo donde duele. Una corrida que termina EN ROJO no midió lo que cuesta correr la
# sección: midió lo que cuesta fallarla, y además falla ANTES, así que mide MENOS. Medido
# por QA (QA-017-03, vuelta 1): con los hooks sustituidos por un sello que siempre permite,
# la sección 32 sale en 14 FAIL, rc 1 y 3,79 s en vez de ~9,6 s; el plazo derivado cae a
# 16 s, la heredada vence de sobra y las DOS mitades daban PASS — incluida la que se llama
# «la comparación no se compra dejando de probar». Es decir: el criterio que existe para
# impedir comprar la comparación dejando de probar, la compraba dejando de probar.
#
# El rc del corredor es la señal correcta y no hay que fabricar ninguna: `run.sh` sale 0
# SÓLO con 0 FAIL, con el cuadre por archivo cerrado (ningún caso perdido) y sin procesos
# vivos. El recuento de casos se conserva porque es la evidencia DIRECTA —y porque un
# corredor que muere antes de imprimir nada también devuelve un rc—.
#
# UNO A UNO, Y NO CONCATENADOS: con `"$rc$ut"` un valor VACÍO desaparece dentro de los
# dígitos del vecino y la guarda deja pasar la basura que existe para atrapar. Y tampoco en
# un solo patrón separado por barras: dentro de un `case`, el `|` de `*[!0-9|]*` NO es un
# carácter de la clase — es el separador de alternativas del propio `case`, que parte el
# patrón en `*[!0-9` y `]*` y así no dispara NUNCA (comprobado en bash 5.3 al escribir
# esto: la primera versión de esta guarda no guardaba nada).
num47() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

MOT47C=''
valida47() {   # <archivo de salida> <rc del corredor> -> 0 si esa corrida midió; si no, MOT47C dice por qué
  local salida="${1:-}" rc="${2:-}" nc nf
  MOT47C=''
  if ! num47 "$rc"; then
    MOT47C="el corredor no devolvió un código de salida legible (<${rc:-vacío}>): sin él no se sabe si esa corrida pasó"; return 1
  fi
  if [ -z "$salida" ] || [ ! -r "$salida" ]; then
    MOT47C="no hay salida que leer (<${salida:-vacío}>)"; return 1
  fi
  nc="$(grep -c '^  \(PASS\|FAIL\|SKIP\)  ' "$salida" 2>/dev/null || true)"
  nf="$(grep -c '^  FAIL  ' "$salida" 2>/dev/null || true)"
  if [ "${nc:-0}" -eq 0 ]; then
    MOT47C="no produjo un solo caso: no es una corrida rápida, es una que no midió"; return 1
  fi
  if [ "$rc" -ne 0 ]; then
    MOT47C="terminó EN ROJO (rc=$rc; ${nf:-0} FAIL de ${nc:-0} casos): una corrida que falla no mide lo que cuesta una corrida que pasa, y falla antes de terminarla, así que mide MENOS"
    return 1
  fi
  return 0
}
# EL MOTIVO VIAJA POR LA SALIDA, NO POR UNA VARIABLE, y eso no es estilo: `corre47` se
# llama dentro de `$( )`, que es un subshell, así que un `MOT47C` puesto ahí dentro muere
# con él y el caso diría «no se pudo medir» sin decir por qué. Un fail-closed silencioso es
# un bug de diagnóstico.
corre47() {   # <dir de hooks> <archivo de salida> -> imprime µs, o el motivo por el que no midió (rc 1)
  local hd="$1" salida="$2" t0 t1 rc
  [ -n "${EPOCHREALTIME:-}" ] || { printf 'no hay EPOCHREALTIME: sin reloj no hay medición\n'; return 1; }
  t0=${EPOCHREALTIME/./}
  ARNES_JOBS=1 ARNES_HOOKS_DIR="$hd" bash "$BANCO47" secciones/32-huecos-auditoria-r001.sh > "$salida" 2>&1
  rc=$?
  t1=${EPOCHREALTIME/./}
  valida47 "$salida" "$rc" || { printf '%s\n' "$MOT47C"; return 1; }
  printf '%s\n' "$((t1 - t0))"
}

# La palanca viene de FUERA y se escribe a mano, así que se normaliza antes de comparar
# —espacios y mayúsculas— y un valor que no se reconoce NO enciende la medición... pero
# tampoco se calla: se dice en el motivo del SKIP. Un fail-closed silencioso es un bug de
# diagnóstico, y aquí se leería como «no lo pedí» cuando la verdad es «lo pediste mal».
_pide47="${ARNES_COSTE_RUTA_CRITICA-}"
_pide47="${_pide47#"${_pide47%%[![:space:]]*}"}"
_pide47="${_pide47%"${_pide47##*[![:space:]]}"}"
PIDE47=no; RARO47=''
case "${_pide47,,}" in
  1|si|sí|yes|true|on) PIDE47=si ;;
  ''|0|no|false|off)   : ;;
  *)                   RARO47="$_pide47" ;;
esac

u_este47=''; inv47=''; inv47_igual=si; ncasos47=0
plazo47=''; rc_her47=''; ut_her47=''; motivo47=''
TIMEOUT47="$(type -P timeout 2>/dev/null || true)"
if [ "$PIDE47" != si ]; then
  motivo47="no se pide: evidencia acreditada en el Historial de REQ-017 ($ACRED47); es acreditación de fail-before, no puerta de cada PR — se repite con ARNES_COSTE_RUTA_CRITICA=1"
  [ -z "$RARO47" ] || motivo47="ARNES_COSTE_RUTA_CRITICA=<$RARO47> no se reconoce y NO enciende la medición; $motivo47"
elif [ "$HER47_OK" != si ]; then
  motivo47="no hay línea base: el tag v1.32.1 no está en este clon"
elif [ -z "$TIMEOUT47" ]; then
  # CA-06 nombra este caso: sin `timeout` el denominador sólo se puede MEDIR, y medirlo es
  # justo lo que cuesta 76 s. Antes que estimar la cota, se dice que no se puede acotar.
  motivo47="no hay 'timeout' en el PATH, y el denominador se ACOTA con él en vez de medirse"
elif [ ! -r "$BANCO47" ] || [ ! -r "$INV47" ]; then
  motivo47="no encuentro el corredor o el inventario junto a esta sección"
else
  # EL NUMERADOR PRIMERO, Y LAS TRES CORRIDAS A ARCHIVOS DISTINTOS: de ellas salen las dos
  # mitades del criterio —el mínimo para (i) y el inventario para (ii)—, y (ii) es
  # AUTO-ANCLADO: compara este árbol consigo mismo, no contra el tag.
  for _r47 in 1 2 3; do
    _o47="$OUT_ESTE47-$_r47.txt"
    _u47="$(corre47 "$HOOKS_DIR" "$_o47")" || { motivo47="la corrida $_r47 de este árbol no midió: ${_u47:-sin motivo}"; u_este47=''; break; }
    if [ -z "$u_este47" ] || [ "$_u47" -lt "$u_este47" ]; then u_este47="$_u47"; fi
    _i47="$(bash "$INV47" "$_o47" 2>/dev/null)"
    if [ -z "$_i47" ]; then motivo47="el inventario de la corrida $_r47 de este árbol salió vacío: no se comparó nada"; u_este47=''; break; fi
    if [ -z "$inv47" ]; then
      inv47="$_i47"
      while IFS= read -r _l47; do ncasos47=$((ncasos47 + 1)); done <<< "$_i47"
    elif [ "$_i47" != "$inv47" ]; then
      inv47_igual=no; inv47_dif="$_i47"
    fi
  done
  # EL SUELO DE 50 ms, aquí y no sólo en las sondas de 37/1: un numerador dentro del ruido
  # produciría un plazo dentro del ruido, y la cota se apoyaría en él.
  if [ -n "$u_este47" ] && [ "$u_este47" -lt 50000 ]; then
    motivo47="el mínimo de este árbol se queda en ${u_este47}µs, bajo el suelo de 50 ms donde el reloj no distingue del ruido"
    u_este47=''
  fi
  if [ -n "$u_este47" ]; then
    # 4 × mín(este árbol), EN SEGUNDOS Y REDONDEADO ARRIBA. La dirección del redondeo no es
    # cosmética: con el plazo >= 4×este, que venza sigue probando heredada > 4×este.
    # Redondear ABAJO probaría una desigualdad más floja que la contratada.
    plazo47=$(( (u_este47 * 4 + 999999) / 1000000 ))
    [ "$plazo47" -ge 1 ] || plazo47=1
    # Sin `--foreground`, `timeout` pone al hijo en SU PROPIO grupo de procesos y señala al
    # grupo entero: el corredor heredado muere con sus subshells, y no queda una corrida de
    # 76 s huérfana envenenando el reloj de la sección siguiente (CA-06).
    # EL RELOJ DE ESTA CORRIDA SE GUARDA, y hace falta: el rc solo NO distingue «venció el
    # plazo» de «alguien lo mató» (QA-017-04). El transcurrido es la corroboración.
    _t0her47=${EPOCHREALTIME/./}
    ARNES_JOBS=1 ARNES_HOOKS_DIR="$HER47/hooks" \
      "$TIMEOUT47" -k 5 "$plazo47" bash "$BANCO47" secciones/32-huecos-auditoria-r001.sh > "$OUT_HER47" 2>&1
    rc_her47=$?
    ut_her47=$(( ${EPOCHREALTIME/./} - _t0her47 ))
  fi
fi

# EL VEREDICTO SOBRE LA HEREDADA, EN UNA FUNCIÓN PURA — y pura para poder probarla con
# entradas sintéticas sin pagar los 76 s de la corrida real (abajo, en los casos de CA-06).
#
# QUÉ PRUEBA QUÉ, QUE ES LO QUE ESTABA MAL. Lo contratado es «la heredada no cabe en
# 4 × mín(este árbol)». Sólo el código **124** significa «el plazo venció»; el **137** es
# «murió por SIGKILL», y eso lo produce igual el OOM killer, un `kill` de fuera o el `-k`
# del propio `timeout`. Medido por QA (QA-017-04): matando al hijo desde fuera a los 0,6 s
# de un plazo de 60 s el rc es 137, y este caso lo leía como «≤ 0,250× — DEMOSTRADO». Y no
# es hipotético: la corrida heredada ES el camino cuadrático, el que más memoria pide, así
# que el OOM kill es su modo de muerte más probable en un runner apretado — un verde falso
# etiquetado como demostración.
#
# Por eso el PASS exige las DOS cosas y de dos instrumentos distintos: que `timeout` diga
# que venció (124) y que el reloj de pared lo corrobore (transcurrido ≥ plazo). Cualquier
# otra muerte no es un FAIL —no hemos medido que la heredada sea rápida— sino un SKIP CON
# MOTIVO, que es lo que CA-06 contrata para una sonda que no pudo medir.
veredicto47() {   # <nombre> <rc> <µs transcurridos> <plazo s> <µs mín(este árbol)> <salida heredada>
  local nombre="$1" rc="${2:-}" ut="${3:-}" plazo="${4:-}" ue="${5:-}" sal="${6:-}" pl seg este
  if ! num47 "$rc" || ! num47 "$ut" || ! num47 "$plazo" || ! num47 "$ue"; then
    echo "  SKIP  $nombre  el instrumento no devolvió números (rc=<${rc:-vacío}> transcurrido=<${ut:-vacío}>µs plazo=<${plazo:-vacío}>s este=<${ue:-vacío}>µs)"
    return 0
  fi
  pl=$(( plazo * 1000000 ))
  seg="$(awk -v u="$ut" 'BEGIN{printf "%.2f", u/1e6}')"
  este="$(awk -v u="$ue" 'BEGIN{printf "%.2f", u/1e6}')"
  if [ "$rc" = 124 ] && [ "$ut" -ge "$pl" ]; then
    echo "  PASS  $nombre  la heredada NO terminó en ${plazo}s = 4 × mín(este árbol) ($este s) y el reloj lo corrobora (${seg}s): heredada > 4 × este, luego el cociente es ≤ 0,250× — DEMOSTRADO, no estimado"
    PASS=$((PASS+1)); return 0
  fi
  if [ "$rc" = 124 ]; then
    echo "  SKIP  $nombre  timeout dice que venció (rc=124) pero el reloj sólo cuenta ${seg}s de un plazo de ${plazo}s: los dos instrumentos se contradicen y una cota no se firma sobre eso"
    return 0
  fi
  if [ "$rc" -ge 128 ]; then
    echo "  SKIP  $nombre  la corrida heredada murió por la señal $((rc - 128)) a los ${seg}s de un plazo de ${plazo}s: sólo el vencimiento (rc=124) prueba que el plazo se agotó — el OOM killer, un kill de fuera y el -k del propio timeout dan todos 137, y este camino es el cuadrático, el que más memoria pide"
    return 0
  fi
  if valida47 "$sal" "$rc"; then
    echo "  FAIL  $nombre  la heredada TERMINÓ dentro de ${plazo}s = 4 × mín(este árbol) (rc=$rc, ${seg}s frente a $este s): heredada < 4 × este, luego el cociente es > 0,250×"
    FAIL=$((FAIL+1)); return 0
  fi
  echo "  SKIP  $nombre  la corrida heredada terminó a los ${seg}s de ${plazo}s sin producir una medición: $MOT47C — una cota sobre una corrida que no midió no es una cota"
}

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 reloj" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (i) la ruta crítica cuesta no más de 0,250× lo de v1.32.1"
  if [ -z "$u_este47" ]; then
    echo "  SKIP  $nom47  ${motivo47:-no se pudo medir}"
  else
    veredicto47 "$nom47" "$rc_her47" "$ut_her47" "$plazo47" "$u_este47" "$OUT_HER47"
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 inventario" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (ii) la comparación no se compra dejando de probar"
  if [ -z "$u_este47" ]; then
    echo "  SKIP  $nom47  ${motivo47:-no se pudo medir}"
  elif [ "$inv47_igual" = si ]; then
    echo "  PASS  $nom47  las 3 corridas cronometradas terminaron EN VERDE (rc=0, 0 FAIL, cuadre cerrado) y dan el MISMO inventario ordenado caso→veredicto ENTRE SÍ ($ncasos47 casos); la igualdad contra el árbol heredado la cierra CA-02 sobre el banco entero"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  el inventario cambió ENTRE corridas del MISMO árbol: la medición del numerador no es reproducible"; FAIL=$((FAIL+1))
    diff <(printf '%s\n' "$inv47") <(printf '%s\n' "${inv47_dif:-}") 2>/dev/null | head -6 | sed 's/^/          /'
  fi
fi

# ---------- CA-06 · LAS DOS PUERTAS DE CA-05, PROBADAS CON ENTRADAS SINTÉTICAS ----------
# Las dos comprobaciones de aquí abajo son la misma familia que este REQ combate —DAR VERDE
# SIN HABER MEDIDO— pero una capa más arriba: no en el escáner, sino en la prueba que lo
# certifica. Vienen de la vuelta 1 de QA (QA-017-03 y QA-017-04) y cuestan MILISEGUNDOS,
# porque las dos decisiones viven en funciones puras: `valida47` (¿esta corrida midió?) y
# `veredicto47` (¿esta muerte prueba el vencimiento?). Probarlas contra la corrida real
# habría costado 76 s y sólo habría cubierto el camino que ese día se diera.
#
# FAIL-BEFORE, para que conste cómo se reproduce: con los cuerpos de esas dos funciones
# revertidos a los de antes de esta vuelta —`valida47` sin mirar el rc, y `veredicto47`
# aceptando `137` como vencimiento— los dos casos salen en FAIL. Es la única forma de saber
# que miden: una prueba nueva que pasa también contra el código viejo no probó nada.
ROJO47="$RAIZ/val47-rojo-$BASHPID.txt"
LIMPIO47="$RAIZ/val47-limpio-$BASHPID.txt"
MUDO47="$RAIZ/val47-mudo-$BASHPID.txt"
{ _i47=1; while [ "$_i47" -le 26 ]; do echo "  PASS  caso sintético $_i47"; _i47=$((_i47+1)); done
  _i47=1; while [ "$_i47" -le 14 ]; do echo "  FAIL  caso sintético en rojo $_i47"; _i47=$((_i47+1)); done
  echo "Resultado: 26 PASS, 14 FAIL"; } > "$ROJO47"
{ _i47=1; while [ "$_i47" -le 40 ]; do echo "  PASS  caso sintético $_i47"; _i47=$((_i47+1)); done
  echo "Resultado: 40 PASS, 0 FAIL"; } > "$LIMPIO47"
printf 'ABORT: el canario no arranca; no se lanzó ni una sección\n' > "$MUDO47"

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 corrida en rojo" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (i)/(ii) una corrida que termina EN ROJO no cuenta como medición: deciden el rc y los casos, no el número de líneas"
  falla47=''
  # 14 FAIL y rc=1: es la reproducción exacta de QA-017-03 (hooks sustituidos por un sello
  # que siempre permite → 3,79 s en vez de ~9,6 s → plazo 16 s → dos PASS falsos).
  valida47 "$ROJO47"   1 && falla47="$falla47 <14 FAIL con rc=1 se aceptó como medición>"
  valida47 "$LIMPIO47" 0 || falla47="$falla47 <una corrida limpia se rechazó: $MOT47C>"
  valida47 "$MUDO47"   0 && falla47="$falla47 <una corrida sin un solo caso se aceptó como medición>"
  valida47 "$LIMPIO47" 1 && falla47="$falla47 <40 PASS pero rc=1 (cuadre roto o proceso vivo) se aceptó como medición>"
  valida47 "$LIMPIO47" '' && falla47="$falla47 <un rc ilegible se aceptó como medición>"
  if [ -z "$falla47" ]; then
    echo "  PASS  $nom47"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47 :$falla47"; FAIL=$((FAIL+1))
  fi
fi

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 muerte por señal" | grep -qi -- "$FILTRO"; then
  nom47="REQ-017 CA-05 (i) sólo el vencimiento del plazo, y con el reloj de acuerdo, prueba la cota: una muerte por señal dice SKIP"
  # Plazo de 60 s en todas: lo que cambia es CÓMO murió y CUÁNDO. `u_este47` no se toca —la
  # función es pura y recibe todo por argumentos—, así que esto vale igual con la palanca
  # apagada, que es como corre el banco por defecto.
  obs47="$( {
    veredicto47 sonda-de-prueba 137     600000 60 9000000 "$LIMPIO47"   # matada desde fuera a los 0,6 s: QA-017-04
    veredicto47 sonda-de-prueba 137   61000000 60 9000000 "$LIMPIO47"   # sobrevivió al plazo, pero murió por señal
    veredicto47 sonda-de-prueba 124   60000000 60 9000000 "$LIMPIO47"   # el positivo real: venció y el reloj lo dice
    veredicto47 sonda-de-prueba 124    1000000 60 9000000 "$LIMPIO47"   # 124 con el reloj corto: instrumentos en contra
    veredicto47 sonda-de-prueba   0    9000000 60 9000000 "$LIMPIO47"   # terminó limpia dentro del plazo: eso SÍ es FAIL
    veredicto47 sonda-de-prueba   0    9000000 60 9000000 "$MUDO47"     # terminó sin medir nada: no acota nada
    veredicto47 sonda-de-prueba  ''    9000000 60 9000000 "$LIMPIO47"   # sin rc: el instrumento no devolvió números
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp47='SKIP SKIP PASS SKIP FAIL SKIP SKIP '
  if [ "$obs47" = "$esp47" ]; then
    echo "  PASS  $nom47  (7 formas de terminar → $obs47)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom47  se esperaba <$esp47> y se obtuvo <$obs47>"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `veredicto47` corrió dentro de una sustitución de
# comandos, que es un subshell, y sus PASS/FAIL murieron con él. Se dice porque un lector
# que no lo sepa creerá que estos casos descuadran el recuento de la sección.

# ---------- CA-08 · LAS DOS MAGNITUDES DEL CAMINO NORMAL ----------
mkreq_r REQ-100 no aprobado n/a estandar     # un REQ real: 6 líneas de cabecera
{ printf '# REQ-200\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n'
  _i47=1; while [ "$_i47" -le 195 ]; do printf 'Campo%03d: valor de relleno de cabecera\n' "$_i47"; _i47=$((_i47+1)); done
} > "$PROJ/requirements/REQ-200.md"
json47() {   # <REQ> -> el Edit que cierra ese REQ
  jq -n --arg fp "$PROJ/requirements/$1.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.NADA,
      tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}'
}
SONDA47="$RAIZ/sonda47-$BASHPID.sh"
cat > "$SONDA47" <<'SONDA47FIN'
# <hooks> <proyecto> <json> <k> -> "<procesos por llamada> <mejor de 3 series, µs>"
HD="$1"; PR="$2"; JS="$3"; K="$4"
[ -n "${EPOCHREALTIME:-}" ] || { printf 'SIN-RELOJ\n'; exit 2; }
BIN="$PR/.bin47-$$"; rm -rf "$BIN"; mkdir -p "$BIN" || exit 1
# CA-06, Y ESTO NO ES CEREMONIA. Las rutas reales se resuelven ANTES de tocar el PATH y con
# `type -P`, que sólo mira ejecutables del PATH y NO ve funciones de shell. En 1.32.1 un
# envoltorio de `grep` construido con `command -v` sobre un binario SOMBREADO POR UNA
# FUNCIÓN se resolvió a sí mismo, se llamó a sí mismo y vivió 3 h 41 min comiéndose un
# núcleo. Además se comprueba que ninguna ruta resuelta caiga dentro del propio envoltorio.
declare -A REAL
for b in jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git; do
  r="$(type -P "$b" 2>/dev/null || true)"; [ -n "$r" ] && REAL[$b]="$r"
done
[ "${#REAL[@]}" -gt 0 ] || { printf 'SIN-BINARIOS\n'; exit 1; }
for b in "${!REAL[@]}"; do
  case "${REAL[$b]}" in "$BIN"/*) printf 'ENVOLTORIO-RECURSIVO %s\n' "$b"; exit 9 ;; esac
  printf '#!/bin/sh\necho %s >> "%s/reg"\nexec %s "$@"\n' "$b" "$BIN" "${REAL[$b]}" > "$BIN/$b" || exit 1
  chmod +x "$BIN/$b" || exit 1
done
: > "$BIN/reg"
printf '%s' "$JS" > "$BIN/in.json"
[ -s "$BIN/in.json" ] || { rm -rf "$BIN"; printf 'SIN-JSON\n'; exit 3; }
PATH="$BIN:$PATH" CLAUDE_PROJECT_DIR="$PR" bash "$HD/guard-completado.sh" < "$BIN/in.json" >/dev/null 2>&1
procs=0; while IFS= read -r _; do procs=$((procs+1)); done < "$BIN/reg"
# El RELOJ se mide SIN la instrumentación: un envoltorio por proceso mide el envoltorio.
mejor=''
for r in 1 2 3; do
  t0=${EPOCHREALTIME/./}
  for ((i=0;i<K;i++)); do CLAUDE_PROJECT_DIR="$PR" bash "$HD/guard-completado.sh" < "$BIN/in.json" >/dev/null 2>&1; done
  t1=${EPOCHREALTIME/./}; u=$((t1-t0))
  if [ -z "$mejor" ] || [ "$u" -lt "$mejor" ]; then mejor="$u"; fi
done
rm -rf "$BIN"
printf '%s %s\n' "$procs" "$mejor"
SONDA47FIN

# k=8: cada serie ronda 1 s, veinte veces por encima del suelo de 50 ms donde el reloj deja
# de distinguir del ruido, y la sonda entera cuesta la cuarta parte que con k=20.
K47=8
# mide47 <hooks> <json> -> deja P47 (procesos) y U47 (µs de la mejor serie de K47 llamadas)
P47=''; U47=''; MOT47=''
mide47() {
  local hd="$1" json="$2" salida p u
  P47=''; U47=''; MOT47=''
  if [ -z "$json" ]; then MOT47="el JSON del caso salió vacío: el hook no habría recibido entrada"; return 1; fi
  salida="$(bash "$SONDA47" "$hd" "$PROJ" "$json" "$K47" 2>/dev/null)"
  if [ -z "$salida" ]; then MOT47="la sonda no devolvió nada"; return 1; fi
  read -r p u <<< "$salida"
  case "${p:-x}${u:-x}" in ''|*[!0-9]*) MOT47="la sonda respondió <$salida>"; return 1 ;; esac
  P47="$p"; U47="$u"; return 0
}
declare -A PROCS47 RELOJ47
falta47=''
for _cual47 in REQ-100 REQ-200; do
  for _arb47 in este heredado; do
    _hd47="$HOOKS_DIR"; [ "$_arb47" = heredado ] && _hd47="$HER47/hooks"
    if [ "$_arb47" = heredado ] && [ "$HER47_OK" != si ]; then falta47="sin línea base v1.32.1"; continue; fi
    if mide47 "$_hd47" "$(json47 "$_cual47")"; then
      PROCS47["$_cual47-$_arb47"]="$P47"; RELOJ47["$_cual47-$_arb47"]="$U47"
    else
      falta47="$MOT47"
    fi
  done
done

for _cual47 in REQ-100 REQ-200; do
  _etq47="un REQ real de 6 líneas"; [ "$_cual47" = REQ-200 ] && _etq47="una cabecera de 200 líneas"
  nom47="REQ-017 CA-08 (i) $_etq47: 0 procesos añadidos respecto a v1.32.1"
  if [ -z "$FILTRO" ] || printf '%s' "$nom47" | grep -qi -- "$FILTRO"; then
    pe47="${PROCS47[$_cual47-este]:-}"; ph47="${PROCS47[$_cual47-heredado]:-}"
    if [ -z "$pe47" ] || [ -z "$ph47" ]; then
      echo "  SKIP  $nom47  ${falta47:-no se pudo medir} (este=<${pe47:-vacío}> heredado=<${ph47:-vacío}>)"
    elif [ "$pe47" -le "$ph47" ]; then
      echo "  PASS  $nom47  $pe47 procesos frente a $ph47 (menos es conforme)"; PASS=$((PASS+1))
    else
      echo "  FAIL  $nom47  $pe47 procesos frente a $ph47: el arreglo compró tiempo con un fork"; FAIL=$((FAIL+1))
    fi
  fi
  nom47="REQ-017 CA-08 (ii) $_etq47: el reloj no sube más de 1,25× el de v1.32.1"
  if [ -z "$FILTRO" ] || printf '%s' "$nom47" | grep -qi -- "$FILTRO"; then
    ue47="${RELOJ47[$_cual47-este]:-}"; uh47="${RELOJ47[$_cual47-heredado]:-}"
    if [ -z "$ue47" ] || [ -z "$uh47" ]; then
      echo "  SKIP  $nom47  ${falta47:-no se pudo medir} (este=<${ue47:-vacío}>µs heredado=<${uh47:-vacío}>µs)"
    elif [ "$uh47" -lt 50000 ]; then
      echo "  SKIP  $nom47  la serie heredada se queda en ${uh47}µs, bajo el suelo de 50 ms: el reloj no distingue del ruido"
    else
      r47=$(( ue47 * 1000 / uh47 ))
      if [ "$r47" -le 1250 ]; then
        echo "  PASS  $nom47  $(awk -v c=$r47 'BEGIN{printf "%.3f", c/1000}')× ($(awk -v u=$ue47 -v k=$K47 'BEGIN{printf "%.4f", u/(k*1e6)}') s/llamada frente a $(awk -v u=$uh47 -v k=$K47 'BEGIN{printf "%.4f", u/(k*1e6)}') s)"; PASS=$((PASS+1))
      else
        echo "  FAIL  $nom47  $(awk -v c=$r47 'BEGIN{printf "%.3f", c/1000}')× > 1,250× ($(awk -v u=$ue47 -v k=$K47 'BEGIN{printf "%.4f", u/(k*1e6)}') s/llamada frente a $(awk -v u=$uh47 -v k=$K47 'BEGIN{printf "%.4f", u/(k*1e6)}') s)"; FAIL=$((FAIL+1))
      fi
    fi
  fi
done

# La sonda de procesos se comprueba A SÍ MISMA: si el envoltorio se resolviera a sí mismo
# —el fallo real de 1.32.1— la sonda tiene que DECIRLO y no dar un número. Se le da un
# PATH que ya contiene un `grep` falso y se exige que no lo tome por el binario real.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-06 el envoltorio no se resuelve a sí mismo" | grep -qi -- "$FILTRO"; then
  trampa47="$RAIZ/trampa47-$BASHPID"; mkdir -p "$trampa47"
  printf '#!/bin/sh\nexit 0\n' > "$trampa47/grep"; chmod +x "$trampa47/grep"
  sal47="$(PATH="$trampa47:$PATH" bash "$SONDA47" "$HOOKS_DIR" "$PROJ" "$(json47 REQ-100)" 1 2>/dev/null)"
  # `type -P` resuelve al PRIMER grep del PATH, que es la trampa; lo que se exige es que la
  # sonda no acabe apuntándose a su propio directorio ni devuelva basura.
  case "$sal47" in
    ENVOLTORIO-RECURSIVO*) echo "  PASS  REQ-017 CA-06 el envoltorio detecta y denuncia resolverse a sí mismo (<$sal47>)"; PASS=$((PASS+1)) ;;
    [0-9]*\ [0-9]*)        echo "  PASS  REQ-017 CA-06 el envoltorio resuelve rutas absolutas antes de tocar el PATH y no se llama a sí mismo (<$sal47>)"; PASS=$((PASS+1)) ;;
    *)                     echo "  FAIL  REQ-017 CA-06 la sonda de procesos devolvió <${sal47:-vacío}> con un binario sombreado en el PATH"; FAIL=$((FAIL+1)) ;;
  esac
  rm -rf "$trampa47"
fi

# ---------- CA-06 · EL CORREDOR ACUSA A LA SECCIÓN QUE DEJA UN PROCESO VIVO ----------
# Se comprueba sobre el corredor REAL, con una sección sintética que deja un proceso
# corriendo, igual que hace `autoprueba-corredor.sh`. Es la mitad de CA-06 que no vive en
# la sonda sino en quien cierra la sección.
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-06 el corredor acusa" | grep -qi -- "$FILTRO"; then
  sint47="$RAIZ/sint47-$BASHPID"; mkdir -p "$sint47"
  { echo 'CASOS_ESPERADOS_SECCION=1'
    echo 'sleep 120 &'
    echo 'echo "  PASS  seccion sintetica que deja una sonda viva"'
  } > "$sint47/90-deja-sonda-viva.sh"
  out47="$(ARNES_SECCIONES_DIR="$sint47" bash "$BANCO47" 2>&1)"
  rc47=$?
  vivos47="$(printf '%s' "$out47" | grep -c 'dejando procesos vivos' || true)"
  if [ -z "$out47" ]; then
    echo "  FAIL  REQ-017 CA-06 el corredor acusa a la sección que deja un proceso vivo  la autoprueba no imprimió nada"; FAIL=$((FAIL+1))
  elif [ "${vivos47:-0}" -ge 1 ] && [ "$rc47" -ne 0 ]; then
    echo "  PASS  REQ-017 CA-06 el corredor acusa POR SU NOMBRE a la sección que deja un proceso vivo, y la vuelta sale en rojo"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-017 CA-06 el corredor no acusó el proceso vivo (rc=$rc47, avisos=$vivos47): una sonda huérfana envenenaría la vuelta siguiente"; FAIL=$((FAIL+1))
    printf '%s' "$out47" | tail -4 | sed 's/^/          /'
  fi
  rm -rf "$sint47"
fi

rm -rf "$HER47" "$SONDA47" "$OUT_HER47" "$OUT_ESTE47"-1.txt "$OUT_ESTE47"-2.txt "$OUT_ESTE47"-3.txt \
       "$ROJO47" "$LIMPIO47" "$MUDO47"
