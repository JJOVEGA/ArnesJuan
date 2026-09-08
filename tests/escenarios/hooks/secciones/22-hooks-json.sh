# Sección 22 del banco — 22-hooks-json
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=9
PISO_AUTONOMO_SECCION=38  # 14 preámbulo + 5 maquinaria compartida duplicada + 19 bloque indivisible mayor · REQ-014 CA-18

# --- hooks.json: la forma que hace que Bash de lectura NO arranque el guard -------
# Los hooks del plugin se declaran en hooks.json y Claude Code evalua el `if` de cada
# handler ANTES de crear el proceso (verificado en 2.1.260 con control positivo). El
# banco no puede probar ese motor --es de Claude Code--, pero SI puede fijar la forma
# del archivo: si alguien anade un handler Bash sin `if`, todos los `ls` vuelven a
# pagar el interprete y nadie lo nota, porque nada falla: solo se vuelve lento.
seccion_nueva "hooks.json (la forma que NO deja Bash sin guardian):"
HJ="$HOOKS_DIR/hooks.json"
hj_check() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; FAIL=$((FAIL+1)); fi
}
hj_check "es JSON valido" "ok" "$(jq -e . "$HJ" >/dev/null 2>&1 && echo ok || echo roto)"
# NINGUN handler lleva `if`. 1.25.0 puso uno por disparador para que un `ls` no arrancara
# el guardian, y `if` funciona --medido con control positivo-- pero SOLO para prefijos de
# comando: una redireccion NUNCA casa, porque Claude Code la separa del comando antes de
# evaluar el patron. Medido en un proyecto real: `echo 'Estado: completado' > requirements/x`
# paso y creo el archivo. Como la redireccion puede ir en cualquier comando, la unica puerta
# posible para Bash es la que ve TODOS. Este caso existe para que nadie vuelva a "optimizar"
# esto sin pasar por aqui: la version anterior de este mismo banco EXIGIA el `if`, y eso
# certificaba la forma que dejaba la puerta en abierto.
hj_check "NINGUN handler lleva if: la redireccion no se puede seleccionar con if" "0" \
  "$(jq -r '[.hooks.PreToolUse[] | .hooks[] | select(has("if"))] | length' "$HJ")"
hj_check "un solo grupo cubre Edit|Write|MultiEdit|Bash" "1" \
  "$(jq -r '[.hooks.PreToolUse[] | select(.matcher=="Edit|Write|MultiEdit|Bash")] | length' "$HJ")"
hj_check "Bash esta en el matcher (la puerta de consola existe)" "true" "$(jq -r '[.hooks.PreToolUse[].matcher | select(split("|") | index("Bash") != null)] | length > 0' "$HJ")"
hj_check "todos los handlers PreToolUse apuntan a guard.sh" "0" \
  "$(jq -r '[.hooks.PreToolUse[] | .hooks[] | select(.command | endswith("/hooks/guard.sh") | not)] | length' "$HJ")"
hj_check "Stop y SubagentStop: UN solo proceso, stop.sh" "stop.sh-stop.sh" \
  "$(jq -r '.hooks.Stop[0].hooks | map(.command | split("/") | last) | join(",")' "$HJ")-$(jq -r '.hooks.SubagentStop[0].hooks | map(.command | split("/") | last) | join(",")' "$HJ")"

# --- stop.sh: el segundo paso sigue corriendo tras el primero ---------------------
# Mismo caso que "guard.sh: el 2o guardian sigue corriendo tras el 1o": si la
# continuidad terminara el proceso, la rotacion nunca correria y nadie lo veria.
# (misma seccion: comparte proyecto con la de arriba)
echo "stop.sh (continuidad y rotacion en un proceso):"
ST="$(mktemp -d)"; mkdir -p "$ST/.arnes" "$ST/requirements" "$ST/docs"
jq '.rotacion = {activo:true, umbral_bytes:500, conservar_secciones:2, artefactos:["CHANGELOG.md"]}' "$PROJ/.arnes/config.json" > "$ST/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$ST/PENDING_APPROVAL.md"
printf '# REQ-001\nEstado: en-revisión\nQA: pendiente\nSeguridad: n/a\n' > "$ST/requirements/REQ-001.md"
{ printf '# CHANGELOG\n\n'; for v in 5 4 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in 1 2 3 4; do printf 'relleno %s de 1.%s.0 para que pese\n' "$i" "$v"; done; printf '\n'; done; } > "$ST/CHANGELOG.md"
: > "$ERRLOG"
CLAUDE_PROJECT_DIR="$ST" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}' | CLAUDE_PROJECT_DIR="$ST" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"; ST_RC=$?
hj_check "stop.sh sale 0 (no bloquea la parada)" "0" "$ST_RC"
hj_check "la continuidad escribio su bloque" "1" "$(grep -c 'ARNES:DERIVADO inicio' "$ST/docs/ESTADO.md" 2>/dev/null || echo 0)"
hj_check "...y la rotacion corrio EN LA MISMA parada" "2" "$(grep -c '^## ' "$ST/CHANGELOG.md")"
rm -rf "$ST"

