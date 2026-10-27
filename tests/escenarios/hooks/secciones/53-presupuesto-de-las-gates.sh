# Sección 53 del banco — 53-presupuesto-de-las-gates
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# Hotfix 1.36.3, REQ-037 (issue #63): el plazo propio de 30 s mide el ANÁLISIS y no las quality gates (CA-01); las
# gates tienen su presupuesto de 420 s con su motivo propio de deny (CA-02), y la gate es código no confiable (CA-03).
#   G1–G6 y A2  CA-04 y CA-01 · C, B, I1–I8  CA-05 y CA-03, controles que no se mueven · P1–P6  CA-03, sólo la
#   candidata · M  CA-07, el motivo del plazo por la cadena · PROC, RELOJ  CA-06, cada rama contra su techo.
# DOS ÁRBOLES por fila: la CANDIDATA (`$HOOKS_DIR`) y v1.36.2 (46ee7ca), por SHA con `mat53` (copia de `mat49`); sin
# ella, SKIP y motivo, nunca PASS. COPIAS DE PRUEBA («Convenciones» de REQ-037): `hooks/` con UNA constante de lib.sh
# reducida —el plazo en 2 o 1 s, el presupuesto en 5 o 30 s—; si la constante no está una sola vez, la fila sale FAIL
# (con v1.36.2 como candidata el presupuesto no existe, y eso es parte de su fail-before). Las corridas, en paralelo.
CASOS_ESPERADOS_SECCION=62
PISO_AUTONOMO_SECCION=108  # 14 preámbulo (líneas 1-14, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO53, mat53_reg y mat53, copia de mat49, líneas 15-38) + 70 bloque indivisible mayor (l53, j53, pe53, pw53, gj53 y fila53: el brazo, el juez, los proyectos y las filas, líneas 52-121)
seccion_nueva "--- 53 · el plazo propio mide el análisis; las quality gates tienen su presupuesto (REQ-037, hotfix 1.36.3) ---"
REPO53="${SEC_DIR%/}/../../../.."; MAT53_RUTAS='hooks'; MAT53_REG=''; MAT53_T0=0; MAT53_REF='-'
mat53_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT53_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT53_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT53_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT53_T0 )) procesos=$4 etiqueta=$MAT53_REF ref=$MAT53_REF archivos=$3"
}
# mat53 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat53() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT53_T0=${EPOCHREALTIME/./}; MAT53_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO53" ls-tree -r "$ref" -- $MAT53_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat53_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO53" archive "$ref" $MAT53_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat53_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO53" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat53_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat53_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat53_reg ok - "$n" 6
}
RV53="$RAIZ/rv1362-53-$BASHPID"; RV53_OK=no; RV53_MOT=''
if mat53 46ee7ca "$RV53"; then RV53_OK=si
else RV53_MOT="v1.36.2 (46ee7ca) no se materializó (${MAT53_REG#*motivo=})"; RV53_MOT="${RV53_MOT%% corrida=*})"; fi
v53() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
W53="$RAIZ/w53-$BASHPID"; mkdir -p "$W53"
# cop53 <hooks> <destino> <línea> <línea nueva> -> la copia de prueba en <destino>/hooks, o 1 si <línea> no está una vez.
cop53() {
  local t r
  [ -r "$1/lib.sh" ] || return 1
  t="$(<"$1/lib.sh")"; case "$t" in *$'\n'"$3"$'\n'*) ;; *) return 1 ;; esac
  r="${t/$'\n'"$3"$'\n'/$'\n'"$4"$'\n'}"; case "$r" in *$'\n'"$3"$'\n'*) return 1 ;; esac
  rm -rf "$2" && mkdir -p "$2" && cp -R "$1" "$2/hooks" && printf '%s\n' "$r" > "$2/hooks/lib.sh"
}
# l53 <id> <hooks> <proyecto> <timeout s> [eof] — el BRAZO: ejecuta guard.sh como lo lanza el cliente, desde el
# proyecto y bajo `timeout`; deja salida, código y duración en $W53/<id>.{out,rc,ms}. No juzga. Con `eof`, la salida
# estándar y la de error van a la MISMA tubería, leída por un `cat` acotado a 10 s: la duración es hasta su EOF.
l53() {
  local t0 o; t0=${EPOCHREALTIME/./}
  if [ "${5:-}" = eof ]; then
    o="$( (cd "$3" && CLAUDE_PROJECT_DIR="$3" timeout "$4" bash "$2/guard.sh" < "$3/in" 2>&1; printf '%s\n' "$?" > "$W53/$1.rc") | timeout 10 cat)"
  else
    o="$(cd "$3" && CLAUDE_PROJECT_DIR="$3" timeout "$4" bash "$2/guard.sh" < "$3/in" 2>>"$W53/$1.err")"; printf '%s\n' "$?" > "$W53/$1.rc"
  fi
  printf '%s' "$o" > "$W53/$1.out"; printf '%s\n' $(( (${EPOCHREALTIME/./} - t0) / 1000 )) > "$W53/$1.ms"
}
# j53 <nombre> <id> <esperado> <techo ms|-> — el JUEZ, sobre lo que dejó l53. <esperado>: allow, sin-decision (no
# respondió antes del timeout), plazo, presupuesto:<N> (el literal de CA-02 (b), sin «plazo propio» ni «60 s»),
# gate:<orden> (deny por el fallo de esa gate) o regla:<cita> (otro deny, con esa cita).
j53() {
  local nom="$1" id="$2" esp="$3" tope="$4" sal='' rc='' ms='' mot='' got n
  [ -r "$W53/$id.rc" ] && rc="$(<"$W53/$id.rc")"; [ -r "$W53/$id.ms" ] && ms="$(<"$W53/$id.ms")"; [ -r "$W53/$id.out" ] && sal="$(<"$W53/$id.out")"
  if [ -z "$rc" ] || [ -z "$ms" ]; then v53 FAIL "$nom  el brazo no dejó código ni duración: no se midió"; return 0; fi
  if [ "$rc" = 124 ]; then got=sin-decision
  elif [ "$rc" != 0 ]; then got="código $rc"
  elif [ -z "$sal" ]; then got=allow
  elif [[ "$sal" == *'"permissionDecision":"deny"'* ]]; then
    mot="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$sal" 2>/dev/null)"
    case "$mot" in
      *'el reloj que vigila el presupuesto de las quality gates termino antes de tiempo'*) got=reloj ;;
      *'las quality gates no terminaron dentro de su presupuesto de '*)
        n="${mot#*dentro de su presupuesto de }"; got="presupuesto:${n%% s*}"
        case "$mot" in *'plazo propio'*|*'60 s'*) got="presupuesto con «plazo propio» o «60 s» en el motivo" ;; esac ;;
      *'plazo propio'*) got=plazo ;;
      *'falló la quality gate `'*) n="${mot#*falló la quality gate \`}"; got="gate:${n%%\`*}" ;;
      *) got="deny: ${mot:0:160}"; [[ "$esp" != regla:* || "$mot" != *"${esp#regla:}"* ]] || got="$esp" ;;
    esac
  else got="otra salida: ${sal:0:160}"; fi
  if [ "$got" != "$esp" ]; then v53 FAIL "$nom  esperado=$esp got=$got (rc $rc, $ms ms)"
  elif [ "$tope" != - ] && [ "$ms" -gt "$tope" ]; then v53 FAIL "$nom  $got, pero en $ms ms: por encima del techo de $tope ms"
  else v53 PASS "$nom  ($got, $ms ms)"; fi
}
# pe53 <dir> <gates JSON> [<QA:>] -> el CIERRE LEGÍTIMO de REQ-037 («Convenciones»; `repro.sh` del issue): un Edit de
# `Estado: en-revisión` a `completado` por qa-tester, sobre REQ-001 con todo en orden, en <dir>/in.
pe53() {
  rm -rf "$1"; mkdir -p "$1/requirements" "$1/.arnes" "$1/docs" || return 1
  jq -cn --argjson g "$2" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$1/.arnes/config.json" || return 1
  printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"; printf 'n\n' > "$1/docs/notas.md"
  printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: %s\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' "${3:-aprobado}" > "$1/requirements/REQ-001.md"
  jq -cn --arg fp "$1/requirements/REQ-001.md" --arg c "$1" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$1/in"
}
# pw53 <dir> <gates JSON> -> el caso que agota el plazo por el análisis (`62-` de cand-1.36.0/sec115-118): un Write de
# la coordinadora de 393 212 bytes con la cabecera pendiente (≈ 4 s de análisis en Linux/WSL2).
pw53() {
  pe53 "$1" "$2" || return 1
  printf "$CAB53" en-revisión > "$1/requirements/REQ-950.md"
  jq -Rs --arg fp "$1/requirements/REQ-950.md" --arg c "$1" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$CW53" > "$1/in"
}
gj53() { if [ "$1" = '[]' ]; then printf '[]'; else jq -cRn '[inputs]' <<< "$1"; fi; }   # <gates, una por línea, o []>
# fila53 <id> <nombre> <E|W|Q> <gates> <hooks C|!motivo> <esperado C> <techo C ms|-> <hooks B|-|!motivo> [<esperado B>]
# [<timeout B s>] — prepara y LANZA en segundo plano las dos corridas de la fila (Q: el cierre con `QA: pendiente`);
# el juicio va después, en orden, con `R53`. Un timeout de 60 s, salvo el de B que diga la fila.
R53=()
fila53() {
  local id="$1" g pc="$W53/p-$1-c" pb="$W53/p-$1-b" ok=si
  g="$(gj53 "$4")"
  case "$3" in W) pw53 "$pc" "$g" && pw53 "$pb" "$g" || ok=no ;; Q) pe53 "$pc" "$g" pendiente && pe53 "$pb" "$g" pendiente || ok=no ;;
               *) pe53 "$pc" "$g" && pe53 "$pb" "$g" || ok=no ;; esac
  [ "$ok" = si ] || { v53 FAIL "REQ-037 $2  no se pudo preparar el proyecto: no se midió"; return 0; }
  json_no_vacio "REQ-037 $2" "$(<"$pc/in")" || { FAIL=$((FAIL + 1)); return 0; }
  R53+=("$id|$2|$5|$6|$7|$8|${9:-}")
  [[ "$5" == '!'* ]] || l53 "$id-c" "$5" "$pc" 60 &
  [ "$8" = - ] || [[ "$8" == '!'* ]] || [ "$RV53_OK" != si ] || l53 "$id-b" "$8" "$pb" "${10:-60}" &
}
# Los árboles: la candidata, v1.36.2 y las copias de prueba (una constante reducida; `!motivo` si no se pudo).
C53="$HOOKS_DIR"; B53="$RV53/hooks"; CAB53='# REQ-950\nEstado: %s\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\nRigor: critico\n'
copia53() {   # <var> <hooks> <nombre> <línea> <línea nueva>
  if cop53 "$2" "$W53/$3" "$4" "$5"; then printf -v "$1" '%s' "$W53/$3/hooks"; else printf -v "$1" '%s' "!la copia de prueba no se pudo hacer: «$4» no está una sola vez en lib.sh"; fi
}
copia53 C2 "$C53" c2 'ARNES_PLAZO_S=30' 'ARNES_PLAZO_S=2'; copia53 C1 "$C53" c1 'ARNES_PLAZO_S=30' 'ARNES_PLAZO_S=1'
copia53 CN5 "$C53" cn5 'ARNES_GATES_PRESUPUESTO_S=420' 'ARNES_GATES_PRESUPUESTO_S=5'
copia53 CN30 "$C53" cn30 'ARNES_GATES_PRESUPUESTO_S=420' 'ARNES_GATES_PRESUPUESTO_S=30'
B2='-'; B1='-'
if [ "$RV53_OK" = si ]; then copia53 B2 "$B53" b2 'ARNES_PLAZO_S=30' 'ARNES_PLAZO_S=2'; copia53 B1 "$B53" b1 'ARNES_PLAZO_S=30' 'ARNES_PLAZO_S=1'; fi
# El contenido del Write de pw53: 393 212 bytes exactos (cabecera, `## Texto` y líneas de 80 bytes, con relleno final).
CW53="$W53/cont-w"; L53="$(printf '%s' 'relleno de cuerpo relleno de cuerpo relleno de cuerpo relleno de cuerpo relleno')"$'\n'
{ printf "$CAB53" completado; printf '\n## Texto\n'; } > "$CW53"; q53="$(<"$CW53")"$'\n'; q53="$(LC_ALL=C; printf '%s' "${#q53}")"
b53=''; n53=$(( (393212 - q53) / 80 )); s53="$L53"
while [ "$n53" -gt 0 ]; do [ $((n53 & 1)) -eq 0 ] || b53+="$s53"; s53+="$s53"; n53=$((n53 >> 1)); done
f53=$(( 393212 - q53 - (393212 - q53) / 80 * 80 )); printf '%s' "$b53" >> "$CW53"
[ "$f53" -le 0 ] || { s53=''; while [ "${#s53}" -lt $((f53 - 1)) ]; do s53+=z; done; printf '%s\n' "$s53" >> "$CW53"; }

# --- Las filas: CA-04 (G1–G6), CA-01 (A2, B), CA-05 (C) y CA-03 (I1–I7) en los dos árboles; P1–P5 en la candidata ---
I1G53='for f in 0 3 4 5 6 7 8 9 10 11 12 255; do { echo 0 >&$f; } 2>/dev/null; done; false'
I3G53='printf %s "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\"}}"; false'
P3G53='for f in 0 3 4 5 6 7 8 9 10 11 12 255; do { echo 0 >&$f; } 2>/dev/null; done; sleep 1000'
P4G53='exec bash -c '\''exec 3< <(exec sleep 300); for ((i = 0; i < 14000; i++)); do { read -r -u 3; } & disown; done; echo "$i" > listo53; read -r -u 3'\'''
P5G53='read -r _ _ _ _ p _ < /proc/$BASHPID/stat && echo "$p" > pg53; sleep 1000 & { while :; do sleep 1; done; } & true'
P6G53='read -r _ _ _ o _ < /proc/$BASHPID/stat; read -r _ _ _ h _ < /proc/$o/stat; pkill -P "$h" -x sleep; sleep 1000'
fila53 G1 'G1 cierre legítimo con una gate verde `sleep 35` (la reproducción del issue)' E 'sleep 35' "$C53" allow 40000 "$B53" plazo
fila53 A2 'CA-01 dos gates verdes `sleep 20` (40 s en total, menos que N)' E $'sleep 20\nsleep 20' "$C53" allow 50000 "$B53" plazo
fila53 G2 'G2 copia con el plazo en 2 s, gate verde `sleep 3`' E 'sleep 3' "$C2" allow 10000 "$B2" plazo
fila53 G3 'G3 copia con N en 5 s, gate colgada `sleep 1000`' E 'sleep 1000' "$CN5" presupuesto:5 15000 "$B53" sin-decision 15
fila53 G4 'G4 copia con N en 5 s, dos gates verdes `sleep 3` en serie' E $'sleep 3\nsleep 3' "$CN5" presupuesto:5 15000 "$B53" allow
fila53 G5 'G5 control: gate roja `false`' E false "$C53" gate:false - "$B53" gate:false
fila53 G6 'G6 control: gate verde `sleep 35` y detrás roja `false`' E $'sleep 35\nfalse' "$C53" gate:false - "$B53" gate:false
fila53 C1 'C control: gate verde corta `true`' E true "$C53" allow - "$B53" allow
fila53 C2 'C control y CA-02 (g): `quality_gates: []`' E '[]' "$C53" allow - "$B53" allow
fila53 C3 'C control: cierre ilegítimo (`QA: pendiente`) con las gates en verde' Q true "$C53" 'regla:QA: aprobado' - "$B53" 'regla:QA: aprobado'
fila53 B1 'CA-01 borde: copia con el plazo en 1 s, el Write de 393 212 bytes, sin gates' W '[]' "$C1" plazo - "$B1" plazo
fila53 B2 'CA-01 borde: copia con el plazo en 1 s, el Write de 393 212 bytes, con la gate `true`' W true "$C1" plazo - "$B1" plazo
fila53 I1 'I1 roja que escribe 0 en todo descriptor heredado y sale con false' E "$I1G53" "$C53" "gate:$I1G53" - "$B53" "gate:$I1G53"
fila53 I2 'I2 roja con una trampa EXIT que escribe 0 (el vector de QA-007-15)' E 'trap "echo 0" EXIT; false' "$C53" 'gate:trap "echo 0" EXIT; false' - "$B53" 'gate:trap "echo 0" EXIT; false'
fila53 I2b "I2b la trampa EXIT que hace \`exit 0\` deja el código de salida en 0: verde, igual en los dos (no es movimiento)" E "trap 'exit 0' EXIT; false" "$C53" allow - "$B53" allow
fila53 I3 'I3 roja que imprime un allow en su salida' E "$I3G53" "$C53" "gate:$I3G53" - "$B53" "gate:$I3G53"
fila53 I4 'I4 verde `exec true`, sin deny falso' E 'exec true' "$C53" allow - "$B53" allow
fila53 I5 'I5 roja `sleep 3; false`: su motivo, ni el del plazo ni allow' E 'sleep 3; false' "$C53" 'gate:sleep 3; false' - "$B53" 'gate:sleep 3; false'
fila53 I6 'I6 verde lenta `sleep 3` y detrás roja `false`' E $'sleep 3\nfalse' "$C53" gate:false - "$B53" gate:false
for x53 in 124 137 143; do
  fila53 "I7-$x53" "I7 y CA-02 (d) roja que sale ella misma con $x53 dentro del presupuesto" E "exit $x53" "$C53" "gate:exit $x53" - "$B53" "gate:exit $x53"
done
fila53 I8 'I8 roja `exec setsid false` (con la gate de jefa de grupo, `setsid` se bifurcaba y salía con 0)' E 'exec setsid false' "$C53" 'gate:exec setsid false' - "$B53" 'gate:exec setsid false'
fila53 P1 'P1 copia con N en 5 s: agotada que sale con 0 al recibir TERM' E "trap 'exit 0' TERM; sleep 1000" "$CN5" presupuesto:5 15000 -
fila53 P2 'P2 copia con N en 5 s: agotada que ignora TERM' E "trap '' TERM; sleep 1000" "$CN5" presupuesto:5 15000 -
fila53 P3 'P3 copia con N en 5 s: agotada que escribe 0 en todo descriptor heredado antes de colgarse' E "$P3G53" "$CN5" presupuesto:5 15000 -
fila53 P5 'P5 verde que deja vivos `sleep 1000` y un bucle de bash' E "$P5G53" "$C53" allow 5000 -
# P6: la gate mata el reloj del hook (el `sleep` hijo del hook) y se cuelga: el hook no le cree, deniega con el
# motivo del reloj muerto —no el del presupuesto, que no se agotó (CA-02 (d))—; en la copia de 5 s, por si no lo mata.
NP6_53='REQ-037 P6 copia con N en 5 s: la gate mata el reloj del hook y se cuelga'; P6MOT53=''
command -v pkill >/dev/null 2>&1 && [ -r "/proc/$BASHPID/stat" ] || P6MOT53='sin `pkill` o sin /proc: la gate no puede encontrar el reloj del hook'
[ -n "$P6MOT53" ] || fila53 P6 "${NP6_53#REQ-037 }" E "$P6G53" "$CN5" reloj 15000 -
# P4: 14 000 descendientes de un bash pequeño, sin tabla de trabajos (`disown`), miden ≈ 2,9 GB y ≈ 7,7 s de
# bifurcaciones en Linux/WSL2 (con la tabla de trabajos creciendo, cada hijo copiaba más: 1,2 MB por hijo a 8 000 y
# sin terminar de crearse en 60 s a 14 000). Donde no caben, SKIP con motivo. El techo de 40 s es N + 10 s: el corte
# de `cd63066` tardaba 23,8 s con 9 000 (QA-007-17), y éste es una señal al grupo.
P4MOT53=''
case "${OSTYPE:-}" in linux*) ;; *) P4MOT53="no es Linux (OSTYPE=${OSTYPE:-?}): 14 000 bifurcaciones no caben en el reloj del banco" ;; esac
u53="$(ulimit -u)"; [ -n "$P4MOT53" ] || [ "$u53" = unlimited ] || [ "$u53" -ge 30000 ] 2>/dev/null || P4MOT53="ulimit -u = $u53, menos de 30 000"
m53k=0; [ -n "$P4MOT53" ] || while read -r k53 v53k _; do [ "$k53" != MemAvailable: ] || m53k="$v53k"; done 2>/dev/null < /proc/meminfo
[ -n "$P4MOT53" ] || [ "$m53k" -ge 6291456 ] || P4MOT53="MemAvailable = $m53k kB, menos de 6 GiB"
pm53=0; [ -n "$P4MOT53" ] || read -r pm53 2>/dev/null < /proc/sys/kernel/pid_max; [ -n "$P4MOT53" ] || [ "$pm53" -ge 65536 ] || P4MOT53="pid_max = $pm53, menos de 65 536"
NP4_53='REQ-037 P4 copia con N en 30 s: agotada con 14 000 descendientes, corte lineal'
[ -n "$P4MOT53" ] || fila53 P4 "${NP4_53#REQ-037 }" E "$P4G53" "$CN30" presupuesto:30 40000 -
wait
# P5 tiene que haber dejado vivo lo que retendría la salida (si no, no midió), y P4 haber llegado a sus 14 000
# descendientes antes del corte (si no, tampoco): se miran ANTES de juzgarlas, y lo que P5 dejó vivo se mata después.
pg53="$(cat "$W53/p-P5-c/pg53" 2>/dev/null)"; P5VIVO53=no; [ -z "$pg53" ] || ! kill -0 -- "-$pg53" 2>/dev/null || P5VIVO53=si
for r53 in "${R53[@]}"; do
  IFS='|' read -r id53 nom53 hc53 ec53 tc53 hb53 eb53 <<< "$r53"; nom53="REQ-037 $nom53"
  if [ "$id53" = P4 ] && [[ "$hc53" != '!'* ]] && [ "$(cat "$W53/p-P4-c/listo53" 2>/dev/null)" != 14000 ]; then
    v53 SKIP "$nom53 candidata  la gate no llegó a 14 000 descendientes antes del corte: no midió el tamaño (listo53=<$(cat "$W53/p-P4-c/listo53" 2>/dev/null)>)"; continue
  fi
  if [ "$id53" = P5 ] && [[ "$hc53" != '!'* ]] && [ "$P5VIVO53" != si ]; then v53 SKIP "$nom53 candidata  lo que la gate dejó vivo no seguía vivo al leer el EOF: no midió la retención"; continue; fi
  if [[ "$hc53" == '!'* ]]; then v53 FAIL "$nom53 candidata  ${hc53#!}"; else j53 "$nom53 candidata" "$id53-c" "$ec53" "$tc53"; fi
  if [ "$hb53" = - ] && [ -z "$eb53" ]; then :
  elif [ "$RV53_OK" != si ]; then v53 SKIP "$nom53 v1.36.2  $RV53_MOT"
  elif [[ "$hb53" == '!'* ]]; then v53 FAIL "$nom53 v1.36.2  ${hb53#!}"
  else j53 "$nom53 v1.36.2" "$id53-b" "$eb53" -; fi
