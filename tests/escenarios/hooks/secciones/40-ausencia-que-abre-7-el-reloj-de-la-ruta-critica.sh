# Sección 40 (7 de 7) del banco — 40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos (invariantes 3 y 4 del README del banco).
#
# REQ-024 · `CA-07 (ii)` SOLO. Las otras tres vías del coste —(i) los procesos, (iii) y (iv)
# la linealidad del lector de la cola— SE QUEDAN en `40/2`, sin moverse ni duplicarse. Va en
# una parte 7 porque la 2 estaba en 400 de 400: `REQ-014 CA-18` manda PARTIR.
#
# QUÉ SE REPARÓ. Hasta el 2026-09-11 el caso tomaba UNA invocación de la sonda y decidía con
# `min_a/min_b` contra el techo, sin guarda de dispersión: le faltaba el TERCER ESTADO —«medí, y
# lo que medí no resuelve el factor que vigilo»—, así que una medición inconclusa salía FAIL.
# Medido sobre ESTE MISMO sujeto: con el mismo árbol en los DOS brazos —verdad 1,000× por
# construcción— la sonda recorre 0,875×–1,213× bajo contención, y una repetición da 1,213× con
# los brazos CONVERGIDOS a 1,176×: la convergencia sola no la atrapa. El cociente VERDADERO
# contra v1.33.0 es 1,118× (k=8 r=30, nula colapsada a 0,984×–1,005×), o sea que el techo se
# cumple y los rojos de CI eran ese coste real más el ruido del instrumento. Evidencia, método
# y demostraciones: `docs/arnes/req-024-ca-07-ii-reparacion/`.
#
# EL TECHO NO SE TOCA (1,250×), el caso NO sale de la puerta requerida y no hay
# `continue-on-error`: lo que cambia es lo que la puerta hace cuando NO puede resolver.
CASOS_ESPERADOS_SECCION=5
PISO_AUTONOMO_SECCION=329  # 23 preámbulo (líneas 1-23) + 73 maquinaria compartida duplicada (num07 y mat07 con la línea base, líneas 24-96) + 233 bloque indivisible mayor (el sujeto con su fixture, las constantes derivadas midiendo, la medición, razon07/veredicto07 y los CINCO casos, líneas 97-329) · REQ-014 CA-18. El tercer término es TODO lo que queda y eso se afirma, no se esconde: el caso real no existe sin la medición, y las cuatro demostraciones TIENEN que ejercer la función que decide y no una copia suya —partirlas la duplicaría y dejarían de acreditar nada—. Misma forma que 37/2 (552 líneas, piso 551).
seccion_nueva "--- 40/7 · el reloj de la ruta crítica y su guarda de dispersión (REQ-024 CA-07 ii) ---"

