# Sección 33 del banco — 33-acento-y-clave-2-manifiesto
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=45
PISO_AUTONOMO_SECCION=157  # 8 preámbulo + 26 maquinaria compartida duplicada + 123 bloque indivisible mayor · REQ-014 CA-18

seccion_nueva "La ruta escrita y el manifiesto roto (SEC-004, SEC-005, SEC-006):"

# ---------- SEC-004 (CA-49/CA-50): el arnes juzga LA RUTA ESCRITA, no su destino ----------
printf '# REQ-860\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-860.md"
ln -sf "$PROJ/requirements/REQ-860.md" "$PROJ/docs/enlace.md"
check_motivo "SEC-004 CA-49 Edit sobre un enlace a un REQ -> deny (salida fail-closed)" \
  'ENLACE SIMBOLICO|ruta escrita, no su destino' guard-completado.sh \
  "$(emite_write "$PROJ/docs/enlace.md" "# REQ-860
Estado: completado
QA: pendiente
")"
ln -sf "$PROJ/src/a.ts" "$PROJ/docs/enlace-src.md"
check "SEC-004 CA-49 Write sobre un enlace a codigo protegido -> deny tambien en guard-codigo" deny \
  guard-codigo.sh "$(emite_write "$PROJ/docs/enlace-src.md" 'hola')"
# CA-50 (a): un archivo REGULAR fuera de los globs sigue permitido. La puerta no puede
# convertir en protegido lo que no lo es.
printf 'notas\n' > "$PROJ/docs/notas.md"
check "SEC-004 CA-50a un archivo REGULAR en docs/ sigue -> allow" allow \
  guard-codigo.sh "$(emite_write "$PROJ/docs/notas.md" 'hola')"
check "SEC-004 CA-50a ...y tambien para la puerta de cierre" allow \
  guard-completado.sh "$(emite_write "$PROJ/docs/notas.md" 'hola')"
# CA-50 (b): un enlace ROTO no puede matar al guardian — y un guardian muerto no deniega.
ln -sf "$PROJ/no-existe-jamas.md" "$PROJ/docs/enlace-roto.md"
# DEV 1.31.0 v3 (QA-111): este caso tambien decidia por reloj de pared (umbral 1000 ms)
# y era el decimo del banco que lo hacia. Lo que acredita —«ni cuelga ni revienta»— es
# discreto: que RESPONDA (no lo corte `timeout`) y que responda `deny`. El reloj se
# informa; no decide. Un enlace roto que colgara el guardian lo caza el `timeout`, que es
# el fallo real: un hook muerto no deniega.
mide_hook guard.sh "$(emite_write "$PROJ/docs/enlace-roto.md" 'hola')" 15
if [ "$CRONO_RC" -ne 124 ] && printf '%s' "$SALIDA_HOOK" | grep -q '"deny"'; then
  echo "  PASS  SEC-004 CA-50b enlace ROTO: responde deny (${CRONO_MS}ms), ni cuelga ni revienta"; PASS=$((PASS+1))
else
  echo "  FAIL  SEC-004 CA-50b enlace roto: rc=$CRONO_RC ${CRONO_MS}ms, salida=<${SALIDA_HOOK:0:80}>"; diag; FAIL=$((FAIL+1))
fi
# CA-50 (c) — DESVIACION DECLARADA. El criterio pide `allow` para un enlace que apunta
# FUERA del proyecto, porque esta escrito suponiendo la salida (a), la que RESUELVE el
# destino. La salida elegida es fail-closed SIN resolver, y sin resolver no se puede saber
# adonde apunta: el enlace esta DENTRO del proyecto y se deniega por lo que es, no por
# adonde va. Lo que si se conserva del criterio es que el arnes NO SE SALE DE LA RAIZ.
ln -sf /etc/hostname "$PROJ/docs/enlace-fuera.md"
check "SEC-004 CA-50c enlace que apunta FUERA -> deny, no allow" deny \
  guard-codigo.sh "$(emite_write "$PROJ/docs/enlace-fuera.md" 'hola')"
# ...y el control que sostiene la desviacion: un enlace que esta FUERA del proyecto no es
# asunto del arnes y no se juzga.
FUERA33="$(mktemp -d)"; printf 'x\n' > "$FUERA33/real.md"; ln -sf "$FUERA33/real.md" "$FUERA33/enlace.md"
check "SEC-004 CA-50c control: un enlace FUERA del proyecto no se juzga -> allow" allow \
  guard-codigo.sh "$(emite_write "$FUERA33/enlace.md" 'hola')"
