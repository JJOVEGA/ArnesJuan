# Sección 53 del banco — 53-presupuesto-de-las-gates (el nombre es de la versión anterior; el número lo fija CA-13)
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# Hotfix 1.36.3, REQ-037 reescrito (issue #63, F-137-24, ADR-019): las quality gates NO corren en el hook; las corre
# `tools/arnes-gates.sh` y deja un veredicto ligado al hash del árbol, y la puerta sólo lo comprueba.
#   G1 y C*  CA-08 (b), fail-before y controles · M2  el movimiento M-037-2 · W  CA-05, fail-before por forma
#   A*  CA-01 · L*  CA-03 · H*  CA-02, la herramienta · I1–I8, E1, T1  CA-06 sobre la herramienta · MK  CA-03
#   D  CA-08 (a), un documento por respuesta · K*, PROC, RELOJ  CA-10, coste · O1–O3  gates en forma de objeto.
# DOS ÁRBOLES donde la fila lo pide: la CANDIDATA (`$HOOKS_DIR`) y v1.36.2 (46ee7ca), por SHA con `mat53` (copia de
# `mat49`); sin ella, SKIP y motivo, nunca PASS. Las corridas, en paralelo; el juicio, después y en orden.
CASOS_ESPERADOS_SECCION=102
PISO_AUTONOMO_SECCION=136  # 14 preámbulo (líneas 1-14, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO53, mat53_reg y mat53, copia de mat49, líneas 15-38) + 98 bloque indivisible mayor (l53, j53, pe53, t53, r53, prep53 y caso53: el brazo, el juez, los proyectos, la herramienta y las filas, líneas 44-141)
seccion_nueva "--- 53 · las quality gates corren fuera del hook; la puerta comprueba un veredicto con el hash del árbol (REQ-037, hotfix 1.36.3) ---"
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
W53="$RAIZ/w53-$BASHPID"; mkdir -p "$W53"; C53="$HOOKS_DIR"; B53="$RV53/hooks"
TOOL53="$C53/../tools/arnes-gates.sh"; [ -f "$TOOL53" ] || TOOL53="$REPO53/tools/arnes-gates.sh"
# l53 <id> <hooks> <proyecto> <timeout s> [entrada] — el BRAZO: guard.sh como lo lanza el cliente, desde el proyecto y bajo
# `timeout`; deja salida, código y duración en $W53/<id>.{out,rc,ms}. No juzga.
l53() {
  local t0 o; t0=${EPOCHREALTIME/./}
  o="$(cd "$3" && CLAUDE_PROJECT_DIR="$3" timeout "$4" bash "$2/guard.sh" < "${5:-$3/in}" 2>>"$W53/$1.err")"; printf '%s\n' "$?" > "$W53/$1.rc"
  printf '%s' "$o" > "$W53/$1.out"; printf '%s\n' $(( (${EPOCHREALTIME/./} - t0) / 1000 )) > "$W53/$1.ms"
}
# j53 <nombre> <id> <esperado> <techo ms|-> — el JUEZ. <esperado>: allow, sin-decision, plazo, ausente, ilegible, lista,
# caducado, nomedible, registro (CA-05), roja:<orden> (la puerta, por el registro), gate:<orden> (v1.36.2, que la
# ejecutaba) o regla:<cita>. Más de un documento en la respuesta es «dobles», nunca lo esperado.
j53() {
  local nom="$1" id="$2" esp="$3" tope="$4" sal='' rc='' ms='' mot='' got n d=0 x
  [ -r "$W53/$id.rc" ] && rc="$(<"$W53/$id.rc")"; [ -r "$W53/$id.ms" ] && ms="$(<"$W53/$id.ms")"; [ -r "$W53/$id.out" ] && sal="$(<"$W53/$id.out")"
  if [ -z "$rc" ] || [ -z "$ms" ]; then v53 FAIL "$nom  el brazo no dejó código ni duración: no se midió"; return 0; fi
  x="$sal"; while [[ "$x" == *'"permissionDecision"'* ]]; do d=$((d + 1)); x="${x#*'"permissionDecision"'}"; done
  if [ "$rc" = 124 ]; then got=sin-decision
  elif [ "$rc" != 0 ]; then got="código $rc"
  elif [ -z "$sal" ]; then got=allow
  elif [ "$d" -gt 1 ]; then got="dobles ($d documentos)"
  elif [[ "$sal" == *'"permissionDecision":"deny"'* ]]; then
    mot="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$sal" 2>/dev/null)"
    case "$mot" in
      *'no hay veredicto de ellas'*) got=ausente ;;
      *'no se puede leer como un veredicto completo'*) got=ilegible ;;
      *'es de otra lista de gates'*) got=lista ;;
      *'en el veredicto registrado'*) n="${mot#*la quality gate \`}"; got="roja:${n%%\`*}" ;;
      *'no es del arbol actual'*) got=caducado ;;
      *'no se puede medir el arbol del proyecto'*) got=nomedible ;;
      *'el registro del veredicto de las quality gates'*) got=registro ;;
      *'plazo propio'*) got=plazo ;;
      *'falló la quality gate `'*) n="${mot#*falló la quality gate \`}"; got="gate:${n%%\`*}" ;;
      *) got="deny: ${mot:0:160}"; [[ "$esp" != regla:* || "$mot" != *"${esp#regla:}"* ]] || got="$esp" ;;
    esac
  else got="otra salida: ${sal:0:160}"; fi
  if [ "$got" != "$esp" ]; then v53 FAIL "$nom  esperado=$esp got=$got (rc $rc, $ms ms)"
  elif [ "$tope" != - ] && [ "$ms" -gt "$tope" ]; then v53 FAIL "$nom  $got, pero en $ms ms: por encima del techo de $tope ms"
  else v53 PASS "$nom  ($got, $ms ms)"; fi
}
# pe53 <dir> <gates JSON> [<QA:>] -> el CIERRE LEGÍTIMO de REQ-037 («Convenciones»; `repro.sh` del issue), con git y su
# commit inicial: un Edit de `Estado: en-revisión` a `completado` por qa-tester, sobre REQ-001 con todo en orden.
pe53() {
  rm -rf "$1"; mkdir -p "$1/requirements" "$1/.arnes" "$1/docs" "$1/src" || return 1
  jq -cn --argjson g "$2" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$1/.arnes/config.json" || return 1
  printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"; printf 'n\n' > "$1/docs/notas.md"; printf 'x\n' > "$1/src/a.txt"
  printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: %s\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' "${3:-aprobado}" > "$1/requirements/REQ-001.md"
  ( cd "$1" && git init -q && git add -A && git -c user.email=b@b -c user.name=b commit -qm base ) >/dev/null 2>&1 || return 1
  jq -cn --arg fp "$1/requirements/REQ-001.md" --arg c "$1" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$1/in"
}
# t53 <dir> — LA HERRAMIENTA, fuera del hook, como la lanza QA; código, salida y duración en <dir>.tool.{rc,out,ms}.
t53() {
  local t0=${EPOCHREALTIME/./}
  ( cd "$1" && bash "$TOOL53" --quien banco --proyecto "$1" ) > "$1.tool.out" 2>&1; printf '%s\n' "$?" > "$1.tool.rc"
  printf '%s\n' $(( (${EPOCHREALTIME/./} - t0) / 1000 )) > "$1.tool.ms"
}
# r53 <dir> <expresión jq> — reescribe el registro de la prueba (lo hace el banco, no un agente: no pasa por el hook).
r53() { local t; t="$(jq -c "$2" "$1/.arnes/gates-veredicto.json" 2>/dev/null)" && printf '%s\n' "$t" > "$1/.arnes/gates-veredicto.json"; }
# prep53 <qué> <dir> — lo que pasa entre preparar el proyecto y el cierre: `-` nada; `gi` un .gitignore, la
# herramienta y un archivo ignorado; `v` la herramienta; el resto, la herramienta y después ese cambio.
prep53() {
  local p="$2"
  case "$1" in
    -) return 0 ;;
    gi) printf 'tmp53/\n' > "$p/.gitignore"; t53 "$p"; mkdir -p "$p/tmp53"; echo z > "$p/tmp53/x"; return 0 ;;
  esac
  t53 "$p"
  case "$1" in
    src) echo cambio >> "$p/src/a.txt" ;;
    borra) rm -f "$p/src/a.txt" ;;
    nuevo) echo nuevo > "$p/src/b.txt" ;;
    modo) chmod +x "$p/src/a.txt" ;;
    req) echo 'Nota tras la firma.' >> "$p/requirements/REQ-001.md" ;;
    qa) mkdir -p "$p/docs/qa" && echo firma > "$p/docs/qa/REQ-001.md" ;;
    commit) ( cd "$p" && git add -A && git -c user.email=b@b -c user.name=b commit -qm firma ) >/dev/null 2>&1 ;;
    lista) jq -c '.quality_gates += ["true"]' "$p/.arnes/config.json" > "$p.m" && mv "$p.m" "$p/.arnes/config.json" ;;
    sinjson) printf '{' > "$p/.arnes/gates-veredicto.json" ;;
    texto0) r53 "$p" '.gates[0].rc = "0"' ;;
    rc256) r53 "$p" '.gates[0].rc = 256' ;;
    extra) r53 "$p" '. + {extra: 1}' ;;
    blanco) r53 "$p" '.quien = " "' ;;
    nulo) r53 "$p" '.gates[0].rc = null' ;;
    singit) rm -rf "$p/.git" ;;
    simb) mv "$p/.arnes/gates-veredicto.json" "$p.verde" && ln -s "$p.verde" "$p/.arnes/gates-veredicto.json" ;;
    duro) ln "$p/.arnes/gates-veredicto.json" "$p.otro" ;;
  esac
  return 0
}
# caso53 <id> <nombre> <gates, una por línea, o [], o json:<array del manifiesto>> <prep C> <esperado C> <techo C ms|->
# <prep B> [<esperado B>] [QA] — prepara y LANZA en segundo plano las dos corridas; el juicio va después, con `R53`. B es
# v1.36.2, que ignora el registro y ejecuta las gates. Timeout de 60 s.
R53=()
caso53() {
  local g; case "$3" in '[]') g='[]' ;; json:*) g="${3#json:}" ;; *) g="$(jq -cRn '[inputs]' <<< "$3")" ;; esac
  R53+=("$1|$2|$5|$6|${8:-}")
  { pe53 "$W53/p-$1-c" "$g" "${9:-}" && prep53 "$4" "$W53/p-$1-c" && l53 "$1-c" "$C53" "$W53/p-$1-c" 60; } &
  if [ -n "${8:-}" ] && [ "$RV53_OK" = si ]; then
    { pe53 "$W53/p-$1-b" "$g" "${9:-}" && prep53 "$7" "$W53/p-$1-b" && l53 "$1-b" "$B53" "$W53/p-$1-b" 60; } &
  fi
}

