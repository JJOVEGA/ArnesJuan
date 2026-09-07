# Sección 32 del banco — 32-huecos-auditoria-r001
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=40

# --- REQ-007: los huecos de la auditoria R-001 (SEC-001, SEC-002, SEC-003, SEC-006) ----
  seccion_nueva "Huecos de la auditoria de seguridad R-001 (REQ-007, bloque H):"

printf '# REQ-700\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-700.md"
printf '# REQ-701\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-701.md"

# --- SEC-003 (CA-47/CA-48): una barra de mas desactivaba LAS DOS puertas ---
# Un caracter, sin ninguna forma exotica: `arnes_ruta_relativa` recortaba el prefijo del
# proyecto TEXTUALMENTE, la ruta no empezaba por `<raiz>/`, ningun glob casaba y ninguna
# ruta caia dentro de requirements/.
check "REQ-007 CA-47 SEC-003 Write a <raiz>//src//a.ts -> deny igual que con una barra" deny \
  guard-codigo.sh "$(emite_write "$PROJ//src//a.ts" 'hola')"
check "REQ-007 CA-47 SEC-003 Edit que cierra un REQ en <raiz>//requirements//REQ-700.md -> deny" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ//requirements//REQ-700.md" 'en-revisión' 'completado')"
# CA-48: los controles positivos que YA se resolvian bien no pueden romperse.
check "REQ-007 CA-48 control <raiz>/./src/../src/a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "$PROJ/./src/../src/a.ts" 'hola')"
check "REQ-007 CA-48 control <raiz>/src/./a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "$PROJ/src/./a.ts" 'hola')"
check "REQ-007 CA-48 control ruta relativa src/a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "src/a.ts" 'hola')"
check "REQ-007 CA-48 control ./src/a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "./src/a.ts" 'hola')"
# CA-48 (a): lo que decide es el glob, no la barra.
check "REQ-007 CA-48 <raiz>//docs//notas.md (fuera de los globs) -> allow" allow \
  guard-codigo.sh "$(emite_write "$PROJ//docs//notas.md" 'hola')"
# CA-48 (b): la doble barra INICIAL de una UNC de Windows no se colapsa.
check "REQ-007 CA-48 una ruta UNC //servidor/recurso/x.ts conserva su forma -> allow" allow \
  guard-codigo.sh "$(emite_write "//servidor/recurso/src/a.ts" 'hola')"
# CA-48 (c): la restriccion sigue siendo de QUIEN edita.
check "REQ-007 CA-48 el desarrollador si puede escribir en <raiz>//src//a.ts" allow \
  guard-codigo.sh "$(jq -n --arg fp "$PROJ//src//a.ts" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,agent_id:"a1",agent_type:"desarrollador",tool_input:{file_path:$fp,content:"hola"}}')"

# --- SEC-001 (CA-43/CA-44): un byte de control desincronizaba la simulacion ---
# El separador de las piezas viaja DENTRO del dato que controla quien llama. Con campos
# de mas, el bucle leia como tripletas cosas que no lo eran y el documento que el hook
# simulaba dejaba de ser el que la herramienta iba a escribir: las cuatro puertas del
# cierre se saltaban a la vez, con un byte.
SOH=$'\001'
check "REQ-007 CA-43 SEC-001 MultiEdit con un byte de control en el new_string -> deny" deny \
  guard-completado.sh "$(jq -n --arg fp "$PROJ/requirements/REQ-700.md" --arg ns "completado${SOH}x${SOH}y${SOH}1" \
    '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:[{old_string:"en-revisión",new_string:$ns},{old_string:"# REQ-700",new_string:"# REQ-700"}]}}')"
check "REQ-007 CA-43 SEC-001 Write con 'nota'+byte de control delante del documento cerrado -> deny" deny \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-700.md" "nota${SOH}# REQ-700
Estado: completado
QA: pendiente
")"
check "REQ-007 CA-44 control: el MultiEdit HONESTO que cierra con QA pendiente ya denegaba" deny \
  guard-completado.sh "$(emite_multiedit "$PROJ/requirements/REQ-700.md" 'en-revisión' 'completado' '# REQ-700' '# REQ-700 x')"
check "REQ-007 CA-44 control: el mismo MultiEdit sobre un REQ en verde -> allow" allow \
  guard-completado.sh "$(emite_multiedit "$PROJ/requirements/REQ-701.md" 'en-revisión' 'completado' '# REQ-701' '# REQ-701 x')"
check "REQ-007 CA-44 control: tabuladores y saltos de linea legitimos no son un falso positivo" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-701.md" '# REQ-701' "# REQ-701
| a	| b |
")"

# --- SEC-002 (CA-45/CA-46): un NUL en el REQ truncaba la lectura del disco ---
# `read -d ''` se detiene en el primer NUL: los veredictos se leian de un texto incompleto
# —y un campo vacio no exige nada— y ademas el `old_string` no se encontraba, asi que la
# puerta caia a la via mas laxa. Bastaba una escritura previa en requirements/.
printf '# REQ-702 ' > "$PROJ/requirements/REQ-702.md"
printf '\000' >> "$PROJ/requirements/REQ-702.md"
printf ' nota\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' >> "$PROJ/requirements/REQ-702.md"
check_motivo "REQ-007 CA-45 SEC-002 un NUL en el REQ: el cierre deniega con motivo propio" \
  'no se puede leer entero' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-702.md" 'en-revisión' 'completado')"