rm -rf "$FUERA33"
# CA-50 (d): el camino comun de Bash no paga NADA por esto.
check "SEC-004 CA-50d el camino comun de Bash ('ls -la') sigue -> allow" allow \
  guard-codigo.sh "$(jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"ls -la"}}')"
# ...y el agente de codigo TAMPOCO escribe a traves de un enlace: la puerta es sobre la
# FORMA de la escritura, no sobre quien la hace.
check "SEC-004 el desarrollador tampoco escribe a traves de un enlace -> deny" deny \
  guard-codigo.sh "$(jq -n --arg fp "$PROJ/docs/enlace-src.md" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,agent_id:"a1",agent_type:"desarrollador",tool_input:{file_path:$fp,content:"hola"}}')"

# ---------- SEC-006 parte (a) (CA-53): control obligatorio de la decision ----------
# La ampliacion de `codigo_app.globs` es MAPEO DE ESTE REPOSITORIO, no mecanismo: ninguna
# plantilla puede ganarla, o todos los proyectos que instalen el arnes la heredarian.
TPL33="$HOOKS_DIR/../templates/arnes-config.json.tpl"
if [ -f "$TPL33" ] && grep -Eq '\.arnes/config\.json|\.claude-plugin' "$TPL33"; then
  echo "  FAIL  REQ-007 CA-53 la plantilla arnes-config.json.tpl gano los globs de este repo"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-53 la ampliacion NO se propaga a templates/arnes-config.json.tpl"; PASS=$((PASS+1))
fi
# Y el mecanismo que la hace valer: con esos globs declarados, la coordinadora no escribe
# el manifiesto y el agente de codigo si. Se mide sobre un proyecto efimero, no sobre este
# repositorio: el banco no puede depender del mapeo de quien lo corre.
M33="$RAIZ/m33-$BASHPID"; mkdir -p "$M33/.arnes" "$M33/.claude-plugin" "$M33/requirements"
jq '.codigo_app.globs = ["hooks/*",".arnes/config.json",".claude-plugin/*"]' <<< "$MANIFIESTO_BASE" > "$M33/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$M33/PENDING_APPROVAL.md"
CLAUDE_PROJECT_DIR="$M33" check "REQ-007 CA-53 la coordinadora NO escribe .arnes/config.json -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$M33" emite_write "$M33/.arnes/config.json" '{}')"
CLAUDE_PROJECT_DIR="$M33" check "REQ-007 CA-53 ...ni .claude-plugin/plugin.json -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$M33" emite_write "$M33/.claude-plugin/plugin.json" '{}')"
CLAUDE_PROJECT_DIR="$M33" check "REQ-007 CA-53 el desarrollador SI lo escribe -> allow" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$M33" jq -n --arg fp "$M33/.arnes/config.json" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,agent_id:"a1",agent_type:"desarrollador",tool_input:{file_path:$fp,content:"{}"}}')"
# ---------- SEC-005 (CA-51/CA-52): un manifiesto ROTO no es un manifiesto AUSENTE ------
# Medido en la auditoria R-001: `arnes_parse_manifest` no miraba el codigo de salida de
# `arnes_jq_file`, y `arnes_jq_file` deja `ARNES_JQ` CON SU VALOR ANTERIOR cuando jq falla.
# El valor anterior era el analisis del INPUT: las variables del manifiesto se rellenaban
# con campos que controla quien llama (`ARNES_AGENTE_CODIGO` = `Bash`, el `tool_name`) y
# los globs quedaban vacios. Todo permitido, en silencio, con las invariantes declaradas.
R33="$RAIZ/r33-$BASHPID"; mkdir -p "$R33/.arnes" "$R33/requirements" "$R33/src" "$R33/docs"
printf '## Pendientes\n\n## Resueltas\n' > "$R33/PENDING_APPROVAL.md"
roto33() { printf '%s' "$1" > "$R33/.arnes/config.json"; }
# Las cuatro formas del criterio: invalido, vacio, `null` y un array. Las tres ultimas son
# JSON VALIDO, que es lo que las hacia peligrosas: jq las atravesaba sin fallar.
roto33 '{ "codigo_app": '
CLAUDE_PROJECT_DIR="$R33" check_motivo "REQ-007 CA-51 SEC-005 manifiesto INVALIDO: Write -> deny con motivo" \
  'no se puede leer|NO se puede leer' guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