# --- CA-08 (b): #63 y los controles que no se mueven; M-037-2 ------------------------------------------------------
caso53 G1 'G1 #63: gate verde `sleep 35`, veredicto de la herramienta fuera del hook (≤ 3 s; v1.36.2: el plazo)' 'sleep 35' v allow 3000 - plazo
caso53 C1 'C control: gate roja `false` con su veredicto rojo' false v roja:false - - gate:false
caso53 C2 'C control: gate verde `true` con su veredicto' true v allow - - allow
caso53 C3 'C control: `quality_gates: []`' '[]' - allow - - allow
caso53 C4 'C control: cierre ilegítimo (`QA: pendiente`) con el veredicto verde' true v 'regla:QA: aprobado' - v 'regla:QA: aprobado' pendiente
caso53 M2 'M-037-2 gates verdes sin veredicto (cambio de compatibilidad)' true - ausente - - allow
# --- CA-01: lo que cambia el hash y lo que no ------------------------------------------------------------------------
caso53 A1 'A1 CA-01 cambia un archivo comiteado tras las gates' true src caducado - -
caso53 A2 'A2 CA-01 se borra un archivo tras las gates' true borra caducado - -
caso53 A3 'A3 CA-01 aparece un archivo nuevo no ignorado' true nuevo caducado - -
caso53 A4 'A4 CA-01 cambia sólo el modo de un archivo' true modo caducado - -
caso53 A5 'A5 CA-01 cambia un REQ (excluido: la firma de QA)' true req allow - -
caso53 A6 'A6 CA-01 aparece un archivo en docs/qa/ (excluido)' true qa allow - -
caso53 A7 'A7 CA-01 cambia un archivo ignorado' true gi allow - -
caso53 A8 'A8 CA-01 se comitea todo tras las gates (el contenido no cambia)' true commit allow - -
caso53 A9 'A9 CA-01 sin git (el hash no se puede calcular): deniega' true singit nomedible - -
# --- CA-03: cada condición, con su motivo -----------------------------------------------------------------------------
caso53 L1 'L1 CA-03 registro que no es JSON' true sinjson ilegible - -
caso53 L2 'L2 CA-03 un `0` escrito como texto' true texto0 ilegible - -
caso53 L3 'L3 CA-03 un código fuera de rango (256)' true rc256 ilegible - -
caso53 L4 'L4 CA-03 un campo de más' true extra ilegible - -
caso53 L5 'L5 CA-03 `quien` en blanco' true blanco ilegible - -
caso53 L6 'L6 CA-03 una gate añadida al manifiesto después' true lista lista - -
caso53 L7 'L7 CA-03 una gate sin código (no corrió) cuenta como no verde' true nulo roja:true - -
# CA-03 (a), QA-037-11: un registro verde que es un enlace simbólico, o un enlace duro de más, es ilegible (en 42a320c, allow).
caso53 L8 'L8 CA-03 (a) el registro verde es un enlace simbólico a otro archivo' true simb ilegible - -
caso53 L9 'L9 CA-03 (a) el registro verde tiene un segundo enlace duro' true duro ilegible - -
# CA-08 (b), QA-037-13: gates en forma de objeto {nombre, comando}, por la herramienta y por la puerta (la misma expresión).
caso53 O1 'O1 gates en forma de objeto, verdes, con su veredicto' 'json:[{"nombre":"Verde","comando":"true"}]' v allow - -
caso53 O2 'O2 gates en forma de objeto, roja, con su veredicto' 'json:[{"nombre":"Roja","comando":"false"}]' v roja:false - -
caso53 O3 'O3 gates mezcla de objeto y cadena, verdes, con su veredicto' 'json:["true",{"nombre":"Eco","comando":"echo o3"}]' v allow - -
# --- CA-06: los vectores, sobre la herramienta (registro y puerta) ----------------------------------------------------
I1G53='for f in 0 3 4 5 6 7 8 9 10 11 12 255; do { echo 0 >&$f; } 2>/dev/null; done; false'
I3G53='printf %s "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\"}}"; false'
T1G53="sleep 1000 & echo \$! > '$W53/t1pid'; true"
caso53 I1 'I1 roja que escribe 0 en todo descriptor heredado' "$I1G53" v "roja:$I1G53" - -
caso53 I2 'I2 roja con una trampa EXIT que escribe 0' 'trap "echo 0" EXIT; false' v 'roja:trap "echo 0" EXIT; false' - -
caso53 I2b "I2b la trampa EXIT que hace \`exit 0\` deja el código en 0: verde, como en v1.36.2" "trap 'exit 0' EXIT; false" v allow - -
caso53 I3 'I3 roja que imprime un allow' "$I3G53" v "roja:$I3G53" - -
caso53 I4 'I4 verde `exec true`' 'exec true' v allow - -
caso53 I5 'I5 roja tras una espera (`sleep 3; false`)' 'sleep 3; false' v 'roja:sleep 3; false' - -
caso53 I6 'I6 verde lenta y detrás una roja' $'sleep 3\nfalse' v roja:false - -
for x53 in 124 137 143; do caso53 "I7-$x53" "I7 roja que sale ella misma con $x53" "exit $x53" v "roja:exit $x53" - -; done
caso53 I8 'I8 roja `exec setsid false`' 'exec setsid false' v 'roja:exec setsid false' - -
caso53 E1 'E1 una gate que lee su entrada estándar y detrás una roja (SEC-133, cerrado por construcción)' $'read -r x; true\nfalse' v roja:false - -
caso53 T1 'T1 un superviviente que hereda la salida de la gate: la puerta deja pasar' "$T1G53" v allow - -
# --- CA-03: la puerta no ejecuta ninguna gate, ni con el veredicto válido ---------------------------------------------
MG53="$W53/marca53"
{ pe53 "$W53/p-MK" "$(jq -cn --arg c ": > '$MG53'" '[$c]')" && t53 "$W53/p-MK" && rm -f "$MG53" && l53 MK "$C53" "$W53/p-MK" 60; } &
# --- CA-05: el registro sólo lo escribe la herramienta (a todo agente; fail-before contra v1.36.2) --------------------
pe53 "$W53/p-W" '["true"]'
RW53=.arnes/gates-veredicto.json; NW53=0; FW53=()
w53() {   # <nombre> <herramienta> <orden o -> <esperado C> <esperado B>
  local f="$W53/in-W$NW53"
  if [ "$2" = Bash ]; then jq -cn --arg c "$W53/p-W" --arg cmd "$3" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_input:{command:$cmd}}' > "$f"
  else jq -cn --arg c "$W53/p-W" --arg t "$2" --arg fp "$W53/p-W/$RW53" '{hook_event_name:"PreToolUse",tool_name:$t,cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_input:({file_path:$fp} + (if $t=="Write" then {content:"{}"} elif $t=="Edit" then {old_string:"a",new_string:"b"} else {edits:[{old_string:"a",new_string:"b"}]} end))}' > "$f"; fi
  FW53+=("W$NW53"$'\x1f'"$1"$'\x1f'"$4"$'\x1f'"$5"); l53 "W$NW53-c" "$C53" "$W53/p-W" 30 "$f" &
  if [ "$RV53_OK" = si ]; then l53 "W$NW53-b" "$B53" "$W53/p-W" 30 "$f" & fi
  NW53=$((NW53 + 1))
}
for t53x in Edit Write MultiEdit; do w53 "W CA-05 $t53x del registro, el agente de código" "$t53x" - registro allow; done
for c53 in "echo '{}' > $RW53" "printf x >> $RW53" "echo x | tee $RW53" "cp src/a.txt $RW53" "mv src/a.txt $RW53" "sed -i s/a/b/ $RW53" "install src/a.txt $RW53" "dd if=src/a.txt of=$RW53"; do
  w53 "W CA-05 Bash \`$c53\`" Bash "$c53" registro allow
