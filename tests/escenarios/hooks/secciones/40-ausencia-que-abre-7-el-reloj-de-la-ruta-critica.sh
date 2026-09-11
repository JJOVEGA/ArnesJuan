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
CASOS_ESPERADOS_SECCION=6
PISO_AUTONOMO_SECCION=449  # 23 preámbulo (líneas 1-23) + 73 maquinaria compartida duplicada (num07 y mat07 con la línea base, líneas 24-96) + 353 bloque indivisible mayor (el sujeto con su fixture, las constantes derivadas midiendo, mide07, razon07/resuelve07/cierre07/veredicto07, el caso con su bucle de reintento y las CINCO demostraciones, líneas 97-449) · REQ-014 CA-18. El tercer término es TODO lo que queda y eso se afirma, no se esconde: el caso real no existe sin la medición, y las cinco demostraciones TIENEN que ejercer la función que decide y no una copia suya —partirlas la duplicaría y dejarían de acreditar nada—. Misma forma que 37/2 (552 líneas, piso 551). Creció de 329 a 449 en la vuelta 4 y el techo NO se compró deformando el sujeto: el techo que ese piso gobierna es 561 y el archivo mide 449.
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
# MANDOS RE-DERIVADOS MIDIENDO EN EL RUNNER (vuelta 4 fase 1, corrida `1b3760e`: 4 vCPU,
# `ARNES_JOBS=6`, carga 5,04). `k=4 r=6` NO RESUELVE EL FACTOR QUE VIGILA, y no es opinión: con
# el MISMO árbol en los dos brazos —razón verdadera 1,000× POR CONSTRUCCIÓN— esos mandos
# recorren [0,805× , 1,123×] allí, de modo que una regresión REAL de 1,28× cae DENTRO del ruido
# y sale SKIP (QA-024-21, medido: `SKIP·SKIP·SKIP·FAIL·SKIP`, rc 0 en 4 de 5). Con `k=8` la
# MISMA corrida y la MISMA carga 5,04 dan 1018 en vez de 805: `k` alarga la serie de ~54 ms a
# ~110 ms y la saca del régimen en que manda el planificador. `k=8` es, por tanto, la palanca
# MEDIDA, y por eso sube.
#
# `r=30` ES PROVISIONAL Y SE DICE AQUÍ, NO EN OTRO DOCUMENTO. La fase 1 lo eligió sobre la
# distribución NULA (mismo árbol en los dos brazos), donde `r` sí estrecha el recorrido y
# plateaua en ~1,01 a partir de r=30. La fase 2 fue a confirmarlo con una regresión REAL
# inyectada y lo REFUTÓ EN PARTE: sobre la comparación REAL (candidato contra v1.33.0, dos
# árboles distintos) el recorrido de este host NO baja con `r` —1,066 a r=15, 1,10 a r=30,
# 1,072–1,125 a r=60—, así que la nula SUBESTIMA la dispersión de lo que la puerta mide de
# verdad. Consecuencia declarada y no escondida: la detección de 1,28× a estos mandos NO está
# demostrada en el runner, y lo que la decidirá es el recorrido REAL que este caso publica en
# cada corrida. Qué se midió, con qué método y qué queda abierto:
# `docs/arnes/req-024-ca-07-ii-reparacion/05-fase-2-lo-construido-y-lo-que-falta.md`.
# OPERATIVOS los dos: se mueven CON LA MEDICIÓN, nunca para que algo pase.
SER07=30  # series por árbol, INTERCALADAS a,b,a,b por la propia sonda
K07=8     # repeticiones del sujeto DENTRO de cada serie
# KRAZ07 = repeticiones del PAR INTERCALADO ENTERO, cada una con SU razón; es lo que la
# reparación AÑADE, porque una sola invocación da un punto y un punto no tiene recorrido. Se
# DERIVA MIDIENDO (REQ-012 CA-03): sobre 300 razones reales en DOCE condiciones se mide cuánto
# del recorrido de la muestra entera ve ya la PEOR ventana de tamaño k. El mínimo sobre las
# doce sube 65 % → 67 % → 74 % de k=2 a k=4 y AHÍ SE ESTANCA; k=5 y k=6 lo dejan en el mismo
# 74 % y cuestan 25 % y 50 % más de reloj en la puerta. k=4 es el codo, no un redondeo.
KRAZ07=4
TECHO07=1250   # ‰. EL TECHO DE CA-07 (ii), INTACTO. El mismo número sirve de techo a la
               # convergencia: «un instrumento tiene que resolver al menos el factor que vigila».