done
[ -z "$P4MOT53" ] || v53 SKIP "$NP4_53 candidata  $P4MOT53"
[ -z "$P6MOT53" ] || v53 SKIP "$NP6_53 candidata  $P6MOT53"
[ "$P5VIVO53" != si ] || kill -KILL -- "-$pg53" 2>/dev/null
# --- M: CA-07, el motivo del plazo propio por la cadena (la librería sola, con el reloj vencido) ---------------------
for t53 in C B; do
  h53="$C53"; nom53='REQ-037 M CA-07 el motivo del plazo propio dice «30 s de analisis» y no cita «60 s» candidata'
  [ "$t53" = C ] || { h53="$B53"; nom53='REQ-037 M CA-07 el motivo del plazo propio de 1.36.2 cita «60 s» (el movimiento de CA-07) v1.36.2'; }
  if [ "$t53" = B ] && [ "$RV53_OK" != si ]; then v53 SKIP "$nom53  $RV53_MOT"; continue; fi
  m53="$( ( set -uo pipefail; . "$h53/lib.sh" >/dev/null 2>&1 || exit 97; ARNES_EN_HOOK=1; SECONDS=31; arnes_plazo ) 2>/dev/null )"
  m53="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$m53" 2>/dev/null)"
  if [ "$t53" = C ] && [[ "$m53" == *'plazo propio (30 s de analisis'* && "$m53" != *'60 s'* ]]; then v53 PASS "$nom53"
  elif [ "$t53" = B ] && [[ "$m53" == *'plazo propio'* && "$m53" == *'60 s'* ]]; then v53 PASS "$nom53"
  else v53 FAIL "$nom53  <${m53:0:220}>"; fi