done
w53 'W CA-05 control: leer el registro (`cat`)' Bash "cat $RW53" allow allow
w53 'W CA-05 control: borrarlo (`rm -f`): sólo hace que la puerta deniegue' Bash "rm -f $RW53" allow allow
# QA-037-11: `ln` y `ln -s` con el registro de destino, y de fuente de un enlace duro (en 42a320c, allow); `unlink`, control.
for c53 in "ln -s VJ $RW53" "ln -sf VJ $RW53" "ln VJ $RW53" "ln $RW53 otro.json"; do
  w53 "W CA-05 (ii) Bash \`$c53\`" Bash "$c53" registro allow
done
w53 'W CA-05 control: borrarlo (`unlink`)' Bash "unlink $RW53" allow allow
# --- CA-02: la herramienta y sus códigos de salida --------------------------------------------------------------------
{ pe53 "$W53/h-0" '[]' && t53 "$W53/h-0"; } &
{ pe53 "$W53/h-g" '["true"]' && rm -rf "$W53/h-g/.git" && t53 "$W53/h-g"; } &
{ pe53 "$W53/h-c" '["echo cambio >> src/a.txt"]' && t53 "$W53/h-c"; } &
# Cortada a mitad (borde de CA-07): un veredicto verde previo, otra corrida con una gate larga en SU PROPIA SESIÓN (el
# bash que la lanza deja su pid, que es el de su grupo) y el corte a ese grupo a los 2 s. No queda registro.
hk53() {
  local p="$W53/h-k" g=''
  pe53 "$p" '["true"]' && t53 "$p" || return 0
  jq -c '.quality_gates = ["sleep 30"]' "$p/.arnes/config.json" > "$p.m" && mv "$p.m" "$p/.arnes/config.json"
  setsid bash -c 'echo $$ > "$1.pg"; cd "$1" && exec bash "$2" --quien banco --proyecto "$1"' _ "$p" "$TOOL53" >/dev/null 2>&1 &
  sleep 2; g="$(cat "$p.pg" 2>/dev/null)"
  case "$g" in ''|*[!0-9]*) echo sin-grupo > "$p.res"; return 0 ;; esac
  kill -TERM -- "-$g" 2>/dev/null; sleep 1; kill -KILL -- "-$g" 2>/dev/null; wait
  { [ -e "$p/.arnes/gates-veredicto.json" ] && echo queda || echo sin-registro; } > "$p.res"
}
hk53 &
# --- CA-08 (a): un documento por respuesta, en serie y con cierres concurrentes ---------------------------------------
d53() {   # <id> <prep> <gates> <n> — <n> cierres seguidos: «<n> dobles cuelgues otros»; cuelgue = sin respuesta en 5 s
  local p="$W53/d-$1" i o rc d x dob=0 cue=0 otr=0
  pe53 "$p" "$3" && prep53 "$2" "$p" || return 0
  for ((i = 0; i < $4; i++)); do
    o="$(cd "$p" && CLAUDE_PROJECT_DIR="$p" timeout 5 bash "$C53/guard.sh" < "$p/in" 2>/dev/null)"; rc=$?
    d=0; x="$o"; while [[ "$x" == *'"permissionDecision"'* ]]; do d=$((d + 1)); x="${x#*'"permissionDecision"'}"; done
    if [ "$rc" = 124 ]; then cue=$((cue + 1))
    elif [ "$d" -gt 1 ]; then dob=$((dob + 1))
    elif [ "$1" = verde ] && { [ "$d" != 0 ] || [ "$rc" != 0 ]; }; then otr=$((otr + 1))
    elif [ "$1" != verde ] && [ "$d" != 1 ]; then otr=$((otr + 1)); fi
  done
  printf '%s %s %s %s\n' "$i" "$dob" "$cue" "$otr" > "$p.res"
}
d53 verde v '["true"]' 30 & d53 roja v '["false"]' 30 & d53 caducado src '["true"]' 30 & d53 ausente - '["true"]' 30 &
wait
# --- El juicio, en orden ----------------------------------------------------------------------------------------------
for r53 in "${R53[@]}"; do
  IFS='|' read -r id53 nom53 ec53 tc53 eb53 <<< "$r53"; nom53="REQ-037 $nom53"
  j53 "$nom53 candidata" "$id53-c" "$ec53" "$tc53"
  [ -n "$eb53" ] || continue
  if [ "$RV53_OK" != si ]; then v53 SKIP "$nom53 v1.36.2  $RV53_MOT"; else j53 "$nom53 v1.36.2" "$id53-b" "$eb53" -; fi