roto33 ''
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 manifiesto VACIO -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
roto33 'null'
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 manifiesto 'null' (JSON valido) -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
roto33 '[1,2]'
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 manifiesto ARRAY (JSON valido) -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 ...y la puerta de cierre tampoco deja pasar" deny \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/requirements/REQ-870.md" 'Estado: completado')"
# El aviso de un manifiesto ilegible va por `arnes_warn`, o sea por STDERR, y NO por
# `systemMessage`. Se emite SIEMPRE QUE EL MANIFIESTO SE CONSULTA —tambien cuando la
# llamada se permite: aqui el comando escribe fuera de toda ruta protegida y aun asi hubo
# que leer el manifiesto para saberlo—. Se comprueba donde vive.
# DEV 1.31.0 v2 (QA-104): la sonda era `ls -la`, que NO escribe nada y por tanto ya no
# consulta el manifiesto; el aviso se sigue exigiendo, en la llamada que si lo consulta.
: > "$ERRLOG"
sal33="$(CLAUDE_PROJECT_DIR="$R33" jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"cat notas.md"}}' \
  | CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard-codigo.sh" 2>"$ERRLOG")"
if [ ! -s "$ERRLOG" ] && ! printf '%s' "$sal33" | grep -q '"deny"'; then
  echo "  PASS  DEV 1.31.0 v2: QA-104 un comando que no escribe no consulta el manifiesto (ni avisa ni deniega)"; PASS=$((PASS+1))
else
  echo "  FAIL  DEV 1.31.0 v2: QA-104 un comando sin escrituras leyo el manifiesto o quedo denegado"; diag; FAIL=$((FAIL+1))
fi
: > "$ERRLOG"
# La llamada PERMITIDA con el manifiesto roto es la que lo repara (QA-105): se consulta el
# manifiesto, se avisa por stderr, y aun asi se deja pasar. Es la unica combinacion donde
# «avisa aunque permita» se puede observar, porque cualquier otra escritura se deniega.
sal33="$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'printf "{}" > .arnes/config.json' "" "" \
  | CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard-codigo.sh" 2>"$ERRLOG")"
if grep -q 'no se puede leer' "$ERRLOG" && ! printf '%s' "$sal33" | grep -q '"deny"'; then
  echo "  PASS  REQ-007 CA-51 SEC-005 el aviso se emite siempre que el manifiesto se consulta (stderr), tambien cuando permite"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-51 SEC-005 sin aviso en stderr, o la reparacion del manifiesto quedo denegada"; diag; FAIL=$((FAIL+1))
fi
# DEV 1.31.0 v2 (QA-105): CON EL MANIFIESTO ROTO, LA UNICA ESCRITURA QUE SE PERMITE ES LA
# DEL PROPIO MANIFIESTO. El motivo del deny recomienda «corrige el JSON», y desde que
# `.arnes/config.json` esta en `codigo_app.globs` esa salida estaba denegada para TODOS:
# el remedio que el mensaje ofrece tiene que existir por la via que el mensaje nombra.
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 manifiesto roto: Write al PROPIO manifiesto -> allow" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/.arnes/config.json" '{}')"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 ...tambien por Bash (la via que el motivo nombra)" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'printf "{}" > .arnes/config.json' "" "")"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 ...y la puerta de cierre tampoco lo estorba" allow \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/.arnes/config.json" '{}')"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 control: cualquier OTRA ruta sigue denegada" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 control: reparar Y escribir otra cosa no es reparar -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'printf "{}" > .arnes/config.json; echo x > docs/x.md' "" "")"
# La excepcion es de UN ARCHIVO, no del modo degradado: no se extiende por vecindad.
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 control: otro archivo bajo .arnes/ NO repara nada -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/.arnes/migracion.md" 'hola')"
# El fail-closed de SEC-005 no se debilita por leer el manifiesto mas tarde: un comando de
# Bash que SI escribe lo consulta, no puede leerlo, y deniega igual que antes.
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-104 control: manifiesto roto + Bash que escribe -> deny (el fail-closed sigue)" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'echo x > src/a.ts' "" "")"
# Y el motivo nombra una salida ALCANZABLE: un remedio que el propio arnes deniega no es un
# remedio. Es la mitad de diagnostico del hallazgo QA-105.
CLAUDE_PROJECT_DIR="$R33" check_motivo "DEV 1.31.0 v2: QA-105 el motivo dice que la reparacion del manifiesto SI se puede" \
  "UNICA escritura permitida es la del propio" guard-codigo.sh \
  "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
