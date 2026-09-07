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
CASOS_ESPERADOS_SECCION=8
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
OUT_ESTE47="$RAIZ/s32-este-$BASHPID.txt"
OUT_HER47="$RAIZ/s32-her-$BASHPID.txt"

# ---------- CA-05 · LA RUTA CRÍTICA, CONTRA LA MISMA SECCIÓN EN EL ÁRBOL HEREDADO ----------
# La sección 32 corrida AISLADA y con `ARNES_JOBS=1` contra los dos árboles, en la misma
# máquina y la misma corrida: así la velocidad de la máquina se cancela y lo que queda es
# la razón. Se comparan las dos cosas, y el orden importa: PRIMERO el inventario —la
# velocidad no se compra dejando de probar— y sólo después el reloj.
#
# ESTA MEDICIÓN ES CARA Y SE DICE: la corrida del árbol heredado cuesta lo que costaba el
# defecto (~75 s en Linux), porque es literalmente el defecto corriendo. Se paga entera
# por defecto —una puerta que no se ejecuta no mide— y se puede apagar con
# `ARNES_COSTE_RUTA_CRITICA=0` cuando se está diagnosticando otra cosa, diciéndolo.
corre47() {   # <dir de hooks> <archivo de salida> -> imprime microsegundos, o vacío
  local hd="$1" salida="$2" t0 t1
  [ -n "${EPOCHREALTIME:-}" ] || return 1
  t0=${EPOCHREALTIME/./}
  ARNES_JOBS=1 ARNES_HOOKS_DIR="$hd" bash "$BANCO47" secciones/32-huecos-auditoria-r001.sh > "$salida" 2>&1
  t1=${EPOCHREALTIME/./}
  # UNA CORRIDA QUE NO PRODUJO CASOS NO ES UNA CORRIDA RÁPIDA: es una que no midió.
  grep -q '^  \(PASS\|FAIL\|SKIP\)  ' "$salida" || return 1
  printf '%s\n' "$((t1 - t0))"
}
u_este47=''; u_her47=''; motivo47=''
if [ "${ARNES_COSTE_RUTA_CRITICA:-1}" = 0 ]; then
  motivo47="apagada a mano con ARNES_COSTE_RUTA_CRITICA=0"
elif [ "$HER47_OK" != si ]; then
  motivo47="no hay línea base: el tag v1.32.1 no está en este clon"
elif [ ! -r "$BANCO47" ] || [ ! -r "$INV47" ]; then
  motivo47="no encuentro el corredor o el inventario junto a esta sección"
else
  for _r47 in 1 2 3; do
    _u47="$(corre47 "$HOOKS_DIR" "$OUT_ESTE47")" || { motivo47="la corrida de este árbol no produjo casos"; u_este47=''; break; }
    if [ -z "$u_este47" ] || [ "$_u47" -lt "$u_este47" ]; then u_este47="$_u47"; fi
  done
  # UNA sola corrida heredada, y es deliberado: la carga sólo puede AÑADIR tiempo, así que
  # un denominador inflado sólo puede hacer la razón MÁS pequeña... que es la dirección que
  # ABRE. Se compensa con el margen: el techo es 0,25× y lo medido ronda 0,12×, así que
  # haría falta que la línea base se inflara al DOBLE para que un verde fuera falso. Tres
  # corridas heredadas costarían 150 s más para cerrar un hueco que el margen ya cierra.
  [ -n "$u_este47" ] && { u_her47="$(corre47 "$HER47/hooks" "$OUT_HER47")" || motivo47="la corrida heredada no produjo casos"; }
fi

if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 inventario" | grep -qi -- "$FILTRO"; then
  if [ -z "$u_este47" ] || [ -z "$u_her47" ]; then
    echo "  SKIP  REQ-017 CA-05 (i) la sección 32 decide lo mismo contra los dos árboles  ${motivo47:-no se pudo medir}"
  else
    a47="$(bash "$INV47" "$OUT_HER47"  2>/dev/null)"
    b47="$(bash "$INV47" "$OUT_ESTE47" 2>/dev/null)"
    if [ -z "$a47" ] || [ -z "$b47" ]; then
      echo "  FAIL  REQ-017 CA-05 (i) uno de los dos inventarios salió vacío (heredado=${#a47}B, este=${#b47}B): no se comparó nada"; FAIL=$((FAIL+1))
    elif [ "$a47" = "$b47" ]; then
      echo "  PASS  REQ-017 CA-05 (i) la sección 32 da el MISMO inventario caso→veredicto en los dos árboles ($(printf '%s\n' "$b47" | grep -c '^') casos)"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-017 CA-05 (i) el inventario de la sección 32 cambió: la velocidad se compró dejando de probar"; FAIL=$((FAIL+1))
      diff <(printf '%s\n' "$a47") <(printf '%s\n' "$b47") 2>/dev/null | head -6 | sed 's/^/          /'
    fi
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-017 CA-05 reloj" | grep -qi -- "$FILTRO"; then
  if [ -z "$u_este47" ] || [ -z "$u_her47" ]; then
    echo "  SKIP  REQ-017 CA-05 (ii) el reloj de la ruta crítica  ${motivo47:-no se pudo medir} (este=<${u_este47:-vacío}>µs heredada=<${u_her47:-vacío}>µs)"
  else
    r47=$(( u_este47 * 1000 / u_her47 ))
    if [ "$r47" -le 250 ]; then
      echo "  PASS  REQ-017 CA-05 (ii) la ruta crítica cuesta $(awk -v c=$r47 'BEGIN{printf "%.3f", c/1000}')× lo de v1.32.1 (techo 0,250×; $(awk -v u=$u_este47 'BEGIN{printf "%.2f", u/1e6}') s frente a $(awk -v u=$u_her47 'BEGIN{printf "%.2f", u/1e6}') s)"; PASS=$((PASS+1))
    else
      echo "  FAIL  REQ-017 CA-05 (ii) la ruta crítica cuesta $(awk -v c=$r47 'BEGIN{printf "%.3f", c/1000}')× lo de v1.32.1 y el techo es 0,250× ($(awk -v u=$u_este47 'BEGIN{printf "%.2f", u/1e6}') s frente a $(awk -v u=$u_her47 'BEGIN{printf "%.2f", u/1e6}') s)"; FAIL=$((FAIL+1))
    fi
  fi
fi

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

rm -rf "$HER47" "$SONDA47" "$OUT_ESTE47" "$OUT_HER47"