done
for r53 in "${FW53[@]}"; do
  IFS=$'\x1f' read -r id53 nom53 ec53 eb53 <<< "$r53"; nom53="REQ-037 $nom53"   # la orden puede llevar `|`
  j53 "$nom53 candidata" "$id53-c" "$ec53" -
  if [ "$RV53_OK" != si ]; then v53 SKIP "$nom53 v1.36.2  $RV53_MOT"; else j53 "$nom53 v1.36.2" "$id53-b" "$eb53" -; fi
done
nom53='REQ-037 MK CA-03 la puerta no ejecuta ninguna gate: con el veredicto válido, el marcador de la gate no aparece candidata'
if [ "$(cat "$W53/MK.rc" 2>/dev/null)" = 0 ] && [ ! -s "$W53/MK.out" ] && [ ! -e "$MG53" ]; then v53 PASS "$nom53"
else v53 FAIL "$nom53  rc=<$(cat "$W53/MK.rc" 2>/dev/null)> salida=<$(head -c 120 "$W53/MK.out" 2>/dev/null)> marcador=<$([ -e "$MG53" ] && echo está || echo no)>"; fi
# La herramienta: CA-02 (iv) y sus bordes.
h53() {   # <nombre> <rc esperado> <rc obtenido> <registro esperado si|no> <proyecto>
  local hay=no; [ -e "$5/.arnes/gates-veredicto.json" ] && hay=si
  if [ "$3" = "$2" ] && [ "$hay" = "$4" ]; then v53 PASS "REQ-037 $1  (rc $3, registro: $hay)"
  else v53 FAIL "REQ-037 $1  rc esperado $2 obtenido <$3>, registro esperado $4 obtenido $hay"; fi
}
h53 'H1 CA-02 todas verdes: sale 0 y escribe el registro' 0 "$(cat "$W53/p-C2-c.tool.rc" 2>/dev/null)" si "$W53/p-C2-c"
h53 'H2 CA-02 una roja: sale 1, se detiene y registra el rojo' 1 "$(cat "$W53/p-C1-c.tool.rc" 2>/dev/null)" si "$W53/p-C1-c"
h53 'H3 CA-02 sin quality_gates: sale 2 y no escribe' 2 "$(cat "$W53/h-0.tool.rc" 2>/dev/null)" no "$W53/h-0"
h53 'H4 CA-01 sin git: sale 2 y no escribe' 2 "$(cat "$W53/h-g.tool.rc" 2>/dev/null)" no "$W53/h-g"
h53 'H5 CA-02 (ii) el árbol cambia mientras corren: sale 2 y no escribe' 2 "$(cat "$W53/h-c.tool.rc" 2>/dev/null)" no "$W53/h-c"
nom53='REQ-037 H6 CA-02 (iii) una corrida cortada no deja registro, ni el verde anterior'
if [ "$(cat "$W53/h-k.res" 2>/dev/null)" = sin-registro ]; then v53 PASS "$nom53"; else v53 FAIL "$nom53  <$(cat "$W53/h-k.res" 2>/dev/null)>"; fi
nom53='REQ-037 H7 CA-06 T1: con un superviviente de la gate, la herramienta vuelve en no más de 5 s'
t153="$(cat "$W53/p-T1-c.tool.ms" 2>/dev/null)"
if [ -n "$t153" ] && [ "$t153" -le 5000 ] && [ "$(cat "$W53/p-T1-c.tool.rc" 2>/dev/null)" = 0 ]; then v53 PASS "$nom53  ($t153 ms)"
else v53 FAIL "$nom53  <$t153> ms, rc <$(cat "$W53/p-T1-c.tool.rc" 2>/dev/null)>"; fi
t153="$(cat "$W53/t1pid" 2>/dev/null)"; case "$t153" in ''|*[!0-9]*) ;; *) kill -KILL "$t153" 2>/dev/null ;; esac   # el superviviente de T1
for d53x in verde roja caducado ausente; do
  nom53="REQ-037 D CA-08 (a) 30 cierres seguidos, veredicto $d53x: un documento por respuesta (cero si allow), ninguno de más de 5 s"
  read -r n53 dob53 cue53 otr53 2>/dev/null < "$W53/d-$d53x.res" || n53=''
  if [ "$n53" != 30 ]; then v53 FAIL "$nom53  el bucle no terminó (<$(cat "$W53/d-$d53x.res" 2>/dev/null)>)"
  elif [ "$dob53$cue53$otr53" = 000 ]; then v53 PASS "$nom53"
  else v53 FAIL "$nom53  $dob53 con más de un documento, $cue53 de más de 5 s, $otr53 con otra respuesta"; fi
