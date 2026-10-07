#!/usr/bin/env bash
# 10-sondas.sh <dir-hooks> <etiqueta> <caso>... — SEC-132 (a), sondas de QA a nivel de hook, por guard.sh, como lo
# lanza el cliente (timeout 60, LANG=C.UTF-8, sin LC_ALL, cwd y CLAUDE_PROJECT_DIR = proyecto). Un caso = un cierre
# por Edit de un REQ con todo en verde y las quality gates del caso. Mide:
#   hook  = ms hasta que el proceso del hook sale;  eof = ms hasta que la salida (stdout+stderr, una tubería) se cierra
#           —si algo que lanzó la gate retiene la tubería, el cliente no ve el final aunque el hook haya decidido—;
#   dec   = deny | nada | otra;  cerrado = si el REQ queda en completado (si no hubo deny, se aplica el Edit);
#   vivos = procesos con la marca del caso que siguen vivos 1 s después de la decisión (luego se matan con -9).
set -u
H="$1"; ET="$2"; shift 2
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; export TMPDIR=$S
M="7$$"   # marca de esta corrida (en los argumentos de los sleep)
gates_de() {   # <caso> -> JSON de quality_gates
  case "$1" in
    cuatro20)    printf '%s' '["sleep 20","sleep 20","sleep 20","sleep 20"]' ;;
    colgada)     printf '["sleep 599.%s"]' "$M" ;;
    control)     printf '%s' '["true","true"]' ;;
    eq-false)    printf '%s' '["true","exit 0","false"]' ;;
    eq-cd)       printf '%s' '["cd /no/existe/qa5 && true"]' ;;
    eq-exit3)    printf '%s' '["exit 3"]' ;;
    eq-sub3)     printf '%s' '["(exit 3)","true"]' ;;
    eq-exit0)    printf '%s' '["exit 0","true"]' ;;
    eq-salida)   printf '%s' '["echo hola; echo adios >&2; exit 4"]' ;;
    trap-legit)  printf '%s' '["trap \"rm -f /tmp/qa5-no-existe\" EXIT; true"]' ;;
    trap-echo)   printf '%s' '["trap \"echo limpieza\" EXIT; true"]' ;;
    exec-true)   printf '%s' '["exec true"]' ;;
    exec-false)  printf '%s' '["exec false"]' ;;
    forja-trap)  printf '%s' '["trap \"echo 0\" EXIT; false"]' ;;
    forja-fd3)   printf '%s' '["echo 0 >&3; false"]' ;;
    f29)         printf '%s' '["sleep 29"]' ;;
    f31)         printf '%s' '["sleep 31"]' ;;
    par15)       printf '%s' '["sleep 15","sleep 15.5"]' ;;
    noempieza)   printf '%s' '["sleep 29.95","true"]' ;;
    term-ign)    printf '["trap \\"\\" TERM; sleep 598.%s"]' "$M" ;;
    term-ign-h)  printf '["sh -c \\"trap \\\\\\"\\\\\\" TERM; sleep 597.%s\\" & sleep 596.%s"]' "$M" "$M" ;;
    setsid-f)    printf '["setsid -f sleep 595.%s; sleep 594.%s"]' "$M" "$M" ;;
    doble-fork)  printf '["( sleep 593.%s & ); sleep 592.%s"]' "$M" "$M" ;;
    setsid-h)    printf '["setsid sleep 591.%s & sleep 590.%s"]' "$M" "$M" ;;
    profundo)    printf '["f(){ if [ $1 -gt 0 ]; then ( f $(( $1 - 1 )) ); else sleep 589.%s; fi; }; f 60"]' "$M" ;;
    ancho)       printf '["for i in $(seq 300); do sleep 588.%s & done; wait"]' "$M" ;;
    ancho4500)   printf '["for i in $(seq 4500); do sleep 587.%s & done; wait"]' "$M" ;;
    ancho9000)   printf '["for i in $(seq 9000); do sleep 579.%s & done; wait"]' "$M" ;;
    ancho14000)  printf '["for i in $(seq 14000); do sleep 578.%s & done; wait"]' "$M" ;;
    escribe)     printf '["while :; do echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; done; : 586.%s"]' "$M" ;;
    escribe-fd3) printf '["yes >&3; : 585.%s"]' "$M" ;;
    cierra-out)  printf '["exec >&- 2>&-; sleep 584.%s"]' "$M" ;;
    cierra-fd3)  printf '["exec 3>&-; sleep 583.%s"]' "$M" ;;
    bg-sale0)    printf '["sleep 582.%s & true"]' "$M" ;;
    *) return 1 ;;
  esac
}
for caso in "$@"; do
  g="$(gates_de "$caso")" || { echo "$ET $caso: caso desconocido"; continue; }
  P="$S/qa5p-$caso-$$"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
  jq -n --argjson g "$g" '{codigo_app:{globs:["src/**"]},agentes:{agente_codigo:"desarrollador"},quality_gates:$g}' > "$P/.arnes/config.json"
  printf '# REQ-900\nEstado: en-revision\nQA: aprobado\nSeguridad: aprobado\nSensible a seguridad: si\n' > "$P/requirements/REQ-900.md"
  git -C "$P" init -q && git -C "$P" add -A && git -C "$P" -c user.name=qa -c user.email=qa@invalid -c core.hooksPath=/dev/null \
    -c commit.gpgsign=false commit -qm base >/dev/null 2>&1
  jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:($c+"/requirements/REQ-900.md"),old_string:"Estado: en-revision",new_string:"Estado: completado"}}' > "$P.in"
  t0=${EPOCHREALTIME/./}
  out="$(cd "$P" && unset LC_ALL POSIXLY_CORRECT BASH_ENV SHELLOPTS; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"
         timeout 60 bash "$H/guard.sh" < "$P.in" 2>&1; echo "RC=$?"; echo "${EPOCHREALTIME/./}" > "$P.tsal")"
  t2=${EPOCHREALTIME/./}
  t1="$(cat "$P.tsal" 2>/dev/null || echo "$t2")"
  rc="${out##*RC=}"; out="${out%RC=*}"
  case "$out" in *'"permissionDecision":"deny"'*) dec=deny ;; '') dec=nada ;; *) dec=otra ;; esac
  mot="$(printf '%s' "$out" | jq -rs 'map(.hookSpecificOutput.permissionDecisionReason? // empty) | join(" ")' 2>/dev/null | cut -c1-260)"
  [ "$dec" = deny ] || (cd "$P" && sed -i 's/Estado: en-revision/Estado: completado/' requirements/REQ-900.md)
  grep -q '^Estado: completado' "$P/requirements/REQ-900.md" && cer=si || cer=no
  sleep 1; vivos="$(pgrep -fc "\.$M\b" 2>/dev/null)"; vivos="${vivos:-0}"
  [ "$vivos" = 0 ] || pkill -9 -f "\.$M\b" 2>/dev/null
  printf '%s | %-11s | rc=%s hook=%sms eof=%sms | dec=%s cerrado=%s vivos=%s | %s\n' "$ET" "$caso" "${rc//[^0-9]/}" \
    $(( (t1 - t0) / 1000 )) $(( (t2 - t0) / 1000 )) "$dec" "$cer" "$vivos" "${mot:-${out:0:200}}"
  rm -rf "$P" "$P.in" "$P.tsal"
done
