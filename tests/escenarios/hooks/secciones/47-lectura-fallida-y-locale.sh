# Sección 47 del banco — 47-lectura-fallida-y-locale
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# 1.36.0, paso 5 (SEC-127 y QA-007-06), fase 1: casos SIN REPARAR, a nivel de hook y de librería.
#   RF  QA-007-06 (REQ-007 CA-47 punto 20, «Pendiente hasta SEC-127»): si el `read` de la entrada
#       falla con error, por cualquier causa —medidas: la entrada estándar CERRADA y una entrada
#       estándar que es un DIRECTORIO—, el hook deniega a todo agente, con el motivo de la entrada
#       ilegible, por guard.sh y por cada guardián del `matcher` de hooks/hooks.json;
#   RL  el límite declarado sin CLAUDE_PROJECT_DIR: sin proyecto que sacar de la entrada, sin decisión;
#   LO  SEC-127 (R-052 §4): el locale del proceso que juzga, LEÍDO DESPUÉS del atajo de guard-completado
#       (`arnes_estado_ausente`), es el de antes, en modo normal y en modo POSIX, con las dos respuestas
#       del atajo. En bash 5.1 o posterior la fuga no ocurre: estos casos NO son el fail-before (R-052 §4);
#   LK  SEC-127, la consecuencia: el cierre por Bash de un REQ con estado terminal no ASCII (`terminé`)
#       escrito `TERMINÉ` deniega con el locale del entorno en UTF-8 —lo que un locale C que sobreviviera
#       al atajo volvería allow (simulación de R-052, `94-`)—.
# DOS ÁRBOLES (RF, RL, LK): la CANDIDATA (`$HOOKS_DIR`) y v1.35.0 (3956a6f, REQ-007 CA-69 punto 1), por
# SHA con `mat47` (copia de `mat46`); sin ella, SKIP y motivo, nunca PASS. LO sólo en la candidata: en
# v1.35.0 el atajo no existe. Esto NO es la validación en el host.
CASOS_ESPERADOS_SECCION=32
PISO_AUTONOMO_SECCION=63  # 21 preámbulo (líneas 1-21, con seccion_nueva) + 24 maquinaria compartida duplicada (REPO47, mat47_reg y mat47, copia de mat46, líneas 22-45) + 18 bloque indivisible mayor (g47, líneas 57-74)
seccion_nueva "--- 47 · lectura fallida de la entrada y locale tras el atajo (QA-007-06, SEC-127; REQ-007 CA-47 punto 20, CA-54) ---"
REPO47="${SEC_DIR%/}/../../../.."; MAT47_RUTAS='hooks'; MAT47_REG=''; MAT47_T0=0; MAT47_REF='-'
mat47_reg() {   # <estado> <motivo> <archivos> <procesos> -> MAT47_REG, UNA sola línea (la lee `sonda_lee`)
  local mot="${2//[[:space:]]/_}"; [ -n "$mot" ] || mot='-'
  MAT47_REG="sonda=linea-base modo=medicion estado=$1 motivo=$mot corrida=${ARNES_CORRIDA:-desconocido} invocacion=$BASHPID-$MAT47_T0 arbol=${ARNES_ARBOL:-desconocido} k=1 r=1 us=$(( ${EPOCHREALTIME/./} - MAT47_T0 )) procesos=$4 etiqueta=$MAT47_REF ref=$MAT47_REF archivos=$3"
}
# mat47 <ref> <destino>: las propiedades de REQ-021 CA-05 —cada archivo con el contenido Y el modo del
# objeto de ESE árbol, verificados; `archivos=<n>`; y `sin-linea-base` con motivo, nunca un árbol a medias—.
mat47() {
  local ref="$1" dst="$2" lista m o r i n=0 hs; local -a modos=() oids=() rutas=()
  MAT47_T0=${EPOCHREALTIME/./}; MAT47_REF="${ref//[[:space:]]/_}"
  lista="$(git -C "$REPO47" ls-tree -r "$ref" -- $MAT47_RUTAS 2>/dev/null)"
  [ -n "$lista" ] || { mat47_reg sin-linea-base "la-referencia-no-resuelve:$ref" desconocido 1; return 1; }
  while IFS=$' \t' read -r m _ o r; do n=$((n + 1)); modos+=("$m"); oids+=("$o"); rutas+=("$dst/$r"); done <<< "$lista"
  mkdir -p "$dst" && git -C "$REPO47" archive "$ref" $MAT47_RUTAS 2>/dev/null | tar -x -C "$dst" 2>/dev/null \
    || { mat47_reg sin-linea-base no-se-pudo-materializar desconocido 4; return 1; }
  hs="$(printf '%s\n' "${rutas[@]}" | git -C "$REPO47" hash-object --stdin-paths 2>/dev/null)"$'\n'
  for ((i = 0; i < n; i++)); do
    [ "${hs%%$'\n'*}" = "${oids[i]}" ] || { mat47_reg sin-linea-base "el-contenido-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
    hs="${hs#*$'\n'}"
    case "${modos[i]}" in *755) [ -x "${rutas[i]}" ] ;; *) [ ! -x "${rutas[i]}" ] ;; esac \
      || { mat47_reg sin-linea-base "el-modo-no-coincide-en:${rutas[i]#"$dst"/}" desconocido 6; return 1; }
  done
  mat47_reg ok - "$n" 6
}
RV47="$RAIZ/rv135-47-$BASHPID"; RV47_OK=no; RV47_MOT=''
if mat47 3956a6f "$RV47"; then RV47_OK=si
else RV47_MOT="v1.35.0 no se materializó (${MAT47_REG#*motivo=})"; RV47_MOT="${RV47_MOT%% corrida=*})"; fi
v47() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
# El locale UTF-8 del que dependen LO y LK. Sin él, «igual» y «deniega» no distinguirían nada: SKIP con motivo.
UTF47="$(env -u LC_ALL LANG=C.UTF-8 "$BASH" -c 'x=ñ; printf %s "${#x}"' 2>/dev/null)"
U47_MOT='el locale C.UTF-8 no está disponible en este anfitrión: el caso no distinguiría'
# El proyecto de LK, con el estado terminal del manifiesto `terminé`, y un directorio para la entrada.
P47="$PROJ"; T47="$RAIZ/t47-$BASHPID"; DIR47="$RAIZ/d47-$BASHPID"; mkdir -p "$T47/.arnes" "$T47/requirements" "$DIR47"
jq '.estados.completado = "terminé"' "$PROJ/.arnes/config.json" > "$T47/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$T47/PENDING_APPROVAL.md"; printf '# REQ-900\nEstado: en-revision\n' > "$T47/requirements/REQ-900.md"
# g47 <dir de hooks> <guardián> <entrada> -> D47 (deny | nada) y M47 (el motivo). La entrada es `cerrada`,
# `directorio` (la entrada estándar es ese directorio) o el JSON; `PD47` es el proyecto, y vacío, sin
# CLAUDE_PROJECT_DIR y con el proceso en el directorio del proyecto. Locale del entorno: C.UTF-8.
# SIN `env` delante del hook: medido, `env … bash guard.sh <&-` le entrega un descriptor 0 abierto y el
# caso deja de medir la entrada cerrada (sec127/07-). El entorno se prepara en el subshell y se exporta.
D47=''; M47=''; PD47="$P47"
g47() {
  local h="$1" s="$2" e="$3" out
  out="$(cd "$P47" || exit; unset LC_ALL POSIXLY_CORRECT CLAUDE_PROJECT_DIR; export LANG=C.UTF-8
    [ -z "$PD47" ] || export CLAUDE_PROJECT_DIR="$PD47"
    case "$e" in
      cerrada)    "$BASH" "$h/$s" <&- ;;
      directorio) "$BASH" "$h/$s" < "$DIR47" ;;
      *)          printf '%s' "$e" | "$BASH" "$h/$s" ;;
    esac 2>>"$ERRLOG")"
  case "$out" in *'"permissionDecision":"deny"'*) D47=deny ;; *) D47=nada ;; esac
  M47="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