# UNO A UNO: concatenado, un valor VACÍO desaparece entre los dígitos del vecino.
num07() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# EL MATERIALIZADOR VIENE DUPLICADO de `40/2`, con su motivo largo allí: cada sección corre en su
# propio subshell y en `secciones/` no cabe un auxiliar. Residual AN-021-01: nadie comprueba que
# las copias no se desvíen.
REPO07="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT07_RUTAS='hooks tools'
MAT07_REG=''; MAT07_T0=0; MAT07_REF='-'; MAT07_ETIQ='-'
mat07_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT07_REG, UNA sola línea
  local est="$1" mot="$2" arch="$3" procs="$4" us
  us=$(( ${EPOCHREALTIME/./} - MAT07_T0 ))
  mot="${mot//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT07_REG="sonda=linea-base modo=medicion estado=$est motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT07_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$us procesos=$procs etiqueta=$MAT07_ETIQ ref=$MAT07_REF archivos=$arch"
}
mat07() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l modo tipo oid ruta n=0 i calc obtenido
  local dirs='' paths='' ejec='' procs=0
  local -a oids=() modos=() rutas=()
  MAT07_T0=${EPOCHREALTIME/./}
  MAT07_REF="${ref//[[:space:]]/_}"; MAT07_ETIQ="$MAT07_REF"; MAT07_REG=''
  # `-e` y no `-d`: en un `git worktree` `.git` es un ARCHIVO.
  [ -e "$REPO07/.git" ] || { mat07_reg sin-linea-base no-hay-.git-en-el-repositorio desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  git -C "$REPO07" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { mat07_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  lista="$(git -C "$REPO07" ls-tree -r "$ref" -- $MAT07_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat07_reg sin-linea-base "la-referencia-no-tiene-esas-rutas:$ref" desconocido "$procs"; return 1; }
  while IFS= read -r l || [ -n "$l" ]; do
    [ -n "$l" ] || continue
    modo="${l%% *}"; l="${l#* }"
    tipo="${l%% *}"; l="${l#* }"
    oid="${l%%$'\t'*}"; ruta="${l#*$'\t'}"
    [ "$tipo" = blob ] || continue
    n=$((n + 1))
    dirs="$dirs $dst/${ruta%/*}"
    paths="$paths$dst/$ruta"$'\n'
    oids+=("$oid"); modos+=("$modo"); rutas+=("$dst/$ruta")
    case "$modo" in *755) ejec="$ejec $dst/$ruta" ;; esac
  done <<< "$lista"
  [ "$n" -ge 1 ] || { mat07_reg sin-linea-base la-referencia-no-materializa-ningun-archivo desconocido "$procs"; return 1; }
  procs=$((procs + 1))
  mkdir -p $dirs 2>/dev/null || { mat07_reg sin-linea-base no-se-pudo-crear-el-destino desconocido "$procs"; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    procs=$((procs + 1))
    git -C "$REPO07" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { mat07_reg sin-linea-base "no-se-pudo-materializar:${ruta#"$dst"/}" desconocido "$procs"; return 1; }
  done <<< "$paths"
  if [ -n "$ejec" ]; then
    procs=$((procs + 1))
    chmod +x $ejec 2>/dev/null || { mat07_reg sin-linea-base no-se-pudo-fijar-el-modo-del-objeto desconocido "$procs"; return 1; }
  fi
  procs=$((procs + 1))
  calc="$(git -C "$REPO07" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { mat07_reg sin-linea-base no-se-pudo-verificar-el-contenido-materializado desconocido "$procs"; return 1; }
  i=0
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { mat07_reg sin-linea-base la-verificacion-devolvio-mas-lineas-que-archivos desconocido "$procs"; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { mat07_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]##*/}" desconocido "$procs"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { mat07_reg sin-linea-base "se-verificaron-$i-de-$n-archivos" desconocido "$procs"; return 1; }
  mat07_reg ok - "$n" "$procs"
  return 0
}
HER07="$RAIZ/her07-$BASHPID"; HER07_OK=no
mat07 v1.33.0 "$HER07" && HER07_OK=si
REGHER07="${MAT07_REG:-sin registro}"

# ---------- EL SUJETO: el MISMO fixture y el MISMO proyecto que `40/2` ----------
P07="$RAIZ/p07-$BASHPID"
mkdir -p "$P07/.arnes" "$P07/requirements" "$P07/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$P07/.arnes/config.json"   # SIN la llave: proyecto sin migrar
printf '# ESTADO\n' > "$P07/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P07/PENDING_APPROVAL.md"
cp "$REPO07"/requirements/REQ-*.md "$P07/requirements/" 2>/dev/null || :
ENT07="$RAIZ/ent07-$BASHPID.json"
CLAUDE_PROJECT_DIR="$P07" emite_write "$P07/requirements/REQ-951.md" '# REQ-951
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Hallazgos abiertos: (ninguno)
Rigor: critico' > "$ENT07"

# ---------- LAS CONSTANTES, TODAS DERIVADAS MIDIENDO ----------
# `K07`/`SER07` son los parámetros con los que este caso YA medía (`--k 4 --r 6`) y no se tocan:
# cambiarlos movería el sujeto a la vez que el juez.
SER07=6   # series por árbol, INTERCALADAS a,b,a,b por la propia sonda
K07=4     # repeticiones del sujeto DENTRO de cada serie
# KRAZ07 = repeticiones del PAR INTERCALADO ENTERO, cada una con SU razón; es lo que la
# reparación AÑADE, porque una sola invocación da un punto y un punto no tiene recorrido. Se
# DERIVA MIDIENDO (REQ-012 CA-03): sobre 300 razones reales en DOCE condiciones se mide cuánto
# del recorrido de la muestra entera ve ya la PEOR ventana de tamaño k. El mínimo sobre las
# doce sube 65 % → 67 % → 74 % de k=2 a k=4 y AHÍ SE ESTANCA; k=5 y k=6 lo dejan en el mismo
# 74 % y cuestan 25 % y 50 % más de reloj en la puerta. k=4 es el codo, no un redondeo.
KRAZ07=4
TECHO07=1250   # ‰. EL TECHO DE CA-07 (ii), INTACTO. El mismo número sirve de techo a la
               # convergencia: «un instrumento tiene que resolver al menos el factor que vigila».
FACTOR07=2000  # ‰. La regresión SINTÉTICA del par discriminante: no menos de 2×. Suelo derivado:
               # techo × el peor recorrido medido (1,250 × 1,386, la nula BB bajo contención) =
               # 1,733. OPERATIVO: se baja con la medición.
# LA ACREDITACIÓN, que impide que un SKIP se acumule sin cerrar nada:
# `ARNES_COSTE_RUTA_CRITICA=1` sube las series de 6 a 30 y el sujeto por serie de 4 a 8 —30× el
# coste—, lo que colapsa el recorrido y saca la serie del suelo de 50 ms. Mismo patrón que
# `REQ-017 CA-05`: no apaga la señal, deja de decidir cada PR con ella; sin la palanca el caso
# SIGUE en la puerta con el techo intacto. Medido: a k=8 r=30 las nueve razones caen en
# 1,059×-1,129× y la nula colapsa a 0,984×-1,005×, contra ±0,21 a k=4 r=6. Acredita 1,118×.
if [ "${ARNES_COSTE_RUTA_CRITICA:-}" = 1 ]; then SER07=30; K07=8; fi
# Milésimas -> texto, SIN fork: `printf -v` es builtin y no abre subshell.
FMT07=''
fmt07() { printf -v FMT07 '%d.%03d×' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }

# ---------- LA MEDIDA: KRAZ07 pares intercalados, cada uno con SU razón ----------
REPS07=''; FALTA07=''
if [ "$HER07_OK" != si ]; then
  FALTA07="no hay línea base v1.33.0 ($REGHER07)"
else
  for ((n07 = 1; n07 <= KRAZ07; n07++)); do
    reg07="$("$UTIL_DIR/sonda-reloj.sh" --k "$K07" --r "$SER07" --etiqueta "ruta-critica-024-r$n07" \
      --sujeto-a "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT07' >/dev/null 2>&1" \
      --sujeto-b "bash '$HER07/hooks/guard-completado.sh' < '$ENT07' >/dev/null 2>&1" 2>/dev/null)"
    if sonda_lee "$reg07" && [ "${SONDA[estado]}" = ok ]; then
      REPS07="$REPS07 ${SONDA[min_a]:-}:${SONDA[min2_a]:-}:${SONDA[min_b]:-}:${SONDA[min2_b]:-}"
    else
      # Entra IGUAL, vacía: descartarla en silencio encogería la k sin decirlo. Va a SKIP.
      FALTA07="la sonda de reloj no midió en la repetición $n07 (${SONDA_MOTIVO:-estado=${SONDA[estado]:-?} motivo=${SONDA[motivo]:-?}})"
      REPS07="$REPS07 :::"
    fi
  done
fi

# ---------- EL VEREDICTO, EN DOS FUNCIONES PURAS ----------
# PURAS para ejercer la abstención con entradas sintéticas: en una corrida sana la sonda
# converge, así que el camino que más importa es el que nunca se recorrería. PORTADAS de
# `REQ-017 CA-08 (ii)` (`37/5`: `razon08_47`/`veredicto08_47`), donde ya estaban probadas.
R07=''; MOT07=''; CONV07=0
razon07() {   # <ue:ue2:uh:uh2 en µs> -> R07 y CONV07, o R07 vacío y MOT07 con el motivo
  local rep="$1" ue ue2 uh uh2 ce ch x rob
  R07=''; MOT07=''; CONV07=0
  ue="${rep%%:*}"; x="${rep#*:}"; ue2="${x%%:*}"; x="${x#*:}"; uh="${x%%:*}"; uh2="${x##*:}"
  for x in "$ue" "$ue2" "$uh" "$uh2"; do
    num07 "$x" && [ "$x" -gt 0 ] && continue
    MOT07="la sonda no dio $SER07 series por árbol con sus dos mínimos (este ${ue:-vacío}/${ue2:-vacío}µs · heredada ${uh:-vacío}/${uh2:-vacío}µs)"; return 0
  done
  if [ "$uh" -lt 50000 ] || [ "$ue" -lt 50000 ]; then
    MOT07="serie por debajo del suelo de 50 ms (este ${ue}µs · heredada ${uh}µs): el reloj no distingue del ruido"; return 0
  fi
  ce=$(( ue2 * 1000 / ue )); ch=$(( uh2 * 1000 / uh ))
  CONV07="$ce"; [ "$ch" -gt "$ce" ] && CONV07="$ch"
  if [ "$CONV07" -gt "$TECHO07" ]; then
    # LA RAZÓN OBTENIDA SE CALCULA AQUÍ, ANTES DE ABSTENERSE, Y VA EN `MOT07` — NUNCA EN `R07`,
    # que no vacío significa «hay razón válida para juzgar». Un SKIP sin la cifra que sí se
    # obtuvo no dice DE QUÉ se abstiene; se perdió así una vez (QA-017-16, `contrato`).
    fmt07 $(( ue * 1000 / uh )); rob="$FMT07"
    fmt07 "$ce"; x="$FMT07"; fmt07 "$ch"; ce="$FMT07"; fmt07 "$TECHO07"; ch="$FMT07"
    MOT07="la sonda NO convergió: segundo mínimo / mínimo = $x (este) y $ce (heredada), por encima de su propio techo $ch — no puede distinguir una regresión de su ruido. La razón que sí obtuvo es $rob, y sobre eso no se firma"
    return 0
  fi
  R07=$(( ue * 1000 / uh ))
}
# LA CONVERGENCIA ES NECESARIA Y NO SUFICIENTE, y está MEDIDO arriba: responde «¿se asentó CADA
# serie?», no «¿puede ESTE COCIENTE distinguir el factor que vigila?». Por eso ENCIMA va la
# resolución sobre la RAZÓN: PASS si máx(r) <= techo (conforme en TODAS), FAIL si mín(r) > techo
# (excedido en TODAS, así que no lo puso ahí el vecino) y SKIP en cuanto el techo cae DENTRO del
# recorrido. La unanimidad es DE CONTRATO —la definición de «la decisión no depende del ruido»—
# y no admite mayoría, promedio ni «la mejor de k». `guarda = no` reproduce la regla ANTERIOR y
# existe sólo para el par discriminante: sin ella, un SKIP no demuestra que lo causara la
# guarda. No toca los contadores: no es un caso, es el testigo de uno.
veredicto07() {   # <nombre> <guarda: si|no> <rep...>, rep = ue:ue2:uh:uh2 en µs
  local nombre="$1" guarda="$2"; shift 2
  local rep n=0 rmin='' rmax='' cmax=0 lista='' techo mn mx rec
  fmt07 "$TECHO07"; techo="$FMT07"
  if [ "$guarda" = no ]; then
    for rep in "$@"; do
      razon07 "$rep"
      if [ -z "$R07" ]; then echo "  SKIP  $nombre  $MOT07"; continue; fi
      fmt07 "$R07"
      if [ "$R07" -le "$TECHO07" ]; then echo "  PASS  $nombre  $FMT07 <= $techo"
      else echo "  FAIL  $nombre  $FMT07 > $techo"; fi
    done
    return 0
  fi
  for rep in "$@"; do
    n=$((n + 1))
    razon07 "$rep"
    [ -n "$R07" ] || { echo "  SKIP  $nombre  repetición $n de $#: $MOT07"; return 0; }
    if [ "$CONV07" -gt "$cmax" ]; then cmax="$CONV07"; fi
    fmt07 "$R07"; lista="$lista $FMT07"
    if [ -z "$rmin" ] || [ "$R07" -lt "$rmin" ]; then rmin="$R07"; fi
    if [ -z "$rmax" ] || [ "$R07" -gt "$rmax" ]; then rmax="$R07"; fi
  done
  [ "$n" -ge 1 ] || { echo "  SKIP  $nombre  no llegó ninguna repetición del par intercalado"; return 0; }
  rec=$(( rmax * 1000 / rmin ))
  fmt07 "$rmin"; mn="$FMT07"; fmt07 "$rmax"; mx="$FMT07"; fmt07 "$rec"; rec="$FMT07"; fmt07 "$cmax"; cmax="$FMT07"
  # Las k razones, el recorrido y el techo se publican SIEMPRE: son la evidencia de que la
  # decisión no depende del ruido, no el adorno del SKIP.
  lista="$n razones:$lista · recorrido $rec · techo $techo · peor convergencia $cmax · k=$K07 r=$SER07"
  if [ "$rmax" -le "$TECHO07" ]; then
    echo "  PASS  $nombre  máx(r) $mx <= techo en las $lista"; PASS=$((PASS+1))
  elif [ "$rmin" -gt "$TECHO07" ]; then
    echo "  FAIL  $nombre  mín(r) $mn > techo en TODAS: es regresión, no ruido — el techo es OPERATIVO y no se sube, lo que baja es el coste del lector — $lista"; FAIL=$((FAIL+1))
  else
    echo "  SKIP  $nombre  el techo cae DENTRO del recorrido observado [$mn, $mx]: el instrumento no distingue el factor que vigila, y una medición inconclusa NO es una aprobación. Vía de acreditación: repetir con ARNES_COSTE_RUTA_CRITICA=1 (r=30, k=8) o en un host menos cargado — nunca subir el techo — $lista"
  fi
}

# ---------- EL CASO ----------
NOM07="REQ-024 CA-07 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base"
if [ -z "$FILTRO" ] || printf '%s' "$NOM07" | grep -qi -- "$FILTRO"; then
  if [ -z "${REPS07// /}" ]; then
    echo "  SKIP  $NOM07  ${FALTA07:-no se pudo medir}: no llegó ninguna repetición del par intercalado"
  else
    veredicto07 "$NOM07" si $REPS07   # SIN comillas a propósito: una palabra por repetición
  fi
fi

# ---------- DEMOSTRACIÓN 1 · LOS TRES ESTADOS, con entradas sintéticas (la sonda converge en
# una corrida sana, así que sin esto la abstención no se recorrería nunca) ----------
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-07 (ii) la sonda que no converge se ABSTIENE" | grep -qi -- "$FILTRO"; then
  nom07="REQ-024 CA-07 (ii) la sonda que no converge se ABSTIENE: nunca PASS y nunca FAIL, y la abstención manda sobre el rojo"
  obs07="$( {
    veredicto07 sonda-de-prueba si 1000000:1050000:1000000:1020000   # converge y está bajo el techo
    veredicto07 sonda-de-prueba si 1300000:1310000:1000000:1020000   # converge y lo CRUZA: eso sí es FAIL
    veredicto07 sonda-de-prueba si 1000000:1400000:1000000:1020000   # este árbol no converge (1,400×)
    veredicto07 sonda-de-prueba si 1000000:1050000:1000000:1400000   # la heredada no converge
    veredicto07 sonda-de-prueba si 1300000:1700000:1000000:1020000   # cruzaría el techo Y no converge: manda la abstención
    veredicto07 sonda-de-prueba si        '':1050000:1000000:1020000 # falta un número
    veredicto07 sonda-de-prueba si   40000:41000:40000:41000         # bajo el suelo de 50 ms
  } 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ' )"
  esp07='PASS FAIL SKIP SKIP SKIP SKIP SKIP '
  if [ "$obs07" = "$esp07" ]; then
    echo "  PASS  $nom07  (7 sondas → $obs07)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom07  se esperaba <$esp07> y se obtuvo <$obs07>"; FAIL=$((FAIL+1))
  fi
fi
# Los contadores no se tocan de más: `veredicto07` corrió en un subshell y sus PASS/FAIL con él.

# ---------- DEMOSTRACIÓN 2 · EL CONTENIDO DEL SKIP, y no sólo su palabra ----------
# La autoprueba de arriba reduce cada salida a la PALABRA del veredicto, así que una guarda cuyo
# contrato es LO QUE DICE quedaría verificada sólo por LO QUE DECIDE: por ese hueco se perdió el
# tercer elemento del SKIP en el criterio hermano (QA-017-16, `contrato`). Las tres cifras van
# DISTINTAS entre sí y del techo —1,400× · 1,020× · 1,600×—: con dos iguales, una podría darse
# por presente porque casó con la otra.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-07 (ii) el SKIP por no convergencia cita las TRES cifras" | grep -qi -- "$FILTRO"; then
  nom07="REQ-024 CA-07 (ii) el SKIP por no convergencia cita las TRES cifras: las dos razones de convergencia y la razón que sí obtuvo"
  # Sin subshell A PROPÓSITO: la abstención contrata que `R07` quede VACÍO, y en `$( )` ese
  # estado moriría con el subshell.
  razon07 1000000:1400000:625000:637500   # este 1,400× · heredada 1,020× · razón 1,600×
  faltacif07=''
  [ -z "$R07" ] || faltacif07="$faltacif07 R07-no-quedó-vacío(<$R07>)"
  case "$MOT07" in *'1.400×'*) ;; *) faltacif07="$faltacif07 la-convergencia-de-este(1.400×)" ;; esac
  case "$MOT07" in *'1.020×'*) ;; *) faltacif07="$faltacif07 la-convergencia-de-la-heredada(1.020×)" ;; esac
  case "$MOT07" in *'1.600×'*) ;; *) faltacif07="$faltacif07 la-razón-que-sí-obtuvo(1.600×)" ;; esac
  if [ -z "$faltacif07" ]; then
    echo "  PASS  $nom07  <$MOT07>"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom07  al mensaje le falta:$faltacif07 — salió <$MOT07>"; FAIL=$((FAIL+1))
  fi