done
# --- CA-10: el coste de la puerta --------------------------------------------------------------------------------------
min53() {   # <hooks> <proyecto> [entrada] -> el mínimo de 5 corridas, en µs
  local i t m=''; for i in 1 2 3 4 5; do
    t=${EPOCHREALTIME/./}; (cd "$2" && CLAUDE_PROJECT_DIR="$2" bash "$1/guard.sh" < "${3:-$2/in}" >/dev/null 2>&1); t=$(( ${EPOCHREALTIME/./} - t ))
    [ -n "$m" ] && [ "$m" -le "$t" ] || m=$t; done; printf '%s' "$m"
}
procs53() {   # <hooks> <proyecto> [entrada] -> procesos de la invocación, o vacío
  local s; s="$("$UTIL_DIR/sonda-procesos.sh" --dir-trabajo "$RAIZ" --etiqueta 53-procesos \
    --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git readlink realpath cygpath find stat rm sleep' \
    --sujeto "cd '$2' && CLAUDE_PROJECT_DIR='$2' bash '$1/guard.sh' < '${3:-$2/in}'" 2>/dev/null)"
  sonda_lee "$s" && [ "${SONDA[estado]}" = ok ] && printf '%s' "${SONDA[cuenta]:-}"
}
razon53() {   # <nombre> <a µs> <b µs> <techo ×100>
  local cif="$(( $2 / 1000 ))/$(( $3 / 1000 )) ms, $(( $2 * 1000 / $3 ))/1000 ×"
  if [ "$3" -lt 50000 ]; then v53 SKIP "$1  bajo el suelo de 50 ms; no acredita ($cif)"
  elif [ $(( $2 * 100 )) -le $(( $3 * $4 )) ]; then v53 PASS "$1  ($cif)"
  else v53 FAIL "$1  $cif, por encima de ${4:0:1},${4:1}×"; fi
}
razon53 'REQ-037 K1 CA-10 (i) el cierre con veredicto de `sleep 35` y el de `true` tardan lo mismo: razón ≤ 1,25×' "$(min53 "$C53" "$W53/p-G1-c")" "$(min53 "$C53" "$W53/p-C2-c")" 125
nom53='REQ-037 K2 CA-10 (ii) procesos del cierre con veredicto frente al de `quality_gates: []` de v1.36.2: no más de 4 añadidos'
if [ "$RV53_OK" != si ]; then v53 SKIP "$nom53  $RV53_MOT"
else pc53="$(procs53 "$C53" "$W53/p-C2-c")"; pb53="$(procs53 "$B53" "$W53/p-C3-b")"
  if [ -z "$pc53" ] || [ -z "$pb53" ]; then v53 SKIP "$nom53  la sonda no midió (<$pc53>/<$pb53>)"
  elif [ "$pc53" -le $(( pb53 + 4 )) ]; then v53 PASS "$nom53  (candidata $pc53 / v1.36.2 $pb53)"
  else v53 FAIL "$nom53  $pc53 > $pb53 + 4"; fi; fi