# fila47 <nombre> <candidata> <v1.35.0> <cita|-> <entrada> <guardianes…>: por guardián, un caso en cada árbol.
# La CITA se exige al `deny` de la candidata; en v1.35.0 se juzga la decisión.
fila47() {
  local nom0="$1" ec="$2" ev="$3" cita="$4" e="$5" s nom etq; shift 5
  case "$ec:$ev" in deny:nada) etq='fail-before: sin decisión' ;; *) etq='control, decide igual' ;; esac
  for s in "$@"; do
    nom="$nom0 por $s"
    g47 "$HOOKS_DIR" "$s" "$e"
    if [ "$D47" != "$ec" ]; then v47 FAIL "$nom candidata  esperado=$ec got=$D47  <${M47:0:200}>"
    elif [ "$ec" = deny ] && [ "$cita" != - ] && [[ "$M47" != *"$cita"* ]]; then v47 FAIL "$nom candidata  el motivo no cita «$cita»  <${M47:0:200}>"
    else v47 PASS "$nom candidata  ($D47)"; fi
    if [ "$RV47_OK" != si ]; then v47 SKIP "$nom v1.35.0: $etq  $RV47_MOT"; continue; fi
    g47 "$RV47/hooks" "$s" "$e"
    if [ "$D47" = "$ev" ]; then v47 PASS "$nom v1.35.0: $etq  ($D47)"; else v47 FAIL "$nom v1.35.0: $etq  esperado=$ev got=$D47"; fi
  done
}
# lo47 <dir de hooks> <normal|posix> <texto> <estado> -> LO47: «igual»; la diferencia (antes/después);
# «no-existe» si el árbol no tiene el atajo; «no-utf8» si el locale de partida no era UTF-8; «modo» si
# el proceso no arrancó en el modo pedido. Las tres últimas no miden nada: nunca PASS.
lo47() {
  local pos=; [ "$2" != posix ] || pos=1
  LO47="$(env -u LC_ALL -u LC_CTYPE -u POSIXLY_CORRECT LANG=C.UTF-8 ${pos:+POSIXLY_CORRECT=1} "$BASH" -c '
    . "$1/lib.sh" 2>/dev/null
    declare -F arnes_estado_ausente >/dev/null || { printf no-existe; exit 0; }
    x="ñandú"; [ "${#x}" -eq 5 ] || { printf no-utf8; exit 0; }
    p=normal; [[ :$SHELLOPTS: != *:posix:* ]] || p=posix; [ "$p" = "$4" ] || { printf "modo %s" "$p"; exit 0; }
    a="LC_ALL=${LC_ALL-<sin-definir>} LC_CTYPE=${LC_CTYPE-<sin-definir>} LANG=${LANG-} len=${#x}"
    arnes_estado_ausente "$2" "$3" >/dev/null 2>&1; rc=$?
    b="LC_ALL=${LC_ALL-<sin-definir>} LC_CTYPE=${LC_CTYPE-<sin-definir>} LANG=${LANG-} len=${#x}"
    if [ "$a" = "$b" ]; then printf "igual rc=%s" "$rc"; else printf "antes[%s] después[%s] rc=%s" "$a" "$b" "$rc"; fi
  ' _ "$1" "$3" "$4" "$2" 2>/dev/null)"
}