FACTOR07=1280  # ‰. La regresión SINTÉTICA del par discriminante. BAJA DE 2,000× A 1,280× —la
               # dirección OPERATIVA declarada— porque el suelo de detección bajó al bajar el
               # ruido: suelo = techo × el peor recorrido medido A ESTOS MANDOS = 1,250 × 1,021
               # (peor ventana de 4 de la nula en el runner) = 1,276. Y 1,280 no es un número
               # cualquiera por encima de 1,276: es LA MAGNITUD DE LOS ROJOS REALES DE CI
               # (1,257×–1,338×) y la que `QA-024-21` demostró INDETECTABLE con los mandos
               # viejos. El par discriminante pasa a ejercer EXACTAMENTE el caso que falló.
# EL SUELO DE DETECCIÓN NO ES UNA CONSTANTE, Y ÉSE ES EL ARREGLO DE `QA-024-21`. El hallazgo
# dice que «el propio código deriva su suelo de detección en 1,733×, en un comentario y en ningún
# criterio». La tentación es mover ese número; la medición dice que NINGÚN número sirve: el
# suelo es `techo × recorrido`, y el recorrido DEPENDE DE LA MÁQUINA Y DEL MOMENTO —medido en la
# vuelta 4: recorrido real 1,066–1,125 en WSL2 bajo el banco y 1,911 en el runner con `k=4 r=6`,
# o sea suelos de 1,33× a 2,39× para el MISMO código—. Un suelo escrito a mano queda falso en
# cuanto cambia el host, y publicado en el mensaje sería una cota mentida. Así que se DERIVA de
# la propia medición que se está juzgando (`suelo = TECHO07 × recorrido observado`) y se publica
# en cada veredicto: dice «por debajo de este factor, ESTA corrida no habría podido probar nada».
# LA ACREDITACIÓN, a demanda y con los mandos MÁS PRECISOS QUE SE MIDIERON:
# `ARNES_COSTE_RUTA_CRITICA=1` sube las series de 15 a 60 —4× el coste, 52,9 s por veredicto en
# el runner—, que es el ajuste `V3` del barrido de viabilidad: nula [0,999× , 1,009×], el
# recorrido más estrecho de los cuatro. Mismo patrón que `REQ-017 CA-05`: no apaga la señal,
# deja de decidir cada PR con ella; sin la palanca el caso SIGUE en la puerta con el techo
# intacto. `k` NO sube aquí porque ya está en 8: a partir de ahí lo que queda por bajar es la
# cola del mínimo, y eso lo baja `r`.
if [ "${ARNES_COSTE_RUTA_CRITICA:-}" = 1 ]; then SER07=60; fi
# CUÁNTAS VECES SE VUELVE A MEDIR ANTES DE DECLARAR QUE NO SE PUDO ACREDITAR. Es la mitad
# mecánica de «una medición inconcluyente es acreditación PENDIENTE»: el caso no acepta la
# inconclusión mientras le quede presupuesto. Derivado de la medición, no redondeado: en el
# runner la contención que estropea una medida dura lo que tardan en vaciarse las otras
# secciones —las dos repeticiones malas de `k=4 r=6` caen en los primeros ~4 s de la sección y
# a los ~20 s ya no hay ninguna—, y un intento a estos mandos cuesta ~15 s, así que el SEGUNDO
# intento cae YA FUERA de esa ventana. El tercero es el margen. OPERATIVO: se BAJA con la
# medición, y su suelo es 1 —con 0 no habría medición—. Coste del peor caso: 3 × 14,8 s = 44,3 s,
# que sigue bajo los 60 s de presupuesto que la fase 1 fijó ANTES de medir.
INTENTOS07=3
# Milésimas -> texto, SIN fork: `printf -v` es builtin y no abre subshell.
FMT07=''
fmt07() { printf -v FMT07 '%d.%03d×' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }

# ---------- LA MEDIDA: KRAZ07 pares intercalados, cada uno con SU razón ----------
# En una FUNCIÓN, y ésa es la mitad mecánica de «una medición inconcluyente es acreditación
# PENDIENTE»: para no aceptar la inconclusión hay que poder VOLVER A MEDIR, y para eso la
# medida tiene que ser repetible. No dicta ningún veredicto —sólo deja `REPS07`/`FALTA07`—, así
# que ejecuta el hook sin decidir y la invariante 1 del corredor no le aplica.
# Además publica DE QUÉ MÁQUINA salió la muestra (`MAQ07`): sin eso, dos abstenciones no se
# pueden sumar, que es la mitad que `REQ-017 CA-08 (ii)` dejó abierta con dueño.
REPS07=''; FALTA07=''; MAQ07='máquina desconocida'
mide07() {   # -> REPS07, FALTA07, MAQ07
  local n07 reg07
  REPS07=''; FALTA07=''
  if [ "$HER07_OK" != si ]; then
    FALTA07="no hay línea base v1.33.0 ($REGHER07)"
    return 0
  fi
  for ((n07 = 1; n07 <= KRAZ07; n07++)); do
    reg07="$("$UTIL_DIR/sonda-reloj.sh" --k "$K07" --r "$SER07" --etiqueta "ruta-critica-024-i$INT07-r$n07" \
      --sujeto-a "bash '$HOOKS_DIR/guard-completado.sh' < '$ENT07' >/dev/null 2>&1" \
      --sujeto-b "bash '$HER07/hooks/guard-completado.sh' < '$ENT07' >/dev/null 2>&1" 2>/dev/null)"
    if sonda_lee "$reg07" && [ "${SONDA[estado]}" = ok ]; then
      REPS07="$REPS07 ${SONDA[min_a]:-}:${SONDA[min2_a]:-}:${SONDA[min_b]:-}:${SONDA[min2_b]:-}"
    else
      # Entra IGUAL, vacía: descartarla en silencio encogería la k sin decirlo.
      FALTA07="la sonda de reloj no midió en la repetición $n07 (${SONDA_MOTIVO:-estado=${SONDA[estado]:-?} motivo=${SONDA[motivo]:-?}})"
      REPS07="$REPS07 :::"
    fi
    [ -z "${SONDA[plataforma]:-}" ] || MAQ07="máquina ${SONDA[plataforma]} · carga ${SONDA[carga]:-?} · jobs ${ARNES_JOBS:-6}"
  done
}

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
# `resuelve07` DECIDE y no imprime; `veredicto07` imprime y no decide. Se parten porque el
# reintento de la acreditación necesita preguntar «¿resolvió?» sin emitir todavía, y preguntarlo
# con una copia de la regla serían DOS SEDES de la unanimidad, que se desfasan.
RES07=''; LISTA07=''; MN07=''; MX07=''; MOTRES07=''
resuelve07() {   # <rep...> -> RES07 = pass|fail|inconcluso (+ LISTA07, MN07, MX07, MOTRES07)
  local rep n=0 rmin='' rmax='' cmax=0 lista='' techo rec
  RES07=''; LISTA07=''; MN07=''; MX07=''; MOTRES07=''
  fmt07 "$TECHO07"; techo="$FMT07"
  for rep in "$@"; do
    n=$((n + 1))
    razon07 "$rep"
    [ -n "$R07" ] || { RES07=inconcluso; MOTRES07="repetición $n de $#: $MOT07"; return 0; }
    if [ "$CONV07" -gt "$cmax" ]; then cmax="$CONV07"; fi
    fmt07 "$R07"; lista="$lista $FMT07"
    if [ -z "$rmin" ] || [ "$R07" -lt "$rmin" ]; then rmin="$R07"; fi
    if [ -z "$rmax" ] || [ "$R07" -gt "$rmax" ]; then rmax="$R07"; fi
  done
  [ "$n" -ge 1 ] || { RES07=inconcluso; MOTRES07="no llegó ninguna repetición del par intercalado"; return 0; }
  rec=$(( rmax * 1000 / rmin ))
  fmt07 "$rmin"; MN07="$FMT07"; fmt07 "$rmax"; MX07="$FMT07"; fmt07 "$rec"; rec="$FMT07"
  fmt07 "$cmax"; cmax="$FMT07"; fmt07 $(( TECHO07 * ( rmax * 1000 / rmin ) / 1000 )); local suelo="$FMT07"
  # Las k razones, el recorrido, el techo, el SUELO DE DETECCIÓN y LA MÁQUINA se publican
  # SIEMPRE: son la evidencia de que la decisión no depende del ruido, no el adorno del SKIP.
  # El suelo va aquí y no en un comentario porque `QA-024-21` midió justo eso —el suelo vivía en
  # un comentario y en ningún criterio—, y la máquina porque sin ella dos abstenciones no se
  # pueden sumar (`REQ-017 CA-08 (ii)`, mitad abierta con dueño).
  LISTA07="$n razones:$lista · recorrido $rec · techo $techo · suelo de detección $suelo · peor convergencia $cmax · k=$K07 r=$SER07 · $MAQ07"
  if [ "$rmax" -le "$TECHO07" ]; then RES07=pass
  elif [ "$rmin" -gt "$TECHO07" ]; then RES07=fail
  else RES07=inconcluso; MOTRES07="el techo cae DENTRO del recorrido observado [$MN07, $MX07]"; fi
}
# LA ESCALADA, en su propia función y con una sola sede: «una medición inconcluyente es
# ACREDITACIÓN PENDIENTE». Mientras quede presupuesto se vuelve a medir; agotado, la inconclusión
# DEJA DE SER UN VEREDICTO y el caso NO sale verde — que es la regla que el arnés ya tiene
# escrita para sus puertas: una puerta que no puede medir no deja pasar (`AGENTS.md` §13).
cierre07() {   # <res> <intento> -> emitir | reintentar | sin-acreditar
  case "${1:-}" in
    pass|fail) printf 'emitir\n' ;;
    *) if [ "${2:-0}" -lt "$INTENTOS07" ]; then printf 'reintentar\n'; else printf 'sin-acreditar\n'; fi ;;
  esac
}
veredicto07() {   # <nombre> <guarda: si|no> <rep...>, rep = ue:ue2:uh:uh2 en µs
  local nombre="$1" guarda="$2"; shift 2
  local rep techo via
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
  resuelve07 "$@"
  # QA-024-22: la vía de acreditación NO puede ofrecer la palanca que ya se está usando. Se
  # ofrecía, y el mensaje se salía a sí mismo.
  via="repetir con ARNES_COSTE_RUTA_CRITICA=1 (k=$K07, r=60) o en un host menos cargado — nunca subir el techo"
  [ "${ARNES_COSTE_RUTA_CRITICA:-}" != 1 ] || via="esta corrida YA usa la palanca de acreditación (k=$K07, r=$SER07), así que la salida NO es repetirla: es medir en un host menos cargado, y si se repite es hallazgo con dueño — nunca subir el techo"
  case "$RES07" in
    pass) echo "  PASS  $nombre  máx(r) $MX07 <= techo en las $LISTA07"; PASS=$((PASS+1)) ;;
    fail) echo "  FAIL  $nombre  mín(r) $MN07 > techo en TODAS: es regresión, no ruido — el techo es OPERATIVO y no se sube, lo que baja es el coste del lector — $LISTA07"; FAIL=$((FAIL+1)) ;;
    *)    echo "  SKIP  $nombre  $MOTRES07: el instrumento no distingue el factor que vigila, y una medición inconclusa NO es una aprobación. Vía de acreditación: $via — ${LISTA07:-sin razones}" ;;
  esac
}