# K3: el cierre en el árbol de este repositorio (su HEAD, por `git archive`, con el veredicto de la herramienta).
nom53='REQ-037 K3 CA-10 (ii) el cierre con veredicto, en el árbol de este repositorio: no más de 1 s'
pr53="$W53/k-repo"; mkdir -p "$pr53"
if git -C "$REPO53" archive HEAD 2>/dev/null | tar -x -C "$pr53" 2>/dev/null \
   && jq -cn '{agentes:{agente_codigo:"desarrollador",conocidos:["qa-tester"]},codigo_app:{globs:["src/*"]},quality_gates:["true"]}' > "$pr53/.arnes/config.json" \
   && printf '# REQ-901\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n' > "$pr53/requirements/REQ-901.md" \
   && printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$pr53/PENDING_APPROVAL.md" \
   && ( cd "$pr53" && git init -q && git add -A && git -c user.email=b@b -c user.name=b commit -qm base ) >/dev/null 2>&1 \
   && jq -cn --arg fp "$pr53/requirements/REQ-901.md" --arg c "$pr53" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$pr53/in" \
   && t53 "$pr53" && [ "$(cat "$pr53.tool.rc")" = 0 ]; then
  m53="$(min53 "$C53" "$pr53")"; l53 K3 "$C53" "$pr53" 60
  if [ -s "$W53/K3.out" ]; then v53 FAIL "$nom53  la puerta no dejó pasar: <$(head -c 160 "$W53/K3.out")>"
  elif [ "$m53" -le 1000000 ]; then v53 PASS "$nom53  ($(( m53 / 1000 )) ms, $(git -C "$pr53" ls-files | wc -l) archivos)"
  else v53 FAIL "$nom53  $(( m53 / 1000 )) ms"; fi