# --- QA-007-06: el `read` de la entrada falla con error -> deny a todo agente (RF) -----------------------
IL47='la entrada de esta llamada no se pudo leer'; G47='guard.sh guard-codigo.sh guard-completado.sh guard-git.sh'
fila47 "QA-007-06 RF1 la entrada estándar está cerrada"          deny nada "$IL47" cerrada    $G47
fila47 "QA-007-06 RF2 la entrada estándar es un directorio"      deny nada "$IL47" directorio $G47
# RL: el límite de CA-47 punto 20 —sin CLAUDE_PROJECT_DIR no hay proyecto que sacar de la entrada—, inerte.
PD47=''
fila47 "QA-007-06 RL1 sin CLAUDE_PROJECT_DIR, la entrada estándar cerrada: sin proyecto, sin decisión"     nada nada - cerrada    guard.sh
fila47 "QA-007-06 RL2 sin CLAUDE_PROJECT_DIR, la entrada estándar es un directorio: sin decisión"          nada nada - directorio guard.sh
PD47="$P47"

# --- SEC-127: el locale del proceso que juzga, leído DESPUÉS del atajo (LO) -------------------------------
for m47 in normal posix; do
  for c47 in "ascii:echo hola > requirements/REQ-900.md" "no-ascii:sed -i 's/en-revisión/listo/' requirements/REQ-900.md"; do
    nom47="SEC-127 LO el locale tras arnes_estado_ausente es el de antes (modo $m47, texto ${c47%%:*}, estado completado)"
    lo47 "$HOOKS_DIR" "$m47" "${c47#*:}" completado
    case "$LO47" in
      igual*)    v47 PASS "$nom47 candidata  ($LO47)" ;;
      no-existe) v47 SKIP "$nom47 candidata  el atajo no existe en este árbol (lo introdujo 82ceb63): SEC-127 no existía" ;;
      no-utf8)   v47 SKIP "$nom47 candidata  $U47_MOT" ;;
      antes*)    v47 FAIL "$nom47 candidata  el locale cambió: $LO47" ;;
      *)         v47 FAIL "$nom47 candidata  no midió: <$LO47>" ;;
    esac
  done
done

# --- SEC-127: la consecuencia, el cierre por Bash con estado no ASCII (LK) --------------------------------
PD47="$T47"
for a47 in - desarrollador; do
  k47="$(jq -cn --arg c "$T47" --arg a "$a47" --arg k "sed -i 's/en-revision/TERMINÉ/' requirements/REQ-900.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)')"
  if [ "$UTF47" != 1 ]; then for s47 in guard.sh guard-completado.sh; do v47 SKIP "SEC-127 LK $s47 candidata  $U47_MOT"; v47 SKIP "SEC-127 LK $s47 v1.35.0  $U47_MOT"; done; continue; fi
  fila47 "SEC-127 LK cierre de REQ-900 a TERMINÉ (estado terminé) por Bash, agente ${a47/#-/coordinadora}, locale UTF-8" deny deny "menciona 'terminé'" \
    "$k47" guard.sh guard-completado.sh
done
PD47="$P47"
rm -rf "$RV47" "$T47" "$DIR47"