check "REQ-007 CA-46 control: sobre el REQ con NUL, una edicion que no toca el estado -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-702.md" 'nota' 'otra anotacion')"
check "REQ-007 CA-46 control: el mismo REQ SIN NUL y con QA pendiente -> deny (como siempre)" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-700.md" 'en-revisión' 'completado')"
check "REQ-007 CA-46 control: el mismo REQ SIN NUL y con los veredictos completos -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-701.md" 'en-revisión' 'completado')"

# --- SEC-006 parte (b) (CA-54/CA-55): el techo del manifiesto no tenia tope ---
# El coste del analisis crece con el tamano y un hook PreToolUse MUERE a los 60 s
# permitiendo: sin maximo, subir el techo desde el manifiesto reabria POR CONFIGURACION
# el fallo en abierto que el presupuesto cerro.
GRANDE="$(printf 'a%.0s' $(seq 1 140000))"
MEDIANO="$(printf 'a%.0s' $(seq 1 70000))"
setcfg '.limites.bash_max_analisis = 4294967296'
check_motivo "REQ-007 CA-54 SEC-006 un techo de 4294967296 se recorta al maximo y el deny lo dice" \
  'presupuesto de analisis vigente es de 131072 bytes' guard-codigo.sh "$(emite_bash "$GRANDE" "" "")"
setcfg '.limites.bash_max_analisis = 99999999999999999999'
check_motivo "REQ-007 CA-54 SEC-006 un valor que desborda 64 bits tampoco sube el techo" \
  'presupuesto de analisis vigente es de 131072 bytes' guard-codigo.sh "$(emite_bash "$GRANDE" "" "")"
setcfg '.limites.bash_max_analisis = "999999"'
check_motivo "REQ-007 CA-54 SEC-006 '999999' entrecomillado no es un numero: cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
# CA-55: los cuatro controles ya medidos. Su veredicto es identico al de v1.30.3.
setcfg '.limites.bash_max_analisis = 100'
check_motivo "REQ-007 CA-55 control: un valor mas bajo que el defecto no baja el techo" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
setcfg '.limites.bash_max_analisis = -5'
check_motivo "REQ-007 CA-55 control: -5 cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
setcfg '.limites.bash_max_analisis = 0'
check_motivo "REQ-007 CA-55 control: 0 cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
setcfg 'del(.limites)'
check_motivo "REQ-007 CA-55 control: la clave ausente cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
# CA-55: el motivo del deny por presupuesto NO nombra ninguna ruta (QA-016 de REQ-001).
S7_MOT="$(printf '%s' "$(emite_bash "$MEDIANO" "" "")" | "$HOOKS_DIR/guard-codigo.sh" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason // ""')"
if [ -n "$FILTRO" ] && ! printf '%s' "REQ-007 CA-55 el deny por presupuesto no nombra ninguna ruta" | grep -qi -- "$FILTRO"; then :
elif printf '%s' "$S7_MOT" | grep -q 'src/'; then
  echo "  FAIL  REQ-007 CA-55 el deny por presupuesto no nombra ninguna ruta"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-55 el deny por presupuesto no nombra ninguna ruta"; PASS=$((PASS+1))
fi
# CA-53, control obligatorio: la ampliacion de globs es MAPEO de ArnesJuan y no se propaga
# a las plantillas. Si un dia aparece ahi, este caso se pone rojo.
if [ -n "$FILTRO" ] && ! printf '%s' "REQ-007 CA-53 ninguna plantilla hereda los globs del autoalojamiento" | grep -qi -- "$FILTRO"; then :
elif sed -n '/"codigo_app"/,/^  }/p' "$TPL_DIR/arnes-config.json.tpl" | grep -qE '\.arnes|\.claude-plugin'; then
  echo "  FAIL  REQ-007 CA-53 ninguna plantilla hereda los globs del autoalojamiento"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-53 ninguna plantilla hereda los globs del autoalojamiento"; PASS=$((PASS+1))
fi

# --- QA-014 (CA-40/CA-41): la clase del hallazgo solo se leia en forma CERRADA ---
# `AGENTS.md` 6 pide anotar dueno y forzador en la deuda de `instrumento`, y la puerta
# denegaba el cierre justo por esa anotacion: partia la lista por comas sin mirar el
# parentesis y leia «un hallazgo sin clase». Castigaba lo que la metodologia pide.
mkreq "$PROJ/requirements/REQ-710.md" no aprobado n/a 'QA-006 (instrumento, dueño REQ-007)'
check "REQ-007 CA-40 QA-014 '(instrumento, dueño REQ-007)': la clase es el primer elemento -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-710.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-711.md" no aprobado n/a 'SEC-9 (usuario/dinero, dueño desarrollador, vence 2026-10-01)'
check_motivo "REQ-007 CA-40 QA-014 la evidencia acompana, nunca cambia el veredicto -> deny por la clase" \
  "clase 'usuario/dinero'" guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-711.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-712.md" no aprobado n/a 'QA-006 (nota, instrumento)'