# NINGUNA VARIABLE DEL MANIFIESTO SE RELLENA CON CAMPOS DEL INPUT. Es la mitad grave del
# hallazgo: no es solo que permitiera, es que el llamante escribia quien es el agente
# autorizado. Se mide leyendo las variables, no la decision.
fuga33="$(CLAUDE_PROJECT_DIR="$R33" bash -c '. "'"$HOOKS_DIR"'/lib.sh"
  ARNES_INPUT="$(jq -n "{tool_name:\"Bash\",agent_type:\"qa-tester\",tool_input:{file_path:\"/x\",command:\"c\"}}")"
  arnes_project_dir "$ARNES_INPUT"; ARNES_MANIFEST="'"$R33"'/.arnes/config.json"
  arnes_parse_input; arnes_parse_manifest 2>/dev/null
  printf "%s|%s|%s" "$ARNES_AGENTE_CODIGO" "$ARNES_REQ_DIR" "${#ARNES_GLOBS[@]}"')"
if [ "$fuga33" = "||0" ]; then
  echo "  PASS  REQ-007 CA-51 SEC-005 ninguna variable del manifiesto se rellena con el input"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-51 SEC-005 fuga del input al manifiesto: <$fuga33> (esperado '||0')"; FAIL=$((FAIL+1))
fi
# CA-52: LOS CONTROLES QUE YA PASABAN NO CAMBIAN. Un fail-closed nuevo que rompa el modo
# inerte convertiria el arreglo en un estorbo para todo proyecto que no usa el arnes.
rm -f "$R33/.arnes/config.json"
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-52 control: manifiesto AUSENTE sigue INERTE -> allow" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/src/a.ts" 'hola')"
printf '%s\n' "$MANIFIESTO_BASE" > "$R33/.arnes/config.json"
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-52 control: manifiesto VALIDO decide igual que siempre -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/src/a.ts" 'hola')"
CLAUDE_PROJECT_DIR="$R33" check_aviso "REQ-007 CA-52 control: un manifiesto VALIDO no emite NINGUN aviso" \
  no '' guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
# La clave OPCIONAL ausente sigue cayendo al defecto del codigo, sin denegar ni avisar:
# "no declarado" no puede confundirse con "ilegible".
CLAUDE_PROJECT_DIR="$R33" check_aviso "REQ-007 CA-52 control: 'limites' ausente cae al defecto sin avisar ni denegar" \
  no '' guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"cat src/a.ts"}}')"

# DEV 1.31.0 v2 (QA-106/QA-107): UNA SOLA REGLA PARA TODOS LOS TIPOS. Lo que no tiene el
# tipo que la clave espera cae al valor por defecto Y SE DICE, nombrando clave y valor. La
# asimetria era el hallazgo: `exigir_fecha: "true"` apagaba la puerta en silencio mientras
# el techo de Bash si avisaba ante el mismo error.
tipo33() {   # <nombre> <filtro jq sobre el manifiesto> <patron esperado en stderr|-> 
  local nombre="$1" filtro="$2" patron="$3" hay entrada
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  # DEV 1.32.0 (REQ-014 CA-06): este ayudante juzga el STDERR del hook, y sus casos de
  # control esperan SILENCIO. Con el emisor mudo el stderr también sale vacío y el
  # control pasaría en falso: es la invariante 1 del banco, con otra boca. La guarda va
  # sobre la ENTRADA, que es lo que puede quedarse callado.
  entrada="$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
  json_no_vacio "$nombre" "$entrada" || { FAIL=$((FAIL+1)); return 0; }
  jq "$filtro" "$R33/.arnes/config.json" > "$R33/.arnes/c.tmp" && mv "$R33/.arnes/c.tmp" "$R33/.arnes/config.json"
  : > "$ERRLOG"
  CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard-codigo.sh" >/dev/null 2>"$ERRLOG" <<< "$entrada"
  if [ "$patron" = "-" ]; then
    if [ -s "$ERRLOG" ]; then echo "  FAIL  $nombre  aviso inesperado"; diag; FAIL=$((FAIL+1)); else echo "  PASS  $nombre"; PASS=$((PASS+1)); fi
    return 0
  fi
  if grep -qE "$patron" "$ERRLOG"; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  el aviso no casa /$patron/"; diag; FAIL=$((FAIL+1)); fi
}
tipo33 "DEV 1.31.0 v2: QA-106 'exigir_fecha' con la cadena \"true\" avisa y cae al defecto" \
  '.veredictos.exigir_fecha = "true"' "veredictos.exigir_fecha.*\"true\""