done

# --- PROC y RELOJ: CA-06 — cada rama de la tabla de coste, contra SU techo, en la misma corrida frente a v1.36.2 -----
# Técnica de REQ-007 CA-59 (sonda de procesos) y mínimo de 5 corridas. Techos: camino común y `quality_gates: []`, 0
# procesos (de contrato) y 1,25×; 3 gates verdes `true`, 2 por gate (6) y 1,5× (operativos). Bajo el suelo de 50 ms en
# v1.36.2, SKIP con motivo y la cifra, nunca PASS.
pe53 "$W53/k-comun" '["true"]'; pe53 "$W53/k-vacio" '[]'; pe53 "$W53/k-tres" '["true","true","true"]'
jq -cn --arg c "$W53/k-comun" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"ls -la"}}' > "$W53/k-ls.json"
jq -cn --arg c "$W53/k-comun" --arg f "$W53/k-comun/docs/notas.md" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$f,old_string:"n",new_string:"m"}}' > "$W53/k-edit.json"
# <procesos añadidos>|<reloj ×100>|<proyecto>|<entrada>|<rama>
ramas53=("0|125|k-comun|k-ls.json|camino común, ls -la" "0|125|k-comun|k-edit.json|camino común, Edit de un archivo no REQ"
         "0|125|k-vacio|k-vacio/in|cierre con quality_gates: []" "6|150|k-tres|k-tres/in|cierre con 3 gates verdes true")