# ---------- EL CASO ----------
# MIDE, Y SI NO RESUELVE VUELVE A MEDIR; agotado el presupuesto NO SALE VERDE. Esto es lo que
# cambia en la vuelta 4 y no es una nota: hasta aquí una medición inconclusa emitía `SKIP`, el
# corredor lo contaba aparte y `hooks-en-linux` salía en VERDE — medido en la corrida `1b3760e`,
# donde el caso se abstuvo con recorrido [0,836× , 1,598×] y la puerta requerida dio `success`.
# Un `SKIP` no puede habilitar la fusión sin una medición válida posterior sobre ESE candidato.
NOM07="REQ-024 CA-07 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base"
if [ -z "$FILTRO" ] || printf '%s' "$NOM07" | grep -qi -- "$FILTRO"; then
  INT07=0; RES07=''; CIE07=reintentar
  while [ "$CIE07" = reintentar ]; do
    INT07=$((INT07 + 1))
    mide07
    if [ -z "${REPS07// /}" ]; then
      RES07=inconcluso; LISTA07=''; MOTRES07="${FALTA07:-no se pudo medir}: no llegó ninguna repetición del par intercalado"
    else
      resuelve07 $REPS07   # SIN comillas a propósito: una palabra por repetición
    fi
    CIE07="$(cierre07 "$RES07" "$INT07")"
    # El reintento se ANUNCIA: un guardián que mide tres veces en silencio y sólo enseña la
    # última esconde justo la variabilidad que existe para medir.
    [ "$CIE07" != reintentar ] || echo "  (reintento) $NOM07  el intento $INT07 de $INTENTOS07 no resolvió ($MOTRES07 · $MAQ07): una medición inconcluyente es acreditación PENDIENTE, así que se vuelve a medir en vez de aceptarla"
  done
  if [ "$CIE07" = emitir ]; then
    veredicto07 "$NOM07" si $REPS07
  else
    echo "  FAIL  $NOM07  NO SE PUDO ACREDITAR en $INTENTOS07 intentos ($MOTRES07). Esto NO afirma que haya regresión: afirma que esta puerta no pudo MEDIRLO, y una medición inconcluyente es ACREDITACIÓN PENDIENTE que no habilita la fusión — una puerta que no puede medir no deja pasar. Salida: acreditar a demanda con ARNES_COSTE_RUTA_CRITICA=1 sobre ESTE candidato, o medir en un host menos cargado; NUNCA subir el techo ni relajar la unanimidad — ${LISTA07:-sin razones} · $MAQ07"; FAIL=$((FAIL+1))
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
  nom07="REQ-024 CA-07 (ii) par discriminante POSITIVO: una regresión sintética de 1,28× —la magnitud de los rojos REALES de CI— da FAIL y no SKIP, y sin regresión ni forzador da PASS"
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
    echo "  PASS  $nom07  (con la regresión de 1,28×: $obsreg07· sin ella y sin forzador: $obslim07)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom07  con la regresión se esperaba <FAIL > y salió <$obsreg07>; sin ella se esperaba <PASS > y salió <$obslim07>"; FAIL=$((FAIL+1))
  fi