tipo33 "DEV 1.31.0 v2: QA-106 'exigir_fecha' con el numero 1 avisa igual" \
  '.veredictos.exigir_fecha = 1' 'veredictos.exigir_fecha.*1'
tipo33 "DEV 1.31.0 v2: QA-106 control: el booleano de verdad no avisa" \
  '.veredictos.exigir_fecha = true' '-'
tipo33 "DEV 1.31.0 v2: QA-107 'bash_max_analisis: 1e9' avisa en vez de caer callado" \
  '.limites.bash_max_analisis = 1e9' 'bash_max_analisis.*no es un entero positivo'
tipo33 "DEV 1.31.0 v2: QA-107 'bash_max_analisis: 1.5' avisa igual" \
  '.limites.bash_max_analisis = 1.5' 'bash_max_analisis.*no es un entero positivo'
tipo33 "DEV 1.31.0 v2: QA-107 control: un entero valido no avisa" \
  '.limites.bash_max_analisis = 131072' '-'
tipo33 "DEV 1.31.0 v2: QA-106 'git.activo' con cadena avisa y manda el defecto (encendida)" \
  '.git.activo = "false"' 'git.activo.*"false"'
tipo33 "DEV 1.31.0 v2: QA-106 'codigo_app.globs' que no es un array avisa" \
  '.codigo_app.globs = "src/**"' 'codigo_app.globs.*src'
# La puerta sigue decidiendo con el defecto, que es lo que hace segura la caida: `git.activo`
# con un tipo raro NO apaga guard-git.
tipo33 "DEV 1.31.0 v2: QA-106 control: el manifiesto ya reparado no avisa" \
  '.codigo_app.globs = ["src/**"] | .git = {} | del(.limites) | del(.veredictos)' '-'
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-106 'git.activo' con cadena no apaga la puerta de git -> deny" deny \
  guard-git.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'git clean -fd' "" "")"

# --- DEV 1.31.0 v2 (QA-104): EL COSTE DEL CAMINO COMUN, MEDIDO EN PROCESOS ---------
# El reloj no sirve para esto: en Linux un fork son milisegundos y en Windows entre 1,2 y
# 6 s, asi que el umbral de tiempo que aqui pasaria alli no diria nada. Lo que se fija es
# el NUMERO DE PROCESOS `jq`, que es la magnitud que cambia de plataforma. Se cuenta con un
# `jq` instrumentado primero en el PATH que registra su llamada y delega en el real.
JQ33="$(mktemp -d)"; CNT33="$JQ33/llamadas"
JQREAL="$(command -v jq)"
{ printf '#!/usr/bin/env bash\n'; printf 'echo x >> "%s"\n' "$CNT33"; printf 'exec "%s" "$@"\n' "$JQREAL"; } > "$JQ33/jq"
chmod +x "$JQ33/jq"
cuenta_jq33() {   # <comando de Bash> -> numero de procesos jq de UNA invocacion de guard.sh
  local entrada; entrada="$(CLAUDE_PROJECT_DIR="$R33" emite_bash "$1" "" "")"
  : > "$CNT33"
  printf '%s' "$entrada" | PATH="$JQ33:$PATH" CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard.sh" >/dev/null 2>/dev/null
  grep -c x "$CNT33" 2>/dev/null || echo 0
}
for par in "ls -la" "npm run build"; do
  n33="$(cuenta_jq33 "$par")"
  if [ "$n33" = "1" ]; then
    echo "  PASS  DEV 1.31.0 v2: QA-104 '$par' cuesta 1 proceso jq (como v1.30.3)"; PASS=$((PASS+1))
  else
    echo "  FAIL  DEV 1.31.0 v2: QA-104 '$par' cuesta $n33 procesos jq y v1.30.3 costaba 1"; FAIL=$((FAIL+1))
  fi
done
rm -rf "$JQ33"