fi

# ---------- DEMOSTRACIONES 3 y 4 · EL PAR DISCRIMINANTE, que se EJECUTA, no se argumenta ----
# «La abstención no tapa una regresión real» es una afirmación sobre el mecanismo; se ejerce. El
# forzador es SINTÉTICO y afecta a PARTE de las repeticiones porque es DETERMINISTA y no le
# cuesta reloj a la puerta —una contención real que unas veces dispersa y otras no sería un rojo
# intermitente, que es el modo de fallo que esto existe para quitar—. La razón VERDADERA es 1,0
# en las cuatro y el forzador infla el brazo «este» de UNA hasta 1,320×: la magnitud del rojo
# real de CI sobre `67b06fe`, reproducida aquí sobre el sujeto fiel bajo contención (1,280× y
# 1,333×). Los dos brazos CONVERGEN en las cuatro (1,010×), así que si sale la abstención, sale
# de la guarda del recorrido y no de la de convergencia.
DISP07='1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000 1320000:1333000:1000000:1010000 1000000:1010000:1000000:1010000'
LIMPIO07='1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000 1000000:1010000:1000000:1010000'
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-07 (ii) par discriminante NEGATIVO" | grep -qi -- "$FILTRO"; then
  nom07="REQ-024 CA-07 (ii) par discriminante NEGATIVO: dispersión ensanchada SIN regresión da SKIP, y con la guarda desactivada la MISMA entrada da PASS o FAIL según la repetición"
  con07="$(veredicto07 sonda-de-prueba si $DISP07 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  sin07="$(veredicto07 sonda-de-prueba no $DISP07 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  if [ "$con07" = 'SKIP ' ] && [ "$sin07" = 'PASS PASS FAIL PASS ' ]; then
    echo "  PASS  $nom07  (con la guarda: $con07· sin ella: $sin07— el rojo lo quita la guarda, no la entrada)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom07  con la guarda se esperaba <SKIP > y salió <$con07>; sin ella se esperaba <PASS PASS FAIL PASS > y salió <$sin07>"; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-07 (ii) par discriminante POSITIVO" | grep -qi -- "$FILTRO"; then
  nom07="REQ-024 CA-07 (ii) par discriminante POSITIVO: una regresión sintética de 2× da FAIL y no SKIP, y sin regresión ni forzador da PASS"
  # La regresión va SOBRE la entrada dispersa —forzador incluido—, no sobre una limpia: hay que
  # demostrar que la abstención no se traga una regresión ESTANDO el ruido presente.
  reg07=''
  for r07 in $DISP07; do
    ue07="${r07%%:*}"; x07="${r07#*:}"
    reg07="$reg07 $(( ue07 * FACTOR07 / 1000 )):$(( ${x07%%:*} * FACTOR07 / 1000 )):${x07#*:}"
  done
  obsreg07="$(veredicto07 sonda-de-prueba si $reg07 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  obslim07="$(veredicto07 sonda-de-prueba si $LIMPIO07 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p' | tr '\n' ' ')"
  if [ "$obsreg07" = 'FAIL ' ] && [ "$obslim07" = 'PASS ' ]; then
    echo "  PASS  $nom07  (con la regresión de 2×: $obsreg07· sin ella y sin forzador: $obslim07)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom07  con la regresión se esperaba <FAIL > y salió <$obsreg07>; sin ella se esperaba <PASS > y salió <$obslim07>"; FAIL=$((FAIL+1))
  fi
fi

rm -rf "$HER07" "$P07" "$ENT07"