check_motivo "REQ-007 CA-41 control: la clase NO es el primer elemento -> deny" \
  'no cuenta como hallazgo' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-712.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-713.md" no aprobado n/a 'QA-006 [instrumento]'
check_motivo "REQ-007 CA-41 control: otro delimitador no es un parentesis -> deny" \
  'no cuenta como hallazgo' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-713.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-714.md" no aprobado n/a 'QA-006 (dueño REQ-007)'
# El motivo admite las dos redacciones —la de v1.30.3 y la de esta version—: lo que este
# control acredita es que un hallazgo sin clase reconocible NO cierra, en las dos.
check_motivo "REQ-007 CA-41 control: sin ninguna clase -> deny" \
  'no cuenta como hallazgo|no es una clase valida|que no existe' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-714.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-715.md" no aprobado n/a 'QA-006 (Instrumento)'
check "REQ-007 CA-41 control: '(Instrumento)' se sigue leyendo como hoy -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-715.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-716.md" no aprobado n/a 'QA-006 ( instrumento )'
check "REQ-007 CA-41 control: '( instrumento )' se sigue leyendo como hoy -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-716.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-717.md" no aprobado n/a 'QA-006 (instrumento) — REQ-007'
check "REQ-007 CA-41 control: '(instrumento) — REQ-007' se sigue leyendo como hoy -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-717.md" 'en-revisión' 'completado')"

# --- SEC-007 (CA-56/CA-57): la reconstruccion no tenia techo ---
# El presupuesto fail-closed del analisis de Bash vivia SOLO en el detector de escrituras;
# la via Edit/MultiEdit aplicaba cada edicion sobre una copia completa del texto. Medido:
# 1.501 ediciones sobre 300 KB -> 25,7 s, y 3,1 MB x 401 ediciones -> sin respuesta a los
# 30 s. A los 60 s el hook muere sin emitir nada y el resultado efectivo es PERMITIR.
S7BIG="$PROJ/requirements/REQ-720.md"
{ printf '# REQ-720\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n'
  for i in $(seq 0 49); do printf 'marca%s\n' "$i"; done
  printf 'x%.0s' $(seq 1 700000); printf '\n'; } > "$S7BIG"
# emite_multi_n <file> <n> — n ediciones iguales en UNA sola llamada a jq.
emite_multi_n() {
  jq -n --arg fp "$1" --argjson n "$2" \
    '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:[range($n)|{old_string:"en-revisión",new_string:"completado"}]}}'
}
check_motivo "REQ-007 CA-56 SEC-007 100 ediciones sobre 700 KB superan el presupuesto -> deny" \
  'presupuesto de 67108864 bytes-edicion' guard-completado.sh "$(emite_multi_n "$S7BIG" 100)"
# CA-56: el motivo dice el presupuesto y NO nombra ninguna ruta.
S7_M="$(printf '%s' "$(emite_multi_n "$S7BIG" 100)" | "$HOOKS_DIR/guard-completado.sh" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason // ""')"
if [ -n "$FILTRO" ] && ! printf '%s' "REQ-007 CA-56 el deny por presupuesto de reconstruccion no nombra ninguna ruta" | grep -qi -- "$FILTRO"; then :
elif printf '%s' "$S7_M" | grep -qE 'REQ-720|requirements/'; then
  echo "  FAIL  REQ-007 CA-56 el deny por presupuesto de reconstruccion no nombra ninguna ruta"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-56 el deny por presupuesto de reconstruccion no nombra ninguna ruta"; PASS=$((PASS+1))
fi
# CA-57 (b): por DEBAJO del presupuesto se reconstruye y se juzga con el veredicto de siempre.
# 50 ediciones REALES —cada una casa con su marca en el documento— mas el cierre: el
# documento se reconstruye de verdad y se juzga por su cabecera resultante.
check "REQ-007 CA-57 control: 50 ediciones (bajo el presupuesto) se juzgan como siempre -> deny" deny \
  guard-completado.sh "$(jq -n --arg fp "$S7BIG" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:([range(50)|{old_string:("marca"+tostring),new_string:("MARCA"+tostring)}]
                                       + [{old_string:"en-revisión",new_string:"completado"}])}}')"
# CA-57 (c): por encima del presupuesto NUNCA hay allow, ni siquiera para el agente de codigo.
check "REQ-007 CA-57 control: el deny por presupuesto alcanza tambien al desarrollador" deny \
  guard-completado.sh "$(emite_multi_n "$S7BIG" 100 | jq '. + {agent_id:"a1",agent_type:"desarrollador"}')"
# CA-57 (a): el caso ordinario no cambia de veredicto ni de coste.
check "REQ-007 CA-57 control: una edicion sola sobre el mismo REQ se juzga como siempre -> deny" deny \
  guard-completado.sh "$(emite_edit_real "$S7BIG" 'en-revisión' 'completado')"