else v53 FAIL "$nom53  no se pudo preparar la copia del repositorio con su veredicto (<$(tail -c 200 "$pr53.tool.out" 2>/dev/null)>)"; fi
# K4: el cociente de duplicación del hash, a nivel de librería: 4 000 y 8 000 archivos.
nom53='REQ-037 K4 CA-10 (iii) doblar los archivos del árbol no más que dobla el hash: cociente ≤ 2,5'
for n53 in 4000 8000; do
  pk53="$W53/k-$n53"; mkdir -p "$pk53/d"; for ((i53 = 0; i53 < n53; i53++)); do printf '%s\n' "$i53" > "$pk53/d/f$i53"; done
  ( cd "$pk53" && git init -q ) >/dev/null 2>&1
done
q53="$( ( . "$C53/lib.sh" >/dev/null 2>&1 || exit 97; for n53 in 4000 8000; do m=''; for i in 1 2 3; do t=${EPOCHREALTIME/./}; arnes_hash_arbol "$W53/k-$n53" || exit 98; t=$(( ${EPOCHREALTIME/./} - t )); [ -n "$m" ] && [ "$m" -le "$t" ] || m=$t; done; printf '%s ' "$m"; done ) 2>/dev/null )"
read -r k2a53 k4a53 <<< "$q53"
if [ -z "${k4a53:-}" ]; then v53 FAIL "$nom53  la librería no midió (<$q53>)"
elif [ "$k2a53" -lt 50000 ]; then v53 SKIP "$nom53  bajo el suelo de 50 ms ($k2a53 µs / $k4a53 µs)"
elif [ $(( k4a53 * 10 )) -le $(( k2a53 * 25 )) ]; then v53 PASS "$nom53  ($(( k2a53 / 1000 )) → $(( k4a53 / 1000 )) ms, $(( k4a53 * 100 / k2a53 ))/100)"
else v53 FAIL "$nom53  $(( k2a53 / 1000 )) → $(( k4a53 / 1000 )) ms, $(( k4a53 * 100 / k2a53 ))/100"; fi
# PROC y RELOJ: camino común (`ls -la`) y cierre sin gates: 0 procesos añadidos (de contrato) y 1,25× el de v1.36.2.
jq -cn --arg c "$W53/p-C3-c" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"ls -la"}}' > "$W53/k-ls.json"
for r53 in "camino común, ls -la|$W53/k-ls.json" "cierre con quality_gates: []|"; do
  IFS='|' read -r rama53 f53 <<< "$r53"
  np53="REQ-037 PROC CA-10 $rama53: 0 procesos añadidos frente a v1.36.2"; nr53="REQ-037 RELOJ CA-10 $rama53 (operativo): mínimo de 5 frente a v1.36.2, techo 1,25×"
  if [ "$RV53_OK" != si ]; then v53 SKIP "$np53  $RV53_MOT"; v53 SKIP "$nr53  $RV53_MOT"; continue; fi
  pc53="$(procs53 "$C53" "$W53/p-C3-c" "$f53")"; pb53="$(procs53 "$B53" "$W53/p-C3-b" "$f53")"
  if [ -z "$pc53" ] || [ -z "$pb53" ]; then v53 SKIP "$np53  la sonda no midió (<$pc53>/<$pb53>)"
  elif [ "$pc53" -le "$pb53" ]; then v53 PASS "$np53  (candidata $pc53 / v1.36.2 $pb53)"
  else v53 FAIL "$np53  $pc53 > $pb53"; fi
  razon53 "$nr53" "$(min53 "$C53" "$W53/p-C3-c" "$f53")" "$(min53 "$B53" "$W53/p-C3-b" "$f53")" 125
done
rm -rf "$W53" "$RV53"