for r53 in "${ramas53[@]}"; do
  IFS='|' read -r x53 t53 p53 f53 rama53 <<< "$r53"; p53="$W53/$p53"; f53="$W53/$f53"
  nomp53="REQ-037 PROC CA-06 $rama53: procesos añadidos frente a v1.36.2, techo $x53"
  nomr53="REQ-037 RELOJ CA-06 $rama53 (operativo): mínimo de 5 frente a v1.36.2, techo ${t53:0:1},${t53:1}×"
  if [ "$RV53_OK" != si ]; then v53 SKIP "$nomp53  $RV53_MOT"; v53 SKIP "$nomr53  $RV53_MOT"; continue; fi
  if [ ! -s "$f53" ]; then v53 FAIL "$nomp53  la entrada salió vacía: no se midió"; v53 FAIL "$nomr53  la entrada salió vacía: no se midió"; continue; fi
  pr53=''; rl53=''; nm53=''
  for h53 in "$C53" "$B53"; do
    s53="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta "53-procesos" \
      --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git readlink realpath cygpath find stat rm sleep' \
      --sujeto "cd '$p53' && CLAUDE_PROJECT_DIR='$p53' bash '$h53/guard.sh' < '$f53'" 2>/dev/null)"
    if sonda_lee "$s53" && [ "${SONDA[estado]}" = ok ]; then pr53+="${SONDA[cuenta]:-x} "; else pr53+="x "; nm53+=" (${SONDA_MOTIVO:-${SONDA[motivo]:-?}})"; fi
    mn53=''
    for _ in 1 2 3 4 5; do
      t053=${EPOCHREALTIME/./}; (cd "$p53" && CLAUDE_PROJECT_DIR="$p53" bash "$h53/guard.sh" < "$f53" >/dev/null 2>&1); t153=$(( ${EPOCHREALTIME/./} - t053 ))
      [ -n "$mn53" ] && [ "$mn53" -le "$t153" ] || mn53=$t153
    done
    rl53+="$mn53 "
  done
  read -r pc53 pb53 <<< "$pr53"; read -r rc53 rb53 <<< "$rl53"
  if [ -n "$nm53" ]; then v53 SKIP "$nomp53  la sonda no midió$nm53"
  elif [ "$pc53" -le $(( pb53 + x53 )) ]; then v53 PASS "$nomp53  (candidata $pc53 / v1.36.2 $pb53)"
  else v53 FAIL "$nomp53  $pc53 > $pb53 + $x53"; fi
  cif53="candidata/v1.36.2: $((rc53 / 1000))/$((rb53 / 1000)) ms, $(( rc53 * 1000 / rb53 ))/1000 ×"
  if [ "$rb53" -lt 50000 ]; then v53 SKIP "$nomr53  bajo el suelo de 50 ms en v1.36.2; no acredita ($cif53)"
  elif [ $(( rc53 * 100 )) -le $(( rb53 * t53 )) ]; then v53 PASS "$nomr53  ($cif53)"
  else v53 FAIL "$nomr53  $rc53 us > ${t53:0:1},${t53:1} × $rb53 us ($cif53)"; fi
done
rm -rf "$W53" "$RV53"