fi

# ---------- DEMOSTRACIÓN 5 · UNA MEDICIÓN INCONCLUYENTE ES ACREDITACIÓN PENDIENTE ----------
# Se ejerce sobre las funciones REALES (`resuelve07` y `cierre07`), no sobre copias. Y lleva su
# MITAD DISCORDANTE, que es lo que la convierte en acreditación y no en tautología: la MISMA
# entrada por el camino de PRESENTACIÓN sigue dando `SKIP` —lo que la puerta hacía hasta la
# vuelta 3, y lo que dejó `hooks-en-linux` en verde sobre `1b3760e` con el caso abstenido—. Sin
# esa mitad, un `sin-acreditar` no demostraría que lo cambia LA ESCALADA y no la entrada.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-07 (ii) una medición inconcluyente es acreditación PENDIENTE" | grep -qi -- "$FILTRO"; then
  nom07="REQ-024 CA-07 (ii) una medición inconcluyente es acreditación PENDIENTE: se reintenta, y agotado el presupuesto el caso NO sale verde"
  resuelve07 $DISP07
  obs07="$RES07/$(cierre07 "$RES07" 1)/$(cierre07 "$RES07" "$INTENTOS07")/$(cierre07 pass 1)/$(cierre07 fail 1)"
  esp07='inconcluso/reintentar/sin-acreditar/emitir/emitir'
  ant07="$(veredicto07 sonda-de-prueba si $DISP07 2>&1 | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p')"
  if [ "$obs07" = "$esp07" ] && [ "$ant07" = SKIP ]; then
    echo "  PASS  $nom07  ($obs07 — y la MISMA entrada por el camino de presentación sigue dando <$ant07>, que es exactamente lo que dejaba la puerta en verde)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom07  se esperaba <$esp07> y salió <$obs07>; la mitad discordante esperaba <SKIP> y salió <$ant07>"; FAIL=$((FAIL+1))
  fi
fi

rm -rf "$HER07" "$P07" "$ENT07"
